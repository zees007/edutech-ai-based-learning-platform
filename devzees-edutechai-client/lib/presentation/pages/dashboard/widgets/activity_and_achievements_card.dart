import 'package:flutter/material.dart';
import '../../../../data/models/dashboard/dashboard_response.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_palette.dart';
import '../../../widgets/glass_card.dart';

class ActivityAndAchievementsCard extends StatelessWidget {
  final List<HeatmapDayItem> activityHeatmap;
  final List<AchievementItem> achievements;

  const ActivityAndAchievementsCard({
    super.key,
    required this.activityHeatmap,
    required this.achievements,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: _buildAchievementsSection(context)),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: _buildActivityHeatmapSection(context)),
        ],
      );
    } else {
      return Column(
        children: [
          _buildAchievementsSection(context),
          const SizedBox(height: 16),
          _buildActivityHeatmapSection(context),
        ],
      );
    }
  }

  Widget _buildAchievementsSection(BuildContext context) {
    final isDark = context.isDarkMode;
    final isMobile = MediaQuery.of(context).size.width < 700;
    final unlockedCount = achievements.where((a) => a.unlocked).length;

    return GlassCard(
      borderRadius: 20,
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Milestone Achievements & Trophy Case',
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: isMobile ? 16 : 18,
                        color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Milestones unlocked through continuous study and quiz mastery',
                      style: AppTextStyles.body2.copyWith(
                        color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                        fontSize: isMobile ? 12 : 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accentAmber.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  '$unlockedCount / ${achievements.length} Unlocked',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentAmber,
                    fontWeight: FontWeight.w700,
                    fontSize: isMobile ? 11 : 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: isMobile ? 450 : 260,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: isMobile ? 95 : 110,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final ach = achievements[index];
              return _buildAchievementTile(context, ach);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementTile(BuildContext context, AchievementItem ach) {
    final isDark = context.isDarkMode;
    final isUnlocked = ach.unlocked;

    IconData iconData = Icons.emoji_events_rounded;
    Color iconColor = AppColors.accentAmber;

    if (ach.icon == 'flag') {
      iconData = Icons.flag_rounded;
      iconColor = AppColors.accentCyan;
    } else if (ach.icon == 'bullseye') {
      iconData = Icons.track_changes_rounded;
      iconColor = AppColors.accentGreen;
    } else if (ach.icon == 'flame') {
      iconData = Icons.local_fire_department_rounded;
      iconColor = const Color(0xFFEF4444);
    } else if (ach.icon == 'compass') {
      iconData = Icons.explore_rounded;
      iconColor = AppColors.accentPurple;
    } else if (ach.icon == 'books') {
      iconData = Icons.menu_book_rounded;
      iconColor = const Color(0xFF38BDF8);
    } else if (ach.icon == 'crown') {
      iconData = Icons.workspace_premium_rounded;
      iconColor = AppColors.accentAmber;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked
            ? (isDark
                ? iconColor.withValues(alpha: 0.08)
                : iconColor.withValues(alpha: 0.06))
            : (isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.black.withValues(alpha: 0.02)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnlocked
              ? iconColor.withValues(alpha: 0.3)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.05)),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? iconColor.withValues(alpha: 0.15)
                  : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUnlocked ? iconData : Icons.lock_outline_rounded,
              color: isUnlocked ? iconColor : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ach.title,
                  style: AppTextStyles.label.copyWith(
                    color: isUnlocked
                        ? (isDark ? Colors.white : const Color(0xFF0F172A))
                        : (isDark ? Colors.grey : const Color(0xFF94A3B8)),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  ach.description,
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityHeatmapSection(BuildContext context) {
    final isDark = context.isDarkMode;
    final isMobile = MediaQuery.of(context).size.width < 700;

    return GlassCard(
      borderRadius: 20,
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.black.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
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
                          Text(
                            day.date,
                            style: AppTextStyles.label.copyWith(
                              color: isDark ? AppColors.textPrimary : const Color(0xFF1E293B),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '${day.stepsCount} ${day.stepsCount == 1 ? "step" : "steps"}',
                            style: AppTextStyles.caption.copyWith(
                              color: isDark ? AppColors.accentCyan : const Color(0xFF0284C7),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
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
  }
}
