import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { UpdatePhaseStatusDto } from './dto/update-phase-status.dto';
import { PhaseStatus } from '@prisma/client';

@Injectable()
export class PhasesService {
  constructor(private prisma: PrismaService) {}

  /**
   * Retorna todas as fases de um projeto.
   */
  async findByProject(projectId: string) {
    const project = await this.prisma.project.findUnique({
      where: { id: projectId },
    });

    if (!project) {
      throw new NotFoundException('Projeto não encontrado');
    }

    const phases = await this.prisma.projectPhase.findMany({
      where: { projectId },
      orderBy: { order: 'asc' },
      include: {
        evidences: {
          select: {
            id: true,
            type: true,
            url: true,
            uploadedAt: true,
            uploadedBy: true,
          },
        },
      },
    });

    return phases.map((phase) => ({
      ...phase,
      amount: Number(phase.amount),
    }));
  }

  /**
   * Retorna uma fase específica.
   */
  async findOne(id: string) {
    const phase = await this.prisma.projectPhase.findUnique({
      where: { id },
      include: {
        project: {
          select: { id: true, title: true, clientId: true, status: true },
        },
        evidences: {
          select: {
            id: true,
            type: true,
            url: true,
            uploadedAt: true,
            uploadedBy: true,
          },
        },
      },
    });

    if (!phase) {
      throw new NotFoundException('Fase não encontrada');
    }

    return {
      ...phase,
      amount: Number(phase.amount),
    };
  }

  /**
   * Atualiza o status de uma fase.
   * Regras de transição entre status de fase:
   *   pending → in_progress (quando worker inicia)
   *   in_progress → evidence_uploaded (quando worker envia evidências)
   *   evidence_uploaded → under_review (automático ou admin)
   *   under_review → validated | rejected (cliente/admin valida)
   *   rejected → in_progress (worker corrige)
   */
  async updateStatus(
    id: string,
    userId: string,
    dto: UpdatePhaseStatusDto,
  ) {
    const phase = await this.prisma.projectPhase.findUnique({
      where: { id },
      include: {
        project: {
          select: { clientId: true, status: true },
        },
      },
    });

    if (!phase) {
      throw new NotFoundException('Fase não encontrada');
    }

    const { status: newStatus } = dto;
    const currentStatus = phase.status;

    // Validar transição de fase
    if (!this.isValidPhaseTransition(currentStatus, newStatus)) {
      throw new BadRequestException(
        `Transição inválida: ${currentStatus} → ${newStatus}`,
      );
    }

    // Verificar permissões
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new ForbiddenException('Usuário não encontrado');
    }

    // Apenas o cliente do projeto ou admin pode validar/rejeitar
    if (
      (newStatus === 'validated' || newStatus === 'rejected') &&
      phase.project.clientId !== userId &&
      user.role !== 'admin'
    ) {
      throw new ForbiddenException(
        'Apenas o cliente do projeto ou admin pode validar/rejeitar fases',
      );
    }

    // Só pode iniciar fase se projeto estiver em execução
    if (newStatus === 'in_progress' && phase.project.status !== 'in_execution') {
      throw new BadRequestException(
        'O projeto precisa estar em execução para iniciar fases',
      );
    }

    // Atualizar status
    const updated = await this.prisma.projectPhase.update({
      where: { id },
      data: { status: newStatus },
    });

    return {
      ...updated,
      amount: Number(updated.amount),
    };
  }

  // ─── Helpers ───────────────────────────────────────────

  private isValidPhaseTransition(
    current: PhaseStatus,
    next: PhaseStatus,
  ): boolean {
    const transitions: Record<PhaseStatus, PhaseStatus[]> = {
      pending: ['in_progress'],
      in_progress: ['evidence_uploaded'],
      evidence_uploaded: ['under_review'],
      under_review: ['validated', 'rejected'],
      validated: [],
      rejected: ['in_progress'],
    };

    return transitions[current]?.includes(next) ?? false;
  }
}
