import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ox_app_bar.dart';
import '../../core/widgets/ox_badge.dart';
import '../../core/widgets/ox_button.dart';
import 'payment_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, required this.contractId});

  final String contractId;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _processing = false;
  String? _error;

  Future<void> _payNow() async {
    setState(() {
      _processing = true;
      _error = null;
    });

    try {
      final intent = await ref
          .read(paymentNotifierProvider.notifier)
          .createOrFetchIntent(widget.contractId);

      if (intent.alreadyPaid) {
        ref.invalidate(escrowProvider(widget.contractId));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pagamento já foi efetuado para este contrato.'),
              backgroundColor: AppColors.accent,
            ),
          );
        }
        return;
      }

      if (intent.clientSecret == null || intent.clientSecret!.isEmpty) {
        throw Exception('Erro: clientSecret não retornado pelo backend');
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: intent.clientSecret!,
          customerId: intent.customerId,
          customerEphemeralKeySecret: intent.customerEphemeralKeySecret,
          merchantDisplayName: 'OX Field Services',
          style: ThemeMode.dark,
          primaryButtonLabel: 'Pagar',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // Sucesso — aguarda o webhook ativar o escrow no backend
      await _pollEscrow();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pagamento realizado! Aguardando confirmação...'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    } on StripeException catch (e) {
      setState(() => _error = e.error.localizedMessage ?? 'Pagamento cancelado');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _pollEscrow() async {
    // Aguarda até 15s pelo webhook que ativa o EscrowTxn
    for (var i = 0; i < 15; i++) {
      await Future.delayed(const Duration(seconds: 1));
      ref.invalidate(escrowProvider(widget.contractId));
      final escrow =
          await ref.read(escrowProvider(widget.contractId).future);
      if (escrow != null && escrow.status == 'held') return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final escrowAsync = ref.watch(escrowProvider(widget.contractId));

    return Scaffold(
      appBar: const OxAppBar(title: 'Pagamento'),
      body: escrowAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (e, _) => Center(
          child: Text('Erro: $e',
              style: const TextStyle(color: AppColors.error)),
        ),
        data: (escrow) {
          if (escrow == null) {
            return _NotPaidView(
              onPay: _processing ? null : _payNow,
              processing: _processing,
              error: _error,
            );
          }
          return _PaidView(escrow: escrow);
        },
      ),
    );
  }
}

class _NotPaidView extends StatelessWidget {
  const _NotPaidView({
    required this.onPay,
    required this.processing,
    this.error,
  });

  final VoidCallback? onPay;
  final bool processing;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.creditCard,
                        size: 24, color: AppColors.accent),
                    SizedBox(width: 10),
                    Text(
                      'Confirmar pagamento',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'O valor ficará bloqueado em escrow seguro. Será liberado para o trabalhador apenas após você validar cada fase do projeto.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Icon(LucideIcons.shieldCheck,
                    size: 18, color: AppColors.accent),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Modo teste: use o cartão 4242 4242 4242 4242, qualquer data futura, qualquer CVC.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.circleAlert,
                      size: 18, color: AppColors.error),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      error!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),
          OxButton(
            label: processing ? 'Processando...' : 'Pagar agora',
            icon: LucideIcons.lock,
            isLoading: processing,
            onPressed: onPay,
          ),
        ],
      ),
    );
  }
}

class _PaidView extends StatelessWidget {
  const _PaidView({required this.escrow});
  final EscrowModel escrow;

  @override
  Widget build(BuildContext context) {
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
                    const Icon(LucideIcons.lock,
                        size: 20, color: AppColors.accent),
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
                  '€ ${escrow.amount.toStringAsFixed(2)}',
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
                  'DISTRIBUIÇÃO',
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
                  label: 'Plataforma OX (30%)',
                  amount: escrow.amount * 0.30,
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
                Icon(LucideIcons.shieldCheck,
                    size: 18, color: AppColors.accent),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'O pagamento é liberado automaticamente após você aprovar cada fase do projeto.',
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
              style: const TextStyle(
                  color: AppColors.textSecondary, fontFamily: 'Inter'),
            ),
          ),
          Text(
            '€ ${amount.toStringAsFixed(2)}',
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
