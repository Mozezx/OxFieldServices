import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _keyOnboarded = 'ox_worker_onboarded';

  static Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboarded) ?? false;
  }

  static Future<void> setOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboarded, true);
  }
}
