import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';

// --- Models ---

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
    this.contractSigned = false,
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
  final bool contractSigned;

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
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
        contractSigned: json['contract']?['signedAt'] != null,
      );

  int get validatedPhases => phases.where((p) => p.status == 'validated').length;

  bool get needsPayment =>
      (status == 'contract_signed' || status == 'active_escrow') &&
      contractId != null &&
      escrowStatus == null;

  bool get workerNeedsToSign =>
      contractId != null &&
      !contractSigned &&
      (status == 'contract_signed' || status == 'active_escrow');
}

class CreateProjectInput {
  const CreateProjectInput({
    required this.title,
    required this.description,
    required this.location,
    required this.budget,
    this.deadline,
    required this.phases,
  });

  final String title;
  final String description;
  final String location;
  final double budget;
  final DateTime? deadline;
  final List<Map<String, dynamic>> phases;

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'location': location,
        'budget': budget,
        if (deadline != null) 'deadline': deadline!.toIso8601String(),
        'phases': phases,
      };
}

// --- Providers ---

final projectsProvider = FutureProvider.autoDispose<List<ProjectModel>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.dio.get(ApiEndpoints.projects);
  final body = res.data as Map<String, dynamic>;
  final data = body['data'] as List<dynamic>;
  return data.map((e) => ProjectModel.fromJson(e as Map<String, dynamic>)).toList();
});

final projectDetailProvider =
    FutureProvider.autoDispose.family<ProjectModel, String>((ref, id) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.dio.get(ApiEndpoints.projectById(id));
  return ProjectModel.fromJson(res.data as Map<String, dynamic>);
});

class ProjectsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> create(CreateProjectInput input) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = ref.read(apiClientProvider);
      await api.dio.post(ApiEndpoints.projects, data: input.toJson());
      ref.invalidate(projectsProvider);
    });
  }

  Future<void> createAndSubmit(CreateProjectInput input) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = ref.read(apiClientProvider);
      final res = await api.dio.post(ApiEndpoints.projects, data: input.toJson());
      final projectId = (res.data as Map<String, dynamic>)['id'] as String;
      await api.dio.patch(
        ApiEndpoints.projectStatus(projectId),
        data: {'event': 'SUBMIT'},
      );
      ref.invalidate(projectsProvider);
    });
  }

  Future<void> submitForValidation(String projectId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = ref.read(apiClientProvider);
      await api.dio.patch(
        ApiEndpoints.projectStatus(projectId),
        data: {'event': 'SUBMIT'},
      );
      ref.invalidate(projectsProvider);
    });
  }

  Future<void> signContract(String contractId, String projectId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = ref.read(apiClientProvider);
      await api.dio.post(ApiEndpoints.contractSign(contractId));
      ref.invalidate(projectDetailProvider(projectId));
    });
  }
}

final projectsNotifierProvider =
    AsyncNotifierProvider<ProjectsNotifier, void>(ProjectsNotifier.new);
