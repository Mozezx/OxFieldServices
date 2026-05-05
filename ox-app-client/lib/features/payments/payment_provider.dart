import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';

class EscrowModel {
  const EscrowModel({
    required this.id,
    required this.amount,
    required this.status,
    required this.contractId,
  });

  final String id;
  final double amount;
  final String status;
  final String contractId;

  factory EscrowModel.fromJson(Map<String, dynamic> json) => EscrowModel(
        id: json['id'] as String,
        amount: double.tryParse(json['amount'].toString()) ?? 0.0,
        status: json['status'] as String? ?? 'held',
        contractId: json['contractId'] as String? ?? '',
      );
}

class EscrowIntent {
  const EscrowIntent({
    required this.clientSecret,
    required this.paymentIntentId,
    required this.amount,
    required this.alreadyPaid,
    this.customerId,
    this.customerEphemeralKeySecret,
    this.publishableKey,
  });

  final String? clientSecret;
  final String? paymentIntentId;
  final double amount;
  final bool alreadyPaid;
  final String? customerId;
  final String? customerEphemeralKeySecret;
  final String? publishableKey;

  factory EscrowIntent.fromJson(Map<String, dynamic> json) => EscrowIntent(
        clientSecret: json['clientSecret'] as String?,
        paymentIntentId: json['paymentIntentId'] as String?,
        amount: double.tryParse(json['amount'].toString()) ?? 0.0,
        alreadyPaid: json['alreadyPaid'] as bool? ?? false,
        customerId: json['customerId'] as String?,
        customerEphemeralKeySecret:
            json['customerEphemeralKeySecret'] as String?,
        publishableKey: json['publishableKey'] as String?,
      );
}

final escrowProvider =
    FutureProvider.family<EscrowModel?, String>((ref, contractId) async {
  final api = ref.watch(apiClientProvider);
  try {
    final res = await api.dio.get(ApiEndpoints.paymentEscrowByContract(contractId));
    return EscrowModel.fromJson(res.data as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
});

class PaymentNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<EscrowIntent> createOrFetchIntent(String contractId) async {
    final api = ref.read(apiClientProvider);
    final res = await api.dio.post(ApiEndpoints.paymentEscrow(contractId));
    return EscrowIntent.fromJson(res.data as Map<String, dynamic>);
  }
}

final paymentNotifierProvider =
    AsyncNotifierProvider<PaymentNotifier, void>(PaymentNotifier.new);
