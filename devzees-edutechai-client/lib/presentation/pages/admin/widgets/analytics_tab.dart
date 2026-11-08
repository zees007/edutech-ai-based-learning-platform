import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/admin_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../widgets/shimmer_loading.dart';

/// Analytics & Metrics tab with metric cards, mobile-friendly left-side reload,
/// and subscription distribution chart.
class AnalyticsTab extends ConsumerWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(adminMetricsProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return RefreshIndicator(
      color: AppColors.purple,
      backgroundColor: AppColors.surfaceDeep,
      onRefresh: () async {
        ref.invalidate(adminMetricsProvider);
        try {
          await ref.read(adminMetricsProvider.future);
        } catch (_) {}
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header: Reload Icon on the LEFT, followed by Title & Live badge ───
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reload Icon Button (Left side, mobile-friendly 44x44 touch target)
                _buildReloadButton(metricsAsync, ref, context),
                const SizedBox(width: 14),

                // Title, Live Status Badge, and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        runSpacing: 6,
                        children: [
                          Text(
                            'Platform Metrics & Subscription Distribution',
                            style: AppTextStyles.h4.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: isMobile ? 18 : 20,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.accentGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.accentGreen.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.accentGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Live',
                                  style: AppTextStyles.captionBold.copyWith(
                                    color: AppColors.accentGreen,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Real-time overview of your platform\'s user base and subscription health',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textMuted,
                          fontSize: isMobile ? 13 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            metricsAsync.when(
              skipLoadingOnRefresh: true,
              data: (metrics) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Metric Cards
                  _buildMetricCardsRow(metrics, isMobile),
                  const SizedBox(height: 36),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: AppColors.glassBorder,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Subscription Tier Distribution',
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: isMobile ? 18 : 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDistributionChart(metrics, isMobile),
                ],
              ),
              loading: () => const Column(
                children: [
                  ShimmerLoading(child: ShimmerBox(height: 120)),
                  SizedBox(height: 32),
                  ShimmerLoading(child: ShimmerBox(height: 300)),
                ],
              ),
              error: (err, _) => Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.rose.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.rose.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.rose),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        err.toString(),
                        style: AppTextStyles.body2.copyWith(color: AppColors.rose),
                      ),
                    ),
                    TextButton(
                      onPressed: () => ref.invalidate(adminMetricsProvider),
                      child: Text(
                        'Retry',
                        style: AppTextStyles.button.copyWith(color: AppColors.rose),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReloadButton(
    AsyncValue<AdminMetrics> metricsAsync,
    WidgetRef ref,
    BuildContext context,
  ) {
    final isLoading = metricsAsync.isLoading;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: 'Reload analytics',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: isLoading
                ? null
                : () {
                    ref.invalidate(adminMetricsProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: AppColors.accentGreen, size: 18),
                            SizedBox(width: 8),
                            Text('Reloading platform analytics...'),
                          ],
                        ),
                        duration: const Duration(seconds: 1),
                        backgroundColor: AppColors.surfaceDeep,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.glassBase,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isLoading
                      ? AppColors.purple.withValues(alpha: 0.6)
                      : AppColors.glassBorder,
                ),
              ),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.purple,
                        ),
                      )
                    : const Icon(
                        Icons.refresh_rounded,
                        color: AppColors.purple,
                        size: 22,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCardsRow(AdminMetrics metrics, bool isMobile) {
    final cards = [
      _MetricCardData(
        label: 'Total Users',
        value: metrics.totalUsers,
        icon: Icons.people,
        gradient: AppColors.primaryGradient,
        iconColor: AppColors.purple,
      ),
      _MetricCardData(
        label: 'Free Tier',
        value: metrics.freeCount,
        icon: Icons.person_outline,
        gradient: const LinearGradient(
          colors: [Color(0xFF334155), Color(0xFF475569)],
        ),
        iconColor: AppColors.slate400,
      ),
      _MetricCardData(
        label: 'Pro Subscribers',
        value: metrics.proCount,
        icon: Icons.star_outline,
        gradient: AppColors.royalBlueIndigoGradient,
        iconColor: AppColors.accentBlue,
      ),
      _MetricCardData(
        label: 'Ultra Subscribers',
        value: metrics.ultraCount,
        icon: Icons.diamond_outlined,
        gradient: AppColors.pinkPurpleGradient,
        iconColor: AppColors.purpleDeep,
      ),
      _MetricCardData(
        label: 'System Roles',
        value: metrics.totalRoles,
        icon: Icons.shield_outlined,
        gradient: AppColors.emeraldGradient,
        iconColor: AppColors.accentGreen,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 5
            : constraints.maxWidth > 600
                ? 3
                : constraints.maxWidth > 340
                    ? 2
                    : 1;
        return Wrap(
          spacing: isMobile ? 12 : 16,
          runSpacing: isMobile ? 12 : 16,
          children: cards.map((card) {
            final spacingTotal = (crossAxisCount - 1) * (isMobile ? 12 : 16);
            final width = (constraints.maxWidth - spacingTotal) / crossAxisCount;
            return SizedBox(
              width: width,
              child: _MetricCard(data: card, isMobile: isMobile),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDistributionChart(AdminMetrics metrics, bool isMobile) {
    final total = metrics.freeCount + metrics.proCount + metrics.ultraCount;
    if (total == 0) {
      return Container(
        height: 280,
        alignment: Alignment.center,
        child: Text(
          'No subscription data available',
          style: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
        ),
      );
    }

    final barWidth = isMobile ? 28.0 : 40.0;

    return Container(
      height: 320,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          maxY: metrics.totalUsers > 0 ? (metrics.totalUsers * 1.2).toDouble() : 10.0,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.popoverBackground.withValues(alpha: 0.9),
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final labels = ['Normal (Free)', 'Pro', 'Ultra'];
                return BarTooltipItem(
                  '${labels[groupIndex]}\n${rod.toY.toInt()} users',
                  AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  final labels = ['Free', 'Pro', 'Ultra'];
                  if (value.toInt() >= 0 && value.toInt() < labels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        labels[value.toInt()],
                        style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (metrics.totalUsers / 4).ceilToDouble().clamp(1.0, double.infinity),
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.glassBorder.withValues(alpha: 0.5),
              strokeWidth: 0.5,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            _makeBarGroup(0, metrics.freeCount.toDouble(), AppColors.slate500, barWidth),
            _makeBarGroup(1, metrics.proCount.toDouble(), AppColors.accentBlue, barWidth),
            _makeBarGroup(2, metrics.ultraCount.toDouble(), AppColors.purpleDeep, barWidth),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color, double barWidth) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: barWidth,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              color.withValues(alpha: 0.6),
              color,
            ],
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            color: AppColors.glassBorder.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }
}

class _MetricCardData {
  final String label;
  final int value;
  final IconData icon;
  final Gradient gradient;
  final Color iconColor;

  _MetricCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.iconColor,
  });
}

class _MetricCard extends StatefulWidget {
  final _MetricCardData data;
  final bool isMobile;

  const _MetricCard({
    required this.data,
    this.isMobile = false,
  });

  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final padding = widget.isMobile ? 14.0 : 20.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? widget.data.iconColor.withValues(alpha: 0.4)
                : AppColors.glassBorder,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.data.iconColor.withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: -5,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.data.iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.data.icon,
                color: widget.data.iconColor,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${widget.data.value}',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: widget.isMobile ? 20 : 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.data.label,
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
