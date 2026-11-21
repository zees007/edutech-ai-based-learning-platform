import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dashboard_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_palette.dart';
import '../../../../data/models/dashboard/dashboard_response.dart';
import '../../../widgets/gradient_text.dart';
import '../../../widgets/theme_toggle_button.dart';
import 'learner_standing_hud.dart';

/// Consolidated, ultra-premium Analytics Command Hub Header.
///
/// Features a two-tier persistent architecture:
/// - TIER 1: All-Time Learner Standing HUD Top Bar with prestige trophy title,
///   total XP badge, next milestone progress, streaks, and the Theme Toggle Button
///   pinned at the top right.
/// - TIER 2: Analytics Filter Sub-Bar placed directly below Tier 1, featuring
///   the "Growth & Mastery Analytics" title, period date range dropdown, and sync button.
class DashboardHeader extends ConsumerWidget {
  final VoidCallback onRefresh;
  final bool isRefreshing;
  final DashboardSummary? fallbackSummary;
  final List<AchievementItem>? fallbackAchievements;

  const DashboardHeader({
    super.key,
    required this.onRefresh,
    this.isRefreshing = false,
    this.fallbackSummary,
    this.fallbackAchievements,
  });

  BoxDecoration _buildPillDecoration(BuildContext context) {
    final isDark = context.isDarkMode;
    return BoxDecoration(
      color: isDark ? const Color(0xFF191B2B) : const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: isDark ? const Color(0x1FFFFFFF) : const Color(0xFFE2E8F0),
        width: 1.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;
    final dashboardState = ref.watch(dashboardProvider);
    final activeRange = dashboardState.timeRange;
    final customStart = dashboardState.customStart;
    final customEnd = dashboardState.customEnd;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 950;
        final isMobile = constraints.maxWidth < 600;

        String displayLabel;
        if (activeRange == 'custom' &&
            customStart != null &&
            customEnd != null) {
          if (isMobile) {
            displayLabel =
                '${_formatShortMonthDay(customStart)} – ${_formatShortMonthDay(customEnd)}';
          } else {
            displayLabel =
                '${_formatFullMonthDay(customStart)} – ${_formatFullMonthDay(customEnd)}';
          }
        } else {
          switch (activeRange) {
            case '7d':
              displayLabel = 'Last 7 Days';
              break;
            case '90d':
              displayLabel = 'Last 90 Days';
              break;
            case '1y':
              displayLabel = 'Last 1 Year';
              break;
            case 'all':
              displayLabel = 'All Time';
              break;
            case '30d':
            default:
              displayLabel = 'Last 30 Days';
              break;
          }
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── TIER 1: Pinned Learner Standing Top Bar (With Theme Toggle at right) ───
            LearnerStandingHud(
              isTopBar: true,
              fallbackSummary: fallbackSummary,
              fallbackAchievements: fallbackAchievements,
              trailing: const ThemeToggleButton(size: 30),
            ),

            // ─── TIER 2: Analytics Filter Sub-Bar (Directly below Tier 1) ───
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24,
                vertical: isMobile ? 8 : 9,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131525) : const Color(0xFFF8FAFC),
                border: Border(
                  bottom: BorderSide(
                    color: context.appColors.border.withValues(alpha: 0.7),
                    width: 1.0,
                  ),
                ),
              ),
              child: isDesktop
                  ? _buildDesktopSubBar(
                      context: context,
                      ref: ref,
                      activeRange: activeRange,
                      displayLabel: displayLabel,
                      isDark: isDark,
                    )
                  : isMobile
                  ? _buildMobileSubBar(
                      context: context,
                      ref: ref,
                      activeRange: activeRange,
                      displayLabel: displayLabel,
                      isDark: isDark,
                    )
                  : _buildTabletSubBar(
                      context: context,
                      ref: ref,
                      activeRange: activeRange,
                      displayLabel: displayLabel,
                      isDark: isDark,
                    ),
            ),
          ],
        );
      },
    );
  }

  // ─── DESKTOP SUB-BAR ────────────────────────────────────────────────────────
  Widget _buildDesktopSubBar({
    required BuildContext context,
    required WidgetRef ref,
    required String activeRange,
    required String displayLabel,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: Context Block (Growth & Mastery Analytics) wrapped in Expanded
        Expanded(
          child: _buildContextBlock(context: context, isMobile: false),
        ),
        const SizedBox(width: 16),
        // Right: Date Dropdown + Refresh Button (Theme toggle is pinned above in Tier 1)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DashboardDateDropdown(
              activeRange: activeRange,
              displayLabel: displayLabel,
              isMobile: false,
              onRangeChanged: (val) {
                ref.read(dashboardProvider.notifier).setTimeRange(val);
              },
              onSelectCustomRange: () => _selectCustomDateRange(context, ref),
              onResetCustomRange: () {
                ref.read(dashboardProvider.notifier).setTimeRange('30d');
              },
            ),
            const SizedBox(width: 8),
            _DashboardRefreshButton(
              isRefreshing: isRefreshing,
              onRefresh: onRefresh,
            ),
          ],
        ),
      ],
    );
  }

  // ─── TABLET SUB-BAR ─────────────────────────────────────────────────────────
  Widget _buildTabletSubBar({
    required BuildContext context,
    required WidgetRef ref,
    required String activeRange,
    required String displayLabel,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildContextBlock(context: context, isMobile: false),
        const SizedBox(height: 8),
        Row(
          children: [
            _DashboardDateDropdown(
              activeRange: activeRange,
              displayLabel: displayLabel,
              isMobile: false,
              onRangeChanged: (val) {
                ref.read(dashboardProvider.notifier).setTimeRange(val);
              },
              onSelectCustomRange: () => _selectCustomDateRange(context, ref),
              onResetCustomRange: () {
                ref.read(dashboardProvider.notifier).setTimeRange('30d');
              },
            ),
            const SizedBox(width: 8),
            _DashboardRefreshButton(
              isRefreshing: isRefreshing,
              onRefresh: onRefresh,
            ),
          ],
        ),
      ],
    );
  }

  // ─── MOBILE SUB-BAR ─────────────────────────────────────────────────────────
  Widget _buildMobileSubBar({
    required BuildContext context,
    required WidgetRef ref,
    required String activeRange,
    required String displayLabel,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildContextBlock(context: context, isMobile: true),
            ),
            const SizedBox(width: 6),
            _DashboardRefreshButton(
              isRefreshing: isRefreshing,
              onRefresh: onRefresh,
              isCompact: true,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _DashboardDateDropdown(
          activeRange: activeRange,
          displayLabel: displayLabel,
          isMobile: true,
          fullWidth: true,
          onRangeChanged: (val) {
            ref.read(dashboardProvider.notifier).setTimeRange(val);
          },
          onSelectCustomRange: () => _selectCustomDateRange(context, ref),
          onResetCustomRange: () {
            ref.read(dashboardProvider.notifier).setTimeRange('30d');
          },
        ),
      ],
    );
  }

  // ─── CONTEXT & IDENTITY BLOCK ──────────────────────────────────────────────
  Widget _buildContextBlock({
    required BuildContext context,
    bool isMobile = false,
  }) {
    final isDark = context.isDarkMode;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Accent Icon Box
        Container(
          width: isMobile ? 32 : 36,
          height: isMobile ? 32 : 36,
          alignment: Alignment.center,
          decoration: _buildPillDecoration(context),
          child: Icon(
            Icons.auto_graph_rounded,
            color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8),
            size: isMobile ? 17 : 19,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: GradientText(
            'Growth & Mastery Analytics',
            gradient: isDark
                ? AppColors.primaryGradient
                : const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                  ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (isMobile
                    ? AppTextStyles.subtitle2
                    : AppTextStyles.h4)
                .copyWith(
                  fontSize: isMobile ? 15.0 : 18.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
          ),
        ),
      ],
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

  String _formatShortMonthDay(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$m/$day';
  }

  String _formatFullMonthDay(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final m = months[d.month - 1];
    return '$m ${d.day}, ${d.year}';
  }
}

/// Unified Theme Date Dropdown matching [_CompactThemeDropdown] from journey_prompt_card.
class _DashboardDateDropdown extends StatefulWidget {
  final String activeRange;
  final String displayLabel;
  final bool isMobile;
  final bool fullWidth;
  final void Function(String) onRangeChanged;
  final Future<void> Function() onSelectCustomRange;
  final VoidCallback onResetCustomRange;

  const _DashboardDateDropdown({
    required this.activeRange,
    required this.displayLabel,
    this.isMobile = false,
    this.fullWidth = false,
    required this.onRangeChanged,
    required this.onSelectCustomRange,
    required this.onResetCustomRange,
  });

  @override
  State<_DashboardDateDropdown> createState() => _DashboardDateDropdownState();
}

class _DashboardDateDropdownState extends State<_DashboardDateDropdown> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDark
              ? (_isHovered ? const Color(0xFF262842) : const Color(0xFF1A1B2C))
              : (_isHovered ? Colors.white : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primary.withValues(
              alpha: isDark
                  ? (_isHovered ? 0.70 : 0.40)
                  : (_isHovered ? 0.60 : 0.35),
            ),
            width: 1.2,
          ),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: isDark ? 0.28 : 0.16,
                ),
                blurRadius: 12,
                spreadRadius: 1,
                offset: Offset.zero,
              ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            hoverColor: AppColors.primary.withValues(alpha: 0.12),
            splashColor: AppColors.primary.withValues(alpha: 0.20),
            highlightColor: Colors.transparent,
          ),
          child: PopupMenuButton<String>(
            tooltip: 'Select date filter',
            offset: const Offset(0, 46),
            position: PopupMenuPosition.under,
            elevation: 12,
            shadowColor: Colors.black.withValues(alpha: 0.35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: AppColors.primary.withValues(alpha: isDark ? 0.45 : 0.30),
                width: 1.2,
              ),
            ),
            color: isDark ? const Color(0xFF1E2138) : Colors.white,
            onSelected: (value) {
              if (value == 'custom') {
                widget.onSelectCustomRange();
              } else {
                widget.onRangeChanged(value);
              }
            },
            itemBuilder: (context) => [
              _buildMenuItem(
                context: context,
                value: '7d',
                icon: Icons.calendar_view_week_rounded,
                label: 'Last 7 Days',
                subLabel: 'Recent momentum',
                isSelected: widget.activeRange == '7d',
                isDark: isDark,
              ),
              _buildMenuItem(
                context: context,
                value: '30d',
                icon: Icons.calendar_month_rounded,
                label: 'Last 30 Days',
                subLabel: 'Standard monthly view',
                isSelected: widget.activeRange == '30d',
                isDark: isDark,
              ),
              _buildMenuItem(
                context: context,
                value: '90d',
                icon: Icons.date_range_rounded,
                label: 'Last 90 Days',
                subLabel: 'Quarterly progress',
                isSelected: widget.activeRange == '90d',
                isDark: isDark,
              ),
              _buildMenuItem(
                context: context,
                value: '1y',
                icon: Icons.history_rounded,
                label: 'Last 1 Year',
                subLabel: 'Annual retrospective',
                isSelected: widget.activeRange == '1y',
                isDark: isDark,
              ),
              _buildMenuItem(
                context: context,
                value: 'all',
                icon: Icons.all_inclusive_rounded,
                label: 'All Time',
                subLabel: 'Complete learning history',
                isSelected: widget.activeRange == 'all',
                isDark: isDark,
              ),
              const PopupMenuDivider(height: 1),
              _buildMenuItem(
                context: context,
                value: 'custom',
                icon: Icons.tune_rounded,
                label: 'Custom Range...',
                subLabel: widget.activeRange == 'custom'
                    ? widget.displayLabel
                    : 'Choose start & end dates',
                isSelected: widget.activeRange == 'custom',
                isDark: isDark,
                trailing: widget.activeRange == 'custom'
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: AppColors.accentRose,
                        ),
                        tooltip: 'Reset to 30 days',
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onResetCustomRange();
                        },
                      )
                    : null,
              ),
            ],
            child: Row(
              mainAxisSize:
                  widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: widget.fullWidth
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 15,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.displayLabel,
                  style: AppTextStyles.button.copyWith(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: widget.isMobile ? 12.0 : 13.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem({
    required BuildContext context,
    required String value,
    required IconData icon,
    required String label,
    required String subLabel,
    required bool isSelected,
    required bool isDark,
    Widget? trailing,
  }) {
    return PopupMenuItem<String>(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      height: 48,
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.15)
                  : (isDark ? const Color(0xFF262842) : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(
              icon,
              size: 15,
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.body2.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? Colors.white : const Color(0xFF0F172A)),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  subLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null)
            trailing
          else if (isSelected)
            const Icon(
              Icons.check_rounded,
              color: AppColors.primary,
              size: 16,
            ),
        ],
      ),
    );
  }
}

/// Dynamic Live Sync / Refresh button with micro-animation and state feedback.
class _DashboardRefreshButton extends StatefulWidget {
  final bool isRefreshing;
  final VoidCallback onRefresh;
  final bool isCompact;

  const _DashboardRefreshButton({
    required this.isRefreshing,
    required this.onRefresh,
    this.isCompact = false,
  });

  @override
  State<_DashboardRefreshButton> createState() =>
      _DashboardRefreshButtonState();
}

class _DashboardRefreshButtonState extends State<_DashboardRefreshButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.isRefreshing) {
      _animController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _DashboardRefreshButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRefreshing && !_animController.isAnimating) {
      _animController.repeat();
    } else if (!widget.isRefreshing && _animController.isAnimating) {
      _animController.stop();
      _animController.reset();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.isRefreshing
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.isRefreshing ? null : widget.onRefresh,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: 38,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCompact ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? (_isHovered
                    ? const Color(0xFF262842)
                    : const Color(0xFF1A1B2C))
                : (_isHovered ? Colors.white : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark
                  ? (_isHovered
                      ? const Color(0xFF4A4E69)
                      : const Color(0x1FFFFFFF))
                  : (_isHovered
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xFFE2E8F0)),
              width: 1.0,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotationTransition(
                turns: _animController,
                child: Icon(
                  Icons.sync_rounded,
                  size: 16,
                  color: widget.isRefreshing
                      ? AppColors.primary
                      : (isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B)),
                ),
              ),
              if (!widget.isCompact) ...[
                const SizedBox(width: 6),
                Text(
                  widget.isRefreshing ? 'Syncing...' : 'Sync',
                  style: AppTextStyles.button.copyWith(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
