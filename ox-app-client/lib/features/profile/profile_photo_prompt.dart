import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_me_provider.dart';
import 'avatar_upload.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

class ProfilePhotoGate extends ConsumerStatefulWidget {
  const ProfilePhotoGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ProfilePhotoGate> createState() => _ProfilePhotoGateState();
}

class _ProfilePhotoGateState extends ConsumerState<ProfilePhotoGate> {
  bool _dialogScheduled = false;

  Future<void> _maybeShowPrompt(AuthMeUser? me) async {
    if (me == null || me.unsynced || me.avatarUrl != null) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(kProfilePhotoPromptDismissedKey) == true) return;
    if (_dialogScheduled || !mounted) return;
    _dialogScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showProfilePhotoPromptDialog(context, ref);
      if (mounted) setState(() => _dialogScheduled = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AuthMeUser?>>(authMeProvider, (previous, next) {
      if (next.hasValue && next.value == null) {
        _dialogScheduled = false;
      }
      next.whenData((me) => unawaited(_maybeShowPrompt(me)));
    });

    return widget.child;
  }
}

Future<void> showProfilePhotoPromptDialog(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context)!;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        l.profilePhotoPromptTitle,
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      content: Text(
        l.profilePhotoPromptBody,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(kProfilePhotoPromptDismissedKey, true);
            if (ctx.mounted) Navigator.of(ctx).pop();
          },
          child: Text(l.profilePhotoPromptLater),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(ctx).pop();
            final picker = ImagePicker();
            final file = await picker.pickImage(
              source: ImageSource.gallery,
              maxWidth: 2048,
              imageQuality: 85,
            );
            if (file == null) return;
            if (!context.mounted) return;
            await _runUpload(context, ref, file);
          },
          child: Text(l.profilePhotoGallery),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(ctx).pop();
            final picker = ImagePicker();
            final file = await picker.pickImage(
              source: ImageSource.camera,
              maxWidth: 2048,
              imageQuality: 85,
            );
            if (file == null) return;
            if (!context.mounted) return;
            await _runUpload(context, ref, file);
          },
          child: Text(l.profilePhotoCamera),
        ),
      ],
    ),
  );
}

Future<void> _runUpload(BuildContext context, WidgetRef ref, XFile file) async {
  final l = AppLocalizations.of(context)!;
  try {
    await uploadProfileAvatar(ref, file);
    ref.invalidate(authMeProvider);
  } catch (e) {
    debugPrint('avatar upload failed: $e');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mapAvatarUploadError(e, l))));
  }
}
