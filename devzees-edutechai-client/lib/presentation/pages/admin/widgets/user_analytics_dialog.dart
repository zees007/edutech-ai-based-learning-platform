import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dashboard_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_palette.dart';
import '../../../../data/models/admin/user_response.dart';
import '../../../../data/models/dashboard/dashboard_response.dart';
import '../../dashboard/widgets/daily_activity_heatmap_card.dart';
import '../../dashboard/widgets/dashboard_kpi_cards.dart';
import '../../dashboard/widgets/learner_standing_hud.dart';
import '../../dashboard/widgets/learning_mode_distribution_card.dart';
import '../../dashboard/widgets/milestone_achievements_card.dart';
import '../../dashboard/widgets/quiz_trend_card.dart';
import '../../dashboard/widgets/topic_breakdown_card.dart';
import '../../dashboard/widgets/weak_concepts_card.dart';
import 'tier_badge.dart';

/// Modal inspection dialog that enables admins to inspect any registered learner's
/// all-time gamification standing, KPI metrics, quiz accuracy curves, weak concepts,
/// and permanent 6-tier prestige trophies without leaving the User Directory.
class UserAnalyticsDialog extends ConsumerStatefulWidget {
  final AdminUserResponse user;

  const UserAnalyticsDialog({super.key, required this.user});

  static Future<void> show(BuildContext context, AdminUserResponse user) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => UserAnalyticsDialog(user: user),
    );
  }

  @override
  ConsumerState<UserAnalyticsDialog> createState() => _UserAnalyticsDialogState();
}

class _UserAnalyticsDialogState extends ConsumerState<UserAnalyticsDialog> {
  String _selectedTimeRange = '30d';

  final List<Map<String, String>> _timeRanges = const [
    {'key': '7d', 'label': '7 Days'},
    {'key': '30d', 'label': '30 Days'},
    {'key': '90d', 'label': '90 Days'},
    {'key': '1y', 'label': '1 Year'},
    {'key': 'all', 'label': 'All Time'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final user = widget.user;
    final tier = user.subscription?.tier ?? 'free';
    final params = UserDashboardParams(userId: user.id, timeRange: _selectedTimeRange);
    final dashboardAsync = ref.watch(userDashboardFutureProvider(params));
    final standingAsync = ref.watch(userStandingFutureProvider(user.id));

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: 1140,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.92,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDeep : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? AppColors.glassBorder : const Color(0xFFE2E8F0),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── DIALOG HEADER ──────────────────────────────────────────
                _buildHeader(context, isDark, user, tier, standingAsync),

                const Divider(height: 1, color: Color(0x1FFFFFFF)),

                // ─── DIALOG BODY ────────────────────────────────────────────
                Expanded(
                  child: dashboardAsync.when(
                    data: (data) => _buildDashboardContent(context, isDark, data, standingAsync),
                    loading: () => _buildLoadingSkeleton(context, isDark),
                    error: (err, _) => _buildErrorView(context, isDark, err.toString()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    AdminUserResponse user,
    String tier,
    AsyncValue<LearnerStanding> standingAsync,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardBackground.withValues(alpha: 0.7)
            : const Color(0xFFF8FAFC),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // User Initials Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${user.firstName.isNotEmpty ? user.firstName[0] : ""}${user.lastName.isNotEmpty ? user.lastName[0] : ""}'.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // User Name, Email, Tier
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${user.firstName} ${user.lastName}',
                        style: AppTextStyles.h4.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TierBadge(tier: tier),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.purple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.purple.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.admin_panel_settings_rounded, size: 12, color: AppColors.purple),
                          const SizedBox(width: 4),
                          Text(
                            'Admin Inspection',
                            style: TextStyle(
                              color: AppColors.purple,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      user.email,
                      style: AppTextStyles.caption.copyWith(
                        color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                    if (user.country != null && user.country!.isNotEmpty) ...[
                      Text(
                        ' • ${user.country}',
                        style: AppTextStyles.caption.copyWith(
                          color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Time Range Filter Segment
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: _timeRanges.map((tr) {
                final isSelected = _selectedTimeRange == tr['key'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTimeRange = tr['key']!;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? AppColors.purple : Colors.white)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      tr['label']!,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.textSecondary : const Color(0xFF475569)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 12),

          // Refresh Button
          IconButton(
            tooltip: 'Refresh Analytics',
            icon: Icon(
              Icons.refresh_rounded,
              size: 20,
              color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
            ),
            onPressed: () {
              final params = UserDashboardParams(userId: user.id, timeRange: _selectedTimeRange);
              ref.invalidate(userDashboardFutureProvider(params));
              ref.invalidate(userStandingFutureProvider(user.id));
            },
          ),
          const SizedBox(width: 4),

          // Close Button
          IconButton(
            tooltip: 'Close',
            icon: Icon(
              Icons.close_rounded,
              size: 22,
              color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    bool isDark,
    dynamic data,
    AsyncValue<LearnerStanding> standingAsync,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. All-Time Gamification Standing HUD
          LearnerStandingHud(
            fallbackSummary: data.summary,
            fallbackAchievements: data.achievements,
          ),
          const SizedBox(height: 20),

          // 2. 4-KPI Summary Grid
          DashboardKpiCards(summary: data.summary),
          const SizedBox(height: 20),

          // 3. Quiz Accuracy Trendline
          QuizTrendCard(quizMetrics: data.quizMetrics),
          const SizedBox(height: 20),

          // 4. Weak Concepts Needing Reinforcement
          WeakConceptsCard(weakConcepts: data.quizMetrics.conceptsNeedingReinforcement),
          const SizedBox(height: 20),

          // 5. Learning Mode Distribution & Milestone Trophies
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 700;
              if (isWide) {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 4,
                        child: LearningModeDistributionCard(
                          modeDistribution: data.modeDistribution,
                          isCompact: constraints.maxWidth < 1100,
                          stretchHeight: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 8,
                        child: MilestoneAchievementsCard(
                          achievements: data.achievements,
                          crossAxisCount: constraints.maxWidth >= 900 ? 3 : 2,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Column(
                  children: [
                    LearningModeDistributionCard(
                      modeDistribution: data.modeDistribution,
                    ),
                    const SizedBox(height: 16),
                    MilestoneAchievementsCard(
                      achievements: data.achievements,
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 20),

          // 6. Topic Mastery Breakdown & Daily Activity Heatmap
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 700;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TopicBreakdownCard(
                        topicBreakdown: data.topicBreakdown,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DailyActivityHeatmapCard(
                        activityHeatmap: data.activityHeatmap,
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    TopicBreakdownCard(
                      topicBreakdown: data.topicBreakdown,
                    ),
                    const SizedBox(height: 16),
                    DailyActivityHeatmapCard(
                      activityHeatmap: data.activityHeatmap,
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.purple,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading learner analytics...',
            style: AppTextStyles.body2.copyWith(
              color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, bool isDark, String errorMsg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 44, color: AppColors.rose),
            const SizedBox(height: 12),
            Text(
              'Failed to Load Learner Analytics',
              style: AppTextStyles.h4.copyWith(
                color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              errorMsg,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final params = UserDashboardParams(userId: widget.user.id, timeRange: _selectedTimeRange);
                ref.invalidate(userDashboardFutureProvider(params));
                ref.invalidate(userStandingFutureProvider(widget.user.id));
              },
            ),
          ],
        ),
      ),
    );
  }
}
