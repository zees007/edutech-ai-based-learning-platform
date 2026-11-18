import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dashboard_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_palette.dart';
import '../../../widgets/gradient_text.dart';
import '../../../widgets/theme_toggle_button.dart';

/// Consolidated, ultra-premium Analytics Command Hub Header.
/// Features a prominent gradient title, unified theme date dropdown matching
/// [_CompactThemeDropdown] from journey_prompt_card, and smooth hover micro-animations.
class DashboardHeader extends ConsumerWidget {
  final VoidCallback onRefresh;
  final bool isRefreshing;

  const DashboardHeader({
    super.key,
    required this.onRefresh,
    this.isRefreshing = false,
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

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: isMobile ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: context.appColors.topBarBackground,
            border: Border(
              bottom: BorderSide(color: context.appColors.border, width: 1.0),
            ),
          ),
          child: isDesktop
              ? _buildDesktopView(
                  context: context,
                  ref: ref,
                  activeRange: activeRange,
                  displayLabel: displayLabel,
                  isDark: isDark,
                )
              : isMobile
              ? _buildMobileView(
                  context: context,
                  ref: ref,
                  activeRange: activeRange,
                  displayLabel: displayLabel,
                  isDark: isDark,
                )
              : _buildTabletView(
                  context: context,
                  ref: ref,
                  activeRange: activeRange,
                  displayLabel: displayLabel,
                  isDark: isDark,
                ),
        );
      },
    );
  }

  // ─── DESKTOP VIEW ──────────────────────────────────────────────────────────
  Widget _buildDesktopView({
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
          child: _buildContextBlock(context: context, isMobile: false),
        ),
        const SizedBox(width: 16),
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
            const SizedBox(width: 8),
            const ThemeToggleButton(size: 30),
          ],
        ),
      ],
    );
  }

  // ─── TABLET VIEW ───────────────────────────────────────────────────────────
  Widget _buildTabletView({
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
              child: _buildContextBlock(context: context, isMobile: false),
            ),
            const SizedBox(width: 8),
            const ThemeToggleButton(size: 30),
          ],
        ),
        const SizedBox(height: 10),
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

  // ─── MOBILE VIEW ───────────────────────────────────────────────────────────
  Widget _buildMobileView({
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
            const SizedBox(width: 6),
            const ThemeToggleButton(size: 30),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Accent Icon Box
        Container(
          width: isMobile ? 34 : 38,
          height: isMobile ? 34 : 38,
          alignment: Alignment.center,
          decoration: _buildPillDecoration(context),
          child: Icon(
            Icons.auto_graph_rounded,
            color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8),
            size: isMobile ? 18 : 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GradientText(
            'Growth & Mastery Analytics',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (isMobile
                    ? AppTextStyles.subtitle2
                    : AppTextStyles.h4)
                .copyWith(
                  fontSize: isMobile ? 16.0 : 20.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
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
            focusColor: AppColors.primary.withValues(alpha: 0.15),
            splashColor: AppColors.primary.withValues(alpha: 0.10),
            highlightColor: AppColors.primary.withValues(alpha: 0.10),
          ),
          child: Row(
            mainAxisSize:
                widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: widget.fullWidth
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.date_range_rounded,
                    size: 15,
                    color: isDark ? AppColors.primary : AppColors.purple,
                  ),
                  const SizedBox(width: 8),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: widget.activeRange == 'custom'
                          ? 'custom'
                          : widget.activeRange,
                      borderRadius: BorderRadius.circular(14),
                      dropdownColor:
                          isDark ? const Color(0xFF1E2034) : Colors.white,
                      elevation: 8,
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: isDark ? AppColors.primary : AppColors.purple,
                        ),
                      ),
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: widget.isMobile ? 12 : 13,
                      ),
                      selectedItemBuilder: (context) {
                        return [
                          _buildSelectedItem(
                            'Last 7 Days',
                            isDark,
                            widget.isMobile,
                          ),
                          _buildSelectedItem(
                            'Last 30 Days',
                            isDark,
                            widget.isMobile,
                          ),
                          _buildSelectedItem(
                            'Last 90 Days',
                            isDark,
                            widget.isMobile,
                          ),
                          _buildSelectedItem(
                            'Last 1 Year',
                            isDark,
                            widget.isMobile,
                          ),
                          _buildSelectedItem(
                            'All Time',
                            isDark,
                            widget.isMobile,
                          ),
                          _buildSelectedItem(
                            widget.displayLabel,
                            isDark,
                            widget.isMobile,
                          ),
                        ];
                      },
                      items: [
                        _buildDropdownItem(
                          'Last 7 Days',
                          '7d',
                          isDark,
                          widget.isMobile,
                        ),
                        _buildDropdownItem(
                          'Last 30 Days',
                          '30d',
                          isDark,
                          widget.isMobile,
                        ),
                        _buildDropdownItem(
                          'Last 90 Days',
                          '90d',
                          isDark,
                          widget.isMobile,
                        ),
                        _buildDropdownItem(
                          'Last 1 Year',
                          '1y',
                          isDark,
                          widget.isMobile,
                        ),
                        _buildDropdownItem(
                          'All Time',
                          'all',
                          isDark,
                          widget.isMobile,
                        ),
                        _buildDropdownItem(
                          widget.activeRange == 'custom'
                              ? widget.displayLabel
                              : 'Custom Date Range...',
                          'custom',
                          isDark,
                          widget.isMobile,
                        ),
                      ],
                      onChanged: (value) async {
                        if (value == null) return;
                        if (value == 'custom') {
                          await widget.onSelectCustomRange();
                        } else {
                          widget.onRangeChanged(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (widget.activeRange == 'custom') ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: widget.onResetCustomRange,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: isDark
                          ? AppColors.textMuted
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedItem(String label, bool isDark, bool isMobile) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: AppTextStyles.body2.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: isMobile ? 12 : 13,
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(
    String label,
    String value,
    bool isDark,
    bool isMobile,
  ) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(
        label,
        style: AppTextStyles.body2.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: isMobile ? 12 : 13,
        ),
      ),
    );
  }
}

/// Unified Theme Refresh Button matching the compact dropdown aesthetic.
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

class _DashboardRefreshButtonState extends State<_DashboardRefreshButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: 'Refresh analytics',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: 38,
          decoration: BoxDecoration(
            color: isDark
                ? (_isHovered
                      ? const Color(0xFF262842)
                      : const Color(0xFF1A1B2C))
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isRefreshing ? null : widget.onRefresh,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isCompact ? 10 : 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    widget.isRefreshing
                        ? SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: isDark
                                  ? AppColors.primary
                                  : AppColors.purple,
                            ),
                          )
                        : Icon(
                            Icons.refresh_rounded,
                            size: 16,
                            color: isDark
                                ? AppColors.primary
                                : AppColors.purple,
                          ),
                    if (!widget.isCompact) ...[
                      const SizedBox(width: 6),
                      Text(
                        'Sync',
                        style: AppTextStyles.body2.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
