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
  });

  final String id;
  final String title;
  final String status;
  final double budget;
  final String location;
  final DateTime? deadline;
  final List<ProjectPhaseModel> phases;
  final String? workerName;

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
      );

  int get validatedPhases => phases.where((p) => p.status == 'validated').length;
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
  final data = res.data as List<dynamic>;
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
}

final projectsNotifierProvider =
    AsyncNotifierProvider<ProjectsNotifier, void>(ProjectsNotifier.new);
