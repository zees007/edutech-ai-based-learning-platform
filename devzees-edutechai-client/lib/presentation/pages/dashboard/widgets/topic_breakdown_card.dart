import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/responsive.dart';
import '../../../../data/models/dashboard/dashboard_response.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_palette.dart';
import '../../../widgets/gradient_button.dart';

/// Reusable card displaying learning journey mastery breakdown with completion progress.
class TopicBreakdownCard extends StatelessWidget {
  final List<TopicBreakdownItem> topicBreakdown;
  final VoidCallback? onStartNewJourney;
  final ValueChanged<TopicBreakdownItem>? onJourneyTap;

  const TopicBreakdownCard({
    super.key,
    required this.topicBreakdown,
    this.onStartNewJourney,
    this.onJourneyTap,
  });

  void _handleStartNewJourney(BuildContext context) {
    if (onStartNewJourney != null) {
      onStartNewJourney!();
    } else {
      try {
        context.go('/learning');
      } catch (_) {}
    }
  }

  void _handleJourneyTap(BuildContext context, TopicBreakdownItem item) {
    if (onJourneyTap != null) {
      onJourneyTap!(item);
    } else if (item.sessionId != null && item.sessionId!.isNotEmpty) {
      try {
        context.go('/learning');
      } catch (_) {}
    }
  }

  Widget _buildModePill(String? mode, bool isDark) {
    final cleanMode = (mode ?? 'visual').toLowerCase();
    IconData iconData;
    Color lightColor;
    Color darkColor;
    String modeLabel;

    switch (cleanMode) {
      case 'deep_dive':
        iconData = Icons.biotech_rounded;
        lightColor = const Color(0xFF0284C7);
        darkColor = const Color(0xFF38BDF8);
        modeLabel = 'Deep Dive';
        break;
      case 'bite_sized':
        iconData = Icons.bolt_rounded;
        lightColor = const Color(0xFFD97706);
        darkColor = const Color(0xFFFBBF24);
        modeLabel = 'Bite-Sized';
        break;
      case 'visual':
      default:
        iconData = Icons.movie_creation_outlined;
        lightColor = const Color(0xFF7C3AED);
        darkColor = const Color(0xFFA78BFA);
        modeLabel = 'Visual';
        break;
    }

    final modeColor = isDark ? darkColor : lightColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: modeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: modeColor.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 11, color: modeColor),
          const SizedBox(width: 4),
          Text(
            modeLabel,
            style: AppTextStyles.caption.copyWith(
              color: modeColor,
              fontWeight: FontWeight.w700,
              fontSize: 10.5,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isComplete, bool isDark) {
    // Completed = Emerald Green, In Progress = Warm Amber / Gold
    final color = isComplete
        ? const Color(0xFF10B981)
        : const Color(0xFFD97706);
    final darkColor = isComplete
        ? const Color(0xFF34D399)
        : const Color(0xFFFBBF24);
    final badgeColor = isDark ? darkColor : color;
    final iconData = isComplete
        ? Icons.check_circle_rounded
        : Icons.timelapse_rounded;
    final text = isComplete ? 'Completed' : 'In Progress';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
          Icon(iconData, size: 11, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w700,
              fontSize: 10.5,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsPill(int completed, int total, bool isDark) {
    const green = AppColors.accentGreen;
    final displayGreen = isDark ? const Color(0xFF34D399) : green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: 11, color: displayGreen),
          const SizedBox(width: 4),
          Text(
            '$completed/$total steps',
            style: AppTextStyles.caption.copyWith(
              color: displayGreen,
              fontWeight: FontWeight.w700,
              fontSize: 10.5,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentagePill(double pct, bool isComplete, bool isDark) {
    // Completed (100%) = Emerald Green, In Progress % = Warm Amber
    final color = isComplete
        ? const Color(0xFF10B981)
        : const Color(0xFFD97706);
    final darkColor = isComplete
        ? const Color(0xFF34D399)
        : const Color(0xFFFBBF24);
    final pillColor = isDark ? darkColor : color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: pillColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: pillColor.withValues(alpha: 0.20),
          width: 0.8,
        ),
      ),
      child: Text(
        '${pct.toStringAsFixed(0)}%',
        style: AppTextStyles.caption.copyWith(
          color: pillColor,
          fontWeight: FontWeight.w800,
          fontSize: 11,
          height: 1.1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final topics = topicBreakdown;
    final count = topics.length;

    final headerTitle = count > 0
        ? 'Top $count Learning Journey Mastery Breakdown'
        : 'Learning Journey Mastery Breakdown';
    final headerSubtitle = count > 0
        ? 'Ranked by completion progress in the selected period'
        : 'Most explored subjects across your learning roadmap';

    final isMobile = Responsive.isMobile(context);
    final int cols = isMobile ? 1 : 2;

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark
                          ? const Color(0xFF818CF8)
                          : const Color(0xFF6366F1))
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.route_rounded,
                  color: isDark
                      ? const Color(0xFF818CF8)
                      : const Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headerTitle,
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: isMobile ? 15 : 18,
                        color: isDark
                            ? AppColors.textPrimary
                            : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      headerSubtitle,
                      style: AppTextStyles.body2.copyWith(
                        color: isDark
                            ? AppColors.textSecondary
                            : const Color(0xFF64748B),
                        fontSize: isMobile ? 12 : 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          if (topics.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.03),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.explore_outlined,
                      size: 36,
                      color: isDark
                          ? AppColors.textMuted
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No Journeys in This Period',
                    style: AppTextStyles.body1.copyWith(
                      color: isDark
                          ? AppColors.textPrimary
                          : const Color(0xFF1E293B),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'You haven\'t explored any learning journeys during this timeframe.\nStart a new journey to begin leveling up!',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.textSecondary
                          : const Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 18),
                  GradientButton(
                    text: 'Start New Journey',
                    icon: Icons.add_rounded,
                    iconFirst: true,
                    height: 40,
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    onPressed: () => _handleStartNewJourney(context),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                for (int i = 0; i < topics.length; i += cols) ...[
                  if (i > 0) const SizedBox(height: 14),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int j = 0; j < cols; j++) ...[
                          if (j > 0) const SizedBox(width: 20),
                          if (i + j < topics.length)
                            Expanded(
                              child: _buildTopicItem(
                                context,
                                i + j,
                                topics[i + j],
                                isDark,
                              ),
                            )
                          else
                            const Expanded(child: SizedBox.shrink()),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTopicItem(
    BuildContext context,
    int index,
    TopicBreakdownItem t,
    bool isDark,
  ) {
    final isComplete = t.isComplete;
    // 10 distinct, electric & vibrant colors arranged for optimal visual harmony
    const colors = [
      Color(0xFF8B5CF6), // 1. Electric Violet
      Color(0xFF06B6D4), // 2. Electric Cyan
      Color(0xFF10B981), // 3. Electric Emerald
      Color(0xFFF59E0B), // 4. Electric Amber
      Color(0xFFEC4899), // 5. Electric Neon Pink
      Color(0xFF6366F1), // 6. Electric Indigo
      Color(0xFF14B8A6), // 7. Electric Teal
      Color(0xFFF97316), // 8. Electric Sunset Orange
      Color(0xFFA855F7), // 9. Electric Magenta Purple
      Color(0xFF84CC16), // 10. Electric Lime
    ];
    final barColor = colors[index % colors.length];

    return InkWell(
      onTap: () => _handleJourneyTap(context, t),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Title Row with Topic & Status Badge
            Row(
              children: [
                Expanded(
                  child: Tooltip(
                    message: t.topic,
                    waitDuration: const Duration(milliseconds: 300),
                    child: Text(
                      t.topic,
                      style: AppTextStyles.label.copyWith(
                        color: isDark
                            ? AppColors.textPrimary
                            : const Color(0xFF1E293B),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(isComplete, isDark),
              ],
            ),
            const SizedBox(height: 7),

            // 2. Metadata Row: Mode Pill + Steps Pill on left, Percentage on right
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 4,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildModePill(t.learningMode, isDark),
                      const SizedBox(width: 6),
                      _buildStepsPill(t.completedSteps, t.totalSteps, isDark),
                    ],
                  ),
                  _buildPercentagePill(t.percentage, isComplete, isDark),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // 3. Progress Track
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (t.percentage / 100).clamp(0.04, 1.0),
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
