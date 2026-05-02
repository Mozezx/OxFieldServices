import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ox_app_bar.dart';
import '../../core/widgets/ox_button.dart';
import '../auth/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: OxAppBar(
        title: 'Meu Perfil',
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.logOut, size: 20),
            color: AppColors.error,
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text('Sair',
                      style: TextStyle(color: AppColors.textPrimary)),
                  content: const Text(
                    'Tem certeza que deseja sair?',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child:
                          const Text('Sair', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                ref.read(authControllerProvider.notifier).signOut();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                child: const Icon(LucideIcons.user,
                    size: 40, color: AppColors.accent),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                user?.email ?? '',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const SizedBox(height: 32),
            _ProfileTile(
              icon: LucideIcons.creditCard,
              label: 'Métodos de pagamento',
              subtitle: 'Cartões salvos para pagamentos rápidos',
              onTap: () => context.push('/payment-methods'),
            ),
            const SizedBox(height: 32),
            OxButton(
              label: 'Sair da conta',
              variant: OxButtonVariant.secondary,
              isLoading: authState is AsyncLoading,
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).signOut(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight,
                size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
