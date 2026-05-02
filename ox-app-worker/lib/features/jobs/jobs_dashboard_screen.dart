import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ox_app_bar.dart';
import '../../core/widgets/ox_badge.dart';
import '../../core/widgets/ox_button.dart';
import '../../core/widgets/ox_empty_state.dart';
import '../../core/widgets/ox_loading.dart';
import '../profile/profile_provider.dart';
import 'jobs_provider.dart';

class JobsDashboardScreen extends ConsumerWidget {
  const JobsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableAsync = ref.watch(availableJobsProvider);
    final activeAsync = ref.watch(activeJobsProvider);
    final workerAsync = ref.watch(workerProfileProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final name = user?.email?.split('@').first ?? 'Trabalhador';

    return Scaffold(
      appBar: OxAppBar(
        showLogo: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.accent.withValues(alpha: 0.15),
              child: Text(
                name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.bell, size: 20),
            color: AppColors.textSecondary,
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () async {
          ref.invalidate(availableJobsProvider);
          ref.invalidate(activeJobsProvider);
          ref.invalidate(workerProfileProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Worker status card
              _WorkerStatusCard(workerAsync: workerAsync),
              const SizedBox(height: 28),

              // Active jobs
              const Text(
                'MEUS JOBS ATIVOS',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 12),
              activeAsync.when(
                loading: () => const OxJobCardSkeleton(),
                error: (_, __) => const SizedBox.shrink(),
                data: (jobs) => jobs.isEmpty
                    ? const OxEmptyState(
                        icon: LucideIcons.zap,
                        title: 'Nenhum job ativo',
                        subtitle: 'Aceite um job disponivel para comecar.',
                      )
                    : Column(
                        children: jobs
                            .map((j) => _ActiveJobCard(job: j))
                            .toList(),
                      ),
              ),

              const SizedBox(height: 28),

              // Available jobs
              const Text(
                'JOBS DISPONIVEIS PARA VOCE',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 12),
              availableAsync.when(
                loading: () => Column(
                  children: List.generate(
                      2, (_) => const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: OxJobCardSkeleton(),
                      )),
                ),
                error: (_, __) => const Center(
                  child: Text(
                    'Erro ao carregar jobs',
                    style: TextStyle(
                        color: AppColors.error, fontFamily: 'Inter'),
                  ),
                ),
                data: (jobs) => jobs.isEmpty
                    ? const OxEmptyState(
                        icon: LucideIcons.briefcase,
                        title: 'Sem jobs disponiveis',
                        subtitle:
                            'Novos projetos aparecerão aqui quando houver compatibilidade com o seu perfil.',
                      )
                    : Column(
                        children: jobs
                            .map((j) => _AvailableJobCard(job: j))
                            .toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkerStatusCard extends ConsumerWidget {
  const _WorkerStatusCard({required this.workerAsync});

  final AsyncValue<WorkerProfileModel?> workerAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                workerAsync.when(
                  loading: () => const OxShimmerBox(width: 80, height: 14),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (w) => Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: (w?.available ?? false)
                              ? AppColors.accent
                              : AppColors.textDisabled,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        (w?.available ?? false) ? 'Disponivel' : 'Indisponivel',
                        style: TextStyle(
                          color: (w?.available ?? false)
                              ? AppColors.accent
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                workerAsync.when(
                  loading: () => const OxShimmerBox(width: 100, height: 12),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (w) => Row(
                    children: [
                      const Icon(LucideIcons.star,
                          size: 14, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        'Avaliacao: ${w?.rating.toStringAsFixed(1) ?? '-'}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontFamily: 'Inter',
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          workerAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (w) => GestureDetector(
              onTap: () => ref
                  .read(workerProfileNotifierProvider.notifier)
                  .toggleAvailability(!(w?.available ?? false)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52,
                height: 28,
                decoration: BoxDecoration(
                  color: (w?.available ?? false)
                      ? AppColors.accent
                      : AppColors.divider,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Align(
                  alignment: (w?.available ?? false)
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: AppColors.textPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveJobCard extends StatelessWidget {
  const _ActiveJobCard({required this.job});

  final JobModel job;

  @override
  Widget build(BuildContext context) {
    final activePhase = job.activePhase;

    return GestureDetector(
      onTap: () => context.push('/jobs/${job.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                OxBadge(
                  label: _jobStatusLabel(job.status),
                  status: phaseStatusToBadge(job.status),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(LucideIcons.mapPin,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  job.location,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            if (activePhase != null) ...[
              const SizedBox(height: 12),
              Text(
                'Fase ${activePhase.order} — ${activePhase.name}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontFamily: 'Inter',
                ),
              ),
            ],
            const SizedBox(height: 16),
            OxButton(
              label: 'Continuar execucao',
              icon: LucideIcons.zap,
              onPressed: activePhase != null
                  ? () => context.push('/execution/${activePhase.id}')
                  : () => context.push('/jobs/${job.id}'),
            ),
          ],
        ),
      ),
    );
  }

  String _jobStatusLabel(String status) {
    switch (status) {
      case 'in_execution': return 'Em execucao';
      case 'active_escrow': return 'Escrow ativo';
      case 'contract_signed': return 'Contrato assinado';
      default: return status;
    }
  }
}

class _AvailableJobCard extends StatelessWidget {
  const _AvailableJobCard({required this.job});

  final JobModel job;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    final matchScore = job.matchScore ?? 85;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            job.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(LucideIcons.mapPin,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                job.location,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(width: 16),
              const Icon(LucideIcons.euro,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                job.budget.toStringAsFixed(0),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontFamily: 'Inter',
                ),
              ),
              if (job.deadline != null) ...[
                const SizedBox(width: 16),
                const Icon(LucideIcons.calendar,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  fmt.format(job.deadline!),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Match score
          Row(
            children: [
              const Text(
                'Compatibilidade: ',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: matchScore / 100,
                  backgroundColor: AppColors.divider,
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$matchScore%',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OxButton(
            label: 'Ver detalhes',
            variant: OxButtonVariant.secondary,
            onPressed: () => context.push('/jobs/${job.id}'),
          ),
        ],
      ),
    );
  }
}
