import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

/// Skeleton placeholder shown while a list (therapists, circles,
/// appointments...) is loading from Firestore, instead of a bare spinner.
class LoadingShimmer extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const LoadingShimmer({super.key, this.itemCount = 4, this.itemHeight = 88});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkCardBackground : AppColors.divider.withValues(alpha: 0.5),
      highlightColor: isDark ? AppColors.darkDivider : AppColors.surface,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Container(
          height: itemHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}