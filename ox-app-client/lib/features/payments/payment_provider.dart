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

final escrowProvider =
    FutureProvider.autoDispose.family<EscrowModel?, String>((ref, contractId) async {
  final api = ref.watch(apiClientProvider);
  try {
    final res = await api.dio.get(ApiEndpoints.paymentEscrow(contractId));
    return EscrowModel.fromJson(res.data as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
});
