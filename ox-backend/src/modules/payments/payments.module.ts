import { Module } from '@nestjs/common';
import { StripeService } from './stripe.service';
import { PaymentsService } from './payments.service';
import { PaymentsController } from './payments.controller';
import { StripeWebhookController } from './stripe-webhook.controller';
import { PrismaModule } from '../../prisma/prisma.module';
import { RolesGuard } from '../../common/guards/roles.guard';

@Module({
  imports: [PrismaModule],
  controllers: [PaymentsController, StripeWebhookController],
  providers: [StripeService, PaymentsService, RolesGuard],
  exports: [PaymentsService, StripeService],
})
export class PaymentsModule {}
