import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/widgets/ox_button.dart';
import '../../core/widgets/ox_input.dart';
import 'auth_controller.dart';
import '../../l10n/app_localizations.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      } else if (next is AsyncData && next.value == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.resetPasswordSuccess),
            backgroundColor: AppColors.accent,
          ),
        );
        context.go('/home');
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.hero),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(LucideIcons.lockKeyhole, size: 36, color: AppColors.accent),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l.resetPasswordTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.resetPasswordSubtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 40),
                    OxInput(
                      label: l.resetPasswordNewLabel,
                      controller: _passwordCtrl,
                      obscureText: true,
                      prefixIcon: LucideIcons.lock,
                      validator: (v) {
                        if (v == null || v.isEmpty) return l.errorFieldRequired;
                        if (v.length < 6) return l.errorPasswordShort;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    OxInput(
                      label: l.resetPasswordConfirmLabel,
                      controller: _confirmCtrl,
                      obscureText: true,
                      prefixIcon: LucideIcons.lockKeyhole,
                      validator: (v) {
                        if (v == null || v.isEmpty) return l.errorFieldRequired;
                        if (v != _passwordCtrl.text) return l.errorPasswordMismatch;
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    OxButton(
                      label: l.resetPasswordButton,
                      isLoading: authState is AsyncLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ref.read(authControllerProvider.notifier).updatePassword(
                                _passwordCtrl.text,
                              );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
