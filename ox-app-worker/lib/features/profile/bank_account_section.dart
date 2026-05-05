import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ox_button.dart';
import '../../core/widgets/ox_loading.dart';
import '../../l10n/app_localizations.dart';
import 'stripe_connect_launch.dart';
import 'stripe_connect_provider.dart';

class BankAccountSection extends ConsumerStatefulWidget {
  const BankAccountSection({super.key});

  @override
  ConsumerState<BankAccountSection> createState() =>
      _BankAccountSectionState();
}

class _BankAccountSectionState extends ConsumerState<BankAccountSection>
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
    final statusAsync = ref.watch(connectStatusProvider);
    final actionState = ref.watch(connectActionProvider);
    final isLoading = actionState is AsyncLoading;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: statusAsync.when(
        loading: () => const OxShimmerBox(
          width: double.infinity,
          height: 80,
          borderRadius: 12,
        ),
        error: (e, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(t: t),
            const SizedBox(height: 12),
            Text(
              t.bankStatusError(e.toString()),
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
            const SizedBox(height: 12),
            OxButton(
              label: t.bankRetryButton,
              variant: OxButtonVariant.secondary,
              onPressed: () => ref.invalidate(connectStatusProvider),
            ),
          ],
        ),
        data: (status) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(t: t),
            const SizedBox(height: 16),
            _StatusBadge(status: status.status, t: t),
            const SizedBox(height: 16),
            ..._buildContent(context, t, status, isLoading),
          ],
        ),
      ),
    );
  }

  List<Widget> _connectBrowserHint(AppLocalizations t) {
    return [
      Text(
        t.bankConnectBrowserHint,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontFamily: 'Inter',
        ),
      ),
      const SizedBox(height: 12),
    ];
  }

  List<Widget> _buildContent(
      BuildContext context, AppLocalizations t, ConnectStatus status, bool isLoading) {
    switch (status.status) {
      case 'not_started':
        return [
          Text(
            t.bankNotStartedDesc,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          ..._connectBrowserHint(t),
          OxButton(
            label: t.bankConfigureButton,
            icon: LucideIcons.creditCard,
            isLoading: isLoading,
            onPressed: () async {
              if (!context.mounted) return;
              await launchWorkerStripeOnboarding(context, ref, status);
            },
          ),
        ];

      case 'pending':
        return [
          Text(
            t.bankPendingDesc,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontFamily: 'Inter',
            ),
          ),
          if (status.currentlyDue.isNotEmpty) ...[
            const SizedBox(height: 12),
            ..._dedupedHumanized(t, status.currentlyDue)
                .take(12)
                .map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(LucideIcons.dot,
                            size: 14, color: AppColors.warning),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            line,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
          const SizedBox(height: 12),
          ..._connectBrowserHint(t),
          OxButton(
            label: t.bankContinueButton,
            icon: LucideIcons.externalLink,
            isLoading: isLoading,
            onPressed: () async {
              if (!context.mounted) return;
              await launchWorkerStripeOnboarding(context, ref, status);
            },
          ),
        ];

      case 'active':
        return [
          if (status.bankAccount != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.landmark,
                      size: 20, color: AppColors.accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status.bankAccount!.bankName ?? t.bankAccountDefault,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '•••• ${status.bankAccount!.last4} · ${status.bankAccount!.currency}',
                          style: const TextStyle(
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
            const SizedBox(height: 12),
          ],
          Text(
            t.bankActivePaymentInfo,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          ..._connectBrowserHint(t),
          OxButton(
            label: t.bankUpdateButton,
            variant: OxButtonVariant.secondary,
            icon: LucideIcons.settings,
            isLoading: isLoading,
            onPressed: () async {
              if (!context.mounted) return;
              await launchWorkerStripeOnboarding(context, ref, status);
            },
          ),
        ];

      case 'restricted':
      default:
        return [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _friendlyDisabledReason(t, status.disabledReason),
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                if (status.pastDue.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ..._dedupedHumanized(t, status.pastDue).take(12).map(
                        (line) => Text(
                          '• $line',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          ..._connectBrowserHint(t),
          OxButton(
            label: t.bankResolveButton,
            icon: LucideIcons.externalLink,
            isLoading: isLoading,
            onPressed: () async {
              if (!context.mounted) return;
              await launchWorkerStripeOnboarding(context, ref, status);
            },
          ),
        ];
    }
  }

  String _friendlyDisabledReason(AppLocalizations t, String? raw) {
    if (raw == null || raw.isEmpty) return t.bankRestrictedDefault;
    switch (raw) {
      case 'requirements.past_due':
        return t.bankStripeDisabledPastDue;
      case 'requirements.pending_verification':
        return t.bankStripeDisabledPendingVerification;
      case 'under_review':
        return t.bankStripeDisabledUnderReview;
      case 'listed':
      case 'rejected.listed':
        return t.bankStripeDisabledUnderReview;
      case 'rejected.fraud':
      case 'rejected.terms_of_service':
      case 'rejected.other':
        return t.bankStripeDisabledRejected;
      default:
        if (raw.startsWith('rejected.')) {
          return t.bankStripeDisabledRejected;
        }
        return t.bankRestrictedDefault;
    }
  }

  List<String> _dedupedHumanized(AppLocalizations t, List<String> keys) {
    final seen = <String>{};
    final out = <String>[];
    for (final k in keys) {
      final line = _humanizeRequirement(t, k);
      if (seen.add(line)) out.add(line);
    }
    return out;
  }

  String _humanizeRequirement(AppLocalizations t, String key) {
    final personMatch = RegExp(r'^person_[^.]+\.(.+)$').firstMatch(key.trim());
    final k = personMatch?.group(1) ?? key.trim();

    switch (k) {
      case 'individual.first_name':
      case 'individual.last_name':
      case 'first_name':
      case 'last_name':
        return t.bankReqFullName;
      case 'individual.dob.day':
      case 'individual.dob.month':
      case 'individual.dob.year':
      case 'dob.day':
      case 'dob.month':
      case 'dob.year':
        return t.bankReqBirthDate;
      case 'individual.id_number':
      case 'individual.ssn_last_4':
      case 'id_number':
      case 'ssn_last_4':
        return t.bankReqIdDocument;
      case 'individual.address.line1':
      case 'individual.address.city':
      case 'individual.address.postal_code':
      case 'individual.address.state':
      case 'address.line1':
      case 'address.city':
      case 'address.postal_code':
      case 'address.state':
        return t.bankReqAddress;
      case 'external_account':
        return t.bankReqBankData;
      case 'tos_acceptance.date':
      case 'tos_acceptance.ip':
        return t.bankReqStripeTerms;
      case 'business_profile.url':
      case 'business_profile.mcc':
      case 'business_profile.name':
        return t.bankReqProfile;
      case 'business_profile.product_description':
        return t.bankReqProductDescription;
      case 'business_type':
        return t.bankReqBusinessType;
      case 'business_profile.support_email':
      case 'business_profile.support_phone':
      case 'email':
      case 'individual.email':
      case 'individual.phone':
        return t.bankReqContactEmailPhone;
      case 'business_profile.support_url':
        return t.bankReqWebsiteOrSocial;
      case 'verification.document':
        return t.bankReqIdDocument;
      case 'verification.additional_document':
        return t.bankReqAdditionalVerification;
    }

    if (k.startsWith('company.')) {
      return t.bankReqCompanyInfo;
    }
    if (k.startsWith('representative.')) {
      if (k.contains('address')) return t.bankReqRepresentativeAddress;
      return t.bankReqRepresentativeDetails;
    }
    if (k.startsWith('business_profile.')) {
      if (k.contains('product_description')) {
        return t.bankReqProductDescription;
      }
      if (k.contains('url')) return t.bankReqWebsiteOrSocial;
      return t.bankReqProfile;
    }
    if (k.startsWith('individual.')) {
      if (k.contains('address')) return t.bankReqAddress;
      if (k.contains('dob')) return t.bankReqBirthDate;
      if (k.contains('email') || k.contains('phone')) {
        return t.bankReqContactEmailPhone;
      }
      if (k.contains('id_number') || k.contains('ssn')) {
        return t.bankReqIdDocument;
      }
      if (k.contains('first_name') || k.contains('last_name')) {
        return t.bankReqFullName;
      }
    }

    return t.bankReqFallbackStripeForm;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.t});
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(LucideIcons.landmark, size: 18, color: AppColors.accent),
        const SizedBox(width: 10),
        Text(
          t.bankSection,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.t});
  final String status;
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'active' => (t.bankStatusActive, AppColors.accent),
      'pending' => (t.bankStatusPending, AppColors.warning),
      'restricted' => (t.bankStatusRestricted, AppColors.error),
      _ => (t.bankStatusNotConfigured, AppColors.textDisabled),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
