import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/l10n/preferred_locale_sync.dart';
import '../../core/notifications/push_notifications_service.dart';
import 'auth_me_provider.dart';

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  SupabaseClient get _supabase => Supabase.instance.client;

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _supabase.auth.signInWithPassword(email: email, password: password);

      final api = ref.read(apiClientProvider);
      try {
        var res = await api.dio.get(ApiEndpoints.authMe);
        if (res.data['id'] == null) {
          final u = _supabase.auth.currentUser;
          final name = (u?.userMetadata?['full_name'] as String?) ??
              (u?.userMetadata?['name'] as String?) ??
              email;
          await api.dio.post(ApiEndpoints.authSync, data: {'name': name, 'role': 'client'});
          await syncFcmTokenAfterAuthSync(api.dio);
          res = await api.dio.get(ApiEndpoints.authMe);
        }
        final role = res.data['role'] as String?;
        if (role != null && role != 'client') {
          await _supabase.auth.signOut();
          throw Exception('Esta conta é de um prestador de serviços. Use o app OX Worker.');
        }
        await patchPreferredLocale(
          api.dio,
          ref.read(localeProvider).languageCode,
        );
        ref.invalidate(authMeProvider);
      } catch (e) {
        if (e is Exception && e.toString().contains('prestador')) rethrow;
      }
    });
  }

  Future<void> loginWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.oxapp.client://login-callback/',
      );
    });
    // signInWithOAuth abre o browser e retorna imediatamente.
    // A sessão é estabelecida via deep link — reset para não-loading.
    state = const AsyncData(null);
  }

  Future<void> loginWithFacebook() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: 'io.oxapp.client://login-callback/',
      );
    });
    state = const AsyncData(null);
  }

  Future<void> syncOAuthProfile(User user) async {
    final api = ref.read(apiClientProvider);
    try {
      final res = await api.dio.get(ApiEndpoints.authMe);
      final role = res.data['role'] as String?;
      if (role != null && role != 'client') {
        await _supabase.auth.signOut();
        state = AsyncError(
          Exception('Esta conta é de um prestador de serviços. Use o app OX Worker.'),
          StackTrace.current,
        );
        return;
      }
      await patchPreferredLocale(
        api.dio,
        ref.read(localeProvider).languageCode,
      );
      ref.invalidate(authMeProvider);
    } catch (_) {
      // Novo usuário OAuth — cria perfil com role client
      final name = (user.userMetadata?['full_name'] as String?) ??
          (user.userMetadata?['name'] as String?) ??
          user.email ??
          'Usuário';
      await api.dio.post(ApiEndpoints.authSync, data: {'name': name, 'role': 'client'});
      await syncFcmTokenAfterAuthSync(api.dio);
      await patchPreferredLocale(
        api.dio,
        ref.read(localeProvider).languageCode,
      );
      ref.invalidate(authMeProvider);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );
      if (res.user == null) throw Exception('Falha ao criar conta');

      final api = ref.read(apiClientProvider);
      await api.dio.post(ApiEndpoints.authSync, data: {'name': name, 'role': role});
      await syncFcmTokenAfterAuthSync(api.dio);
      await patchPreferredLocale(
        api.dio,
        ref.read(localeProvider).languageCode,
      );
      ref.invalidate(authMeProvider);
    });
  }

  Future<void> sendPasswordReset(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.oxapp.client://reset-callback/',
      );
    });
  }

  Future<void> updatePassword(String newPassword) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _supabase.auth.signOut();
      ref.invalidate(authMeProvider);
    });
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
