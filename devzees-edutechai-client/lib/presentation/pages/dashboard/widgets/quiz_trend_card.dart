import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../data/models/dashboard/dashboard_response.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_palette.dart';
import '../../../widgets/glass_card.dart';

class QuizTrendCard extends StatefulWidget {
  final QuizMetrics quizMetrics;

  const QuizTrendCard({super.key, required this.quizMetrics});

  @override
  State<QuizTrendCard> createState() => _QuizTrendCardState();
}

class _QuizTrendCardState extends State<QuizTrendCard> {
  final ScrollController _scrollController = ScrollController();
  bool _showWeeklyTrend = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToLatest();
    });
  }

  @override
  void didUpdateWidget(covariant QuizTrendCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quizMetrics.accuracyTrend.length !=
        widget.quizMetrics.accuracyTrend.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToLatest();
      });
    }
  }

  void _scrollToLatest() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final rawTrend = widget.quizMetrics.accuracyTrend;
    final trend = _showWeeklyTrend ? _calculateWeeklyTrend(rawTrend) : rawTrend;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 620;

        final titleColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiz Comprehension & Accuracy Curve',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: isMobile ? 16 : 18,
                color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Performance progression across 3-question milestone quizzes',
              style: AppTextStyles.body2.copyWith(
                color: isDark
                    ? AppColors.textSecondary
                    : const Color(0xFF64748B),
                fontSize: isMobile ? 12 : 13,
              ),
            ),
          ],
        );

        final badgesWrap = Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildStatBadge(
              context,
              label: 'Quizzes',
              value: '${widget.quizMetrics.totalQuizzesTaken}',
              color: AppColors.accentPurple,
            ),
            _buildStatBadge(
              context,
              label: 'Questions',
              value: '${widget.quizMetrics.totalQuestionsEvaluated}',
              color: AppColors.accentCyan,
            ),
            _buildStatBadge(
              context,
              label: 'Perfect (3/3)',
              value: '${widget.quizMetrics.perfectQuizzesCount}',
              color: AppColors.accentGreen,
            ),
            if (rawTrend.length > 8)
              _buildViewModeToggle(context, isDark),
            IconButton(
              icon: Icon(
                Icons.fullscreen_rounded,
                size: 20,
                color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
              ),
              tooltip: 'Expand chart',
              onPressed: rawTrend.isEmpty
                  ? null
                  : () => _showFullscreenChart(context, trend),
            ),
          ],
        );

        return GlassCard(
          borderRadius: 20,
          padding: EdgeInsets.all(isMobile ? 16 : 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Quick Metric Capsules
              if (isMobile) ...[
                titleColumn,
                const SizedBox(height: 12),
                badgesWrap,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: titleColumn),
                    const SizedBox(width: 16),
                    Flexible(child: badgesWrap),
                  ],
                ),
              const SizedBox(height: 24),

              // Chart Section
              if (trend.isEmpty)
                Container(
                  height: 220,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.quiz_outlined,
                        size: 40,
                        color: isDark
                            ? AppColors.textMuted
                            : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No quiz data recorded in this period.',
                        style: AppTextStyles.body2.copyWith(
                          color: isDark
                              ? AppColors.textSecondary
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Complete milestone steps to generate your accuracy trendline.',
                        style: AppTextStyles.caption.copyWith(
                          color: isDark
                              ? AppColors.textMuted
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                )
              else
                _buildScrollableChart(context, trend, constraints.maxWidth),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScrollableChart(
    BuildContext context,
    List<QuizAccuracyTrendItem> trend,
    double availableWidth,
  ) {
    final needsScroll = trend.length > 10;
    final chartWidth = needsScroll ? max(availableWidth, trend.length * 48.0) : availableWidth;

    Widget chartWidget = SizedBox(
      width: chartWidth,
      height: 240,
      child: LineChart(_buildLineChartData(context, trend)),
    );

    if (needsScroll) {
      return Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(bottom: 12),
          child: chartWidget,
        ),
      );
    }

    return chartWidget;
  }

  Widget _buildViewModeToggle(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(
            label: 'All Dots',
            isSelected: !_showWeeklyTrend,
            onTap: () => setState(() => _showWeeklyTrend = false),
            isDark: isDark,
          ),
          _buildToggleOption(
            label: 'Weekly',
            isSelected: _showWeeklyTrend,
            onTap: () => setState(() => _showWeeklyTrend = true),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primary : AppColors.purple)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.textSecondary : const Color(0xFF64748B)),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildLineChartData(
    BuildContext context,
    List<QuizAccuracyTrendItem> trend,
  ) {
    final isDark = context.isDarkMode;

    final spots = <FlSpot>[];
    for (int i = 0; i < trend.length; i++) {
      spots.add(FlSpot(i.toDouble(), trend[i].stepScore));
    }

    return LineChartData(
      minX: 0,
      maxX: max(1.0, (trend.length - 1).toDouble()),
      minY: 0,
      maxY: 100,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 33.33,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.black.withValues(alpha: 0.05),
            strokeWidth: 1,
            dashArray: [4, 4],
          );
        },
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 33.33,
            reservedSize: 42,
            getTitlesWidget: (value, meta) {
              String text = '';
              if (value >= 99) {
                text = '100%';
              } else if (value >= 66 && value <= 68) {
                text = '67%';
              } else if (value >= 32 && value <= 34) {
                text = '33%';
              } else if (value == 0) {
                text = '0%';
              }
              return Text(
                text,
                style: AppTextStyles.caption.copyWith(
                  color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                  fontSize: 10,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: 28,
            getTitlesWidget: (value, meta) {
              if (value != value.roundToDouble()) {
                return const SizedBox.shrink();
              }
              final index = value.toInt();
              if (index < 0 || index >= trend.length) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Q${index + 1}',
                  style: AppTextStyles.caption.copyWith(
                    color: isDark
                        ? AppColors.textSecondary
                        : const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) =>
              isDark ? const Color(0xFF1E293B) : Colors.white,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final idx = spot.x.toInt();
              if (idx < 0 || idx >= trend.length) return null;
              final item = trend[idx];
              final scoreStr = spot.y.toStringAsFixed(1);
              final correctCount = (spot.y / 100 * 3).round();

              final stepLabel = item.stepTitle.startsWith('Step ')
                  ? item.stepTitle
                  : 'Step ${item.stepIndex + 1}: ${item.stepTitle}';
              final dateLabel = item.date.isNotEmpty ? ' • ${item.date}' : '';

              return LineTooltipItem(
                '${item.topic}\n',
                AppTextStyles.label.copyWith(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(
                    text: '$stepLabel$dateLabel\n',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.textSecondary
                          : const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                  TextSpan(
                    text: '$scoreStr% ($correctCount/3 correct)',
                    style: AppTextStyles.caption.copyWith(
                      color: spot.y >= 90
                          ? AppColors.accentGreen
                          : (spot.y >= 60
                                ? AppColors.accentCyan
                                : const Color(0xFFEF4444)),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.35,
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF38BDF8)],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4.5,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: const Color(0xFF38BDF8),
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF8B5CF6).withValues(alpha: 0.22),
                const Color(0xFF38BDF8).withValues(alpha: 0.02),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  List<QuizAccuracyTrendItem> _calculateWeeklyTrend(
    List<QuizAccuracyTrendItem> raw,
  ) {
    if (raw.length <= 5) return raw;

    final result = <QuizAccuracyTrendItem>[];
    const chunkSize = 4;
    for (int i = 0; i < raw.length; i += chunkSize) {
      final chunk = raw.sublist(i, min(i + chunkSize, raw.length));
      final avgScore = chunk.map((e) => e.stepScore).reduce((a, b) => a + b) / chunk.length;
      result.add(
        QuizAccuracyTrendItem(
          date: chunk.first.date,
          sessionId: chunk.first.sessionId,
          topic: '${chunk.first.topic} (avg)',
          stepIndex: i ~/ chunkSize,
          stepTitle: 'Period Block ${(i ~/ chunkSize) + 1}',
          stepScore: avgScore,
          sessionAvgScore: avgScore,
        ),
      );
    }
    return result;
  }

  void _showFullscreenChart(
    BuildContext context,
    List<QuizAccuracyTrendItem> trend,
  ) {
    final isDark = context.isDarkMode;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 960, maxHeight: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Comprehensive Quiz Accuracy Timeline',
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: max(800.0, trend.length * 52.0),
                      child: LineChart(_buildLineChartData(context, trend)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
