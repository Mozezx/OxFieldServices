/** Payloads for NestJS EventEmitter2 — keep in sync with emitters and listeners. */

import type { ProjectStatus, UserRole } from '@prisma/client';

export type UserCreatedPayload = { userId: string; role: UserRole };

export type ProjectCreatedPayload = { projectId: string; clientId: string };

export type ProjectStatusChangedPayload = {
  projectId: string;
  from: ProjectStatus;
  to: ProjectStatus;
};

export type PhaseIdPayload = { phaseId: string };

export type ContractCreatedPayload = {
  contractId: string;
  projectId: string;
  workerId: string;
};

export type ContractSignedPayload = { contractId: string };

export type EscrowHeldPayload = { contractId: string };

export type PaymentReleasedPayload = { escrowId: string };

export type PaymentTransferredPayload = {
  paymentId: string;
  escrowId: string;
  phaseId: string;
  workerId: string;
  amount: number;
};

export type PaymentFailedPayload = { contractId?: string; reason?: string };

export type WorkerInvitedPayload = { projectId: string; workerId: string };

export type WorkerAssignedPayload = {
  contractId: string;
  projectId: string;
  workerId: string;
};

export type WorkerRatedPayload = {
  workerId: string;
  projectId: string;
  score: number;
  raterUserId: string;
};
