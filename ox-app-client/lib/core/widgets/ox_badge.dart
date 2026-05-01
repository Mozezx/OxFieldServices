import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum OxBadgeStatus {
  active,
  pending,
  rejected,
  neutral,
  inProgress,
}

class OxBadge extends StatelessWidget {
  const OxBadge({super.key, required this.label, required this.status});

  final String label;
  final OxBadgeStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: _textColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: _textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Color get _bgColor {
    switch (status) {
      case OxBadgeStatus.active:
        return const Color(0xFF03FC30).withValues(alpha: 0.15);
      case OxBadgeStatus.pending:
        return const Color(0xFFFFA500).withValues(alpha: 0.15);
      case OxBadgeStatus.rejected:
        return const Color(0xFFFF4C4C).withValues(alpha: 0.15);
      case OxBadgeStatus.neutral:
        return AppColors.secondary.withValues(alpha: 0.08);
      case OxBadgeStatus.inProgress:
        return const Color(0xFF03FC30).withValues(alpha: 0.08);
    }
  }

  Color get _textColor {
    switch (status) {
      case OxBadgeStatus.active:
        return AppColors.accent;
      case OxBadgeStatus.pending:
        return AppColors.warning;
      case OxBadgeStatus.rejected:
        return AppColors.error;
      case OxBadgeStatus.neutral:
        return AppColors.textSecondary;
      case OxBadgeStatus.inProgress:
        return AppColors.textSecondary;
    }
  }
}

OxBadgeStatus projectStatusToBadge(String status) {
  switch (status) {
    case 'in_execution':
    case 'closed':
    case 'validated':
      return OxBadgeStatus.active;
    case 'pending':
    case 'in_validation':
    case 'matched':
    case 'under_review':
      return OxBadgeStatus.pending;
    case 'rejected':
      return OxBadgeStatus.rejected;
    case 'in_progress':
    case 'active_escrow':
    case 'contract_signed':
      return OxBadgeStatus.inProgress;
    default:
      return OxBadgeStatus.neutral;
  }
}
