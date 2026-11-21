import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dashboard_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_palette.dart';
import '../../../../core/utils/trophy_utils.dart';
import '../../../../data/models/dashboard/dashboard_response.dart';
import '../../../widgets/gradient_text.dart';
import '../../../widgets/theme_toggle_button.dart';

/// Dedicated, ultra-premium Mobile Top Bar for the Learning Dashboard.
///
/// Features a high-density, multi-tier executive layout:
/// - Tier 1: Drawer Hamburger Menu, Radiant Prestige Trophy Crest, Title & Total XP,
///   Fiery Streak flame chip, and Theme Toggle Button.
/// - Tier 2: Analytics Context ("Growth & Mastery Analytics"), Period Date Filter chip,
///   and Live Sync / Refresh button.
/// - Seam Progress Track: Micro-height illuminated progress bar showing progression
///   toward the next milestone trophy tier.
class MobileDashboardTopBar extends ConsumerWidget
    implements PreferredSizeWidget {
  const MobileDashboardTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(98.0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;
    final standingAsync = ref.watch(learnerStandingProvider);
    final dashboardState = ref.watch(dashboardProvider);
    final activeRange = dashboardState.timeRange;
    final isRefreshing = dashboardState.isLoading && dashboardState.data != null;

    final standing = standingAsync.asData?.value;
    final fallbackSummary = dashboardState.data?.summary;
    final fallbackAchievements = dashboardState.data?.achievements;

    final highestTrophyId = standing?.highestTrophyId ??
        _resolveFallbackHighestTrophyId(fallbackAchievements);
    final highestTrophyTitle = standing?.highestTrophyTitle ??
        _resolveFallbackHighestTrophyTitle(fallbackAchievements);
    final nextTrophyId = standing?.nextTrophyId;
    final nextTrophyTitle = standing?.nextTrophyTitle ?? 'Bronze Trophy';
    final trophyProgressFraction = standing?.trophyProgressFraction ?? 0.0;
    final totalXp = standing?.totalXp ?? (fallbackSummary?.totalXp ?? 0);
    final currentStreak = standing?.currentStreak ?? (fallbackSummary?.currentStreak ?? 0);
    final longestStreak = standing?.longestStreak ?? (fallbackSummary?.longestStreak ?? 0);

    final trophyStyle = getTrophyStyle(highestTrophyId);
    final nextStyle = getTrophyStyle(nextTrophyId);
    final clampedFraction = trophyProgressFraction.clamp(0.0, 1.0);

    return Material(
      color: context.appColors.topBarBackground,
      child: SafeArea(
        bottom: false,
        child: Container(
          decoration: BoxDecoration(
            color: context.appColors.topBarBackground,
            border: Border(
              bottom: BorderSide(
                color: context.appColors.border.withValues(alpha: 0.65),
                width: 1.0,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── TIER 1: Learner Standing & Identity Row (Height: 46px) ───
              SizedBox(
                height: 46,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Hamburger Drawer Button
                      IconButton(
                        icon: Icon(
                          Icons.menu_rounded,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          size: 21,
                        ),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        tooltip: 'Open navigation menu',
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 4),

                      // Radiant Prestige Trophy Crest
                      Tooltip(
                        message: 'Current Prestige: $highestTrophyTitle\nAll-time highest unlocked milestone achievement tier',
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                trophyStyle.color,
                                trophyStyle.color.withValues(alpha: 0.75),
                                trophyStyle.color.withValues(alpha: 0.55),
                              ],
                              center: const Alignment(-0.25, -0.30),
                              radius: 0.90,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: trophyStyle.color.withValues(alpha: 0.40),
                                blurRadius: 6,
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
                              trophyStyle.icon,
                              color: Colors.white,
                              size: 14.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Trophy Title (Flexible with ellipsis truncation)
                      Flexible(
                        child: Tooltip(
                          message: 'Current Standing: $highestTrophyTitle\nLifetime Achievement Prestige Rank',
                          child: Text(
                            highestTrophyTitle,
                            style: AppTextStyles.subtitle2.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 13.0,
                              color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // XP Gem Capsule
                      Tooltip(
                        message: 'Total XP: $totalXp XP\nEarned across all completed journeys, milestones, and quizzes',
                        child: Container(
                          height: 24,
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accentAmber.withValues(alpha: 0.16),
                                AppColors.accentAmber.withValues(alpha: 0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.accentAmber.withValues(alpha: 0.38),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: AppColors.accentAmber,
                                size: 12,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '$totalXp XP',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.accentAmber,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Streak Flame Chip
                      Tooltip(
                        message: 'Active Study Streak: $currentStreak days\nPersonal Best Record: $longestStreak days consecutive learning',
                        child: Container(
                          height: 25,
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFEF4444).withValues(alpha: 0.15),
                                const Color(0xFFF97316).withValues(alpha: 0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.30),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.local_fire_department_rounded,
                                color: Color(0xFFEF4444),
                                size: 14,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${currentStreak}d',
                                style: AppTextStyles.caption.copyWith(
                                  color: const Color(0xFFEF4444),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Theme Toggle Button
                      const ThemeToggleButton(size: 28),
                    ],
                  ),
                ),
              ),

              // ─── TIER 2: Analytics Context & Date Filter Row (Height: 46px) ───
              Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF141624).withValues(alpha: 0.70)
                      : const Color(0xFFF1F5F9).withValues(alpha: 0.70),
                  border: Border(
                    top: BorderSide(
                      color: context.appColors.border.withValues(alpha: 0.40),
                      width: 1.0,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon Box + Gradient Title
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF191B2B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDark ? const Color(0x1FFFFFFF) : const Color(0xFFE2E8F0),
                          width: 1.0,
                        ),
                      ),
                      child: Icon(
                        Icons.auto_graph_rounded,
                        color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8),
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Tooltip(
                        message: 'Growth & Mastery Analytics\nTrack study velocity, quiz comprehension, and skill mastery',
                        child: GradientText(
                          'Growth & Mastery Analytics',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                          gradient: isDark
                              ? AppColors.primaryGradient
                              : const LinearGradient(
                                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Date Filter Chip
                    _buildDateFilterChip(context, ref, activeRange, isDark),
                    const SizedBox(width: 4),

                    // Live Sync Refresh Button
                    Tooltip(
                      message: isRefreshing ? 'Syncing learning analytics...' : 'Sync & refresh analytics',
                      child: IconButton(
                        icon: isRefreshing
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                              )
                            : Icon(
                                Icons.refresh_rounded,
                                size: 18,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                        onPressed: isRefreshing
                            ? null
                            : () {
                                ref.read(learnerStandingProvider.notifier).refresh();
                                ref.read(dashboardProvider.notifier).refresh();
                              },
                        constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),

              // ─── SEAM: Illuminated Milestone Progression Track (Height: 5px) ───
              Tooltip(
                message: nextTrophyTitle != null
                    ? 'Next Prestige Milestone: $nextTrophyTitle • ${(clampedFraction * 100).toInt()}% towards unlocking'
                    : 'Maximum Prestige Diamond Trophy Unlocked 💎',
                child: Container(
                  height: 4.5,
                  width: double.infinity,
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: clampedFraction,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            nextStyle.color,
                            nextStyle.color.withValues(alpha: 0.85),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: nextStyle.color.withValues(alpha: 0.40),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateFilterChip(
    BuildContext context,
    WidgetRef ref,
    String activeRange,
    bool isDark,
  ) {
    String displayLabel;
    switch (activeRange) {
      case '7d':
        displayLabel = '7 Days';
        break;
      case '90d':
        displayLabel = '90 Days';
        break;
      case '1y':
        displayLabel = '1 Year';
        break;
      case 'all':
        displayLabel = 'All Time';
        break;
      case 'custom':
        displayLabel = 'Custom';
        break;
      case '30d':
      default:
        displayLabel = '30 Days';
        break;
    }

    return Theme(
      data: Theme.of(context).copyWith(
        hoverColor: AppColors.primary.withValues(alpha: 0.12),
      ),
      child: PopupMenuButton<String>(
        tooltip: 'Select date filter period (controls metrics below)',
        offset: const Offset(0, 36),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? const Color(0x28FFFFFF) : const Color(0xFFE2E8F0),
            width: 1.0,
          ),
        ),
        color: isDark ? const Color(0xFF1E2138) : Colors.white,
        onSelected: (val) {
          if (val == 'custom') {
            _selectCustomDateRange(context, ref);
          } else {
            ref.read(dashboardProvider.notifier).setTimeRange(val);
          }
        },
        itemBuilder: (context) => [
          _buildPopupItem('7d', 'Last 7 Days', activeRange, isDark),
          _buildPopupItem('30d', 'Last 30 Days', activeRange, isDark),
          _buildPopupItem('90d', 'Last 90 Days', activeRange, isDark),
          _buildPopupItem('1y', 'Last 1 Year', activeRange, isDark),
          _buildPopupItem('all', 'All Time', activeRange, isDark),
        ],
        child: Container(
          height: 27,
          padding: const EdgeInsets.symmetric(horizontal: 7),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2138) : Colors.white,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.40),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 11.0,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4.0),
              Text(
                displayLabel,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 10.5,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 13,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(
    String value,
    String label,
    String activeRange,
    bool isDark,
  ) {
    final isSelected = activeRange == value;
    return PopupMenuItem<String>(
      value: value,
      height: 36,
      child: Row(
        children: [
          if (isSelected)
            const Icon(Icons.check_rounded, size: 14, color: AppColors.primary)
          else
            const SizedBox(width: 14),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectCustomDateRange(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 730)),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 30)),
        end: now,
      ),
    );
    if (picked != null) {
      await ref.read(dashboardProvider.notifier).setCustomDateRange(picked.start, picked.end);
    }
  }

  String? _resolveFallbackHighestTrophyId(List<AchievementItem>? achievements) {
    if (achievements == null) return null;
    const order = ['diamond', 'sapphire', 'platinum', 'gold', 'silver', 'bronze'];
    for (final id in order) {
      if (achievements.any((a) => a.id == id && a.unlocked)) {
        return id;
      }
    }
    return null;
  }

  String _resolveFallbackHighestTrophyTitle(List<AchievementItem>? achievements) {
    if (achievements == null) return 'Unranked';
    const order = ['diamond', 'sapphire', 'platinum', 'gold', 'silver', 'bronze'];
    for (final id in order) {
      final match = achievements.where((a) => a.id == id && a.unlocked).firstOrNull;
      if (match != null) return match.title;
    }
    return 'Unranked';
  }
}
