import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';

class SavedCard {
  const SavedCard({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    required this.isDefault,
  });

  final String id;
  final String brand;
  final String last4;
  final int expMonth;
  final int expYear;
  final bool isDefault;

  factory SavedCard.fromJson(Map<String, dynamic> json) => SavedCard(
        id: json['id'] as String,
        brand: json['brand'] as String? ?? 'card',
        last4: json['last4'] as String? ?? '****',
        expMonth: (json['expMonth'] as num?)?.toInt() ?? 0,
        expYear: (json['expYear'] as num?)?.toInt() ?? 0,
        isDefault: json['isDefault'] as bool? ?? false,
      );
}

final paymentMethodsProvider = FutureProvider<List<SavedCard>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.dio.get(ApiEndpoints.paymentsMethods);
  final list = (res.data as List<dynamic>);
  return list
      .map((e) => SavedCard.fromJson(e as Map<String, dynamic>))
      .toList();
});

class PaymentMethodsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addCard() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = ref.read(apiClientProvider);
      final res = await api.dio.post(ApiEndpoints.paymentsSetupIntent);
      final data = res.data as Map<String, dynamic>;

      final clientSecret = data['clientSecret'] as String;
      final customerId = data['customerId'] as String?;
      final customerEphemeralKeySecret =
          data['customerEphemeralKeySecret'] as String?;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          setupIntentClientSecret: clientSecret,
          customerId: customerId,
          customerEphemeralKeySecret: customerEphemeralKeySecret,
          merchantDisplayName: 'OX Field Services',
          style: ThemeMode.dark,
          primaryButtonLabel: 'Salvar cartão',
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      ref.invalidate(paymentMethodsProvider);
    });
  }

  Future<void> removeCard(String paymentMethodId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = ref.read(apiClientProvider);
      await api.dio.delete(ApiEndpoints.paymentMethodById(paymentMethodId));
      ref.invalidate(paymentMethodsProvider);
    });
  }

  Future<void> setDefault(String paymentMethodId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = ref.read(apiClientProvider);
      await api.dio.post(ApiEndpoints.paymentMethodDefault(paymentMethodId));
      ref.invalidate(paymentMethodsProvider);
    });
  }
}

final paymentMethodsNotifierProvider =
    AsyncNotifierProvider<PaymentMethodsNotifier, void>(
        PaymentMethodsNotifier.new);
