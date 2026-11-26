import 'package:flutter/material.dart';
import '../../../../core/constants/responsive.dart';
import '../../../../core/theme/theme_palette.dart';
import '../../../widgets/shimmer_loading.dart';

/// Structured, theme-adaptive loading skeleton for Admin Console tabs.
///
/// Mirrors the real admin KPI strips, filter toolbars, and tabular/card rows
/// with [ShimmerLoading] scoped strictly to the placeholder bones inside each card.
class AdminTableSkeleton extends StatelessWidget {
  final int rowCount;
  final bool showMetricsRow;
  final bool showSearchBar;
  final EdgeInsetsGeometry padding;

  const AdminTableSkeleton({
    super.key,
    this.rowCount = 5,
    this.showMetricsRow = false,
    this.showSearchBar = false,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.isDarkMode;
    final bool isMobile = Responsive.isMobile(context);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showMetricsRow) ...[
            _buildMetricsRow(context, isMobile),
            const SizedBox(height: 16),
          ],
          if (showSearchBar) ...[
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: ShimmerLoading(
                child: Row(
                  children: [
                    const ShimmerBox(width: 18, height: 18, shape: BoxShape.circle),
                    const SizedBox(width: 12),
                    ShimmerBox(
                      width: isMobile ? 140 : 220,
                      height: 12,
                    ),
                    const Spacer(),
                    const ShimmerBox(
                      width: 72,
                      height: 26,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border),
              boxShadow: isDark ? null : colors.cardShadow,
            ),
            child: ShimmerLoading(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Table header row
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: colors.border),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Expanded(flex: 2, child: ShimmerBox(height: 12)),
                        const SizedBox(width: 16),
                        if (!isMobile) ...[
                          const Expanded(flex: 2, child: ShimmerBox(height: 12)),
                          const SizedBox(width: 16),
                          const Expanded(flex: 1, child: ShimmerBox(height: 12)),
                          const SizedBox(width: 16),
                        ],
                        const SizedBox(width: 64, child: ShimmerBox(height: 12)),
                      ],
                    ),
                  ),
                  // Data rows
                  for (int i = 0; i < rowCount; i++)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: i < rowCount - 1
                          ? BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: colors.border),
                              ),
                            )
                          : null,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                const ShimmerBox(
                                  width: 28,
                                  height: 28,
                                  shape: BoxShape.circle,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ShimmerBox(
                                        width: i.isEven ? 120 : 96,
                                        height: 12,
                                      ),
                                      const SizedBox(height: 6),
                                      const ShimmerBox(width: 80, height: 10),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          if (!isMobile) ...[
                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: ShimmerBox(
                                  width: i.isEven ? 140 : 110,
                                  height: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              flex: 1,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: ShimmerBox(
                                  width: 64,
                                  height: 22,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          const ShimmerBox(
                            width: 64,
                            height: 24,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(BuildContext context, bool isMobile) {
    final colors = context.appColors;
    final isDark = context.isDarkMode;
    final cardCount = isMobile ? 2 : 4;

    return Row(
      children: [
        for (int i = 0; i < cardCount; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.border),
                boxShadow: isDark ? null : colors.cardShadow,
              ),
              child: ShimmerLoading(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        ShimmerBox(width: 72, height: 11),
                        ShimmerBox(
                          width: 28,
                          height: 28,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const ShimmerBox(width: 56, height: 22),
                    const SizedBox(height: 6),
                    const ShimmerBox(width: 88, height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Compact inline shimmer placeholder for secondary admin sections (e.g. privilege selector).
class AdminCompactSectionSkeleton extends StatelessWidget {
  final double height;

  const AdminCompactSectionSkeleton({super.key, this.height = 80});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      height: height,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: ShimmerLoading(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            ShimmerBox(width: 96, height: 24, borderRadius: BorderRadius.all(Radius.circular(12))),
            ShimmerBox(width: 118, height: 24, borderRadius: BorderRadius.all(Radius.circular(12))),
            ShimmerBox(width: 84, height: 24, borderRadius: BorderRadius.all(Radius.circular(12))),
            ShimmerBox(width: 110, height: 24, borderRadius: BorderRadius.all(Radius.circular(12))),
          ],
        ),
      ),
    );
  }
}
