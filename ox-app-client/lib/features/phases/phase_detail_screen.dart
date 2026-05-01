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
                  'Fase ${phase.order} â€” ${phase.name}',
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
                    'â‚¬ ${phase.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ]),
                const SizedBox(height: 24),

                if (phase.evidences.isNotEmpty) ...[
                  const Text(
                    'EVIDÃŠNCIAS',
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
                    itemBuilder: (ctx, i) => ClipRRect(
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
                          'Nenhuma evidÃªncia enviada ainda',
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

  String _phaseStatusLabel(String status) {
    switch (status) {
      case 'validated': return 'Validada';
      case 'under_review': return 'Em revisÃ£o';
      case 'evidence_uploaded': return 'EvidÃªncias enviadas';
      case 'in_progress': return 'Em execuÃ§Ã£o';
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
