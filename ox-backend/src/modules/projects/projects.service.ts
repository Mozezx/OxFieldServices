import {
  Injectable,
  BadRequestException,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateProjectDto } from './dto/create-project.dto';
import { UpdateProjectDto } from './dto/update-project.dto';
import { UpdateStatusDto } from './dto/update-status.dto';
import { RateProjectDto } from './dto/rate-project.dto';
import {
  getNextStatus,
  getAvailableEvents,
} from '../../common/state-machine/project.machine';
import { ProjectStatus, Prisma, UserRole } from '@prisma/client';

@Injectable()
export class ProjectsService {
  constructor(
    private prisma: PrismaService,
    private readonly eventEmitter: EventEmitter2,
  ) {}

  /** Resolve id interno da tabela User a partir do id Prisma ou do authId (Supabase). */
  async resolveUserKeyToId(userKey: string): Promise<string> {
    const u = await this.requireAppUser(userKey);
    return u.id;
  }

  /** Perfil Worker ligado ao utilizador da app (fallback quando o JWT não inclui `worker`). */
  async findWorkerIdForAppUser(userId: string): Promise<string | undefined> {
    const row = await this.prisma.worker.findUnique({
      where: { userId },
      select: { id: true },
    });
    return row?.id;
  }

  private async requireAppUser(userKey: string): Promise<{ id: string; role: UserRole }> {
    const key = userKey?.trim();
    if (!key) {
      throw new ForbiddenException('Sessão inválida: identificador de utilizador em falta.');
    }
    const user = await this.prisma.user.findFirst({
      where: { OR: [{ id: key }, { authId: key }] },
      select: { id: true, role: true },
    });
    if (!user) {
      throw new ForbiddenException(
        'Utilizador não encontrado na base de dados. Termine sessão, entre novamente ou faça POST /auth/sync.',
      );
    }
    return user;
  }

  /**
   * Cria uma obra com fases opcionais.
   *
   * Hoje só o admin cria obras (após visita presencial). O parâmetro `submit=true`
   * publica a obra direto em `matched` (pronta para matching). `submit=false` deixa
   * em `draft` como rascunho — o admin pode promover depois com o evento READY.
   */
  async create(userKey: string, dto: CreateProjectDto) {
    const appUser = await this.requireAppUser(userKey);
    let clientId = appUser.id;
    let createdByAdmin = false;

    if (appUser.role === 'admin') {
      createdByAdmin = true;
      if (dto.clientId) {
        const target = await this.prisma.user.findUnique({ where: { id: dto.clientId }, select: { id: true } });
        if (!target) throw new BadRequestException(`Cliente com id '${dto.clientId}' não encontrado.`);
        clientId = target.id;
      } else if (dto.clientEmail) {
        const target = await this.prisma.user.findUnique({ where: { email: dto.clientEmail }, select: { id: true } });
        if (!target) throw new BadRequestException(`Cliente com email '${dto.clientEmail}' não encontrado.`);
        clientId = target.id;
      }
    } else if (dto.clientId || dto.clientEmail) {
      throw new ForbiddenException('Apenas administradores podem criar projetos em nome de outro cliente.');
    }

    const { phases, clientId: _cid, clientEmail: _cemail, submit, ...projectData } = dto;

    const initialStatus: ProjectStatus =
      createdByAdmin && submit ? 'matched' : 'draft';

    const project = await this.prisma.project.create({
      data: {
        ...projectData,
        deadline: projectData.deadline
          ? new Date(projectData.deadline)
          : undefined,
        clientId,
        status: initialStatus,
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

    this.eventEmitter.emit('project.created', {
      projectId: project.id,
      clientId,
      createdByAdmin,
    });

    if (initialStatus !== 'draft') {
      this.eventEmitter.emit('project.status_changed', {
        projectId: project.id,
        from: 'draft',
        to: initialStatus,
      });
    }

    return this.formatResponse(project);
  }

  /**
   * Lista projetos com filtros opcionais.
   *  - clientId: limita a projetos cujo dono é o cliente passado.
   *  - workerId: limita a projetos cujo contrato pertence a esse worker.
   *  - noContract: limita a projetos sem contrato (útil para listar
   *    projetos disponíveis para matching).
   */
  async findAll(params: {
    clientId?: string;
    workerId?: string;
    status?: ProjectStatus;
    noContract?: boolean;
    skip?: number;
    take?: number;
  }) {
    const where: Prisma.ProjectWhereInput = {};

    if (params.clientId) where.clientId = params.clientId;
    if (params.workerId) where.contract = { workerId: params.workerId };
    if (params.noContract) where.contract = null;
    if (params.status) where.status = params.status;

    const [projects, total] = await Promise.all([
      this.prisma.project.findMany({
        where,
        skip: params.skip ?? 0,
        take: params.take ?? 20,
        orderBy: { createdAt: 'desc' },
        include: {
          client: {
            select: { id: true, name: true, email: true, avatarUrl: true },
          },
          phases: { orderBy: { order: 'asc' } },
          contract: {
            include: {
              worker: {
                include: {
                  user: { select: { id: true, name: true, email: true } },
                },
              },
              escrow: { select: { id: true, status: true } },
            },
          },
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
   * Quando `viewerKey` é passado e o viewer é o cliente dono, inclui `myRating`.
   */
  async findOne(id: string, viewerKey?: string) {
    const project = await this.prisma.project.findUnique({
      where: { id },
      include: {
        phases: {
          orderBy: { order: 'asc' },
          include: {
            evidences: {
              select: { id: true, type: true, url: true, uploadedAt: true },
            },
          },
        },
        contract: {
          include: {
            worker: {
              include: {
                user: { select: { id: true, name: true, email: true } },
              },
            },
            escrow: { select: { id: true, status: true } },
          },
        },
        client: {
          select: { id: true, name: true, email: true, avatarUrl: true },
        },
      },
    });

    if (!project) {
      throw new NotFoundException('Projeto não encontrado');
    }

    const base = this.formatResponse(project);

    if (!viewerKey?.trim()) {
      return base;
    }

    const viewer = await this.requireAppUser(viewerKey);
    if (viewer.role !== UserRole.client || viewer.id !== project.clientId) {
      return base;
    }

    const row = await this.prisma.workerRating.findFirst({
      where: { projectId: id, userId: viewer.id },
      select: { score: true, feedback: true },
    });

    return {
      ...base,
      myRating: row
        ? { score: row.score, feedback: row.feedback ?? null }
        : null,
    };
  }

  /**
   * Atualiza dados do projeto (não muda status).
   */
  async update(id: string, userKey: string, dto: UpdateProjectDto) {
    const appUser = await this.requireAppUser(userKey);
    const project = await this.prisma.project.findUnique({
      where: { id },
    });

    if (!project) {
      throw new NotFoundException('Projeto não encontrado');
    }

    if (project.clientId !== appUser.id && appUser.role !== 'admin') {
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
  async updateStatus(id: string, userKey: string, dto: UpdateStatusDto) {
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

    const appUser = await this.requireAppUser(userKey);

    if (event === 'READY') {
      if (appUser.role !== 'admin') {
        throw new ForbiddenException(
          'Apenas administradores podem publicar uma obra para matching.',
        );
      }
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

    this.eventEmitter.emit('project.status_changed', {
      projectId: id,
      from: currentStatus,
      to: nextStatus as ProjectStatus,
    });

    return this.formatResponse(updated);
  }

  /**
   * Cliente avalia o trabalhador após o projeto (uma avaliação por projeto/cliente).
   */
  async rateWorker(projectId: string, userKey: string, dto: RateProjectDto) {
    const appUser = await this.requireAppUser(userKey);
    const project = await this.prisma.project.findUnique({
      where: { id: projectId },
      include: { contract: true },
    });

    if (!project) {
      throw new NotFoundException('Projeto não encontrado');
    }

    if (project.clientId !== appUser.id) {
      throw new ForbiddenException('Apenas o cliente do projeto pode avaliar');
    }

    if (!project.contract) {
      throw new BadRequestException('Projeto sem contrato/worker para avaliar');
    }

    if (project.status !== ProjectStatus.closed) {
      throw new BadRequestException(
        'Só é possível avaliar após o projeto estar encerrado.',
      );
    }

    const workerId = project.contract.workerId;

    const rating = await this.prisma.$transaction(async (tx) => {
      const existing = await tx.workerRating.findFirst({
        where: { projectId, userId: appUser.id },
      });

      if (existing) {
        throw new BadRequestException('Você já avaliou este projeto');
      }

      const created = await tx.workerRating.create({
        data: {
          workerId,
          projectId,
          userId: appUser.id,
          score: dto.score,
          feedback: dto.feedback,
        },
      });

      const agg = await tx.workerRating.aggregate({
        where: { workerId },
        _avg: { score: true },
      });

      const avgScore = agg._avg.score ?? dto.score;

      await tx.worker.update({
        where: { id: workerId },
        data: { rating: avgScore },
      });

      return created;
    });

    this.eventEmitter.emit('worker.rated', {
      workerId,
      projectId,
      score: dto.score,
    });

    return rating;
  }

  /**
   * Remove um projeto (apenas draft).
   */
  async remove(id: string, userKey: string) {
    const appUser = await this.requireAppUser(userKey);
    const project = await this.prisma.project.findUnique({
      where: { id },
    });

    if (!project) {
      throw new NotFoundException('Projeto não encontrado');
    }

    if (project.clientId !== appUser.id && appUser.role !== 'admin') {
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
