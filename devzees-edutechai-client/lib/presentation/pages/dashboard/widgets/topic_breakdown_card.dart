import 'package:flutter/material.dart';
import '../../../../data/models/dashboard/dashboard_response.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_palette.dart';

/// Reusable card displaying topic mastery breakdown with horizontal progress bars.
class TopicBreakdownCard extends StatelessWidget {
  final List<TopicBreakdownItem> topicBreakdown;

  const TopicBreakdownCard({
    super.key,
    required this.topicBreakdown,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final topics = topicBreakdown;

    return LayoutBuilder(
      builder: (context, cardConstraints) {
        final isMobile = cardConstraints.maxWidth < 450;

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
                'Topic Mastery Breakdown',
                style: AppTextStyles.h4.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: isMobile ? 16 : 18,
                  color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Most explored subjects across your learning roadmap',
                style: AppTextStyles.body2.copyWith(
                  color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                  fontSize: isMobile ? 12 : 13,
                ),
              ),
              const SizedBox(height: 16),

              if (topics.isEmpty)
                Container(
                  height: 180,
                  alignment: Alignment.center,
                  child: Text(
                    'No topics explored yet.',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topics.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final t = topics[index];
                    final colors = [
                      const Color(0xFF8B5CF6),
                      const Color(0xFF38BDF8),
                      const Color(0xFF10B981),
                      const Color(0xFFF59E0B),
                      const Color(0xFFEC4899),
                    ];
                    final barColor = colors[index % colors.length];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                t.topic,
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
                            const SizedBox(width: 8),
                            Text(
                              '${t.sessionCount} ${t.sessionCount == 1 ? "journey" : "journeys"} (${t.percentage.toStringAsFixed(0)}%)',
                              style: AppTextStyles.caption.copyWith(
                                color: isDark
                                    ? AppColors.textSecondary
                                    : const Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (t.percentage / 100).clamp(0.05, 1.0),
                            backgroundColor: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.06),
                            valueColor: AlwaysStoppedAnimation<Color>(barColor),
                            minHeight: 6,
                          ),
                        ),
                      ],
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
