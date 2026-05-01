import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateContractDto } from './dto/create-contract.dto';

@Injectable()
export class ContractsService {
  constructor(private prisma: PrismaService) {}

  async create(dto: CreateContractDto) {
    const project = await this.prisma.project.findUnique({
      where: { id: dto.projectId },
      include: { phases: true, contract: true },
    });
    if (!project) throw new NotFoundException('Projeto não encontrado');

    if (project.status !== 'matched') {
      throw new BadRequestException(
        `Contrato só pode ser criado para projetos em status 'matched'. Status atual: '${project.status}'`,
      );
    }

    if (project.contract) throw new BadRequestException('Projeto já tem contrato');

    const worker = await this.prisma.worker.findUnique({ where: { id: dto.workerId } });
    if (!worker) throw new NotFoundException('Worker não encontrado');

    if (!worker.available) {
      throw new BadRequestException('Worker não está disponível para novos projetos');
    }

    const totalAmount = project.phases.reduce((sum, p) => sum + Number(p.amount), 0);

    const contract = await this.prisma.contract.create({
      data: {
        projectId: dto.projectId,
        workerId: dto.workerId,
        totalAmount,
      },
      include: { project: true, worker: { include: { user: true } } },
    });

    // Transição de estado: matched → contract_signed
    await this.prisma.project.update({
      where: { id: dto.projectId },
      data: { status: 'contract_signed' },
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

    if (contract.signedAt) throw new BadRequestException('Contrato já assinado');

    return this.prisma.contract.update({
      where: { id: contractId },
      data: { signedAt: new Date() },
    });
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
