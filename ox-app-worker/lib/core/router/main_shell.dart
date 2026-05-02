import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _indexFromLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index < 0 ? 0 : index,
        onTap: (i) => _onTabTap(context, i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.briefcase),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.zap),
            label: 'Em Execução',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.wallet),
            label: 'Pagamentos',
          ),
          BottomNavigationBarItem(
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
    if (location.startsWith('/payments')) return 2;
    if (location.startsWith('/profile')) return 3;
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
        context.go('/payments');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }
}
