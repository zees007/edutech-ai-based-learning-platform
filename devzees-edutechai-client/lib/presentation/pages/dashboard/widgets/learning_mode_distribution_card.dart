import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/responsive.dart';
import '../../../../data/models/dashboard/dashboard_response.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_palette.dart';

/// Reusable card displaying learning mode usage distribution (Visual, Deep Dive, Bite-Sized)
/// with a donut pie chart and interactive legend.
class LearningModeDistributionCard extends StatefulWidget {
  final ModeDistribution modeDistribution;
  final bool? isCompact;
  final bool stretchHeight;

  const LearningModeDistributionCard({
    super.key,
    required this.modeDistribution,
    this.isCompact,
    this.stretchHeight = false,
  });

  @override
  State<LearningModeDistributionCard> createState() =>
      _LearningModeDistributionCardState();
}

class _LearningModeDistributionCardState
    extends State<LearningModeDistributionCard> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final modes = widget.modeDistribution;
    final total = modes.total;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = Responsive.isMobile(context);
    final isCompact = widget.isCompact ?? (screenWidth < 450);

    final Widget chartSection = total == 0
        ? Container(
            height: 180,
            alignment: Alignment.center,
            child: Text(
              'No sessions recorded yet.',
              style: AppTextStyles.caption.copyWith(
                color: isDark
                    ? context.appColors.textSecondary
                    : const Color(0xFF94A3B8),
              ),
            ),
          )
        : (isCompact
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: SizedBox(
                        width: 130,
                        height: 130,
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback:
                                  (FlTouchEvent event, pieTouchResponse) {
                                    setState(() {
                                      if (!event.isInterestedForInteractions ||
                                          pieTouchResponse == null ||
                                          pieTouchResponse.touchedSection ==
                                              null) {
                                        _touchedIndex = -1;
                                        return;
                                      }
                                      _touchedIndex = pieTouchResponse
                                          .touchedSection!
                                          .touchedSectionIndex;
                                    });
                                  },
                            ),
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 3,
                            centerSpaceRadius: 36,
                            sections: _buildPieSections(modes),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLegendColumn(context, modes),
                  ],
                )
              : Row(
                  children: [
                    // Donut Pie Chart
                    SizedBox(
                      width: 130,
                      height: 130,
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback:
                                (FlTouchEvent event, pieTouchResponse) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        pieTouchResponse == null ||
                                        pieTouchResponse.touchedSection ==
                                            null) {
                                      _touchedIndex = -1;
                                      return;
                                    }
                                    _touchedIndex = pieTouchResponse
                                        .touchedSection!
                                        .touchedSectionIndex;
                                  });
                                },
                          ),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 3,
                          centerSpaceRadius: 36,
                          sections: _buildPieSections(modes),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Legend
                    Expanded(child: _buildLegendColumn(context, modes)),
                  ],
                ));

    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: context.appColors.border) : null,
        boxShadow: context.appColors.cardShadow,
      ),
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: widget.stretchHeight
            ? MainAxisSize.max
            : MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      (isDark
                              ? const Color(0xFFA78BFA)
                              : const Color(0xFF7C3AED))
                          .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.pie_chart_rounded,
                  color: isDark
                      ? const Color(0xFFA78BFA)
                      : const Color(0xFF7C3AED),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Learning Mode Distribution',
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: isMobile ? 16 : 18,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Usage ratio across Visual 🎬, Deep Dive 🔬, and Bite-Sized ⚡ modes',
                      style: AppTextStyles.body2.copyWith(
                        color: context.appColors.textSecondary,
                        fontSize: isMobile ? 12 : 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (widget.stretchHeight)
            Expanded(child: Center(child: chartSection))
          else
            chartSection,
        ],
      ),
    );
  }

  Widget _buildLegendColumn(BuildContext context, ModeDistribution modes) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildModeLegendItem(
          context,
          title: 'Visual Mode 🎬',
          count: modes.visual,
          percentage: modes.visualPercentage,
          color: const Color(0xFF38BDF8),
        ),
        const SizedBox(height: 10),
        _buildModeLegendItem(
          context,
          title: 'Deep Dive Mode 🔬',
          count: modes.deepDive,
          percentage: modes.deepDivePercentage,
          color: const Color(0xFF8B5CF6),
        ),
        const SizedBox(height: 10),
        _buildModeLegendItem(
          context,
          title: 'Bite-Sized Mode ⚡',
          count: modes.biteSized,
          percentage: modes.biteSizedPercentage,
          color: const Color(0xFFF59E0B),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections(ModeDistribution modes) {
    final sections = <PieChartSectionData>[];
    int sectionIdx = 0;

    if (modes.visual > 0) {
      final isTouched = _touchedIndex == sectionIdx;
      sections.add(
        PieChartSectionData(
          color: const Color(0xFF38BDF8),
          value: modes.visual.toDouble(),
          title: '${modes.visualPercentage.toStringAsFixed(0)}%',
          radius: isTouched ? 28 : 22,
          titleStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      sectionIdx++;
    }

    if (modes.deepDive > 0) {
      final isTouched = _touchedIndex == sectionIdx;
      sections.add(
        PieChartSectionData(
          color: const Color(0xFF8B5CF6),
          value: modes.deepDive.toDouble(),
          title: '${modes.deepDivePercentage.toStringAsFixed(0)}%',
          radius: isTouched ? 28 : 22,
          titleStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      sectionIdx++;
    }

    if (modes.biteSized > 0) {
      final isTouched = _touchedIndex == sectionIdx;
      sections.add(
        PieChartSectionData(
          color: const Color(0xFFF59E0B),
          value: modes.biteSized.toDouble(),
          title: '${modes.biteSizedPercentage.toStringAsFixed(0)}%',
          radius: isTouched ? 28 : 22,
          titleStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return sections;
  }

  Widget _buildModeLegendItem(
    BuildContext context, {
    required String title,
    required int count,
    required double percentage,
    required Color color,
  }) {
    final isDark = context.isDarkMode;

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.label.copyWith(
              color: isDark
                  ? context.appColors.textPrimary
                  : const Color(0xFF1E293B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$count (${percentage.toStringAsFixed(0)}%)',
          style: AppTextStyles.caption.copyWith(
            color: isDark
                ? context.appColors.textSecondary
                : const Color(0xFF64748B),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
