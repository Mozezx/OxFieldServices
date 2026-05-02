import { Injectable } from '@nestjs/common';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { PrismaService } from '../../prisma/prisma.service';
import { UserRole } from '@prisma/client';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private readonly eventEmitter: EventEmitter2,
  ) {}

  async syncProfile(authId: string, email: string, name: string, role: UserRole) {
    const existing = await this.prisma.user.findUnique({
      where: { authId },
      select: { id: true },
    });

    const user = await this.prisma.user.upsert({
      where: { authId },
      update: {},
      create: { authId, email, name, role },
      include: { worker: true },
    });

    if (!existing) {
      this.eventEmitter.emit('user.created', { userId: user.id, role: user.role });
    }

    // Cria o perfil Worker automaticamente se ainda não existir
    if (role === UserRole.worker && !user.worker) {
      await this.prisma.worker.create({ data: { userId: user.id } });
    }

    return this.prisma.user.findUnique({
      where: { authId },
      include: { worker: true },
    });
  }
}
