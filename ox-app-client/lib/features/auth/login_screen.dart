import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/widgets/ox_button.dart';
import '../../core/widgets/ox_input.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

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
      } else if (next is AsyncData) {
        context.go('/home');
      }
    });

    {
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
                        'Bem-vindo de volta',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Entre na sua conta OX',
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
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.divider)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'ou',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.divider)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      OxButton(
                        label: 'Entrar com Google',
                        variant: OxButtonVariant.secondary,
                        onPressed: () {},
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () => context.push('/register'),
                        child: RichText(
                          text: const TextSpan(
                            text: 'NÃ£o tem conta? ',
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
}
