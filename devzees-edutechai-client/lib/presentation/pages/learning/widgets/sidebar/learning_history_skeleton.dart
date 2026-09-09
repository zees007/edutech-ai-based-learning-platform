import 'package:flutter/material.dart';
import '../../../../widgets/shimmer_loading.dart';

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
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const ShimmerBox(
            width: 18,
            height: 18,
            color: Color(0xFF2E2248),
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
          color: Colors.white.withValues(alpha: 0.02),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon Placeholder
            const ShimmerBox(
              width: 16,
              height: 16,
              color: Color(0xFF2E2248),
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
                    color: const Color(0xFF332750),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ShimmerBox(
                        width: 58,
                        height: 14,
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xFF261D3D),
                      ),
                      const SizedBox(width: 8),
                      ShimmerBox(
                        width: 44,
                        height: 14,
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xFF261D3D),
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
