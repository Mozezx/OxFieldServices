import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ox_app_bar.dart';
import '../../core/widgets/ox_button.dart';
import '../../core/widgets/ox_input.dart';
import 'project_provider.dart';

class CreateProjectScreen extends ConsumerStatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  ConsumerState<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  int _step = 0;
  bool _pendingSubmit = false;
  final _formKey1 = GlobalKey<FormState>();

  // Step 1
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  DateTime? _deadline;

  // Step 2
  final List<Map<String, dynamic>> _phases = [];
  final _phaseNameCtrl = TextEditingController();
  final _phaseAmountCtrl = TextEditingController();

  CreateProjectInput get _input => CreateProjectInput(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        budget: double.tryParse(_budgetCtrl.text) ?? 0,
        deadline: _deadline,
        phases: _phases,
      );

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _budgetCtrl.dispose();
    _phaseNameCtrl.dispose();
    _phaseAmountCtrl.dispose();
    super.dispose();
  }

  void _addPhase() {
    if (_phaseNameCtrl.text.trim().isEmpty) return;
    setState(() {
      _phases.add({
        'name': _phaseNameCtrl.text.trim(),
        'amount': double.tryParse(_phaseAmountCtrl.text) ?? 0,
        'order': _phases.length + 1,
      });
      _phaseNameCtrl.clear();
      _phaseAmountCtrl.clear();
    });
  }

  void _removePhase(int i) => setState(() => _phases.removeAt(i));

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(projectsNotifierProvider);

    ref.listen(projectsNotifierProvider, (_, next) {
      if (next is AsyncData && _step == 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_pendingSubmit ? 'Projeto enviado para validação!' : 'Rascunho salvo!')),
        );
        context.pop();
      }
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

      return Scaffold(
        appBar: OxAppBar(title: 'Novo Projeto — Etapa ${_step + 1}/3'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: [
            _StepBasicInfo(
              formKey: _formKey1,
              titleCtrl: _titleCtrl,
              descCtrl: _descCtrl,
              locationCtrl: _locationCtrl,
              budgetCtrl: _budgetCtrl,
              deadline: _deadline,
              onDeadlineChanged: (d) => setState(() => _deadline = d),
              onNext: () {
                if (_formKey1.currentState!.validate()) setState(() => _step = 1);
              },
            ),
            _StepPhases(
              phases: _phases,
              nameCtrl: _phaseNameCtrl,
              amountCtrl: _phaseAmountCtrl,
              onAddPhase: _addPhase,
              onRemovePhase: _removePhase,
              onBack: () => setState(() => _step = 0),
              onNext: () => setState(() => _step = 2),
            ),
            _StepReview(
              title: _titleCtrl.text,
              location: _locationCtrl.text,
              budget: double.tryParse(_budgetCtrl.text) ?? 0,
              phases: _phases,
              isLoading: notifier is AsyncLoading,
              onBack: () => setState(() => _step = 1),
              onSaveDraft: () {
                setState(() => _pendingSubmit = false);
                ref.read(projectsNotifierProvider.notifier).create(_input);
              },
              onSendForValidation: () {
                setState(() => _pendingSubmit = true);
                ref.read(projectsNotifierProvider.notifier).createAndSubmit(_input);
              },
            ),
          ][_step],
        ),
      );
  }
}

class _StepBasicInfo extends StatelessWidget {
  const _StepBasicInfo({
    required this.formKey,
    required this.titleCtrl,
    required this.descCtrl,
    required this.locationCtrl,
    required this.budgetCtrl,
    required this.deadline,
    required this.onDeadlineChanged,
    required this.onNext,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;
  final TextEditingController locationCtrl;
  final TextEditingController budgetCtrl;
  final DateTime? deadline;
  final void Function(DateTime?) onDeadlineChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informações Básicas',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 24),
          OxInput(
            label: 'Título do projeto',
            controller: titleCtrl,
            prefixIcon: LucideIcons.fileText,
            validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
          ),
          const SizedBox(height: 16),
          OxInput(
            label: 'Descrição',
            controller: descCtrl,
            maxLines: 3,
            validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
          ),
          const SizedBox(height: 16),
          OxInput(
            label: 'Localização',
            controller: locationCtrl,
            prefixIcon: LucideIcons.mapPin,
            validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
          ),
          const SizedBox(height: 16),
          OxInput(
            label: 'Orçamento total (€)',
            controller: budgetCtrl,
            keyboardType: TextInputType.number,
            prefixIcon: LucideIcons.euro,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Campo obrigatório';
              if (double.tryParse(v) == null) return 'Valor inválido';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _DateField(
            label: 'Prazo',
            value: deadline,
            onChanged: onDeadlineChanged,
          ),
          const SizedBox(height: 32),
          OxButton(label: 'Continuar', onPressed: onNext),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.value, required this.onChanged});
  final String label;
  final DateTime? value;
  final void Function(DateTime?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now().add(const Duration(days: 30)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              builder: (ctx, child) => Theme(
                data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(primary: AppColors.accent),
                ),
                child: child!,
              ),
            );
            onChanged(picked);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.calendar, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Text(
                  value != null
                      ? '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}'
                      : 'Selecionar prazo',
                  style: TextStyle(
                    color: value != null ? AppColors.textPrimary : AppColors.textDisabled,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StepPhases extends StatelessWidget {
  const _StepPhases({
    required this.phases,
    required this.nameCtrl,
    required this.amountCtrl,
    required this.onAddPhase,
    required this.onRemovePhase,
    required this.onBack,
    required this.onNext,
  });

  final List<Map<String, dynamic>> phases;
  final TextEditingController nameCtrl;
  final TextEditingController amountCtrl;
  final VoidCallback onAddPhase;
  final void Function(int) onRemovePhase;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fases do Projeto',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 24),
        // Phases list
        ...phases.asMap().entries.map((entry) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Text(
                    '${entry.key + 1}',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value['name'] as String,
                      style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Inter'),
                    ),
                  ),
                  Text(
                    '€ ${entry.value['amount']}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.error),
                    onPressed: () => onRemovePhase(entry.key),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 16),
        // Add phase
        OxInput(label: 'Nome da fase', controller: nameCtrl),
        const SizedBox(height: 12),
        OxInput(
          label: 'Valor estimado (€)',
          controller: amountCtrl,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        OxButton(
          label: '+ Adicionar Fase',
          variant: OxButtonVariant.secondary,
          onPressed: onAddPhase,
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OxButton(
                label: 'Voltar',
                variant: OxButtonVariant.secondary,
                onPressed: onBack,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: OxButton(label: 'Continuar', onPressed: onNext)),
          ],
        ),
      ],
    );
  }
}

class _StepReview extends StatelessWidget {
  const _StepReview({
    required this.title,
    required this.location,
    required this.budget,
    required this.phases,
    required this.isLoading,
    required this.onBack,
    required this.onSaveDraft,
    required this.onSendForValidation,
  });

  final String title;
  final String location;
  final double budget;
  final List<Map<String, dynamic>> phases;
  final bool isLoading;
  final VoidCallback onBack;
  final VoidCallback onSaveDraft;
  final VoidCallback onSendForValidation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Revisão',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
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
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8),
              Text(location, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter')),
              const SizedBox(height: 16),
              Text(
                '€ ${budget.toStringAsFixed(2)} total',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
              const Divider(color: AppColors.divider, height: 24),
              ...phases.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(
                          '${p['order']}. ${p['name']}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '€ ${p['amount']}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 32),
        OxButton(
          label: 'Enviar para Validação',
          isLoading: isLoading,
          icon: LucideIcons.sendHorizontal,
          onPressed: isLoading ? null : onSendForValidation,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OxButton(
                label: 'Voltar',
                variant: OxButtonVariant.secondary,
                onPressed: isLoading ? null : onBack,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OxButton(
                label: 'Salvar Rascunho',
                variant: OxButtonVariant.secondary,
                isLoading: isLoading,
                onPressed: isLoading ? null : onSaveDraft,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
