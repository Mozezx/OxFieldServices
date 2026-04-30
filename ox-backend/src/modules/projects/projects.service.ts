import {
  Injectable,
  BadRequestException,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateProjectDto } from './dto/create-project.dto';
import { UpdateProjectDto } from './dto/update-project.dto';
import { UpdateStatusDto } from './dto/update-status.dto';
import {
  getNextStatus,
  getAvailableEvents,
} from '../../common/state-machine/project.machine';
import { ProjectStatus, Prisma } from '@prisma/client';

@Injectable()
export class ProjectsService {
  constructor(private prisma: PrismaService) {}

  /**
   * Cria um novo projeto no status 'draft', com fases opcionais.
   */
  async create(clientId: string, dto: CreateProjectDto) {
    const { phases, ...projectData } = dto;

    const project = await this.prisma.project.create({
      data: {
        ...projectData,
        deadline: projectData.deadline
          ? new Date(projectData.deadline)
          : undefined,
        clientId,
        phases: phases?.length
          ? {
              create: phases.map((phase) => ({
                name: phase.name,
                order: phase.order,
                amount: phase.amount,
                status: 'pending',
              })),
            }
          : undefined,
      },
      include: {
        phases: { orderBy: { order: 'asc' } },
      },
    });

    return this.formatResponse(project);
  }

  /**
   * Lista projetos com filtros opcionais.
   */
  async findAll(params: {
    clientId?: string;
    status?: ProjectStatus;
    skip?: number;
    take?: number;
  }) {
    const where: Prisma.ProjectWhereInput = {};

    if (params.clientId) where.clientId = params.clientId;
    if (params.status) where.status = params.status;

    const [projects, total] = await Promise.all([
      this.prisma.project.findMany({
        where,
        skip: params.skip ?? 0,
        take: params.take ?? 20,
        orderBy: { createdAt: 'desc' },
        include: {
          phases: { orderBy: { order: 'asc' } },
          contract: true,
        },
      }),
      this.prisma.project.count({ where }),
    ]);

    return {
      data: projects.map((p) => this.formatResponse(p)),
      total,
      skip: params.skip ?? 0,
      take: params.take ?? 20,
    };
  }

  /**
   * Busca um projeto pelo ID.
   */
  async findOne(id: string) {
    const project = await this.prisma.project.findUnique({
      where: { id },
      include: {
        phases: { orderBy: { order: 'asc' } },
        contract: true,
        client: {
          select: { id: true, name: true, email: true },
        },
      },
    });

    if (!project) {
      throw new NotFoundException('Projeto não encontrado');
    }

    return this.formatResponse(project);
  }

  /**
   * Atualiza dados do projeto (não muda status).
   */
  async update(id: string, userId: string, dto: UpdateProjectDto) {
    const project = await this.prisma.project.findUnique({
      where: { id },
    });

    if (!project) {
      throw new NotFoundException('Projeto não encontrado');
    }

    if (project.clientId !== userId) {
      throw new ForbiddenException('Você não é o dono deste projeto');
    }

    const updated = await this.prisma.project.update({
      where: { id },
      data: {
        ...dto,
        deadline: dto.deadline ? new Date(dto.deadline) : undefined,
      },
      include: {
        phases: { orderBy: { order: 'asc' } },
      },
    });

    return this.formatResponse(updated);
  }

  /**
   * Atualiza o status do projeto usando a state machine.
   * Valida a transição antes de executar.
   */
  async updateStatus(id: string, userId: string, dto: UpdateStatusDto) {
    const project = await this.prisma.project.findUnique({
      where: { id },
    });

    if (!project) {
      throw new NotFoundException('Projeto não encontrado');
    }

    const { event } = dto;
    const currentStatus = project.status;

    // Validar transição na state machine
    const nextStatus = getNextStatus(currentStatus, event);

    if (!nextStatus) {
      const available = getAvailableEvents(currentStatus).join(', ');
      throw new BadRequestException(
        `Transição inválida: '${event}' não é permitida a partir do status '${currentStatus}'. ` +
          `Eventos disponíveis: [${available}]`,
      );
    }

    // Apenas o admin pode aprovar/rejeitar na validação
    // Apenas o client pode submeter
    // (regras de negócio podem ser expandidas)
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new ForbiddenException('Usuário não encontrado');
    }

    // Atualizar status
    const updated = await this.prisma.project.update({
      where: { id },
      data: { status: nextStatus as ProjectStatus },
      include: {
        phases: { orderBy: { order: 'asc' } },
        contract: true,
      },
    });

    return this.formatResponse(updated);
  }

  /**
   * Remove um projeto (apenas draft).
   */
  async remove(id: string, userId: string) {
    const project = await this.prisma.project.findUnique({
      where: { id },
    });

    if (!project) {
      throw new NotFoundException('Projeto não encontrado');
    }

    if (project.clientId !== userId) {
      throw new ForbiddenException('Você não é o dono deste projeto');
    }

    if (project.status !== 'draft') {
      throw new BadRequestException(
        'Apenas projetos em status "draft" podem ser removidos',
      );
    }

    await this.prisma.project.delete({ where: { id } });

    return { message: 'Projeto removido com sucesso' };
  }

  // ─── Helpers ───────────────────────────────────────────

  private formatResponse(project: any) {
    const availableEvents = getAvailableEvents(project.status);

    return {
      ...project,
      budget: Number(project.budget),
      deadline: project.deadline?.toISOString() ?? null,
      createdAt: project.createdAt.toISOString(),
      availableEvents,
      phases: project.phases?.map((phase: any) => ({
        ...phase,
        amount: Number(phase.amount),
      })),
    };
  }
}
