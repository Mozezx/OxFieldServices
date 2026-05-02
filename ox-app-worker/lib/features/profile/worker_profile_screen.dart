import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ox_app_bar.dart';
import '../../core/widgets/ox_button.dart';
import '../../core/widgets/ox_loading.dart';
import '../auth/auth_controller.dart';
import 'profile_provider.dart';
import 'bank_account_section.dart';

class WorkerProfileScreen extends ConsumerWidget {
  const WorkerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workerAsync = ref.watch(workerProfileProvider);

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
                builder: (dialogContext) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text(
                    'Sair',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  content: const Text(
                    'Deseja sair da sua conta?',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text(
                        'Sair',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                try {
                  // Limpa a sessão local (instantâneo, sem rede).
                  await ref.read(authControllerProvider.notifier).signOut();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao sair: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }

                // Navega explicitamente para /login (mesmo se signOut falhou,
                // pois o usuário já confirmou que quer sair).
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
          ),
        ],
      ),
      body: workerAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              OxShimmerBox(width: double.infinity, height: 120, borderRadius: 16),
              SizedBox(height: 16),
              OxShimmerBox(width: double.infinity, height: 80, borderRadius: 16),
            ],
          ),
        ),
        error: (e, _) => Center(
          child: Text('Erro: $e',
              style: const TextStyle(color: AppColors.error)),
        ),
        data: (worker) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Avatar + info
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor:
                          AppColors.accent.withValues(alpha: 0.15),
                      child: Text(
                        (worker?.name ?? worker?.email ?? 'W')
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      worker?.name ?? 'Trabalhador',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                    if (worker?.email != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        worker!.email!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontFamily: 'Inter',
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Rating stars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(5, (i) {
                          final full = (worker?.rating ?? 0).floor();
                          return Icon(
                            LucideIcons.star,
                            size: 20,
                            color: i < full
                                ? AppColors.warning
                                : AppColors.textDisabled,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          worker?.rating.toStringAsFixed(1) ?? '0.0',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Status & certifications
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'STATUS',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _StatusRow(
                      icon: LucideIcons.circle,
                      label: 'Disponibilidade',
                      value: (worker?.available ?? false)
                          ? 'Disponivel'
                          : 'Indisponivel',
                      valueColor: (worker?.available ?? false)
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                    _StatusRow(
                      icon: LucideIcons.shield,
                      label: 'Certificacao Shelter',
                      value: (worker?.shelterCertified ?? false)
                          ? 'Certificado'
                          : 'Nao certificado',
                      valueColor: (worker?.shelterCertified ?? false)
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Skills — seleção por chips predefinidos
              if (worker != null) ...[
                _SkillsSection(worker: worker),
                const SizedBox(height: 16),
              ],

              // Conta de recebimento (Stripe Connect)
              const BankAccountSection(),
              const SizedBox(height: 16),

              // Availability toggle
              OxButton(
                label: (worker?.available ?? false)
                    ? 'Marcar como Indisponivel'
                    : 'Marcar como Disponivel',
                variant: (worker?.available ?? false)
                    ? OxButtonVariant.secondary
                    : OxButtonVariant.primary,
                icon: LucideIcons.circle,
                onPressed: () => ref
                    .read(workerProfileNotifierProvider.notifier)
                    .toggleAvailability(!(worker?.available ?? false)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillsSection extends ConsumerWidget {
  const _SkillsSection({required this.worker});
  final WorkerProfileModel worker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skillsAsync = ref.watch(predefinedSkillsProvider);
    final notifierState = ref.watch(workerProfileNotifierProvider);
    final isSaving = notifierState.isLoading;

    return skillsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (predefined) {
        if (predefined.isEmpty) return const SizedBox.shrink();

        final selected = worker.skills.map((s) => s.toLowerCase()).toSet();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'HABILIDADES',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  if (isSaving)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: predefined.map((skill) {
                  final isSelected = selected.contains(skill.name.toLowerCase());
                  return GestureDetector(
                    onTap: isSaving
                        ? null
                        : () {
                            final newSelected = Set<String>.from(selected);
                            if (isSelected) {
                              newSelected.remove(skill.name.toLowerCase());
                            } else {
                              newSelected.add(skill.name.toLowerCase());
                            }
                            ref
                                .read(workerProfileNotifierProvider.notifier)
                                .updateSkills(newSelected.toList());
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent.withValues(alpha: 0.15)
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accent.withValues(alpha: 0.6)
                              : AppColors.divider,
                        ),
                      ),
                      child: Text(
                        skill.label,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (selected.isEmpty) ...[
                const SizedBox(height: 10),
                const Text(
                  'Toque nas habilidades para selecioná-las',
                  style: TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontFamily: 'Inter',
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
