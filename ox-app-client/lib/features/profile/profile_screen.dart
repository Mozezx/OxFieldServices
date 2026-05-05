import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/l10n/language_selector_widget.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ox_app_bar.dart';
import '../../core/widgets/ox_button.dart';
import '../../core/widgets/profile_avatar.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_me_provider.dart';
import 'avatar_upload.dart';
import '../../l10n/app_localizations.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _avatarBusy = false;

  Future<void> _pickAndUpload(ImageSource source, AppLocalizations l) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      maxWidth: 2048,
      imageQuality: 85,
    );
    if (file == null) return;
    setState(() => _avatarBusy = true);
    try {
      await uploadProfileAvatar(ref, file);
      ref.invalidate(authMeProvider);
    } catch (e) {
      debugPrint('avatar upload failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mapAvatarUploadError(e, l))));
    } finally {
      if (mounted) setState(() => _avatarBusy = false);
    }
  }

  Future<void> _confirmRemove(AppLocalizations l) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l.profilePhotoRemove,
            style: const TextStyle(color: AppColors.textPrimary)),
        content: Text(
          l.profilePhotoRemoveMessage,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.profilePhotoRemove),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _avatarBusy = true);
    try {
      await clearProfileAvatar(ref);
      ref.invalidate(authMeProvider);
    } catch (e) {
      debugPrint('avatar clear failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mapAvatarUploadError(e, l))),
        );
      }
    } finally {
      if (mounted) setState(() => _avatarBusy = false);
    }
  }

  void _showAvatarSheet(AppLocalizations l, AuthMeUser? me) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.image, color: AppColors.accent),
              title: Text(l.profilePhotoGallery),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUpload(ImageSource.gallery, l);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.camera, color: AppColors.accent),
              title: Text(l.profilePhotoCamera),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUpload(ImageSource.camera, l);
              },
            ),
            if ((me?.avatarUrl ?? '').isNotEmpty)
              ListTile(
                leading: const Icon(LucideIcons.trash, color: AppColors.error),
                title: Text(l.profilePhotoRemove,
                    style: const TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmRemove(l);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);
    final meAsync = ref.watch(authMeProvider);
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: OxAppBar(
        title: l.profileTitle,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.logOut, size: 20),
            color: AppColors.error,
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: Text(l.profileLogoutTitle,
                      style: const TextStyle(color: AppColors.textPrimary)),
                  content: Text(
                    l.profileLogoutConfirm,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l.commonCancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(l.profileLogoutTitle,
                          style: const TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                ref.read(authControllerProvider.notifier).signOut();
              }
            },
          ),
        ],
      ),
      body: meAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Text(
            user?.email ?? '',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        data: (me) {
          final displayName = (me?.name.isNotEmpty == true
                  ? me!.name
                  : user?.email?.split('@').first) ??
              '';
          final emailLine =
              me?.email.isNotEmpty == true ? me!.email : (user?.email ?? '');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity: _avatarBusy ? 0.45 : 1,
                            child: ProfileAvatar(
                              radius: 40,
                              imageUrl: me?.avatarUrl,
                              label: displayName.isNotEmpty
                                  ? displayName
                                  : emailLine,
                              onTap: _avatarBusy
                                  ? null
                                  : () => _showAvatarSheet(l, me),
                            ),
                          ),
                          if (_avatarBusy)
                            const SizedBox(
                              width: 36,
                              height: 36,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.profilePhotoChangeHint,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    displayName.isNotEmpty ? displayName : emailLine,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                if (emailLine.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      emailLine,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                _ProfileTile(
                  icon: LucideIcons.creditCard,
                  label: l.profilePaymentMethods,
                  subtitle: l.profilePaymentMethodsSubtitle,
                  onTap: () => context.push('/payment-methods'),
                ),
                const SizedBox(height: 12),
                const LanguageSelectorWidget(),
                const SizedBox(height: 32),
                OxButton(
                  label: l.profileLogoutButton,
                  variant: OxButtonVariant.secondary,
                  isLoading: authState is AsyncLoading,
                  onPressed: () =>
                      ref.read(authControllerProvider.notifier).signOut(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight,
                size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
