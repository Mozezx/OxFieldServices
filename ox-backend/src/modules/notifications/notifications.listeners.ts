import { Injectable } from '@nestjs/common';
import { OnEvent } from '@nestjs/event-emitter';
import { NotificationsService } from './notifications.service';

@Injectable()
export class NotificationsListeners {
  constructor(private readonly notificationsService: NotificationsService) {}

  @OnEvent('phase.validated')
  async handlePhaseValidated(payload: { phaseId: string }) {
    await this.notificationsService.notifyPhaseValidated(payload.phaseId);
  }

  @OnEvent('phase.rejected')
  async handlePhaseRejected(payload: { phaseId: string }) {
    await this.notificationsService.notifyPhaseRejected(payload.phaseId);
  }

  @OnEvent('payment.released')
  async handlePaymentReleased(payload: { escrowId: string }) {
    await this.notificationsService.notifyPaymentReleased(payload.escrowId);
  }
}
