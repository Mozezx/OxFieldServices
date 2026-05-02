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
                        if (v == null || v.isEmpty) return 'Campo obrigatório';
                        if (!v.contains('@')) return 'E-mail inválido';
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
                        if (v == null || v.isEmpty) return 'Campo obrigatório';
                        if (v.length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => context.push('/forgot-password'),
                        child: const Text(
                          'Esqueceu a senha?',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
                            'ou continue com',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontFamily: 'Inter',
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: AppColors.divider)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _SocialButton(
                            label: 'Google',
                            icon: CustomPaint(
                              size: const Size(18, 18),
                              painter: _GoogleIconPainter(),
                            ),
                            onTap: () => ref
                                .read(authControllerProvider.notifier)
                                .loginWithGoogle(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SocialButton(
                            label: 'Facebook',
                            icon: const _FacebookIcon(),
                            onTap: () => ref
                                .read(authControllerProvider.notifier)
                                .loginWithFacebook(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    GestureDetector(
                      onTap: () => context.push('/register'),
                      child: RichText(
                        text: const TextSpan(
                          text: 'Não tem conta? ',
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

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.divider, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FacebookIcon extends StatelessWidget {
  const _FacebookIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: const Color(0xFF1877F2),
        borderRadius: BorderRadius.circular(3),
      ),
      alignment: Alignment.center,
      child: const Text(
        'f',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 13,
          height: 1,
        ),
      ),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.scale(scale, scale);

    final paint = Paint();

    final redPath = Path()
      ..moveTo(12.175, 5.853)
      ..cubicTo(13.68, 5.853, 15.03, 6.37, 16.093, 7.386)
      ..lineTo(19.031, 4.448)
      ..cubicTo(17.257, 2.822, 14.937, 2, 12.175, 2)
      ..cubicTo(8.198, 2, 4.7, 3.815, 3.03, 7.257)
      ..lineTo(6.425, 9.89)
      ..cubicTo(7.231, 7.46, 9.497, 5.853, 12.175, 5.853)
      ..close();
    canvas.drawPath(redPath, paint..color = const Color(0xFFEA4335));

    final bluePath = Path()
      ..moveTo(21.805, 10.023)
      ..lineTo(12.175, 10.023)
      ..lineTo(12.175, 13.977)
      ..lineTo(17.692, 13.977)
      ..cubicTo(17.455, 15.272, 16.735, 16.369, 15.656, 17.1)
      ..lineTo(15.656, 19.696)
      ..lineTo(18.948, 19.696)
      ..cubicTo(20.875, 17.923, 21.986, 15.311, 21.986, 12.346)
      ..cubicTo(21.986, 11.859, 21.942, 11.386, 21.805, 10.023)
      ..close();
    canvas.drawPath(bluePath, paint..color = const Color(0xFF4285F4));

    final greenPath = Path()
      ..moveTo(12.175, 22)
      ..cubicTo(14.938, 22, 17.259, 21.087, 18.95, 19.523)
      ..lineTo(15.658, 16.971)
      ..cubicTo(14.744, 17.587, 13.573, 17.951, 12.175, 17.951)
      ..cubicTo(9.497, 17.951, 7.231, 16.144, 6.425, 13.714)
      ..lineTo(3.03, 16.347)
      ..cubicTo(4.7, 20.185, 8.198, 22, 12.175, 22)
      ..close();
    canvas.drawPath(greenPath, paint..color = const Color(0xFF34A853));

    final yellowPath = Path()
      ..moveTo(6.425, 13.714)
      ..cubicTo(6.113, 13.11, 5.913, 12.464, 5.913, 11.8)
      ..cubicTo(5.913, 11.136, 6.113, 10.49, 6.425, 9.886)
      ..lineTo(3.03, 7.253)
      ..cubicTo(2.387, 8.607, 2, 10.137, 2, 11.757)
      ..cubicTo(2, 13.377, 2.387, 14.907, 3.03, 16.261)
      ..close();
    canvas.drawPath(yellowPath, paint..color = const Color(0xFFFBBC05));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
