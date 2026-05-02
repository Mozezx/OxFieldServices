import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ox_app_bar.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const OxAppBar(title: 'Notificações'),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.bellOff, size: 48, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text(
              'Nenhuma notificação',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
