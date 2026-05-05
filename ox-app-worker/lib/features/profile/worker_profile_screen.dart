import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../core/l10n/language_selector_widget.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ox_app_bar.dart';
import '../../core/widgets/ox_button.dart';
import '../../core/widgets/ox_loading.dart';
import '../../core/widgets/profile_avatar.dart';
import '../../l10n/app_localizations.dart';
import '../auth/auth_controller.dart';
import 'avatar_upload.dart';
import 'bank_account_section.dart';
import 'profile_provider.dart';

class WorkerProfileScreen extends ConsumerStatefulWidget {
  const WorkerProfileScreen({super.key});

  @override
  ConsumerState<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends ConsumerState<WorkerProfileScreen> {
  bool _avatarBusy = false;

  Future<void> _pickAndUpload(ImageSource source, AppLocalizations t) async {
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 2048,
      imageQuality: 85,
    );
    if (file == null) return;
    setState(() => _avatarBusy = true);
    try {
      await uploadProfileAvatar(ref, file);
      ref.invalidate(workerProfileProvider);
    } catch (e) {
      debugPrint('avatar upload failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mapAvatarUploadError(e, t))));
    } finally {
      if (mounted) setState(() => _avatarBusy = false);
    }
  }

  Future<void> _confirmRemove(AppLocalizations t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(t.profilePhotoRemove,
            style: const TextStyle(color: AppColors.textPrimary)),
        content: Text(
          t.profilePhotoRemoveMessage,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.profilePhotoRemove),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _avatarBusy = true);
    try {
      await clearProfileAvatar(ref);
      ref.invalidate(workerProfileProvider);
    } catch (e) {
      debugPrint('avatar clear failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mapAvatarUploadError(e, t))),
        );
      }
    } finally {
      if (mounted) setState(() => _avatarBusy = false);
    }
  }

  void _showAvatarSheet(AppLocalizations t, WorkerProfileModel? worker) {
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
              title: Text(t.profilePhotoGallery),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUpload(ImageSource.gallery, t);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.camera, color: AppColors.accent),
              title: Text(t.profilePhotoCamera),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUpload(ImageSource.camera, t);
              },
            ),
            if ((worker?.avatarUrl ?? '').isNotEmpty)
              ListTile(
                leading: const Icon(LucideIcons.trash, color: AppColors.error),
                title: Text(t.profilePhotoRemove,
                    style: const TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmRemove(t);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final workerAsync = ref.watch(workerProfileProvider);

    return Scaffold(
      appBar: OxAppBar(
        title: t.profileTitle,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.logOut, size: 20),
            color: AppColors.error,
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (dialogContext) {
                  final dt = AppLocalizations.of(dialogContext)!;
                  return AlertDialog(
                    backgroundColor: AppColors.surface,
                    title: Text(
                      dt.profileLogoutTitle,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontFamily: 'Inter',
                      ),
                    ),
                    content: Text(
                      dt.profileLogoutConfirm,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: Text(dt.commonCancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: Text(
                          dt.profileLogoutTitle,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  );
                },
              );
              if (confirm == true) {
                try {
                  await ref.read(authControllerProvider.notifier).signOut();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(t.profileSignoutError(e.toString())),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }

                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
          ),
        ],
      ),
      body: workerAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              OxShimmerBox(width: double.infinity, height: 120, borderRadius: 16),
              SizedBox(height: 16),
              OxShimmerBox(width: double.infinity, height: 80, borderRadius: 16),
            ],
          ),
        ),
        error: (e, _) => Center(
          child: Text(
            t.commonErrorWithMessage(e.toString()),
            style: const TextStyle(color: AppColors.error),
          ),
        ),
        data: (worker) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: _avatarBusy ? 0.45 : 1,
                          child: ProfileAvatar(
                            radius: 40,
                            imageUrl: worker?.avatarUrl,
                            label: worker?.name ?? worker?.email ?? 'W',
                            onTap: _avatarBusy
                                ? null
                                : () => _showAvatarSheet(t, worker),
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
                      t.profilePhotoChangeHint,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      worker?.name ?? t.defaultWorkerName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                    if (worker?.email != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        worker!.email!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontFamily: 'Inter',
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(5, (i) {
                          final full = (worker?.rating ?? 0).floor();
                          return Icon(
                            LucideIcons.star,
                            size: 20,
                            color: i < full
                                ? AppColors.warning
                                : AppColors.textDisabled,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          worker?.rating.toStringAsFixed(1) ?? '0.0',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.profileStatusSection,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _StatusRow(
                      icon: LucideIcons.circle,
                      label: t.profileAvailabilityLabel,
                      value: (worker?.available ?? false)
                          ? t.workerStatusAvailable
                          : t.workerStatusUnavailable,
                      valueColor: (worker?.available ?? false)
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                    _StatusRow(
                      icon: LucideIcons.shield,
                      label: t.profileShelterLabel,
                      value: (worker?.shelterCertified ?? false)
                          ? t.profileCertifiedValue
                          : t.profileNotCertifiedValue,
                      valueColor: (worker?.shelterCertified ?? false)
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (worker != null) ...[
                _SkillsSection(worker: worker),
                const SizedBox(height: 16),
              ],

              const BankAccountSection(),
              const SizedBox(height: 16),

              const LanguageSelectorWidget(),
              const SizedBox(height: 16),

              OxButton(
                label: (worker?.available ?? false)
                    ? t.profileMarkUnavailable
                    : t.profileMarkAvailable,
                variant: (worker?.available ?? false)
                    ? OxButtonVariant.secondary
                    : OxButtonVariant.primary,
                icon: LucideIcons.circle,
                onPressed: () => ref
                    .read(workerProfileNotifierProvider.notifier)
                    .toggleAvailability(!(worker?.available ?? false)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillsSection extends ConsumerWidget {
  const _SkillsSection({required this.worker});
  final WorkerProfileModel worker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final skillsAsync = ref.watch(predefinedSkillsProvider);
    final notifierState = ref.watch(workerProfileNotifierProvider);
    final isSaving = notifierState.isLoading;

    return skillsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (predefined) {
        if (predefined.isEmpty) return const SizedBox.shrink();

        final selected = worker.skills.map((s) => s.toLowerCase()).toSet();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.profileSkillsSection,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  if (isSaving)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: predefined.map((skill) {
                  final isSelected = selected.contains(skill.name.toLowerCase());
                  return GestureDetector(
                    onTap: isSaving
                        ? null
                        : () {
                            final newSelected = Set<String>.from(selected);
                            if (isSelected) {
                              newSelected.remove(skill.name.toLowerCase());
                            } else {
                              newSelected.add(skill.name.toLowerCase());
                            }
                            ref
                                .read(workerProfileNotifierProvider.notifier)
                                .updateSkills(newSelected.toList());
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent.withValues(alpha: 0.15)
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accent.withValues(alpha: 0.6)
                              : AppColors.divider,
                        ),
                      ),
                      child: Text(
                        skill.label,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (selected.isEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  t.profileSkillsHint,
                  style: const TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontFamily: 'Inter',
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
