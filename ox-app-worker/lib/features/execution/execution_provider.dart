import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../jobs/jobs_provider.dart';

// --- Models ---

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

class PhaseExecutionModel {
  const PhaseExecutionModel({
    required this.id,
    required this.name,
    required this.status,
    required this.order,
    required this.amount,
    required this.projectId,
    this.evidences = const [],
  });

  final String id;
  final String name;
  final String status;
  final int order;
  final double amount;
  final String projectId;
  final List<EvidenceModel> evidences;

  factory PhaseExecutionModel.fromJson(Map<String, dynamic> json) =>
      PhaseExecutionModel(
        id: json['id'] as String,
        name: json['name'] as String,
        status: json['status'] as String,
        order: json['order'] as int,
        amount: double.tryParse(json['amount'].toString()) ?? 0.0,
        projectId: json['projectId'] as String? ?? '',
        evidences: (json['evidences'] as List<dynamic>? ?? [])
            .map((e) => EvidenceModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  bool get canSubmit => evidences.length >= 3;
}

// --- Providers ---

final phaseExecutionProvider = FutureProvider.autoDispose
    .family<PhaseExecutionModel?, String?>((ref, phaseId) async {
  if (phaseId == null) return null;
  final api = ref.watch(apiClientProvider);
  final res = await api.dio.get(ApiEndpoints.phaseById(phaseId));
  return PhaseExecutionModel.fromJson(res.data as Map<String, dynamic>);
});

/// Agrupa todas as fases ativas do worker, agrupadas por job (project).
/// Considera fases nos status: pending, in_progress, evidence_uploaded,
/// under_review, rejected.
class JobPhasesGroup {
  const JobPhasesGroup({required this.job, required this.activePhases});

  final JobModel job;
  final List<JobPhaseModel> activePhases;
}

const _activePhaseStatuses = {
  'pending',
  'in_progress',
  'evidence_uploaded',
  'under_review',
  'rejected',
};

final activePhasesProvider =
    FutureProvider.autoDispose<List<JobPhasesGroup>>((ref) async {
  final jobs = await ref.watch(activeJobsProvider.future);
  final groups = <JobPhasesGroup>[];
  for (final j in jobs) {
    // Só exibe fases de projetos realmente em execução. active_escrow ainda
    // aguarda ativação pelo backend — o worker não pode iniciar fases ainda.
    if (j.status != 'in_execution') continue;
    final phases = j.phases
        .where((p) => _activePhaseStatuses.contains(p.status))
        .toList();
    if (phases.isNotEmpty) {
      groups.add(JobPhasesGroup(job: j, activePhases: phases));
    }
  }
  return groups;
});

// --- Evidence upload notifier ---

class EvidenceUploadNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Faz upload de uma evidência via multipart/form-data.
  /// Backend espera o campo 'file' com o binário.
  Future<void> uploadEvidence(
      String phaseId, String filePath, String mimeType) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = ref.read(apiClientProvider);

      final parts = mimeType.split('/');
      final mediaType = parts.length == 2
          ? MediaType(parts[0], parts[1])
          : MediaType('application', 'octet-stream');

      final fileName = filePath.split(RegExp(r'[\\/]')).last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: mediaType,
        ),
      });

      await api.dio.post(
        ApiEndpoints.phaseEvidence(phaseId),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      // Invalida caches: a fase, o dashboard de execução e os jobs ativos
      // (o status muda para evidence_uploaded automaticamente no backend).
      ref.invalidate(phaseExecutionProvider(phaseId));
      ref.invalidate(activePhasesProvider);
      ref.invalidate(activeJobsProvider);
    });
  }
}

final evidenceUploadProvider =
    AsyncNotifierProvider<EvidenceUploadNotifier, void>(
        EvidenceUploadNotifier.new);

// --- Start phase (pending → in_progress) ---

class StartPhaseNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> startPhase(String phaseId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = ref.read(apiClientProvider);
      await api.dio.patch(
        ApiEndpoints.phaseStatus(phaseId),
        data: {'status': 'in_progress'},
      );
      ref.invalidate(phaseExecutionProvider(phaseId));
      ref.invalidate(activePhasesProvider);
      ref.invalidate(activeJobsProvider);
    });
  }
}

final startPhaseProvider =
    AsyncNotifierProvider<StartPhaseNotifier, void>(StartPhaseNotifier.new);

// --- Submit phase for review (evidence_uploaded → under_review) ---

class PhaseSubmitNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submitForReview(String phaseId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = ref.read(apiClientProvider);

      // Garante que o cache da fase está atualizado antes de calcular a transição
      ref.invalidate(phaseExecutionProvider(phaseId));
      final phase =
          await ref.read(phaseExecutionProvider(phaseId).future);

      if (phase == null) {
        throw Exception('Fase não encontrada');
      }

      // Backend só aceita evidence_uploaded → under_review.
      // Se ainda estiver em in_progress (sem upload), avisa.
      if (phase.status != 'evidence_uploaded') {
        throw Exception(
          'Faça upload de pelo menos uma evidência antes de enviar para revisão.',
        );
      }

      await api.dio.patch(
        ApiEndpoints.phaseStatus(phaseId),
        data: {'status': 'under_review'},
      );

      ref.invalidate(phaseExecutionProvider(phaseId));
      ref.invalidate(activePhasesProvider);
      ref.invalidate(activeJobsProvider);
    });
  }
}

final phaseSubmitProvider =
    AsyncNotifierProvider<PhaseSubmitNotifier, void>(PhaseSubmitNotifier.new);

// --- Checklist state (local only) ---

final checklistProvider =
    StateNotifierProvider.autoDispose<ChecklistNotifier, Map<String, bool>>(
        (ref) => ChecklistNotifier());

class ChecklistNotifier extends StateNotifier<Map<String, bool>> {
  ChecklistNotifier()
      : super({
          'Materiais separados': false,
          "EPI's utilizados": false,
          'Trabalho iniciado': false,
          'Verificacao de seguranca': false,
          'Documentacao fotografica': false,
        });

  void toggle(String key) {
    state = {...state, key: !(state[key] ?? false)};
  }

  bool get allChecked => state.values.every((v) => v);
}
