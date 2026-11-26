import 'package:flutter/material.dart';
import '../../../../core/constants/responsive.dart';
import '../../../../core/theme/theme_palette.dart';
import '../../../widgets/shimmer_loading.dart';

/// Layout-accurate loading skeleton for [LearningDashboardView].
/// Mirrors the real elevated card shells, concentric donut KPI hub, split panels,
/// and mobile segmented tab bar so loading transitions smoothly with minimal layout shift.
class DashboardLoadingSkeleton extends StatelessWidget {
  const DashboardLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width <= 0) return const SizedBox.shrink();

        final isMobile = width < Responsive.mobileBreakpoint;
        if (isMobile) {
          return _buildMobileSkeleton(context, width);
        }
        return _buildDesktopTabletSkeleton(context, width);
      },
    );
  }

  Widget _buildCardShell(
    BuildContext context, {
    required Widget child,
    double radius = 20,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
  }) {
    final isDark = context.isDarkMode;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: isDark ? Border.all(color: context.appColors.border) : null,
        boxShadow: context.appColors.cardShadow,
      ),
      child: ShimmerLoading(child: child),
    );
  }

  // ─── MOBILE SKELETON (< 768px) ───────────────────────────────────────────
  Widget _buildMobileSkeleton(BuildContext context, double width) {
    final isDark = context.isDarkMode;
    final compactPadding = width < 360 ? 12.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Segmented Mobile Tab Bar Placeholder
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
          ),
          child: ShimmerLoading(
            child: Row(
              children: List.generate(4, (i) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 0 : 4),
                    child: ShimmerBox(
                      height: 32,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 2. Concentric Donut + 2x2 KPI Card Grid
        _buildCardShell(
          context,
          radius: 24,
          padding: EdgeInsets.all(compactPadding),
          child: Column(
            children: [
              _buildDonutRingPlaceholder(context, size: 152),
              const SizedBox(height: 18),
              _buildKpiGridRows(rows: 2, cols: 2, spacing: 10),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Learning Mode Distribution Card
        _buildModeDistributionSkeleton(context, padding: compactPadding),
        const SizedBox(height: 16),

        // 4. Daily Activity Heatmap Card
        _buildHeatmapSkeleton(context, padding: compactPadding),
        const SizedBox(height: 32),
      ],
    );
  }

  // ─── TABLET & DESKTOP SKELETON (>= 768px) ─────────────────────────────────
  Widget _buildDesktopTabletSkeleton(BuildContext context, double width) {
    final isLargeDesktop = width >= 1300;
    final isWideKpiRow = width >= 920;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Concentric Donut Hub & 4 KPI Cards
        _buildCardShell(
          context,
          radius: 24,
          padding: EdgeInsets.all(isWideKpiRow ? 22 : 16),
          child: width >= 680
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildDonutRingPlaceholder(
                      context,
                      size: isLargeDesktop ? 176 : 164,
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: isLargeDesktop
                          ? _buildKpiGridRows(rows: 1, cols: 4, spacing: 12)
                          : _buildKpiGridRows(rows: 2, cols: 2, spacing: 12),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildDonutRingPlaceholder(context, size: 156),
                    const SizedBox(height: 18),
                    _buildKpiGridRows(rows: 2, cols: 2, spacing: 12),
                  ],
                ),
        ),
        const SizedBox(height: 24),

        // 2. Learning Mode Distribution (4) + Milestone Achievements (8)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 4,
                child: _buildModeDistributionSkeleton(context, padding: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 8,
                child: _buildAchievementsSkeleton(
                  context,
                  cols: width >= Responsive.tabletBreakpoint ? 3 : 2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 3. Quiz Accuracy Curve Card
        _buildQuizTrendSkeleton(context),
        const SizedBox(height: 24),

        // 4. Topic Mastery Breakdown Card
        _buildTopicBreakdownSkeleton(context),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildDonutRingPlaceholder(BuildContext context, {required double size}) {
    final surfaceColor = context.appColors.surface;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ShimmerBox(
            width: size,
            height: size,
            shape: BoxShape.circle,
          ),
          Container(
            width: size * 0.56,
            height: size * 0.56,
            decoration: BoxDecoration(
              color: surfaceColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShimmerBox(
                    width: size * 0.24,
                    height: 18,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  const SizedBox(height: 6),
                  ShimmerBox(
                    width: size * 0.30,
                    height: 10,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGridRows({
    required int rows,
    required int cols,
    required double spacing,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(rows, (r) {
        return Padding(
          padding: EdgeInsets.only(top: r == 0 ? 0 : spacing),
          child: Row(
            children: List.generate(cols, (c) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: c == 0 ? 0 : spacing),
                  child: _buildKpiSubCardPlaceholder(),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildKpiSubCardPlaceholder() {
    return Builder(
      builder: (context) {
        final isDark = context.isDarkMode;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerBox(
                    width: 30,
                    height: 30,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  ShimmerBox(
                    width: 44,
                    height: 16,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ShimmerBox(
                width: 68,
                height: 22,
                borderRadius: BorderRadius.circular(6),
              ),
              const SizedBox(height: 8),
              ShimmerBox(
                width: 96,
                height: 11,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModeDistributionSkeleton(
    BuildContext context, {
    required double padding,
  }) {
    return _buildCardShell(
      context,
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
            width: 150,
            height: 15,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 6),
          ShimmerBox(
            width: 110,
            height: 10,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 18),
          Center(child: _buildDonutRingPlaceholder(context, size: 112)),
          const SizedBox(height: 18),
          ...List.generate(3, (i) {
            return Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
              child: Row(
                children: [
                  ShimmerBox(
                    width: 10,
                    height: 10,
                    shape: BoxShape.circle,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ShimmerBox(
                      height: 12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ShimmerBox(
                    width: 34,
                    height: 12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAchievementsSkeleton(BuildContext context, {required int cols}) {
    final rows = cols == 3 ? 2 : 3;
    return _buildCardShell(
      context,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(
                width: 170,
                height: 15,
                borderRadius: BorderRadius.circular(5),
              ),
              ShimmerBox(
                width: 64,
                height: 22,
                borderRadius: BorderRadius.circular(12),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...List.generate(rows, (r) {
            return Padding(
              padding: EdgeInsets.only(top: r == 0 ? 0 : 12),
              child: Row(
                children: List.generate(cols, (c) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: c == 0 ? 0 : 12),
                      child: ShimmerBox(
                        height: 82,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuizTrendSkeleton(BuildContext context) {
    return _buildCardShell(
      context,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ShimmerBox(
                width: 210,
                height: 16,
                borderRadius: BorderRadius.circular(5),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShimmerBox(
                    width: 72,
                    height: 24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(width: 8),
                  ShimmerBox(
                    width: 72,
                    height: 24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          ShimmerBox(
            width: double.infinity,
            height: 150,
            borderRadius: BorderRadius.circular(14),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicBreakdownSkeleton(BuildContext context) {
    return _buildCardShell(
      context,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
            width: 185,
            height: 16,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ShimmerBox(
                  height: 76,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ShimmerBox(
                  height: 76,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapSkeleton(
    BuildContext context, {
    required double padding,
  }) {
    return _buildCardShell(
      context,
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
            width: 160,
            height: 15,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 14),
          ...List.generate(3, (rowIdx) {
            return Padding(
              padding: EdgeInsets.only(top: rowIdx == 0 ? 0 : 8),
              child: Row(
                children: List.generate(10, (colIdx) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: colIdx == 0 ? 0 : 6),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ShimmerBox(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }
}
