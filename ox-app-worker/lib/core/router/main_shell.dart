import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../features/notifications/notifications_provider.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _indexFromLocation(location);
    final unreadAsync = ref.watch(unreadNotificationsCountProvider);
    final unread = unreadAsync.maybeWhen(data: (c) => c, orElse: () => 0);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: index < 0 ? 0 : index,
        onTap: (i) => _onTabTap(context, i),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(LucideIcons.briefcase),
            label: 'Jobs',
          ),
          const BottomNavigationBarItem(
            icon: Icon(LucideIcons.zap),
            label: 'Em Execução',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text(unread > 99 ? '99+' : '$unread'),
              child: const Icon(LucideIcons.bell),
            ),
            label: 'Notificações',
          ),
          const BottomNavigationBarItem(
            icon: Icon(LucideIcons.wallet),
            label: 'Pagamentos',
          ),
          const BottomNavigationBarItem(
            icon: Icon(LucideIcons.user),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  int _indexFromLocation(String location) {
    if (location.startsWith('/home') || location.startsWith('/jobs')) return 0;
    if (location.startsWith('/execution')) return 1;
    if (location.startsWith('/notifications')) return 2;
    if (location.startsWith('/payments')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onTabTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/execution');
        break;
      case 2:
        context.go('/notifications');
        break;
      case 3:
        context.go('/payments');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}
