import {
  BadRequestException,
  Controller,
  Headers,
  HttpCode,
  Post,
  type RawBodyRequest,
  Req,
} from '@nestjs/common';
import type { Request } from 'express';
import { ApiExcludeController } from '@nestjs/swagger';
import { StripeService } from './stripe.service';

/** Campos usados do PaymentIntent em payment_intent.succeeded (Stripe SDK v22 não exporta PaymentIntent no root). */
type PaymentIntentSucceededPayload = {
  metadata?: { contractId?: string } | null;
  latest_charge?: string | { id: string } | null;
};
import { PaymentsService } from './payments.service';

@ApiExcludeController()
@Controller('webhooks')
export class StripeWebhookController {
  constructor(
    private stripeService: StripeService,
    private paymentsService: PaymentsService,
  ) {}

  @Post('stripe')
  @HttpCode(200)
  async handleWebhook(
    @Req() req: RawBodyRequest<Request>,
    @Headers('stripe-signature') sig: string,
  ) {
    if (!req.rawBody) throw new BadRequestException('Raw body não disponível');

    let event;
    try {
      event = this.stripeService.constructWebhookEvent(req.rawBody, sig);
    } catch {
      throw new BadRequestException('Stripe webhook signature inválida');
    }

    switch (event.type) {
      case 'payment_intent.succeeded': {
        const pi = event.data.object as PaymentIntentSucceededPayload;
        const contractId = pi.metadata?.contractId;
        const chargeId =
          typeof pi.latest_charge === 'string'
            ? pi.latest_charge
            : pi.latest_charge?.id;
        if (contractId) {
          await this.paymentsService.activateEscrow(contractId, chargeId);
        }
        break;
      }
      // transfer.created é registrado em releaseSplitPayment — sem ação extra necessária
    }

    return { received: true };
  }
}
