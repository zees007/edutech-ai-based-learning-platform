import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dashboard_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_palette.dart';
import '../../../../core/utils/trophy_utils.dart';
import '../../../widgets/gradient_text.dart';
import '../../../widgets/theme_toggle_button.dart';
import 'learner_standing_hud.dart';

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
  Size get preferredSize => const Size.fromHeight(104.0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;
    final standingAsync = ref.watch(learnerStandingProvider);
    final dashboardState = ref.watch(dashboardProvider);
    final activeRange = dashboardState.timeRange;
    final isRefreshing =
        dashboardState.isLoading && dashboardState.data != null;

    final standing = standingAsync.asData?.value;
    final fallbackSummary = dashboardState.data?.summary;
    final fallbackAchievements = dashboardState.data?.achievements;

    final nextTrophyId = standing?.nextTrophyId;
    final nextTrophyTitle = standing?.nextTrophyTitle;
    final trophyProgressFraction = standing?.trophyProgressFraction ?? 0.0;
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
              // ─── TIER 1: Redesigned Learner Standing HUD (Option 1 Sleek) ───
              LearnerStandingHud(
                isTopBar: true,
                showBottomBorder: false,
                showHamburgerOnMobile: true,
                fallbackSummary: fallbackSummary,
                fallbackAchievements: fallbackAchievements,
                trailing: const ThemeToggleButton(size: 28),
              ),

              // ─── TIER 2: Analytics Context & Date Filter Row (Height: 44px) ───
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0C0D1A)
                      : context.appColors.topBarBackground,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? context.appColors.scaffoldBackground
                          : const Color(0xFFF1F5F9),
                      width: 1.0,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Glowing Squircle Accent Badge
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F6CFA).withValues(
                          alpha: isDark ? 0.22 : 0.12,
                        ),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF60A5FA).withValues(alpha: 0.55)
                              : const Color(0xFF2563EB).withValues(alpha: 0.35),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1F6CFA).withValues(
                              alpha: isDark ? 0.35 : 0.15,
                            ),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.auto_graph_rounded,
                          color: isDark
                              ? const Color(0xFF38BDF8)
                              : const Color(0xFF1D4ED8),
                          size: 14.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Tooltip(
                        message:
                            'Growth & Mastery Analytics\nTrack study velocity, quiz comprehension, and skill mastery',
                        child: GradientText(
                          'Growth & Mastery Analytics',
                          gradient: isDark
                              ? AppColors.primaryGradient
                              : const LinearGradient(
                                  colors: [
                                    Color(0xFF4F46E5),
                                    Color(0xFF7C3AED),
                                  ],
                                ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.h4.copyWith(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Date Filter Chip
                    _buildDateFilterChip(context, ref, activeRange, isDark),
                    const SizedBox(width: 5),

                    // Live Sync All Refresh Button
                    Tooltip(
                      message: isRefreshing
                          ? 'Syncing learning analytics...'
                          : 'Sync All: refresh learning analytics',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(7),
                        onTap: isRefreshing
                            ? null
                            : () {
                                ref
                                    .read(learnerStandingProvider.notifier)
                                    .refresh();
                                ref.read(dashboardProvider.notifier).refresh();
                              },
                        child: Container(
                          height: 28,
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.primary.withValues(alpha: 0.12)
                                : AppColors.purple.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.primary.withValues(alpha: 0.60)
                                  : AppColors.purple.withValues(alpha: 0.55),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isRefreshing)
                                const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF22D3EE),
                                  ),
                                )
                              else
                                Icon(
                                  Icons.sync_rounded,
                                  size: 13,
                                  color: isDark
                                      ? AppColors.primary
                                      : AppColors.purple,
                                ),
                            ],
                          ),
                        ),
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
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.04),
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
      data: Theme.of(
        context,
      ).copyWith(hoverColor: const Color(0xFF6B47EB).withValues(alpha: 0.12)),
      child: PopupMenuButton<String>(
        tooltip: 'Select date filter period (controls metrics below)',
        offset: const Offset(0, 36),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark
                ? const Color(0xFF6B47EB).withValues(alpha: 0.35)
                : const Color(0xFFE2E8F0),
            width: 1.0,
          ),
        ),
        color: isDark ? const Color(0xFF0C0D1A) : Colors.white,
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
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 7),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.purple.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: isDark
                  ? AppColors.primary.withValues(alpha: 0.60)
                  : AppColors.purple.withValues(alpha: 0.55),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 10.5,
                color: isDark
                    ? AppColors.primary
                    : AppColors.purple,
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
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
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

  Future<void> _selectCustomDateRange(
    BuildContext context,
    WidgetRef ref,
  ) async {
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
      await ref
          .read(dashboardProvider.notifier)
          .setCustomDateRange(picked.start, picked.end);
    }
  }
}
