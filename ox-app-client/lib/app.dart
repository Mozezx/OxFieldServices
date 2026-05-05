import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/l10n/locale_provider.dart';
import 'core/l10n/preferred_locale_session_hook.dart';
import 'core/notifications/push_notifications_service.dart';
import 'core/providers/domain_cache_invalidation.dart';
import 'core/realtime/realtime_sync_listener.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_controller.dart';
import 'features/profile/profile_photo_prompt.dart';
import 'l10n/app_localizations.dart';

class OxApp extends ConsumerStatefulWidget {
  const OxApp({super.key});

  @override
  ConsumerState<OxApp> createState() => _OxAppState();
}

class _OxAppState extends ConsumerState<OxApp> with WidgetsBindingObserver {
  late final StreamSubscription<AuthState> _authSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedOut) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) invalidateClientDomainCache(ref);
        });
        return;
      }

      if (event == AuthChangeEvent.passwordRecovery) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) ref.read(routerProvider).push('/reset-password');
        });
        return;
      }

      if (event == AuthChangeEvent.signedIn && session != null) {
        final provider = session.user.appMetadata['provider'] as String? ?? 'email';
        if (provider != 'email') {
          // Sync OAuth user profile in background
          ref
              .read(authControllerProvider.notifier)
              .syncOAuthProfile(session.user)
              .ignore();
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = ref.read(routerProvider);
      final l = lookupAppLocalizations(ref.read(localeProvider));
      PushNotificationsService(ref).initialize(
        router: router,
        channelName: l.pushChannelName,
        channelDescription: l.pushChannelDescription,
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSub.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed &&
        mounted &&
        Supabase.instance.client.auth.currentSession != null) {
      invalidateClientDomainCache(ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return RealtimeSyncListener(
      child: PreferredLocaleSessionSync(
        child: ProfilePhotoGate(
          child: MaterialApp.router(
            title: 'OX Services',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark,
            routerConfig: router,
            locale: locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: supportedLocales,
          ),
        ),
      ),
    );
  }
}
