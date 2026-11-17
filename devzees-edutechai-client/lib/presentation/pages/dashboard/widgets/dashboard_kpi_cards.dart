import 'package:flutter/material.dart';
import '../../../../data/models/dashboard/dashboard_response.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_palette.dart';
import '../../../widgets/glass_card.dart';

class DashboardKpiCards extends StatelessWidget {
  final DashboardSummary summary;

  const DashboardKpiCards({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final int crossAxisCount;
    if (width > 1150) {
      crossAxisCount = 3;
    } else if (width > 680) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    final formattedStudyTime = _formatStudyTime(summary.totalStudyMinutes);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildCard(
              context: context,
              width: _calculateCardWidth(constraints.maxWidth, crossAxisCount),
              title: 'Active Study Time',
              value: formattedStudyTime,
              subtitle: 'Active time across sessions',
              icon: Icons.timer_outlined,
              iconColor: AppColors.accentCyan,
              accentGradient: const [Color(0xFF06B6D4), Color(0xFF0284C7)],
            ),
            _buildCard(
              context: context,
              width: _calculateCardWidth(constraints.maxWidth, crossAxisCount),
              title: 'Journeys Completed',
              value: '${summary.completedSessions} / ${summary.totalSessions}',
              subtitle: '${summary.completionRate.toStringAsFixed(1)}% completion rate',
              icon: Icons.flag_rounded,
              iconColor: AppColors.accentPurple,
              accentGradient: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
            ),
            _buildCard(
              context: context,
              width: _calculateCardWidth(constraints.maxWidth, crossAxisCount),
              title: 'Milestones Mastered',
              value: '${summary.totalStepsMastered} Steps',
              subtitle: 'Roadmap checkpoints completed',
              icon: Icons.check_circle_outline_rounded,
              iconColor: AppColors.accentGreen,
              accentGradient: const [Color(0xFF10B981), Color(0xFF059669)],
            ),
            _buildCard(
              context: context,
              width: _calculateCardWidth(constraints.maxWidth, crossAxisCount),
              title: 'All-Time Learner Level',
              value: 'Level ${summary.currentLevel}',
              subtitle: '${summary.levelTitle} (+${summary.totalXp} XP)',
              icon: Icons.military_tech_rounded,
              iconColor: AppColors.accentAmber,
              accentGradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
              extraBadge: summary.isMaxLevel ? 'MAX' : '+${summary.xpNeededForNext} XP to next',
            ),
            _buildCard(
              context: context,
              width: _calculateCardWidth(constraints.maxWidth, crossAxisCount),
              title: 'Active Study Streak',
              value: '${summary.currentStreak} Days',
              subtitle: 'Personal Best: ${summary.longestStreak} days',
              icon: Icons.local_fire_department_rounded,
              iconColor: const Color(0xFFEF4444),
              accentGradient: const [Color(0xFFEF4444), Color(0xFFDC2626)],
            ),
            _buildCard(
              context: context,
              width: _calculateCardWidth(constraints.maxWidth, crossAxisCount),
              title: 'Overall Quiz Accuracy',
              value: '${summary.averageQuizScoreOverall.toStringAsFixed(1)}%',
              subtitle: 'Across all 3-question quizzes',
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
    final spacingTotal = (count - 1) * 16.0;
    return (totalWidth - spacingTotal) / count;
  }

  String _formatStudyTime(int minutes) {
    if (minutes < 60) {
      return '$minutes mins';
    }
    final hours = minutes ~/ 60;
    final remainingMins = minutes % 60;
    if (remainingMins == 0) {
      return '$hours hrs';
    }
    return '${hours}h ${remainingMins}m';
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

    return GlassCard(
      width: width,
      borderRadius: 18,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentGradient.first.withValues(alpha: 0.18),
                      accentGradient.last.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accentGradient.first.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              if (extraBadge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentGradient.first.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: accentGradient.first.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    extraBadge,
                    style: AppTextStyles.caption.copyWith(
                      color: accentGradient.first,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 24,
              letterSpacing: -0.5,
              color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.label.copyWith(
              color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              color: isDark
                  ? AppColors.textMuted
                  : const Color(0xFF94A3B8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
