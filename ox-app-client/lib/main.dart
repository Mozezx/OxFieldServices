import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import 'app.dart';
import 'core/api/api_endpoints.dart';
import 'core/notifications/push_notifications_service.dart';

const _supabaseUrl = 'https://pmsccdvhhhokormlvxww.supabase.co';
const _supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'YOUR_SUPABASE_ANON_KEY',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  // Busca a publishable key do backend (endpoint público).
  // Em caso de falha, segue sem Stripe — telas de pagamento avisam.
  try {
    final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
    final res = await dio.get('/payments/config');
    final pk = (res.data?['publishableKey'] as String?) ?? '';
    if (pk.isNotEmpty) {
      Stripe.publishableKey = pk;
      Stripe.merchantIdentifier = 'merchant.com.ox.fieldservices';
      await Stripe.instance.applySettings();
    }
  } catch (_) {
    // App segue funcional para fluxos não-Stripe
  }

  runApp(const ProviderScope(child: OxApp()));
}
