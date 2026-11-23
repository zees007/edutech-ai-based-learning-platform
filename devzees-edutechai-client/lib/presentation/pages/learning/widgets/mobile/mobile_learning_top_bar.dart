import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:devzees_edutechai_client/core/providers/dashboard_provider.dart';
import 'package:devzees_edutechai_client/data/models/learning/session_response.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/core/theme/theme_palette.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/presentation/widgets/theme_toggle_button.dart';
import 'package:devzees_edutechai_client/presentation/widgets/step_pill.dart';

/// A high-density, ultra-sleek Mobile Top Bar.
/// Features the official EduTechAI logo immediately following the hamburger icon
/// on the left side, with the active learning HUD and gamification badges on the right.
class MobileLearningTopBar extends ConsumerWidget
    implements PreferredSizeWidget {
  final SessionResponse? session;
  final int activeStepIndex;
  final VoidCallback? onOpenCommandHub;
  final bool? isDashboardOverride;

  const MobileLearningTopBar({
    super.key,
    required this.session,
    this.activeStepIndex = 0,
    this.onOpenCommandHub,
    this.isDashboardOverride,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1.0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSession = session != null;
    final isDark = context.isDarkMode;
    String location = '';
    try {
      location = GoRouterState.of(context).matchedLocation;
    } catch (_) {
      // In isolated tests without GoRouter state
    }
    final bool isDashboard =
        isDashboardOverride ??
        (location.startsWith('/learning/dashboard') ||
            location.startsWith('/dashboard'));

    return Material(
      color: AppColors.topBarBackground,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: kToolbarHeight,
              child: Row(
                children: [
                  // 1. Left: Hamburger Menu Icon
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Builder(
                      builder: (ctx) => IconButton(
                        icon: Icon(
                          Icons.menu_rounded,
                          color: AppColors.textSecondary,
                          size: 21,
                        ),
                        onPressed: () => Scaffold.of(ctx).openDrawer(),
                        tooltip: 'Open menu',
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: const EdgeInsets.all(6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // 2. Center / Left Content:
                  // On Dashboard: Show Web-matching Accent Icon Box + "Growth & Mastery Analytics" gradient text
                  // In Learning Session: Show EduTech AI logo + Centered Learning Capsule
                  // Otherwise: Show EduTech AI logo + Spacer
                  if (isDashboard) ...[
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1F6CFA).withValues(alpha: 0.22)
                            : AppColors.purple.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF60A5FA).withValues(alpha: 0.55)
                              : AppColors.purple.withValues(alpha: 0.35),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? const Color(0xFF1F6CFA).withValues(alpha: 0.35)
                                : AppColors.purple.withValues(alpha: 0.15),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.auto_graph_rounded,
                        color: isDark
                            ? const Color(0xFF38BDF8)
                            : AppColors.purple,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: GradientText(
                        'Growth & Mastery Analytics',
                        gradient: AppColors.primaryGradient,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.h4.copyWith(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ]
                  else ...[
                    _buildAppLogo(isCompact: hasSession),
                    if (hasSession)
                      Expanded(
                        child: Center(
                          child: _buildUnifiedCommandHubCapsule(context),
                        ),
                      )
                    else
                      const Spacer(),
                  ],

                  // 3. Right Actions:
                  // On Dashboard: Date Filter Icon + Refresh Icon + Theme Toggle
                  // Otherwise: Theme Toggle Button
                  if (isDashboard) ...[
                    _buildDateFilterIcon(context, ref, isDark),
                    _buildRefreshIcon(context, ref, isDark),
                    const SizedBox(width: 2),
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: ThemeToggleButton(size: 30),
                    ),
                  ] else
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: ThemeToggleButton(size: 30),
                    ),
                ],
              ),
            ),
            Container(color: AppColors.glassBorder, height: 1.0),
          ],
        ),
      ),
    );
  }

  // ─── DASHBOARD DATE FILTER ICON ───────────────────────────────────────────
  Widget _buildDateFilterIcon(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
  ) {
    final dashboardState = ref.watch(dashboardProvider);
    final activeRange = dashboardState.timeRange;
    final isCustom = activeRange == 'custom';

    return Theme(
      data: Theme.of(context).copyWith(
        hoverColor: AppColors.primary.withValues(alpha: 0.12),
        focusColor: AppColors.primary.withValues(alpha: 0.15),
        splashColor: AppColors.primary.withValues(alpha: 0.10),
        highlightColor: AppColors.primary.withValues(alpha: 0.10),
      ),
      child: PopupMenuButton<String>(
        tooltip: 'Time range filter',
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.date_range_rounded,
              size: 20,
              color: isCustom
                  ? (isDark ? AppColors.primary : AppColors.purple)
                  : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
            ),
            if (isCustom)
              Positioned(
                right: -1,
                top: -1,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.primary : AppColors.purple,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        color: AppColors.cardBackground,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide.none,
        ),
        onSelected: (value) async {
          if (value == 'custom') {
            await _selectCustomDateRange(context, ref);
          } else {
            ref.read(dashboardProvider.notifier).setTimeRange(value);
          }
        },
        itemBuilder: (context) => [
          _buildPopupItem('7d', 'Last 7 Days', activeRange, isDark),
          _buildPopupItem('30d', 'Last 30 Days', activeRange, isDark),
          _buildPopupItem('90d', 'Last 90 Days', activeRange, isDark),
          _buildPopupItem('1y', 'Last 1 Year', activeRange, isDark),
          _buildPopupItem('all', 'All Time', activeRange, isDark),
          const PopupMenuDivider(),
          _buildPopupItem('custom', 'Custom Range...', activeRange, isDark),
        ],
      ),
    );
  }

  // ─── DASHBOARD REFRESH ICON ───────────────────────────────────────────────
  Widget _buildRefreshIcon(BuildContext context, WidgetRef ref, bool isDark) {
    final dashboardState = ref.watch(dashboardProvider);
    final isRefreshing =
        dashboardState.isLoading && dashboardState.data != null;

    return IconButton(
      tooltip: 'Refresh analytics',
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
      icon: isRefreshing
          ? SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isDark
                    ? const Color(0xFF60A5FA)
                    : AppColors.purple,
              ),
            )
          : Icon(
              Icons.refresh_rounded,
              size: 20,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
            ),
      onPressed: isRefreshing
          ? null
          : () {
              ref.read(learnerStandingProvider.notifier).refresh();
              ref.read(dashboardProvider.notifier).refresh();
            },
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
      height: 38,
      child: Row(
        children: [
          if (isSelected)
            Icon(
              Icons.check_rounded,
              size: 16,
              color: isDark ? AppColors.primary : AppColors.purple,
            )
          else
            const SizedBox(width: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? (isDark ? AppColors.primary : AppColors.purple)
                  : AppColors.textPrimary,
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
    final twoYearsAgo = now.subtract(const Duration(days: 730));

    final picked = await showDateRangePicker(
      context: context,
      firstDate: twoYearsAgo,
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 30)),
        end: now,
      ),
      helpText: 'Select Learning Analytics Range (Max 2 Years)',
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: const Color(0xFF1E293B),
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: const Color(0xFF0F172A),
                  ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      final daysDiff = picked.end.difference(picked.start).inDays;
      if (daysDiff > 730) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Date range cannot exceed 2 years (730 days). Please select a narrower period.',
              ),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
        }
        return;
      }

      await ref
          .read(dashboardProvider.notifier)
          .setCustomDateRange(picked.start, picked.end);
    }
  }

  // ─── OFFICIAL APP LOGO (⚡ EduTech [AI]) ────────────────────────────────────
  Widget _buildAppLogo({bool isCompact = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '⚡ ',
          style: AppTextStyles.h4.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: isCompact ? 14 : 16,
          ),
        ),
        GradientText(
          'EduTech',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            fontSize: isCompact ? 14 : 16,
          ),
        ),
        const SizedBox(width: 3),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 3.5 : 5,
            vertical: isCompact ? 1.0 : 1.5,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(isCompact ? 4.5 : 6),
          ),
          child: Text(
            'AI',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: isCompact ? 8.5 : 9.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  // ─── UNIFIED COMMAND HUB CAPSULE (Interactive Pill in Center) ──────────────
  Widget _buildUnifiedCommandHubCapsule(BuildContext context) {
    final s = session!;
    final totalSteps = s.steps.isNotEmpty ? s.steps.length : 1;
    final currentStepNum = (activeStepIndex + 1).clamp(1, totalSteps);

    return Tooltip(
      message: 'Milestone Roadmap: ${s.topic}',
      child: GestureDetector(
        onTap: onOpenCommandHub,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 4.5),
          decoration: BoxDecoration(
            color: AppColors.sidebarBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Goal / Track icon
              Icon(
                Icons.track_changes_rounded,
                size: 13,
                color: AppColors.adaptiveBlueLight,
              ),
              const SizedBox(width: 4),

              // 2. Topic Name
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 85),
                  child: Text(
                    s.topic,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),

              // 3. Standardized Glowing Green Step Pill (e.g. 2/5)
              StepPill(
                currentStep: currentStepNum,
                totalSteps: totalSteps,
                isCompact: true,
              ),
              const SizedBox(width: 5),

              // 4. Elegant vertical hairline separator
              Container(
                width: 1.0,
                height: 10,
                color: AppColors.isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.12),
              ),
              const SizedBox(width: 5),

              // 5. XP Counter
              const Icon(
                Icons.star_rounded,
                size: 13,
                color: AppColors.accentAmber,
              ),
              const SizedBox(width: 2.5),
              Text(
                '${s.xpEarned}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accentAmber,
                ),
              ),
              const SizedBox(width: 3),

              // 6. Down Chevron Indicator
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 13,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
