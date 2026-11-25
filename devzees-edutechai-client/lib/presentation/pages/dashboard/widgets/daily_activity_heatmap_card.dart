import 'package:flutter/material.dart';
import '../../../../core/constants/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_palette.dart';
import '../../../../data/models/dashboard/dashboard_response.dart';

/// Reusable card displaying daily study activity and milestone checkpoints.
class DailyActivityHeatmapCard extends StatefulWidget {
  final List<HeatmapDayItem> activityHeatmap;
  final bool stretchHeight;

  const DailyActivityHeatmapCard({
    super.key,
    required this.activityHeatmap,
    this.stretchHeight = false,
  });

  @override
  State<DailyActivityHeatmapCard> createState() =>
      _DailyActivityHeatmapCardState();
}

class _DailyActivityHeatmapCardState extends State<DailyActivityHeatmapCard> {
  final ScrollController _scrollController = ScrollController();
  bool _isHovered = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final isMobile = Responsive.isMobile(context);
    final days = widget.activityHeatmap.reversed.toList();
    final hasOverflowRisk = days.length > 5;

    final Widget content = days.isEmpty
        ? Container(
            height: 140,
            alignment: Alignment.center,
            child: Text(
              'No activity days recorded yet.',
              style: AppTextStyles.caption.copyWith(
                color: isDark ? context.appColors.textSecondary : const Color(0xFF94A3B8),
              ),
            ),
          )
        : MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 290),
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  thickness: const WidgetStatePropertyAll(3.5),
                  radius: const Radius.circular(8),
                  thumbColor: WidgetStatePropertyAll(
                    (isDark ? Colors.white : const Color(0xFF64748B))
                        .withValues(alpha: 0.28),
                  ),
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: _isHovered && hasOverflowRisk,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(right: hasOverflowRisk ? 8 : 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int index = 0; index < days.length; index++) ...[
                          if (index > 0) const SizedBox(height: 8),
                          _buildDayRow(days[index], isDark),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );

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
                              ? const Color(0xFF34D399)
                              : const Color(0xFF059669))
                          .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.event_available_rounded,
                  color: isDark
                      ? const Color(0xFF34D399)
                      : const Color(0xFF059669),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Activity Log',
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: isMobile ? 16 : 18,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Step milestones completed by day',
                      style: AppTextStyles.body2.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (widget.stretchHeight && days.isEmpty)
            Expanded(child: Center(child: content))
          else
            content,
        ],
      ),
    );
  }

  Widget _buildDayRow(HeatmapDayItem day, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentGreen,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    day.date,
                    style: AppTextStyles.label.copyWith(
                      color: isDark
                          ? context.appColors.textPrimary
                          : const Color(0xFF1E293B),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${day.stepsCount} ${day.stepsCount == 1 ? "step" : "steps"}',
                style: AppTextStyles.caption.copyWith(
                  color: isDark
                      ? AppColors.accentCyan
                      : const Color(0xFF0284C7),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '+${day.xpEarned} XP',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.accentAmber,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
