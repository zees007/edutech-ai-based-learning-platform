import 'dart:ui';
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
    return ShimmerLoading(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.glassBase,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Circular Progress Gauge Skeleton
                const ShimmerBox(
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
                      const ShimmerBox(
                        width: 130,
                        height: 13,
                        color: AppColors.shimmerBoxLight,
                      ),
                      const SizedBox(height: 6),
                      // Badges line (XP & steps)
                      Row(
                        children: [
                          const ShimmerBox(
                            width: 38,
                            height: 10,
                            color: AppColors.shimmerBoxMid,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.glassBorder,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const ShimmerBox(
                            width: 56,
                            height: 10,
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
                  decoration: const BoxDecoration(
                    color: AppColors.glassHover,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
