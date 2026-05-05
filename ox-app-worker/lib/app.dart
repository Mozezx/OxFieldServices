import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/l10n/locale_provider.dart';
import 'core/notifications/push_notifications_service.dart';
import 'core/providers/domain_cache_invalidation.dart';
import 'core/realtime/realtime_sync_listener.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_controller.dart';
import 'features/profile/profile_photo_prompt.dart';
import 'features/profile/stripe_connect_provider.dart';
import 'l10n/app_localizations.dart';

class OxWorkerApp extends ConsumerStatefulWidget {
  const OxWorkerApp({super.key});

  @override
  ConsumerState<OxWorkerApp> createState() => _OxWorkerAppState();
}

class _OxWorkerAppState extends ConsumerState<OxWorkerApp>
    with WidgetsBindingObserver {
  late final StreamSubscription<AuthState> _authSub;
  StreamSubscription<Uri>? _stripeConnectDeepLinkSub;

  static const _stripeConnectScheme = 'io.oxapp.worker';
  static const _stripeConnectHost = 'connect-return';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _stripeConnectDeepLinkSub =
        AppLinks().uriLinkStream.listen(_onStripeConnectDeepLink);
    AppLinks().getInitialLink().then((uri) {
      if (uri != null) _onStripeConnectDeepLink(uri);
    });

    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedOut) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) invalidateWorkerDomainCache(ref);
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
          ref
              .read(authControllerProvider.notifier)
              .syncOAuthProfile(session.user)
              .ignore();
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = ref.read(routerProvider);
      final locale = ref.read(localeProvider);
      final l10n = lookupAppLocalizations(locale);
      PushNotificationsService(ref).initialize(
        router: router,
        channelName: l10n.pushChannelName,
        channelDescription: l10n.pushChannelDescription,
      );
    });
  }

  void _onStripeConnectDeepLink(Uri uri) {
    if (uri.scheme != _stripeConnectScheme || uri.host != _stripeConnectHost) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.invalidate(connectStatusProvider);
      ref.read(routerProvider).go('/profile');
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stripeConnectDeepLinkSub?.cancel();
    _authSub.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed &&
        mounted &&
        Supabase.instance.client.auth.currentSession != null) {
      invalidateWorkerDomainCache(ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return RealtimeSyncListener(
      child: ProfilePhotoGate(
        child: MaterialApp.router(
        title: lookupAppLocalizations(locale).appTitle,
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
    );
  }
}
