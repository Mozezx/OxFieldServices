import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/notifications/notifications_provider.dart';
import '../../features/payments/payment_methods_provider.dart';
import '../../features/payments/payment_provider.dart';
import '../../features/phases/phase_provider.dart';
import '../../features/projects/project_provider.dart';
/// Clears cached domain data so the next user never sees the previous session.
void invalidateClientDomainCache(WidgetRef ref) {
  ref.invalidate(projectsProvider);
  ref.invalidate(projectDetailProvider);
  ref.invalidate(phaseDetailProvider);
  ref.invalidate(notificationsListProvider);
  ref.invalidate(unreadNotificationsCountProvider);
  ref.invalidate(paymentMethodsProvider);
  ref.invalidate(escrowProvider);
}

/// Targeted refresh from Realtime / broadcast (backend publishes scopes).
void applyClientRealtimeScopes(WidgetRef ref, Set<String> scopes) {
  if (scopes.contains('all')) {
    invalidateClientDomainCache(ref);
    return;
  }
  if (scopes.contains('notifications')) {
    ref.invalidate(notificationsListProvider);
    ref.invalidate(unreadNotificationsCountProvider);
  }
  if (scopes.contains('projects')) {
    ref.invalidate(projectsProvider);
    ref.invalidate(projectDetailProvider);
    ref.invalidate(phaseDetailProvider);
  }
  if (scopes.contains('payments')) {
    ref.invalidate(paymentMethodsProvider);
    ref.invalidate(escrowProvider);
  }
}

/// FCM `data.scopes` (comma-separated) — alinhado ao Realtime `invalidate`.
void applyClientRealtimeScopesFromFcm(WidgetRef ref, String? scopesCsv) {
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
  applyClientRealtimeScopes(ref, scopes);
}
