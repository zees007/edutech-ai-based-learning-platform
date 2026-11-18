import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/dashboard_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_palette.dart';
import '../../../widgets/gradient_text.dart';

class DashboardHeader extends ConsumerWidget {
  final VoidCallback onRefresh;
  final bool isRefreshing;

  const DashboardHeader({
    super.key,
    required this.onRefresh,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isDark = context.isDarkMode;
    final dashboardState = ref.watch(dashboardProvider);
    final activeRange = dashboardState.timeRange;
    final customStart = dashboardState.customStart;
    final customEnd = dashboardState.customEnd;

    final firstName = user?.firstName ?? 'Learner';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Welcome Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        runSpacing: 6,
                        children: [
                          GradientText(
                            'Growth & Mastery Analytics',
                            style:
                                (isMobile ? AppTextStyles.h4 : AppTextStyles.h3)
                                    .copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                            gradient: isDark
                                ? AppColors.primaryGradient
                                : const LinearGradient(
                                    colors: [
                                      Color(0xFF4F46E5),
                                      Color(0xFF7C3AED),
                                    ],
                                  ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentGreen.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.accentGreen.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.accentGreen,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Performance Period',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.accentGreen,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Welcome back, $firstName! Filter your active milestones, study hours, and quiz trends below.',
                        style: AppTextStyles.body2.copyWith(
                          color: isDark
                              ? AppColors.textSecondary
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Time Range Filter Toolbar (Dropdown + Custom Range + Refresh)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildDateFilterDropdown(
                  context: context,
                  ref: ref,
                  activeRange: activeRange,
                  customStart: customStart,
                  customEnd: customEnd,
                  isDark: isDark,
                  isMobile: isMobile,
                ),
                // Reload Icon
                IconButton(
                  icon: isRefreshing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.refresh_rounded,
                          size: 20,
                          color: isDark
                              ? AppColors.textSecondary
                              : const Color(0xFF64748B),
                        ),
                  tooltip: 'Refresh analytics',
                  onPressed: isRefreshing ? null : onRefresh,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateFilterDropdown({
    required BuildContext context,
    required WidgetRef ref,
    required String activeRange,
    required DateTime? customStart,
    required DateTime? customEnd,
    required bool isDark,
    required bool isMobile,
  }) {
    String displayLabel;
    if (activeRange == 'custom' && customStart != null && customEnd != null) {
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: activeRange == 'custom'
              ? (isDark ? AppColors.accentCyan : AppColors.primary)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.08)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.date_range_rounded,
            size: 18,
            color: activeRange == 'custom'
                ? AppColors.accentCyan
                : (isDark ? AppColors.textSecondary : const Color(0xFF64748B)),
          ),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: activeRange == 'custom' ? 'custom' : activeRange,
              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              icon: const Icon(Icons.arrow_drop_down_rounded),
              selectedItemBuilder: (context) {
                return [
                  _buildSelectedItem('Last 7 Days', isDark),
                  _buildSelectedItem('Last 30 Days', isDark),
                  _buildSelectedItem('Last 90 Days', isDark),
                  _buildSelectedItem('Last 1 Year', isDark),
                  _buildSelectedItem('All Time', isDark),
                  _buildSelectedItem(displayLabel, isDark),
                ];
              },
              items: [
                _buildDropdownItem('Last 7 Days', '7d', isDark),
                _buildDropdownItem('Last 30 Days', '30d', isDark),
                _buildDropdownItem('Last 90 Days', '90d', isDark),
                _buildDropdownItem('Last 1 Year', '1y', isDark),
                _buildDropdownItem('All Time', 'all', isDark),
                _buildDropdownItem(
                  activeRange == 'custom' ? displayLabel : 'Custom Date Range...',
                  'custom',
                  isDark,
                ),
              ],
              onChanged: (value) async {
                if (value == null) return;
                if (value == 'custom') {
                  await _selectCustomDateRange(context, ref);
                } else {
                  ref.read(dashboardProvider.notifier).setTimeRange(value);
                }
              },
            ),
          ),
          if (activeRange == 'custom') ...[
            const SizedBox(width: 4),
            InkWell(
              onTap: () {
                ref.read(dashboardProvider.notifier).setTimeRange('30d');
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedItem(String label, bool isDark) {
    return Center(
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(
    String label,
    String value,
    bool isDark,
  ) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
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
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: const Color(0xFF1E293B),
              onSurface: Colors.white,
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
