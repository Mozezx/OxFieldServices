import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/execution/execution_provider.dart';
import '../../features/jobs/jobs_provider.dart';
import '../../features/notifications/notifications_provider.dart';
import '../../features/payments/payments_provider.dart';
import '../../features/profile/profile_provider.dart';
import '../../features/profile/stripe_connect_provider.dart';
/// Clears cached domain data so the next user never sees the previous session.
void invalidateWorkerDomainCache(WidgetRef ref) {
  ref.invalidate(availableJobsProvider);
  ref.invalidate(activeJobsProvider);
  ref.invalidate(jobDetailProvider);
  ref.invalidate(phaseExecutionProvider);
  ref.invalidate(activePhasesProvider);
  ref.invalidate(notificationsListProvider);
  ref.invalidate(unreadNotificationsCountProvider);
  ref.invalidate(paymentsProvider);
  ref.invalidate(totalReceivedProvider);
  ref.invalidate(connectStatusProvider);
  ref.invalidate(workerProfileProvider);
  ref.invalidate(predefinedSkillsProvider);
}

/// Targeted refresh from Realtime / broadcast (backend publishes scopes).
void applyWorkerRealtimeScopes(WidgetRef ref, Set<String> scopes) {
  if (scopes.contains('all')) {
    invalidateWorkerDomainCache(ref);
    return;
  }
  if (scopes.contains('notifications')) {
    ref.invalidate(notificationsListProvider);
    ref.invalidate(unreadNotificationsCountProvider);
  }
  if (scopes.contains('jobs')) {
    ref.invalidate(availableJobsProvider);
    ref.invalidate(activeJobsProvider);
    ref.invalidate(jobDetailProvider);
  }
  if (scopes.contains('execution')) {
    ref.invalidate(phaseExecutionProvider);
    ref.invalidate(activePhasesProvider);
  }
  if (scopes.contains('payments')) {
    ref.invalidate(paymentsProvider);
    ref.invalidate(totalReceivedProvider);
    ref.invalidate(connectStatusProvider);
  }
  if (scopes.contains('profile')) {
    ref.invalidate(workerProfileProvider);
    ref.invalidate(predefinedSkillsProvider);
  }
}

/// FCM `data.scopes` (comma-separated) — alinhado ao Realtime `invalidate`.
void applyWorkerRealtimeScopesFromFcm(WidgetRef ref, String? scopesCsv) {
  if (scopesCsv == null || scopesCsv.isEmpty) {
    ref.invalidate(notificationsListProvider);
    ref.invalidate(unreadNotificationsCountProvider);
    return;
  }
  final scopes = scopesCsv
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toSet();
  applyWorkerRealtimeScopes(ref, scopes);
}
