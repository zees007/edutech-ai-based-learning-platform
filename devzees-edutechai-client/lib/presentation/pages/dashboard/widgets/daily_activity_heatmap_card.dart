import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_palette.dart';
import '../../../../data/models/dashboard/dashboard_response.dart';

/// Reusable card displaying daily study activity and milestone checkpoints.
class DailyActivityHeatmapCard extends StatelessWidget {
  final List<HeatmapDayItem> activityHeatmap;

  const DailyActivityHeatmapCard({
    super.key,
    required this.activityHeatmap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return LayoutBuilder(
      builder: (context, sectionConstraints) {
        final isMobile = sectionConstraints.maxWidth < 500;

        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.cardBackground.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.20)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(isMobile ? 16 : 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Activity Log',
                style: AppTextStyles.h4.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: isMobile ? 16 : 18,
                  color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Step milestones completed by day',
                style: AppTextStyles.body2.copyWith(
                  color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 18),

              if (activityHeatmap.isEmpty)
                Container(
                  height: 140,
                  alignment: Alignment.center,
                  child: Text(
                    'No activity days recorded yet.',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activityHeatmap.reversed.take(6).length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final day = activityHeatmap.reversed.toList()[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : Colors.black.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.accentGreen,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    day.date,
                                    style: AppTextStyles.label.copyWith(
                                      color: isDark
                                          ? AppColors.textPrimary
                                          : const Color(0xFF1E293B),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${day.stepsCount} ${day.stepsCount == 1 ? "step" : "steps"}',
                                style: AppTextStyles.caption.copyWith(
                                  color: isDark
                                      ? AppColors.accentCyan
                                      : const Color(0xFF0284C7),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '+${day.xpEarned} XP',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.accentAmber,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
