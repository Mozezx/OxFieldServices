import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ox_app_bar.dart';
import '../../core/widgets/ox_badge.dart';
import 'payment_provider.dart';

class PaymentScreen extends ConsumerWidget {
  const PaymentScreen({super.key, required this.contractId});

  final String contractId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final escrowAsync = ref.watch(escrowProvider(contractId));

    return Scaffold(
      appBar: const OxAppBar(title: 'Pagamento'),
      body: escrowAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (e, _) => Center(
          child: Text('Erro: $e', style: const TextStyle(color: AppColors.error)),
        ),
        data: (escrow) {
          if (escrow == null) {
            return const Center(
              child: Text(
                'Nenhum escrow ativo encontrado.',
                style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter'),
              ),
            );
          }

          final statusLabel = escrow.status == 'released'
              ? 'Liberado'
              : escrow.status == 'held'
                  ? 'Bloqueado'
                  : 'Reembolsado';
          final badgeStatus = escrow.status == 'released'
              ? OxBadgeStatus.active
              : escrow.status == 'held'
                  ? OxBadgeStatus.pending
                  : OxBadgeStatus.neutral;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status do Escrow',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
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
                          const Icon(LucideIcons.lock, size: 20, color: AppColors.accent),
                          const SizedBox(width: 10),
                          const Text(
                            'Escrow',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const Spacer(),
                          OxBadge(label: statusLabel, status: badgeStatus),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'â‚¬ ${escrow.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Valor total do contrato',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
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
                        'DISTRIBUIÃ‡ÃƒO',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SplitRow(
                        label: 'Trabalhador (70%)',
                        amount: escrow.amount * 0.70,
                        icon: LucideIcons.hardHat,
                      ),
                      _SplitRow(
                        label: 'Fornecedor (20%)',
                        amount: escrow.amount * 0.20,
                        icon: LucideIcons.package,
                      ),
                      _SplitRow(
                        label: 'Plataforma OX (10%)',
                        amount: escrow.amount * 0.10,
                        icon: LucideIcons.building2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(LucideIcons.shieldCheck, size: 18, color: AppColors.accent),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'O pagamento Ã© liberado automaticamente apÃ³s vocÃª aprovar cada fase do projeto.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SplitRow extends StatelessWidget {
  const _SplitRow({required this.label, required this.amount, required this.icon});
  final String label;
  final double amount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter'),
            ),
          ),
          Text(
            'â‚¬ ${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
