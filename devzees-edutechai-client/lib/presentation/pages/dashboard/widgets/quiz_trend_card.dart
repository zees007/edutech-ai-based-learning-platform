import 'dart:math';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/responsive.dart';
import '../../../../data/models/dashboard/dashboard_response.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_palette.dart';

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
    final weeklyPoints = _groupQuizzesByWeek(rawTrend);
    final trend = _showWeeklyTrend
        ? weeklyPoints.map((p) => p.toTrendItem()).toList()
        : rawTrend;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile =
            Responsive.isMobile(context) ||
            constraints.maxWidth < Responsive.mobileBreakpoint;
        final isDesktop =
            Responsive.isDesktop(context) && constraints.maxWidth >= 960;
        final horizontalPadding = isMobile ? 32.0 : 44.0;
        final chartAvailableWidth = max(
          0.0,
          constraints.maxWidth - horizontalPadding,
        );

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

        final statPills = Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildStatBadge(
              context,
              label: 'Quizzes',
              value: '${widget.quizMetrics.totalQuizzesTaken}',
              icon: Icons.quiz_rounded,
              lightColor: const Color(0xFF6366F1),
              darkColor: const Color(0xFFA78BFA),
            ),
            _buildStatBadge(
              context,
              label: 'Questions',
              value: '${widget.quizMetrics.totalQuestionsEvaluated}',
              icon: Icons.fact_check_rounded,
              lightColor: const Color(0xFF0284C7),
              darkColor: const Color(0xFF38BDF8),
            ),
            _buildStatBadge(
              context,
              label: 'Perfect (3/3)',
              value: '${widget.quizMetrics.perfectQuizzesCount}',
              icon: Icons.check_circle_rounded,
              lightColor: const Color(0xFF059669),
              darkColor: const Color(0xFF34D399),
            ),
          ],
        );

        final zoomButton = Tooltip(
          message: 'Expand chart',
          child: InkWell(
            onTap: rawTrend.isEmpty
                ? null
                : () => _showFullscreenChart(context, rawTrend, weeklyPoints),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withValues(
                  alpha: 0.04,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.fullscreen_rounded,
                size: 19,
                color: rawTrend.isEmpty
                    ? (isDark ? AppColors.textMuted : const Color(0xFF94A3B8))
                    : (isDark
                          ? AppColors.textSecondary
                          : const Color(0xFF475569)),
              ),
            ),
          ),
        );

        final actionControls = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (rawTrend.length >= 3) ...[
              _buildViewModeToggle(context, isDark),
              const SizedBox(width: 6),
            ],
            zoomButton,
          ],
        );

        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.cardBackground.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.20)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(isMobile ? 16 : 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Quick Metric Capsules
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: titleColumn),
                    const SizedBox(width: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        statPills,
                        const SizedBox(width: 10),
                        actionControls,
                      ],
                    ),
                  ],
                )
              else if (!isMobile) ...[
                // Tablet / Intermediate: Title + Action Controls on top, Stat Pills cleanly below
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: titleColumn),
                    const SizedBox(width: 12),
                    actionControls,
                  ],
                ),
                const SizedBox(height: 12),
                statPills,
              ] else ...[
                // Mobile: Title + Zoom pinned top-right, Stat Pills & Toggle below
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: titleColumn),
                    const SizedBox(width: 8),
                    zoomButton,
                  ],
                ),
                const SizedBox(height: 12),
                if (constraints.maxWidth >= 460)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: statPills),
                      if (rawTrend.length >= 3) ...[
                        const SizedBox(width: 8),
                        _buildViewModeToggle(context, isDark),
                      ],
                    ],
                  )
                else ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: statPills,
                  ),
                  if (rawTrend.length >= 3) ...[
                    const SizedBox(height: 8),
                    _buildViewModeToggle(context, isDark),
                  ],
                ],
              ],
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
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: KeyedSubtree(
                    key: ValueKey(_showWeeklyTrend),
                    child: _buildScrollableChart(
                      context,
                      trend,
                      chartAvailableWidth,
                      weeklyPoints: _showWeeklyTrend ? weeklyPoints : null,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScrollableChart(
    BuildContext context,
    List<QuizAccuracyTrendItem> trend,
    double availableWidth, {
    List<WeeklyTrendPoint>? weeklyPoints,
  }) {
    final isDark = context.isDarkMode;
    const double pointSpacing = 48.0;
    final double minChartWidth = trend.length * pointSpacing;
    final needsScroll = minChartWidth > availableWidth && trend.length > 5;
    final chartWidth = needsScroll ? minChartWidth : availableWidth;

    Widget chartWidget = SizedBox(
      width: chartWidth,
      height: 270,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, right: 10),
        child: LineChart(
          _buildLineChartData(context, trend, weeklyPoints: weeklyPoints),
        ),
      ),
    );

    if (needsScroll) {
      return ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
          },
        ),
        child: ScrollbarTheme(
          data: ScrollbarThemeData(
            thickness: const WidgetStatePropertyAll(3.5),
            radius: const Radius.circular(8),
            thumbColor: WidgetStatePropertyAll(
              (isDark ? Colors.white : const Color(0xFF64748B)).withValues(
                alpha: 0.28,
              ),
            ),
          ),
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: false,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.only(bottom: 10),
              child: chartWidget,
            ),
          ),
        ),
      );
    }

    return chartWidget;
  }

  void _setWeeklyTrend(bool showWeekly) {
    if (_showWeeklyTrend == showWeekly) return;
    setState(() => _showWeeklyTrend = showWeekly);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToLatest();
    });
  }

  Widget _buildViewModeToggle(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(
            label: 'All Dots',
            isSelected: !_showWeeklyTrend,
            onTap: () => _setWeeklyTrend(false),
            isDark: isDark,
          ),
          _buildToggleOption(
            label: 'Weekly',
            isSelected: _showWeeklyTrend,
            onTap: () => _setWeeklyTrend(true),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(
                      alpha: isDark ? 0.30 : 0.22,
                    ),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.textSecondary : const Color(0xFF64748B)),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 10.5,
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color lightColor,
    required Color darkColor,
  }) {
    final isDark = context.isDarkMode;
    final badgeColor = isDark ? darkColor : lightColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: badgeColor),
          const SizedBox(width: 5),
          Text(
            '$label: ',
            style: AppTextStyles.caption.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              height: 1.1,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.caption.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildLineChartData(
    BuildContext context,
    List<QuizAccuracyTrendItem> trend, {
    List<WeeklyTrendPoint>? weeklyPoints,
    bool? isWeeklyOverride,
  }) {
    final isDark = context.isDarkMode;
    final isMobile = Responsive.isMobile(context);
    final isWeekly = isWeeklyOverride ?? _showWeeklyTrend;

    final spots = <FlSpot>[];
    for (int i = 0; i < trend.length; i++) {
      spots.add(FlSpot(i.toDouble(), trend[i].stepScore));
    }

    return LineChartData(
      minX: 0,
      maxX: max(1.0, (trend.length - 1).toDouble()),
      minY: 0,
      maxY: 100,
      clipData: const FlClipData.none(),
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

              final prefix = isWeekly ? 'W' : 'Q';
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '$prefix${index + 1}',
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
        getTouchedSpotIndicator: (barData, spotIndexes) {
          return spotIndexes.map((index) {
            return TouchedSpotIndicatorData(
              FlLine(
                color: const Color(0xFF8B5CF6)
                    .withValues(alpha: isDark ? 0.55 : 0.40),
                strokeWidth: 1.5,
                dashArray: [4, 3],
              ),
              FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 7.0,
                    color: Colors.white,
                    strokeWidth: 3.0,
                    strokeColor: const Color(0xFF8B5CF6),
                  );
                },
              ),
            );
          }).toList();
        },
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => isDark
              ? const Color(0xFF14182B).withValues(alpha: 0.96)
              : Colors.white,
          tooltipBorder: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.14)
                : const Color(0xFFE2E8F0),
            width: 1.0,
          ),
          tooltipRoundedRadius: 14,
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          tooltipMargin: 12,
          maxContentWidth: isMobile ? 250 : 340,
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final idx = spot.x.toInt();
              if (idx < 0 || idx >= trend.length) return null;
              final scoreStr = spot.y.toStringAsFixed(1);

              // ─── WEEKLY VIEW TOOLTIP ────────────────────────────────
              if (isWeekly &&
                  weeklyPoints != null &&
                  idx < weeklyPoints.length) {
                final point = weeklyPoints[idx];
                final Color statusColor;
                final String statusText;
                if (point.averageScore >= 85.0) {
                  statusColor = isDark
                      ? const Color(0xFF34D399)
                      : const Color(0xFF059669);
                  statusText = 'Strong Mastery';
                } else if (point.averageScore >= 65.0) {
                  statusColor = isDark
                      ? const Color(0xFF38BDF8)
                      : const Color(0xFF0284C7);
                  statusText = 'Solid Progress';
                } else {
                  statusColor = isDark
                      ? const Color(0xFFF87171)
                      : const Color(0xFFDC2626);
                  statusText = 'Difficulty Dip';
                }

                final truncatedTopics = _truncate(point.topicSummary, 50);

                return LineTooltipItem(
                  'Week ${point.weekNumber} • ${point.dateRangeLabel}\n',
                  AppTextStyles.label.copyWith(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.15,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.left,
                  children: [
                    TextSpan(
                      text: '$truncatedTopics\n',
                      style: AppTextStyles.caption.copyWith(
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF334155),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                    TextSpan(
                      text:
                          'Quizzes Evaluated: ${point.quizCount} ${point.quizCount == 1 ? 'quiz' : 'quizzes'} (${point.totalQuestions} questions evaluated)\n',
                      style: AppTextStyles.caption.copyWith(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                        fontSize: 10.5,
                        height: 1.4,
                      ),
                    ),
                    TextSpan(
                      text:
                          'Weekly Accuracy: $scoreStr% (${point.correctQuestions}/${point.totalQuestions} correct) • $statusText',
                      style: AppTextStyles.caption.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                        height: 1.45,
                      ),
                    ),
                  ],
                );
              }

              // ─── ALL DOTS VIEW TOOLTIP ──────────────────────────────
              final item = trend[idx];
              final correctCount = (spot.y / 100 * 3).round().clamp(0, 3);
              final rawStepTitle = item.stepTitle.startsWith('Step ')
                  ? item.stepTitle
                  : 'Step ${item.stepIndex + 1}: ${item.stepTitle.isNotEmpty ? item.stepTitle : 'Milestone Evaluation'}';
              final truncatedTopic = _truncate(
                item.topic.isNotEmpty ? item.topic : 'Learning Milestone',
                isMobile ? 42 : 55,
              );
              final truncatedStep = _truncate(
                rawStepTitle,
                isMobile ? 26 : 36,
              );
              final formattedDate = _formatSingleDate(item.date);

              final Color statusColor;
              final String statusIcon;
              final String statusText;
              if (spot.y >= 99.0) {
                statusColor = isDark
                    ? const Color(0xFF34D399)
                    : const Color(0xFF059669);
                statusIcon = '✓';
                statusText = 'Mastered';
              } else if (spot.y >= 60.0) {
                statusColor = isDark
                    ? const Color(0xFF38BDF8)
                    : const Color(0xFF0284C7);
                statusIcon = '●';
                statusText = 'Passed';
              } else {
                statusColor = isDark
                    ? const Color(0xFFF87171)
                    : const Color(0xFFDC2626);
                statusIcon = '▲';
                statusText = 'Needs Review';
              }

              return LineTooltipItem(
                '📘 $truncatedTopic\n',
                AppTextStyles.label.copyWith(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.15,
                  height: 1.4,
                ),
                textAlign: TextAlign.left,
                children: [
                  TextSpan(
                    text: '$truncatedStep • $formattedDate\n',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF475569),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      height: 1.45,
                    ),
                  ),
                  TextSpan(
                    text:
                        '$statusIcon $scoreStr% ($correctCount/3) • $statusText',
                    style: AppTextStyles.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      height: 1.45,
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

  static const _months = [
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

  static String _formatSingleDate(String dateStr) {
    if (dateStr.isEmpty) return 'Recorded';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    return '${_months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  static String _formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year) {
      if (start.month == end.month) {
        return '${_months[start.month - 1]} ${start.day} – ${end.day}, ${start.year}';
      }
      return '${_months[start.month - 1]} ${start.day} – ${_months[end.month - 1]} ${end.day}, ${start.year}';
    }
    return '${_months[start.month - 1]} ${start.day}, ${start.year} – ${_months[end.month - 1]} ${end.day}, ${end.year}';
  }

  static String _truncate(String text, int maxLength) {
    final clean = text.trim();
    if (clean.length <= maxLength) return clean;
    return '${clean.substring(0, maxLength - 3)}...';
  }

  List<WeeklyTrendPoint> _groupQuizzesByWeek(List<QuizAccuracyTrendItem> raw) {
    if (raw.isEmpty) return [];

    final Map<String, List<QuizAccuracyTrendItem>> weekBuckets = {};
    final Map<String, ({DateTime monday, DateTime sunday})> weekDateBounds = {};

    for (final item in raw) {
      final parsed = DateTime.tryParse(item.date);
      final dt = parsed ?? DateTime.now();
      final monday = DateTime(
        dt.year,
        dt.month,
        dt.day,
      ).subtract(Duration(days: dt.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));
      final key =
          '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';

      weekBuckets.putIfAbsent(key, () => []).add(item);
      weekDateBounds[key] = (monday: monday, sunday: sunday);
    }

    final sortedKeys = weekBuckets.keys.toList()..sort();
    final result = <WeeklyTrendPoint>[];

    for (int i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      final items = weekBuckets[key]!;
      final bounds = weekDateBounds[key]!;

      final distinctTopics = items
          .map((e) => e.topic.trim())
          .where((t) => t.isNotEmpty)
          .toSet()
          .toList();

      final String topicSummary;
      if (distinctTopics.isEmpty) {
        topicSummary = 'Curriculum Milestones';
      } else if (distinctTopics.length == 1) {
        topicSummary = distinctTopics.first;
      } else if (distinctTopics.length == 2) {
        topicSummary = '${distinctTopics[0]}, ${distinctTopics[1]}';
      } else {
        topicSummary =
            '${distinctTopics[0]}, ${distinctTopics[1]} (+${distinctTopics.length - 2} more)';
      }

      final quizCount = items.length;
      final totalQuestions = quizCount * 3;
      final totalCorrect = items
          .map((e) => (e.stepScore / 100 * 3).round().clamp(0, 3))
          .fold<int>(0, (sum, val) => sum + val);

      final avgScore =
          items
              .map((e) => e.stepScore)
              .fold<double>(0.0, (sum, val) => sum + val) /
          quizCount;

      final dateRangeLabel = _formatDateRange(bounds.monday, bounds.sunday);

      result.add(
        WeeklyTrendPoint(
          weekNumber: i + 1,
          weekStart: bounds.monday,
          weekEnd: bounds.sunday,
          dateRangeLabel: dateRangeLabel,
          topicSummary: topicSummary,
          quizCount: quizCount,
          totalQuestions: totalQuestions,
          correctQuestions: totalCorrect,
          averageScore: double.parse(avgScore.toStringAsFixed(1)),
        ),
      );
    }

    return result;
  }

  void _showFullscreenChart(
    BuildContext context,
    List<QuizAccuracyTrendItem> rawTrend,
    List<WeeklyTrendPoint> weeklyPoints,
  ) {
    final isDark = context.isDarkMode;
    final isMobile = Responsive.isMobile(context);
    bool modalWeekly = _showWeeklyTrend;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final activeTrend = modalWeekly
                ? weeklyPoints.map((p) => p.toTrendItem()).toList()
                : rawTrend;

            return Dialog(
              backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              insetPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 24,
                vertical: isMobile ? 20 : 32,
              ),
              child: Container(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                constraints: const BoxConstraints(
                  maxWidth: 960,
                  maxHeight: 600,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'Quiz Accuracy Timeline',
                            style: AppTextStyles.h4.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: isMobile ? 16 : 18,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (rawTrend.length >= 3) ...[
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildToggleOption(
                                  label: 'All Dots',
                                  isSelected: !modalWeekly,
                                  onTap: () =>
                                      setModalState(() => modalWeekly = false),
                                  isDark: isDark,
                                ),
                                _buildToggleOption(
                                  label: 'Weekly',
                                  isSelected: modalWeekly,
                                  onTap: () =>
                                      setModalState(() => modalWeekly = true),
                                  isDark: isDark,
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => Navigator.of(dialogContext).pop(),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: (isDark ? Colors.white : Colors.black)
                                  .withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 19,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, modalConstraints) {
                          final minWidth = max(
                            modalConstraints.maxWidth,
                            activeTrend.length * 52.0,
                          );
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: ScrollConfiguration(
                              key: ValueKey(modalWeekly),
                              behavior: const MaterialScrollBehavior().copyWith(
                                dragDevices: {
                                  PointerDeviceKind.touch,
                                  PointerDeviceKind.mouse,
                                  PointerDeviceKind.trackpad,
                                },
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics(),
                                ),
                                child: SizedBox(
                                  width: minWidth,
                                  height: modalConstraints.maxHeight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 10,
                                      right: 10,
                                    ),
                                    child: LineChart(
                                      _buildLineChartData(
                                        context,
                                        activeTrend,
                                        weeklyPoints: modalWeekly
                                            ? weeklyPoints
                                            : null,
                                        isWeeklyOverride: modalWeekly,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class WeeklyTrendPoint {
  final int weekNumber;
  final DateTime weekStart;
  final DateTime weekEnd;
  final String dateRangeLabel;
  final String topicSummary;
  final int quizCount;
  final int totalQuestions;
  final int correctQuestions;
  final double averageScore;

  WeeklyTrendPoint({
    required this.weekNumber,
    required this.weekStart,
    required this.weekEnd,
    required this.dateRangeLabel,
    required this.topicSummary,
    required this.quizCount,
    required this.totalQuestions,
    required this.correctQuestions,
    required this.averageScore,
  });

  QuizAccuracyTrendItem toTrendItem() {
    return QuizAccuracyTrendItem(
      date: dateRangeLabel,
      sessionId: '',
      topic: topicSummary,
      stepIndex: weekNumber - 1,
      stepTitle: '$quizCount ${quizCount == 1 ? "quiz" : "quizzes"} evaluated',
      stepScore: averageScore,
      sessionAvgScore: averageScore,
    );
  }
}
