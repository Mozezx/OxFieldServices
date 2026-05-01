import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ox_badge.dart';
import '../project_provider.dart';

String _statusLabel(String status) {
  switch (status) {
    case 'draft': return 'Rascunho';
    case 'in_validation': return 'Em Validação';
    case 'matched': return 'Match feito';
    case 'contract_signed': return 'Contrato assinado';
    case 'active_escrow': return 'Escrow ativo';
    case 'in_execution': return 'Em Execução';
    case 'closing': return 'Encerrando';
    case 'closed': return 'Concluído';
    case 'rejected': return 'Rejeitado';
    default: return 'Aguardando match';
  }
}

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project});

  final ProjectModel project;

  @override
  Widget build(BuildContext context) {
    final progress = project.phases.isEmpty
        ? 0.0
        : project.validatedPhases / project.phases.length;

    return GestureDetector(
      onTap: () => context.push('/projects/${project.id}'),
      child: Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    project.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                OxBadge(
                  label: _statusLabel(project.status),
                  status: projectStatusToBadge(project.status),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (project.phases.isNotEmpty) ...[
              LinearPercentIndicator(
                padding: EdgeInsets.zero,
                lineHeight: 6,
                percent: progress.clamp(0.0, 1.0),
                backgroundColor: AppColors.divider,
                progressColor: AppColors.accent,
                barRadius: const Radius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                'Fase ${project.validatedPhases}/${project.phases.length}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '€ ${project.budget.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontFamily: 'Inter',
                  ),
                ),
                if (project.deadline != null) ...[
                  const SizedBox(width: 12),
                  const Text(
                    '·',
                    style: TextStyle(color: AppColors.textDisabled),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${project.deadline!.difference(DateTime.now()).inDays} dias',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
