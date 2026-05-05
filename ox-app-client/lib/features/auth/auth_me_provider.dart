import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';

const kProfilePhotoPromptDismissedKey = 'profile_photo_prompt_dismissed_v1';

class AuthMeUser {
  const AuthMeUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.unsynced = false,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatarUrl;
  final bool unsynced;

  factory AuthMeUser.fromJson(Map<String, dynamic> json) {
    return AuthMeUser(
      id: json['id'] as String? ?? '',
      name: (json['name'] as String?)?.trim() ?? '',
      email: (json['email'] as String?)?.trim() ?? '',
      role: json['role'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      unsynced: json['_unsynced'] == true,
    );
  }
}

/// Perfil da API (`GET /auth/me`). `null` se não houver sessão Supabase.
final authMeProvider = FutureProvider<AuthMeUser?>((ref) async {
  if (Supabase.instance.client.auth.currentSession == null) {
    return null;
  }
  final api = ref.watch(apiClientProvider);
  try {
    final res = await api.dio.get<Map<String, dynamic>>(ApiEndpoints.authMe);
    final data = res.data;
    if (data == null || data['id'] == null) return null;
    return AuthMeUser.fromJson(data);
  } catch (_) {
    return null;
  }
});
