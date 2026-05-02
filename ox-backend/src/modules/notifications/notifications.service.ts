import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { NotificationType } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.service';
import * as admin from 'firebase-admin';

export type CreateNotificationInput = {
  userId: string;
  type: NotificationType;
  title: string;
  body: string;
  entityType?: string | null;
  entityId?: string | null;
  data?: Record<string, unknown> | null;
};

type FcmPayload = {
  title: string;
  body: string;
  data?: Record<string, string>;
};

const INVALID_TOKEN_CODES = new Set([
  'messaging/invalid-registration-token',
  'messaging/registration-token-not-registered',
]);

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);
  private readonly firebaseApp?: admin.app.App;

  constructor(
    private readonly prisma: PrismaService,
    private readonly configService: ConfigService,
  ) {
    const projectId = this.configService.get<string>('FIREBASE_PROJECT_ID');
    const privateKey = this.configService
      .get<string>('FIREBASE_PRIVATE_KEY')
      ?.replace(/\\n/g, '\n');
    const clientEmail = this.configService.get<string>('FIREBASE_CLIENT_EMAIL');

    if (!projectId || !privateKey || !clientEmail) {
      this.logger.warn(
        'Firebase não configurado completamente. Push notifications desabilitadas.',
      );
      return;
    }

    this.firebaseApp = admin.apps[0]
      ? admin.app()
      : admin.initializeApp({
          credential: admin.credential.cert({
            projectId,
            privateKey,
            clientEmail,
          }),
        });
  }

  /**
   * Persiste no banco e envia FCM para todos os DeviceTokens (+ legacy fcmToken).
   */
  async create(input: CreateNotificationInput) {
    const row = await this.prisma.notification.create({
      data: {
        userId: input.userId,
        type: input.type,
        title: input.title,
        body: input.body,
        entityType: input.entityType ?? undefined,
        entityId: input.entityId ?? undefined,
        data: input.data === undefined ? undefined : (input.data as object),
      },
    });

    await this.pushToUser(input.userId, {
      title: input.title,
      body: input.body,
      data: this.buildFcmData(input.type, input.entityType, input.entityId, input.data),
    });

    return row;
  }

  /** Envia a vários usuários (deduplica IDs). */
  async createForUsers(
    userIds: string[],
    payload: Omit<CreateNotificationInput, 'userId'>,
  ) {
    const unique = [...new Set(userIds)];
    await Promise.all(
      unique.map((userId) => this.create({ ...payload, userId })),
    );
  }

  async listForUser(params: {
    userId: string;
    cursor?: string | null;
    limit: number;
  }) {
    const take = Math.min(Math.max(params.limit, 1), 50);
    const cursorDate = params.cursor ? new Date(params.cursor) : undefined;

    const items = await this.prisma.notification.findMany({
      where: {
        userId: params.userId,
        ...(cursorDate && !Number.isNaN(cursorDate.getTime())
          ? { createdAt: { lt: cursorDate } }
          : {}),
      },
      orderBy: { createdAt: 'desc' },
      take: take + 1,
    });

    const hasMore = items.length > take;
    const slice = hasMore ? items.slice(0, take) : items;
    const nextCursor =
      hasMore && slice.length > 0
        ? slice[slice.length - 1].createdAt.toISOString()
        : null;

    return {
      items: slice.map((n) => ({
        id: n.id,
        type: n.type,
        title: n.title,
        body: n.body,
        entityType: n.entityType,
        entityId: n.entityId,
        data: n.data,
        readAt: n.readAt?.toISOString() ?? null,
        createdAt: n.createdAt.toISOString(),
      })),
      nextCursor,
    };
  }

  async unreadCount(userId: string) {
    const count = await this.prisma.notification.count({
      where: { userId, readAt: null },
    });
    return { count };
  }

  async markRead(userId: string, notificationId: string) {
    const n = await this.prisma.notification.findFirst({
      where: { id: notificationId, userId },
    });
    if (!n) return null;
    return this.prisma.notification.update({
      where: { id: notificationId },
      data: { readAt: new Date() },
    });
  }

  async markAllRead(userId: string) {
    await this.prisma.notification.updateMany({
      where: { userId, readAt: null },
      data: { readAt: new Date() },
    });
    return { ok: true };
  }

  async deleteOne(userId: string, notificationId: string) {
    const result = await this.prisma.notification.deleteMany({
      where: { id: notificationId, userId },
    });
    return { deleted: result.count > 0 };
  }

  async getAdminUserIds(): Promise<string[]> {
    const rows = await this.prisma.user.findMany({
      where: { role: 'admin' },
      select: { id: true },
    });
    return rows.map((r) => r.id);
  }

  private buildFcmData(
    type: NotificationType,
    entityType?: string | null,
    entityId?: string | null,
    extra?: Record<string, unknown> | null,
  ): Record<string, string> {
    const data: Record<string, string> = {
      type,
      entityType: entityType ?? '',
      entityId: entityId ?? '',
    };
    if (extra && typeof extra === 'object') {
      data.payload = JSON.stringify(extra);
    }
    return data;
  }

  private async pushToUser(userId: string, payload: FcmPayload) {
    if (!this.firebaseApp) return;

    const [devices, user] = await Promise.all([
      this.prisma.deviceToken.findMany({
        where: { userId },
        select: { token: true },
      }),
      this.prisma.user.findUnique({
        where: { id: userId },
        select: { fcmToken: true },
      }),
    ]);

    const tokens = devices.map((d) => d.token);
    if (user?.fcmToken && !tokens.includes(user.fcmToken)) {
      tokens.push(user.fcmToken);
    }

    if (tokens.length === 0) return;

    const dataStrings: Record<string, string> = {
      ...(payload.data ?? {}),
    };

    try {
      const resp = await admin.messaging(this.firebaseApp).sendEachForMulticast({
        tokens,
        notification: {
          title: payload.title,
          body: payload.body,
        },
        data: dataStrings,
      });

      const toDelete: string[] = [];
      resp.responses.forEach((r, i) => {
        if (r.success) return;
        const code = r.error?.code;
        if (code && INVALID_TOKEN_CODES.has(code)) {
          toDelete.push(tokens[i]);
        }
      });

      if (toDelete.length > 0) {
        await this.prisma.deviceToken.deleteMany({
          where: { token: { in: toDelete } },
        });
      }
    } catch (error) {
      this.logger.warn(`FCM multicast falhou para user ${userId}: ${String(error)}`);
    }
  }
}
