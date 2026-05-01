import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import '../auth/token_storage.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/projects/projects_list_screen.dart';
import '../../features/projects/project_detail_screen.dart';
import '../../features/projects/create_project_screen.dart';
import '../../features/phases/phase_detail_screen.dart';
import '../../features/phases/validate_phase_screen.dart';
import '../../features/payments/payment_screen.dart';
import 'main_shell.dart';

final _publicRoutes = {'/splash', '/onboarding', '/login', '/register'};

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      final isAuth = ref.read(isAuthenticatedProvider);
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
      authState.when(
        data: (state) => Stream.value(state),
        loading: () => const Stream.empty(),
        error: (_, __) => const Stream.empty(),
      ),
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
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const ProjectsListScreen(),
          ),
          GoRoute(
            path: '/projects/new',
            builder: (context, state) => const CreateProjectScreen(),
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
            builder: (context, state) =>
                PaymentScreen(contractId: state.pathParameters['id']!),
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
