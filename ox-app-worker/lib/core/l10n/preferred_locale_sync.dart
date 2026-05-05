import 'package:dio/dio.dart';

import '../api/api_endpoints.dart';

Future<void> patchPreferredLocale(Dio dio, String languageCode) async {
  try {
    await dio.patch<Map<String, dynamic>>(
      ApiEndpoints.usersPreferredLocale,
      data: {'preferredLocale': languageCode},
    );
  } catch (_) {}
}
