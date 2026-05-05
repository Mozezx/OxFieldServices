import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { REALTIME_SUBSCRIBE_STATES } from '@supabase/realtime-js';
import { PrismaService } from '../../prisma/prisma.service';

/**
 * Pushes Supabase Realtime Broadcast on `app-sync-{authId}` so Flutter apps
 * invalidate Riverpod caches (event name `invalidate`, payload `{ scopes }`).
 */
@Injectable()
export class AppSyncService {
  private readonly logger = new Logger(AppSyncService.name);
  private readonly client: SupabaseClient | null;

  constructor(
    private readonly configService: ConfigService,
    private readonly prisma: PrismaService,
  ) {
    const url = this.configService.get<string>('SUPABASE_URL');
    const key =
      this.configService.get<string>('SUPABASE_SERVICE_KEY') ??
      this.configService.get<string>('SUPABASE_SERVICE_ROLE_KEY');

    if (!url || !key) {
      this.logger.warn(
        'SUPABASE_URL ou SUPABASE_SERVICE_KEY ausentes — app-sync Realtime desativado.',
      );
      this.client = null;
      return;
    }

    this.client = createClient(url, key, {
      auth: { persistSession: false, autoRefreshToken: false },
    });
  }

  /**
   * @param prismaUserId — `User.id` (Prisma). Resolve `authId` for channel name.
   */
  async publishInvalidateForUser(
    prismaUserId: string,
    scopes: string[],
  ): Promise<void> {
    if (!this.client || scopes.length === 0) return;

    const user = await this.prisma.user.findUnique({
      where: { id: prismaUserId },
      select: { authId: true },
    });

    const authId = user?.authId;
    if (!authId || authId.startsWith('pending:')) return;

    const topic = `app-sync-${authId}`;
    const channel = this.client.channel(topic);

    try {
      await new Promise<void>((resolve, reject) => {
        let settled = false;
        const done = (err?: Error) => {
          if (settled) return;
          settled = true;
          void this.client!.removeChannel(channel).finally(() => {
            if (err) reject(err);
            else resolve();
          });
        };

        channel.subscribe(
          (status, err) => {
            if (settled) return;
            if (status === REALTIME_SUBSCRIBE_STATES.SUBSCRIBED) {
              void channel
                .send({
                  type: 'broadcast',
                  event: 'invalidate',
                  payload: { scopes },
                })
                .then((sendStatus) => {
                  if (sendStatus === 'error' || sendStatus === 'timed out') {
                    done(new Error(`send: ${sendStatus}`));
                  } else {
                    done();
                  }
                })
                .catch((e: unknown) =>
                  done(e instanceof Error ? e : new Error(String(e))),
                );
              return;
            }
            if (
              status === REALTIME_SUBSCRIBE_STATES.CHANNEL_ERROR ||
              status === REALTIME_SUBSCRIBE_STATES.TIMED_OUT
            ) {
              done(err ?? new Error(status));
            }
          },
          15_000,
        );
      });
    } catch (e) {
      this.logger.warn(
        `app-sync falhou (${topic}): ${e instanceof Error ? e.message : String(e)}`,
      );
    }
  }
}
