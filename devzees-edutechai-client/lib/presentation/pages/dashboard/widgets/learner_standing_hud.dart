import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dashboard_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_palette.dart';
import '../../../../core/utils/trophy_utils.dart';
import '../../../../data/models/dashboard/dashboard_response.dart';
import '../../../widgets/glass_card.dart';

/// Ultra-premium, high-density Learner Standing HUD.
///
/// Designed to fit seamlessly into persistent top bars ([isTopBar] = true)
/// as well as embedded cards ([isTopBar] = false) across all viewports
/// with informative tooltips and radiant jewel-toned aesthetics.
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
        final width = constraints.maxWidth;
        final isWideDesktop = width >= 1050;
        final isCompactDesktop = width >= 750 && width < 1050;
        final isNarrow = width < 750;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isNarrow ? 14 : 24,
            vertical: isNarrow ? 7 : 8,
          ),
          decoration: BoxDecoration(
            color: context.appColors.topBarBackground,
            border: Border(
              bottom: BorderSide(
                color: context.appColors.border.withValues(alpha: 0.65),
                width: 1.0,
              ),
            ),
          ),
          child: isWideDesktop
              ? _buildDesktopSingleRow(
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
                )
              : isCompactDesktop
              ? _buildCompactSingleRow(
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
                )
              : _buildNarrowTwoRow(
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
                  width: width,
                ),
        );
      },
    );
  }

  // 1. Wide Desktop Single Row (>= 1050px)
  Widget _buildDesktopSingleRow(
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Radiant Prestige Trophy Crest
        _buildTrophyBadge(
          trophyStyle,
          isDark,
          title: highestTrophyTitle,
          size: 30,
          iconSize: 16,
        ),
        const SizedBox(width: 10),

        // Title & XP Gem Capsule
        _buildTitleAndXp(highestTrophyTitle, totalXp, isDark),
        const SizedBox(width: 14),

        _buildDivider(isDark),
        const SizedBox(width: 14),

        // Next Trophy Progression Capsule
        Expanded(
          child: _buildProgressCapsule(
            clampedFraction: clampedFraction,
            accentColor: nextStyle.color,
            nextTrophyTitle: nextTrophyTitle,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 14),

        _buildDivider(isDark),
        const SizedBox(width: 14),

        // Fiery Streak Chip
        _buildStreakChip(currentStreak, longestStreak, isDark, isCompact: false),
        const SizedBox(width: 8),

        // Trophy Case Chip
        _buildTrophyChip(unlockedTrophies, totalTrophies, isDark, isCompact: false),

        // Trailing Theme Toggle
        if (trailing != null) ...[
          const SizedBox(width: 10),
          _buildDivider(isDark),
          const SizedBox(width: 10),
          trailing!,
        ],
      ],
    );
  }

  // 2. Compact Single Row (750px - 1049px)
  Widget _buildCompactSingleRow(
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTrophyBadge(
          trophyStyle,
          isDark,
          title: highestTrophyTitle,
          size: 28,
          iconSize: 15,
        ),
        const SizedBox(width: 8),
        _buildTitleAndXp(highestTrophyTitle, totalXp, isDark, isCompact: true),
        const SizedBox(width: 10),

        _buildDivider(isDark),
        const SizedBox(width: 10),

        Expanded(
          child: _buildProgressCapsule(
            clampedFraction: clampedFraction,
            accentColor: nextStyle.color,
            nextTrophyTitle: nextTrophyTitle,
            isDark: isDark,
            isCompact: true,
          ),
        ),
        const SizedBox(width: 10),

        _buildDivider(isDark),
        const SizedBox(width: 10),

        _buildStreakChip(currentStreak, longestStreak, isDark, isCompact: true),
        const SizedBox(width: 6),
        _buildTrophyChip(unlockedTrophies, totalTrophies, isDark, isCompact: true),

        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
  }

  // 3. Narrow / Mobile Two-Row (< 750px)
  Widget _buildNarrowTwoRow(
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
    required double width,
  }) {
    final isVeryNarrow = width < 360;

    if (isVeryNarrow) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildTrophyBadge(
                trophyStyle,
                isDark,
                title: highestTrophyTitle,
                size: 24,
                iconSize: 13,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Tooltip(
                  message: 'Current Standing: $highestTrophyTitle\nLifetime Achievement Rank',
                  child: Text(
                    highestTrophyTitle,
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _buildXpPill(totalXp, isCompact: true),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildStreakChip(currentStreak, longestStreak, isDark, isCompact: true),
              const SizedBox(width: 6),
              _buildTrophyChip(unlockedTrophies, totalTrophies, isDark, isCompact: true),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSlimProgressRow(
                  clampedFraction: clampedFraction,
                  accentColor: nextStyle.color,
                  nextTrophyTitle: nextTrophyTitle,
                  isDark: isDark,
                  isCompact: true,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildTrophyBadge(
              trophyStyle,
              isDark,
              title: highestTrophyTitle,
              size: 26,
              iconSize: 14,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Tooltip(
                message: 'Current Standing: $highestTrophyTitle\nLifetime Achievement Rank',
                child: Text(
                  highestTrophyTitle,
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 6),
            _buildXpPill(totalXp, isCompact: true),
            const Spacer(),
            _buildStreakChip(currentStreak, longestStreak, isDark, isCompact: true),
            const SizedBox(width: 6),
            _buildTrophyChip(unlockedTrophies, totalTrophies, isDark, isCompact: true),
            if (trailing != null) ...[
              const SizedBox(width: 6),
              trailing!,
            ],
          ],
        ),
        const SizedBox(height: 6),
        _buildSlimProgressRow(
          clampedFraction: clampedFraction,
          accentColor: nextStyle.color,
          nextTrophyTitle: nextTrophyTitle,
          isDark: isDark,
        ),
      ],
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
        final width = constraints.maxWidth;
        final isVeryNarrow = width < 340;
        final isMobile = width < 700;

        return GlassCard(
          borderRadius: 16,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 20,
            vertical: isMobile ? 10 : 14,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isVeryNarrow) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTrophyBadge(
                      trophyStyle,
                      isDark,
                      title: highestTrophyTitle,
                      size: 26,
                      iconSize: 13,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        highestTrophyTitle,
                        style: AppTextStyles.subtitle2.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                          color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildXpPill(totalXp, isCompact: true),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildStreakChip(currentStreak, longestStreak, isDark, isCompact: true),
                    const SizedBox(width: 6),
                    _buildTrophyChip(unlockedTrophies, totalTrophies, isDark, isCompact: true),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSlimProgressRow(
                        clampedFraction: clampedFraction,
                        accentColor: nextStyle.color,
                        nextTrophyTitle: nextTrophyTitle,
                        isDark: isDark,
                        isCompact: true,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTrophyBadge(
                      trophyStyle,
                      isDark,
                      title: highestTrophyTitle,
                      size: isMobile ? 30 : 34,
                      iconSize: isMobile ? 15 : 17,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        highestTrophyTitle,
                        style: (isMobile ? AppTextStyles.subtitle1 : AppTextStyles.h4).copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: isMobile ? 14.5 : 16.0,
                          color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildXpPill(totalXp, isCompact: isMobile),
                    const Spacer(),
                    _buildStreakChip(currentStreak, longestStreak, isDark, isCompact: isMobile),
                    const SizedBox(width: 6),
                    _buildTrophyChip(unlockedTrophies, totalTrophies, isDark, isCompact: isMobile),
                  ],
                ),
                const SizedBox(height: 10),
                _buildSlimProgressRow(
                  clampedFraction: clampedFraction,
                  accentColor: nextStyle.color,
                  nextTrophyTitle: nextTrophyTitle,
                  isDark: isDark,
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

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1,
      height: 16,
      color: isDark ? const Color(0x1FFFFFFF) : const Color(0xFFE2E8F0),
    );
  }

  Widget _buildTitleAndXp(
    String title,
    int xp,
    bool isDark, {
    bool isCompact = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Tooltip(
          message: 'Current Standing: $title\nAll-Time Lifetime Achievement Prestige Rank',
          child: Text(
            title,
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: isCompact ? 13.5 : 14.5,
              color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildXpPill(xp, isCompact: isCompact),
      ],
    );
  }

  Widget _buildXpPill(int totalXp, {bool isCompact = false}) {
    return Tooltip(
      message: 'Total Experience Points: $totalXp XP\nEarned across all completed journeys, milestones, and quizzes',
      child: Container(
        height: 26,
        padding: EdgeInsets.symmetric(horizontal: isCompact ? 7 : 9),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accentAmber.withValues(alpha: 0.16),
              AppColors.accentAmber.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.accentAmber.withValues(alpha: 0.38),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.star_rounded,
              color: AppColors.accentAmber,
              size: 13,
            ),
            const SizedBox(width: 3.5),
            Text(
              isCompact ? '$totalXp XP' : '$totalXp Total XP',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.accentAmber,
                fontWeight: FontWeight.w800,
                fontSize: isCompact ? 10.5 : 11.5,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCapsule({
    required double clampedFraction,
    required Color accentColor,
    required String? nextTrophyTitle,
    required bool isDark,
    bool isCompact = false,
  }) {
    final label = nextTrophyTitle != null
        ? (isCompact
            ? 'Next: $nextTrophyTitle (${(clampedFraction * 100).toInt()}%)'
            : 'Next: $nextTrophyTitle • ${(clampedFraction * 100).toInt()}%')
        : '💎 Diamond Achieved';

    final tooltipMsg = nextTrophyTitle != null
        ? 'Next Prestige Milestone: $nextTrophyTitle\n${(clampedFraction * 100).toInt()}% of required criteria completed'
        : 'Maximum Prestige Achieved: Diamond Trophy Holder 💎';

    return Tooltip(
      message: tooltipMsg,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E2138).withValues(alpha: 0.5)
              : const Color(0xFFF1F5F9).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? const Color(0x14FFFFFF) : const Color(0xFFE2E8F0),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildProgressBar(clampedFraction, accentColor, isDark),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  fontSize: isCompact ? 10.5 : 11.0,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlimProgressRow({
    required double clampedFraction,
    required Color accentColor,
    required String? nextTrophyTitle,
    required bool isDark,
    bool isCompact = false,
  }) {
    final label = nextTrophyTitle != null
        ? (isCompact
            ? '${(clampedFraction * 100).toInt()}%'
            : 'Next: $nextTrophyTitle • ${(clampedFraction * 100).toInt()}%')
        : '💎 Max';

    final tooltipMsg = nextTrophyTitle != null
        ? 'Next Milestone: $nextTrophyTitle • ${(clampedFraction * 100).toInt()}% completed'
        : 'Maximum Prestige Diamond Trophy Unlocked 💎';

    return Tooltip(
      message: tooltipMsg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _buildProgressBar(clampedFraction, accentColor, isDark),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
                fontSize: isCompact ? 10.0 : 10.5,
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
    required String title,
    double size = 30,
    double iconSize = 16,
  }) {
    return Tooltip(
      message: 'Current Prestige: $title\nAll-time highest unlocked milestone achievement trophy',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              style.color,
              style.color.withValues(alpha: 0.75),
              style.color.withValues(alpha: 0.55),
            ],
            center: const Alignment(-0.25, -0.30),
            radius: 0.90,
          ),
          boxShadow: [
            BoxShadow(
              color: style.color.withValues(alpha: 0.40),
              blurRadius: size * 0.32,
              spreadRadius: 0.5,
              offset: const Offset(0, 1.5),
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: isDark ? 0.25 : 0.45),
            width: 1.0,
          ),
        ),
        child: Center(
          child: Icon(
            style.icon,
            color: Colors.white,
            size: iconSize,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(double fraction, Color accentColor, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 5.0,
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

  Widget _buildStreakChip(
    int current,
    int longest,
    bool isDark, {
    bool isCompact = false,
  }) {
    return Tooltip(
      message: 'Active Study Streak: $current days\nPersonal Best Record: $longest days consecutive learning',
      child: Container(
        height: 26,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 6.5 : 8.5,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFEF4444).withValues(alpha: 0.15),
              const Color(0xFFF97316).withValues(alpha: 0.07),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFEF4444).withValues(alpha: 0.30),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_fire_department_rounded,
              color: Color(0xFFEF4444),
              size: 14.5,
            ),
            const SizedBox(width: 4),
            Text(
              isCompact ? '${current}d' : '${current}d Streak',
              style: AppTextStyles.caption.copyWith(
                color: const Color(0xFFEF4444),
                fontWeight: FontWeight.w800,
                fontSize: 11.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrophyChip(
    int unlocked,
    int total,
    bool isDark, {
    bool isCompact = false,
  }) {
    return Tooltip(
      message: 'Prestige Trophies Unlocked: $unlocked of $total\nCollection of all-time achievement trophies',
      child: Container(
        height: 26,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 6.5 : 8.5,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accentAmber.withValues(alpha: 0.15),
              AppColors.accentAmber.withValues(alpha: 0.06),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.accentAmber.withValues(alpha: 0.30),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              color: AppColors.accentAmber,
              size: 14.5,
            ),
            const SizedBox(width: 4),
            Text(
              isCompact ? '$unlocked/$total' : '$unlocked / $total',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.accentAmber,
                fontWeight: FontWeight.w800,
                fontSize: 11.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
