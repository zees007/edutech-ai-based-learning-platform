import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_palette.dart';
import '../../../../core/utils/trophy_utils.dart';
import '../../../../data/models/dashboard/dashboard_response.dart';

/// Reusable card displaying milestone achievements and prestige trophy case.
class MilestoneAchievementsCard extends StatelessWidget {
  final List<AchievementItem> achievements;

  const MilestoneAchievementsCard({
    super.key,
    required this.achievements,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final unlockedCount = achievements.where((a) => a.unlocked).length;

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
                  Flexible(
                    child: Container(
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (achievements.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  alignment: Alignment.center,
                  child: Text(
                    'No achievements available.',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                    ),
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, gridConstraints) {
                    final availableWidth = gridConstraints.maxWidth;
                    if (availableWidth <= 0) return const SizedBox.shrink();

                    final int cols = availableWidth >= 500 ? 2 : 1;
                    final double tileWidth = cols == 2
                        ? (availableWidth - 12) / 2
                        : availableWidth;

                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: achievements.map((ach) {
                        return SizedBox(
                          width: tileWidth,
                          child: _buildAchievementTile(context, ach),
                        );
                      }).toList(),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAchievementTile(BuildContext context, AchievementItem ach) {
    final isDark = context.isDarkMode;
    final isUnlocked = ach.unlocked;

    final style = getTrophyStyle(ach.icon.isNotEmpty ? ach.icon : ach.id);
    final iconData = style.icon;
    final iconColor = style.color;

    return Container(
      constraints: const BoxConstraints(minHeight: 84),
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
              ? iconColor.withValues(alpha: 0.35)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.05)),
          width: 1,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: iconColor.withValues(alpha: isDark ? 0.20 : 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: isUnlocked
                  ? LinearGradient(
                      colors: [
                        iconColor.withValues(alpha: 0.28),
                        iconColor.withValues(alpha: 0.10),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isUnlocked ? null : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: isUnlocked
                  ? Border.all(
                      color: iconColor.withValues(alpha: 0.45),
                      width: 1.0,
                    )
                  : null,
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
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
                    ),
                    if (isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: iconColor.withValues(alpha: 0.35),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          'UNLOCKED',
                          style: TextStyle(
                            color: iconColor,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
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
}
