import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { PrismaService } from '../../prisma/prisma.service';
import { StripeService } from './stripe.service';

@Injectable()
export class PaymentsService {
  constructor(
    private prisma: PrismaService,
    private stripeService: StripeService,
    private eventEmitter: EventEmitter2,
  ) {}

  async createWorkerStripeAccount(workerId: string) {
    const worker = await this.prisma.worker.findUnique({
      where: { id: workerId },
      include: { user: true },
    });

    if (!worker) throw new NotFoundException('Worker não encontrado');
    if (worker.stripeAccountId) {
      throw new BadRequestException('Worker já possui conta Stripe');
    }

    return this.stripeService.createWorkerAccount(workerId, worker.user.email);
  }

  async getOnboardingLink(workerId: string, returnUrl: string) {
    const worker = await this.prisma.worker.findUnique({ where: { id: workerId } });
    if (!worker?.stripeAccountId) {
      throw new BadRequestException('Worker sem conta Stripe. Crie primeiro via POST /payments/worker-account');
    }
    const url = await this.stripeService.createOnboardingLink(
      worker.stripeAccountId,
      returnUrl,
      returnUrl,
    );
    return { url };
  }

  async createEscrow(contractId: string) {
    const contract = await this.prisma.contract.findUnique({
      where: { id: contractId },
      include: { escrow: true },
    });

    if (!contract) throw new NotFoundException('Contrato não encontrado');
    if (contract.escrow) throw new BadRequestException('Escrow já criado para este contrato');

    const amountCents = Math.round(Number(contract.totalAmount) * 100);
    const intent = await this.stripeService.createEscrowIntent(amountCents, contractId);

    await this.prisma.contract.update({
      where: { id: contractId },
      data: { stripeIntentId: intent.id },
    });

    return {
      clientSecret: intent.client_secret,
      paymentIntentId: intent.id,
      amount: contract.totalAmount,
    };
  }

  // Chamado pelo webhook payment_intent.succeeded
  async activateEscrow(contractId: string) {
    const contract = await this.prisma.contract.findUnique({ where: { id: contractId } });
    if (!contract) return;

    await this.prisma.escrowTxn.upsert({
      where: { contractId },
      update: {},
      create: {
        contractId,
        amount: contract.totalAmount,
        status: 'held',
      },
    });
  }

  async captureIntent(paymentIntentId: string) {
    return this.stripeService.captureIntent(paymentIntentId);
  }

  async releaseEscrow(escrowId: string) {
    const escrow = await this.prisma.escrowTxn.findUnique({ where: { id: escrowId } });
    if (!escrow) throw new NotFoundException('Escrow não encontrado');
    if (escrow.status !== 'held') {
      throw new BadRequestException(
        `Escrow está '${escrow.status}', esperado 'held'`,
      );
    }
    await this.stripeService.releaseSplitPayment(escrowId);
    this.eventEmitter.emit('payment.released', { escrowId });
    return { released: true };
  }

  async getEscrowByContract(contractId: string) {
    const escrow = await this.prisma.escrowTxn.findUnique({
      where: { contractId },
      include: { payments: true },
    });
    if (!escrow) throw new NotFoundException('Escrow não encontrado para este contrato');
    return escrow;
  }
}
