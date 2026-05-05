import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/token_storage.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/reset_password_screen.dart';
import '../../features/projects/projects_list_screen.dart';
import '../../features/projects/project_detail_screen.dart';
import '../../features/projects/redeem_invite_screen.dart';
import '../../features/phases/phase_detail_screen.dart';
import '../../features/phases/validate_phase_screen.dart';
import '../../features/payments/payment_screen.dart';
import '../../features/payments/payment_methods_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/profile/profile_screen.dart';
import 'main_shell.dart';

final _publicRoutes = {'/splash', '/onboarding', '/login', '/register', '/forgot-password', '/reset-password'};

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

      if (isAuth && (location == '/login' || location == '/register')) {
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
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              ShellRoute(
                builder: (context, state, child) => child,
                routes: [
                  GoRoute(
                    path: '/home',
                    builder: (context, state) => const ProjectsListScreen(),
                  ),
                  GoRoute(
                    path: '/redeem',
                    builder: (context, state) {
                      final token = state.uri.queryParameters['token'];
                      return RedeemInviteScreen(initialToken: token);
                    },
                  ),
                  GoRoute(
                    path: '/projects/:id',
                    builder: (context, state) =>
                        ProjectDetailScreen(projectId: state.pathParameters['id']!),
                  ),
                  GoRoute(
                    path: '/phases/:id',
                    builder: (context, state) =>
                        PhaseDetailScreen(phaseId: state.pathParameters['id']!),
                  ),
                  GoRoute(
                    path: '/phases/:id/validate',
                    builder: (context, state) =>
                        ValidatePhaseScreen(phaseId: state.pathParameters['id']!),
                  ),
                  GoRoute(
                    path: '/payments/:id',
                    builder: (context, state) => PaymentScreen(
                      contractId: state.pathParameters['id']!,
                      projectId: state.uri.queryParameters['projectId'],
                    ),
                  ),
                  GoRoute(
                    path: '/payment-methods',
                    builder: (context, state) => const PaymentMethodsScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications',
                builder: (context, state) => const NotificationsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
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
