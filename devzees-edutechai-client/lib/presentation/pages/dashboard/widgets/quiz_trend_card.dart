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
    final weeklyPoints = _groupQuizzesByWeek(rawTrend);
    final trend = _showWeeklyTrend
        ? weeklyPoints.map((p) => p.toTrendItem()).toList()
        : rawTrend;

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
            if (rawTrend.length >= 3) _buildViewModeToggle(context, isDark),
            IconButton(
              icon: Icon(
                Icons.fullscreen_rounded,
                size: 20,
                color: isDark
                    ? AppColors.textSecondary
                    : const Color(0xFF64748B),
              ),
              tooltip: 'Expand chart',
              onPressed: rawTrend.isEmpty
                  ? null
                  : () => _showFullscreenChart(
                      context,
                      trend,
                      weeklyPoints: _showWeeklyTrend ? weeklyPoints : null,
                    ),
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
                _buildScrollableChart(
                  context,
                  trend,
                  constraints.maxWidth,
                  weeklyPoints: _showWeeklyTrend ? weeklyPoints : null,
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
    final needsScroll = trend.length > 10;
    final chartWidth = needsScroll
        ? max(availableWidth, trend.length * 48.0)
        : availableWidth;

    Widget chartWidget = SizedBox(
      width: chartWidth,
      height: 260,
      child: LineChart(
        _buildLineChartData(context, trend, weeklyPoints: weeklyPoints),
      ),
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
    List<QuizAccuracyTrendItem> trend, {
    List<WeeklyTrendPoint>? weeklyPoints,
  }) {
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

              final prefix = _showWeeklyTrend ? 'W' : 'Q';
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
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) =>
              isDark ? const Color(0xFF151628) : Colors.white,
          tooltipBorder: BorderSide.none,
          tooltipRoundedRadius: 14,
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          tooltipMargin: 12,
          maxContentWidth: 350,
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final idx = spot.x.toInt();
              if (idx < 0 || idx >= trend.length) return null;
              final scoreStr = spot.y.toStringAsFixed(1);

              // ─── WEEKLY VIEW TOOLTIP ────────────────────────────────
              if (_showWeeklyTrend &&
                  weeklyPoints != null &&
                  idx < weeklyPoints.length) {
                final point = weeklyPoints[idx];
                final Color statusColor;
                final String statusText;
                if (point.averageScore >= 85.0) {
                  statusColor = AppColors.accentGreen;
                  statusText = 'Strong Mastery';
                } else if (point.averageScore >= 65.0) {
                  statusColor = AppColors.accentCyan;
                  statusText = 'Solid Progress';
                } else {
                  statusColor = const Color(0xFFEF4444);
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
                      ),
                    ),
                    TextSpan(
                      text:
                          'Weekly Accuracy: $scoreStr% (${point.correctQuestions}/${point.totalQuestions} correct) • $statusText',
                      style: AppTextStyles.caption.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
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
                50,
              );
              final truncatedStep = _truncate(rawStepTitle, 30);
              final formattedDate = _formatSingleDate(item.date);

              final Color statusColor;
              final String statusText;
              if (spot.y >= 99.0) {
                statusColor = AppColors.accentGreen;
                statusText = 'Mastered';
              } else if (spot.y >= 60.0) {
                statusColor = AppColors.accentCyan;
                statusText = 'Passed';
              } else {
                statusColor = const Color(0xFFEF4444);
                statusText = 'Needs Review';
              }

              return LineTooltipItem(
                '$truncatedTopic\n',
                AppTextStyles.label.copyWith(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.15,
                ),
                textAlign: TextAlign.left,
                children: [
                  TextSpan(
                    text: '$truncatedStep\n',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF334155),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                  TextSpan(
                    text: '$formattedDate\n',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                      fontSize: 10.5,
                    ),
                  ),
                  TextSpan(
                    text:
                        'Score: $scoreStr% ($correctCount/3 correct) • $statusText',
                    style: AppTextStyles.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
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
    List<QuizAccuracyTrendItem> trend, {
    List<WeeklyTrendPoint>? weeklyPoints,
  }) {
    final isDark = context.isDarkMode;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 32,
          ),
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
                      child: LineChart(
                        _buildLineChartData(
                          context,
                          trend,
                          weeklyPoints: weeklyPoints,
                        ),
                      ),
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
