import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../l10n/app_localizations.dart';

const _maxBytes = 5 * 1024 * 1024;
const _bucket = 'avatars';

Future<void> uploadProfileAvatar(
  WidgetRef ref,
  XFile file,
) async {
  final bytes = await file.readAsBytes();
  if (bytes.length > _maxBytes) {
    throw Exception('IMAGE_TOO_LARGE');
  }

  final mime = file.mimeType ?? '';
  final pathLower = file.path.toLowerCase();
  final isPng = mime.contains('png') || pathLower.endsWith('.png');
  final isJpeg =
      mime.contains('jpeg') || pathLower.endsWith('.jpg') || pathLower.endsWith('.jpeg');
  if (!isPng && !isJpeg) {
    throw Exception('IMAGE_TYPE');
  }

  final ext = isPng ? 'png' : 'jpg';
  final authId = Supabase.instance.client.auth.currentUser?.id;
  if (authId == null) throw Exception('NO_SESSION');

  final objectPath = '$authId/${DateTime.now().millisecondsSinceEpoch}.$ext';
  final contentType = isPng ? 'image/png' : 'image/jpeg';

  await Supabase.instance.client.storage.from(_bucket).uploadBinary(
        objectPath,
        Uint8List.fromList(bytes),
        fileOptions: FileOptions(contentType: contentType, upsert: true),
      );

  final publicUrl =
      Supabase.instance.client.storage.from(_bucket).getPublicUrl(objectPath);

  final api = ref.read(apiClientProvider);
  await api.dio.patch<Map<String, dynamic>>(
    ApiEndpoints.usersAvatarUrl,
    data: {'avatarUrl': publicUrl},
  );
}

Future<void> clearProfileAvatar(WidgetRef ref) async {
  final api = ref.read(apiClientProvider);
  await api.dio.patch<Map<String, dynamic>>(
    ApiEndpoints.usersAvatarUrl,
    data: {'avatarUrl': null},
  );
}

/// Mapeia erros do upload de avatar para mensagem traduzida; em debug, anexa
/// a causa real (ex.: `StorageException: new row violates row-level security`)
/// para facilitar o diagnóstico em campo.
String mapAvatarUploadError(Object error, AppLocalizations l) {
  final raw = error.toString();
  String base;
  if (raw.contains('IMAGE_TOO_LARGE')) {
    base = l.profilePhotoSizeError;
  } else if (raw.contains('IMAGE_TYPE')) {
    base = l.profilePhotoTypeError;
  } else {
    base = l.profilePhotoUploadError;
  }
  if (kDebugMode && !raw.contains('IMAGE_TOO_LARGE') && !raw.contains('IMAGE_TYPE')) {
    return '$base ($raw)';
  }
  return base;
}
