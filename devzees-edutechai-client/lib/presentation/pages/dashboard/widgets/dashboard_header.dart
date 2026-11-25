import 'dart:ui';
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
              showBottomBorder: false,
              fallbackSummary: fallbackSummary,
              fallbackAchievements: fallbackAchievements,
              trailing: const ThemeToggleButton(size: 30),
            ),

            // ─── TIER 2: Analytics Filter Sub-Bar (Directly below Tier 1) ───
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 16 : (isMobile ? 10 : 14),
                vertical: isDesktop ? 8 : (isMobile ? 6 : 7),
              ),
              decoration: BoxDecoration(
                color: context.appColors.topBarBackground,
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? context.appColors.scaffoldBackground
                        : const Color(0xFFF1F5F9),
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
                      isCompact: constraints.maxWidth < 1100,
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
    bool isCompact = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: Context Block (Growth & Mastery Analytics) wrapped in Expanded
        Expanded(
          child: _buildContextBlock(
            context: context,
            isMobile: false,
            isCompact: isCompact,
          ),
        ),
        SizedBox(width: isCompact ? 8 : 12),
        // Right: Date Dropdown + Sync All Button
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
              isCompact: isCompact,
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _buildContextBlock(
            context: context,
            isMobile: false,
            isCompact: true,
          ),
        ),
        const SizedBox(width: 8),
        _DashboardDateDropdown(
          activeRange: activeRange,
          displayLabel: displayLabel,
          isMobile: true,
          onRangeChanged: (val) {
            ref.read(dashboardProvider.notifier).setTimeRange(val);
          },
          onSelectCustomRange: () => _selectCustomDateRange(context, ref),
          onResetCustomRange: () {
            ref.read(dashboardProvider.notifier).setTimeRange('30d');
          },
        ),
        const SizedBox(width: 6),
        _DashboardRefreshButton(
          isRefreshing: isRefreshing,
          onRefresh: onRefresh,
          isCompact: true,
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
              child: _buildContextBlock(
                context: context,
                isMobile: true,
                isCompact: true,
              ),
            ),
            const SizedBox(width: 6),
            _DashboardRefreshButton(
              isRefreshing: isRefreshing,
              onRefresh: onRefresh,
              isCompact: true,
            ),
          ],
        ),
        const SizedBox(height: 6),
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
    bool isCompact = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Glowing Gradient Hero Squircle Badge (Same in Light and Dark Mode)
        Container(
          width: isMobile ? 30 : (isCompact ? 32 : 36),
          height: isMobile ? 30 : (isCompact ? 32 : 36),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.leaderboard_rounded,
              color: Colors.white,
              size: isMobile ? 16 : (isCompact ? 17 : 19),
            ),
          ),
        ),
        SizedBox(width: isCompact ? 8 : 10),
        Flexible(
          child: Tooltip(
            triggerMode: TooltipTriggerMode.tap,
            message:
                'Growth & Mastery Analytics\nPerformance metrics, concept mastery, and quiz comprehension',
            child: GradientText(
              'Growth & Mastery Analytics',
              gradient: AppColors.primaryGradient,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.h4.copyWith(
                fontSize: isMobile ? 15.0 : (isCompact ? 17.0 : 19.0),
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
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
  final GlobalKey _dropdownKey = GlobalKey();
  bool _isHovered = false;

  void _showFilterDialog(BuildContext context, bool isDark) {
    final RenderBox? renderBox =
        _dropdownKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    showMenu<String>(
      context: context,
      color: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide.none,
      ),
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height + 4,
        MediaQuery.of(context).size.width - offset.dx - size.width,
        0,
      ),
      items: [
        PopupMenuItem<String>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: IconTheme(
            data: const IconThemeData(opacity: 1.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  width: 175,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.popoverBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.glassBorder,
                      width: 1.0,
                    ),
                    boxShadow: isDark
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : const [
                            BoxShadow(
                              color: Color(0x18000000),
                              blurRadius: 20,
                              offset: Offset(0, 8),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                              spreadRadius: 0,
                            ),
                          ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDialogItem(context, '7d', 'Last 7 Days', isDark),
                      _buildDialogItem(context, '30d', 'Last 30 Days', isDark),
                      _buildDialogItem(context, '90d', 'Last 90 Days', isDark),
                      _buildDialogItem(context, '1y', 'Last 1 Year', isDark),
                      _buildDialogItem(context, 'all', 'All Time', isDark),
                      _buildDialogItem(
                        context,
                        'custom',
                        'Custom Range...',
                        isDark,
                        onTapOverride: () {
                          widget.onSelectCustomRange();
                        },
                      ),
                      if (widget.activeRange == 'custom')
                        _buildDialogItem(
                          context,
                          'reset',
                          'Reset to 30 Days',
                          isDark,
                          onTapOverride: () {
                            widget.onResetCustomRange();
                          },
                          isDestructive: true,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogItem(
    BuildContext context,
    String value,
    String label,
    bool isDark, {
    VoidCallback? onTapOverride,
    bool isDestructive = false,
  }) {
    final isSelected = value == widget.activeRange;
    bool isItemHovered = false;
    final primaryAccent = isDark ? AppColors.primary : AppColors.purple;

    return StatefulBuilder(
      builder: (context, setItemState) {
        final Color bg = isSelected
            ? primaryAccent.withValues(alpha: isDark ? 0.20 : 0.12)
            : (isItemHovered
                  ? (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : primaryAccent.withValues(alpha: 0.08))
                  : Colors.transparent);

        final Color targetTextColor = isDestructive
            ? const Color(0xFFEF4444)
            : (isSelected
                  ? primaryAccent
                  : (isItemHovered
                        ? (isDark ? AppColors.textPrimary : primaryAccent)
                        : (isDark
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF334155))));

        return MouseRegion(
          onEnter: (_) => setItemState(() => isItemHovered = true),
          onExit: (_) => setItemState(() => isItemHovered = false),
          child: InkWell(
            onTap: () {
              Navigator.of(context).pop();
              if (onTapOverride != null) {
                onTapOverride();
              } else {
                widget.onRangeChanged(value);
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOut,
                      style: AppTextStyles.label.copyWith(
                        color: targetTextColor,
                        fontWeight: (isSelected || isItemHovered)
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_rounded, color: primaryAccent, size: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final primaryBlue = AppColors.primary;
    final purple = AppColors.purple;

    final Color borderColor = isDark
        ? (_isHovered ? primaryBlue : primaryBlue.withValues(alpha: 0.60))
        : (_isHovered ? purple : purple.withValues(alpha: 0.55));

    final Color iconColor = isDark ? primaryBlue : purple;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        key: _dropdownKey,
        onTap: () => _showFilterDialog(context, isDark),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isDark
                ? (_isHovered
                      ? primaryBlue.withValues(alpha: 0.16)
                      : primaryBlue.withValues(alpha: 0.08))
                : (_isHovered
                      ? purple.withValues(alpha: 0.10)
                      : purple.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1.0),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: (isDark ? primaryBlue : purple).withValues(
                    alpha: isDark ? 0.30 : 0.18,
                  ),
                  blurRadius: 8,
                  spreadRadius: 0.5,
                  offset: const Offset(0, 1),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: widget.fullWidth
                ? MainAxisSize.max
                : MainAxisSize.min,
            mainAxisAlignment: widget.fullWidth
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.start,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: (isDark ? primaryBlue : purple).withValues(
                    alpha: isDark ? 0.22 : 0.14,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Icon(
                    Icons.calendar_today_rounded,
                    size: 10.5,
                    color: iconColor,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                widget.displayLabel,
                style: AppTextStyles.subtitle2.copyWith(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: widget.isMobile ? 11.0 : 12.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 14,
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
    final primaryBlue = AppColors.primary;
    final purple = AppColors.purple;

    final Color borderColor = isDark
        ? (_isHovered ? primaryBlue : primaryBlue.withValues(alpha: 0.60))
        : (_isHovered ? purple : purple.withValues(alpha: 0.55));

    final Color iconColor = widget.isRefreshing
        ? (isDark ? const Color(0xFF22D3EE) : purple)
        : (isDark ? primaryBlue : purple);

    return Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      message: widget.isRefreshing
          ? 'Syncing learning analytics with latest progress...'
          : 'Sync All: refresh metrics and study records',
      child: MouseRegion(
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
            height: 32,
            padding: EdgeInsets.symmetric(
              horizontal: widget.isCompact ? 8 : 10,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? (_isHovered
                        ? primaryBlue.withValues(alpha: 0.16)
                        : primaryBlue.withValues(alpha: 0.08))
                  : (_isHovered
                        ? purple.withValues(alpha: 0.10)
                        : purple.withValues(alpha: 0.05)),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: 1.0),
              boxShadow: [
                if (_isHovered)
                  BoxShadow(
                    color: (isDark ? primaryBlue : purple).withValues(
                      alpha: isDark ? 0.30 : 0.18,
                    ),
                    blurRadius: 8,
                    spreadRadius: 0.5,
                    offset: const Offset(0, 1),
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: (isDark ? primaryBlue : purple).withValues(
                      alpha: widget.isRefreshing
                          ? 0.30
                          : (isDark ? 0.22 : 0.14),
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: RotationTransition(
                      turns: _animController,
                      child: Icon(
                        Icons.sync_rounded,
                        size: 11.5,
                        color: iconColor,
                      ),
                    ),
                  ),
                ),
                if (!widget.isCompact) ...[
                  const SizedBox(width: 6),
                  Text(
                    widget.isRefreshing ? 'Syncing...' : 'Sync All',
                    style: AppTextStyles.subtitle2.copyWith(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
