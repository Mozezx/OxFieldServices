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
import '../../l10n/app_localizations.dart';

String _phaseStatusLabel(BuildContext context, String status) {
  final l = AppLocalizations.of(context)!;
  switch (status) {
    case 'validated': return l.phaseStatusValidated;
    case 'under_review': return l.phaseStatusUnderReview;
    case 'evidence_uploaded': return l.phaseStatusEvidenceUploaded;
    case 'in_progress': return l.phaseStatusInProgress;
    case 'rejected': return l.phaseStatusRejected;
    default: return l.phaseStatusPending;
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
  String _statusLabel(AppLocalizations l, String status) {
    switch (status) {
      case 'draft': return l.statusDraft;
      case 'in_execution': return l.statusInExecution;
      case 'closed': return l.statusClosed;
      case 'matched': return l.statusMatched;
      case 'contract_signed': return l.statusContractSigned;
      case 'active_escrow': return l.statusActiveEscrow;
      case 'closing': return l.statusClosing;
      case 'rejected': return l.statusRejected;
      default: return l.statusAwaitingMatch;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final projectAsync = ref.watch(projectDetailProvider(widget.projectId));

    return Scaffold(
      appBar: OxAppBar(title: l.projectDetailTitle),
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
                    label: _statusLabel(l, project.status),
                    status: projectStatusToBadge(project.status),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _InfoSection(project: project),
              const SizedBox(height: 24),

              Text(
                l.projectDetailPhasesSection,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 12),
              ...project.phases.map((phase) {
                final canValidate = ['under_review', 'evidence_uploaded'].contains(phase.status);
                return _PhaseItem(
                  phase: phase,
                  onTap: () => context.push(
                    canValidate ? '/phases/${phase.id}/validate' : '/phases/${phase.id}',
                  ),
                  onValidate: canValidate ? () => context.push('/phases/${phase.id}/validate') : null,
                );
              }),

              const SizedBox(height: 24),

              if (project.canRateWorker) ...[
                _RateWorkerPanel(projectId: widget.projectId),
                const SizedBox(height: 24),
              ] else if (project.myRating != null) ...[
                _RatedWorkerSummary(rating: project.myRating!),
                const SizedBox(height: 24),
              ],

              if (project.needsPayment) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.lock, size: 18, color: AppColors.accent),
                          const SizedBox(width: 10),
                          Text(
                            l.projectPaymentRequired,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Inter',
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.projectPaymentRequiredDescription,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 16),
                      OxButton(
                        label: l.projectPayButton,
                        icon: LucideIcons.creditCard,
                        onPressed: () {
                          final pid = widget.projectId;
                          context
                              .push<String?>(
                                '/payments/${project.contractId}?projectId=${project.id}',
                              )
                              .then((_) {
                            if (!context.mounted) return;
                            ref.invalidate(projectDetailProvider(pid));
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              _PaymentSection(project: project),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.project});
  final ProjectModel project;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
          Text(
            l.projectDetailInfoSection,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 16),
          if (project.workerName != null)
            _InfoRow(icon: LucideIcons.user, label: l.projectDetailWorker, value: project.workerName!),
          _InfoRow(
            icon: LucideIcons.euro,
            label: l.projectDetailBudget,
            value: '€ ${project.budget.toStringAsFixed(2)}',
          ),
          if (project.deadline != null)
            _InfoRow(
              icon: LucideIcons.calendar,
              label: l.projectDetailDeadline,
              value: fmt.format(project.deadline!),
            ),
          _InfoRow(icon: LucideIcons.mapPin, label: l.projectDetailLocation, value: project.location),
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
    final l = AppLocalizations.of(context)!;
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
                    l.projectPhaseLabel(phase.order, phase.name),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 4),
                  OxBadge(
                    label: _phaseStatusLabel(context, phase.status),
                    status: _phaseBadge(phase.status),
                  ),
                ],
              ),
            ),
            if (onValidate != null)
              TextButton(
                onPressed: onValidate,
                style: TextButton.styleFrom(foregroundColor: AppColors.accent),
                child: Text(
                  l.phaseValidateButton,
                  style: const TextStyle(fontSize: 13, fontFamily: 'Inter'),
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

class _RateWorkerPanel extends ConsumerStatefulWidget {
  const _RateWorkerPanel({required this.projectId});

  final String projectId;

  @override
  ConsumerState<_RateWorkerPanel> createState() => _RateWorkerPanelState();
}

class _RateWorkerPanelState extends ConsumerState<_RateWorkerPanel> {
  int _score = 5;
  final _feedbackCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(AppLocalizations l) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await submitProjectRating(
        ref,
        projectId: widget.projectId,
        score: _score,
        feedback: _feedbackCtrl.text,
      );
    } catch (e, _) {
      final msg = dioErrorUserMessage(e) ?? e.toString();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.projectRateWorkerError(msg))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.projectRateWorkerSection,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l.projectRateWorkerSubtitle,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(5, (i) {
              final n = i + 1;
              final filled = n <= _score;
              return IconButton(
                onPressed: _submitting
                    ? null
                    : () => setState(() => _score = n),
                icon: Icon(
                  LucideIcons.star,
                  color: filled ? AppColors.warning : AppColors.textDisabled,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _feedbackCtrl,
            maxLines: 3,
            enabled: !_submitting,
            style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Inter', fontSize: 14),
            decoration: InputDecoration(
              labelText: l.projectRateWorkerFeedbackLabel,
              labelStyle: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter'),
              filled: true,
              fillColor: AppColors.surface2,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          OxButton(
            label: l.projectRateWorkerSubmit,
            icon: LucideIcons.send,
            isLoading: _submitting,
            onPressed: _submitting ? null : () => _submit(l),
          ),
        ],
      ),
    );
  }
}

class _RatedWorkerSummary extends StatelessWidget {
  const _RatedWorkerSummary({required this.rating});

  final ClientRating rating;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
          Text(
            l.projectRateWorkerSection,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l.projectRateWorkerThanks,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ...List.generate(5, (i) {
                final n = i + 1;
                return Icon(
                  LucideIcons.star,
                  size: 20,
                  color: n <= rating.score ? AppColors.warning : AppColors.textDisabled,
                );
              }),
              const SizedBox(width: 8),
              Text(
                l.projectRateWorkerYourScore(rating.score),
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontFamily: 'Inter'),
              ),
            ],
          ),
          if (rating.feedback != null && rating.feedback!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              rating.feedback!.trim(),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontFamily: 'Inter'),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentSection extends StatelessWidget {
  const _PaymentSection({required this.project});
  final ProjectModel project;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
          Text(
            l.projectDetailPaymentSection,
            style: const TextStyle(
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
            label: l.projectEscrowLabel,
            value: l.projectEscrowValue(project.budget.toStringAsFixed(2)),
          ),
          _InfoRow(
            icon: LucideIcons.checkCircle2,
            label: l.projectReleasedLabel,
            value: '€ ${validatedAmount.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {},
            child: Text(
              l.projectViewFinancials,
              style: const TextStyle(
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
