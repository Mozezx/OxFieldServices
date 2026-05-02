import { Injectable, NotFoundException } from '@nestjs/common';
import { DevicePlatform } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

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
