import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ox_app_bar.dart';
import '../../core/widgets/ox_badge.dart';
import '../../core/widgets/ox_button.dart';
import '../../core/widgets/ox_empty_state.dart';
import 'execution_provider.dart';

class PhaseExecutionScreen extends ConsumerWidget {
  const PhaseExecutionScreen({super.key, this.phaseId});

  final String? phaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (phaseId == null) {
      return const _NoActivePhaseScreen();
    }

    final phaseAsync = ref.watch(phaseExecutionProvider(phaseId));
    final checklist = ref.watch(checklistProvider);
    final submitState = ref.watch(phaseSubmitProvider);
    final startState = ref.watch(startPhaseProvider);

    ref.listen(phaseSubmitProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      } else if (next is AsyncData) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fase enviada para revisao do cliente!'),
            backgroundColor: AppColors.accent,
          ),
        );
        context.go('/home');
      }
    });

    ref.listen(startPhaseProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      } else if (next is AsyncData) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fase iniciada! Você pode subir as evidências.'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    });

    return Scaffold(
      appBar: const OxAppBar(title: 'Execucao da Fase'),
      body: phaseAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (e, _) => Center(
          child: Text('Erro: $e',
              style: const TextStyle(color: AppColors.error)),
        ),
        data: (phase) {
          if (phase == null) {
            return const _NoActivePhaseScreen();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Phase header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Fase ${phase.order} — ${phase.name}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    OxBadge(
                      label: _phaseLabel(phase.status),
                      status: phaseStatusToBadge(phase.status),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '€ ${phase.amount.toStringAsFixed(2)} nesta fase',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 28),

                // Checklist
                const Text(
                  'CHECKLIST DA FASE',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 12),
                ...checklist.entries.map((entry) => _ChecklistItem(
                      label: entry.key,
                      checked: entry.value,
                      onTap: () =>
                          ref.read(checklistProvider.notifier).toggle(entry.key),
                    )),

                const SizedBox(height: 28),

                if (phase.status == 'pending') ...[
                  // Fase ainda não iniciada — botão para iniciar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(LucideIcons.zap,
                            size: 20, color: AppColors.accent),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Pronto para começar? Inicie a fase para liberar o upload de evidências.',
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
                  const SizedBox(height: 16),
                  OxButton(
                    label: 'Iniciar Fase',
                    icon: LucideIcons.play,
                    isLoading: startState is AsyncLoading,
                    onPressed: () => ref
                        .read(startPhaseProvider.notifier)
                        .startPhase(phase.id),
                  ),
                ] else ...[
                  // Evidence upload
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'EVIDENCIAS',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          fontFamily: 'Inter',
                        ),
                      ),
                      Text(
                        '${phase.evidences.length}/3 obrigatorias',
                        style: TextStyle(
                          color: phase.canSubmit
                              ? AppColors.accent
                              : AppColors.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (phase.evidences.isNotEmpty) ...[
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: phase.evidences.length,
                      itemBuilder: (ctx, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              phase.evidences[i].url,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.surface2,
                                child: const Icon(LucideIcons.image,
                                    color: AppColors.textSecondary),
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Color(0xCC092F3D),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Upload button — apenas quando a fase aceita uploads
                  if (['in_progress', 'evidence_uploaded', 'rejected']
                      .contains(phase.status))
                    GestureDetector(
                      onTap: () =>
                          context.push('/execution/${phase.id}/upload'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.4),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: const Column(
                          children: [
                            Icon(LucideIcons.camera,
                                color: AppColors.accent, size: 28),
                            SizedBox(height: 8),
                            Text(
                              'Adicionar foto / video',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),

                  if (phase.status != 'under_review')
                    OxButton(
                      label: 'Enviar para Revisao',
                      icon: LucideIcons.send,
                      isLoading: submitState is AsyncLoading,
                      onPressed: phase.canSubmit &&
                              phase.status == 'evidence_uploaded'
                          ? () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => const _SubmitConfirmDialog(),
                              );
                              if (confirm == true) {
                                ref
                                    .read(phaseSubmitProvider.notifier)
                                    .submitForReview(phase.id);
                              }
                            }
                          : null,
                    )
                  else
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
                              size: 18, color: AppColors.warning),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Aguardando o cliente revisar e validar a fase.',
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
                  if (phase.status != 'under_review' && !phase.canSubmit)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Adicione pelo menos 3 fotos/videos para poder enviar',
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontFamily: 'Inter',
                        ),
                        textAlign: TextAlign.center,
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

  String _phaseLabel(String status) {
    switch (status) {
      case 'in_progress': return 'Em execucao';
      case 'under_review': return 'Em revisao';
      case 'evidence_uploaded': return 'Evidencias enviadas';
      case 'validated': return 'Validada';
      case 'rejected': return 'Rejeitada';
      default: return 'Pendente';
    }
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({
    required this.label,
    required this.checked,
    required this.onTap,
  });

  final String label;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: checked
              ? AppColors.accent.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                checked ? AppColors.accent.withValues(alpha: 0.3) : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            Icon(
              checked ? LucideIcons.checkSquare : LucideIcons.square,
              color: checked ? AppColors.accent : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: checked ? AppColors.textPrimary : AppColors.textSecondary,
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight:
                    checked ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoActivePhaseScreen extends StatelessWidget {
  const _NoActivePhaseScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: OxEmptyState(
        icon: LucideIcons.zap,
        title: 'Nenhuma fase em execucao',
        subtitle:
            'Aceite um job disponivel para comecar a executar suas fases.',
      ),
    );
  }
}

class _SubmitConfirmDialog extends StatelessWidget {
  const _SubmitConfirmDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text(
        'Enviar para Revisao',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
      ),
      content: const Text(
        'O cliente sera notificado para revisar as evidencias enviadas. Ao aprovar, o pagamento desta fase sera liberado para voce.',
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
          child: const Text('Enviar',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
