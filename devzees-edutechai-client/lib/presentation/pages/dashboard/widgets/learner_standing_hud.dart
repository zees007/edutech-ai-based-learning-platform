import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dashboard_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_palette.dart';
import '../../../../core/utils/trophy_utils.dart';
import '../../../../data/models/dashboard/dashboard_response.dart';
import '../../../widgets/glass_card.dart';

/// Ultra-premium Learner Standing HUD component.
///
/// Supports two rendering modes:
/// 1. Top Bar Mode ([isTopBar] = true): Sleek, edge-to-edge persistent identity
///    bar containing prestige trophy emblem, total XP badge, next trophy progression,
///    streaks, and an optional [trailing] widget (e.g. ThemeToggleButton).
/// 2. Card Mode ([isTopBar] = false): Frosted glass card for modal dialogues
///    (e.g., UserAnalyticsDialog) and mobile scrollable containers.
class LearnerStandingHud extends ConsumerWidget {
  final DashboardSummary? fallbackSummary;
  final List<AchievementItem>? fallbackAchievements;
  final bool isTopBar;
  final Widget? trailing;

  const LearnerStandingHud({
    super.key,
    this.fallbackSummary,
    this.fallbackAchievements,
    this.isTopBar = false,
    this.trailing,
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

    if (isTopBar) {
      return _buildTopBarLayout(
        context,
        trophyStyle: trophyStyle,
        nextStyle: nextStyle,
        highestTrophyTitle: highestTrophyTitle,
        nextTrophyTitle: nextTrophyTitle,
        clampedFraction: clampedFraction,
        totalXp: totalXp,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        unlockedTrophies: unlockedTrophies,
        totalTrophies: totalTrophies,
        isDark: isDark,
      );
    }

    return _buildCardLayout(
      context,
      trophyStyle: trophyStyle,
      nextStyle: nextStyle,
      highestTrophyTitle: highestTrophyTitle,
      nextTrophyTitle: nextTrophyTitle,
      clampedFraction: clampedFraction,
      totalXp: totalXp,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      unlockedTrophies: unlockedTrophies,
      totalTrophies: totalTrophies,
      isDark: isDark,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ─── TOP BAR HUD MODE (Tier 1 Global Identity) ────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTopBarLayout(
    BuildContext context, {
    required TrophyStyle trophyStyle,
    required TrophyStyle nextStyle,
    required String highestTrophyTitle,
    required String? nextTrophyTitle,
    required double clampedFraction,
    required int totalXp,
    required int currentStreak,
    required int longestStreak,
    required int unlockedTrophies,
    required int totalTrophies,
    required bool isDark,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1050;
        final isMobile = constraints.maxWidth < 600;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: isMobile ? 8 : 10,
          ),
          decoration: BoxDecoration(
            color: context.appColors.topBarBackground,
            border: Border(
              bottom: BorderSide(
                color: context.appColors.border.withValues(alpha: 0.7),
                width: 1.0,
              ),
            ),
          ),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 1. Prestige Emblem
                    _buildTrophyBadge(trophyStyle, isDark, size: 36, iconSize: 18),
                    const SizedBox(width: 12),

                    // 2. Trophy Title + Total XP
                    _buildTitleAndXp(highestTrophyTitle, totalXp, isDark, isMobile: false),
                    const SizedBox(width: 16),

                    // 3. Next Trophy Progress Bar Capsule
                    Expanded(
                      child: _buildProgressCapsule(
                        clampedFraction: clampedFraction,
                        accentColor: nextStyle.color,
                        nextTrophyTitle: nextTrophyTitle,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // 4. Streak Counter Pill
                    _buildStreakPill(currentStreak, longestStreak, isDark, isCompact: false),
                    const SizedBox(width: 10),

                    // 5. Trophy Counter Pill
                    _buildTrophyPill(unlockedTrophies, totalTrophies, isDark, isCompact: false),

                    // 6. Untouched Top-Right Trailing Action (ThemeToggleButton)
                    if (trailing != null) ...[
                      const SizedBox(width: 12),
                      trailing!,
                    ],
                  ],
                )
              : isMobile
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTrophyBadge(trophyStyle, isDark, size: 32, iconSize: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  highestTrophyTitle,
                                  style: AppTextStyles.subtitle2.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              _buildXpPill(totalXp, isCompact: true),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            nextTrophyTitle != null
                                ? 'Next: $nextTrophyTitle • ${(clampedFraction * 100).toInt()}%'
                                : '💎 Diamond Achieved',
                            style: AppTextStyles.caption.copyWith(
                              color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStreakPill(currentStreak, longestStreak, isDark, isCompact: true),
                    if (trailing != null) ...[
                      const SizedBox(width: 8),
                      trailing!,
                    ],
                  ],
                )
              : Column(
                  // Intermediate Tablet View: Balanced 2-line layout
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildTrophyBadge(trophyStyle, isDark, size: 34, iconSize: 17),
                        const SizedBox(width: 10),
                        _buildTitleAndXp(highestTrophyTitle, totalXp, isDark, isMobile: false),
                        const Spacer(),
                        if (trailing != null) trailing!,
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _buildProgressCapsule(
                            clampedFraction: clampedFraction,
                            accentColor: nextStyle.color,
                            nextTrophyTitle: nextTrophyTitle,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildStreakPill(currentStreak, longestStreak, isDark, isCompact: true),
                        const SizedBox(width: 8),
                        _buildTrophyPill(unlockedTrophies, totalTrophies, isDark, isCompact: true),
                      ],
                    ),
                  ],
                ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ─── CARD HUD MODE (Standalone / Modal / Mobile Scroll View) ──────────────
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildCardLayout(
    BuildContext context, {
    required TrophyStyle trophyStyle,
    required TrophyStyle nextStyle,
    required String highestTrophyTitle,
    required String? nextTrophyTitle,
    required double clampedFraction,
    required int totalXp,
    required int currentStreak,
    required int longestStreak,
    required int unlockedTrophies,
    required int totalTrophies,
    required bool isDark,
  }) {
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
                              _buildXpPill(totalXp),
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
                              _buildXpPill(totalXp),
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

  // ═══════════════════════════════════════════════════════════════════════════
  // ─── REUSABLE UI PRIMITIVES ───────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildTitleAndXp(String title, int xp, bool isDark, {bool isMobile = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: (isMobile ? AppTextStyles.subtitle2 : AppTextStyles.h4).copyWith(
            fontWeight: FontWeight.w800,
            fontSize: isMobile ? 14 : 16,
            color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(width: 8),
        _buildXpPill(xp, isCompact: isMobile),
      ],
    );
  }

  Widget _buildXpPill(int totalXp, {bool isCompact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 7 : 9,
        vertical: isCompact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentAmber.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.accentAmber.withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: AppColors.accentAmber,
            size: 13,
          ),
          const SizedBox(width: 4),
          Text(
            isCompact ? '$totalXp XP' : '$totalXp Total XP',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.accentAmber,
              fontWeight: FontWeight.w800,
              fontSize: isCompact ? 10.5 : 11.5,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCapsule({
    required double clampedFraction,
    required Color accentColor,
    required String? nextTrophyTitle,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E2138).withValues(alpha: 0.6)
            : const Color(0xFFF1F5F9).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0x1AFFFFFF) : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: _buildProgressBar(clampedFraction, accentColor, isDark),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              nextTrophyTitle != null
                  ? 'Next: $nextTrophyTitle • ${(clampedFraction * 100).toInt()}%'
                  : '💎 Diamond Achieved',
              style: AppTextStyles.caption.copyWith(
                color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrophyBadge(
    TrophyStyle style,
    bool isDark, {
    double size = 44,
    double iconSize = 22,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            style.color,
            style.color.withValues(alpha: 0.70),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: style.color.withValues(alpha: 0.35),
            blurRadius: size * 0.22,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          style.icon,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }

  Widget _buildProgressBar(double fraction, Color accentColor, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 6.5,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: fraction,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentColor, accentColor.withValues(alpha: 0.85)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreakPill(
    int current,
    int longest,
    bool isDark, {
    bool isCompact = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: const Color(0xFFEF4444),
            size: isCompact ? 15 : 17,
          ),
          const SizedBox(width: 5),
          if (isCompact)
            Text(
              '${current}d Streak',
              style: AppTextStyles.caption.copyWith(
                color: const Color(0xFFEF4444),
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$current-Day Streak',
                  style: AppTextStyles.caption.copyWith(
                    color: const Color(0xFFEF4444),
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                  ),
                ),
                Text(
                  'Best: $longest days',
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTrophyPill(
    int unlocked,
    int total,
    bool isDark, {
    bool isCompact = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentAmber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.accentAmber.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events_rounded,
            color: AppColors.accentAmber,
            size: isCompact ? 15 : 17,
          ),
          const SizedBox(width: 5),
          if (isCompact)
            Text(
              '$unlocked/$total Trophies',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.accentAmber,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$unlocked / $total Trophies',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentAmber,
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                  ),
                ),
                Text(
                  'All-Time Unlocked',
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
