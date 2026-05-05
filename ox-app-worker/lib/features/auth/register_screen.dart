import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/widgets/ox_button.dart';
import '../../core/widgets/ox_input.dart';
import '../../l10n/app_localizations.dart';
import 'auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

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
    final t = AppLocalizations.of(context)!;
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
                    icon: const Icon(LucideIcons.arrowLeft,
                        color: AppColors.textPrimary),
                    onPressed: widget.onBack,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.registerTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 32),
                  OxInput(
                    label: t.registerNameLabel,
                    controller: _nameCtrl,
                    prefixIcon: LucideIcons.user,
                    validator: (v) =>
                        v == null || v.isEmpty ? t.errorFieldRequired : null,
                  ),
                  const SizedBox(height: 16),
                  OxInput(
                    label: t.emailLabel,
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: LucideIcons.mail,
                    validator: (v) {
                      if (v == null || v.isEmpty) return t.errorFieldRequired;
                      if (!v.contains('@')) return t.errorInvalidEmail;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  OxInput(
                    label: t.passwordLabel,
                    controller: _passwordCtrl,
                    obscureText: true,
                    prefixIcon: LucideIcons.lock,
                    validator: (v) {
                      if (v == null || v.isEmpty) return t.errorFieldRequired;
                      if (v.length < 6) return t.errorPasswordShort;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  OxInput(
                    label: t.registerConfirmPasswordLabel,
                    controller: _confirmCtrl,
                    obscureText: true,
                    prefixIcon: LucideIcons.lockKeyhole,
                    validator: (v) {
                      if (v != _passwordCtrl.text) return t.errorPasswordMismatch;
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.hardHat,
                            color: AppColors.accent, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          t.registerWorkerBadge,
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  OxButton(
                    label: t.registerButton,
                    isLoading: authState is AsyncLoading,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ref.read(authControllerProvider.notifier).register(
                              name: _nameCtrl.text.trim(),
                              email: _emailCtrl.text.trim(),
                              password: _passwordCtrl.text,
                            );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: widget.onBack,
                      child: Text(
                        t.registerHasAccount,
                        style: const TextStyle(
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
