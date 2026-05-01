import { Injectable, Logger } from '@nestjs/common';
import { OnEvent } from '@nestjs/event-emitter';
import { PrismaService } from '../../prisma/prisma.service';
import { StripeService } from '../../modules/payments/stripe.service';

@Injectable()
export class PhaseValidatedHandler {
  private readonly logger = new Logger(PhaseValidatedHandler.name);

  constructor(
    private prisma: PrismaService,
    private stripeService: StripeService,
  ) {}

  @OnEvent('phase.validated')
  async handle(payload: { phaseId: string }) {
    const phase = await this.prisma.projectPhase.findUnique({
      where: { id: payload.phaseId },
      include: {
        project: {
          include: { contract: { include: { escrow: true } } },
        },
      },
    });

    if (!phase) {
      this.logger.warn(`phase.validated: fase ${payload.phaseId} não encontrada`);
      return;
    }

    const allPhases = await this.prisma.projectPhase.findMany({
      where: { projectId: phase.projectId },
    });

    const allValidated = allPhases.every((p) => p.status === 'validated');

    if (!allValidated) return;

    const escrow = phase.project.contract?.escrow;

    if (!escrow) {
      this.logger.warn(
        `phase.validated: projeto ${phase.projectId} sem escrow — pagamento não liberado`,
      );
    } else if (escrow.status !== 'held') {
      this.logger.warn(
        `phase.validated: escrow ${escrow.id} já está '${escrow.status}' — nada a fazer`,
      );
    } else {
      await this.stripeService.releaseSplitPayment(escrow.id);
      this.logger.log(`Pagamento liberado — escrow ${escrow.id}`);
    }

    // Avança projeto para closing
    await this.prisma.project.update({
      where: { id: phase.projectId },
      data: { status: 'closing' },
    });

    this.logger.log(`Projeto ${phase.projectId} avançado para closing`);
  }
}
