import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/widgets/ox_button.dart';
import '../../core/widgets/ox_input.dart';
import 'auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String _role = 'client';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      } else if (next is AsyncData) {
        context.go('/home');
      }
    });

    {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppGradients.hero),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Criar conta',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 32),
                    OxInput(
                      label: 'Nome completo',
                      controller: _nameCtrl,
                      prefixIcon: LucideIcons.user,
                      validator: (v) => v == null || v.isEmpty ? 'Campo obrigatÃ³rio' : null,
                    ),
                    const SizedBox(height: 16),
                    OxInput(
                      label: 'E-mail',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: LucideIcons.mail,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Campo obrigatÃ³rio';
                        if (!v.contains('@')) return 'E-mail invÃ¡lido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    OxInput(
                      label: 'Senha',
                      controller: _passwordCtrl,
                      obscureText: true,
                      prefixIcon: LucideIcons.lock,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Campo obrigatÃ³rio';
                        if (v.length < 6) return 'MÃ­nimo 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    OxInput(
                      label: 'Confirmar senha',
                      controller: _confirmCtrl,
                      obscureText: true,
                      prefixIcon: LucideIcons.lockKeyhole,
                      validator: (v) {
                        if (v != _passwordCtrl.text) return 'Senhas nÃ£o conferem';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Tipo de conta',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _RoleOption(
                          label: 'Sou cliente',
                          icon: LucideIcons.briefcase,
                          value: 'client',
                          selected: _role == 'client',
                          onTap: () => setState(() => _role = 'client'),
                        ),
                        const SizedBox(width: 12),
                        _RoleOption(
                          label: 'Sou trabalhador',
                          icon: LucideIcons.hardHat,
                          value: 'worker',
                          selected: _role == 'worker',
                          onTap: () => setState(() => _role = 'worker'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    OxButton(
                      label: 'Criar conta',
                      isLoading: authState is AsyncLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ref.read(authControllerProvider.notifier).register(
                                name: _nameCtrl.text.trim(),
                                email: _emailCtrl.text.trim(),
                                password: _passwordCtrl.text,
                                role: _role,
                              );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: const Text(
                          'JÃ¡ tenho conta',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}

class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.accent.withValues(alpha: 0.12) : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.divider,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? AppColors.accent : AppColors.textSecondary, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.accent : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
