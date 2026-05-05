import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ox_app_bar.dart';
import '../../core/widgets/ox_badge.dart';
import '../../core/widgets/ox_button.dart';
import '../../l10n/app_localizations.dart';
import 'payment_provider.dart';
import '../projects/project_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({
    super.key,
    required this.contractId,
    this.projectId,
  });

  final String contractId;
  /// Quando o utilizador veio do detalhe do projeto, invalida o cache após pagamento.
  final String? projectId;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _processing = false;
  String? _error;

  Future<void> _payNow() async {
    final l = AppLocalizations.of(context)!;
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
        ref.invalidate(projectsProvider);
        final pid = widget.projectId;
        if (pid != null) {
          ref.invalidate(projectDetailProvider(pid));
        }
        if (mounted) {
          final loc = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.paymentAlreadyPaidSnack),
              backgroundColor: AppColors.accent,
            ),
          );
        }
        return;
      }

      if (intent.clientSecret == null || intent.clientSecret!.isEmpty) {
        throw Exception(l.paymentErrorClientSecret);
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: intent.clientSecret!,
          customerId: intent.customerId,
          customerEphemeralKeySecret: intent.customerEphemeralKeySecret,
          merchantDisplayName: l.paymentMerchantDisplayName,
          style: ThemeMode.dark,
          primaryButtonLabel: l.paymentStripePrimaryButton,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // Se o webhook Stripe não chegou ao servidor, o POST re-sincroniza o PI (self-heal no backend).
      await ref
          .read(paymentNotifierProvider.notifier)
          .createOrFetchIntent(widget.contractId);

      ref.invalidate(escrowProvider(widget.contractId));
      ref.invalidate(projectsProvider);

      // Sucesso — aguarda confirmação do escrow na API
      await _pollEscrow();

      final pid = widget.projectId;
      if (pid != null) {
        ref.invalidate(projectDetailProvider(pid));
      }

      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.paymentDoneWaitingSnack),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    } on StripeException catch (e) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;
      setState(
        () => _error = e.error.localizedMessage ?? loc.paymentCancelledStripe,
      );
    } catch (e) {
      if (!mounted) return;
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
    final l = AppLocalizations.of(context)!;
    final escrowAsync = ref.watch(escrowProvider(widget.contractId));

    return Scaffold(
      appBar: OxAppBar(title: l.paymentTitle),
      body: escrowAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (e, _) => Center(
          child: Text(
            l.paymentErrorLine(e.toString()),
            style: const TextStyle(color: AppColors.error),
          ),
        ),
        data: (escrow) {
          if (escrow == null) {
            return _NotPaidView(
              l: l,
              onPay: _processing ? null : _payNow,
              processing: _processing,
              error: _error,
            );
          }
          return _PaidView(l: l, escrow: escrow);
        },
      ),
    );
  }
}

class _NotPaidView extends StatelessWidget {
  const _NotPaidView({
    required this.l,
    required this.onPay,
    required this.processing,
    this.error,
  });

  final AppLocalizations l;
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.creditCard,
                        size: 24, color: AppColors.accent),
                    const SizedBox(width: 10),
                    Text(
                      l.paymentConfirmTitle,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l.paymentConfirmBody,
                  style: const TextStyle(
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
            child: Row(
              children: [
                const Icon(LucideIcons.shieldCheck,
                    size: 18, color: AppColors.accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.paymentTestModeHint,
                    style: const TextStyle(
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
            label: processing ? l.paymentProcessing : l.paymentPayNow,
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
  const _PaidView({required this.l, required this.escrow});

  final AppLocalizations l;
  final EscrowModel escrow;

  @override
  Widget build(BuildContext context) {
    final statusLabel = escrow.status == 'released'
        ? l.paymentEscrowStatusReleased
        : escrow.status == 'held'
            ? l.paymentEscrowStatusHeld
            : l.paymentEscrowStatusRefunded;
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
          Text(
            l.paymentEscrowStatusHeading,
            style: const TextStyle(
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
                    Text(
                      l.paymentEscrowBrand,
                      style: const TextStyle(
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
                Text(
                  l.paymentTotalContractValue,
                  style: const TextStyle(
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
                Text(
                  l.paymentDistributionHeading,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 16),
                _SplitRow(
                  label: l.paymentSplitWorker,
                  amount: escrow.amount * 0.70,
                  icon: LucideIcons.hardHat,
                ),
                _SplitRow(
                  label: l.paymentSplitPlatform,
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
            child: Row(
              children: [
                const Icon(LucideIcons.shieldCheck,
                    size: 18, color: AppColors.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.paymentEscrowReleaseInfo,
                    style: const TextStyle(
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
