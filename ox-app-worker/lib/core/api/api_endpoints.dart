class ApiEndpoints {
  ApiEndpoints._();

  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.18:3000',
  );

  static const authSync = '/auth/sync';
  static const authMe   = '/auth/me';

  // Worker profile
  static const workerMe      = '/workers/me';
  static const workerRatings = '/workers/me/ratings';

  // Jobs (matching)
  static String jobCandidates(String projectId) => '/matching/$projectId/candidates';

  // Projects (for active job execution)
  static const projects      = '/projects';
  static String projectById(String id) => '/projects/$id';

  // Phases
  static String phaseById(String id) => '/phases/$id';
  static String phaseStatus(String id) => '/phases/$id/status';
  static String phaseEvidence(String id) => '/phases/$id/evidence';
  static String phaseEvidenceList(String id) => '/phases/$id/evidence';

  // Contracts
  static const contracts = '/contracts';
  static String contractById(String id) => '/contracts/$id';
  static String contractSign(String id) => '/contracts/$id/sign';
  static String contractByProject(String projectId) => '/contracts/project/$projectId';

  // Payments (histórico do worker)
  static const paymentsHistory = '/payments/me';
  static String paymentEscrow(String contractId) => '/payments/escrow/$contractId';

  // Stripe Connect (worker)
  static const paymentsConnectAccount = '/payments/worker-account';
  static const paymentsConnectOnboarding = '/payments/worker-account/onboarding';
  static const paymentsConnectStatus = '/payments/worker-account/status';

  // Predefined skills
  static const skills = '/skills';

  // FCM
  static const usersFcmToken = '/users/fcm-token';
  static const usersDeviceTokens = '/users/device-tokens';

  static const notifications = '/notifications';
  static const notificationsUnreadCount = '/notifications/unread-count';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const notificationsReadAll = '/notifications/read-all';
}
