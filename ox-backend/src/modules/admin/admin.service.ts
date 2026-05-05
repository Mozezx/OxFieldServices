import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { LookupOrCreateClientDto } from './dto/lookup-or-create-client.dto';
import { randomUUID } from 'crypto';

@Injectable()
export class AdminService {
  constructor(private prisma: PrismaService) {}

  /**
   * Busca cliente por email; se não existir, cria um stub com authId "pending:<uuid>".
   * O authId real é preenchido na primeira chamada POST /auth/sync do cliente.
   */
  async lookupOrCreateClient(dto: LookupOrCreateClientDto) {
    if (dto.unregistered || !dto.email) {
      const uuid = randomUUID();
      const created = await this.prisma.user.create({
        data: {
          email: `unregistered_${uuid}@placeholder.ox`,
          name: dto.name ?? 'Cliente não cadastrado',
          phone: dto.phone,
          role: 'client',
          authId: `pending:${uuid}`,
        },
        select: { id: true, name: true, email: true, phone: true, role: true, authId: true },
      });
      return { ...created, isNew: true, unregistered: true };
    }

    const existing = await this.prisma.user.findUnique({
      where: { email: dto.email },
      select: { id: true, name: true, email: true, phone: true, role: true, authId: true },
    });

    if (existing) {
      return { ...existing, isNew: false };
    }

    const created = await this.prisma.user.create({
      data: {
        email: dto.email,
        name: dto.name ?? dto.email.split('@')[0],
        phone: dto.phone,
        role: 'client',
        authId: `pending:${randomUUID()}`,
      },
      select: { id: true, name: true, email: true, phone: true, role: true, authId: true },
    });

    return { ...created, isNew: true };
  }
}
