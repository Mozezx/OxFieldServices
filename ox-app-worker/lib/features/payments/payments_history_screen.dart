import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ox_app_bar.dart';
import '../../core/widgets/ox_button.dart';
import '../../core/widgets/ox_empty_state.dart';
import '../../core/widgets/ox_loading.dart';
import '../../l10n/app_localizations.dart';
import '../profile/stripe_connect_launch.dart';
import '../profile/stripe_connect_provider.dart';
import 'payments_provider.dart';

class PaymentsHistoryScreen extends ConsumerStatefulWidget {
  const PaymentsHistoryScreen({super.key});

  @override
  ConsumerState<PaymentsHistoryScreen> createState() =>
      _PaymentsHistoryScreenState();
}

class _PaymentsHistoryScreenState extends ConsumerState<PaymentsHistoryScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(connectStatusProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final paymentsAsync = ref.watch(paymentsProvider);
    final totalAsync = ref.watch(totalReceivedProvider);
    final connectAsync = ref.watch(connectStatusProvider);
    final actionState = ref.watch(connectActionProvider);
    final connectActionLoading = actionState is AsyncLoading;

    return Scaffold(
      appBar: OxAppBar(title: t.paymentsTitle),
      body: Column(
        children: [
          connectAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (status) {
              if (status.isReady) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        t.paymentsConnectSetupMessage,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          height: 1.35,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 12),
                      OxButton(
                        label: status.notStarted
                            ? t.bankConfigureButton
                            : t.bankResolveButton,
                        icon: LucideIcons.externalLink,
                        isLoading: connectActionLoading,
                        onPressed: () async {
                          if (!context.mounted) return;
                          await launchWorkerStripeOnboarding(
                            context,
                            ref,
                            status,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
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
                Text(
                  t.paymentsTotalReceived,
                  style: const TextStyle(
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
                Text(
                  t.paymentsReleasedLabel,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: paymentsAsync.when(
              loading: () => ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => const OxJobCardSkeleton(),
              ),
              error: (_, __) => Center(
                child: Text(
                  t.paymentsLoadError,
                  style: const TextStyle(
                      color: AppColors.error, fontFamily: 'Inter'),
                ),
              ),
              data: (payments) {
                if (payments.isEmpty) {
                  return OxEmptyState(
                    icon: LucideIcons.wallet,
                    title: t.paymentsEmpty,
                    subtitle: t.paymentsEmptySubtitle,
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
    final t = AppLocalizations.of(context)!;
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
                  payment.projectTitle ?? t.paymentDefaultTitle,
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
                      ? (payment.paidAt != null
                          ? t.paymentStatusReleasedOn(fmt.format(payment.paidAt!))
                          : t.paymentStatusReleased)
                      : t.paymentStatusPending,
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
