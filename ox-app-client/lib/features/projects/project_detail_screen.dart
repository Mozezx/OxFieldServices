import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ox_app_bar.dart';
import '../../core/widgets/ox_badge.dart';
import '../../core/widgets/ox_button.dart';
import 'project_provider.dart';

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

class ProjectDetailScreen extends ConsumerStatefulWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  bool _isSubmitting = false;

  Future<void> _submitForValidation() async {
    setState(() => _isSubmitting = true);
    await ref.read(projectsNotifierProvider.notifier).submitForValidation(widget.projectId);
    if (!mounted) return;
    final notifierState = ref.read(projectsNotifierProvider);
    if (notifierState.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar: ${notifierState.error}'),
          backgroundColor: AppColors.error,
        ),
      );
    } else {
      ref.invalidate(projectDetailProvider(widget.projectId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Projeto enviado para validação!')),
      );
    }
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(projectDetailProvider(widget.projectId));

    return Scaffold(
      appBar: const OxAppBar(title: 'Detalhes do Projeto'),
      body: projectAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (e, _) => Center(
          child: Text('Erro: $e', style: const TextStyle(color: AppColors.error)),
        ),
        data: (project) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OxBadge(
                    label: _statusLabel(project.status),
                    status: projectStatusToBadge(project.status),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Info card
              _InfoSection(project: project),
              const SizedBox(height: 24),

              // Draft submit section
              if (project.status == 'draft') ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(LucideIcons.send, size: 18, color: AppColors.accent),
                          SizedBox(width: 10),
                          Text(
                            'Rascunho salvo',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Inter',
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Este projeto está salvo como rascunho. Envie para validação para iniciar o processo de matching com trabalhadores.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 16),
                      OxButton(
                        label: 'Enviar para Validação',
                        icon: LucideIcons.send,
                        isLoading: _isSubmitting,
                        onPressed: _isSubmitting ? null : _submitForValidation,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Worker: assinar contrato
              if (project.workerNeedsToSign) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(LucideIcons.filePen, size: 18, color: AppColors.accent),
                          SizedBox(width: 10),
                          Text(
                            'Assinar Contrato',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Inter',
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Assine o contrato para confirmar sua participação neste projeto.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 16),
                      OxButton(
                        label: 'Assinar Contrato',
                        icon: LucideIcons.filePen,
                        isLoading: _isSubmitting,
                        onPressed: _isSubmitting
                            ? null
                            : () async {
                                setState(() => _isSubmitting = true);
                                await ref
                                    .read(projectsNotifierProvider.notifier)
                                    .signContract(project.contractId!, widget.projectId);
                                if (mounted) setState(() => _isSubmitting = false);
                              },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Phases
              const Text(
                'FASES',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 12),
              ...project.phases.map((phase) => _PhaseItem(
                    phase: phase,
                    onTap: () => context.push('/phases/${phase.id}'),
                    onValidate: ['under_review', 'evidence_uploaded'].contains(phase.status)
                        ? () => context.push('/phases/${phase.id}/validate')
                        : null,
                  )),

              const SizedBox(height: 24),

              if (project.needsPayment) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(LucideIcons.lock,
                              size: 18, color: AppColors.accent),
                          SizedBox(width: 10),
                          Text(
                            'Pagamento necessário',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Inter',
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'O trabalhador foi designado e aguarda o início. Pague para liberar a execução das fases.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 16),
                      OxButton(
                        label: 'Pagar e Iniciar Projeto',
                        icon: LucideIcons.creditCard,
                        onPressed: () =>
                            context.push('/payments/${project.contractId}'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Payment section
              _PaymentSection(project: project),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'draft': return 'Rascunho';
      case 'in_validation': return 'Em Validação';
      case 'in_execution': return 'Em Execução';
      case 'closed': return 'Concluído';
      case 'matched': return 'Match feito';
      case 'contract_signed': return 'Contrato assinado';
      case 'active_escrow': return 'Escrow ativo';
      case 'closing': return 'Encerrando';
      case 'rejected': return 'Rejeitado';
      default: return 'Aguardando match';
    }
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.project});
  final ProjectModel project;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    return Container(
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
            'INFORMAÇÕES',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 16),
          if (project.workerName != null)
            _InfoRow(icon: LucideIcons.user, label: 'Trabalhador', value: project.workerName!),
          _InfoRow(
            icon: LucideIcons.euro,
            label: 'Valor Total',
            value: '€ ${project.budget.toStringAsFixed(2)}',
          ),
          if (project.deadline != null)
            _InfoRow(
              icon: LucideIcons.calendar,
              label: 'Prazo',
              value: fmt.format(project.deadline!),
            ),
          _InfoRow(icon: LucideIcons.mapPin, label: 'Local', value: project.location),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

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
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseItem extends StatelessWidget {
  const _PhaseItem({required this.phase, this.onTap, this.onValidate});
  final ProjectPhaseModel phase;
  final VoidCallback? onTap;
  final VoidCallback? onValidate;

  @override
  Widget build(BuildContext context) {
    final isActive = ['under_review', 'evidence_uploaded', 'in_progress'].contains(phase.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surface2 : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.accent.withValues(alpha: 0.3) : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            _PhaseIcon(status: phase.status),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fase ${phase.order} — ${phase.name}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 4),
                  OxBadge(
                    label: _phaseStatusLabel(phase.status),
                    status: _phaseBadge(phase.status),
                  ),
                ],
              ),
            ),
            if (onValidate != null)
              TextButton(
                onPressed: onValidate,
                style: TextButton.styleFrom(foregroundColor: AppColors.accent),
                child: const Text(
                  'Validar',
                  style: TextStyle(fontSize: 13, fontFamily: 'Inter'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PhaseIcon extends StatelessWidget {
  const _PhaseIcon({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 'validated':
        return const Icon(LucideIcons.checkCircle2, color: AppColors.accent, size: 22);
      case 'under_review':
      case 'evidence_uploaded':
        return const Icon(LucideIcons.clock, color: AppColors.warning, size: 22);
      case 'rejected':
        return const Icon(LucideIcons.xCircle, color: AppColors.error, size: 22);
      case 'in_progress':
        return const Icon(LucideIcons.loader, color: AppColors.accent, size: 22);
      default:
        return const Icon(LucideIcons.circle, color: AppColors.textDisabled, size: 22);
    }
  }
}

class _PaymentSection extends StatelessWidget {
  const _PaymentSection({required this.project});
  final ProjectModel project;

  @override
  Widget build(BuildContext context) {
    final validatedAmount = project.phases
        .where((p) => p.status == 'validated')
        .fold(0.0, (sum, p) => sum + p.amount);

    return Container(
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
            'PAGAMENTO',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: LucideIcons.lock,
            label: 'Escrow',
            value: '€ ${project.budget.toStringAsFixed(2)} bloqueado',
          ),
          _InfoRow(
            icon: LucideIcons.checkCircle2,
            label: 'Liberado',
            value: '€ ${validatedAmount.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {},
            child: const Text(
               'Ver detalhes financeiros →',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
