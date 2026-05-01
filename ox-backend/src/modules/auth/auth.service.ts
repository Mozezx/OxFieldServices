import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { UserRole } from '@prisma/client';

@Injectable()
export class AuthService {
  constructor(private prisma: PrismaService) {}

  async syncProfile(authId: string, email: string, name: string, role: UserRole) {
    const user = await this.prisma.user.upsert({
      where: { authId },
      update: {},
      create: { authId, email, name, role },
      include: { worker: true },
    });

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
