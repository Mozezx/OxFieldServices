import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

const MIN_RATING = 3.5;
const MAX_CANDIDATES = 5;

@Injectable()
export class MatchingService {
  constructor(private prisma: PrismaService) {}

  async findCandidates(projectId: string) {
    const project = await this.prisma.project.findUnique({
      where: { id: projectId },
      include: { contract: true },
    });

    if (!project) throw new NotFoundException('Projeto não encontrado');

    if (project.status !== 'matched') {
      throw new BadRequestException(
        `Matching só pode ser executado em projetos com status 'matched'. Status atual: '${project.status}'`,
      );
    }

    if (project.contract) {
      throw new BadRequestException('Projeto já possui um worker atribuído');
    }

    const candidates = await this.prisma.worker.findMany({
      where: {
        available: true,
        shelterCertified: true,
        rating: { gte: MIN_RATING },
      },
      include: {
        user: { select: { id: true, name: true, email: true } },
      },
      orderBy: { rating: 'desc' },
      take: MAX_CANDIDATES,
    });

    return {
      projectId,
      projectTitle: project.title,
      candidates: candidates.map((w) => ({
        ...w,
        rating: Number(w.rating),
      })),
      total: candidates.length,
    };
  }
}
