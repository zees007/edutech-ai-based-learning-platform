import 'package:flutter/material.dart';
import '../../../../widgets/shimmer_loading.dart';
import '../../../../../core/theme/app_colors.dart';

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
    if (!expanded) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.glassSurface.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ShimmerBox(
            width: 18,
            height: 18,
            color: AppColors.shimmerBoxDark,
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
          color: AppColors.glassSurface.withValues(alpha: 0.02),
          border: Border.all(
            color: AppColors.glassBorder,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon Placeholder
            ShimmerBox(
              width: 16,
              height: 16,
              color: AppColors.shimmerBoxDark,
            ),
            const SizedBox(width: 12),

            // Text and badges
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShimmerBox(
                    width: titleWidth,
                    height: 12,
                    color: AppColors.shimmerBoxMid,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ShimmerBox(
                        width: 58,
                        height: 14,
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.shimmerBoxDark,
                      ),
                      const SizedBox(width: 8),
                      ShimmerBox(
                        width: 44,
                        height: 14,
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.shimmerBoxDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
