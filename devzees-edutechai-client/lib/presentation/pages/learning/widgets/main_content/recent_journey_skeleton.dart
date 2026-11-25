import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../widgets/shimmer_loading.dart';
import 'package:devzees_edutechai_client/core/theme/theme_palette.dart';

class RecentJourneySkeletonCard extends StatelessWidget {
  final bool isMobile;
  final bool isCompact;
  final double titleWidth;

  const RecentJourneySkeletonCard({
    super.key,
    this.isMobile = false,
    this.isCompact = false,
    this.titleWidth = 130.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    // Distinct shimmer token colors for crisp contrast against card background
    final shimmerBase = isDark ? const Color(0xFF1E2138) : const Color(0xFFE2E8F0);
    final shimmerHighlight = isDark ? const Color(0xFF353A60) : const Color(0xFFF8FAFC);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 11 : 14,
        vertical: isCompact ? 8 : 9,
      ),
      decoration: BoxDecoration(
        color: isDark ? context.appColors.scaffoldBackground : Colors.white,
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
              width: isCompact ? 22 : 26,
              height: isCompact ? 22 : 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: shimmerBase,
                  width: isCompact ? 2.5 : 3.0,
                ),
              ),
              child: Center(
                child: ShimmerBox(
                  width: isCompact ? 10 : 12,
                  height: isCompact ? 10 : 12,
                  shape: BoxShape.circle,
                  color: shimmerBase,
                ),
              ),
            ),
            SizedBox(width: isCompact ? 8 : 10),

            // Topic Text & Badges Skeleton
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Prominent Topic Header / Title Bar Loader
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final safeWidth = titleWidth.clamp(40.0, constraints.maxWidth);
                      return ShimmerBox(
                        width: safeWidth,
                        height: isCompact ? 12 : 13,
                        borderRadius: BorderRadius.circular(4),
                        color: shimmerBase,
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  // Badges line (XP Star & Steps Pill Loader)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                        const SizedBox(width: 6),
                        // Steps count pill
                        ShimmerBox(
                          width: 56,
                          height: 15,
                          borderRadius: BorderRadius.circular(6),
                          color: shimmerBase,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: isCompact ? 4 : 8),

            // Action Chevron Skeleton
            ShimmerBox(
              width: isCompact ? 12 : 14,
              height: isCompact ? 12 : 14,
              shape: BoxShape.circle,
              color: shimmerBase,
            ),
          ],
        ),
      ),
    );
  }
}
