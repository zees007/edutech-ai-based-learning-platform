import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../widgets/shimmer_loading.dart';

class RecentJourneySkeletonCard extends StatelessWidget {
  final bool isMobile;

  const RecentJourneySkeletonCard({
    super.key,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark;

    return ShimmerLoading(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.canvasBackground : Colors.white,
          border: Border.all(
            color: AppColors.primary.withValues(
              alpha: isDark ? 0.35 : 0.30,
            ),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(
                alpha: isDark ? 0.14 : 0.10,
              ),
              blurRadius: 16,
              offset: Offset.zero,
            ),
            if (!isDark)
              const BoxShadow(
                color: Color(0x060F172A),
                blurRadius: 8,
                spreadRadius: -2,
                offset: Offset(0, 4),
              ),
          ],
        ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Circular Progress Gauge Skeleton
                ShimmerBox(
                  width: 28,
                  height: 28,
                  shape: BoxShape.circle,
                  color: AppColors.shimmerBoxDark,
                ),
                const SizedBox(width: 12),

                // Topic Text & XP Skeleton
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Topic line
                      ShimmerBox(
                        width: 130,
                        height: 13,
                        color: AppColors.shimmerBoxLight,
                      ),
                      const SizedBox(height: 6),
                      // Badges line (XP & steps)
                      Row(
                        children: [
                          ShimmerBox(
                            width: 38,
                            height: 10,
                            color: AppColors.shimmerBoxMid,
                          ),
                          const SizedBox(width: 8),
                          ShimmerBox(
                            width: 58,
                            height: 14,
                            borderRadius: BorderRadius.circular(6),
                            color: AppColors.shimmerBoxMid,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Action Chevron Skeleton
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.glassHover,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
