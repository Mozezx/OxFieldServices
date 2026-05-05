import type { NotificationType } from '@prisma/client';

const uniq = (scopes: string[]) => [...new Set(scopes)];

/**
 * Cache scopes for Flutter `applyClientRealtimeScopes` / `applyWorkerRealtimeScopes`.
 * Extra tags are ignored per app; overlap is intentional so both mobile apps refresh.
 */
export function scopesForNotificationType(type: NotificationType): string[] {
  const notifications = ['notifications'];

  switch (type) {
    case 'user_welcome':
      return uniq([...notifications, 'profile', 'projects']);

    case 'project_created':
    case 'project_in_validation':
    case 'project_matched':
    case 'project_activated':
    case 'project_closing':
    case 'project_closed':
    case 'project_rejected':
      return uniq([
        ...notifications,
        'projects',
        'jobs',
        'execution',
        'payments',
      ]);

    case 'phase_started':
    case 'phase_evidence_uploaded':
    case 'phase_under_review':
    case 'phase_validated':
    case 'phase_rejected':
      return uniq([
        ...notifications,
        'projects',
        'jobs',
        'execution',
        'payments',
      ]);

    case 'contract_created':
    case 'contract_signed':
      return uniq([
        ...notifications,
        'projects',
        'jobs',
        'execution',
        'payments',
      ]);

    case 'escrow_held':
    case 'escrow_released':
    case 'escrow_refunded':
      return uniq([...notifications, 'projects', 'jobs', 'payments', 'execution']);

    case 'payment_transferred':
    case 'payment_failed':
      return uniq([...notifications, 'payments', 'projects', 'jobs']);

    case 'worker_invited':
    case 'worker_assigned':
      return uniq([...notifications, 'jobs', 'projects', 'execution']);

    case 'worker_rated':
      return uniq([...notifications, 'jobs', 'profile']);

    case 'invite_redeemed':
      return uniq([...notifications, 'jobs', 'profile', 'projects']);

    default:
      return uniq([...notifications, 'projects', 'jobs', 'execution']);
  }
}
