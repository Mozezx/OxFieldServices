import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Avatar circular: foto de rede ou inicial do nome/email.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.radius,
    this.imageUrl,
    this.label,
    this.onTap,
    this.emphasizeBorder = false,
  });

  final double radius;
  final String? imageUrl;
  final String? label;
  final VoidCallback? onTap;
  final bool emphasizeBorder;

  String get _initial {
    final t = (label ?? '').trim();
    if (t.isEmpty) return '?';
    return t.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    final child = url != null && url.isNotEmpty
        ? ClipOval(
            child: CachedNetworkImage(
              imageUrl: url,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: radius * 2,
                height: radius * 2,
                color: AppColors.accent.withValues(alpha: 0.12),
                alignment: Alignment.center,
                child: SizedBox(
                  width: radius,
                  height: radius,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (_, __, ___) => _fallback(),
            ),
          )
        : _fallback();

    final decorated = emphasizeBorder
        ? Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            child: child,
          )
        : child;

    if (onTap == null) return decorated;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: decorated,
      ),
    );
  }

  Widget _fallback() {
    return CircleAvatar(
      radius: emphasizeBorder ? radius - 2 : radius,
      backgroundColor: AppColors.accent.withValues(alpha: 0.15),
      child: Text(
        _initial,
        style: TextStyle(
          color: AppColors.accent,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.75,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}
