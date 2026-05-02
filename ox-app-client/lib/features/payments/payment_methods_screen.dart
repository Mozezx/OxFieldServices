import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ox_app_bar.dart';
import '../../core/widgets/ox_button.dart';
import '../../core/widgets/ox_empty_state.dart';
import 'payment_methods_provider.dart';

class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(paymentMethodsProvider);
    final actionState = ref.watch(paymentMethodsNotifierProvider);

    ref.listen(paymentMethodsNotifierProvider, (_, next) {
      if (next is AsyncError) {
        final err = next.error;
        final msg = err is StripeException
            ? (err.error.localizedMessage ?? 'Operação cancelada')
            : err.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
      }
    });

    return Scaffold(
      appBar: const OxAppBar(title: 'Métodos de pagamento'),
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () async => ref.invalidate(paymentMethodsProvider),
        child: cardsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
          error: (e, _) => Center(
            child: Text('Erro: $e',
                style: const TextStyle(color: AppColors.error)),
          ),
          data: (cards) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (cards.isEmpty)
                  const OxEmptyState(
                    icon: LucideIcons.creditCard,
                    title: 'Nenhum cartão salvo',
                    subtitle:
                        'Adicione um cartão para acelerar pagamentos futuros.',
                  )
                else
                  ...cards.map((c) => _CardTile(
                        card: c,
                        onSetDefault: actionState is AsyncLoading
                            ? null
                            : () => ref
                                .read(paymentMethodsNotifierProvider.notifier)
                                .setDefault(c.id),
                        onRemove: actionState is AsyncLoading
                            ? null
                            : () => _confirmRemove(context, ref, c),
                      )),
                const SizedBox(height: 24),
                OxButton(
                  label: 'Adicionar cartão',
                  icon: LucideIcons.plus,
                  isLoading: actionState is AsyncLoading,
                  onPressed: () => ref
                      .read(paymentMethodsNotifierProvider.notifier)
                      .addCard(),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.2)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.shieldCheck,
                              size: 18, color: AppColors.accent),
                          SizedBox(width: 10),
                          Text(
                            'Modo teste',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Use 4242 4242 4242 4242 (sucesso) ou 4000 0025 0000 3155 (3DS).',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmRemove(
      BuildContext context, WidgetRef ref, SavedCard card) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Remover cartão',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Tem certeza que deseja remover o cartão ${card.brand.toUpperCase()} •••• ${card.last4}?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      ref.read(paymentMethodsNotifierProvider.notifier).removeCard(card.id);
    }
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({
    required this.card,
    required this.onSetDefault,
    required this.onRemove,
  });

  final SavedCard card;
  final VoidCallback? onSetDefault;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: card.isDefault
              ? AppColors.accent.withValues(alpha: 0.4)
              : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(LucideIcons.creditCard,
                size: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${card.brand.toUpperCase()} •••• ${card.last4}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                        fontSize: 14,
                      ),
                    ),
                    if (card.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Padrão',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Validade: ${card.expMonth.toString().padLeft(2, '0')}/${card.expYear}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(LucideIcons.ellipsis,
                size: 18, color: AppColors.textSecondary),
            color: AppColors.surface2,
            onSelected: (v) {
              if (v == 'default') onSetDefault?.call();
              if (v == 'remove') onRemove?.call();
            },
            itemBuilder: (_) => [
              if (!card.isDefault)
                const PopupMenuItem(
                  value: 'default',
                  child: Text('Definir como padrão',
                      style: TextStyle(color: AppColors.textPrimary)),
                ),
              const PopupMenuItem(
                value: 'remove',
                child:
                    Text('Remover', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
