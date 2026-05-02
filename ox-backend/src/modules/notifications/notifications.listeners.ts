import { Injectable, Logger } from '@nestjs/common';
import { OnEvent } from '@nestjs/event-emitter';
import type { NotificationType, ProjectStatus } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.service';
import { NotificationsService } from './notifications.service';

@Injectable()
export class NotificationsListeners {
  private readonly logger = new Logger(NotificationsListeners.name);

  constructor(
    private readonly notifications: NotificationsService,
    private readonly prisma: PrismaService,
  ) {}

  @OnEvent('user.created')
  async onUserCreated(payload: { userId: string }) {
    try {
      await this.notifications.create({
        userId: payload.userId,
        type: 'user_welcome',
        title: 'Bem-vindo ao OX Field Service',
        body: 'Sua conta foi criada com sucesso.',
        entityType: 'user',
        entityId: payload.userId,
      });
    } catch (e) {
      this.logger.warn(`user.created listener: ${String(e)}`);
    }
  }

  @OnEvent('project.created')
  async onProjectCreated(payload: { projectId: string; clientId: string }) {
    try {
      const project = await this.prisma.project.findUnique({
        where: { id: payload.projectId },
        select: { title: true },
      });
      const title = project?.title ?? 'Projeto';
      const admins = await this.notifications.getAdminUserIds();
      await this.notifications.create({
        userId: payload.clientId,
        type: 'project_created',
        title: 'Projeto criado',
        body: `O projeto "${title}" foi criado.`,
        entityType: 'project',
        entityId: payload.projectId,
      });
      await this.notifications.createForUsers(admins, {
        type: 'project_created',
        title: 'Novo projeto',
        body: `Cliente criou o projeto "${title}".`,
        entityType: 'project',
        entityId: payload.projectId,
      });
    } catch (e) {
      this.logger.warn(`project.created listener: ${String(e)}`);
    }
  }

  @OnEvent('project.status_changed')
  async onProjectStatusChanged(payload: {
    projectId: string;
    from: ProjectStatus;
    to: ProjectStatus;
  }) {
    try {
      const mapped = this.mapProjectStatusToNotificationType(payload.to);
      if (!mapped) return;

      const project = await this.prisma.project.findUnique({
        where: { id: payload.projectId },
        select: {
          title: true,
          clientId: true,
          contract: {
            select: {
              worker: { select: { userId: true } },
            },
          },
        },
      });
      if (!project) return;

      const workerUserId = project.contract?.worker?.userId;
      const admins = await this.notifications.getAdminUserIds();
      const titleText = project.title;
      const { title, body } = this.projectStatusMessage(mapped, titleText);

      const recipients = new Set<string>();
      recipients.add(project.clientId);
      if (workerUserId) recipients.add(workerUserId);
      admins.forEach((id) => recipients.add(id));

      if (payload.to === 'closed') {
        await this.notifications.createForUsers(
          [project.clientId, ...(workerUserId ? [workerUserId] : [])],
          {
            type: mapped,
            title,
            body,
            entityType: 'project',
            entityId: payload.projectId,
            data: { from: payload.from, to: payload.to },
          },
        );
        return;
      }

      await this.notifications.createForUsers([...recipients], {
        type: mapped,
        title,
        body,
        entityType: 'project',
        entityId: payload.projectId,
        data: { from: payload.from, to: payload.to },
      });
    } catch (e) {
      this.logger.warn(`project.status_changed listener: ${String(e)}`);
    }
  }

  @OnEvent('phase.started')
  async onPhaseStarted(payload: { phaseId: string }) {
    try {
      const phase = await this.loadPhaseBasics(payload.phaseId);
      if (!phase) return;
      const admins = await this.notifications.getAdminUserIds();
      const workerUserId = phase.project.contract?.worker?.userId;
      const targets = [
        ...(workerUserId ? [workerUserId] : []),
        ...admins,
      ];
      if (targets.length === 0) return;
      await this.notifications.createForUsers(targets, {
        type: 'phase_started',
        title: 'Fase iniciada',
        body: `A fase "${phase.name}" do projeto "${phase.project.title}" foi iniciada.`,
        entityType: 'phase',
        entityId: payload.phaseId,
      });
    } catch (e) {
      this.logger.warn(`phase.started listener: ${String(e)}`);
    }
  }

  @OnEvent('phase.evidence_uploaded')
  async onPhaseEvidenceUploaded(payload: { phaseId: string }) {
    try {
      const phase = await this.loadPhaseBasics(payload.phaseId);
      if (!phase) return;
      const admins = await this.notifications.getAdminUserIds();
      await this.notifications.create({
        userId: phase.project.clientId,
        type: 'phase_evidence_uploaded',
        title: 'Novas evidências',
        body: `O trabalhador enviou evidências para a fase "${phase.name}" em "${phase.project.title}".`,
        entityType: 'phase',
        entityId: payload.phaseId,
      });
      await this.notifications.createForUsers(admins, {
        type: 'phase_evidence_uploaded',
        title: 'Evidências recebidas',
        body: `Projeto "${phase.project.title}" — fase "${phase.name}".`,
        entityType: 'phase',
        entityId: payload.phaseId,
      });
    } catch (e) {
      this.logger.warn(`phase.evidence_uploaded listener: ${String(e)}`);
    }
  }

  @OnEvent('phase.under_review')
  async onPhaseUnderReview(payload: { phaseId: string }) {
    try {
      const phase = await this.loadPhaseBasics(payload.phaseId);
      if (!phase) return;
      await this.notifications.create({
        userId: phase.project.clientId,
        type: 'phase_under_review',
        title: 'Fase em revisão',
        body: `A fase "${phase.name}" de "${phase.project.title}" está aguardando sua validação.`,
        entityType: 'phase',
        entityId: payload.phaseId,
      });
    } catch (e) {
      this.logger.warn(`phase.under_review listener: ${String(e)}`);
    }
  }

  @OnEvent('phase.validated')
  async onPhaseValidated(payload: { phaseId: string }) {
    try {
      const phase = await this.prisma.projectPhase.findUnique({
        where: { id: payload.phaseId },
        include: {
          project: {
            select: {
              id: true,
              title: true,
              clientId: true,
              contract: {
                select: {
                  worker: {
                    select: { user: { select: { id: true } } },
                  },
                },
              },
            },
          },
        },
      });
      if (!phase) return;

      const workerUserId = phase.project.contract?.worker?.user?.id;
      const clientId = phase.project.clientId;

      await this.notifications.create({
        userId: clientId,
        type: 'phase_validated',
        title: 'Fase validada',
        body: `A fase ${phase.name} do projeto ${phase.project.title} foi validada.`,
        entityType: 'phase',
        entityId: payload.phaseId,
        data: { projectId: phase.project.id },
      });

      if (workerUserId) {
        await this.notifications.create({
          userId: workerUserId,
          type: 'phase_validated',
          title: 'Fase aprovada',
          body: `Sua fase ${phase.name} foi aprovada no projeto ${phase.project.title}.`,
          entityType: 'phase',
          entityId: payload.phaseId,
          data: { projectId: phase.project.id },
        });
      }
    } catch (e) {
      this.logger.warn(`phase.validated notification: ${String(e)}`);
    }
  }

  @OnEvent('phase.rejected')
  async onPhaseRejected(payload: { phaseId: string }) {
    try {
      const phase = await this.prisma.projectPhase.findUnique({
        where: { id: payload.phaseId },
        include: {
          project: {
            select: {
              id: true,
              title: true,
              clientId: true,
              contract: {
                select: {
                  worker: {
                    select: { user: { select: { id: true } } },
                  },
                },
              },
            },
          },
        },
      });
      if (!phase) return;

      const workerUserId = phase.project.contract?.worker?.user?.id;

      if (workerUserId) {
        await this.notifications.create({
          userId: workerUserId,
          type: 'phase_rejected',
          title: 'Fase rejeitada',
          body: `A fase ${phase.name} do projeto ${phase.project.title} foi rejeitada e precisa de ajustes.`,
          entityType: 'phase',
          entityId: payload.phaseId,
          data: { projectId: phase.project.id },
        });
      }

      await this.notifications.create({
        userId: phase.project.clientId,
        type: 'phase_rejected',
        title: 'Rejeição registrada',
        body: `A fase ${phase.name} foi marcada como rejeitada no projeto ${phase.project.title}.`,
        entityType: 'phase',
        entityId: payload.phaseId,
        data: { projectId: phase.project.id },
      });
    } catch (e) {
      this.logger.warn(`phase.rejected notification: ${String(e)}`);
    }
  }

  @OnEvent('contract.created')
  async onContractCreated(payload: {
    contractId: string;
    projectId: string;
    workerId: string;
  }) {
    try {
      const worker = await this.prisma.worker.findUnique({
        where: { id: payload.workerId },
        select: { userId: true },
      });
      const project = await this.prisma.project.findUnique({
        where: { id: payload.projectId },
        select: { title: true },
      });
      if (!worker) return;
      await this.notifications.create({
        userId: worker.userId,
        type: 'contract_created',
        title: 'Novo contrato',
        body: `Você foi atribuído ao projeto "${project?.title ?? 'Projeto'}". Assine o contrato para continuar.`,
        entityType: 'contract',
        entityId: payload.contractId,
        data: { projectId: payload.projectId },
      });
    } catch (e) {
      this.logger.warn(`contract.created listener: ${String(e)}`);
    }
  }

  @OnEvent('worker.invited')
  async onWorkerInvited(payload: { projectId: string; workerId: string }) {
    try {
      const worker = await this.prisma.worker.findUnique({
        where: { id: payload.workerId },
        select: { userId: true },
      });
      const project = await this.prisma.project.findUnique({
        where: { id: payload.projectId },
        select: { title: true },
      });
      if (!worker) return;
      await this.notifications.create({
        userId: worker.userId,
        type: 'worker_invited',
        title: 'Convite para projeto',
        body: `Você foi selecionado para o projeto "${project?.title ?? 'Projeto'}".`,
        entityType: 'project',
        entityId: payload.projectId,
      });
    } catch (e) {
      this.logger.warn(`worker.invited listener: ${String(e)}`);
    }
  }

  @OnEvent('worker.assigned')
  async onWorkerAssigned(payload: {
    contractId: string;
    projectId: string;
    workerId: string;
  }) {
    try {
      const worker = await this.prisma.worker.findUnique({
        where: { id: payload.workerId },
        select: { userId: true },
      });
      const project = await this.prisma.project.findUnique({
        where: { id: payload.projectId },
        select: { title: true },
      });
      if (!worker) return;
      await this.notifications.create({
        userId: worker.userId,
        type: 'worker_assigned',
        title: 'Atribuição confirmada',
        body: `Você está atribuído ao projeto "${project?.title ?? 'Projeto'}".`,
        entityType: 'contract',
        entityId: payload.contractId,
        data: { projectId: payload.projectId },
      });
    } catch (e) {
      this.logger.warn(`worker.assigned listener: ${String(e)}`);
    }
  }

  @OnEvent('contract.signed')
  async onContractSigned(payload: { contractId: string }) {
    try {
      const contract = await this.prisma.contract.findUnique({
        where: { id: payload.contractId },
        include: {
          project: { select: { id: true, title: true, clientId: true } },
          worker: { select: { userId: true } },
        },
      });
      if (!contract) return;
      const admins = await this.notifications.getAdminUserIds();

      await this.notifications.create({
        userId: contract.project.clientId,
        type: 'contract_signed',
        title: 'Contrato assinado',
        body: `O contrato do projeto "${contract.project.title}" foi assinado pelo trabalhador.`,
        entityType: 'contract',
        entityId: payload.contractId,
        data: { projectId: contract.projectId },
      });

      await this.notifications.create({
        userId: contract.worker.userId,
        type: 'contract_signed',
        title: 'Contrato assinado',
        body: `Você assinou o contrato do projeto "${contract.project.title}".`,
        entityType: 'contract',
        entityId: payload.contractId,
        data: { projectId: contract.projectId },
      });

      await this.notifications.createForUsers(admins, {
        type: 'contract_signed',
        title: 'Contrato assinado',
        body: `Projeto "${contract.project.title}" — contrato assinado.`,
        entityType: 'contract',
        entityId: payload.contractId,
        data: { projectId: contract.projectId },
      });
    } catch (e) {
      this.logger.warn(`contract.signed listener: ${String(e)}`);
    }
  }

  @OnEvent('escrow.held')
  async onEscrowHeld(payload: { contractId: string }) {
    try {
      const contract = await this.prisma.contract.findUnique({
        where: { id: payload.contractId },
        include: {
          project: { select: { id: true, title: true, clientId: true } },
          worker: { select: { userId: true } },
        },
      });
      if (!contract) return;
      const admins = await this.notifications.getAdminUserIds();
      const recipients = [
        contract.project.clientId,
        contract.worker.userId,
        ...admins,
      ];
      await this.notifications.createForUsers(recipients, {
        type: 'escrow_held',
        title: 'Pagamento em escrow',
        body: `O valor do projeto "${contract.project.title}" está retido em escrow.`,
        entityType: 'contract',
        entityId: payload.contractId,
        data: { projectId: contract.projectId },
      });
    } catch (e) {
      this.logger.warn(`escrow.held listener: ${String(e)}`);
    }
  }

  @OnEvent('payment.transferred')
  async onPaymentTransferred(payload: {
    paymentId: string;
    escrowId: string;
    phaseId: string;
    workerUserId: string;
    amount: number;
    projectTitle: string;
  }) {
    try {
      const admins = await this.notifications.getAdminUserIds();
      await this.notifications.create({
        userId: payload.workerUserId,
        type: 'payment_transferred',
        title: 'Transferência recebida',
        body: `Foi creditado ${payload.amount.toFixed(2)} no projeto "${payload.projectTitle}".`,
        entityType: 'payment',
        entityId: payload.paymentId,
        data: { escrowId: payload.escrowId, phaseId: payload.phaseId },
      });
      await this.notifications.createForUsers(admins, {
        type: 'payment_transferred',
        title: 'Pagamento transferido',
        body: `Projeto "${payload.projectTitle}" — transferência ao trabalhador registrada.`,
        entityType: 'payment',
        entityId: payload.paymentId,
      });
    } catch (e) {
      this.logger.warn(`payment.transferred listener: ${String(e)}`);
    }
  }

  @OnEvent('payment.released')
  async onPaymentReleased(payload: { escrowId: string }) {
    try {
      const escrow = await this.prisma.escrowTxn.findUnique({
        where: { id: payload.escrowId },
        include: {
          contract: {
            include: {
              project: {
                select: { id: true, title: true, clientId: true },
              },
              worker: {
                select: { user: { select: { id: true } } },
              },
            },
          },
        },
      });
      if (!escrow) return;

      const clientId = escrow.contract.project.clientId;
      const workerUserId = escrow.contract.worker.user.id;

      await this.notifications.create({
        userId: workerUserId,
        type: 'escrow_released',
        title: 'Pagamento liberado',
        body: `O pagamento do projeto ${escrow.contract.project.title} foi liberado.`,
        entityType: 'escrow',
        entityId: payload.escrowId,
        data: { projectId: escrow.contract.project.id },
      });

      await this.notifications.create({
        userId: clientId,
        type: 'escrow_released',
        title: 'Pagamento concluído',
        body: `O pagamento do projeto ${escrow.contract.project.title} foi transferido com sucesso.`,
        entityType: 'escrow',
        entityId: payload.escrowId,
        data: { projectId: escrow.contract.project.id },
      });
    } catch (e) {
      this.logger.warn(`payment.released notification: ${String(e)}`);
    }
  }

  @OnEvent('payment.failed')
  async onPaymentFailed(payload: { contractId?: string; reason?: string }) {
    try {
      if (!payload.contractId) return;
      const contract = await this.prisma.contract.findUnique({
        where: { id: payload.contractId },
        include: {
          project: { select: { id: true, title: true, clientId: true } },
        },
      });
      if (!contract) return;
      const admins = await this.notifications.getAdminUserIds();
      await this.notifications.create({
        userId: contract.project.clientId,
        type: 'payment_failed',
        title: 'Falha no pagamento',
        body: `Não foi possível concluir o pagamento do projeto "${contract.project.title}". ${payload.reason ?? ''}`,
        entityType: 'contract',
        entityId: payload.contractId,
      });
      await this.notifications.createForUsers(admins, {
        type: 'payment_failed',
        title: 'Falha no pagamento',
        body: `Projeto "${contract.project.title}" — pagamento falhou.`,
        entityType: 'contract',
        entityId: payload.contractId,
      });
    } catch (e) {
      this.logger.warn(`payment.failed listener: ${String(e)}`);
    }
  }

  @OnEvent('worker.rated')
  async onWorkerRated(payload: {
    workerId: string;
    projectId: string;
    score: number;
  }) {
    try {
      const worker = await this.prisma.worker.findUnique({
        where: { id: payload.workerId },
        select: { userId: true },
      });
      const project = await this.prisma.project.findUnique({
        where: { id: payload.projectId },
        select: { title: true },
      });
      if (!worker) return;
      await this.notifications.create({
        userId: worker.userId,
        type: 'worker_rated',
        title: 'Nova avaliação',
        body: `Você recebeu nota ${payload.score} no projeto "${project?.title ?? 'Projeto'}".`,
        entityType: 'project',
        entityId: payload.projectId,
        data: { score: payload.score },
      });
    } catch (e) {
      this.logger.warn(`worker.rated listener: ${String(e)}`);
    }
  }

  private mapProjectStatusToNotificationType(
    to: ProjectStatus,
  ): NotificationType | null {
    switch (to) {
      case 'in_validation':
        return 'project_in_validation';
      case 'matched':
        return 'project_matched';
      case 'contract_signed':
        return 'project_matched';
      case 'active_escrow':
        return 'project_activated';
      case 'in_execution':
        return 'project_activated';
      case 'closing':
        return 'project_closing';
      case 'closed':
        return 'project_closed';
      case 'rejected':
        return 'project_rejected';
      default:
        return null;
    }
  }

  private projectStatusMessage(
    type: NotificationType,
    projectTitle: string,
  ): { title: string; body: string } {
    switch (type) {
      case 'project_in_validation':
        return {
          title: 'Projeto em validação',
          body: `"${projectTitle}" foi enviado para validação.`,
        };
      case 'project_matched':
        return {
          title: 'Projeto atualizado',
          body: `O projeto "${projectTitle}" avançou no fluxo.`,
        };
      case 'project_activated':
        return {
          title: 'Projeto ativo',
          body: `O projeto "${projectTitle}" está em andamento ou escrow ativo.`,
        };
      case 'project_closing':
        return {
          title: 'Projeto em encerramento',
          body: `Todas as fases de "${projectTitle}" foram validadas. Encerramento em curso.`,
        };
      case 'project_closed':
        return {
          title: 'Projeto encerrado',
          body: `O projeto "${projectTitle}" foi encerrado.`,
        };
      case 'project_rejected':
        return {
          title: 'Projeto rejeitado',
          body: `O projeto "${projectTitle}" foi rejeitado.`,
        };
      default:
        return {
          title: 'Projeto atualizado',
          body: `Status do projeto "${projectTitle}" mudou.`,
        };
    }
  }

  private async loadPhaseBasics(phaseId: string) {
    return this.prisma.projectPhase.findUnique({
      where: { id: phaseId },
      select: {
        name: true,
        project: {
          select: {
            title: true,
            clientId: true,
            contract: {
              select: {
                worker: { select: { userId: true } },
              },
            },
          },
        },
      },
    });
  }
}
