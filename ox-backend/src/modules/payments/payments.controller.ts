import { Controller, Post, Get, Param, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { PaymentsService } from './payments.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('payments')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('payments')
export class PaymentsController {
  constructor(private paymentsService: PaymentsService) {}

  // Worker cria sua conta no Stripe Connect
  @Post('worker-account')
  @ApiOperation({ summary: 'Criar conta Stripe Connect para o worker autenticado' })
  createWorkerAccount(@Req() req: any) {
    return this.paymentsService.createWorkerStripeAccount(req.user.worker?.id);
  }

  // Link de onboarding para o worker completar o cadastro no Stripe
  @Get('worker-account/onboarding')
  @ApiOperation({ summary: 'Obter link de onboarding Stripe para o worker' })
  getOnboarding(@Req() req: any) {
    const base = process.env.APP_URL ?? 'http://localhost:3000';
    const returnUrl = `${base}/payments/worker-account/onboarding/done`;
    return this.paymentsService.getOnboardingLink(req.user.worker?.id, returnUrl);
  }

  // Criar PaymentIntent em modo manual (escrow bloqueado)
  @Post('escrow/:contractId')
  @ApiOperation({ summary: 'Criar escrow (PaymentIntent manual) para um contrato' })
  createEscrow(@Param('contractId') contractId: string) {
    return this.paymentsService.createEscrow(contractId);
  }

  // Capturar PaymentIntent (confirmar fundos no escrow após pagamento do cliente)
  @Post('capture/:paymentIntentId')
  @ApiOperation({ summary: 'Capturar PaymentIntent — confirma fundos no escrow' })
  captureIntent(@Param('paymentIntentId') paymentIntentId: string) {
    return this.paymentsService.captureIntent(paymentIntentId);
  }

  // Liberar split após validação de todas as fases (admin/system only)
  @Post('release/:escrowId')
  @ApiOperation({ summary: 'Liberar split de pagamento (70% worker / 30% plataforma)' })
  releaseEscrow(@Param('escrowId') escrowId: string) {
    return this.paymentsService.releaseEscrow(escrowId);
  }

  // Consultar status do escrow por contrato
  @Get('escrow/contract/:contractId')
  @ApiOperation({ summary: 'Consultar escrow de um contrato' })
  getEscrow(@Param('contractId') contractId: string) {
    return this.paymentsService.getEscrowByContract(contractId);
  }
}
