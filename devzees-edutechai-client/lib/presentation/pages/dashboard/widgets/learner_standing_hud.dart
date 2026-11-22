import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dashboard_provider.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_palette.dart';
import '../../../../core/utils/trophy_utils.dart';
import '../../../../data/models/dashboard/dashboard_response.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/theme_toggle_button.dart';

/// Ultra-premium, gamified Learner Standing HUD.
///
/// Follows the exact executive HUD sequence with informative tooltips (no popovers or navigation arrows):
/// 1. Current Prestige Trophy (e.g. Diamond Trophy with radiant crest & "✓ Current" badge)
/// 2. Trophies Unlock (Trophy cup, "3 / 6" counter, 6 mini trophy tier icons, and glowing progress bar)
/// 3. Total XP Rewards (Glowing star squircle & formatted XP)
/// 4. Streak (Glowing flame squircle & "X Days")
/// 5. Theme Toggle (Trailing action pinned at the far right)
///
/// On mobile view, the sidebar hamburger icon is pinned at the far left, the theme switcher is
/// pinned at the far right, and the 4 gamification status badges smoothly scroll horizontally in the middle.
class LearnerStandingHud extends ConsumerWidget {
  final DashboardSummary? fallbackSummary;
  final List<AchievementItem>? fallbackAchievements;
  final bool isTopBar;
  final Widget? leading;
  final Widget? trailing;
  final bool showHamburgerOnMobile;

  const LearnerStandingHud({
    super.key,
    this.fallbackSummary,
    this.fallbackAchievements,
    this.isTopBar = false,
    this.leading,
    this.trailing,
    this.showHamburgerOnMobile = true,
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
        nextTrophyRequirements: standing.nextTrophyRequirements,
        trophyProgressFraction: standing.trophyProgressFraction,
        totalXp: standing.totalXp,
        currentStreak: standing.currentStreak,
        longestStreak: standing.longestStreak,
        unlockedTrophies: standing.achievements.where((a) => a.unlocked).length,
        totalTrophies: standing.achievements.isNotEmpty
            ? standing.achievements.length
            : 6,
        achievements: standing.achievements,
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
      String highestTitle = 'Diamond Trophy';
      String? nextId = 'diamond';
      String? nextTitle = 'Diamond Trophy';
      double fraction = 0.5;

      const order = [
        'diamond',
        'sapphire',
        'platinum',
        'gold',
        'silver',
        'bronze',
      ];
      for (final id in order) {
        final match = unlockedList.where((a) => a.id == id).firstOrNull;
        if (match != null) {
          highestId = id;
          highestTitle = match.title;
          final idx = order.indexOf(id);
          if (idx > 0) {
            nextId = order[idx - 1];
            nextTitle =
                achievements.where((a) => a.id == nextId).firstOrNull?.title ??
                '${order[idx - 1].toUpperCase()[0]}${order[idx - 1].substring(1)} Trophy';
          } else {
            nextId = null;
            nextTitle = null;
            fraction = 1.0;
          }
          break;
        }
      }

      return _buildHudContent(
        context,
        highestTrophyId: highestId ?? 'diamond',
        highestTrophyTitle: highestTitle,
        nextTrophyId: nextId,
        nextTrophyTitle: nextTitle,
        nextTrophyRequirements: null,
        trophyProgressFraction: fraction,
        totalXp: fallbackSummary!.totalXp,
        currentStreak: fallbackSummary!.currentStreak,
        longestStreak: fallbackSummary!.longestStreak,
        unlockedTrophies: unlockedList.isNotEmpty ? unlockedList.length : 3,
        totalTrophies: achievements.isNotEmpty ? achievements.length : 6,
        achievements: achievements,
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
    required List<TrophyRequirement>? nextTrophyRequirements,
    required double trophyProgressFraction,
    required int totalXp,
    required int currentStreak,
    required int longestStreak,
    required int unlockedTrophies,
    required int totalTrophies,
    required List<AchievementItem> achievements,
    required bool isDark,
  }) {
    final clampedFraction = trophyProgressFraction.clamp(0.0, 1.0);
    final trophyStyle = getTrophyStyle(highestTrophyId);
    final nextStyle = getTrophyStyle(nextTrophyId);

    if (isTopBar) {
      return _buildTopBarLayout(
        context,
        highestTrophyId: highestTrophyId,
        highestTrophyTitle: highestTrophyTitle,
        nextTrophyId: nextTrophyId,
        nextTrophyTitle: nextTrophyTitle,
        nextTrophyRequirements: nextTrophyRequirements,
        clampedFraction: clampedFraction,
        trophyStyle: trophyStyle,
        nextStyle: nextStyle,
        totalXp: totalXp,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        unlockedTrophies: unlockedTrophies,
        totalTrophies: totalTrophies,
        achievements: achievements,
        isDark: isDark,
      );
    }

    return _buildCardLayout(
      context,
      highestTrophyId: highestTrophyId,
      highestTrophyTitle: highestTrophyTitle,
      nextTrophyId: nextTrophyId,
      nextTrophyTitle: nextTrophyTitle,
      nextTrophyRequirements: nextTrophyRequirements,
      clampedFraction: clampedFraction,
      trophyStyle: trophyStyle,
      nextStyle: nextStyle,
      totalXp: totalXp,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      unlockedTrophies: unlockedTrophies,
      totalTrophies: totalTrophies,
      achievements: achievements,
      isDark: isDark,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ─── TOP BAR HUD MODE ─────────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTopBarLayout(
    BuildContext context, {
    required String? highestTrophyId,
    required String highestTrophyTitle,
    required String? nextTrophyId,
    required String? nextTrophyTitle,
    required List<TrophyRequirement>? nextTrophyRequirements,
    required double clampedFraction,
    required TrophyStyle trophyStyle,
    required TrophyStyle nextStyle,
    required int totalXp,
    required int currentStreak,
    required int longestStreak,
    required int unlockedTrophies,
    required int totalTrophies,
    required List<AchievementItem> achievements,
    required bool isDark,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 860;

        final effectiveLeading =
            leading ??
            (!isDesktop && showHamburgerOnMobile
                ? _buildHamburgerButton(context, isDark)
                : null);

        final effectiveTrailing =
            trailing ?? (isTopBar ? const ThemeToggleButton(size: 28) : null);

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 16 : 8,
            vertical: isDesktop ? 7 : 3,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0C0D1A)
                : context.appColors.topBarBackground,
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? const Color(0xFF6B47EB).withValues(alpha: 0.28)
                    : context.appColors.border.withValues(alpha: 0.65),
                width: 1.0,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? const Color(0xFF6B47EB).withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isDesktop
              ? _buildDesktopSingleRow(
                  context,
                  highestTrophyId: highestTrophyId,
                  highestTrophyTitle: highestTrophyTitle,
                  nextTrophyId: nextTrophyId,
                  nextTrophyTitle: nextTrophyTitle,
                  nextTrophyRequirements: nextTrophyRequirements,
                  clampedFraction: clampedFraction,
                  trophyStyle: trophyStyle,
                  nextStyle: nextStyle,
                  totalXp: totalXp,
                  currentStreak: currentStreak,
                  longestStreak: longestStreak,
                  unlockedTrophies: unlockedTrophies,
                  totalTrophies: totalTrophies,
                  achievements: achievements,
                  isDark: isDark,
                  isCompact: width < 1100,
                  effectiveLeading: effectiveLeading,
                  effectiveTrailing: effectiveTrailing,
                )
              : _buildMobileScrollablePillRow(
                  context,
                  highestTrophyId: highestTrophyId,
                  highestTrophyTitle: highestTrophyTitle,
                  nextTrophyId: nextTrophyId,
                  nextTrophyTitle: nextTrophyTitle,
                  nextTrophyRequirements: nextTrophyRequirements,
                  clampedFraction: clampedFraction,
                  trophyStyle: trophyStyle,
                  nextStyle: nextStyle,
                  totalXp: totalXp,
                  currentStreak: currentStreak,
                  longestStreak: longestStreak,
                  unlockedTrophies: unlockedTrophies,
                  totalTrophies: totalTrophies,
                  achievements: achievements,
                  isDark: isDark,
                  effectiveLeading: effectiveLeading,
                  effectiveTrailing: effectiveTrailing,
                ),
        );
      },
    );
  }

  Widget _buildHamburgerButton(BuildContext context, bool isDark) {
    return IconButton(
      icon: Icon(
        Icons.menu_rounded,
        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        size: 20,
      ),
      visualDensity: VisualDensity.compact,
      onPressed: () {
        final scaffold = Scaffold.maybeOf(context);
        if (scaffold?.hasDrawer == true) {
          scaffold!.openDrawer();
        }
      },
      tooltip: 'Open navigation menu',
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
    );
  }

  // 1. DESKTOP SINGLE ROW (Exact Sequence requested):
  // 1. Diamond/Current Trophy -> 2. Trophies Unlock -> 3. Total XP Rewards -> 4. Streak -> 5. Theme Toggle
  Widget _buildDesktopSingleRow(
    BuildContext context, {
    required String? highestTrophyId,
    required String highestTrophyTitle,
    required String? nextTrophyId,
    required String? nextTrophyTitle,
    required List<TrophyRequirement>? nextTrophyRequirements,
    required double clampedFraction,
    required TrophyStyle trophyStyle,
    required TrophyStyle nextStyle,
    required int totalXp,
    required int currentStreak,
    required int longestStreak,
    required int unlockedTrophies,
    required int totalTrophies,
    required List<AchievementItem> achievements,
    required bool isDark,
    bool isCompact = false,
    Widget? effectiveLeading,
    Widget? effectiveTrailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (effectiveLeading != null) ...[
          effectiveLeading,
          const SizedBox(width: 6),
          _buildVerticalDivider(isDark),
          SizedBox(width: isCompact ? 8 : 12),
        ],

        // ── 1. Current / Diamond Trophy (First in sequence) ─────────────────
        _buildCurrentTrophySection(
          highestTrophyId: highestTrophyId,
          highestTrophyTitle: highestTrophyTitle,
          nextTrophyTitle: nextTrophyTitle,
          trophyStyle: trophyStyle,
          isDark: isDark,
          isCompact: isCompact,
        ),
        SizedBox(width: isCompact ? 8 : 14),

        _buildVerticalDivider(isDark),
        SizedBox(width: isCompact ? 8 : 14),

        // ── 2. Trophies Unlock (Second in sequence) ─────────────────────────
        _buildTrophiesUnlockSection(
          unlockedTrophies: unlockedTrophies,
          totalTrophies: totalTrophies,
          fraction: clampedFraction,
          nextTrophyTitle: nextTrophyTitle,
          isDark: isDark,
          isCompact: isCompact,
        ),
        SizedBox(width: isCompact ? 8 : 14),

        _buildVerticalDivider(isDark),
        SizedBox(width: isCompact ? 8 : 14),

        // ── 3. Total XP Rewards (Third in sequence) ─────────────────────────
        _buildTotalXpSection(
          totalXp: totalXp,
          isDark: isDark,
          isCompact: isCompact,
        ),
        SizedBox(width: isCompact ? 8 : 14),

        _buildVerticalDivider(isDark),
        SizedBox(width: isCompact ? 8 : 14),

        // ── 4. Streak (Fourth in sequence) ──────────────────────────────────
        _buildStreakSection(
          currentStreak: currentStreak,
          longestStreak: longestStreak,
          isDark: isDark,
          isCompact: isCompact,
        ),

        const Spacer(),

        // ── 5. Theme Toggle (Fifth in sequence) ─────────────────────────────
        if (effectiveTrailing != null) ...[
          _buildVerticalDivider(isDark),
          SizedBox(width: isCompact ? 8 : 12),
          effectiveTrailing,
        ],
      ],
    );
  }

  // 2. MOBILE SCROLLABLE PILL ROW (< 780px Top Bar Mode)
  // Sidebar hamburger pinned at left, theme switcher pinned at right, and 4 badges scroll in the middle
  Widget _buildMobileScrollablePillRow(
    BuildContext context, {
    required String? highestTrophyId,
    required String highestTrophyTitle,
    required String? nextTrophyId,
    required String? nextTrophyTitle,
    required List<TrophyRequirement>? nextTrophyRequirements,
    required double clampedFraction,
    required TrophyStyle trophyStyle,
    required TrophyStyle nextStyle,
    required int totalXp,
    required int currentStreak,
    required int longestStreak,
    required int unlockedTrophies,
    required int totalTrophies,
    required List<AchievementItem> achievements,
    required bool isDark,
    Widget? effectiveLeading,
    Widget? effectiveTrailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── FAR LEFT PINNED: Sidebar Hamburger Icon ───────────────────────────
        if (effectiveLeading != null) ...[
          effectiveLeading,
          const SizedBox(width: 4),
          _buildVerticalDivider(isDark),
          const SizedBox(width: 6),
        ],

        // ── MIDDLE: Horizontally Scrollable Badges (Exact sequence 1-4) ───────
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Current / Diamond Trophy
                _buildCurrentTrophySection(
                  highestTrophyId: highestTrophyId,
                  highestTrophyTitle: highestTrophyTitle,
                  nextTrophyTitle: nextTrophyTitle,
                  trophyStyle: trophyStyle,
                  isDark: isDark,
                  isCompact: true,
                ),
                const SizedBox(width: 8),

                _buildVerticalDivider(isDark),
                const SizedBox(width: 8),

                // 2. Trophies Unlock
                _buildTrophiesUnlockSection(
                  unlockedTrophies: unlockedTrophies,
                  totalTrophies: totalTrophies,
                  fraction: clampedFraction,
                  nextTrophyTitle: nextTrophyTitle,
                  isDark: isDark,
                  isCompact: true,
                ),
                const SizedBox(width: 8),

                _buildVerticalDivider(isDark),
                const SizedBox(width: 8),

                // 3. Total XP Rewards
                _buildTotalXpSection(
                  totalXp: totalXp,
                  isDark: isDark,
                  isCompact: true,
                ),
                const SizedBox(width: 8),

                _buildVerticalDivider(isDark),
                const SizedBox(width: 8),

                // 4. Streak
                _buildStreakSection(
                  currentStreak: currentStreak,
                  longestStreak: longestStreak,
                  isDark: isDark,
                  isCompact: true,
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),

        // ── FAR RIGHT PINNED: Theme Switcher Toggle ──────────────────────────
        if (effectiveTrailing != null) ...[
          const SizedBox(width: 6),
          _buildVerticalDivider(isDark),
          const SizedBox(width: 6),
          effectiveTrailing,
        ],
      ],
    );
  }

  // 3. MOBILE ERGONOMIC DECK (For Standalone / Card Mode < 780px)
  Widget _buildMobileDeck(
    BuildContext context, {
    required String? highestTrophyId,
    required String highestTrophyTitle,
    required String? nextTrophyId,
    required String? nextTrophyTitle,
    required List<TrophyRequirement>? nextTrophyRequirements,
    required double clampedFraction,
    required TrophyStyle trophyStyle,
    required TrophyStyle nextStyle,
    required int totalXp,
    required int currentStreak,
    required int longestStreak,
    required int unlockedTrophies,
    required int totalTrophies,
    required List<AchievementItem> achievements,
    required bool isDark,
    required double width,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── ROW 1: Current Trophy & Theme Toggle ─────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _buildCurrentTrophySection(
                highestTrophyId: highestTrophyId,
                highestTrophyTitle: highestTrophyTitle,
                nextTrophyTitle: nextTrophyTitle,
                trophyStyle: trophyStyle,
                isDark: isDark,
                isCompact: true,
                isFlexible: true,
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
        const SizedBox(height: 6),

        // ── ROW 2: Trophies Unlock (Full-Width Card) ─────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF141529).withValues(alpha: 0.65)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF6B47EB).withValues(alpha: 0.22)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: _buildTrophiesUnlockSection(
            unlockedTrophies: unlockedTrophies,
            totalTrophies: totalTrophies,
            fraction: clampedFraction,
            nextTrophyTitle: nextTrophyTitle,
            isDark: isDark,
            isCompact: true,
            isMobile: true,
          ),
        ),
        const SizedBox(height: 6),

        // ── ROW 3: Total XP Rewards & Streak (Side by Side) ──────────────────
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF141529).withValues(alpha: 0.65)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF6B47EB).withValues(alpha: 0.18)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: _buildTotalXpSection(
                  totalXp: totalXp,
                  isDark: isDark,
                  isCompact: true,
                  isFlexible: true,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF141529).withValues(alpha: 0.65)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFFF97316).withValues(alpha: 0.20)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: _buildStreakSection(
                  currentStreak: currentStreak,
                  longestStreak: longestStreak,
                  isDark: isDark,
                  isCompact: true,
                  isFlexible: true,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 3. CARD HUD MODE (Standalone / Modal / Dialog)
  Widget _buildCardLayout(
    BuildContext context, {
    required String? highestTrophyId,
    required String highestTrophyTitle,
    required String? nextTrophyId,
    required String? nextTrophyTitle,
    required List<TrophyRequirement>? nextTrophyRequirements,
    required double clampedFraction,
    required TrophyStyle trophyStyle,
    required TrophyStyle nextStyle,
    required int totalXp,
    required int currentStreak,
    required int longestStreak,
    required int unlockedTrophies,
    required int totalTrophies,
    required List<AchievementItem> achievements,
    required bool isDark,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < 780;

        return GlassCard(
          borderRadius: 18,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 18,
            vertical: isMobile ? 12 : 14,
          ),
          child: isMobile
              ? _buildMobileDeck(
                  context,
                  highestTrophyId: highestTrophyId,
                  highestTrophyTitle: highestTrophyTitle,
                  nextTrophyId: nextTrophyId,
                  nextTrophyTitle: nextTrophyTitle,
                  nextTrophyRequirements: nextTrophyRequirements,
                  clampedFraction: clampedFraction,
                  trophyStyle: trophyStyle,
                  nextStyle: nextStyle,
                  totalXp: totalXp,
                  currentStreak: currentStreak,
                  longestStreak: longestStreak,
                  unlockedTrophies: unlockedTrophies,
                  totalTrophies: totalTrophies,
                  achievements: achievements,
                  isDark: isDark,
                  width: width,
                )
              : _buildDesktopSingleRow(
                  context,
                  highestTrophyId: highestTrophyId,
                  highestTrophyTitle: highestTrophyTitle,
                  nextTrophyId: nextTrophyId,
                  nextTrophyTitle: nextTrophyTitle,
                  nextTrophyRequirements: nextTrophyRequirements,
                  clampedFraction: clampedFraction,
                  trophyStyle: trophyStyle,
                  nextStyle: nextStyle,
                  totalXp: totalXp,
                  currentStreak: currentStreak,
                  longestStreak: longestStreak,
                  unlockedTrophies: unlockedTrophies,
                  totalTrophies: totalTrophies,
                  achievements: achievements,
                  isDark: isDark,
                  isCompact: false,
                  effectiveLeading: leading,
                  effectiveTrailing: trailing,
                ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ─── 1. CURRENT TROPHY SECTION (Diamond / Prestige Trophy Crest) ───────────
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildCurrentTrophySection({
    required String? highestTrophyId,
    required String highestTrophyTitle,
    required String? nextTrophyTitle,
    required TrophyStyle trophyStyle,
    required bool isDark,
    required bool isCompact,
    bool isFlexible = false,
  }) {
    final isDiamond = highestTrophyId?.toLowerCase() == 'diamond';
    final glowColor = isDiamond ? const Color(0xFF22D3EE) : trophyStyle.color;

    final String trophyTooltipMsg;
    if (highestTrophyId == null ||
        highestTrophyTitle.toLowerCase().contains('unranked')) {
      trophyTooltipMsg =
          'Current Trophy: In Progress\nNext to Achieve: ${nextTrophyTitle ?? 'Bronze Trophy'}';
    } else if (nextTrophyTitle != null &&
        nextTrophyTitle.isNotEmpty &&
        nextTrophyTitle.toLowerCase() != highestTrophyTitle.toLowerCase()) {
      trophyTooltipMsg =
          'Current Trophy: $highestTrophyTitle\nNext to Achieve: $nextTrophyTitle';
    } else {
      trophyTooltipMsg =
          'Current Trophy: $highestTrophyTitle\nMaximum trophy milestone achieved! 💎';
    }

    final textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          highestTrophyTitle,
          style: AppTextStyles.subtitle2.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: isCompact ? 12.0 : 13.5,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            letterSpacing: -0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1F6CFA), // App Royal Blue
                Color(0xFF8B5CF6), // App Violet
                Color(0xFFC839F6), // App Electric Magenta
              ],
            ),
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.45),
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_rounded, color: Colors.white, size: 9.5),
              const SizedBox(width: 2.5),
              Text(
                'Current',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 9.0,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final tooltipWrappedText = Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      preferBelow: true,
      verticalOffset: 14,
      message: trophyTooltipMsg,
      child: textColumn,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Row(
        mainAxisSize: isFlexible ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Radiant 3D-effect Trophy Crest with hover scale animation (NO tooltip on hover)
          _HoverableTrophyCrest(
            trophyStyle: trophyStyle,
            glowColor: glowColor,
            isDark: isDark,
            isCompact: isCompact,
            isDiamond: isDiamond,
          ),
          const SizedBox(width: 7),

          // Informative tooltip attached to trophy title and badge
          if (isFlexible)
            Expanded(child: tooltipWrappedText)
          else
            tooltipWrappedText,
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ─── 2. TROPHIES UNLOCK SECTION (With Mini Trophies & Glowing Progress) ────
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTrophiesUnlockSection({
    required int unlockedTrophies,
    required int totalTrophies,
    required double fraction,
    required String? nextTrophyTitle,
    required bool isDark,
    required bool isCompact,
    bool isMobile = false,
  }) {
    final clamped = fraction.clamp(0.0, 1.0);
    final percent = (clamped * 100).toInt();
    final tooltipMsg =
        (nextTrophyTitle != null &&
            nextTrophyTitle.isNotEmpty &&
            unlockedTrophies < totalTrophies)
        ? '$unlockedTrophies of $totalTrophies Trophies Unlocked\nNext: $nextTrophyTitle ($percent% to unlock)'
        : 'All $totalTrophies Trophies Unlocked!\nMaximum prestige achieved 💎';

    return Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      preferBelow: true,
      verticalOffset: 14,
      message: tooltipMsg,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Glowing Golden Trophy Cup
            Container(
              width: isCompact ? 26 : 32,
              height: isCompact ? 26 : 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFF59E0B).withValues(alpha: 0.30),
                    const Color(0xFFF59E0B).withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: const Color(0xFFF59E0B),
                  size: isCompact ? 17 : 21,
                ),
              ),
            ),
            const SizedBox(width: 7),

            // Count & Label Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$unlockedTrophies / $totalTrophies',
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: isCompact ? 12.5 : 14.0,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  isCompact ? 'Trophies' : 'Trophies Unlocked',
                  style: AppTextStyles.caption.copyWith(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                    fontSize: isCompact ? 9.0 : 10.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            if (isMobile) const Spacer() else const SizedBox(width: 8),

            // Mini Trophies Row + Glowing Progress Bar Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    totalTrophies > 0 ? totalTrophies : 6,
                    (index) {
                      final isUnlocked = index < unlockedTrophies;
                      return Padding(
                        padding: const EdgeInsets.only(left: 2.5),
                        child: Icon(
                          Icons.emoji_events_rounded,
                          size: isCompact ? 11 : 12.5,
                          color: isUnlocked
                              ? const Color(0xFFF59E0B)
                              : (isDark
                                    ? const Color(
                                        0xFF6B47EB,
                                      ).withValues(alpha: 0.35)
                                    : const Color(0xFFCBD5E1)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 3.5),

                // Radiant Glowing Progress Bar directly under the mini trophies
                Container(
                  width: isCompact ? 72 : 86,
                  height: 5.0,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E1F38)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: clamped,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.5),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF6B47EB),
                              Color(0xFF8B5CF6),
                              Color(0xFFB838EE),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF8B5CF6,
                              ).withValues(alpha: 0.60),
                              blurRadius: 4,
                              offset: const Offset(0, 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ─── 3. TOTAL XP REWARDS SECTION ──────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTotalXpSection({
    required int totalXp,
    required bool isDark,
    required bool isCompact,
    bool isFlexible = false,
  }) {
    final formattedXp = _formatNumber(totalXp);

    final textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Total XP Rewards',
          style: AppTextStyles.caption.copyWith(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
            fontSize: isCompact ? 9.0 : 10.0,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                formattedXp,
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: isCompact ? 12.0 : 13.5,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 2.5),
            Text(
              'XP',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: isCompact ? 9.5 : 10.5,
                color: const Color(0xFFA855F7),
              ),
            ),
          ],
        ),
      ],
    );

    return Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      preferBelow: true,
      verticalOffset: 14,
      message:
          'Lifetime XP: $formattedXp XP\nEarned across sessions, milestones & quizzes',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          mainAxisSize: isFlexible ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Glowing Purple Hexagonal/Squircle Badge
            Container(
              width: isCompact ? 26 : 30,
              height: isCompact ? 26 : 30,
              decoration: BoxDecoration(
                color: const Color(0xFF6B47EB).withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.55),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B47EB).withValues(alpha: 0.35),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.star_rounded,
                  color: const Color(0xFFC084FC),
                  size: isCompact ? 14 : 16,
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Label & Value Column
            if (isFlexible) Expanded(child: textColumn) else textColumn,
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ─── 4. STREAK SECTION ────────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildStreakSection({
    required int currentStreak,
    required int longestStreak,
    required bool isDark,
    required bool isCompact,
    bool isFlexible = false,
  }) {
    final textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isCompact ? 'Streak' : 'Daily Streak',
          style: AppTextStyles.caption.copyWith(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
            fontSize: isCompact ? 9.0 : 10.0,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '$currentStreak Days',
          style: AppTextStyles.subtitle2.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: isCompact ? 12.0 : 13.5,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            letterSpacing: -0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    return Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      preferBelow: true,
      verticalOffset: 14,
      message:
          'Daily Streak: $currentStreak Days\nPersonal Best Record: $longestStreak Days',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          mainAxisSize: isFlexible ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Glowing Fiery Orange Hexagonal/Squircle Badge
            Container(
              width: isCompact ? 26 : 30,
              height: isCompact ? 26 : 30,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFF97316).withValues(alpha: 0.55),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF97316).withValues(alpha: 0.35),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.local_fire_department_rounded,
                  color: const Color(0xFFFB923C),
                  size: isCompact ? 14 : 16,
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Label & Value Column
            if (isFlexible) Expanded(child: textColumn) else textColumn,
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ─── REUSABLE UI PRIMITIVES ───────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      width: 1.0,
      height: 24,
      color: isDark
          ? const Color(0xFF6B47EB).withValues(alpha: 0.22)
          : const Color(0xFFE2E8F0),
    );
  }

  String _formatNumber(int number) {
    final str = number.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (Match m) => '${m[1]},');
  }
}

/// Interactive 3D Trophy Crest with springy hover scale animation.
///
/// On desktop/web hover, scales up specifically the 3D trophy image with an
/// elastic pop ([Curves.easeOutBack]) while maintaining layout stability.
class _HoverableTrophyCrest extends StatefulWidget {
  final TrophyStyle trophyStyle;
  final Color glowColor;
  final bool isDark;
  final bool isCompact;
  final bool isDiamond;

  const _HoverableTrophyCrest({
    required this.trophyStyle,
    required this.glowColor,
    required this.isDark,
    required this.isCompact,
    required this.isDiamond,
  });

  @override
  State<_HoverableTrophyCrest> createState() => _HoverableTrophyCrestState();
}

class _HoverableTrophyCrestState extends State<_HoverableTrophyCrest> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isCompact = widget.isCompact;
    final glowColor = widget.glowColor;
    final isDark = widget.isDark;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        clipBehavior: Clip.antiAlias,
        width: isCompact ? 36 : 46,
        height: isCompact ? 36 : 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              glowColor.withValues(alpha: _isHovered ? 0.48 : 0.35),
              glowColor.withValues(alpha: _isHovered ? 0.22 : 0.15),
              Colors.transparent,
            ],
            center: Alignment.center,
            radius: 0.85,
          ),
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(
                alpha: isDark
                    ? (_isHovered ? 0.55 : 0.40)
                    : (_isHovered ? 0.38 : 0.25),
              ),
              blurRadius: _isHovered ? 12 : 8,
              spreadRadius: _isHovered ? 1.0 : 0.5,
            ),
          ],
        ),
        child: Center(
          child: AnimatedScale(
            scale: _isHovered ? 1.25 : 1.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            child: widget.trophyStyle.assetPath != null
                ? Image.asset(
                    widget.trophyStyle.assetPath!,
                    width: isCompact ? 32 : 40,
                    height: isCompact ? 32 : 40,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Icon(
                      widget.isDiamond
                          ? Icons.diamond_rounded
                          : widget.trophyStyle.icon,
                      color: isDark ? Colors.white : glowColor,
                      size: isCompact ? 19 : 24,
                    ),
                  )
                : Icon(
                    widget.isDiamond
                        ? Icons.diamond_rounded
                        : widget.trophyStyle.icon,
                    color: isDark ? Colors.white : glowColor,
                    size: isCompact ? 19 : 24,
                  ),
          ),
        ),
      ),
    );
  }
}
