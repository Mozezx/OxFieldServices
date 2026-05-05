import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../core/router/notification_route_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ox_app_bar.dart';
import '../../l10n/app_localizations.dart';
import 'notifications_provider.dart';

/// Unread indicator on dark surfaces — blue dot only (icons stay visible at all times).
const _kUnreadDotColor = Color(0xFF42A5F5);

String _resolveTitle(AppLocalizations l, NotificationItem n) {
  final variant = n.metadata?['variant'] as String?;

  switch (n.type) {
    case 'user_welcome':
      return l.notifUserWelcomeTitle;
    case 'worker_invited':
      return l.notifWorkerInvitedTitle;
    case 'worker_assigned':
      return l.notifWorkerAssignedTitle;
    case 'contract_created':
      return l.notifContractCreatedTitle;
    case 'contract_signed':
      if (variant == 'worker') return l.notifContractSignedWorkerTitle;
      if (variant == 'admin') return l.notifContractSignedAdminTitle;
      return l.notifContractSignedClientTitle;
    case 'escrow_held':
      return l.notifEscrowHeldTitle;
    case 'project_activated':
      return l.notifProjectActivatedTitle;
    case 'project_matched':
      return l.notifProjectMatchedTitle;
    case 'project_closing':
      return l.notifProjectClosingTitle;
    case 'project_rejected':
      return l.notifProjectRejectedTitle;
    case 'project_created':
      if (variant == 'admin') return l.notifProjectCreatedAdminTitle;
      return l.notifProjectCreatedClientTitle;
    case 'phase_started':
      return l.notifPhaseStartedTitle;
    case 'phase_evidence_uploaded':
      if (variant == 'admin') return l.notifPhaseEvidenceUploadedAdminTitle;
      return l.notifPhaseEvidenceUploadedClientTitle;
    case 'phase_under_review':
      return l.notifPhaseUnderReviewClientTitle;
    case 'phase_validated':
      if (variant == 'worker') return l.notifPhaseValidatedWorkerTitle;
      return l.notifPhaseValidatedClientTitle;
    case 'phase_rejected':
      if (variant == 'worker') return l.notifPhaseRejectedWorkerTitle;
      return l.notifPhaseRejectedClientTitle;
    case 'payment_transferred':
      if (variant == 'admin') return l.notifPaymentTransferredAdminTitle;
      return l.notifPaymentTransferredWorkerTitle;
    case 'payment_failed':
      if (variant == 'admin') return l.notifPaymentFailedAdminTitle;
      return l.notifPaymentFailedTitle;
    case 'escrow_released':
      if (variant == 'worker') return l.notifEscrowReleasedWorkerTitle;
      return l.notifEscrowReleasedClientTitle;
    case 'project_closed':
      return l.notifProjectClosedTitle;
    case 'worker_rated':
      return l.notifWorkerRatedTitle;
    default:
      return n.title;
  }
}

String _resolveBody(AppLocalizations l, NotificationItem n) {
  final m = n.metadata;
  final variant = m?['variant'] as String?;
  final p = m?['projectTitle'] as String? ?? '';
  final ph = m?['phaseName'] as String? ?? '';
  final amt = (m?['amount'] ?? '').toString();
  final score = (m?['score'] ?? '').toString();

  switch (n.type) {
    case 'user_welcome':
      return l.notifUserWelcomeBody;
    case 'worker_invited':
      return l.notifWorkerInvitedBody(p);
    case 'worker_assigned':
      return l.notifWorkerAssignedBody(p);
    case 'contract_created':
      return l.notifContractCreatedBody(p);
    case 'contract_signed':
      if (variant == 'worker') return l.notifContractSignedWorkerBody(p);
      if (variant == 'admin') return l.notifContractSignedAdminBody(p);
      return l.notifContractSignedClientBody(p);
    case 'escrow_held':
      return l.notifEscrowHeldBody(p);
    case 'project_activated':
      return l.notifProjectActivatedBody(p);
    case 'project_matched':
      return l.notifProjectMatchedBody(p);
    case 'project_closing':
      return l.notifProjectClosingBody(p);
    case 'project_rejected':
      return l.notifProjectRejectedBody(p);
    case 'project_created':
      if (variant == 'admin') return l.notifProjectCreatedAdminBody(p);
      return l.notifProjectCreatedClientBody(p);
    case 'phase_started':
      return l.notifPhaseStartedBody(ph, p);
    case 'phase_evidence_uploaded':
      if (variant == 'admin') return l.notifPhaseEvidenceUploadedAdminBody(p, ph);
      return l.notifPhaseEvidenceUploadedClientBody(ph, p);
    case 'phase_under_review':
      return l.notifPhaseUnderReviewClientBody(ph, p);
    case 'phase_validated':
      if (variant == 'worker') return l.notifPhaseValidatedWorkerBody(ph, p);
      return l.notifPhaseValidatedClientBody(ph, p);
    case 'phase_rejected':
      if (variant == 'worker') return l.notifPhaseRejectedWorkerBody(ph, p);
      return l.notifPhaseRejectedClientBody(ph, p);
    case 'payment_transferred':
      if (variant == 'admin') return l.notifPaymentTransferredAdminBody(p);
      return l.notifPaymentTransferredWorkerBody(amt, p);
    case 'payment_failed':
      if (variant == 'admin') return l.notifPaymentFailedAdminBody(p);
      return l.notifPaymentFailedBody(p);
    case 'escrow_released':
      if (variant == 'worker') return l.notifEscrowReleasedWorkerBody(p);
      return l.notifEscrowReleasedClientBody(p);
    case 'project_closed':
      return l.notifProjectClosedBody(p);
    case 'worker_rated':
      return l.notifWorkerRatedBody(score, p);
    default:
      return n.body;
  }
}

IconData _notificationIcon(String type) {
  switch (type) {
    case 'user_welcome':
      return LucideIcons.sparkles;
    case 'project_created':
      return LucideIcons.folderPlus;
    case 'invite_redeemed':
      return LucideIcons.link;
    case 'project_matched':
      return LucideIcons.userCheck;
    case 'project_activated':
      return LucideIcons.zap;
    case 'project_closing':
      return LucideIcons.doorOpen;
    case 'project_closed':
      return LucideIcons.checkCheck;
    case 'project_rejected':
      return LucideIcons.xCircle;
    case 'phase_started':
      return LucideIcons.play;
    case 'phase_evidence_uploaded':
      return LucideIcons.upload;
    case 'phase_under_review':
      return LucideIcons.searchCheck;
    case 'phase_validated':
      return LucideIcons.checkCircle2;
    case 'phase_rejected':
      return LucideIcons.xCircle;
    case 'contract_created':
      return LucideIcons.fileText;
    case 'worker_invited':
      return LucideIcons.mail;
    case 'worker_assigned':
      return LucideIcons.userPlus;
    case 'contract_signed':
      return LucideIcons.filePen;
    case 'escrow_held':
      return LucideIcons.lock;
    case 'payment_transferred':
      return LucideIcons.banknote;
    case 'escrow_released':
      return LucideIcons.unlock;
    case 'payment_failed':
      return LucideIcons.circleAlert;
    case 'worker_rated':
      return LucideIcons.star;
    default:
      return LucideIcons.bell;
  }
}

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  String _formatTime(BuildContext context, String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final locale = Localizations.localeOf(context).toString();
      return DateFormat.yMd(locale).add_Hm().format(dt);
    } catch (_) {
      return iso;
    }
  }

  void _openFromNotification(
    BuildContext context,
    WidgetRef ref,
    NotificationItem n,
  ) {
    final id = n.entityId;
    if (id == null || id.isEmpty) return;

    final router = GoRouter.of(context);
    switch (n.entityType) {
      case 'project':
        goThenPushDetail(
          router,
          basePath: '/home',
          detailPath: '/jobs/$id',
        );
        break;
      case 'phase':
        goThenPushDetail(
          router,
          basePath: '/execution',
          detailPath: '/execution/$id',
        );
        break;
      case 'contract':
      case 'escrow':
        context.go('/payments');
        break;
      default:
        break;
    }
    if (n.isUnread) {
      markNotificationRead(ref, n.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final async = ref.watch(notificationsListProvider);

    return Scaffold(
      appBar: OxAppBar(
        title: l.notificationsTitle,
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.textPrimary),
            onPressed: () async {
              await markAllNotificationsRead(ref);
            },
            child: Text(
              l.notificationsMarkAllRead,
              style: const TextStyle(fontFamily: 'Inter'),
            ),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l.notificationsLoadErrorWithDetail(e.toString()),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.bellOff,
                      size: 48, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text(
                    l.notificationsEmpty,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notificationsListProvider);
              ref.invalidate(unreadNotificationsCountProvider);
              await ref.read(notificationsListProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final n = items[index];
                final title = _resolveTitle(l, n);
                final body = _resolveBody(l, n);
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/logo.webp',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        body,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontFamily: 'Inter',
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatTime(context, n.createdAt),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _notificationIcon(n.type),
                        color: AppColors.textSecondary,
                        size: 22,
                      ),
                      if (n.isUnread) ...[
                        const SizedBox(width: 10),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: _kUnreadDotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  onTap: () => _openFromNotification(context, ref, n),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
