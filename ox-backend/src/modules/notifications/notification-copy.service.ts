import { Injectable } from '@nestjs/common';
import type { NotificationType } from '@prisma/client';

import en from './i18n/en.json';
import es from './i18n/es.json';
import nl from './i18n/nl.json';
import pt from './i18n/pt.json';

export type NotificationLocale = 'pt' | 'en' | 'es' | 'nl';

const BUNDLES: Record<NotificationLocale, Record<string, string>> = {
  pt: pt as Record<string, string>,
  en: en as Record<string, string>,
  es: es as Record<string, string>,
  nl: nl as Record<string, string>,
};

function interpolate(
  template: string,
  vars: Record<string, string>,
): string {
  let out = template;
  for (const [k, v] of Object.entries(vars)) {
    out = out.split(`{${k}}`).join(v);
  }
  return out;
}

@Injectable()
export class NotificationCopyService {
  normalizeLocale(raw: string | null | undefined): NotificationLocale {
    const k = (raw ?? 'pt').toLowerCase().slice(0, 2);
    if (k === 'en' || k === 'es' || k === 'nl' || k === 'pt') return k;
    return 'pt';
  }

  t(locale: NotificationLocale, key: string): string {
    return BUNDLES[locale][key] ?? BUNDLES.pt[key] ?? key;
  }

  /**
   * Builds localized title/body for persistence + FCM.
   * Falls back to listener-provided strings when type has no template mapping.
   */
  format(
    type: NotificationType,
    localeRaw: string | null | undefined,
    data: Record<string, unknown> | null | undefined,
    fallback: { title: string; body: string },
  ): { title: string; body: string } {
    const locale = this.normalizeLocale(localeRaw);
    const d = data ?? {};
    const variant = String(d.variant ?? 'client');
    const projectTitle = String(d.projectTitle ?? '');
    const phaseName = String(d.phaseName ?? '');
    const clientName = String(d.clientName ?? '');
    const amount = String(d.amount ?? '');
    const score = String(d.score ?? '');
    const createdByAdmin = Boolean(d.createdByAdmin);
    const reasonRaw = d.reason;
    const reason =
      reasonRaw !== undefined && reasonRaw !== null && String(reasonRaw).trim()
        ? ` ${String(reasonRaw).trim()}`
        : '';

    try {
      switch (type) {
        case 'user_welcome':
          return {
            title: this.t(locale, 'notifUserWelcomeTitle'),
            body: this.t(locale, 'notifUserWelcomeBody'),
          };

        case 'project_created': {
          if (variant === 'admin') {
            if (createdByAdmin && clientName) {
              return {
                title: this.t(locale, 'notifProjectCreatedAdminTitle'),
                body: interpolate(
                  this.t(locale, 'notifProjectCreatedAdminRegisteredBody'),
                  { projectTitle, clientName },
                ),
              };
            }
            return {
              title: this.t(locale, 'notifProjectCreatedAdminTitle'),
              body: interpolate(
                this.t(locale, 'notifProjectCreatedAdminBody'),
                { projectTitle },
              ),
            };
          }
          return {
            title: this.t(locale, 'notifProjectCreatedClientTitle'),
            body: interpolate(
              this.t(locale, 'notifProjectCreatedClientBody'),
              { projectTitle },
            ),
          };
        }

        case 'project_in_validation':
          return {
            title: this.t(locale, 'notifProjectInValidationTitle'),
            body: interpolate(
              this.t(locale, 'notifProjectInValidationBody'),
              { projectTitle },
            ),
          };

        case 'project_matched':
          return {
            title: this.t(locale, 'notifProjectMatchedTitle'),
            body: interpolate(
              this.t(locale, 'notifProjectMatchedBody'),
              { projectTitle },
            ),
          };

        case 'project_activated':
          return {
            title: this.t(locale, 'notifProjectActivatedTitle'),
            body: interpolate(
              this.t(locale, 'notifProjectActivatedBody'),
              { projectTitle },
            ),
          };

        case 'project_closing':
          return {
            title: this.t(locale, 'notifProjectClosingTitle'),
            body: interpolate(
              this.t(locale, 'notifProjectClosingBody'),
              { projectTitle },
            ),
          };

        case 'project_closed':
          return {
            title: this.t(locale, 'notifProjectClosedTitle'),
            body: interpolate(
              this.t(locale, 'notifProjectClosedBody'),
              { projectTitle },
            ),
          };

        case 'project_rejected':
          return {
            title: this.t(locale, 'notifProjectRejectedTitle'),
            body: interpolate(
              this.t(locale, 'notifProjectRejectedBody'),
              { projectTitle },
            ),
          };

        case 'phase_started':
          return {
            title: this.t(locale, 'notifPhaseStartedTitle'),
            body: interpolate(
              this.t(locale, 'notifPhaseStartedBody'),
              { phaseName, projectTitle },
            ),
          };

        case 'phase_evidence_uploaded':
          if (variant === 'admin') {
            return {
              title: this.t(locale, 'notifPhaseEvidenceUploadedAdminTitle'),
              body: interpolate(
                this.t(locale, 'notifPhaseEvidenceUploadedAdminBody'),
                { projectTitle, phaseName },
              ),
            };
          }
          return {
            title: this.t(locale, 'notifPhaseEvidenceUploadedClientTitle'),
            body: interpolate(
              this.t(locale, 'notifPhaseEvidenceUploadedClientBody'),
              { phaseName, projectTitle },
            ),
          };

        case 'phase_under_review':
          return {
            title: this.t(locale, 'notifPhaseUnderReviewTitle'),
            body: interpolate(
              this.t(locale, 'notifPhaseUnderReviewBody'),
              { phaseName, projectTitle },
            ),
          };

        case 'phase_validated':
          if (variant === 'worker') {
            return {
              title: this.t(locale, 'notifPhaseValidatedWorkerTitle'),
              body: interpolate(
                this.t(locale, 'notifPhaseValidatedWorkerBody'),
                { phaseName, projectTitle },
              ),
            };
          }
          return {
            title: this.t(locale, 'notifPhaseValidatedClientTitle'),
            body: interpolate(
              this.t(locale, 'notifPhaseValidatedClientBody'),
              { phaseName, projectTitle },
            ),
          };

        case 'phase_rejected':
          if (variant === 'worker') {
            return {
              title: this.t(locale, 'notifPhaseRejectedWorkerTitle'),
              body: interpolate(
                this.t(locale, 'notifPhaseRejectedWorkerBody'),
                { phaseName, projectTitle },
              ),
            };
          }
          return {
            title: this.t(locale, 'notifPhaseRejectedClientTitle'),
            body: interpolate(
              this.t(locale, 'notifPhaseRejectedClientBody'),
              { phaseName, projectTitle },
            ),
          };

        case 'contract_created':
          return {
            title: this.t(locale, 'notifContractCreatedTitle'),
            body: interpolate(
              this.t(locale, 'notifContractCreatedBody'),
              { projectTitle },
            ),
          };

        case 'worker_invited':
          return {
            title: this.t(locale, 'notifWorkerInvitedTitle'),
            body: interpolate(
              this.t(locale, 'notifWorkerInvitedBody'),
              { projectTitle },
            ),
          };

        case 'worker_assigned':
          return {
            title: this.t(locale, 'notifWorkerAssignedTitle'),
            body: interpolate(
              this.t(locale, 'notifWorkerAssignedBody'),
              { projectTitle },
            ),
          };

        case 'contract_signed':
          if (variant === 'admin') {
            return {
              title: this.t(locale, 'notifContractSignedAdminTitle'),
              body: interpolate(
                this.t(locale, 'notifContractSignedAdminBody'),
                { projectTitle },
              ),
            };
          }
          if (variant === 'worker') {
            return {
              title: this.t(locale, 'notifContractSignedWorkerTitle'),
              body: interpolate(
                this.t(locale, 'notifContractSignedWorkerBody'),
                { projectTitle },
              ),
            };
          }
          return {
            title: this.t(locale, 'notifContractSignedClientTitle'),
            body: interpolate(
              this.t(locale, 'notifContractSignedClientBody'),
              { projectTitle },
            ),
          };

        case 'escrow_held':
          return {
            title: this.t(locale, 'notifEscrowHeldTitle'),
            body: interpolate(this.t(locale, 'notifEscrowHeldBody'), {
              projectTitle,
            }),
          };

        case 'payment_transferred':
          if (variant === 'admin') {
            return {
              title: this.t(locale, 'notifPaymentTransferredAdminTitle'),
              body: interpolate(
                this.t(locale, 'notifPaymentTransferredAdminBody'),
                { projectTitle },
              ),
            };
          }
          return {
            title: this.t(locale, 'notifPaymentTransferredWorkerTitle'),
            body: interpolate(
              this.t(locale, 'notifPaymentTransferredWorkerBody'),
              { amount, projectTitle },
            ),
          };

        case 'escrow_released':
          if (variant === 'worker') {
            return {
              title: this.t(locale, 'notifEscrowReleasedWorkerTitle'),
              body: interpolate(
                this.t(locale, 'notifEscrowReleasedWorkerBody'),
                { projectTitle },
              ),
            };
          }
          return {
            title: this.t(locale, 'notifEscrowReleasedClientTitle'),
            body: interpolate(
              this.t(locale, 'notifEscrowReleasedClientBody'),
              { projectTitle },
            ),
          };

        case 'payment_failed':
          if (variant === 'admin') {
            return {
              title: this.t(locale, 'notifPaymentFailedAdminTitle'),
              body:
                interpolate(
                  this.t(locale, 'notifPaymentFailedAdminBody'),
                  { projectTitle },
                ) + reason,
            };
          }
          return {
            title: this.t(locale, 'notifPaymentFailedTitle'),
            body:
              interpolate(this.t(locale, 'notifPaymentFailedBody'), {
                projectTitle,
              }) + reason,
          };

        case 'worker_rated':
          return {
            title: this.t(locale, 'notifWorkerRatedTitle'),
            body: interpolate(
              this.t(locale, 'notifWorkerRatedBody'),
              { score, projectTitle },
            ),
          };

        case 'invite_redeemed':
          if (variant === 'admin') {
            return {
              title: this.t(locale, 'notifInviteRedeemedAdminTitle'),
              body: interpolate(
                this.t(locale, 'notifInviteRedeemedAdminBody'),
                { clientName, projectTitle },
              ),
            };
          }
          return {
            title: this.t(locale, 'notifInviteRedeemedClientTitle'),
            body: interpolate(
              this.t(locale, 'notifInviteRedeemedClientBody'),
              { projectTitle },
            ),
          };

        default:
          return fallback;
      }
    } catch {
      return fallback;
    }
  }
}
