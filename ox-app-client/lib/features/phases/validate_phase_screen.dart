import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ox_app_bar.dart';
import '../../core/widgets/ox_button.dart';
import 'phase_provider.dart';
import '../../l10n/app_localizations.dart';

class ValidatePhaseScreen extends ConsumerWidget {
  const ValidatePhaseScreen({super.key, required this.phaseId});

  final String phaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final phaseAsync = ref.watch(phaseDetailProvider(phaseId));
    final validationState = ref.watch(phaseValidationProvider);

    ref.listen(phaseValidationProvider, (previous, next) {
      final isValidationRequest = previous is AsyncLoading;
      if (isValidationRequest && next is AsyncData) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.validatePhaseSuccess),
            backgroundColor: AppColors.accent,
          ),
        );
        context.pop();
        context.pop();
      }
      if (isValidationRequest && next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: OxAppBar(title: l.validatePhaseTitle),
      body: phaseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (e, _) => Center(child: Text('Erro: $e', style: const TextStyle(color: AppColors.error))),
        data: (phase) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.validatePhaseDetailTitle(phase.order, phase.name),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 24),

              Text(
                l.validatePhaseEvidenceSection,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 12),
              if (phase.evidences.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    children: [
                      const Icon(LucideIcons.alertCircle, color: AppColors.warning, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        l.validatePhaseNoEvidence,
                        style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter'),
                      ),
                    ],
                  ),
                )
              else if (phase.evidences.length == 1)
                Center(
                  child: GestureDetector(
                    onTap: () => _showFullscreen(context, phase.evidences.first.url),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 240,
                        height: 180,
                        child: CachedNetworkImage(
                          imageUrl: phase.evidences.first.url,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppColors.surface2,
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.surface2,
                            child: const Icon(LucideIcons.image, color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: phase.evidences.length,
                  itemBuilder: (ctx, i) => GestureDetector(
                    onTap: () => _showFullscreen(context, phase.evidences[i].url),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
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
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.surface2,
                              child: const Icon(LucideIcons.image, color: AppColors.textSecondary),
                            ),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Color(0x80092F3D)],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.info, size: 18, color: AppColors.accent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l.validatePhaseAmountWarning(phase.amount.toStringAsFixed(2)),
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
              const SizedBox(height: 24),

              OxButton(
                label: l.validatePhaseApproveAction,
                isLoading: validationState is AsyncLoading,
                onPressed: phase.evidences.isEmpty
                    ? null
                    : () => _confirmValidation(context, ref, true),
              ),
              const SizedBox(height: 12),
              OxButton(
                label: l.validatePhaseRejectAction,
                variant: OxButtonVariant.danger,
                isLoading: validationState is AsyncLoading,
                onPressed: () => _confirmValidation(context, ref, false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullscreen(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: SizedBox.expand(
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                    errorWidget: (_, __, ___) => const Icon(
                      LucideIcons.image,
                      color: Colors.white54,
                      size: 48,
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Material(
                      color: Colors.black54,
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: const Icon(LucideIcons.x, color: Colors.white),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmValidation(BuildContext context, WidgetRef ref, bool approved) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          approved ? l.validatePhaseApproveConfirmTitle : l.validatePhaseRejectConfirmTitle,
          style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Inter'),
        ),
        content: Text(
          approved ? l.validatePhaseApproveConfirmBody : l.validatePhaseRejectConfirmBody,
          style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.commonCancel,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              approved ? l.validatePhaseApproveButton : l.validatePhaseRejectButton,
              style: TextStyle(
                color: approved ? AppColors.accent : AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(phaseValidationProvider.notifier).validate(phaseId, approved);
    }
  }
}
