// Configure via: dart define ou flutterfire configure
// dart run flutterfire configure --project=<your-firebase-project>

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Defaults são placeholders — substitua por valores do Firebase Console ou use flutterfire configure.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions não configurado para web neste app.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions não suportado para esta plataforma.',
        );
    }
  }

  /// Valores por defeito alinhados com `android/app/google-services.json` (ox-field-services).
  /// Sobrescreve com `--dart-define=FIREBASE_*=...` se necessário.
  static FirebaseOptions android = FirebaseOptions(
    apiKey: const String.fromEnvironment(
      'FIREBASE_ANDROID_API_KEY',
      defaultValue: 'AIzaSyDQOx8LnLmnVNmChQV9_iGFWlhIlkucOtM',
    ),
    appId: const String.fromEnvironment(
      'FIREBASE_ANDROID_APP_ID',
      defaultValue: '1:420140898358:android:bbaf73b486e1cc0502e097',
    ),
    messagingSenderId: const String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '420140898358',
    ),
    projectId: const String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'ox-field-services',
    ),
    storageBucket: const String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'ox-field-services.firebasestorage.app',
    ),
  );

  static FirebaseOptions ios = FirebaseOptions(
    apiKey: const String.fromEnvironment(
      'FIREBASE_IOS_API_KEY',
      defaultValue: 'AIzaSyBTnR9rJDoYvdURrakJrLNQAfLnSMVAriM',
    ),
    appId: const String.fromEnvironment(
      'FIREBASE_IOS_APP_ID',
      defaultValue: '1:420140898358:ios:54666010fd5057a402e097',
    ),
    messagingSenderId: const String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '420140898358',
    ),
    projectId: const String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'ox-field-services',
    ),
    storageBucket: const String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'ox-field-services.firebasestorage.app',
    ),
    iosBundleId: const String.fromEnvironment(
      'FIREBASE_IOS_BUNDLE_ID',
      defaultValue: 'com.oxservices.oxAppClient',
    ),
  );
}
