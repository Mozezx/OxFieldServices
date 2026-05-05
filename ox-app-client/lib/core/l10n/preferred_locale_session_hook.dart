import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../api/api_client.dart';
import 'locale_provider.dart';
import 'preferred_locale_sync.dart';
import '../../features/auth/auth_me_provider.dart';

/// Envia o idioma atual ao backend quando existe sessão e perfil carregado,
/// para alinhar push e cópia persistida com o seletor do app (não só após login manual).
class PreferredLocaleSessionSync extends ConsumerWidget {
  const PreferredLocaleSessionSync({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<AuthMeUser?>>(authMeProvider, (_, next) {
      next.whenData((me) {
        if (me == null) return;
        if (Supabase.instance.client.auth.currentSession == null) return;
        patchPreferredLocale(
          ref.read(apiClientProvider).dio,
          ref.read(localeProvider).languageCode,
        );
      });
    });
    return child;
  }
}
