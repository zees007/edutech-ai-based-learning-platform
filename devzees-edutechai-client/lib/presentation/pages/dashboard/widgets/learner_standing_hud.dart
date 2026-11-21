import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dashboard_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_palette.dart';
import '../../../../core/utils/trophy_utils.dart';
import '../../../../data/models/dashboard/dashboard_response.dart';
import '../../../widgets/glass_card.dart';

class LearnerStandingHud extends ConsumerWidget {
  final DashboardSummary? fallbackSummary;
  final List<AchievementItem>? fallbackAchievements;

  const LearnerStandingHud({
    super.key,
    this.fallbackSummary,
    this.fallbackAchievements,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final standingAsync = ref.watch(learnerStandingProvider);
    final isDark = context.isDarkMode;

    return standingAsync.when(
      data: (standing) => _buildHudContent(
        context,
        highestTrophyId: standing.highestTrophyId,
        highestTrophyTitle: standing.highestTrophyTitle,
        nextTrophyId: standing.nextTrophyId,
        nextTrophyTitle: standing.nextTrophyTitle,
        trophyProgressFraction: standing.trophyProgressFraction,
        totalXp: standing.totalXp,
        currentStreak: standing.currentStreak,
        longestStreak: standing.longestStreak,
        unlockedTrophies: standing.achievements.where((a) => a.unlocked).length,
        totalTrophies: standing.achievements.isNotEmpty ? standing.achievements.length : 6,
        isDark: isDark,
      ),
      loading: () => _buildFallback(context, isDark),
      error: (_, _) => _buildFallback(context, isDark),
    );
  }

  Widget _buildFallback(BuildContext context, bool isDark) {
    if (fallbackSummary != null) {
      final achievements = fallbackAchievements ?? const [];
      final unlockedList = achievements.where((a) => a.unlocked).toList();

      String? highestId;
      String highestTitle = 'Unranked';
      String? nextTitle = 'Bronze Trophy';
      double fraction = 0.0;

      const order = ['diamond', 'sapphire', 'platinum', 'gold', 'silver', 'bronze'];
      for (final id in order) {
        final match = unlockedList.where((a) => a.id == id).firstOrNull;
        if (match != null) {
          highestId = id;
          highestTitle = match.title;
          final idx = order.indexOf(id);
          if (idx > 0) {
            nextTitle = achievements.where((a) => a.id == order[idx - 1]).firstOrNull?.title;
          } else {
            nextTitle = null;
            fraction = 1.0;
          }
          break;
        }
      }

      return _buildHudContent(
        context,
        highestTrophyId: highestId,
        highestTrophyTitle: highestTitle,
        nextTrophyId: null,
        nextTrophyTitle: nextTitle,
        trophyProgressFraction: fraction,
        totalXp: fallbackSummary!.totalXp,
        currentStreak: fallbackSummary!.currentStreak,
        longestStreak: fallbackSummary!.longestStreak,
        unlockedTrophies: unlockedList.length,
        totalTrophies: achievements.isNotEmpty ? achievements.length : 6,
        isDark: isDark,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildHudContent(
    BuildContext context, {
    required String? highestTrophyId,
    required String highestTrophyTitle,
    required String? nextTrophyId,
    required String? nextTrophyTitle,
    required double trophyProgressFraction,
    required int totalXp,
    required int currentStreak,
    required int longestStreak,
    required int unlockedTrophies,
    required int totalTrophies,
    required bool isDark,
  }) {
    final clampedFraction = trophyProgressFraction.clamp(0.0, 1.0);
    final trophyStyle = getTrophyStyle(highestTrophyId);
    final nextStyle = getTrophyStyle(nextTrophyId);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 780;

        return GlassCard(
          borderRadius: 20,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 22,
            vertical: isMobile ? 14 : 18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile) ...[
                // Stacked Layout (Mobile & Narrow Tablet)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTrophyBadge(trophyStyle, isDark),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  highestTrophyTitle,
                                  style: AppTextStyles.h4.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accentAmber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$totalXp Total XP',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.accentAmber,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            nextTrophyTitle != null
                                ? 'Next: $nextTrophyTitle • ${(clampedFraction * 100).toInt()}%'
                                : '💎 Diamond Achieved (Max Prestige)',
                            style: AppTextStyles.caption.copyWith(
                              color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildProgressBar(clampedFraction, nextStyle.color, isDark),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _buildStreakPill(currentStreak, longestStreak, isDark),
                    _buildTrophyPill(unlockedTrophies, totalTrophies, isDark),
                  ],
                ),
              ] else ...[
                // Desktop Wide Layout
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTrophyBadge(trophyStyle, isDark),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  highestTrophyTitle,
                                  style: AppTextStyles.h4.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17,
                                    color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accentAmber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.accentAmber.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  '$totalXp Total XP',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.accentAmber,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: _buildProgressBar(clampedFraction, nextStyle.color, isDark),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                nextTrophyTitle != null
                                    ? 'Next: $nextTrophyTitle • ${(clampedFraction * 100).toInt()}%'
                                    : '💎 Diamond Achieved',
                                style: AppTextStyles.caption.copyWith(
                                  color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildStreakPill(currentStreak, longestStreak, isDark),
                    const SizedBox(width: 10),
                    _buildTrophyPill(unlockedTrophies, totalTrophies, isDark),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrophyBadge(TrophyStyle style, bool isDark) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            style.color,
            style.color.withValues(alpha: 0.65),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: style.color.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          style.icon,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildProgressBar(double fraction, Color accentColor, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 7,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: fraction,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentColor, accentColor.withValues(alpha: 0.8)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreakPill(int current, int longest, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department_rounded, color: Color(0xFFEF4444), size: 18),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$current-Day Streak',
                style: AppTextStyles.caption.copyWith(
                  color: const Color(0xFFEF4444),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              Text(
                'Best: $longest days',
                style: AppTextStyles.caption.copyWith(
                  color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrophyPill(int unlocked, int total, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.accentAmber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentAmber.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events_rounded, color: AppColors.accentAmber, size: 18),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$unlocked / $total Trophies',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.accentAmber,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              Text(
                'All-Time Unlocked',
                style: AppTextStyles.caption.copyWith(
                  color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
