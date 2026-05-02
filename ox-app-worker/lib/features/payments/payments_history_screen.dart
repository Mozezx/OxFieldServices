import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ox_app_bar.dart';
import '../../core/widgets/ox_empty_state.dart';
import '../../core/widgets/ox_loading.dart';
import 'payments_provider.dart';

class PaymentsHistoryScreen extends ConsumerWidget {
  const PaymentsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentsProvider);
    final totalAsync = ref.watch(totalReceivedProvider);

    return Scaffold(
      appBar: const OxAppBar(title: 'Meus Pagamentos'),
      body: Column(
        children: [
          // Total received header
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL RECEBIDO',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                totalAsync.when(
                  loading: () => const OxShimmerBox(width: 120, height: 32),
                  error: (_, __) => const Text('—'),
                  data: (total) => Text(
                    'R\$ ${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pagamentos liberados',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),

          // Transaction list
          Expanded(
            child: paymentsAsync.when(
              loading: () => ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => const OxJobCardSkeleton(),
              ),
              error: (_, __) => const Center(
                child: Text(
                  'Erro ao carregar pagamentos',
                  style: TextStyle(
                      color: AppColors.error, fontFamily: 'Inter'),
                ),
              ),
              data: (payments) {
                if (payments.isEmpty) {
                  return const OxEmptyState(
                    icon: LucideIcons.wallet,
                    title: 'Nenhum pagamento ainda',
                    subtitle:
                        'Os pagamentos aparecerão aqui conforme suas fases forem validadas.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: payments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _PaymentCard(payment: payments[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.payment});

  final PaymentItemModel payment;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: payment.isReleased
                  ? AppColors.accent.withValues(alpha: 0.15)
                  : AppColors.warning.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              payment.isReleased
                  ? LucideIcons.checkCircle2
                  : LucideIcons.clock,
              color: payment.isReleased ? AppColors.accent : AppColors.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.projectTitle ?? 'Pagamento',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  payment.isReleased
                      ? 'Liberado${payment.paidAt != null ? ' em ${fmt.format(payment.paidAt!)}' : ''}'
                      : 'Aguardando liberacao',
                  style: TextStyle(
                    color: payment.isReleased
                        ? AppColors.textSecondary
                        : AppColors.warning,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+ R\$ ${payment.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: payment.isReleased ? AppColors.accent : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
