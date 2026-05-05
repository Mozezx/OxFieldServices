class ApiEndpoints {
  ApiEndpoints._();

  // Alterar para a URL real do backend em produção
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.18:3000',
  ); // Android físico via Wi‑Fi local

  static const authSync = '/auth/sync';
  static const authMe   = '/auth/me';

  static const projects      = '/projects';
  static String projectById(String id) => '/projects/$id';
  static String projectStatus(String id) => '/projects/$id/status';
  static String projectPhases(String id) => '/projects/$id/phases';
  static String projectRating(String id) => '/projects/$id/rating';

  static String phaseById(String id) => '/phases/$id';
  static String phaseValidate(String id) => '/phases/$id/validate';
  static String phaseEvidence(String id) => '/phases/$id/evidence';
  static String phaseEvidenceList(String id) => '/phases/$id/evidence';

  static String contractByProject(String projectId) => '/contracts/project/$projectId';
  static const contracts = '/contracts';

  static const payments = '/payments';
  static const paymentsConfig = '/payments/config';
  static String paymentEscrow(String contractId) => '/payments/escrow/$contractId';
  static String paymentEscrowByContract(String contractId) =>
      '/payments/escrow/contract/$contractId';

  static const paymentsSetupIntent = '/payments/setup-intent';
  static const paymentsMethods = '/payments/payment-methods';
  static String paymentMethodById(String id) => '/payments/payment-methods/$id';
  static String paymentMethodDefault(String id) =>
      '/payments/payment-methods/$id/default';

  static const invitesPreview = '/invites/preview';
  static const invitesRedeem = '/invites/redeem';

  static const usersFcmToken = '/users/fcm-token';
  static const usersDeviceTokens = '/users/device-tokens';
  static const usersPreferredLocale = '/users/preferred-locale';
  static const usersAvatarUrl = '/users/avatar-url';

  static const notifications = '/notifications';
  static const notificationsUnreadCount = '/notifications/unread-count';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const notificationsReadAll = '/notifications/read-all';
}
