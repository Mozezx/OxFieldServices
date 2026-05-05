import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { DevicePlatform } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.service';
import type { PreferredLocale } from './dto/update-preferred-locale.dto';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  /** Prefixo esperado: SUPABASE_URL + /storage/v1/object/public/{bucket}/ */
  private assertAvatarUrlAllowed(avatarUrl: string, authId: string): void {
    const supabaseUrl = process.env.SUPABASE_URL?.replace(/\/$/, '');
    const bucket = process.env.AVATARS_STORAGE_BUCKET ?? 'avatars';
    if (!supabaseUrl) {
      throw new BadRequestException('SUPABASE_URL não configurado');
    }
    const prefix = `${supabaseUrl}/storage/v1/object/public/${bucket}/`;
    if (!avatarUrl.startsWith(prefix)) {
      throw new BadRequestException('avatarUrl deve ser uma URL pública do bucket de avatares');
    }
    const rest = avatarUrl.slice(prefix.length);
    if (!rest.startsWith(`${authId}/`)) {
      throw new BadRequestException('avatarUrl deve estar na pasta do utilizador autenticado');
    }
  }

  async updateAvatarUrl(userId: string, authId: string, avatarUrl: string | null | undefined) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('Usuário não encontrado');
    }

    if (avatarUrl === undefined) {
      return this.prisma.user.findUnique({
        where: { id: userId },
        select: {
          id: true,
          authId: true,
          email: true,
          name: true,
          role: true,
          avatarUrl: true,
        },
      });
    }

    const next = avatarUrl === null || avatarUrl === '' ? null : avatarUrl;

    if (next) {
      this.assertAvatarUrlAllowed(next, authId);
    }

    return this.prisma.user.update({
      where: { id: userId },
      data: { avatarUrl: next },
      select: {
        id: true,
        authId: true,
        email: true,
        name: true,
        role: true,
        avatarUrl: true,
      },
    });
  }

  async updateFcmToken(userId: string, fcmToken: string | null) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('Usuário não encontrado');
    }

    if (fcmToken) {
      await this.registerDeviceToken(userId, fcmToken, DevicePlatform.android);
    } else {
      await this.prisma.user.update({
        where: { id: userId },
        data: { fcmToken: null },
      });
      await this.prisma.deviceToken.deleteMany({ where: { userId } });
    }

    return this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        authId: true,
        email: true,
        role: true,
        fcmToken: true,
      },
    });
  }

  async registerDeviceToken(
    userId: string,
    token: string,
    platform: DevicePlatform,
  ) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('Usuário não encontrado');
    }

    await this.prisma.deviceToken.upsert({
      where: { token },
      create: {
        userId,
        token,
        platform,
      },
      update: {
        userId,
        lastSeen: new Date(),
      },
    });

    if (platform === DevicePlatform.android || platform === DevicePlatform.ios) {
      await this.prisma.user.update({
        where: { id: userId },
        data: { fcmToken: token },
      });
    }

    return { ok: true };
  }

  async updatePreferredLocale(userId: string, preferredLocale: PreferredLocale) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });
    if (!user) {
      throw new NotFoundException('Usuário não encontrado');
    }
    return this.prisma.user.update({
      where: { id: userId },
      data: { preferredLocale },
      select: { id: true, preferredLocale: true },
    });
  }

  async removeDeviceToken(userId: string, token: string) {
    await this.prisma.deviceToken.deleteMany({
      where: { userId, token },
    });

    await this.prisma.user.updateMany({
      where: { id: userId, fcmToken: token },
      data: { fcmToken: null },
    });

    return { ok: true };
  }
}
