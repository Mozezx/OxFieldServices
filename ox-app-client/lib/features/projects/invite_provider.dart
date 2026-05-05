import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';

class InvitePreview {
  const InvitePreview({
    required this.projectTitle,
    required this.clientName,
    required this.expiresAt,
  });

  final String projectTitle;
  final String clientName;
  final DateTime expiresAt;

  factory InvitePreview.fromJson(Map<String, dynamic> json) => InvitePreview(
        projectTitle: json['projectTitle'] as String,
        clientName: json['clientName'] as String,
        expiresAt: DateTime.parse(json['expiresAt'] as String),
      );
}

class InviteNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<InvitePreview> preview(String token) async {
    final api = ref.read(apiClientProvider);
    final res = await api.dio.get(
      ApiEndpoints.invitesPreview,
      queryParameters: {'token': token},
    );
    return InvitePreview.fromJson(res.data as Map<String, dynamic>);
  }

  Future<String> redeem(String token) async {
    state = const AsyncLoading();
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.dio.post(
        ApiEndpoints.invitesRedeem,
        data: {'token': token},
      );
      final projectId =
          (res.data as Map<String, dynamic>)['projectId'] as String;
      state = const AsyncData(null);
      return projectId;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final inviteNotifierProvider =
    AsyncNotifierProvider<InviteNotifier, void>(InviteNotifier.new);
