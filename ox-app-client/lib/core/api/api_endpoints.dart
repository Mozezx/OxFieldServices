class ApiEndpoints {
  ApiEndpoints._();

  // Alterar para a URL real do backend em produção
  static const baseUrl = 'http://10.0.2.2:3000'; // Android emulator → localhost

  static const authSync = '/auth/sync';
  static const authMe   = '/auth/me';

  static const projects      = '/projects';
  static String projectById(String id) => '/projects/$id';
  static String projectStatus(String id) => '/projects/$id/status';
  static String projectPhases(String id) => '/projects/$id/phases';

  static String phaseById(String id) => '/phases/$id';
  static String phaseValidate(String id) => '/phases/$id/validate';
  static String phaseEvidence(String id) => '/phases/$id/evidence';
  static String phaseEvidenceList(String id) => '/phases/$id/evidence';

  static String contractByProject(String projectId) => '/contracts/project/$projectId';
  static const contracts = '/contracts';

  static const payments = '/payments';
  static String paymentEscrow(String contractId) => '/payments/escrow/$contractId';

  static const usersFcmToken = '/users/fcm-token';
}
