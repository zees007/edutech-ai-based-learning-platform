import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../data/models/dashboard/dashboard_response.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_palette.dart';
import '../../../widgets/glass_card.dart';

/// Ultra-premium Concentric Donut Activity Hub & KPI Dashboard.
///
/// Combines a 4-ring gamified activity donut (inspired by Apple Fitness & Linear)
/// with 4 interactive Glass KPI cards:
/// - Ring 1 (Cyan): Active Study Time vs. Target
/// - Ring 2 (Purple): Journey Completion Rate
/// - Ring 3 (Emerald): Milestone Mastery Checkpoints
/// - Ring 4 (Electric Blue): Period Quiz Accuracy
///
/// Features smooth sweep animations, interactive cross-hover/tap focus,
/// full theme adaptation, and seamless responsive scaling across desktop,
/// tablet (all 4 cards visible), and mobile (compact 2x2 grid).
class DashboardKpiCards extends StatefulWidget {
  final DashboardSummary summary;

  const DashboardKpiCards({super.key, required this.summary});

  @override
  State<DashboardKpiCards> createState() => _DashboardKpiCardsState();
}

class _DashboardKpiCardsState extends State<DashboardKpiCards>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _curvedAnimation;

  /// Currently focused metric index (0: Study Time, 1: Journeys, 2: Milestones, 3: Quiz Score).
  /// When null, the center displays the overall composite Mastery Index.
  int? _focusedIndex;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _curvedAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant DashboardKpiCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.summary.totalStudyMinutes != widget.summary.totalStudyMinutes ||
        oldWidget.summary.completedSessions != widget.summary.completedSessions ||
        oldWidget.summary.totalStepsMastered != widget.summary.totalStepsMastered ||
        oldWidget.summary.averageQuizScoreOverall != widget.summary.averageQuizScoreOverall) {
      _animController.reset();
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final isDark = context.isDarkMode;

    final metrics = _buildMetricItems(summary);
    final compositeScore = _calculateCompositeMastery(metrics);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        if (totalWidth <= 0) return const SizedBox.shrink();

        final isDesktop = totalWidth >= 920;
        final isTabletSideBySide = totalWidth >= 680 && totalWidth < 920;
        final isCompactTablet = totalWidth >= 520 && totalWidth < 680;

        return GlassCard(
          borderRadius: 24,
          padding: EdgeInsets.all(isDesktop ? 22 : (totalWidth < 360 ? 12 : 16)),
          child: AnimatedBuilder(
            animation: _curvedAnimation,
            builder: (context, _) {
              if (isDesktop || isTabletSideBySide) {
                return _buildSideBySideLayout(
                  context: context,
                  totalWidth: totalWidth,
                  metrics: metrics,
                  compositeScore: compositeScore,
                  isDark: isDark,
                  isTablet: isTabletSideBySide,
                );
              } else if (isCompactTablet) {
                return _buildTabletStackedLayout(
                  context: context,
                  totalWidth: totalWidth,
                  metrics: metrics,
                  compositeScore: compositeScore,
                  isDark: isDark,
                );
              } else {
                return _buildMobileLayout(
                  context: context,
                  totalWidth: totalWidth,
                  metrics: metrics,
                  compositeScore: compositeScore,
                  isDark: isDark,
                );
              }
            },
          ),
        );
      },
    );
  }

  // ─── LAYOUT BUILDERS ────────────────────────────────────────────────────────

  /// Desktop / Tablet Wide: Side-by-side Donut on left, 2x2 KPI card grid on right.
  Widget _buildSideBySideLayout({
    required BuildContext context,
    required double totalWidth,
    required List<_KpiMetricData> metrics,
    required int compositeScore,
    required bool isDark,
    required bool isTablet,
  }) {
    final donutSize = isTablet ? 210.0 : 250.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Concentric Donut Hub
        SizedBox(
          width: donutSize,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDonutHub(
                size: donutSize,
                metrics: metrics,
                compositeScore: compositeScore,
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildDonutFooterBadge(isDark: isDark, isCompact: isTablet),
            ],
          ),
        ),
        const SizedBox(width: 20),

        // Vertical Divider
        Container(
          width: 1,
          height: donutSize * 0.9,
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
        const SizedBox(width: 20),

        // 2x2 Grid of the 4 KPI Cards (All 4 visible on Tablet and Desktop)
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      context: context,
                      index: 0,
                      metric: metrics[0],
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildMetricTile(
                      context: context,
                      index: 1,
                      metric: metrics[1],
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      context: context,
                      index: 2,
                      metric: metrics[2],
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildMetricTile(
                      context: context,
                      index: 3,
                      metric: metrics[3],
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Tablet Stacked (520px - 679px): Centered Donut on top, all 4 cards in a 2x2 grid below.
  Widget _buildTabletStackedLayout({
    required BuildContext context,
    required double totalWidth,
    required List<_KpiMetricData> metrics,
    required int compositeScore,
    required bool isDark,
  }) {
    const donutSize = 210.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildDonutHub(
          size: donutSize,
          metrics: metrics,
          compositeScore: compositeScore,
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        _buildDonutFooterBadge(isDark: isDark, isCompact: true),
        const SizedBox(height: 18),
        // All 4 Cards in 2x2 Grid
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                context: context,
                index: 0,
                metric: metrics[0],
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                context: context,
                index: 1,
                metric: metrics[1],
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                context: context,
                index: 2,
                metric: metrics[2],
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                context: context,
                index: 3,
                metric: metrics[3],
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Mobile Layout (< 520px): Donut on top, compact 2x2 grid below.
  /// For ultra-narrow devices (< 340px), wraps gracefully into 1 column to avoid overflow.
  Widget _buildMobileLayout({
    required BuildContext context,
    required double totalWidth,
    required List<_KpiMetricData> metrics,
    required int compositeScore,
    required bool isDark,
  }) {
    final donutSize = totalWidth < 360 ? 170.0 : 190.0;
    final isUltraNarrow = totalWidth < 340;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildDonutHub(
          size: donutSize,
          metrics: metrics,
          compositeScore: compositeScore,
          isDark: isDark,
        ),
        const SizedBox(height: 6),
        _buildDonutFooterBadge(isDark: isDark, isCompact: true),
        const SizedBox(height: 16),

        if (isUltraNarrow) ...[
          // Single-column fallback for screens under 340px (e.g. Galaxy Fold outer / narrow widgets)
          for (int i = 0; i < metrics.length; i++) ...[
            _buildMetricTile(
              context: context,
              index: i,
              metric: metrics[i],
              isDark: isDark,
              isMobileCompact: true,
            ),
            if (i < metrics.length - 1) const SizedBox(height: 10),
          ],
        ] else ...[
          // Standard mobile 2x2 compact grid: all 4 KPIs visible without deep scrolling!
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context: context,
                  index: 0,
                  metric: metrics[0],
                  isDark: isDark,
                  isMobileCompact: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  context: context,
                  index: 1,
                  metric: metrics[1],
                  isDark: isDark,
                  isMobileCompact: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context: context,
                  index: 2,
                  metric: metrics[2],
                  isDark: isDark,
                  isMobileCompact: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  context: context,
                  index: 3,
                  metric: metrics[3],
                  isDark: isDark,
                  isMobileCompact: true,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ─── CONCENTRIC DONUT HUB ───────────────────────────────────────────────────

  Widget _buildDonutHub({
    required double size,
    required List<_KpiMetricData> metrics,
    required int compositeScore,
    required bool isDark,
  }) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ambient Radial Glow behind the rings
            Container(
              width: size * 0.72,
              height: size * 0.72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (_focusedIndex != null
                            ? metrics[_focusedIndex!].startColor
                            : AppColors.primary)
                        .withValues(alpha: isDark ? 0.20 : 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Hardware-accelerated Concentric Rings Painter
            CustomPaint(
              size: Size(size, size),
              painter: _ConcentricRingsPainter(
                metrics: metrics,
                animationProgress: _curvedAnimation.value,
                focusedIndex: _focusedIndex,
                isDark: isDark,
              ),
            ),

            // Center Dynamic Content (Cross-fades smoothly on focus)
            _buildCenterHubContent(
              size: size,
              metrics: metrics,
              compositeScore: compositeScore,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterHubContent({
    required double size,
    required List<_KpiMetricData> metrics,
    required int compositeScore,
    required bool isDark,
  }) {
    final activeMetric = _focusedIndex != null ? metrics[_focusedIndex!] : null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.90, end: 1.0).animate(animation),
              child: child,
            ),
          ),
          child: activeMetric == null
              ? _buildDefaultMasteryCenter(
                  compositeScore: compositeScore,
                  isDark: isDark,
                  key: const ValueKey('default_composite'),
                )
              : _buildFocusedMetricCenter(
                  metric: activeMetric,
                  isDark: isDark,
                  key: ValueKey('focused_$_focusedIndex'),
                ),
        ),
      ),
    );
  }

  Widget _buildDefaultMasteryCenter({
    required int compositeScore,
    required bool isDark,
    required Key key,
  }) {
    final animatedScore = (_curvedAnimation.value * compositeScore).round();

    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.auto_awesome_rounded,
          size: 15,
          color: AppColors.primary,
        ),
        const SizedBox(height: 2),
        Text(
          '$animatedScore%',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: -0.8,
            color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'MASTERY INDEX',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 9.5,
            letterSpacing: 0.6,
            color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildFocusedMetricCenter({
    required _KpiMetricData metric,
    required bool isDark,
    required Key key,
  }) {
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          metric.icon,
          size: 15,
          color: metric.startColor,
        ),
        const SizedBox(height: 2),
        Text(
          metric.value,
          style: AppTextStyles.h4.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.5,
            color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          metric.shortTitle.toUpperCase(),
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 9.0,
            letterSpacing: 0.5,
            color: metric.startColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDonutFooterBadge({
    required bool isDark,
    required bool isCompact,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
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
            _focusedIndex != null ? 'Metric Focused' : 'Active Rings',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // ─── KPI METRIC TILES ───────────────────────────────────────────────────────

  Widget _buildMetricTile({
    required BuildContext context,
    required int index,
    required _KpiMetricData metric,
    required bool isDark,
    bool isMobileCompact = false,
  }) {
    final isSelected = _focusedIndex == index;
    final isOtherSelected = _focusedIndex != null && !isSelected;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _focusedIndex = index),
      onExit: (_) => setState(() => _focusedIndex = null),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _focusedIndex = isSelected ? null : index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.symmetric(
            horizontal: isMobileCompact ? 12 : 14,
            vertical: isMobileCompact ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? (isSelected
                    ? metric.startColor.withValues(alpha: 0.14)
                    : Colors.white.withValues(alpha: 0.035))
                : (isSelected
                    ? metric.startColor.withValues(alpha: 0.10)
                    : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? metric.startColor.withValues(alpha: 0.65)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFE2E8F0)),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: metric.startColor.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : (isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]),
          ),
          child: Opacity(
            opacity: isOtherSelected ? 0.65 : 1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Title + Color Indicator / Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        metric.title,
                        style: AppTextStyles.label.copyWith(
                          color: isDark
                              ? AppColors.textSecondary
                              : const Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                          fontSize: isMobileCompact ? 11.5 : 12.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: metric.startColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: metric.startColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        metric.icon,
                        color: metric.startColor,
                        size: isMobileCompact ? 13 : 15,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobileCompact ? 6 : 8),

                // Metric Value Display
                Text(
                  metric.value,
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    fontSize: isMobileCompact ? 17 : 20,
                    color: isDark
                        ? AppColors.textPrimary
                        : const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isMobileCompact ? 4 : 6),

                // Subtitle
                Text(
                  metric.subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                    fontSize: isMobileCompact ? 10.5 : 11.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isMobileCompact ? 6 : 8),

                // Mini Glowing Progress Track
                _buildProgressTrack(
                  fraction: metric.fraction * _curvedAnimation.value,
                  color: metric.startColor,
                  isDark: isDark,
                  isSelected: isSelected,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressTrack({
    required double fraction,
    required Color color,
    required bool isDark,
    required bool isSelected,
  }) {
    final clampedFraction = fraction.clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalTrackWidth = constraints.maxWidth;
        final filledWidth = totalTrackWidth * clampedFraction;

        return Container(
          height: 4,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(2),
          ),
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: filledWidth,
            height: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.6),
                        blurRadius: 4,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      },
    );
  }

  // ─── DATA PREPARATION & HELPERS ─────────────────────────────────────────────

  List<_KpiMetricData> _buildMetricItems(DashboardSummary summary) {
    // 1. Active Study Time (Period target benchmark: 120 minutes / 2h)
    final studyMinutes = summary.totalStudyMinutes;
    final studyFraction = (studyMinutes / 120.0).clamp(0.0, 1.0);

    // 2. Journeys Completed (Direct completion rate ratio)
    final journeyFraction = (summary.completionRate / 100.0).clamp(0.0, 1.0);

    // 3. Milestones Mastered (Checkpoints benchmark: 20 steps)
    final stepsMastered = summary.totalStepsMastered;
    final milestonesFraction = (stepsMastered / 20.0).clamp(0.0, 1.0);

    // 4. Period Quiz Accuracy (Direct percentage ratio)
    final quizFraction =
        (summary.averageQuizScoreOverall / 100.0).clamp(0.0, 1.0);

    return [
      _KpiMetricData(
        title: 'Active Study Time',
        shortTitle: 'Study Time',
        value: _formatStudyTime(studyMinutes),
        subtitle: 'Active time in period',
        fraction: studyFraction,
        icon: Icons.timer_outlined,
        startColor: const Color(0xFF06B6D4), // Cyan
        endColor: const Color(0xFF0284C7),
      ),
      _KpiMetricData(
        title: 'Journeys Completed',
        shortTitle: 'Journeys',
        value: '${summary.completedSessions} / ${summary.totalSessions}',
        subtitle:
            '${summary.completionRate.toStringAsFixed(1)}% completion rate',
        fraction: journeyFraction,
        icon: Icons.flag_rounded,
        startColor: const Color(0xFF8B5CF6), // Purple
        endColor: const Color(0xFF6D28D9),
      ),
      _KpiMetricData(
        title: 'Milestones Mastered',
        shortTitle: 'Milestones',
        value: '$stepsMastered Steps',
        subtitle: 'Roadmap checkpoints completed',
        fraction: milestonesFraction,
        icon: Icons.check_circle_outline_rounded,
        startColor: const Color(0xFF10B981), // Emerald
        endColor: const Color(0xFF059669),
      ),
      _KpiMetricData(
        title: 'Period Quiz Accuracy',
        shortTitle: 'Quiz Accuracy',
        value: '${summary.averageQuizScoreOverall.toStringAsFixed(1)}%',
        subtitle: 'Across milestone quizzes in period',
        fraction: quizFraction,
        icon: Icons.track_changes_rounded,
        startColor: const Color(0xFF3B82F6), // Electric Blue
        endColor: const Color(0xFF1D4ED8),
      ),
    ];
  }

  int _calculateCompositeMastery(List<_KpiMetricData> metrics) {
    if (metrics.isEmpty) return 0;
    // Harmonic weighted composite: Quiz (35%), Journeys (35%), Study Time (20%), Milestones (10%)
    final weighted = (metrics[3].fraction * 0.35) +
        (metrics[1].fraction * 0.35) +
        (metrics[0].fraction * 0.20) +
        (metrics[2].fraction * 0.10);
    return (weighted * 100).round().clamp(0, 100);
  }

  String _formatStudyTime(int minutes) {
    if (minutes <= 0) return '0 min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}m';
    }
  }
}

// ─── INTERNAL METRIC MODEL ───────────────────────────────────────────────────

class _KpiMetricData {
  final String title;
  final String shortTitle;
  final String value;
  final String subtitle;
  final double fraction;
  final IconData icon;
  final Color startColor;
  final Color endColor;

  const _KpiMetricData({
    required this.title,
    required this.shortTitle,
    required this.value,
    required this.subtitle,
    required this.fraction,
    required this.icon,
    required this.startColor,
    required this.endColor,
  });
}

// ─── CONCENTRIC RINGS CUSTOM PAINTER ─────────────────────────────────────────

class _ConcentricRingsPainter extends CustomPainter {
  final List<_KpiMetricData> metrics;
  final double animationProgress;
  final int? focusedIndex;
  final bool isDark;

  const _ConcentricRingsPainter({
    required this.metrics,
    required this.animationProgress,
    required this.focusedIndex,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (metrics.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final minDimension = math.min(size.width, size.height);

    // Compute stroke widths and radii dynamically based on canvas dimensions
    final baseStrokeWidth = minDimension * 0.040;
    final ringSpacing = baseStrokeWidth * 0.46;
    final outerRadius = (minDimension / 2) - baseStrokeWidth - 4;

    const startAngle = -math.pi / 2; // 12 o'clock

    for (int i = 0; i < metrics.length; i++) {
      final metric = metrics[i];
      final radius = outerRadius - (i * (baseStrokeWidth + ringSpacing));
      if (radius <= 0) continue;

      final isFocused = focusedIndex == i;
      final isAnyFocused = focusedIndex != null;
      final strokeWidth = isFocused ? (baseStrokeWidth * 1.25) : baseStrokeWidth;

      // Opacity calculation for focus effect
      final ringAlpha = isAnyFocused
          ? (isFocused ? 1.0 : 0.28)
          : 1.0;

      final rect = Rect.fromCircle(center: center, radius: radius);

      // 1. Draw subtle background track
      final trackPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = metric.startColor.withValues(
          alpha: (isDark ? 0.10 : 0.15) * ringAlpha,
        );
      canvas.drawCircle(center, radius, trackPaint);

      // 2. Draw progress arc
      final targetProgress = (metric.fraction * animationProgress).clamp(0.0, 1.0);
      if (targetProgress > 0.001) {
        // Clamp sweep slightly below 2*pi so rounded end caps render cleanly
        final sweepAngle = (targetProgress * 2 * math.pi).clamp(0.0, 2 * math.pi - 0.0001);

        // Ambient glow when focused
        if (isFocused) {
          final glowPaint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth + 4.0
            ..strokeCap = StrokeCap.round
            ..color = metric.startColor.withValues(alpha: 0.35)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
          canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);
        }

        // Gradient Arc Shader
        final gradient = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + 2 * math.pi,
          colors: [
            metric.startColor.withValues(alpha: ringAlpha),
            metric.endColor.withValues(alpha: ringAlpha),
          ],
        );

        final arcPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..shader = gradient.createShader(rect);

        canvas.drawArc(rect, startAngle, sweepAngle, false, arcPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConcentricRingsPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.focusedIndex != focusedIndex ||
        oldDelegate.isDark != isDark ||
        oldDelegate.metrics != metrics;
  }
}
