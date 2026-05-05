import { ConflictException, Injectable, Logger } from '@nestjs/common';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { PrismaService } from '../../prisma/prisma.service';
import { UserRole } from '@prisma/client';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private prisma: PrismaService,
    private readonly eventEmitter: EventEmitter2,
  ) {}

  /**
   * Evita que POST /auth/sync grave role=worker por engano (ex.: app worker no mesmo email)
   * quando o utilizador já é cliente na API — stub criado pelo admin ou com obras em que é clientId.
   * Caso contrário o mesmo userId continua a receber notificações de cliente mas não resgata convites.
   */
  private async resolveEffectiveRole(
    existing: { id: string; role: UserRole } | null,
    requested: UserRole,
  ): Promise<UserRole> {
    if (!existing) return requested;

    const ownsClientProjects =
      (await this.prisma.project.count({ where: { clientId: existing.id } })) > 0;

    if (
      requested === UserRole.worker &&
      (existing.role === UserRole.client || ownsClientProjects)
    ) {
      this.logger.warn(
        `POST /auth/sync: role "worker" ignorado — utilizador ${existing.id} é cliente (perfil ou obras).`,
      );
      return UserRole.client;
    }

    return requested;
  }

  private normalizeIncomingName(name: string | null | undefined): string | null {
    const trimmed = name?.trim();
    if (!trimmed || trimmed.length < 2) return null;
    return trimmed;
  }

  private looksLikeEmail(value: string): boolean {
    return value.includes('@');
  }

  async syncProfile(authId: string, email: string, name: string, role: UserRole) {
    const incomingName = this.normalizeIncomingName(name);
    const safeNameFromEmail = email.split('@')[0];
    const canUseIncomingName = !!incomingName && !this.looksLikeEmail(incomingName);

    const priorByAuth = await this.prisma.user.findUnique({
      where: { authId },
      include: { worker: true },
    });

    let user = priorByAuth;
    let createdNew = false;

    if (priorByAuth) {
      const effectiveRole = await this.resolveEffectiveRole(
        { id: priorByAuth.id, role: priorByAuth.role },
        role,
      );
      const shouldRepairName =
        canUseIncomingName && this.looksLikeEmail(priorByAuth.name);
      user = await this.prisma.user.update({
        where: { authId },
        // Nome é definido no onboarding e não deve ser regravado com fallback de email.
        data: {
          email,
          role: effectiveRole,
          ...(shouldRepairName ? { name: incomingName } : {}),
        },
        include: { worker: true },
      });
    } else {
      const priorByEmail = await this.prisma.user.findUnique({ where: { email } });
      if (priorByEmail) {
        if (priorByEmail.role === 'admin') {
          throw new ConflictException('Este email está reservado para a equipa administrativa.');
        }
        const effectiveRole = await this.resolveEffectiveRole(
          { id: priorByEmail.id, role: priorByEmail.role },
          role,
        );
        user = await this.prisma.user.update({
          where: { id: priorByEmail.id },
          data: {
            authId,
            name: canUseIncomingName ? incomingName : priorByEmail.name,
            role: effectiveRole,
          },
          include: { worker: true },
        });
      } else {
        user = await this.prisma.user.create({
          data: {
            authId,
            email,
            name: canUseIncomingName ? incomingName : safeNameFromEmail,
            role,
          },
          include: { worker: true },
        });
        createdNew = true;
      }
    }

    if (createdNew) {
      this.eventEmitter.emit('user.created', { userId: user.id, role: user.role });
    }

    if (user.role === UserRole.worker && !user.worker) {
      await this.prisma.worker.create({ data: { userId: user.id } });
      user = (await this.prisma.user.findUnique({
        where: { authId },
        include: { worker: true },
      }))!;
    }

    return user;
  }
}
