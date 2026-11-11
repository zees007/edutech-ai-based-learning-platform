import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../widgets/shimmer_loading.dart';

class RecentJourneySkeletonCard extends StatelessWidget {
  final bool isMobile;
  final double titleWidth;

  const RecentJourneySkeletonCard({
    super.key,
    this.isMobile = false,
    this.titleWidth = 130.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark;

    // Distinct shimmer token colors for crisp contrast against card background
    final shimmerBase = isDark ? const Color(0xFF1E2138) : const Color(0xFFE2E8F0);
    final shimmerHighlight = isDark ? const Color(0xFF353A60) : const Color(0xFFF8FAFC);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
      child: ShimmerLoading(
        baseColor: shimmerBase,
        highlightColor: shimmerHighlight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular Progress Gauge Skeleton
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: shimmerBase,
                  width: 3.0,
                ),
              ),
              child: Center(
                child: ShimmerBox(
                  width: 12,
                  height: 12,
                  shape: BoxShape.circle,
                  color: shimmerBase,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Topic Text & Badges Skeleton
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Prominent Topic Header / Title Bar Loader
                  ShimmerBox(
                    width: titleWidth,
                    height: 13,
                    borderRadius: BorderRadius.circular(4),
                    color: shimmerBase,
                  ),
                  const SizedBox(height: 6),
                  // Badges line (XP Star & Steps Pill Loader)
                  Row(
                    children: [
                      // Mini star icon placeholder
                      ShimmerBox(
                        width: 10,
                        height: 10,
                        borderRadius: BorderRadius.circular(2),
                        color: shimmerBase,
                      ),
                      const SizedBox(width: 4),
                      // XP text bar
                      ShimmerBox(
                        width: 36,
                        height: 10,
                        borderRadius: BorderRadius.circular(3),
                        color: shimmerBase,
                      ),
                      const SizedBox(width: 8),
                      // Steps count pill
                      ShimmerBox(
                        width: 60,
                        height: 15,
                        borderRadius: BorderRadius.circular(6),
                        color: shimmerBase,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Action Chevron Skeleton
            ShimmerBox(
              width: 14,
              height: 14,
              shape: BoxShape.circle,
              color: shimmerBase,
            ),
          ],
        ),
      ),
    );
  }
}
