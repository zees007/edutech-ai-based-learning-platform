import 'package:flutter/material.dart';
import '../../../../data/models/dashboard/dashboard_response.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_palette.dart';
import '../../../widgets/glass_card.dart';

class DashboardKpiCards extends StatelessWidget {
  final DashboardSummary summary;

  const DashboardKpiCards({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final formattedStudyTime = _formatStudyTime(summary.totalStudyMinutes);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        if (totalWidth <= 0) return const SizedBox.shrink();

        final int crossAxisCount;
        if (totalWidth >= 960) {
          crossAxisCount = 4;
        } else if (totalWidth >= 500) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        final cardWidth = _calculateCardWidth(totalWidth, crossAxisCount);

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildCard(
              context: context,
              width: cardWidth,
              title: 'Active Study Time',
              value: formattedStudyTime,
              subtitle: 'Active time in period',
              icon: Icons.timer_outlined,
              iconColor: AppColors.accentCyan,
              accentGradient: const [Color(0xFF06B6D4), Color(0xFF0284C7)],
            ),
            _buildCard(
              context: context,
              width: cardWidth,
              title: 'Journeys Completed',
              value: '${summary.completedSessions} / ${summary.totalSessions}',
              subtitle:
                  '${summary.completionRate.toStringAsFixed(1)}% completion rate',
              icon: Icons.flag_rounded,
              iconColor: AppColors.accentPurple,
              accentGradient: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
            ),
            _buildCard(
              context: context,
              width: cardWidth,
              title: 'Milestones Mastered',
              value: '${summary.totalStepsMastered} Steps',
              subtitle: 'Roadmap checkpoints completed',
              icon: Icons.check_circle_outline_rounded,
              iconColor: AppColors.accentGreen,
              accentGradient: const [Color(0xFF10B981), Color(0xFF059669)],
            ),
            _buildCard(
              context: context,
              width: cardWidth,
              title: 'Period Quiz Accuracy',
              value: '${summary.averageQuizScoreOverall.toStringAsFixed(1)}%',
              subtitle: 'Across milestone quizzes in period',
              icon: Icons.track_changes_rounded,
              iconColor: AppColors.accentBlue,
              accentGradient: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            ),
          ],
        );
      },
    );
  }

  double _calculateCardWidth(double totalWidth, int count) {
    if (count <= 1) return totalWidth;
    final totalSpacing = (count - 1) * 16.0;
    return (totalWidth - totalSpacing) / count;
  }

  Widget _buildCard({
    required BuildContext context,
    required double width,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required List<Color> accentGradient,
    String? extraBadge,
  }) {
    final isDark = context.isDarkMode;

    return SizedBox(
      width: width,
      child: GlassCard(
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.label.copyWith(
                      color: isDark
                          ? AppColors.textSecondary
                          : const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: iconColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      fontSize: 22,
                      color: isDark
                          ? AppColors.textPrimary
                          : const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (extraBadge != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: accentGradient),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      extraBadge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _formatStudyTime(int minutes) {
    if (minutes <= 0) return '0 min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}m';
    }
  }
}
