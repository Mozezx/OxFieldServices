import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../api/api_client.dart';
import 'preferred_locale_sync.dart';

const _kLocaleKey = 'selected_locale';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(ref);
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._ref) : super(const Locale('pt')) {
    _loadLocale();
  }

  final Ref _ref;

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kLocaleKey);
    if (code != null) state = Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, locale.languageCode);
    if (Supabase.instance.client.auth.currentSession != null) {
      await patchPreferredLocale(
        _ref.read(apiClientProvider).dio,
        locale.languageCode,
      );
    }
  }
}

const supportedLocales = [
  Locale('pt'),
  Locale('en'),
  Locale('nl'),
  Locale('es'),
];

const localeDisplayNames = {
  'pt': 'Português',
  'en': 'English',
  'nl': 'Nederlands',
  'es': 'Español',
};
