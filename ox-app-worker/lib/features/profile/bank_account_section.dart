import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ox_button.dart';
import '../../core/widgets/ox_loading.dart';
import 'stripe_connect_provider.dart';

/// Seção do perfil do worker para gerenciar a conta de recebimento (Stripe Connect).
/// Detecta automaticamente o estado da conta e mostra o CTA apropriado.
class BankAccountSection extends ConsumerStatefulWidget {
  const BankAccountSection({super.key});

  @override
  ConsumerState<BankAccountSection> createState() =>
      _BankAccountSectionState();
}

class _BankAccountSectionState extends ConsumerState<BankAccountSection>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Ao retornar do navegador (onde concluiu o onboarding), refresh o status
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(connectStatusProvider);
    }
  }

  Future<void> _openUrl(BuildContext context, String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o link de onboarding'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(connectStatusProvider);
    final actionState = ref.watch(connectActionProvider);
    final isLoading = actionState is AsyncLoading;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: statusAsync.when(
        loading: () => const OxShimmerBox(
          width: double.infinity,
          height: 80,
          borderRadius: 12,
        ),
        error: (e, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Header(),
            const SizedBox(height: 12),
            Text(
              'Erro ao verificar status: $e',
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
            const SizedBox(height: 12),
            OxButton(
              label: 'Tentar novamente',
              variant: OxButtonVariant.secondary,
              onPressed: () => ref.invalidate(connectStatusProvider),
            ),
          ],
        ),
        data: (status) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Header(),
            const SizedBox(height: 16),
            _StatusBadge(status: status.status),
            const SizedBox(height: 16),
            ..._buildContent(context, status, isLoading),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContent(
      BuildContext context, ConnectStatus status, bool isLoading) {
    switch (status.status) {
      case 'not_started':
        return [
          const Text(
            'Configure sua conta Stripe para receber pagamentos pelos jobs concluídos.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 16),
          OxButton(
            label: 'Configurar agora',
            icon: LucideIcons.creditCard,
            isLoading: isLoading,
            onPressed: () async {
              final url = await ref
                  .read(connectActionProvider.notifier)
                  .openOnboarding();
              if (context.mounted) await _openUrl(context, url);
            },
          ),
        ];

      case 'pending':
        return [
          const Text(
            'Sua conta foi criada, mas algumas informações ainda são necessárias para começar a receber:',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontFamily: 'Inter',
            ),
          ),
          if (status.currentlyDue.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...status.currentlyDue.take(5).map(
                  (req) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(LucideIcons.dot,
                            size: 14, color: AppColors.warning),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _humanizeRequirement(req),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
          const SizedBox(height: 16),
          OxButton(
            label: 'Continuar cadastro',
            icon: LucideIcons.externalLink,
            isLoading: isLoading,
            onPressed: () async {
              final url = await ref
                  .read(connectActionProvider.notifier)
                  .reopenOnboarding();
              if (context.mounted) await _openUrl(context, url);
            },
          ),
        ];

      case 'active':
        return [
          if (status.bankAccount != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.landmark,
                      size: 20, color: AppColors.accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status.bankAccount!.bankName ?? 'Conta bancária',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '•••• ${status.bankAccount!.last4} · ${status.bankAccount!.currency}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          const Text(
            'Pagamentos são depositados em até 2 dias úteis após cada fase ser validada pelo cliente.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 16),
          OxButton(
            label: 'Atualizar dados bancários',
            variant: OxButtonVariant.secondary,
            icon: LucideIcons.settings,
            isLoading: isLoading,
            onPressed: () async {
              final url = await ref
                  .read(connectActionProvider.notifier)
                  .reopenOnboarding();
              if (context.mounted) await _openUrl(context, url);
            },
          ),
        ];

      case 'restricted':
      default:
        return [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.disabledReason ?? 'Há pendências bloqueando os recebimentos.',
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                if (status.pastDue.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...status.pastDue.take(5).map(
                        (req) => Text(
                          '• ${_humanizeRequirement(req)}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          OxButton(
            label: 'Resolver pendências',
            icon: LucideIcons.externalLink,
            isLoading: isLoading,
            onPressed: () async {
              final url = await ref
                  .read(connectActionProvider.notifier)
                  .reopenOnboarding();
              if (context.mounted) await _openUrl(context, url);
            },
          ),
        ];
    }
  }

  String _humanizeRequirement(String key) {
    switch (key) {
      case 'individual.first_name':
      case 'individual.last_name':
        return 'Nome completo';
      case 'individual.dob.day':
      case 'individual.dob.month':
      case 'individual.dob.year':
        return 'Data de nascimento';
      case 'individual.id_number':
      case 'individual.ssn_last_4':
        return 'Documento de identidade';
      case 'individual.address.line1':
      case 'individual.address.city':
      case 'individual.address.postal_code':
        return 'Endereço residencial';
      case 'external_account':
        return 'Dados bancários (IBAN ou conta)';
      case 'tos_acceptance.date':
      case 'tos_acceptance.ip':
        return 'Aceitar termos da Stripe';
      case 'business_profile.url':
      case 'business_profile.mcc':
        return 'Perfil profissional';
      default:
        return key.replaceAll('_', ' ').replaceAll('.', ' › ');
    }
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(LucideIcons.landmark, size: 18, color: AppColors.accent),
        SizedBox(width: 10),
        Text(
          'CONTA DE RECEBIMENTO',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'active' => ('Ativo', AppColors.accent),
      'pending' => ('Em verificação', AppColors.warning),
      'restricted' => ('Suspenso', AppColors.error),
      _ => ('Não configurado', AppColors.textDisabled),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
