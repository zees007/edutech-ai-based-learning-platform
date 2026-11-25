import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/responsive.dart';
import '../../../../data/models/dashboard/dashboard_response.dart';
import '../../../../core/providers/active_session_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_palette.dart';

class WeakConceptsCard extends ConsumerStatefulWidget {
  final List<WeakConceptItem> weakConcepts;
  final bool stretchHeight;

  const WeakConceptsCard({
    super.key,
    required this.weakConcepts,
    this.stretchHeight = false,
  });

  @override
  ConsumerState<WeakConceptsCard> createState() => _WeakConceptsCardState();
}

class _WeakConceptsCardState extends ConsumerState<WeakConceptsCard> {
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
    final weakConcepts = widget.weakConcepts;
    final hasOverflowRisk = weakConcepts.length > 4;

    final Widget bodyContent = weakConcepts.isEmpty
        ? Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withValues(
                alpha: isDark ? 0.06 : 0.08,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.accentGreen.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.accentGreen,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Outstanding Comprehension!',
                        style: AppTextStyles.label.copyWith(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'All attempted milestone quizzes have passed with 67% (2/3) or 100% (3/3) accuracy. Keep up the high retention!',
                        style: AppTextStyles.caption.copyWith(
                          color: isDark
                              ? AppColors.textSecondary
                              : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                        for (
                          int index = 0;
                          index < weakConcepts.length;
                          index++
                        ) ...[
                          if (index > 0) const SizedBox(height: 7),
                          _buildWeakConceptItem(
                            context,
                            ref,
                            weakConcepts[index],
                            isMobile,
                          ),
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
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Concepts Needing Reinforcement',
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: isMobile ? 16 : 18,
                        color: isDark
                            ? AppColors.textPrimary
                            : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Milestone steps with quiz scores below 60% (0/3 or 1/3 correct)',
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
              if (weakConcepts.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${weakConcepts.length} to review',
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFFEF4444),
                      fontWeight: FontWeight.w700,
                      fontSize: isMobile ? 11 : 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          if (widget.stretchHeight && weakConcepts.isEmpty)
            Expanded(child: Center(child: bodyContent))
          else
            bodyContent,
        ],
      ),
    );
  }

  Widget _buildWeakConceptItem(
    BuildContext context,
    WidgetRef ref,
    WeakConceptItem item,
    bool isMobile,
  ) {
    final isDark = context.isDarkMode;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Compact Score Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFEF4444).withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${item.correctCount}/3',
                  style: AppTextStyles.label.copyWith(
                    color: const Color(0xFFEF4444),
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '${item.quizScore.toStringAsFixed(0)}%',
                  style: AppTextStyles.caption.copyWith(
                    color: const Color(0xFFEF4444),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Compact 2-Line Topic (Line 1) & Step Title (Line 2)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.topic,
                  style: AppTextStyles.caption.copyWith(
                    color: isDark
                        ? AppColors.accentCyan
                        : const Color(0xFF0284C7),
                    fontWeight: FontWeight.w600,
                    fontSize: 10.5,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  item.stepTitle.startsWith('Step ')
                      ? item.stepTitle
                      : 'Step ${item.stepIndex + 1}: ${item.stepTitle}',
                  style: AppTextStyles.body1.copyWith(
                    color: isDark
                        ? AppColors.textPrimary
                        : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Sleek Review Button
          Builder(
            builder: (context) {
              final btnColor = isDark
                  ? const Color(0xFFA78BFA)
                  : AppColors.purple;
              final isEnabled = item.sessionId.isNotEmpty;
              return InkWell(
                onTap: !isEnabled
                    ? null
                    : () async {
                        await ref
                            .read(activeSessionProvider.notifier)
                            .loadSession(item.sessionId);
                        if (context.mounted) {
                          ref
                              .read(activeSessionProvider.notifier)
                              .setActiveStep(item.stepIndex);
                          context.go('/learning');
                        }
                      },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: btnColor.withValues(alpha: isEnabled ? 0.10 : 0.04),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: btnColor.withValues(
                        alpha: isEnabled ? 0.40 : 0.15,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.replay_rounded,
                        size: 13.5,
                        color: isEnabled
                            ? btnColor
                            : btnColor.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Review',
                        style: AppTextStyles.label.copyWith(
                          color: isEnabled
                              ? btnColor
                              : btnColor.withValues(alpha: 0.4),
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
