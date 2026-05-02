import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

class OxShimmerBox extends StatelessWidget {
  const OxShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surface2,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class OxJobCardSkeleton extends StatelessWidget {
  const OxJobCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OxShimmerBox(width: 200, height: 16, borderRadius: 4),
          SizedBox(height: 10),
          OxShimmerBox(width: 120, height: 12, borderRadius: 4),
          SizedBox(height: 14),
          OxShimmerBox(width: double.infinity, height: 8, borderRadius: 4),
          SizedBox(height: 10),
          Row(
            children: [
              OxShimmerBox(width: 60, height: 12, borderRadius: 4),
              SizedBox(width: 12),
              OxShimmerBox(width: 60, height: 12, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }
}
