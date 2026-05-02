import {
  Injectable,
  BadRequestException,
  NotFoundException,
  Logger,
} from '@nestjs/common';
import { EventEmitter2, OnEvent } from '@nestjs/event-emitter';
import { PrismaService } from '../../prisma/prisma.service';
import { StripeService } from './stripe.service';
import { getNextStatus } from '../../common/state-machine/project.machine';
import { ProjectStatus } from '@prisma/client';

@Injectable()
export class PaymentsService {
  private readonly logger = new Logger(PaymentsService.name);

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

  async createEscrow(contractId: string, userId?: string) {
    const contract = await this.prisma.contract.findUnique({
      where: { id: contractId },
      include: { escrow: true, project: true },
    });

    if (!contract) throw new NotFoundException('Contrato não encontrado');

    // Quando já existe escrow, retorna o intent atual em vez de erro
    // (idempotência: usuário pode reabrir a tela de pagamento)
    if (contract.escrow) {
      return {
        clientSecret: null,
        paymentIntentId: contract.stripeIntentId,
        amount: contract.totalAmount,
        alreadyPaid: true,
      };
    }

    // Anexa Customer ao PaymentIntent quando temos o userId (apps autenticados)
    let customerId: string | undefined;
    let ephemeralKeySecret: string | undefined;
    if (userId) {
      customerId = await this.stripeService.getOrCreateCustomer(userId);
      const ephKey = await this.stripeService.createEphemeralKey(customerId);
      ephemeralKeySecret = ephKey.secret;
    }

    const amountCents = Math.round(Number(contract.totalAmount) * 100);
    const intent = await this.stripeService.createEscrowIntent(
      amountCents,
      contractId,
      customerId,
    );

    await this.prisma.contract.update({
      where: { id: contractId },
      data: { stripeIntentId: intent.id },
    });

    return {
      clientSecret: intent.client_secret,
      paymentIntentId: intent.id,
      amount: contract.totalAmount,
      customerId,
      customerEphemeralKeySecret: ephemeralKeySecret,
      publishableKey: process.env.STRIPE_PUBLISHABLE_KEY ?? '',
      alreadyPaid: false,
    };
  }

  // ─── Payment Methods (cliente) ─────────────────────────

  async createSetupIntent(userId: string) {
    const customerId = await this.stripeService.getOrCreateCustomer(userId);
    const intent = await this.stripeService.createSetupIntent(customerId);
    const ephKey = await this.stripeService.createEphemeralKey(customerId);
    return {
      clientSecret: intent.client_secret,
      customerId,
      customerEphemeralKeySecret: ephKey.secret,
      publishableKey: process.env.STRIPE_PUBLISHABLE_KEY ?? '',
    };
  }

  async listPaymentMethods(userId: string) {
    const customerId = await this.stripeService.getOrCreateCustomer(userId);
    return this.stripeService.listPaymentMethods(customerId);
  }

  async detachPaymentMethod(userId: string, paymentMethodId: string) {
    // Verifica que o PM pertence ao customer do user (segurança)
    const customerId = await this.stripeService.getOrCreateCustomer(userId);
    const methods = await this.stripeService.listPaymentMethods(customerId);
    if (!methods.find((m) => m.id === paymentMethodId)) {
      throw new BadRequestException('Cartão não pertence ao usuário');
    }
    await this.stripeService.detachPaymentMethod(paymentMethodId);
    return { detached: true };
  }

  async setDefaultPaymentMethod(userId: string, paymentMethodId: string) {
    const customerId = await this.stripeService.getOrCreateCustomer(userId);
    const methods = await this.stripeService.listPaymentMethods(customerId);
    if (!methods.find((m) => m.id === paymentMethodId)) {
      throw new BadRequestException('Cartão não pertence ao usuário');
    }
    await this.stripeService.setDefaultPaymentMethod(customerId, paymentMethodId);
    return { default: paymentMethodId };
  }

  // ─── Connect status (worker) ───────────────────────────

  async getWorkerAccountStatus(workerId: string) {
    const worker = await this.prisma.worker.findUnique({ where: { id: workerId } });
    if (!worker) throw new NotFoundException('Worker não encontrado');

    if (!worker.stripeAccountId) {
      return {
        status: 'not_started' as const,
        stripeAccountId: null,
        detailsSubmitted: false,
        chargesEnabled: false,
        payoutsEnabled: false,
        requirements: { currentlyDue: [], pastDue: [], disabledReason: null },
        bankAccount: null,
      };
    }

    return this.stripeService.getAccountStatus(worker.stripeAccountId);
  }

  // Chamado pelo webhook payment_intent.succeeded
  async activateEscrow(contractId: string, stripeSourceChargeId?: string | null) {
    const contract = await this.prisma.contract.findUnique({
      where: { id: contractId },
      include: { project: true },
    });
    if (!contract) return;

    let chargeId = stripeSourceChargeId ?? null;
    if (!chargeId && contract.stripeIntentId) {
      try {
        const pi = await this.stripeService.client.paymentIntents.retrieve(
          contract.stripeIntentId,
        );
        chargeId =
          typeof pi.latest_charge === 'string'
            ? pi.latest_charge
            : pi.latest_charge?.id ?? null;
      } catch {
        this.logger.warn(
          `Não foi possível recuperar PaymentIntent ${contract.stripeIntentId} para obter a charge`,
        );
      }
    }

    await this.prisma.escrowTxn.upsert({
      where: { contractId },
      update: {
        ...(chargeId ? { stripeSourceChargeId: chargeId } : {}),
      },
      create: {
        contractId,
        amount: contract.totalAmount,
        status: 'held',
        ...(chargeId ? { stripeSourceChargeId: chargeId } : {}),
      },
    });

    this.eventEmitter.emit('escrow.held', { contractId });

    if (!chargeId) {
      this.logger.warn(
        `Escrow ${contractId}: sem charge de origem (ch_) — transfers Connect ao Brasil exigem source_transaction`,
      );
    }

    await this.advanceProjectAfterEscrow(contractId);
  }

  /** Webhook: falha no PaymentIntent do cliente */
  handlePaymentIntentFailed(contractId?: string, reason?: string) {
    this.eventEmitter.emit('payment.failed', { contractId, reason });
  }

  /**
   * Avança o projeto via state-machine após escrow ser ativado.
   * Sequência: contract_signed -> active_escrow -> in_execution
   * Quando entra em in_execution, marca a fase de menor `order` como in_progress.
   *
   * Idempotente: pode ser chamado múltiplas vezes sem efeitos colaterais.
   */
  private async advanceProjectAfterEscrow(contractId: string) {
    const contract = await this.prisma.contract.findUnique({
      where: { id: contractId },
      include: {
        project: { include: { phases: { orderBy: { order: 'asc' } } } },
      },
    });
    if (!contract) return;

    let currentStatus: string = contract.project.status;

    // 1) contract_signed -> active_escrow (PAY) — só se escrow real existe
    if (currentStatus === 'contract_signed') {
      const escrow = await this.prisma.escrowTxn.findUnique({ where: { contractId } });
      if (escrow) {
        const next = getNextStatus(currentStatus, 'PAY');
        if (next) {
          const from = currentStatus as ProjectStatus;
          await this.prisma.project.update({
            where: { id: contract.projectId },
            data: { status: next as ProjectStatus },
          });
          currentStatus = next;
          this.eventEmitter.emit('project.status_changed', {
            projectId: contract.projectId,
            from,
            to: next as ProjectStatus,
          });
          this.logger.log(
            `Projeto ${contract.projectId}: contract_signed -> ${next}`,
          );
        }
      }
    }

    // 2) active_escrow -> in_execution (START), só se worker já assinou
    if (currentStatus === 'active_escrow' && contract.signedAt) {
      const next = getNextStatus(currentStatus, 'START');
      if (next) {
        const from = currentStatus as ProjectStatus;
        await this.prisma.project.update({
          where: { id: contract.projectId },
          data: { status: next as ProjectStatus },
        });
        currentStatus = next;
        this.eventEmitter.emit('project.status_changed', {
          projectId: contract.projectId,
          from,
          to: next as ProjectStatus,
        });
        this.logger.log(`Projeto ${contract.projectId}: active_escrow -> ${next}`);
      }
    }

    // 3) Ao entrar em in_execution, marcar primeira fase pending como in_progress
    if (currentStatus === 'in_execution') {
      const firstPending = contract.project.phases.find(
        (p) => p.status === 'pending',
      );
      if (firstPending) {
        await this.prisma.projectPhase.update({
          where: { id: firstPending.id },
          data: { status: 'in_progress' },
        });
        this.eventEmitter.emit('phase.started', { phaseId: firstPending.id });
        this.logger.log(
          `Fase ${firstPending.id} (order ${firstPending.order}) iniciada como in_progress`,
        );
      }
    }
  }

  /**
   * Listener: contrato assinado pelo worker.
   * Se o escrow já está ativo, avança o projeto para in_execution.
   */
  @OnEvent('contract.signed')
  async onContractSigned(payload: { contractId: string }) {
    await this.advanceProjectAfterEscrow(payload.contractId);
  }

  /**
   * Listener: fase validada pelo cliente.
   * Transfere 70% do valor da fase ao worker via Stripe Connect.
   * Se todas as fases do projeto estiverem validadas, marca o escrow como released.
   */
  @OnEvent('phase.validated')
  async onPhaseValidated(payload: { phaseId: string }) {
    const phase = await this.prisma.projectPhase.findUnique({
      where: { id: payload.phaseId },
      include: {
        project: {
          select: {
            title: true,
            phases: { select: { id: true, status: true } },
            contract: {
              include: {
                escrow: true,
                worker: true,
              },
            },
          },
        },
      },
    });

    if (!phase) return;

    const contract = phase.project.contract;
    if (!contract?.escrow) {
      this.logger.warn(`Fase ${payload.phaseId} validada mas não há escrow para o contrato`);
      return;
    }

    const { escrow, worker } = contract;

    if (escrow.status !== 'held') {
      this.logger.warn(`Escrow ${escrow.id} não está em 'held' (status: ${escrow.status}), pulando transfer`);
      return;
    }

    if (!worker.stripeAccountId) {
      this.logger.warn(`Worker ${worker.id} não tem conta Stripe — transfer ignorado`);
      return;
    }

    if (!escrow.stripeSourceChargeId) {
      this.logger.error(
        `Escrow ${escrow.id} sem stripeSourceChargeId (charge ch_...) — obrigatório para transfers ao Brasil`,
      );
      return;
    }

    const workerCents = Math.floor(Number(phase.amount) * 100 * 0.7);

    try {
      const transfer = await this.stripeService.client.transfers.create(
        {
          amount: workerCents,
          currency: this.stripeService.chargeCurrency,
          destination: worker.stripeAccountId,
          source_transaction: escrow.stripeSourceChargeId,
          metadata: { phaseId: payload.phaseId, type: 'phase_payment' },
        },
        { idempotencyKey: `phase_${payload.phaseId}` },
      );

      const paymentRow = await this.prisma.payment.create({
        data: {
          escrowId: escrow.id,
          recipientType: 'worker',
          recipientId: contract.workerId,
          amount: workerCents / 100,
          stripeTransferId: transfer.id,
          paidAt: new Date(),
        },
      });

      this.eventEmitter.emit('payment.transferred', {
        paymentId: paymentRow.id,
        escrowId: escrow.id,
        phaseId: payload.phaseId,
        workerUserId: worker.userId,
        amount: workerCents / 100,
        projectTitle: phase.project.title,
      });

      this.logger.log(
        `Fase ${payload.phaseId}: ${(workerCents / 100).toFixed(2)} ${this.stripeService.chargeCurrency.toUpperCase()} transferidos ao worker ${worker.id} (transfer ${transfer.id})`,
      );
    } catch (err) {
      this.logger.error(`Erro no transfer da fase ${payload.phaseId}: ${err}`);
      return;
    }

    const allValidated = phase.project.phases.every(
      (p) => p.id === payload.phaseId || p.status === 'validated',
    );

    if (allValidated) {
      await this.prisma.escrowTxn.update({
        where: { id: escrow.id },
        data: { status: 'released', releasedAt: new Date() },
      });
      this.logger.log(`Projeto ${phase.projectId}: todas as fases validadas — escrow ${escrow.id} liberado`);
      this.eventEmitter.emit('payment.released', { escrowId: escrow.id });
    }
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

  /** Pagamentos creditados ao worker (transfers Connect registadas em Payment). */
  async listWorkerPayments(workerId: string) {
    const rows = await this.prisma.payment.findMany({
      where: { recipientType: 'worker', recipientId: workerId },
      orderBy: [{ paidAt: 'desc' }, { id: 'desc' }],
      include: {
        escrow: {
          include: {
            contract: {
              include: {
                project: { select: { id: true, title: true } },
              },
            },
          },
        },
      },
    });

    return rows.map((p) => ({
      id: p.id,
      amount: Number(p.amount),
      recipientType: p.recipientType,
      paidAt: p.paidAt,
      stripeTransferId: p.stripeTransferId,
      status: p.escrow.status,
      escrow: {
        id: p.escrow.id,
        status: p.escrow.status,
        amount: Number(p.escrow.amount),
        contract: {
          id: p.escrow.contract.id,
          project: p.escrow.contract.project,
        },
      },
    }));
  }

  async listAllPaymentsAdmin() {
    const rows = await this.prisma.payment.findMany({
      orderBy: [{ paidAt: 'desc' }, { id: 'desc' }],
      include: {
        escrow: {
          include: {
            contract: {
              include: {
                project: { select: { id: true, title: true } },
                worker: {
                  include: { user: { select: { id: true, name: true } } },
                },
              },
            },
          },
        },
      },
    });

    return rows.map((p) => ({
      id: p.id,
      amount: Number(p.amount),
      recipientType: p.recipientType,
      recipientId: p.recipientId,
      paidAt: p.paidAt,
      stripeTransferId: p.stripeTransferId,
      escrow: {
        id: p.escrow.id,
        status: p.escrow.status,
        amount: Number(p.escrow.amount),
        contract: {
          id: p.escrow.contract.id,
          totalAmount: Number(p.escrow.contract.totalAmount),
          project: p.escrow.contract.project,
          worker: {
            id: p.escrow.contract.worker.id,
            user: p.escrow.contract.worker.user,
          },
        },
      },
    }));
  }

  async getAdminPaymentStats() {
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    const [paymentsMonth, workerReleasedMonth, heldEscrow] = await Promise.all([
      this.prisma.payment.aggregate({
        where: { paidAt: { gte: startOfMonth } },
        _sum: { amount: true },
      }),
      this.prisma.payment.aggregate({
        where: {
          recipientType: 'worker',
          paidAt: { gte: startOfMonth },
        },
        _sum: { amount: true },
      }),
      this.prisma.escrowTxn.aggregate({
        where: { status: 'held' },
        _sum: { amount: true },
      }),
    ]);

    const weeklyData = await this.buildWeeklyReleasedBuckets();

    return {
      totalThisMonth: Number(paymentsMonth._sum.amount ?? 0),
      released: Number(workerReleasedMonth._sum.amount ?? 0),
      inEscrow: Number(heldEscrow._sum.amount ?? 0),
      weeklyData,
    };
  }

  /** Últimas 4 janelas de 7 dias: liberado ao worker (EscrowTxn não tem createdAt — escrow semanal fica 0). */
  private async buildWeeklyReleasedBuckets() {
    const now = new Date();
    const buckets: { week: string; released: number; escrow: number }[] = [];

    for (let i = 3; i >= 0; i--) {
      const weekEnd = new Date(now);
      weekEnd.setDate(weekEnd.getDate() - i * 7);
      weekEnd.setHours(23, 59, 59, 999);
      const weekStart = new Date(weekEnd);
      weekStart.setDate(weekStart.getDate() - 7);
      weekStart.setHours(0, 0, 0, 0);

      const agg = await this.prisma.payment.aggregate({
        where: {
          recipientType: 'worker',
          paidAt: { gte: weekStart, lte: weekEnd },
        },
        _sum: { amount: true },
      });

      buckets.push({
        week: `Sem ${4 - i}`,
        released: Number(agg._sum.amount ?? 0),
        escrow: 0,
      });
    }

    return buckets;
  }
}
