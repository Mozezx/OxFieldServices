import {
  Injectable,
  BadRequestException,
  NotFoundException,
  ForbiddenException,
  GoneException,
} from '@nestjs/common';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateInviteDto } from './dto/create-invite.dto';
import { RedeemInviteDto } from './dto/redeem-invite.dto';
import { randomBytes, createHash } from 'crypto';

@Injectable()
export class InvitesService {
  constructor(
    private prisma: PrismaService,
    private readonly eventEmitter: EventEmitter2,
  ) {}

  private hashToken(token: string): string {
    return createHash('sha256').update(token).digest('hex');
  }

  /**
   * Cria convite para um projeto. Devolve o token plaintext apenas uma vez.
   */
  async createForProject(projectId: string, adminUserId: string, dto: CreateInviteDto) {
    const project = await this.prisma.project.findUnique({
      where: { id: projectId },
      select: { id: true, clientId: true, title: true },
    });
    if (!project) throw new NotFoundException('Projeto não encontrado');

    const expiresInDays = dto.expiresInDays ?? 14;
    const expiresAt = new Date(Date.now() + expiresInDays * 24 * 60 * 60 * 1000);

    const tokenPlaintext = randomBytes(32).toString('base64url');
    const tokenHash = this.hashToken(tokenPlaintext);

    const invite = await this.prisma.projectInvite.create({
      data: {
        projectId,
        clientId: project.clientId,
        tokenHash,
        expiresAt,
        createdById: adminUserId,
      },
    });

    this.eventEmitter.emit('invite.created', { inviteId: invite.id, projectId, adminUserId });

    const baseUrl = process.env.APP_BASE_URL ?? 'https://app.ox.example';
    return {
      id: invite.id,
      token: tokenPlaintext,
      url: `${baseUrl}/i/${tokenPlaintext}`,
      expiresAt: invite.expiresAt,
      projectId,
    };
  }

  /**
   * Lista convites de um projeto (sem expor token).
   */
  async findByProject(projectId: string) {
    const invites = await this.prisma.projectInvite.findMany({
      where: { projectId },
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        projectId: true,
        clientId: true,
        expiresAt: true,
        usedAt: true,
        revokedAt: true,
        createdById: true,
        createdAt: true,
      },
    });
    return invites.map((inv) => ({
      ...inv,
      status: this.computeStatus(inv),
    }));
  }

  /**
   * Revoga um convite (marca revokedAt).
   */
  async revoke(inviteId: string) {
    const invite = await this.prisma.projectInvite.findUnique({ where: { id: inviteId } });
    if (!invite) throw new NotFoundException('Convite não encontrado');
    if (invite.revokedAt) throw new BadRequestException('Convite já revogado');

    const updated = await this.prisma.projectInvite.update({
      where: { id: inviteId },
      data: { revokedAt: new Date() },
    });

    this.eventEmitter.emit('invite.revoked', { inviteId });
    return { id: updated.id, revokedAt: updated.revokedAt };
  }

  /**
   * Preview público: retorna apenas título, nome do cliente e data de expiração.
   * Não revela dados sensíveis. Resposta genérica para token inválido/expirado.
   */
  async preview(token: string) {
    const tokenHash = this.hashToken(token);
    const invite = await this.prisma.projectInvite.findUnique({
      where: { tokenHash },
      include: {
        project: { select: { title: true } },
        client: { select: { name: true } },
      },
    });

    if (!invite || invite.revokedAt) {
      throw new NotFoundException('Convite inválido ou expirado');
    }
    if (invite.expiresAt < new Date()) {
      throw new GoneException('Convite expirado');
    }

    return {
      projectTitle: invite.project.title,
      clientName: invite.client.name,
      expiresAt: invite.expiresAt,
    };
  }

  /**
   * Resgata convite: associa projeto ao cliente autenticado.
   */
  async redeem(userKey: string, dto: RedeemInviteDto) {
    const appUser = await this.prisma.user.findFirst({
      where: { OR: [{ id: userKey }, { authId: userKey }] },
      select: { id: true, email: true, role: true },
    });
    if (!appUser) throw new ForbiddenException('Utilizador não encontrado. Faça POST /auth/sync.');

    const tokenHash = this.hashToken(dto.token);
    const invite = await this.prisma.projectInvite.findUnique({
      where: { tokenHash },
      include: { client: { select: { id: true, email: true, authId: true } } },
    });

    if (!invite) throw new GoneException('Convite inválido');
    if (invite.revokedAt) throw new ForbiddenException('Convite revogado');
    if (invite.usedAt) throw new GoneException('Convite já utilizado');
    if (invite.expiresAt < new Date()) throw new GoneException('Convite expirado');

    const isStub = invite.client.authId.startsWith('pending:');
    const emailMatch = invite.client.email === appUser.email;

    if (!emailMatch && !isStub) {
      throw new ForbiddenException(
        'Este convite foi gerado para outro email. Entre com a conta correta ou peça um novo convite ao administrador.',
      );
    }

    await this.prisma.$transaction(async (tx) => {
      // Reassign project clientId to the real authenticated user
      if (invite.client.id !== appUser.id) {
        await tx.project.update({
          where: { id: invite.projectId },
          data: { clientId: appUser.id },
        });
        // Disable stub if it was a pending user different from the authenticated one
        if (isStub) {
          await tx.projectInvite.updateMany({
            where: { clientId: invite.client.id, usedAt: null },
            data: { revokedAt: new Date() },
          });
        }
      }

      await tx.projectInvite.update({
        where: { id: invite.id },
        data: { usedAt: new Date(), clientId: appUser.id },
      });
    });

    this.eventEmitter.emit('invite.redeemed', { inviteId: invite.id, projectId: invite.projectId, userId: appUser.id });

    return { projectId: invite.projectId };
  }

  private computeStatus(invite: { usedAt: Date | null; revokedAt: Date | null; expiresAt: Date }) {
    if (invite.revokedAt) return 'revoked';
    if (invite.usedAt) return 'used';
    if (invite.expiresAt < new Date()) return 'expired';
    return 'active';
  }
}
