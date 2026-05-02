import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/ox_app_bar.dart';
import 'notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  static String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
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

    switch (n.entityType) {
      case 'project':
        context.go('/projects/$id');
        break;
      case 'phase':
        context.go('/phases/$id');
        break;
      case 'contract':
      case 'escrow':
        context.go('/payments/$id');
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
    final async = ref.watch(notificationsListProvider);

    return Scaffold(
      appBar: OxAppBar(
        title: 'Notificações',
        actions: [
          TextButton(
            onPressed: () async {
              await markAllNotificationsRead(ref);
            },
            child: const Text(
              'Ler todas',
              style: TextStyle(
                color: AppColors.primary,
                fontFamily: 'Inter',
              ),
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
              'Erro ao carregar: $e',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.bellOff,
                      size: 48, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text(
                    'Nenhuma notificação',
                    style: TextStyle(
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
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  leading: Icon(
                    LucideIcons.bell,
                    color: n.isUnread
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  title: Text(
                    n.title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight:
                          n.isUnread ? FontWeight.w600 : FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        n.body,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontFamily: 'Inter',
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatTime(n.createdAt),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  trailing: n.isUnread
                      ? Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
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
