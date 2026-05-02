import { Controller, Post, Get, Param, Req, UseGuards, Delete } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { PaymentsService } from './payments.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { Public } from '../../common/decorators/public.decorator';

@ApiTags('payments')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('payments')
export class PaymentsController {
  constructor(private paymentsService: PaymentsService) {}

  // Endpoint público para os apps Flutter buscarem a publishable key
  @Get('config')
  @Public()
  @ApiOperation({ summary: 'Obter chave pública do Stripe (não requer auth)' })
  getConfig() {
    return {
      publishableKey: process.env.STRIPE_PUBLISHABLE_KEY ?? '',
    };
  }

  @Get('me')
  @ApiOperation({ summary: 'Histórico de pagamentos recebidos pelo worker autenticado' })
  listMyPayments(@Req() req: any) {
    const workerId = req.user.worker?.id as string | undefined;
    if (!workerId) return [];
    return this.paymentsService.listWorkerPayments(workerId);
  }

  @Get('stats')
  @UseGuards(RolesGuard)
  @Roles('admin')
  @ApiOperation({ summary: 'KPIs e série semanal (admin)' })
  getPaymentStats() {
    return this.paymentsService.getAdminPaymentStats();
  }

  @Get()
  @UseGuards(RolesGuard)
  @Roles('admin')
  @ApiOperation({ summary: 'Listar todas as transações (admin)' })
  listAllPayments() {
    return this.paymentsService.listAllPaymentsAdmin();
  }

  // ─── Worker Connect ────────────────────────────────────

  @Post('worker-account')
  @ApiOperation({ summary: 'Criar conta Stripe Connect para o worker autenticado' })
  createWorkerAccount(@Req() req: any) {
    return this.paymentsService.createWorkerStripeAccount(req.user.worker?.id);
  }

  @Get('worker-account/onboarding')
  @ApiOperation({ summary: 'Obter link de onboarding Stripe para o worker' })
  getOnboarding(@Req() req: any) {
    const base = process.env.APP_URL ?? 'http://localhost:3000';
    const returnUrl = `${base}/payments/worker-account/onboarding/done`;
    return this.paymentsService.getOnboardingLink(req.user.worker?.id, returnUrl);
  }

  @Get('worker-account/status')
  @ApiOperation({
    summary: 'Status da conta Connect do worker (charges, payouts, requirements, banco)',
  })
  getWorkerAccountStatus(@Req() req: any) {
    return this.paymentsService.getWorkerAccountStatus(req.user.worker?.id);
  }

  // ─── Payment Methods (cliente) ─────────────────────────

  @Post('setup-intent')
  @ApiOperation({ summary: 'Criar SetupIntent para salvar um cartão' })
  createSetupIntent(@Req() req: any) {
    return this.paymentsService.createSetupIntent(req.user.id);
  }

  @Get('payment-methods')
  @ApiOperation({ summary: 'Listar cartões salvos do cliente' })
  listPaymentMethods(@Req() req: any) {
    return this.paymentsService.listPaymentMethods(req.user.id);
  }

  @Delete('payment-methods/:id')
  @ApiOperation({ summary: 'Remover cartão salvo' })
  detachPaymentMethod(@Req() req: any, @Param('id') id: string) {
    return this.paymentsService.detachPaymentMethod(req.user.id, id);
  }

  @Post('payment-methods/:id/default')
  @ApiOperation({ summary: 'Definir cartão padrão' })
  setDefaultPaymentMethod(@Req() req: any, @Param('id') id: string) {
    return this.paymentsService.setDefaultPaymentMethod(req.user.id, id);
  }

  // ─── Escrow ────────────────────────────────────────────

  @Post('escrow/:contractId')
  @ApiOperation({ summary: 'Criar escrow (PaymentIntent manual) para um contrato' })
  createEscrow(@Param('contractId') contractId: string, @Req() req: any) {
    return this.paymentsService.createEscrow(contractId, req.user.id);
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
