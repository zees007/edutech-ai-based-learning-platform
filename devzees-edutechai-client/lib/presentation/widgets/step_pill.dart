import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';

/// Standardized Step Progress Pill used across the entire EduTechAI application.
///
/// Features:
/// - Glowing Green Pill: Primary green tint (15% opacity), green hairline border (40% opacity), vibrant green text.
/// - Review Mode: Cyan tint & cyan border with an optional mini "Review" tag.
/// - Compact Mode: Displays "X/Y" (e.g., "3/7") for tight spaces like top bar HUDs.
/// - Standard Mode: Displays "Step X/Y" (e.g., "Step 2/7").
class StepPill extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final bool isReviewing;
  final bool isCompact;
  final bool showReviewBadge;
  final double? fontSize;

  const StepPill({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.isReviewing = false,
    this.isCompact = false,
    this.showReviewBadge = true,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = AppColors.isDark;

    // Background Color
    final Color bgColor = isReviewing
        ? (isDark
            ? AppColors.cyanLight.withValues(alpha: 0.15)
            : const Color(0xFFE0F2FE))
        : (isDark
            ? AppColors.accentGreen.withValues(alpha: 0.15)
            : AppColors.greenSoft.withValues(alpha: 0.65));

    // Border Color
    final Color borderColor = isReviewing
        ? (isDark
            ? AppColors.cyanLight.withValues(alpha: 0.45)
            : const Color(0xFFBAE6FD))
        : (isDark
            ? AppColors.accentGreen.withValues(alpha: 0.40)
            : AppColors.accentGreen.withValues(alpha: 0.35));

    // Text Color
    final Color textColor = isReviewing
        ? (isDark ? AppColors.cyanLight : const Color(0xFF0284C7))
        : (isDark ? AppColors.accentGreen : AppColors.greenDark);

    final String label = isCompact
        ? '$currentStep/$totalSteps'
        : 'Step $currentStep/$totalSteps';

    final effectiveFontSize = fontSize ?? (isCompact ? 9.5 : 10.5);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 5 : 8,
        vertical: isCompact ? 1.5 : 3,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: borderColor,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.badge.copyWith(
              fontSize: effectiveFontSize,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
          if (isReviewing && showReviewBadge && !isCompact) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cyanLight.withValues(alpha: 0.25)
                    : const Color(0xFF0284C7),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                'Review',
                style: AppTextStyles.badge.copyWith(
                  fontSize: 7.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
