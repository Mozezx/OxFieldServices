import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';

class PaymentItemModel {
  const PaymentItemModel({
    required this.id,
    required this.amount,
    required this.status,
    this.projectTitle,
    this.phaseDescription,
    this.paidAt,
  });

  final String id;
  final double amount;
  final String status;
  final String? projectTitle;
  final String? phaseDescription;
  final DateTime? paidAt;

  factory PaymentItemModel.fromJson(Map<String, dynamic> json) =>
      PaymentItemModel(
        id: json['id'] as String,
        amount: double.tryParse(json['amount'].toString()) ?? 0.0,
        status: json['status'] as String? ??
            json['escrow']?['status'] as String? ??
            'held',
        projectTitle: json['escrow']?['contract']?['project']?['title']
            as String?,
        phaseDescription: json['recipientType'] as String?,
        paidAt:
            json['paidAt'] != null ? DateTime.tryParse(json['paidAt']) : null,
      );

  bool get isReleased => status == 'released' || paidAt != null;
}

final paymentsProvider =
    FutureProvider.autoDispose<List<PaymentItemModel>>((ref) async {
  final api = ref.watch(apiClientProvider);
  try {
    final res = await api.dio.get(ApiEndpoints.paymentsHistory);
    final data = res.data as List<dynamic>;
    return data
        .map((e) => PaymentItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
});

final totalReceivedProvider = Provider.autoDispose<AsyncValue<double>>((ref) {
  return ref.watch(paymentsProvider).whenData(
    (payments) => payments
        .where((p) => p.isReleased)
        .fold(0.0, (sum, p) => sum + p.amount),
  );
});
