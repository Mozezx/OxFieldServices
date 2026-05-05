import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/widgets/profile_avatar.dart';
import '../../features/auth/auth_me_provider.dart';
import '../../features/notifications/notifications_provider.dart';
import '../../l10n/app_localizations.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final unreadAsync = ref.watch(unreadNotificationsCountProvider);
    final unread = unreadAsync.maybeWhen(data: (c) => c, orElse: () => 0);
    final meAsync = ref.watch(authMeProvider);
    final me = meAsync.valueOrNull;
    final label = (me?.name.isNotEmpty == true
            ? me!.name
            : me?.email.isNotEmpty == true
                ? me!.email
                : Supabase.instance.client.auth.currentUser?.email) ??
        '';

    Widget profileIcon({required bool active}) {
      return ProfileAvatar(
        radius: 12,
        imageUrl: me?.avatarUrl,
        label: label,
        emphasizeBorder: active,
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: navigationShell.goBranch,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(LucideIcons.folderOpen),
            label: l.navProjects,
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text(unread > 99 ? '99+' : '$unread'),
              child: const Icon(LucideIcons.bell),
            ),
            label: l.navNotifications,
          ),
          BottomNavigationBarItem(
            icon: profileIcon(active: false),
            activeIcon: profileIcon(active: true),
            label: l.navProfile,
          ),
        ],
      ),
    );
  }
}
