import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { PrismaService } from '../../prisma/prisma.service';
import { ContractsService } from '../contracts/contracts.service';

const MIN_RATING = 3.5; // só aplicado quando o worker já tem avaliações (rating > 0)
const MAX_CANDIDATES = 5;

@Injectable()
export class MatchingService {
  constructor(
    private prisma: PrismaService,
    private contractsService: ContractsService,
    private readonly eventEmitter: EventEmitter2,
  ) {}

  async findCandidates(projectId: string) {
    const project = await this.prisma.project.findUnique({
      where: { id: projectId },
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

    // Assinatura sem escrow ainda: troca não é suportada (mesma regra que ContractsService).
    if (project.contract?.signedAt && !project.contract.escrow) {
      throw new BadRequestException(
        'Contrato já assinado pelo worker e sem escrow — não é possível buscar novos candidatos.',
      );
    }

    const projectSkills = project.phases.map((p) => p.name.toLowerCase());
    const currentWorkerId = project.contract?.workerId;

    const candidates = await this.prisma.worker.findMany({
      where: {
        available: true,
        // Esconde o worker atualmente atribuído da lista de candidatos
        ...(currentWorkerId ? { id: { not: currentWorkerId } } : {}),
        OR: [
          { rating: { gte: MIN_RATING } },
          { rating: { equals: 0 } }, // worker ainda sem avaliações
        ],
      },
      include: {
        user: { select: { id: true, name: true, email: true, avatarUrl: true } },
      },
      orderBy: { rating: 'desc' },
      take: MAX_CANDIDATES,
    });

    return candidates.map((w) => {
      const workerSkills = w.skills.map((s) => s.toLowerCase());
      const matchingSkills = projectSkills.filter((s) => workerSkills.includes(s));
      const missingSkills = projectSkills.filter((s) => !workerSkills.includes(s));

      // Score: 60% baseado no rating (max 5), 40% na cobertura de skills
      const ratingScore = (Number(w.rating) / 5) * 60;
      const skillScore =
        projectSkills.length > 0
          ? (matchingSkills.length / projectSkills.length) * 40
          : 40;
      const matchScore = Math.round(ratingScore + skillScore);

      return {
        ...w,
        rating: Number(w.rating),
        matchScore,
        matchingSkills: matchingSkills,
        missingSkills: missingSkills,
      };
    });
  }

  async assignWorker(projectId: string, workerId: string) {
    this.eventEmitter.emit('worker.invited', { projectId, workerId });
    return this.contractsService.create({ projectId, workerId });
  }
}
