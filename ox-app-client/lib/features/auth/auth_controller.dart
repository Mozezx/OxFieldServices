import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';

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
        final res = await api.dio.get(ApiEndpoints.authMe);
        final role = res.data['role'] as String?;
        if (role != null && role != 'client') {
          await _supabase.auth.signOut();
          throw Exception('Esta conta é de um prestador de serviços. Use o app OX Worker.');
        }
      } catch (e) {
        if (e is Exception && e.toString().contains('prestador')) rethrow;
        // Ignora falhas de rede — não bloqueia login por indisponibilidade do backend
      }
    });
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final res = await _supabase.auth.signUp(email: email, password: password);
      if (res.user == null) throw Exception('Falha ao criar conta');

      final api = ref.read(apiClientProvider);
      await api.dio.post(ApiEndpoints.authSync, data: {'name': name, 'role': role});
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _supabase.auth.signOut();
    });
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
