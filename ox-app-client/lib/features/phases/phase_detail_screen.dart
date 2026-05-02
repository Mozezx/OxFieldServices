import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ox_app_bar.dart';
import '../../core/widgets/ox_badge.dart';
import '../../core/widgets/ox_button.dart';
import 'phase_provider.dart';

class PhaseDetailScreen extends ConsumerWidget {
  const PhaseDetailScreen({super.key, required this.phaseId});

  final String phaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phaseAsync = ref.watch(phaseDetailProvider(phaseId));

    return Scaffold(
      appBar: const OxAppBar(title: 'Detalhes da Fase'),
      body: phaseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (e, _) => Center(
          child: Text('Erro: $e', style: const TextStyle(color: AppColors.error)),
        ),
        data: (phase) {
          final canValidate = ['under_review', 'evidence_uploaded'].contains(phase.status);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fase ${phase.order} — ${phase.name}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  OxBadge(
                    label: _phaseStatusLabel(phase.status),
                    status: _phaseBadge(phase.status),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '€ ${phase.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ]),
                const SizedBox(height: 24),

                if (phase.evidences.isNotEmpty) ...[
                  const Text(
                    'EVIDÊNCIAS',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: phase.evidences.length,
                    itemBuilder: (ctx, i) => GestureDetector(
                      onTap: () => _showFullscreen(context, phase.evidences[i].url),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          phase.evidences[i].url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.surface2,
                            child: const Icon(LucideIcons.image, color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else ...[
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
                        Icon(LucideIcons.image, color: AppColors.textDisabled, size: 40),
                        SizedBox(height: 8),
                        Text(
                          'Nenhuma evidência enviada ainda',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                if (canValidate)
                  OxButton(
                    label: 'Validar Fase',
                    icon: LucideIcons.checkCircle2,
                    onPressed: () => context.push('/phases/$phaseId/validate'),
                  ),
              ],
            ),
          );
        },
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
                  child: Image.network(url, fit: BoxFit.contain),
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

  String _phaseStatusLabel(String status) {
    switch (status) {
      case 'validated': return 'Validada';
      case 'under_review': return 'Em revisão';
      case 'evidence_uploaded': return 'Evidências enviadas';
      case 'in_progress': return 'Em execução';
      case 'rejected': return 'Rejeitada';
      default: return 'Pendente';
    }
  }

  OxBadgeStatus _phaseBadge(String status) {
    switch (status) {
      case 'validated': return OxBadgeStatus.active;
      case 'under_review':
      case 'evidence_uploaded': return OxBadgeStatus.pending;
      case 'rejected': return OxBadgeStatus.rejected;
      case 'in_progress': return OxBadgeStatus.inProgress;
      default: return OxBadgeStatus.neutral;
    }
  }
}
