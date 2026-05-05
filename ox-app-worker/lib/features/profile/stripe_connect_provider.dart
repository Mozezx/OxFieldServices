import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';

class BankAccountPreview {
  const BankAccountPreview({
    required this.type,
    required this.bankName,
    required this.last4,
    required this.currency,
    required this.country,
  });

  final String type; // 'bank' | 'card'
  final String? bankName;
  final String last4;
  final String currency;
  final String country;

  factory BankAccountPreview.fromJson(Map<String, dynamic> json) =>
      BankAccountPreview(
        type: json['type'] as String? ?? 'bank',
        bankName: json['bankName'] as String?,
        last4: json['last4'] as String? ?? '****',
        currency: json['currency'] as String? ?? 'EUR',
        country: json['country'] as String? ?? '',
      );
}

class ConnectStatus {
  const ConnectStatus({
    required this.status,
    required this.detailsSubmitted,
    required this.chargesEnabled,
    required this.payoutsEnabled,
    required this.currentlyDue,
    required this.pastDue,
    this.disabledReason,
    this.bankAccount,
    this.stripeAccountId,
  });

  final String status; // 'not_started' | 'pending' | 'active' | 'restricted'
  final bool detailsSubmitted;
  final bool chargesEnabled;
  final bool payoutsEnabled;
  final List<String> currentlyDue;
  final List<String> pastDue;
  final String? disabledReason;
  final BankAccountPreview? bankAccount;
  final String? stripeAccountId;

  bool get isReady => status == 'active';
  bool get notStarted => status == 'not_started';

  factory ConnectStatus.fromJson(Map<String, dynamic> json) {
    final req = json['requirements'] as Map<String, dynamic>?;
    final bank = json['bankAccount'] as Map<String, dynamic>?;
    return ConnectStatus(
      status: json['status'] as String? ?? 'not_started',
      detailsSubmitted: json['detailsSubmitted'] as bool? ?? false,
      chargesEnabled: json['chargesEnabled'] as bool? ?? false,
      payoutsEnabled: json['payoutsEnabled'] as bool? ?? false,
      currentlyDue: (req?['currentlyDue'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      pastDue: (req?['pastDue'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      disabledReason: req?['disabledReason'] as String?,
      bankAccount:
          bank != null ? BankAccountPreview.fromJson(bank) : null,
      stripeAccountId: json['stripeAccountId'] as String?,
    );
  }
}

final connectStatusProvider = FutureProvider<ConnectStatus>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.dio.get(ApiEndpoints.paymentsConnectStatus);
  return ConnectStatus.fromJson(res.data as Map<String, dynamic>);
});

class ConnectActionNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async => null;

  /// Cria a conta Connect (se ainda não existe) e retorna a URL de onboarding.
  Future<String?> openOnboarding() async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final api = ref.read(apiClientProvider);

      // Garantir que a conta existe (idempotente: backend retorna 400 se já existe)
      try {
        await api.dio.post(ApiEndpoints.paymentsConnectAccount);
      } catch (_) {
        // Já existia, segue
      }

      final res = await api.dio.get(ApiEndpoints.paymentsConnectOnboarding);
      return (res.data as Map<String, dynamic>)['url'] as String?;
    });
    state = result;
    return result.value;
  }

  /// Apenas reabre o link de onboarding (worker já tem conta).
  Future<String?> reopenOnboarding() async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final api = ref.read(apiClientProvider);
      final res = await api.dio.get(ApiEndpoints.paymentsConnectOnboarding);
      return (res.data as Map<String, dynamic>)['url'] as String?;
    });
    state = result;
    return result.value;
  }

  void refreshStatus() {
    ref.invalidate(connectStatusProvider);
  }
}

final connectActionProvider =
    AsyncNotifierProvider<ConnectActionNotifier, String?>(
        ConnectActionNotifier.new);
