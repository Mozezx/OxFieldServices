import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/token_storage.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/reset_password_screen.dart';
import '../../features/jobs/jobs_dashboard_screen.dart';
import '../../features/jobs/job_detail_screen.dart';
import '../../features/execution/execution_dashboard_screen.dart';
import '../../features/execution/phase_execution_screen.dart';
import '../../features/execution/upload_evidence_screen.dart';
import '../../features/payments/payments_history_screen.dart';
import '../../features/profile/worker_profile_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import 'main_shell.dart';

final _publicRoutes = {'/splash', '/onboarding', '/login', '/forgot-password', '/reset-password'};

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      final isAuth = Supabase.instance.client.auth.currentSession != null;
      final location = state.matchedLocation;

      if (location == '/splash') return null;

      if (!isAuth && !_publicRoutes.contains(location)) {
        final onboarded = await TokenStorage.isOnboarded();
        return onboarded ? '/login' : '/onboarding';
      }

      if (isAuth && (location == '/login' || location == '/onboarding')) {
        return '/home';
      }

      return null;
    },
    refreshListenable: GoRouterRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange,
    ),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const JobsDashboardScreen(),
          ),
          GoRoute(
            path: '/jobs/:id',
            builder: (context, state) =>
                JobDetailScreen(projectId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/execution',
            builder: (context, state) => const ExecutionDashboardScreen(),
          ),
          GoRoute(
            path: '/execution/:phaseId',
            builder: (context, state) =>
                PhaseExecutionScreen(phaseId: state.pathParameters['phaseId']),
          ),
          GoRoute(
            path: '/execution/:phaseId/upload',
            builder: (context, state) =>
                UploadEvidenceScreen(phaseId: state.pathParameters['phaseId']!),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/payments',
            builder: (context, state) => const PaymentsHistoryScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const WorkerProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.listen((_) => notifyListeners());
  }

  late final dynamic _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
