import 'dart:io';

import 'package:dio/dio.dart';
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
import '../router/notification_route_helper.dart';
import '../providers/domain_cache_invalidation.dart';

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

String? _fcmScopesString(Map<String, dynamic> data) {
  final s = data['scopes'];
  if (s is String && s.isNotEmpty) return s;
  return null;
}

/// POST /users/device-tokens só depois de existir perfil em GET /auth/me.
Future<void> registerFcmTokenWithBackend(Dio dio, String token) async {
  try {
    final me = await dio.get<Map<String, dynamic>>(ApiEndpoints.authMe);
    final appUserId = me.data?['id'] as String?;
    if (appUserId == null || appUserId.isEmpty) {
      debugPrint(
        'Register FCM token skipped: perfil ainda não existe (faça POST /auth/sync).',
      );
      return;
    }
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

/// Após POST /auth/sync, envia o token FCM ao backend (Firebase já inicializado).
Future<void> syncFcmTokenAfterAuthSync(Dio dio) async {
  try {
    if (Firebase.apps.isEmpty) return;
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await registerFcmTokenWithBackend(dio, token);
  } catch (e) {
    debugPrint('syncFcmTokenAfterAuthSync: $e');
  }
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

  Future<void> initialize({
    GoRouter? router,
    String channelName = 'OX Notifications',
    String channelDescription = 'OX Field Services notifications',
  }) async {
    try {
      final opts = DefaultFirebaseOptions.currentPlatform;
      if (!_firebaseReady(opts)) {
        debugPrint(
          'PushNotifications: Firebase options incompletas — defina FIREBASE_* via --dart-define ou flutterfire configure.',
        );
        return;
      }

      await Firebase.initializeApp(options: opts);

      await _setupLocalNotifications(
        channelName: channelName,
        channelDescription: channelDescription,
      );

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
        await _showLocalNotification(
          msg,
          channelName: channelName,
          channelDescription: channelDescription,
        );
        applyClientRealtimeScopesFromFcm(_ref, _fcmScopesString(msg.data));
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
        applyClientRealtimeScopesFromFcm(_ref, _fcmScopesString(msg.data));
        _handleNavigation(router, msg.data);
      });

      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          applyClientRealtimeScopesFromFcm(_ref, _fcmScopesString(initial.data));
          _handleNavigation(router, initial.data);
        });
      }
    } catch (e, st) {
      debugPrint('PushNotifications init error: $e\n$st');
    }
  }

  Future<void> _registerToken(String token) async {
    final dio = _ref.read(apiClientProvider).dio;
    await registerFcmTokenWithBackend(dio, token);
  }

  Future<void> _setupLocalNotifications({
    required String channelName,
    required String channelDescription,
  }) async {
    const android = AndroidInitializationSettings('ic_stat_ox');
    const ios = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    final channel = AndroidNotificationChannel(
      'ox_default',
      channelName,
      description: channelDescription,
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _showLocalNotification(
    RemoteMessage msg, {
    required String channelName,
    required String channelDescription,
  }) async {
    final n = msg.notification;
    final title = n?.title ?? msg.data['title'] as String? ?? 'OX';
    final body = n?.body ?? msg.data['body'] as String? ?? '';
    if (title.isEmpty && body.isEmpty) return;

    await _localNotifications.show(
      msg.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'ox_default',
          channelName,
          channelDescription: channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_stat_ox',
          largeIcon: const DrawableResourceAndroidBitmap('ic_launcher_foreground'),
        ),
        iOS: const DarwinNotificationDetails(),
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
        goThenPushDetail(
          router,
          basePath: '/home',
          detailPath: '/projects/$entityId',
        );
        break;
      case 'phase':
        goThenPushDetail(
          router,
          basePath: '/home',
          detailPath: '/phases/$entityId',
        );
        break;
      case 'contract':
      case 'escrow':
        final projectId = data['projectId'] as String?;
        final q = (projectId != null && projectId.isNotEmpty)
            ? '?projectId=${Uri.encodeQueryComponent(projectId)}'
            : '';
        goThenPushDetail(
          router,
          basePath: '/home',
          detailPath: '/payments/$entityId$q',
        );
        break;
      default:
        router.go('/notifications');
    }
  }
}
