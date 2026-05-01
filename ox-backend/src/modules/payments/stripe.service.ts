import { Injectable, InternalServerErrorException } from '@nestjs/common';
import Stripe from 'stripe';
import { PrismaService } from '../../prisma/prisma.service';

type StripeClient = InstanceType<typeof Stripe>;

@Injectable()
export class StripeService {
  readonly client: StripeClient;

  constructor(private prisma: PrismaService) {
    this.client = new Stripe(process.env.STRIPE_SECRET_KEY!);
  }

  async createWorkerAccount(workerId: string, email: string) {
    const account = await this.client.accounts.create({
      type: 'express',
      email,
      metadata: { workerId },
      capabilities: { transfers: { requested: true } },
    });

    await this.prisma.worker.update({
      where: { id: workerId },
      data: { stripeAccountId: account.id },
    });

    return account;
  }

  async createOnboardingLink(
    stripeAccountId: string,
    returnUrl: string,
    refreshUrl: string,
  ): Promise<string> {
    const link = await this.client.accountLinks.create({
      account: stripeAccountId,
      refresh_url: refreshUrl,
      return_url: returnUrl,
      type: 'account_onboarding',
    });
    return link.url;
  }

  async createEscrowIntent(amountCents: number, contractId: string) {
    return this.client.paymentIntents.create({
      amount: amountCents,
      currency: 'eur',
      capture_method: 'manual', // bloqueia mas não captura ainda
      metadata: { contractId },
    });
  }

  async captureIntent(paymentIntentId: string) {
    return this.client.paymentIntents.capture(paymentIntentId);
  }

  // Split: 70% worker / 30% OX (plataforma retém sem transfer explícito)
  async releaseSplitPayment(escrowTxnId: string): Promise<void> {
    const escrow = await this.prisma.escrowTxn.findUnique({
      where: { id: escrowTxnId },
      include: { contract: { include: { worker: true } } },
    });

    if (!escrow) throw new InternalServerErrorException('EscrowTxn não encontrado');

    if (!escrow.contract.worker.stripeAccountId) {
      throw new InternalServerErrorException('Worker não tem conta Stripe configurada');
    }

    const totalCents = Math.round(Number(escrow.amount) * 100);
    const workerCents = Math.floor(totalCents * 0.7);
    const platformCents = totalCents - workerCents;

    const transfer = await this.client.transfers.create(
      {
        amount: workerCents,
        currency: 'eur',
        destination: escrow.contract.worker.stripeAccountId,
        metadata: { escrowTxnId, type: 'worker' },
      },
      { idempotencyKey: `worker_${escrowTxnId}` },
    );

    await this.prisma.payment.createMany({
      data: [
        {
          escrowId: escrowTxnId,
          recipientType: 'worker',
          recipientId: escrow.contract.workerId,
          amount: workerCents / 100,
          stripeTransferId: transfer.id,
          paidAt: new Date(),
        },
        {
          escrowId: escrowTxnId,
          recipientType: 'platform',
          recipientId: 'ox-platform',
          amount: platformCents / 100,
          paidAt: new Date(),
        },
      ],
    });

    await this.prisma.escrowTxn.update({
      where: { id: escrowTxnId },
      data: { status: 'released', releasedAt: new Date() },
    });
  }

  constructWebhookEvent(rawBody: Buffer, signature: string) {
    return this.client.webhooks.constructEvent(
      rawBody,
      signature,
      process.env.STRIPE_WEBHOOK_SECRET!,
    );
  }
}
