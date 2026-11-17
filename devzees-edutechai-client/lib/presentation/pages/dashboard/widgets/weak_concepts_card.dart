import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/models/dashboard/dashboard_response.dart';
import '../../../../core/providers/active_session_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_palette.dart';
import '../../../widgets/glass_card.dart';

class WeakConceptsCard extends ConsumerWidget {
  final List<WeakConceptItem> weakConcepts;

  const WeakConceptsCard({
    super.key,
    required this.weakConcepts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;

    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Concepts Needing Reinforcement',
                        style: AppTextStyles.h4.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Milestone steps with quiz scores below 60% (0/3 or 1/3 correct)',
                        style: AppTextStyles.body2.copyWith(
                          color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (weakConcepts.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          if (weakConcepts.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: isDark ? 0.06 : 0.08),
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
                      children: [
                        Text(
                          'Outstanding Comprehension!',
                          style: AppTextStyles.label.copyWith(
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'All attempted milestone quizzes have passed with 67% (2/3) or 100% (3/3) accuracy. Keep up the high retention!',
                          style: AppTextStyles.caption.copyWith(
                            color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: weakConcepts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = weakConcepts[index];
                return _buildWeakConceptItem(context, ref, item);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildWeakConceptItem(
    BuildContext context,
    WidgetRef ref,
    WeakConceptItem item,
  ) {
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Score Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFEF4444).withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '${item.correctCount}/3',
                  style: AppTextStyles.label.copyWith(
                    color: const Color(0xFFEF4444),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${item.quizScore.toStringAsFixed(0)}%',
                  style: AppTextStyles.caption.copyWith(
                    color: const Color(0xFFEF4444),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Topic & Step Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.topic,
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.accentCyan : const Color(0xFF0284C7),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.stepTitle,
                  style: AppTextStyles.body1.copyWith(
                    color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Step ${item.stepIndex + 1} Assessment',
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Review Button
          OutlinedButton(
            onPressed: () async {
              // Load session into workspace and navigate to the exact step
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
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: (isDark ? AppColors.primary : AppColors.purple).withValues(alpha: 0.5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.replay_rounded,
                  size: 16,
                  color: isDark ? AppColors.primary : AppColors.purple,
                ),
                const SizedBox(width: 6),
                Text(
                  'Review',
                  style: AppTextStyles.label.copyWith(
                    color: isDark ? AppColors.primary : AppColors.purple,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
