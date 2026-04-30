import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { UserRole } from '@prisma/client';

@Injectable()
export class AuthService {
  constructor(private prisma: PrismaService) {}

  async syncProfile(authId: string, email: string, name: string, role: UserRole) {
    return this.prisma.user.upsert({
      where: { authId },
      update: {},
      create: { authId, email, name, role },
    });
  }
}
