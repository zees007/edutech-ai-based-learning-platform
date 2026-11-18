import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../data/models/dashboard/dashboard_response.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_palette.dart';
import '../../../widgets/glass_card.dart';

class ModeAndTopicCards extends StatefulWidget {
  final ModeDistribution modeDistribution;
  final List<TopicBreakdownItem> topicBreakdown;

  const ModeAndTopicCards({
    super.key,
    required this.modeDistribution,
    required this.topicBreakdown,
  });

  @override
  State<ModeAndTopicCards> createState() => _ModeAndTopicCardsState();
}

class _ModeAndTopicCardsState extends State<ModeAndTopicCards> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 760;

        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildModeCard(context)),
              const SizedBox(width: 16),
              Expanded(child: _buildTopicCard(context)),
            ],
          );
        } else {
          return Column(
            children: [
              _buildModeCard(context),
              const SizedBox(height: 16),
              _buildTopicCard(context),
            ],
          );
        }
      },
    );
  }

  Widget _buildModeCard(BuildContext context) {
    final isDark = context.isDarkMode;
    final modes = widget.modeDistribution;
    final total = modes.total;

    return LayoutBuilder(
      builder: (context, cardConstraints) {
        final isMobile = cardConstraints.maxWidth < 450;
        final isCompact = cardConstraints.maxWidth < 360;

        return GlassCard(
          borderRadius: 20,
          padding: EdgeInsets.all(isMobile ? 16 : 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Learning Mode Distribution',
                style: AppTextStyles.h4.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: isMobile ? 16 : 18,
                  color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Usage ratio across Visual 🎬, Deep Dive 🔬, and Bite-Sized ⚡ modes',
                style: AppTextStyles.body2.copyWith(
                  color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                  fontSize: isMobile ? 12 : 13,
                ),
              ),
              const SizedBox(height: 20),

              if (total == 0)
                Container(
                  height: 180,
                  alignment: Alignment.center,
                  child: Text(
                    'No sessions recorded yet.',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                    ),
                  ),
                )
              else ...[
                if (isCompact) ...[
                  Center(
                    child: SizedBox(
                      width: 130,
                      height: 130,
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  _touchedIndex = -1;
                                  return;
                                }
                                _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
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
                ] else
                  Row(
                    children: [
                      // Donut Pie Chart
                      SizedBox(
                        width: 130,
                        height: 130,
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    _touchedIndex = -1;
                                    return;
                                  }
                                  _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
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
                      Expanded(
                        child: _buildLegendColumn(context, modes),
                      ),
                    ],
                  ),
              ],
            ],
          ),
        );
      },
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
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.label.copyWith(
              color: isDark ? AppColors.textPrimary : const Color(0xFF1E293B),
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
            color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTopicCard(BuildContext context) {
    final isDark = context.isDarkMode;
    final topics = widget.topicBreakdown;

    return LayoutBuilder(
      builder: (context, cardConstraints) {
        final isMobile = cardConstraints.maxWidth < 450;

        return GlassCard(
          borderRadius: 20,
          padding: EdgeInsets.all(isMobile ? 16 : 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Topic Mastery Breakdown',
                style: AppTextStyles.h4.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: isMobile ? 16 : 18,
                  color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Most explored subjects across your learning roadmap',
                style: AppTextStyles.body2.copyWith(
                  color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                  fontSize: isMobile ? 12 : 13,
                ),
              ),
              const SizedBox(height: 16),

              if (topics.isEmpty)
                Container(
                  height: 180,
                  alignment: Alignment.center,
                  child: Text(
                    'No topics explored yet.',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topics.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final t = topics[index];
                    final colors = [
                      const Color(0xFF8B5CF6),
                      const Color(0xFF38BDF8),
                      const Color(0xFF10B981),
                      const Color(0xFFF59E0B),
                      const Color(0xFFEC4899),
                    ];
                    final barColor = colors[index % colors.length];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                t.topic,
                                style: AppTextStyles.label.copyWith(
                                  color: isDark ? AppColors.textPrimary : const Color(0xFF1E293B),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${t.sessionCount} ${t.sessionCount == 1 ? "journey" : "journeys"} (${t.percentage.toStringAsFixed(0)}%)',
                              style: AppTextStyles.caption.copyWith(
                                color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (t.percentage / 100).clamp(0.05, 1.0),
                            backgroundColor: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.06),
                            valueColor: AlwaysStoppedAnimation<Color>(barColor),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
