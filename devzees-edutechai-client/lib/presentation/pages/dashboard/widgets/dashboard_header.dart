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
    final isMobile = MediaQuery.of(context).size.width < 700;
    final dashboardState = ref.watch(dashboardProvider);
    final activeRange = dashboardState.timeRange;

    final firstName = user?.firstName ?? 'Learner';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Row with Back button & Refresh
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
                        'Learning Performance & Stats',
                        style: (isMobile ? AppTextStyles.h4 : AppTextStyles.h3)
                            .copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                        gradient: isDark
                            ? AppColors.primaryGradient
                            : const LinearGradient(
                                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                              ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen.withValues(alpha: 0.15),
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
                              'Live HUD',
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
                    'Welcome back, $firstName! Here is your comprehensive learning growth and quiz accuracy breakdown.',
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

        // Time Range Filter Segment
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildTimeFilterPill(
              context: context,
              ref: ref,
              label: 'Last 7 Days',
              rangeKey: '7d',
              isSelected: activeRange == '7d',
            ),
            _buildTimeFilterPill(
              context: context,
              ref: ref,
              label: 'Last 30 Days',
              rangeKey: '30d',
              isSelected: activeRange == '30d',
            ),
            _buildTimeFilterPill(
              context: context,
              ref: ref,
              label: 'All Time',
              rangeKey: 'all',
              isSelected: activeRange == 'all',
            ),
            const SizedBox(width: 8),
            // Reload icon
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
  }

  Widget _buildTimeFilterPill({
    required BuildContext context,
    required WidgetRef ref,
    required String label,
    required String rangeKey,
    required bool isSelected,
  }) {
    final isDark = context.isDarkMode;

    final bg = isSelected
        ? (isDark ? AppColors.primary : AppColors.purple)
        : (isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.05));

    final textColor = isSelected
        ? Colors.white
        : (isDark ? AppColors.textSecondary : const Color(0xFF475569));

    return InkWell(
      onTap: () {
        ref.read(dashboardProvider.notifier).setTimeRange(rangeKey);
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.primary : AppColors.purple)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.08)),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDark ? AppColors.primary : AppColors.purple)
                        .withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: textColor,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
