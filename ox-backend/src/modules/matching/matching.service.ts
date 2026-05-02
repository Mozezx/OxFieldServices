import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { ContractsService } from '../contracts/contracts.service';

const MIN_RATING = 3.5; // só aplicado quando o worker já tem avaliações (rating > 0)
const MAX_CANDIDATES = 5;

@Injectable()
export class MatchingService {
  constructor(
    private prisma: PrismaService,
    private contractsService: ContractsService,
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

    // Se já existe contrato e ele está "fechado" (assinado ou com escrow),
    // não há mais como atribuir/trocar worker.
    if (project.contract && (project.contract.signedAt || project.contract.escrow)) {
      throw new BadRequestException(
        'Projeto já possui contrato assinado ou com escrow ativo — não é possível trocar de worker',
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
        user: { select: { id: true, name: true, email: true } },
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
    return this.contractsService.create({ projectId, workerId });
  }
}
