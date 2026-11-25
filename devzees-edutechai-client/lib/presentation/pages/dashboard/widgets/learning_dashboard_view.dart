import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/responsive.dart';
import '../../../../core/providers/dashboard_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_palette.dart';
import '../../../widgets/shimmer_loading.dart';
import 'daily_activity_heatmap_card.dart';
import 'dashboard_header.dart';
import 'dashboard_kpi_cards.dart';
import 'learning_mode_distribution_card.dart';
import 'milestone_achievements_card.dart';
import 'quiz_trend_card.dart';
import 'topic_breakdown_card.dart';
import 'weak_concepts_card.dart';

/// Embeddable dashboard content widget for use inside the learning shell.
///
/// Contains only the scrollable body content (no Scaffold, AppBar, or
/// GlowBackground — those are provided by the parent shell).
class LearningDashboardView extends ConsumerStatefulWidget {
  const LearningDashboardView({super.key});

  @override
  ConsumerState<LearningDashboardView> createState() =>
      _LearningDashboardViewState();
}

class _LearningDashboardViewState extends ConsumerState<LearningDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final isDark = context.isDarkMode;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        return Container(
          color: isDark ? AppColors.canvasBackground : const Color(0xFFF8FAFC),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── TIER 1 & 2: Pinned Learner Standing & Analytics Command Hub ───
              if (!Responsive.isMobile(context))
                DashboardHeader(
                  onRefresh: () {
                    ref.read(learnerStandingProvider.notifier).refresh();
                    ref.read(dashboardProvider.notifier).refresh();
                  },
                  isRefreshing: state.isLoading && state.data != null,
                  fallbackSummary: state.data?.summary,
                  fallbackAchievements: state.data?.achievements,
                ),

              // ─── TIER 3: Scrollable Analytics Body Content ───
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    await ref.read(dashboardProvider.notifier).refresh();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile
                          ? 16
                          : (constraints.maxWidth >= 1500 ? 24 : 32),
                      vertical: isMobile ? 16 : 24,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth >= 1500
                              ? 1560
                              : (constraints.maxWidth >= 1280 ? 1380 : 1180),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Loading State
                            if (state.isLoading && state.data == null)
                              _buildLoadingSkeleton(context, isMobile)
                            // Error State
                            else if (state.error != null && state.data == null)
                              _buildErrorView(context, state.error!)
                            // Loaded Content
                            else if (state.data != null) ...[
                              // 1. Concentric Donut Hub & KPI Cards
                              DashboardKpiCards(summary: state.data!.summary),
                              const SizedBox(height: 24),

                              // 2. Right below KPIs: Learning Mode Distribution & Milestone Achievements
                              if (constraints.maxWidth >=
                                  Responsive.mobileBreakpoint)
                                IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: LearningModeDistributionCard(
                                          modeDistribution:
                                              state.data!.modeDistribution,
                                          isCompact:
                                              constraints.maxWidth < 1150,
                                          stretchHeight: true,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        flex: 8,
                                        child: MilestoneAchievementsCard(
                                          achievements:
                                              state.data!.achievements,
                                          crossAxisCount:
                                              constraints.maxWidth >=
                                                      Responsive.tabletBreakpoint
                                                  ? 3
                                                  : 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else ...[
                                LearningModeDistributionCard(
                                  modeDistribution:
                                      state.data!.modeDistribution,
                                ),
                                const SizedBox(height: 16),
                                MilestoneAchievementsCard(
                                  achievements: state.data!.achievements,
                                ),
                              ],
                              const SizedBox(height: 24),

                              // 3. Quiz Trend Card (Accuracy Curve)
                              QuizTrendCard(
                                quizMetrics: state.data!.quizMetrics,
                              ),
                              const SizedBox(height: 24),

                              // 4. Full-Width Topic Mastery Breakdown (2-col on Tablet/Desktop, 1-col on Mobile)
                              TopicBreakdownCard(
                                topicBreakdown: state.data!.topicBreakdown,
                              ),
                              const SizedBox(height: 24),

                              // 5. Daily Activity Log & Weak Concepts (Exact Same Height on Tablet/Desktop)
                              if (constraints.maxWidth >=
                                  Responsive.mobileBreakpoint)
                                IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: DailyActivityHeatmapCard(
                                          activityHeatmap:
                                              state.data!.activityHeatmap,
                                          stretchHeight: true,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        flex: 7,
                                        child: WeakConceptsCard(
                                          weakConcepts: state
                                              .data!
                                              .quizMetrics
                                              .conceptsNeedingReinforcement,
                                          stretchHeight: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else ...[
                                DailyActivityHeatmapCard(
                                  activityHeatmap: state.data!.activityHeatmap,
                                ),
                                const SizedBox(height: 16),
                                WeakConceptsCard(
                                  weakConcepts: state
                                      .data!
                                      .quizMetrics
                                      .conceptsNeedingReinforcement,
                                ),
                              ],
                              const SizedBox(height: 48),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context, bool isMobile) {
    return ShimmerLoading(
      child: Column(
        children: [
          if (isMobile) ...[
            const ShimmerBox(
              width: double.infinity,
              height: 110,
              borderRadius: BorderRadius.all(Radius.circular(18)),
            ),
            const SizedBox(height: 16),
            const ShimmerBox(
              width: double.infinity,
              height: 110,
              borderRadius: BorderRadius.all(Radius.circular(18)),
            ),
          ] else
            Row(
              children: const [
                Expanded(
                  child: ShimmerBox(
                    height: 120,
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ShimmerBox(
                    height: 120,
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ShimmerBox(
                    height: 120,
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),
          const ShimmerBox(
            width: double.infinity,
            height: 260,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          const SizedBox(height: 24),
          const ShimmerBox(
            width: double.infinity,
            height: 200,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String error) {
    final isDark = context.isDarkMode;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load dashboard metrics',
              style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.body2.copyWith(
                color: isDark
                    ? AppColors.textSecondary
                    : const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(dashboardProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
