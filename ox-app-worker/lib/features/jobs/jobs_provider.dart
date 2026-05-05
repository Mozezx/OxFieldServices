import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';

/// Accept job was called but the admin has not created a contract for this project yet.
class NoContractForProjectException implements Exception {
  const NoContractForProjectException();
}

// --- Models ---

class JobPhaseModel {
  const JobPhaseModel({
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

  factory JobPhaseModel.fromJson(Map<String, dynamic> json) => JobPhaseModel(
        id: json['id'] as String,
        name: json['name'] as String,
        status: json['status'] as String,
        order: json['order'] as int,
        amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      );
}

class JobModel {
  const JobModel({
    required this.id,
    required this.title,
    required this.status,
    required this.budget,
    required this.location,
    this.deadline,
    this.phases = const [],
    this.description,
    this.matchScore,
    this.contractId,
    this.contractSignedAt,
    this.escrowStatus,
  });

  final String id;
  final String title;
  final String status;
  final double budget;
  final String location;
  final DateTime? deadline;
  final List<JobPhaseModel> phases;
  final String? description;
  final int? matchScore;
  final String? contractId;
  final DateTime? contractSignedAt;
  final String? escrowStatus;

  factory JobModel.fromJson(Map<String, dynamic> json) {
    final contract = json['contract'] as Map<String, dynamic>?;
    final escrow = contract?['escrow'] as Map<String, dynamic>?;
    return JobModel(
      id: json['id'] as String,
      title: json['title'] as String,
      status: json['status'] as String,
      budget: double.tryParse(json['budget'].toString()) ?? 0.0,
      location: json['location'] as String? ?? '',
      deadline: json['deadline'] != null
          ? DateTime.tryParse(json['deadline'])
          : null,
      phases: (json['phases'] as List<dynamic>? ?? [])
          .map((p) => JobPhaseModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      description: json['description'] as String?,
      matchScore: json['matchScore'] as int?,
      contractId: contract?['id'] as String?,
      contractSignedAt: contract?['signedAt'] != null
          ? DateTime.tryParse(contract!['signedAt'].toString())
          : null,
      escrowStatus: escrow?['status'] as String?,
    );
  }

  double get totalAmount =>
      phases.fold(0.0, (sum, p) => sum + p.amount);

  int get completedPhases =>
      phases.where((p) => p.status == 'validated').length;

  /// Worker já assinou o contrato?
  bool get isSigned => contractSignedAt != null;

  /// Pode aceitar (assinar) o contrato?
  /// Inclui `active_escrow`: o cliente pode pagar antes do worker assinar; o
  /// backend então fica em escrow ativo até a assinatura disparar `in_execution`.
  bool get canAccept =>
      contractId != null &&
      !isSigned &&
      ['contract_signed', 'matched', 'active_escrow'].contains(status);

  /// Projeto em execução ativa — worker pode executar fases.
  bool get isExecuting => isSigned && status == 'in_execution';

  /// Contrato assinado + escrow confirmado, aguardando ativação do projeto.
  bool get awaitingStart => isSigned && status == 'active_escrow';

  /// Aguardando pagamento do cliente?
  bool get awaitingPayment =>
      isSigned && status == 'contract_signed' && escrowStatus == null;

  JobPhaseModel? get activePhase {
    try {
      return phases.firstWhere(
        (p) => ['in_progress', 'evidence_uploaded', 'under_review'].contains(p.status),
      );
    } catch (_) {
      return null;
    }
  }
}

// --- Helper: backend retorna { data: [...], total, skip, take } ---

List<dynamic> _extractList(dynamic body) {
  if (body is List) return body;
  if (body is Map<String, dynamic>) {
    final data = body['data'];
    if (data is List) return data;
  }
  return const [];
}

// --- Available jobs provider (for matching candidates) ---

final availableJobsProvider = FutureProvider<List<JobModel>>((ref) async {
  final api = ref.watch(apiClientProvider);
  // Busca projetos em status 'matched' sem contrato ainda (disponíveis)
  final res = await api.dio.get(
    ApiEndpoints.projects,
    queryParameters: {'status': 'matched', 'noContract': true},
  );
  return _extractList(res.data)
      .map((e) => JobModel.fromJson(e as Map<String, dynamic>))
      .toList();
});

// --- Active worker jobs ---
// Inclui contract_signed (worker pode aceitar) + active_escrow + in_execution

final activeJobsProvider = FutureProvider<List<JobModel>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.dio.get(
    ApiEndpoints.projects,
    queryParameters: {'workerJobs': true},
  );
  return _extractList(res.data)
      .map((e) => JobModel.fromJson(e as Map<String, dynamic>))
      .where((j) => ['contract_signed', 'active_escrow', 'in_execution']
          .contains(j.status))
      .toList();
});

// --- Job detail ---

final jobDetailProvider =
    FutureProvider.family<JobModel, String>((ref, id) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.dio.get(ApiEndpoints.projectById(id));
  return JobModel.fromJson(res.data as Map<String, dynamic>);
});

// --- Accept / decline job ---

class JobActionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Aceita um job: busca o contrato pré-criado pelo admin e o assina.
  /// Após assinar, se o cliente já pagou (escrow held), o backend
  /// avança automaticamente para in_execution e marca a primeira fase
  /// como in_progress.
  Future<void> acceptJob(String projectId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = ref.read(apiClientProvider);

      // Busca o contrato vinculado a este projeto (foi criado pelo admin no matching)
      final contractRes =
          await api.dio.get(ApiEndpoints.contractByProject(projectId));
      final contract = contractRes.data as Map<String, dynamic>?;
      if (contract == null || contract['id'] == null) {
        throw const NoContractForProjectException();
      }

      final contractId = contract['id'] as String;

      // Assina o contrato (idempotente: se já assinou, retorna ok)
      await api.dio.post(ApiEndpoints.contractSign(contractId));

      ref.invalidate(availableJobsProvider);
      ref.invalidate(activeJobsProvider);
      ref.invalidate(jobDetailProvider(projectId));
    });
  }

  Future<void> declineJob(String projectId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // Decline = report back to matching that worker is not interested
      // For MVP: simply marks worker as unavailable for this project
      // (no dedicated endpoint yet — placeholder)
      ref.invalidate(availableJobsProvider);
    });
  }
}

final jobActionProvider =
    AsyncNotifierProvider<JobActionNotifier, void>(JobActionNotifier.new);
