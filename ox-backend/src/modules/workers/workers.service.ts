import {
  Injectable,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { UpdateWorkerDto } from './dto/update-worker.dto';

@Injectable()
export class WorkersService {
  constructor(private prisma: PrismaService) {}

  async findMe(userId: string) {
    const worker = await this.prisma.worker.findUnique({
      where: { userId },
      include: {
        user: {
          select: { id: true, name: true, email: true, phone: true, avatarUrl: true },
        },
        ratings: { orderBy: { createdAt: 'desc' }, take: 10 },
      },
    });

    if (!worker) throw new NotFoundException('Perfil de worker não encontrado');

    return this.formatWorker(worker);
  }

  async updateMe(userId: string, dto: UpdateWorkerDto) {
    const worker = await this.prisma.worker.findUnique({ where: { userId } });
    if (!worker) throw new NotFoundException('Perfil de worker não encontrado');

    const updated = await this.prisma.worker.update({
      where: { userId },
      data: dto,
      include: {
        user: {
          select: { id: true, name: true, email: true, phone: true, avatarUrl: true },
        },
      },
    });

    return this.formatWorker(updated);
  }

  async findAll(params: { available?: boolean; skip?: number; take?: number }) {
    const where: any = {};
    if (params.available !== undefined) where.available = params.available;

    const [workers, total] = await Promise.all([
      this.prisma.worker.findMany({
        where,
        skip: params.skip ?? 0,
        take: params.take ?? 20,
        orderBy: { rating: 'desc' },
        include: {
          user: {
            select: { id: true, name: true, email: true, avatarUrl: true },
          },
        },
      }),
      this.prisma.worker.count({ where }),
    ]);

    return { data: workers.map((w) => this.formatWorker(w)), total };
  }

  async updateById(workerId: string, dto: UpdateWorkerDto) {
    const worker = await this.prisma.worker.findUnique({ where: { id: workerId } });
    if (!worker) throw new NotFoundException('Worker não encontrado');

    const updated = await this.prisma.worker.update({
      where: { id: workerId },
      data: dto,
      include: {
        user: {
          select: { id: true, name: true, email: true, phone: true, avatarUrl: true },
        },
      },
    });

    return this.formatWorker(updated);
  }

  async findOne(workerId: string) {
    const worker = await this.prisma.worker.findUnique({
      where: { id: workerId },
      include: {
        user: {
          select: { id: true, name: true, email: true, avatarUrl: true },
        },
        ratings: { orderBy: { createdAt: 'desc' }, take: 5 },
      },
    });

    if (!worker) throw new NotFoundException('Worker não encontrado');

    return this.formatWorker(worker);
  }

  async assertWorkerRole(userId: string) {
    const worker = await this.prisma.worker.findUnique({ where: { userId } });
    if (!worker) throw new ForbiddenException('Apenas workers podem acessar este recurso');
    return worker;
  }

  private formatWorker(worker: any) {
    return {
      ...worker,
      rating: Number(worker.rating),
    };
  }
}
