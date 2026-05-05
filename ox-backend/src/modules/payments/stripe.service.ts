import {
  Injectable,
  InternalServerErrorException,
  Logger,
} from '@nestjs/common';
import Stripe from 'stripe';
import { PrismaService } from '../../prisma/prisma.service';

type StripeClient = InstanceType<typeof Stripe>;

@Injectable()
export class StripeService {
  private readonly logger = new Logger(StripeService.name);
  readonly client: StripeClient;

  /** Mesma moeda em PaymentIntent + transfers; default EUR (use STRIPE_CHARGE_CURRENCY=brl para Connect Brasil). */
  readonly chargeCurrency: string;

  constructor(private prisma: PrismaService) {
    this.client = new Stripe(process.env.STRIPE_SECRET_KEY!);
    this.chargeCurrency = (
      process.env.STRIPE_CHARGE_CURRENCY ?? 'eur'
    ).toLowerCase();
  }

  async createWorkerAccount(workerId: string, email: string) {
    // BR Connect accounts must request card_payments alongside transfers (Stripe API rule).
    const account = await this.client.accounts.create({
      type: 'express',
      email,
      metadata: { workerId },
      capabilities: {
        transfers: { requested: true },
        card_payments: { requested: true },
      },
    });

    await this.prisma.worker.update({
      where: { id: workerId },
      data: { stripeAccountId: account.id },
    });

    return account;
  }

  /**
   * Retorna ou cria um Customer no Stripe para o usuário.
   * Persiste o customerId em User.stripeCustomerId.
   */
  async getOrCreateCustomer(userId: string): Promise<string> {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new InternalServerErrorException('Usuário não encontrado');

    let existingId = user.stripeCustomerId;
    if (existingId) {
      try {
        await this.client.customers.retrieve(existingId);
        return existingId;
      } catch (err) {
        const missing =
          err instanceof Stripe.errors.StripeInvalidRequestError &&
          err.code === 'resource_missing';
        if (!missing) throw err;
        await this.prisma.user.update({
          where: { id: userId },
          data: { stripeCustomerId: null },
        });
        existingId = null;
      }
    }

    const customer = await this.client.customers.create({
      email: user.email,
      name: user.name,
      metadata: { userId },
    });

    await this.prisma.user.update({
      where: { id: userId },
      data: { stripeCustomerId: customer.id },
    });

    return customer.id;
  }

  async createSetupIntent(customerId: string) {
    return this.client.setupIntents.create({
      customer: customerId,
      payment_method_types: ['card'],
      usage: 'off_session',
    });
  }

  async createEphemeralKey(customerId: string, apiVersion?: string) {
    return this.client.ephemeralKeys.create(
      { customer: customerId },
      { apiVersion: apiVersion ?? '2024-06-20' },
    );
  }

  async listPaymentMethods(customerId: string) {
    const customer = await this.client.customers.retrieve(customerId);
    const defaultPmId =
      typeof customer === 'object' && !('deleted' in customer)
        ? (customer.invoice_settings?.default_payment_method as string | null)
        : null;

    const list = await this.client.paymentMethods.list({
      customer: customerId,
      type: 'card',
    });

    return list.data.map((pm) => ({
      id: pm.id,
      brand: pm.card?.brand ?? 'card',
      last4: pm.card?.last4 ?? '****',
      expMonth: pm.card?.exp_month ?? 0,
      expYear: pm.card?.exp_year ?? 0,
      isDefault: pm.id === defaultPmId,
    }));
  }

  async detachPaymentMethod(paymentMethodId: string) {
    return this.client.paymentMethods.detach(paymentMethodId);
  }

  async setDefaultPaymentMethod(customerId: string, paymentMethodId: string) {
    return this.client.customers.update(customerId, {
      invoice_settings: { default_payment_method: paymentMethodId },
    });
  }

  /**
   * Retorna o status atual da conta Connect Express, com info do banco.
   */
  async getAccountStatus(stripeAccountId: string) {
    const account = await this.client.accounts.retrieve(stripeAccountId);

    const requirements = account.requirements ?? null;
    const externalAccount = account.external_accounts?.data?.[0] as
      | { object: string; bank_name?: string; last4?: string; brand?: string; currency?: string; country?: string }
      | undefined;

    let bankPreview: {
      type: 'bank' | 'card';
      bankName: string | null;
      last4: string;
      currency: string;
      country: string;
    } | null = null;

    if (externalAccount) {
      bankPreview = {
        type: externalAccount.object === 'card' ? 'card' : 'bank',
        bankName:
          externalAccount.bank_name ?? externalAccount.brand ?? null,
        last4: externalAccount.last4 ?? '****',
        currency: (externalAccount.currency ?? this.chargeCurrency).toUpperCase(),
        country: externalAccount.country ?? '',
      };
    }

    let derivedStatus: 'not_started' | 'pending' | 'active' | 'restricted';
    if (account.charges_enabled && account.payouts_enabled) {
      derivedStatus = 'active';
    } else if (
      requirements?.disabled_reason ||
      (requirements?.past_due?.length ?? 0) > 0
    ) {
      derivedStatus = 'restricted';
    } else {
      derivedStatus = 'pending';
    }

    return {
      status: derivedStatus,
      stripeAccountId,
      detailsSubmitted: account.details_submitted,
      chargesEnabled: account.charges_enabled,
      payoutsEnabled: account.payouts_enabled,
      requirements: {
        currentlyDue: requirements?.currently_due ?? [],
        pastDue: requirements?.past_due ?? [],
        disabledReason: requirements?.disabled_reason ?? null,
      },
      bankAccount: bankPreview,
    };
  }

  /**
   * Account Link hospedado pelo Stripe: onboarding inicial ou atualização (conta restrita / KYC).
   * `account_update` quando já houve submissão de dados; caso contrário `account_onboarding`.
   */
  async createConnectAccountLink(
    stripeAccountId: string,
    returnUrl: string,
    refreshUrl: string,
  ): Promise<string> {
    const account = await this.client.accounts.retrieve(stripeAccountId);
    const linkType: 'account_onboarding' | 'account_update' =
      account.details_submitted ? 'account_update' : 'account_onboarding';

    const link = await this.client.accountLinks.create({
      account: stripeAccountId,
      refresh_url: refreshUrl,
      return_url: returnUrl,
      type: linkType,
    });
    return link.url;
  }

  async createEscrowIntent(
    amountCents: number,
    contractId: string,
    customerId?: string,
  ) {
    return this.client.paymentIntents.create({
      amount: amountCents,
      currency: this.chargeCurrency,
      capture_method: 'automatic',
      metadata: { contractId },
      ...(customerId
        ? {
            customer: customerId,
            setup_future_usage: 'off_session', // permite reuso do cartão
          }
        : {}),
    });
  }

  async captureIntent(paymentIntentId: string) {
    return this.client.paymentIntents.capture(paymentIntentId);
  }

  /**
   * Moeda da balance transaction da charge — obrigatória em Transfer.currency quando se usa source_transaction.
   * Stripe exige que Transfer.currency === balance_transaction.currency (NÃO charge.currency: a moeda
   * de apresentação pode diferir da moeda em que a plataforma efetivamente liquida o saldo).
   * Se divergir de STRIPE_CHARGE_CURRENCY há inconsistência de config/dados, mas usamos sempre a
   * moeda do balance_transaction porque é o único valor aceito pelo Stripe no transfer.
   */
  async getChargeCurrency(chargeId: string): Promise<string> {
    const charge = await this.client.charges.retrieve(chargeId, {
      expand: ['balance_transaction'],
    });
    const bt = charge.balance_transaction;
    if (bt && typeof bt === 'object' && 'currency' in bt) {
      return bt.currency.toLowerCase();
    }
    return charge.currency.toLowerCase();
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

    if (!escrow.stripeSourceChargeId) {
      throw new InternalServerErrorException(
        'Escrow sem stripeSourceChargeId — transfers Connect com source_transaction exigem o id da charge (ch_)',
      );
    }

    const transferCurrency = await this.getChargeCurrency(escrow.stripeSourceChargeId);
    if (transferCurrency !== this.chargeCurrency) {
      this.logger.warn(
        `releaseSplitPayment: charge currency (${transferCurrency}) ≠ STRIPE_CHARGE_CURRENCY (${this.chargeCurrency}) — transfer usa a moeda da charge`,
      );
    }

    const totalCents = Math.round(Number(escrow.amount) * 100);
    const workerCents = Math.floor(totalCents * 0.7);
    const platformCents = totalCents - workerCents;

    const transfer = await this.client.transfers.create(
      {
        amount: workerCents,
        currency: transferCurrency,
        destination: escrow.contract.worker.stripeAccountId,
        source_transaction: escrow.stripeSourceChargeId,
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
