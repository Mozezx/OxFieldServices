import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/notifications/push_notifications_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_controller.dart';

class OxWorkerApp extends ConsumerStatefulWidget {
  const OxWorkerApp({super.key});

  @override
  ConsumerState<OxWorkerApp> createState() => _OxWorkerAppState();
}

class _OxWorkerAppState extends ConsumerState<OxWorkerApp> {
  late final StreamSubscription<AuthState> _authSub;

  @override
  void initState() {
    super.initState();

    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

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
      PushNotificationsService(ref).initialize(router: router);
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'OX Trabalhador',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt'),
        Locale('en'),
      ],
      locale: const Locale('pt'),
    );
  }
}
