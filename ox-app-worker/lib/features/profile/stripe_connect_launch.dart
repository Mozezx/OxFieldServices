import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'stripe_connect_provider.dart';

/// Abre a URL de onboarding do Stripe (in-app browser com fallback).
Future<void> launchStripeConnectUrl(BuildContext context, String? url) async {
  if (url == null || url.isEmpty) return;
  final t = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);
  final uri = Uri.parse(url);

  try {
    var launched = await launchUrl(
      uri,
      mode: LaunchMode.inAppBrowserView,
      browserConfiguration: const BrowserConfiguration(showTitle: true),
    );
    if (!launched) {
      launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
    if (!launched && context.mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(t.bankOnboardingError),
          backgroundColor: AppColors.error,
        ),
      );
    }
  } catch (e, st) {
    debugPrint('launchUrl in-app failed: $e\n$st');
    try {
      final ok = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!ok && context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(t.bankOnboardingError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e2, st2) {
      debugPrint('launchUrl external fallback failed: $e2\n$st2');
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(t.bankOnboardingError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

/// Mesmo fluxo do perfil: cria conta se necessário, depois abre o link de onboarding.
Future<void> launchWorkerStripeOnboarding(
  BuildContext context,
  WidgetRef ref,
  ConnectStatus status,
) async {
  final notifier = ref.read(connectActionProvider.notifier);
  final String? url = status.notStarted
      ? await notifier.openOnboarding()
      : await notifier.reopenOnboarding();
  if (!context.mounted) return;
  await launchStripeConnectUrl(context, url);
}
