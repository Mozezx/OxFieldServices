import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ox_app_bar.dart';
import '../../core/widgets/ox_badge.dart';
import '../../core/widgets/ox_empty_state.dart';
import '../../core/widgets/ox_loading.dart';
import '../jobs/jobs_provider.dart';
import 'execution_provider.dart';

/// Tela da aba "Em Execução" — lista todas as fases ativas dos jobs do worker
/// agrupadas por job. Tap → abre a tela de execução da fase.
class ExecutionDashboardScreen extends ConsumerWidget {
  const ExecutionDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(activePhasesProvider);

    return Scaffold(
      appBar: const OxAppBar(title: 'Em Execução'),
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () async {
          ref.invalidate(activeJobsProvider);
          ref.invalidate(activePhasesProvider);
        },
        child: groupsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                OxJobCardSkeleton(),
                SizedBox(height: 12),
                OxJobCardSkeleton(),
              ],
            ),
          ),
          error: (e, _) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Center(
                child: Text(
                  'Erro ao carregar fases: $e',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ),
          ),
          data: (groups) {
            if (groups.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 80),
                  OxEmptyState(
                    icon: LucideIcons.zap,
                    title: 'Nenhuma fase em execução',
                    subtitle:
                        'Quando você aceitar um job e o cliente pagar, suas fases aparecerão aqui para você executar.',
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              itemCount: groups.length,
              itemBuilder: (ctx, i) => _JobGroupCard(group: groups[i]),
            );
          },
        ),
      ),
    );
  }
}

class _JobGroupCard extends StatelessWidget {
  const _JobGroupCard({required this.group});
  final JobPhasesGroup group;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.job.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(LucideIcons.mapPin,
                              size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            group.job.location,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.divider, height: 1),
          // Phases
          ...group.activePhases
              .map((p) => _PhaseTile(job: group.job, phase: p)),
        ],
      ),
    );
  }
}

class _PhaseTile extends StatelessWidget {
  const _PhaseTile({required this.job, required this.phase});
  final JobModel job;
  final JobPhaseModel phase;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/execution/${phase.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                '${phase.order}',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    phase.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      OxBadge(
                        label: _phaseStatusLabel(phase.status),
                        status: phaseStatusToBadge(phase.status),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '€ ${phase.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
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

String _phaseStatusLabel(String status) {
  switch (status) {
    case 'in_progress':
      return 'Em execução';
    case 'evidence_uploaded':
      return 'Evidências enviadas';
    case 'under_review':
      return 'Em revisão';
    case 'rejected':
      return 'Rejeitada';
    case 'pending':
    default:
      return 'Aguardando início';
  }
}
