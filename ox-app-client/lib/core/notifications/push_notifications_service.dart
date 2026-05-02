import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../firebase_options.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../../features/notifications/notifications_provider.dart';

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

bool _firebaseReady(FirebaseOptions o) {
  return o.projectId.isNotEmpty &&
      o.apiKey.isNotEmpty &&
      o.appId.isNotEmpty &&
      o.messagingSenderId.isNotEmpty;
}

String _devicePlatform() {
  if (kIsWeb) return 'web';
  if (Platform.isIOS) return 'ios';
  return 'android';
}

/// Handler top-level para mensagens em background (isolado).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final opts = DefaultFirebaseOptions.currentPlatform;
  if (!_firebaseReady(opts)) return;
  await Firebase.initializeApp(options: opts);
}

/// Registra FCM, envia token ao backend e escuta mensagens.
class PushNotificationsService {
  PushNotificationsService(this._ref);

  final WidgetRef _ref;

  Future<void> initialize({GoRouter? router}) async {
    try {
      final opts = DefaultFirebaseOptions.currentPlatform;
      if (!_firebaseReady(opts)) {
        debugPrint(
          'PushNotifications: Firebase options incompletas — defina FIREBASE_* via --dart-define ou flutterfire configure.',
        );
        return;
      }

      await Firebase.initializeApp(options: opts);

      await _setupLocalNotifications();

      final messaging = FirebaseMessaging.instance;
      if (Platform.isIOS) {
        await messaging.requestPermission(alert: true, badge: true, sound: true);
      } else if (Platform.isAndroid) {
        // Android 13+ (API 33): permissão POST_NOTIFICATIONS
        await messaging.requestPermission();
      }

      final token = await messaging.getToken();
      if (token != null) {
        await _registerToken(token);
      }

      FirebaseMessaging.instance.onTokenRefresh.listen(_registerToken);

      FirebaseMessaging.onMessage.listen((RemoteMessage msg) async {
        await _showLocalNotification(msg);
        _ref.invalidate(notificationsListProvider);
        _ref.invalidate(unreadNotificationsCountProvider);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
        _handleNavigation(router, msg.data);
      });

      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleNavigation(router, initial.data);
        });
      }
    } catch (e, st) {
      debugPrint('PushNotifications init error: $e\n$st');
    }
  }

  Future<void> _registerToken(String token) async {
    try {
      final dio = _ref.read(apiClientProvider).dio;
      await dio.post(
        ApiEndpoints.usersDeviceTokens,
        data: {
          'token': token,
          'platform': _devicePlatform(),
        },
      );
    } catch (e) {
      debugPrint('Register FCM token failed: $e');
    }
  }

  Future<void> _setupLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    const channel = AndroidNotificationChannel(
      'ox_default',
      'OX Notificações',
      description: 'Notificações do OX Field Services',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _showLocalNotification(RemoteMessage msg) async {
    final n = msg.notification;
    final title = n?.title ?? msg.data['title'] ?? 'OX';
    final body = n?.body ?? msg.data['body'] ?? '';
    if (title.isEmpty && body.isEmpty) return;

    await _localNotifications.show(
      msg.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'ox_default',
          'OX Notificações',
          channelDescription: 'Notificações do OX Field Services',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: msg.data.isNotEmpty ? msg.data.toString() : null,
    );
  }

  void _handleNavigation(GoRouter? router, Map<String, dynamic> data) {
    if (router == null) return;
    final entityType = data['entityType'] as String? ?? '';
    final entityId = data['entityId'] as String? ?? '';
    if (entityId.isEmpty) return;

    switch (entityType) {
      case 'project':
        router.go('/projects/$entityId');
        break;
      case 'phase':
        router.go('/phases/$entityId');
        break;
      case 'contract':
      case 'escrow':
        router.go('/payments/$entityId');
        break;
      default:
        router.go('/notifications');
    }
  }
}
