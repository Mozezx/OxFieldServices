import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateContractDto } from './dto/create-contract.dto';

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
   *  - Permitido em status 'matched' (primeira atribuição) ou 'contract_signed'
   *    (troca de worker antes da assinatura/escrow).
   *  - Se já existe contrato, só pode ser trocado enquanto NÃO foi assinado pelo
   *    worker (`signedAt` nulo) e NÃO existe escrow associado.
   *  - Se for primeira atribuição (status 'matched'), transiciona o projeto para
   *    'contract_signed'. Em troca, o status fica como está.
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

    if (project.status !== 'matched' && project.status !== 'contract_signed') {
      throw new BadRequestException(
        `Atribuição de worker só é permitida em status 'matched' ou 'contract_signed' (troca). Status atual: '${project.status}'`,
      );
    }

    const existing = project.contract;
    if (existing) {
      if (existing.signedAt) {
        throw new BadRequestException(
          'Contrato já foi assinado pelo worker. Não é possível trocar de worker.',
        );
      }
      if (existing.escrow) {
        throw new BadRequestException(
          'Já existe escrow ativo para este contrato. Não é possível trocar de worker.',
        );
      }
      if (existing.workerId === dto.workerId) {
        throw new BadRequestException(
          'Esse worker já está atribuído a este projeto.',
        );
      }
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

    const totalAmount = project.phases.reduce(
      (sum, p) => sum + Number(p.amount),
      0,
    );

    // Transação: substitui o contrato antigo (se existir) e cria o novo.
    // Em primeira atribuição (status 'matched'), também avança o status.
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
