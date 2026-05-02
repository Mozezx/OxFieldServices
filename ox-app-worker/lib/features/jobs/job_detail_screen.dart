import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ox_app_bar.dart';
import '../../core/widgets/ox_badge.dart';
import '../../core/widgets/ox_button.dart';
import 'jobs_provider.dart';

class JobDetailScreen extends ConsumerWidget {
  const JobDetailScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(jobDetailProvider(projectId));
    final actionState = ref.watch(jobActionProvider);

    ref.listen(jobActionProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      } else if (next is AsyncData && next.value == null) {
        // ignore initial
      } else if (next is AsyncData) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job aceito com sucesso!'),
            backgroundColor: AppColors.accent,
          ),
        );
        context.go('/home');
      }
    });

    return Scaffold(
      appBar: const OxAppBar(title: 'Detalhes do Job'),
      body: jobAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (e, _) => Center(
          child: Text('Erro: $e',
              style: const TextStyle(color: AppColors.error)),
        ),
        data: (job) {
          final fmt = DateFormat('dd/MM/yyyy');
          final canAccept = job.canAccept;
          final isActive = job.isExecuting;
          final awaitingPayment = job.awaitingPayment;
          final awaitingStart = job.awaitingStart;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  job.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(LucideIcons.mapPin,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      job.location,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Info card
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
                      const Text(
                        'INFORMACOES',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (job.deadline != null)
                        _InfoRow(
                          icon: LucideIcons.calendar,
                          label: 'Prazo',
                          value: fmt.format(job.deadline!),
                        ),
                      _InfoRow(
                        icon: LucideIcons.mapPin,
                        label: 'Local',
                        value: job.location,
                      ),
                      if (job.description != null)
                        _InfoRow(
                          icon: LucideIcons.fileText,
                          label: 'Descricao',
                          value: job.description!,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Phases & payments
                const Text(
                  'FASES E PAGAMENTOS',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 12),
                ...job.phases.map((phase) => _PhaseRow(phase: phase)),
                const Divider(color: AppColors.divider),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '€ ${job.budget.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                if (isActive) ...[
                  OxButton(
                    label: 'Continuar execucao',
                    icon: LucideIcons.zap,
                    onPressed: job.activePhase != null
                        ? () =>
                            context.push('/execution/${job.activePhase!.id}')
                        : null,
                  ),
                ] else if (canAccept) ...[
                  OxButton(
                    label: 'Aceitar Job',
                    icon: LucideIcons.checkCircle2,
                    isLoading: actionState is AsyncLoading,
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => const _AcceptConfirmDialog(),
                      );
                      if (confirm == true) {
                        ref
                            .read(jobActionProvider.notifier)
                            .acceptJob(projectId);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  OxButton(
                    label: 'Recusar',
                    variant: OxButtonVariant.danger,
                    onPressed: () {
                      ref.read(jobActionProvider.notifier).declineJob(projectId);
                      context.pop();
                    },
                  ),
                ] else if (awaitingPayment) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(LucideIcons.clock,
                            color: AppColors.warning, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Contrato assinado. Aguardando o cliente efetuar o pagamento para iniciar a execução.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (awaitingStart) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(LucideIcons.zap,
                            color: AppColors.accent, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Pagamento confirmado! O projeto será ativado em breve e as fases aparecerão na aba "Em Execução".',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
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
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontFamily: 'Inter'),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseRow extends StatelessWidget {
  const _PhaseRow({required this.phase});
  final JobPhaseModel phase;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          OxBadge(
            label: 'Fase ${phase.order}',
            status: phaseStatusToBadge(phase.status),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              phase.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
          ),
          Text(
            '€ ${phase.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

class _AcceptConfirmDialog extends StatelessWidget {
  const _AcceptConfirmDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text(
        'Aceitar Job',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
      ),
      content: const Text(
        'Ao aceitar, voce se compromete a executar todas as fases conforme acordado. Deseja continuar?',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontFamily: 'Inter',
          fontSize: 14,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.primary,
          ),
          child: const Text('Aceitar',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
