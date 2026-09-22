import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/admin_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../widgets/shimmer_loading.dart';

/// Analytics & Metrics tab with metric cards and subscription distribution chart.
class AnalyticsTab extends ConsumerWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(adminMetricsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Platform Metrics & Subscription Distribution',
            style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Real-time overview of your platform\'s user base and subscription health',
            style: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 32),

          metricsAsync.when(
            data: (metrics) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Metric Cards
                _buildMetricCardsRow(metrics),
                const SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: AppColors.glassBorder,
                ),
                const SizedBox(height: 32),
                Text(
                  'Subscription Tier Distribution',
                  style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 24),
                _buildDistributionChart(metrics),
              ],
            ),
            loading: () => Column(
              children: [
                const ShimmerLoading(child: ShimmerBox(height: 120)),
                const SizedBox(height: 32),
                const ShimmerLoading(child: ShimmerBox(height: 300)),
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
    );
  }

  Widget _buildMetricCardsRow(AdminMetrics metrics) {
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
                : 2;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards.map((card) {
            final width = (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;
            return SizedBox(
              width: width,
              child: _MetricCard(data: card),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDistributionChart(AdminMetrics metrics) {
    final total = metrics.freeCount + metrics.proCount + metrics.ultraCount;
    if (total == 0) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: Text(
          'No subscription data available',
          style: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
        ),
      );
    }

    return Container(
      height: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          maxY: (metrics.totalUsers * 1.2).toDouble(),
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
                reservedSize: 40,
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
            horizontalInterval: (metrics.totalUsers / 4).ceilToDouble().clamp(1, double.infinity),
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.glassBorder.withValues(alpha: 0.5),
              strokeWidth: 0.5,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            _makeBarGroup(0, metrics.freeCount.toDouble(), AppColors.slate500),
            _makeBarGroup(1, metrics.proCount.toDouble(), AppColors.accentBlue),
            _makeBarGroup(2, metrics.ultraCount.toDouble(), AppColors.purpleDeep),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 40,
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

  const _MetricCard({required this.data});

  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
        padding: const EdgeInsets.all(20),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.data.iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.data.icon,
                color: widget.data.iconColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${widget.data.value}',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.data.label,
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
