import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ox_app_bar.dart';
import '../../core/widgets/ox_badge.dart';
import '../../core/widgets/ox_button.dart';
import '../../core/widgets/ox_empty_state.dart';
import '../../l10n/app_localizations.dart';
import 'execution_provider.dart';

String _phaseChecklistLabel(AppLocalizations t, String key) {
  switch (key) {
    case 'materials':
      return t.phaseChecklistItemMaterials;
    case 'ppe':
      return t.phaseChecklistItemPpe;
    case 'work_started':
      return t.phaseChecklistItemWorkStarted;
    case 'safety':
      return t.phaseChecklistItemSafety;
    case 'photo_doc':
      return t.phaseChecklistItemPhotoDoc;
    default:
      return key;
  }
}

class PhaseExecutionScreen extends ConsumerWidget {
  const PhaseExecutionScreen({super.key, this.phaseId});

  final String? phaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;

    if (phaseId == null) {
      return const _NoActivePhaseScreen();
    }

    final phaseAsync = ref.watch(phaseExecutionProvider(phaseId));
    final checklist = ref.watch(checklistProvider);
    final submitState = ref.watch(phaseSubmitProvider(phaseId!));
    final startState = ref.watch(startPhaseProvider(phaseId!));

    ref.listen(phaseSubmitProvider(phaseId!), (previous, next) {
      final triggeredByAction = previous is AsyncLoading;
      if (!triggeredByAction) return;

      if (next is AsyncError) {
        final e = next.error;
        final msg = e is PhaseNotFoundException
            ? t.phaseErrorNotFound
            : e is PhaseSubmitPreconditionException
                ? t.phaseErrorNeedEvidenceBeforeSubmit
                : e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.error,
          ),
        );
      } else if (next is AsyncData) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.phaseSubmittedSuccess),
            backgroundColor: AppColors.accent,
          ),
        );
        context.go('/home');
      }
    });

    ref.listen(startPhaseProvider(phaseId!), (previous, next) {
      final triggeredByAction = previous is AsyncLoading;
      if (!triggeredByAction) return;

      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      } else if (next is AsyncData) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.phaseStartedSuccess),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    });

    return Scaffold(
      appBar: OxAppBar(title: t.phaseExecutionTitle),
      body: phaseAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (e, _) => Center(
          child: Text(
            t.commonErrorWithMessage(e.toString()),
            style: const TextStyle(color: AppColors.error),
          ),
        ),
        data: (phase) {
          if (phase == null) {
            return const _NoActivePhaseScreen();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.phaseOrderAndName(phase.order, phase.name),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    OxBadge(
                      label: _phaseLabel(t, phase.status),
                      status: phaseStatusToBadge(phase.status),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  t.phaseAmountLabel(phase.amount.toStringAsFixed(2)),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  t.phaseChecklist,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 12),
                ...kPhaseChecklistKeys.map((key) => _ChecklistItem(
                      label: _phaseChecklistLabel(t, key),
                      checked: checklist[key] ?? false,
                      onTap: () =>
                          ref.read(checklistProvider.notifier).toggle(key),
                    )),
                const SizedBox(height: 28),
                if (phase.status == 'pending') ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.zap,
                            size: 20, color: AppColors.accent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            t.phaseReadyMsg,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  OxButton(
                    label: t.phaseStartButton,
                    icon: LucideIcons.play,
                    isLoading: startState is AsyncLoading,
                    onPressed: () => ref
                        .read(startPhaseProvider(phase.id).notifier)
                        .startPhase(),
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t.phaseEvidences,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          fontFamily: 'Inter',
                        ),
                      ),
                      Text(
                        t.phaseEvidenceCount(phase.evidences.length),
                        style: TextStyle(
                          color: phase.canSubmit
                              ? AppColors.accent
                              : AppColors.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (phase.evidences.isNotEmpty) ...[
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: phase.evidences.length,
                      itemBuilder: (ctx, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: phase.evidences[i].url,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: AppColors.surface2,
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: AppColors.surface2,
                                child: const Icon(LucideIcons.image,
                                    color: AppColors.textSecondary),
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Color(0xCC092F3D),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (['in_progress', 'evidence_uploaded', 'rejected']
                      .contains(phase.status))
                    GestureDetector(
                      onTap: () =>
                          context.push('/execution/${phase.id}/upload'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.4),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(LucideIcons.camera,
                                color: AppColors.accent, size: 28),
                            const SizedBox(height: 8),
                            Text(
                              t.phaseAddMedia,
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  if (phase.status != 'under_review')
                    OxButton(
                      label: t.phaseSubmitButton,
                      icon: LucideIcons.send,
                      isLoading: submitState is AsyncLoading,
                      onPressed: phase.canSubmit &&
                              phase.status == 'evidence_uploaded'
                          ? () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => const _SubmitConfirmDialog(),
                              );
                              if (confirm == true) {
                                ref
                                    .read(phaseSubmitProvider(phase.id).notifier)
                                    .submitForReview();
                              }
                            }
                          : null,
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.clock,
                              size: 18, color: AppColors.warning),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              t.phaseAwaitingReview,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (phase.status != 'under_review' && !phase.canSubmit)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        t.phaseAddMinPhotos,
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontFamily: 'Inter',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _phaseLabel(AppLocalizations t, String status) {
    switch (status) {
      case 'in_progress': return t.phaseStatusInProgress;
      case 'under_review': return t.phaseStatusUnderReview;
      case 'evidence_uploaded': return t.phaseStatusEvidenceUploaded;
      case 'validated': return t.phaseStatusValidated;
      case 'rejected': return t.phaseStatusRejected;
      default: return t.phaseStatusPending;
    }
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({
    required this.label,
    required this.checked,
    required this.onTap,
  });

  final String label;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: checked
              ? AppColors.accent.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                checked ? AppColors.accent.withValues(alpha: 0.3) : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            Icon(
              checked ? LucideIcons.checkSquare : LucideIcons.square,
              color: checked ? AppColors.accent : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: checked ? AppColors.textPrimary : AppColors.textSecondary,
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight:
                    checked ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoActivePhaseScreen extends StatelessWidget {
  const _NoActivePhaseScreen();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: OxEmptyState(
        icon: LucideIcons.zap,
        title: t.phaseNoActiveTitle,
        subtitle: t.phaseNoActiveSubtitle,
      ),
    );
  }
}

class _SubmitConfirmDialog extends StatelessWidget {
  const _SubmitConfirmDialog();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        t.phaseSubmitDialogTitle,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        t.phaseSubmitDialogContent,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontFamily: 'Inter',
          fontSize: 14,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(t.commonCancel,
              style: const TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.primary,
          ),
          child: Text(t.dialogSend,
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
