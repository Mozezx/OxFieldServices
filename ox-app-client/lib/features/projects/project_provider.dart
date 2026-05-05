import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';

// --- Models ---

class ClientRating {
  const ClientRating({required this.score, this.feedback});

  final int score;
  final String? feedback;

  factory ClientRating.fromJson(Map<String, dynamic> json) => ClientRating(
        score: (json['score'] as num).toInt(),
        feedback: json['feedback'] as String?,
      );
}

class ProjectPhaseModel {
  const ProjectPhaseModel({
    required this.id,
    required this.name,
    required this.status,
    required this.order,
    required this.amount,
  });

  final String id;
  final String name;
  final String status;
  final int order;
  final double amount;

  factory ProjectPhaseModel.fromJson(Map<String, dynamic> json) => ProjectPhaseModel(
        id: json['id'] as String,
        name: json['name'] as String,
        status: json['status'] as String,
        order: json['order'] as int,
        amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      );
}

class ProjectModel {
  const ProjectModel({
    required this.id,
    required this.title,
    required this.status,
    required this.budget,
    required this.location,
    this.deadline,
    this.phases = const [],
    this.workerName,
    this.contractId,
    this.escrowStatus,
    this.myRating,
  });

  final String id;
  final String title;
  final String status;
  final double budget;
  final String location;
  final DateTime? deadline;
  final List<ProjectPhaseModel> phases;
  final String? workerName;
  final String? contractId;
  final String? escrowStatus;
  final ClientRating? myRating;

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final myRaw = json['myRating'];
    return ProjectModel(
      id: json['id'] as String,
      title: json['title'] as String,
      status: json['status'] as String,
      budget: double.tryParse(json['budget'].toString()) ?? 0.0,
      location: json['location'] as String? ?? '',
      deadline: json['deadline'] != null ? DateTime.tryParse(json['deadline']) : null,
      phases: (json['phases'] as List<dynamic>? ?? [])
          .map((p) => ProjectPhaseModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      workerName: json['contract']?['worker']?['user']?['name'] as String?,
      contractId: json['contract']?['id'] as String?,
      escrowStatus: json['contract']?['escrow']?['status'] as String?,
      myRating: myRaw is Map<String, dynamic> ? ClientRating.fromJson(myRaw) : null,
    );
  }

  int get validatedPhases => phases.where((p) => p.status == 'validated').length;

  /// Avaliação só após encerramento; backend também valida.
  bool get canRateWorker =>
      workerName != null && status == 'closed' && myRating == null;

  bool get needsPayment =>
      (status == 'contract_signed' || status == 'active_escrow') &&
      contractId != null &&
      escrowStatus == null;
}

/// Backend retorna `{ data: [...], total, skip, take }`; trata `data` ausente como lista vazia.
List<dynamic> _extractProjectsList(dynamic body) {
  if (body is List) return body;
  if (body is Map<String, dynamic>) {
    final data = body['data'];
    if (data is List) return data;
  }
  return const [];
}

// --- Providers ---

final projectsProvider = FutureProvider<List<ProjectModel>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.dio.get(ApiEndpoints.projects);
  final list = _extractProjectsList(res.data);
  return list
      .whereType<Map<String, dynamic>>()
      .map(ProjectModel.fromJson)
      .toList();
});

final projectDetailProvider =
    FutureProvider.family<ProjectModel, String>((ref, id) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.dio.get(ApiEndpoints.projectById(id));
  return ProjectModel.fromJson(res.data as Map<String, dynamic>);
});

String? dioErrorUserMessage(Object e) {
  if (e is! DioException) return null;
  final data = e.response?.data;
  if (data is Map) {
    final m = data['message'];
    if (m is String) return m;
    if (m is List) return m.map((x) => x.toString()).join(' ');
  }
  return null;
}

Future<void> submitProjectRating(
  WidgetRef ref, {
  required String projectId,
  required int score,
  String? feedback,
}) async {
  final api = ref.read(apiClientProvider);
  final trimmed = feedback?.trim();
  await api.dio.post(
    ApiEndpoints.projectRating(projectId),
    data: {
      'score': score,
      if (trimmed != null && trimmed.isNotEmpty) 'feedback': trimmed,
    },
  );
  ref.invalidate(projectDetailProvider(projectId));
  ref.invalidate(projectsProvider);
}
