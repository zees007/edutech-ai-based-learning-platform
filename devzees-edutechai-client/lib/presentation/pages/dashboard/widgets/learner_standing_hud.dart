import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dashboard_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_palette.dart';
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
        level: standing.currentLevel,
        levelTitle: standing.levelTitle,
        xpProgress: standing.xpProgressInLevel,
        xpNeeded: standing.xpNeededForNext,
        isMaxLevel: standing.isMaxLevel,
        totalXp: standing.totalXp,
        currentStreak: standing.currentStreak,
        longestStreak: standing.longestStreak,
        unlockedTrophies: standing.achievements.where((a) => a.unlocked).length,
        totalTrophies: standing.achievements.length,
        isDark: isDark,
      ),
      loading: () {
        if (fallbackSummary != null) {
          final achievements = fallbackAchievements ?? const [];
          return _buildHudContent(
            context,
            level: fallbackSummary!.currentLevel,
            levelTitle: fallbackSummary!.levelTitle,
            xpProgress: fallbackSummary!.xpProgressInLevel,
            xpNeeded: fallbackSummary!.xpNeededForNext,
            isMaxLevel: fallbackSummary!.isMaxLevel,
            totalXp: fallbackSummary!.totalXp,
            currentStreak: fallbackSummary!.currentStreak,
            longestStreak: fallbackSummary!.longestStreak,
            unlockedTrophies: achievements.where((a) => a.unlocked).length,
            totalTrophies: achievements.isNotEmpty ? achievements.length : 7,
            isDark: isDark,
          );
        }
        return const SizedBox.shrink();
      },
      error: (_, _) {
        if (fallbackSummary != null) {
          final achievements = fallbackAchievements ?? const [];
          return _buildHudContent(
            context,
            level: fallbackSummary!.currentLevel,
            levelTitle: fallbackSummary!.levelTitle,
            xpProgress: fallbackSummary!.xpProgressInLevel,
            xpNeeded: fallbackSummary!.xpNeededForNext,
            isMaxLevel: fallbackSummary!.isMaxLevel,
            totalXp: fallbackSummary!.totalXp,
            currentStreak: fallbackSummary!.currentStreak,
            longestStreak: fallbackSummary!.longestStreak,
            unlockedTrophies: achievements.where((a) => a.unlocked).length,
            totalTrophies: achievements.isNotEmpty ? achievements.length : 7,
            isDark: isDark,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHudContent(
    BuildContext context, {
    required int level,
    required String levelTitle,
    required int xpProgress,
    required int xpNeeded,
    required bool isMaxLevel,
    required int totalXp,
    required int currentStreak,
    required int longestStreak,
    required int unlockedTrophies,
    required int totalTrophies,
    required bool isDark,
  }) {
    final denominator = (xpProgress + xpNeeded).clamp(1, 999999);
    final progressFraction = isMaxLevel ? 1.0 : (xpProgress / denominator).clamp(0.0, 1.0);

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
                    _buildLevelBadge(level, isDark),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  levelTitle,
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
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accentAmber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$totalXp XP',
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
                            isMaxLevel ? 'Mastery Cap Reached' : '$xpProgress / ${xpProgress + xpNeeded} XP to Level ${level + 1}',
                            style: AppTextStyles.caption.copyWith(
                              color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildProgressBar(progressFraction, isDark),
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
                    _buildLevelBadge(level, isDark),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  levelTitle,
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
                                  'Level $level • $totalXp Total XP',
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
                              Expanded(child: _buildProgressBar(progressFraction, isDark)),
                              const SizedBox(width: 12),
                              Text(
                                isMaxLevel ? 'MAX' : '$xpProgress / ${xpProgress + xpNeeded} XP',
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

  Widget _buildLevelBadge(int level, bool isDark) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF38BDF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$level',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(double fraction, bool isDark) {
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
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF38BDF8)],
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
