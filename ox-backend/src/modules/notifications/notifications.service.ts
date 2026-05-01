import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../prisma/prisma.service';
import * as admin from 'firebase-admin';

type NotificationPayload = {
  title: string;
  body: string;
  data?: Record<string, string>;
};

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
      this.logger.warn('Firebase não configurado completamente. Push notifications desabilitadas.');
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

  async notifyPhaseValidated(phaseId: string) {
    try {
      const phase = await this.prisma.projectPhase.findUnique({
        where: { id: phaseId },
        include: {
          project: {
            select: {
              id: true,
              title: true,
              client: { select: { id: true, fcmToken: true } },
              contract: {
                select: {
                  worker: {
                    select: {
                      user: { select: { id: true, fcmToken: true } },
                    },
                  },
                },
              },
            },
          },
        },
      });

      if (!phase) return;

      await Promise.all([
        this.sendToUserToken(phase.project.client.id, phase.project.client.fcmToken, {
          title: 'Fase validada',
          body: `A fase ${phase.name} do projeto ${phase.project.title} foi validada.`,
          data: { event: 'phase.validated', phaseId, projectId: phase.project.id },
        }),
        this.sendToUserToken(
          phase.project.contract?.worker.user.id,
          phase.project.contract?.worker.user.fcmToken,
          {
            title: 'Fase aprovada',
            body: `Sua fase ${phase.name} foi aprovada no projeto ${phase.project.title}.`,
            data: { event: 'phase.validated', phaseId, projectId: phase.project.id },
          },
        ),
      ]);
    } catch (error) {
      this.logger.warn(`Falha silenciosa ao enviar push de phase.validated: ${String(error)}`);
    }
  }

  async notifyPhaseRejected(phaseId: string) {
    try {
      const phase = await this.prisma.projectPhase.findUnique({
        where: { id: phaseId },
        include: {
          project: {
            select: {
              id: true,
              title: true,
              client: { select: { id: true, fcmToken: true } },
              contract: {
                select: {
                  worker: {
                    select: {
                      user: { select: { id: true, fcmToken: true } },
                    },
                  },
                },
              },
            },
          },
        },
      });

      if (!phase) return;

      await Promise.all([
        this.sendToUserToken(
          phase.project.contract?.worker.user.id,
          phase.project.contract?.worker.user.fcmToken,
          {
            title: 'Fase rejeitada',
            body: `A fase ${phase.name} do projeto ${phase.project.title} foi rejeitada e precisa de ajustes.`,
            data: { event: 'phase.rejected', phaseId, projectId: phase.project.id },
          },
        ),
        this.sendToUserToken(phase.project.client.id, phase.project.client.fcmToken, {
          title: 'Rejeição registrada',
          body: `A fase ${phase.name} foi marcada como rejeitada no projeto ${phase.project.title}.`,
          data: { event: 'phase.rejected', phaseId, projectId: phase.project.id },
        }),
      ]);
    } catch (error) {
      this.logger.warn(`Falha silenciosa ao enviar push de phase.rejected: ${String(error)}`);
    }
  }

  async notifyPaymentReleased(escrowId: string) {
    try {
      const escrow = await this.prisma.escrowTxn.findUnique({
        where: { id: escrowId },
        include: {
          contract: {
            include: {
              project: {
                select: {
                  id: true,
                  title: true,
                  client: { select: { id: true, fcmToken: true } },
                },
              },
              worker: {
                select: {
                  user: { select: { id: true, fcmToken: true } },
                },
              },
            },
          },
        },
      });

      if (!escrow) return;

      await Promise.all([
        this.sendToUserToken(
          escrow.contract.worker.user.id,
          escrow.contract.worker.user.fcmToken,
          {
            title: 'Pagamento liberado',
            body: `O pagamento do projeto ${escrow.contract.project.title} foi liberado.`,
            data: {
              event: 'payment.released',
              escrowId,
              projectId: escrow.contract.project.id,
            },
          },
        ),
        this.sendToUserToken(
          escrow.contract.project.client.id,
          escrow.contract.project.client.fcmToken,
          {
            title: 'Pagamento concluído',
            body: `O pagamento do projeto ${escrow.contract.project.title} foi transferido com sucesso.`,
            data: {
              event: 'payment.released',
              escrowId,
              projectId: escrow.contract.project.id,
            },
          },
        ),
      ]);
    } catch (error) {
      this.logger.warn(`Falha silenciosa ao enviar push de payment.released: ${String(error)}`);
    }
  }

  private async sendToUserToken(
    userId: string | undefined,
    token: string | null | undefined,
    payload: NotificationPayload,
  ) {
    if (!userId || !token || !this.firebaseApp) {
      return;
    }

    try {
      await admin.messaging(this.firebaseApp).send({
        token,
        notification: {
          title: payload.title,
          body: payload.body,
        },
        data: payload.data,
      });
    } catch (error) {
      this.logger.warn(`Falha silenciosa ao enviar push para user ${userId}: ${String(error)}`);
    }
  }
}
