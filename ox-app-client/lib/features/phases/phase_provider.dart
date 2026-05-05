import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';

class EvidenceModel {
  const EvidenceModel({required this.id, required this.url, required this.type});
  final String id;
  final String url;
  final String type;

  factory EvidenceModel.fromJson(Map<String, dynamic> json) => EvidenceModel(
        id: json['id'] as String,
        url: json['url'] as String,
        type: json['type'] as String? ?? 'photo',
      );
}

class PhaseModel {
  const PhaseModel({
    required this.id,
    required this.name,
    required this.status,
    required this.order,
    required this.amount,
    this.evidences = const [],
  });

  final String id;
  final String name;
  final String status;
  final int order;
  final double amount;
  final List<EvidenceModel> evidences;

  factory PhaseModel.fromJson(Map<String, dynamic> json) => PhaseModel(
        id: json['id'] as String,
        name: json['name'] as String,
        status: json['status'] as String,
        order: json['order'] as int,
        amount: double.tryParse(json['amount'].toString()) ?? 0.0,
        evidences: (json['evidences'] as List<dynamic>? ?? [])
            .map((e) => EvidenceModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

final phaseDetailProvider =
    FutureProvider.family<PhaseModel, String>((ref, phaseId) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.dio.get(ApiEndpoints.phaseById(phaseId));
  return PhaseModel.fromJson(res.data as Map<String, dynamic>);
});

class PhaseValidationNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> validate(String phaseId, bool approved) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = ref.read(apiClientProvider);
      await api.dio.post(
        ApiEndpoints.phaseValidate(phaseId),
        data: {'approved': approved},
      );
      ref.invalidate(phaseDetailProvider(phaseId));
    });
  }
}

final phaseValidationProvider =
    AsyncNotifierProvider<PhaseValidationNotifier, void>(PhaseValidationNotifier.new);
