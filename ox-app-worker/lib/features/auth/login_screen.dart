import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/widgets/ox_button.dart';
import '../../core/widgets/ox_input.dart';
import 'auth_controller.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _showRegister = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
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
      } else if (next is AsyncData && next.value == null) {
        // Triggered after initial build — ignore
      } else if (next is AsyncData) {
        context.go('/home');
      }
    });

    if (_showRegister) {
      return RegisterScreen(onBack: () => setState(() => _showRegister = false));
    }

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
                    Image.asset('assets/logo.webp', width: 100, height: 100),
                    const SizedBox(height: 32),
                    const Text(
                      'OX Trabalhador',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Entre na sua conta de trabalhador',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 40),
                    OxInput(
                      label: 'E-mail',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: LucideIcons.mail,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Campo obrigatorio';
                        if (!v.contains('@')) return 'E-mail invalido';
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
                        if (v == null || v.isEmpty) return 'Campo obrigatorio';
                        if (v.length < 6) return 'Minimo 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    OxButton(
                      label: 'Entrar',
                      isLoading: authState is AsyncLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ref.read(authControllerProvider.notifier).login(
                                _emailCtrl.text.trim(),
                                _passwordCtrl.text,
                              );
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => setState(() => _showRegister = true),
                      child: const Text.rich(
                        TextSpan(
                          text: 'Nao tem conta? ',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontFamily: 'Inter',
                          ),
                          children: [
                            TextSpan(
                              text: 'Cadastre-se',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
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
