import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ox_app_bar.dart';
import '../../core/widgets/ox_button.dart';
import 'phase_provider.dart';

class ValidatePhaseScreen extends ConsumerWidget {
  const ValidatePhaseScreen({super.key, required this.phaseId});

  final String phaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phaseAsync = ref.watch(phaseDetailProvider(phaseId));
    final validationState = ref.watch(phaseValidationProvider);

    ref.listen(phaseValidationProvider, (_, next) {
      if (next is AsyncData) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fase validada com sucesso!'),
            backgroundColor: AppColors.accent,
          ),
        );
        context.pop();
        context.pop();
      }
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: const OxAppBar(title: 'Validar Fase'),
      body: phaseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (e, _) => Center(child: Text('Erro: $e', style: const TextStyle(color: AppColors.error))),
        data: (phase) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Validar â€” Fase ${phase.order}: ${phase.name}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 24),

              // Evidence section
              const Text(
                'EVIDÃŠNCIAS DO TRABALHADOR',
                style: TextStyle(
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
                  child: const Column(
                    children: [
                      Icon(LucideIcons.alertCircle, color: AppColors.warning, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'Nenhuma evidÃªncia enviada',
                        style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter'),
                      ),
                    ],
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
                          Image.network(
                            phase.evidences[i].url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
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

              // Warning
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
                        'Ao aprovar, â‚¬ ${phase.amount.toStringAsFixed(2)} serÃ¡ liberado ao trabalhador.',
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
                label: 'âœ“ Aprovar Fase',
                isLoading: validationState is AsyncLoading,
                onPressed: phase.evidences.isEmpty
                    ? null
                    : () => _confirmValidation(context, ref, true),
              ),
              const SizedBox(height: 12),
              OxButton(
                label: 'âœ— Rejeitar Fase',
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
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(child: Image.network(url, fit: BoxFit.contain)),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(LucideIcons.x, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmValidation(BuildContext context, WidgetRef ref, bool approved) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          approved ? 'Aprovar Fase?' : 'Rejeitar Fase?',
          style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Inter'),
        ),
        content: Text(
          approved
              ? 'O pagamento da fase serÃ¡ liberado ao trabalhador.'
              : 'O trabalhador deverÃ¡ reenviar as evidÃªncias.',
          style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              approved ? 'Aprovar' : 'Rejeitar',
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
