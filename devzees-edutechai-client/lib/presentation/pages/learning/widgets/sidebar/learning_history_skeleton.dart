import 'package:flutter/material.dart';
import '../../../../widgets/shimmer_loading.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/theme/theme_palette.dart';

class LearningHistorySkeletonItem extends StatelessWidget {
  final bool expanded;
  final double titleWidth;

  const LearningHistorySkeletonItem({
    super.key,
    required this.expanded,
    this.titleWidth = 110.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    final cardBg = isDark
        ? context.appColors.scaffoldBackground
        : Colors.white;

    final cardBorder = AppColors.primary.withValues(
      alpha: isDark ? 0.35 : 0.30,
    );

    if (!expanded) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: cardBorder,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: isDark ? 0.14 : 0.10,
                ),
                blurRadius: 10,
                offset: Offset.zero,
              ),
              if (!isDark)
                const BoxShadow(
                  color: Color(0x060F172A),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
            ],
          ),
          child: ShimmerLoading(
            child: ShimmerBox(
              width: 18,
              height: 18,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: cardBg,
          border: Border.all(
            color: cardBorder,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(
                alpha: isDark ? 0.14 : 0.10,
              ),
              blurRadius: 12,
              offset: Offset.zero,
            ),
            if (!isDark)
              const BoxShadow(
                color: Color(0x060F172A),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: ShimmerLoading(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Placeholder
              ShimmerBox(
                width: 16,
                height: 16,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(width: 12),

              // Text and badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Topic Header / Title Bar Loader
                    ShimmerBox(
                      width: titleWidth,
                      height: 13,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 6),
                    // Badges line (Steps pill + XP pill)
                    Row(
                      children: [
                        // Steps count pill loader
                        ShimmerBox(
                          width: 58,
                          height: 14,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        const SizedBox(width: 8),
                        // XP badge pill loader
                        ShimmerBox(
                          width: 44,
                          height: 14,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Trailing action menu dots placeholder
              const ShimmerBox(
                width: 14,
                height: 14,
                shape: BoxShape.circle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
