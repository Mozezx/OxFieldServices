import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/profile_avatar.dart';
import '../../features/profile/profile_provider.dart';
import '../../features/profile/stripe_connect_provider.dart';
import '../../l10n/app_localizations.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;

    final connectAsync = ref.watch(connectStatusProvider);
    final showStripeBanner = connectAsync.maybeWhen(
      data: (s) => !s.isReady,
      orElse: () => false,
    );
    final workerAsync = ref.watch(workerProfileProvider);
    final w = workerAsync.valueOrNull;
    final user = Supabase.instance.client.auth.currentUser;
    final label = (w?.name?.isNotEmpty == true
            ? w!.name
            : w?.email?.isNotEmpty == true
                ? w!.email
                : user?.email) ??
        '';

    Widget profileIcon({required bool active}) {
      return ProfileAvatar(
        radius: 12,
        imageUrl: w?.avatarUrl,
        label: label,
        emphasizeBorder: active,
      );
    }

    void goProfile() {
      navigationShell.goBranch(3);
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showStripeBanner)
            SafeArea(
              bottom: false,
              left: false,
              right: false,
              top: true,
              minimum: EdgeInsets.zero,
              child: Material(
                color: AppColors.warning.withValues(alpha: 0.14),
                child: InkWell(
                  onTap: goProfile,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.stripeConnectBannerMessage,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          t.stripeConnectBannerCta,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: navigationShell.currentIndex,
        onTap: navigationShell.goBranch,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(LucideIcons.briefcase),
            label: t.navJobs,
          ),
          BottomNavigationBarItem(
            icon: const Icon(LucideIcons.zap),
            label: t.navExecution,
          ),
          BottomNavigationBarItem(
            icon: const Icon(LucideIcons.wallet),
            label: t.navPayments,
          ),
          BottomNavigationBarItem(
            icon: profileIcon(active: false),
            activeIcon: profileIcon(active: true),
            label: t.navProfile,
          ),
        ],
      ),
    );
  }
}
