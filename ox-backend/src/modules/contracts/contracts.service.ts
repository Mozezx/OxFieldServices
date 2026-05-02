import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { ProjectStatus } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateContractDto } from './dto/create-contract.dto';

const STATUS_ALLOW_ESCROW_REASSIGN: ProjectStatus[] = [
  ProjectStatus.matched,
  ProjectStatus.contract_signed,
  ProjectStatus.active_escrow,
  ProjectStatus.in_execution,
];

@Injectable()
export class ContractsService {
  constructor(
    private prisma: PrismaService,
    private eventEmitter: EventEmitter2,
  ) {}

  /**
   * Cria ou substitui o contrato de um projeto.
   *
   * Regras:
   *  - Primeira atribuição: status `matched` ou `contract_signed`.
   *  - Troca sem escrow: substitui o contrato (delete + create) enquanto o worker
   *    ainda não assinou.
   *  - Troca **com escrow**: atualiza `workerId` no mesmo contrato; o EscrowTxn e
   *    o pagamento Stripe permanecem; `signedAt` é limpo para o novo worker aceitar.
   *  - Nenhuma troca se já existir fase em andamento ou concluída (`!== pending`).
   */
  async create(dto: CreateContractDto) {
    const project = await this.prisma.project.findUnique({
      where: { id: dto.projectId },
      include: {
        phases: true,
        contract: { include: { escrow: true } },
      },
    });
    if (!project) throw new NotFoundException('Projeto não encontrado');

    const workStarted = project.phases.some((p) => p.status !== 'pending');
    if (workStarted) {
      throw new BadRequestException(
        'Não é possível trocar worker: já existe fase em andamento ou concluída.',
      );
    }

    const existing = project.contract;
    if (existing?.workerId === dto.workerId) {
      throw new BadRequestException('Esse worker já está atribuído a este projeto.');
    }

    const worker = await this.prisma.worker.findUnique({
      where: { id: dto.workerId },
    });
    if (!worker) throw new NotFoundException('Worker não encontrado');

    if (!worker.available) {
      throw new BadRequestException(
        'Worker não está disponível para novos projetos',
      );
    }

    // ── Mesmo contrato + escrow: fundos permanecem retidos; só muda o worker ──
    if (existing?.escrow) {
      if (!STATUS_ALLOW_ESCROW_REASSIGN.includes(project.status)) {
        throw new BadRequestException(
          `Troca com escrow não é permitida no status '${project.status}'.`,
        );
      }

      const updated = await this.prisma.$transaction(async (tx) => {
        const res = await tx.contract.update({
          where: { id: existing.id },
          data: {
            workerId: dto.workerId,
            signedAt: null,
          },
          include: {
            project: true,
            worker: { include: { user: true } },
            escrow: true,
          },
        });

        if (project.status === ProjectStatus.in_execution) {
          await tx.project.update({
            where: { id: dto.projectId },
            data: { status: ProjectStatus.active_escrow },
          });
        }

        return res;
      });

      this.eventEmitter.emit('worker.assigned', {
        contractId: updated.id,
        projectId: dto.projectId,
        workerId: dto.workerId,
      });

      return updated;
    }

    if (existing?.signedAt) {
      throw new BadRequestException(
        'Contrato já foi assinado pelo worker. Não é possível trocar de worker.',
      );
    }

    if (project.status !== 'matched' && project.status !== 'contract_signed') {
      throw new BadRequestException(
        `Atribuição de worker só é permitida em status 'matched' ou 'contract_signed' (troca). Status atual: '${project.status}'`,
      );
    }

    const totalAmount = project.phases.reduce(
      (sum, p) => sum + Number(p.amount),
      0,
    );

    const previousStatus = project.status;

    const contract = await this.prisma.$transaction(async (tx) => {
      if (existing) {
        await tx.contract.delete({ where: { id: existing.id } });
      }

      const created = await tx.contract.create({
        data: {
          projectId: dto.projectId,
          workerId: dto.workerId,
          totalAmount,
        },
        include: { project: true, worker: { include: { user: true } } },
      });

      if (project.status === 'matched') {
        await tx.project.update({
          where: { id: dto.projectId },
          data: { status: 'contract_signed' },
        });
      }

      return created;
    });

    this.eventEmitter.emit('contract.created', {
      contractId: contract.id,
      projectId: contract.projectId,
      workerId: contract.workerId,
    });

    if (previousStatus === ProjectStatus.matched) {
      this.eventEmitter.emit('project.status_changed', {
        projectId: dto.projectId,
        from: previousStatus,
        to: ProjectStatus.contract_signed,
      });
    }

    return contract;
  }

  async sign(contractId: string, userId: string) {
    const worker = await this.prisma.worker.findUnique({ where: { userId } });
    if (!worker) throw new NotFoundException('Worker não encontrado');

    const contract = await this.prisma.contract.findUnique({ where: { id: contractId } });
    if (!contract) throw new NotFoundException('Contrato não encontrado');

    if (contract.workerId !== worker.id) {
      throw new BadRequestException('Apenas o worker atribuído pode assinar o contrato');
    }

    if (contract.signedAt) {
      // Idempotente: assinar duas vezes não erra, apenas reaproveita
      return contract;
    }

    const updated = await this.prisma.contract.update({
      where: { id: contractId },
      data: { signedAt: new Date() },
    });

    // Notifica o módulo de pagamentos para tentar avançar o projeto
    // (caso o escrow já esteja ativo, vai disparar START)
    this.eventEmitter.emit('contract.signed', { contractId });

    return updated;
  }

  async findOne(contractId: string) {
    const contract = await this.prisma.contract.findUnique({
      where: { id: contractId },
      include: {
        project: { include: { phases: true } },
        worker: { include: { user: true } },
        escrow: { include: { payments: true } },
      },
    });
    if (!contract) throw new NotFoundException('Contrato não encontrado');
    return contract;
  }

  async findByProject(projectId: string) {
    return this.prisma.contract.findUnique({
      where: { projectId },
      include: { escrow: true },
    });
  }
}
