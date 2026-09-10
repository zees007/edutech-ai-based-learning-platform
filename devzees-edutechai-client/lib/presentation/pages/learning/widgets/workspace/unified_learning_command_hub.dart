import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../../data/models/learning/session_response.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import 'milestone_roadmap_stepper.dart';

/// A consolidated, ultra-premium Glassmorphic Command & Mastery Hub.
/// Merges Mastery Gamification, 4 Key Metrics, Your Goal, and the Milestone Roadmap
/// into a single cohesive container, reclaiming up to 65% of vertical viewport real estate.
class UnifiedLearningCommandHub extends StatefulWidget {
  final SessionResponse session;
  final int activeIndex;
  final int maxUnlockedIndex;
  final ValueChanged<int> onStepTapped;

  const UnifiedLearningCommandHub({
    super.key,
    required this.session,
    required this.activeIndex,
    required this.maxUnlockedIndex,
    required this.onStepTapped,
  });

  @override
  State<UnifiedLearningCommandHub> createState() => _UnifiedLearningCommandHubState();
}

class _UnifiedLearningCommandHubState extends State<UnifiedLearningCommandHub> {
  bool _isHovered = false;

  Map<String, dynamic> _calculateLevel(int totalXp) {
    const levels = [
      {"level": 1, "xp_required": 0, "title": "Curious Explorer"},
      {"level": 2, "xp_required": 100, "title": "Knowledge Seeker"},
      {"level": 3, "xp_required": 300, "title": "Quick Learner"},
      {"level": 4, "xp_required": 600, "title": "Deep Thinker"},
      {"level": 5, "xp_required": 1000, "title": "Rising Scholar"},
      {"level": 6, "xp_required": 1500, "title": "Concept Master"},
      {"level": 7, "xp_required": 2200, "title": "Wisdom Weaver"},
      {"level": 8, "xp_required": 3000, "title": "Knowledge Architect"},
      {"level": 9, "xp_required": 4000, "title": "Enlightened Mind"},
      {"level": 10, "xp_required": 5500, "title": "Grand Sage"},
    ];

    var current = levels[0];
    var nextLevel = levels.length > 1 ? levels[1] : null;

    for (var i = 0; i < levels.length; i++) {
      final levelInfo = levels[i];
      if (totalXp >= (levelInfo["xp_required"] as int)) {
        current = levelInfo;
        nextLevel = (i + 1 < levels.length) ? levels[i + 1] : null;
      } else {
        break;
      }
    }

    int xpInLevel;
    int xpNeeded;
    double progress;

    if (nextLevel != null) {
      xpInLevel = totalXp - (current["xp_required"] as int);
      xpNeeded = (nextLevel["xp_required"] as int) - (current["xp_required"] as int);
      progress = xpNeeded > 0 ? (xpInLevel / xpNeeded) : 1.0;
    } else {
      xpInLevel = totalXp - (current["xp_required"] as int);
      xpNeeded = 0;
      progress = 1.0;
    }

    return {
      "level": current["level"],
      "title": current["title"],
      "total_xp": totalXp,
      "xp_for_current_level": current["xp_required"],
      "xp_for_next_level": nextLevel != null ? nextLevel["xp_required"] : current["xp_required"],
      "xp_in_level": xpInLevel,
      "xp_needed_for_next": xpNeeded,
      "progress": progress.clamp(0.0, 1.0),
    };
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final int totalSteps = session.steps.isNotEmpty ? session.steps.length : 1;
    final double topicPct = (session.stepsCompleted / totalSteps).clamp(0.0, 1.0);
    final levelData = _calculateLevel(session.xpEarned);
    final double lvlPct = (levelData['progress'] as double).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1050;
        final isTablet = constraints.maxWidth >= 650 && constraints.maxWidth < 1050;
        final isMobile = constraints.maxWidth < 650;

        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purpleLight.withValues(alpha: _isHovered ? 0.16 : 0.08),
                  blurRadius: _isHovered ? 28 : 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AppColors.purple.withValues(alpha: 0.08),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    gradient: AppColors.commandHubGradient,
                    borderRadius: const BorderRadius.all(Radius.circular(18)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ─── TIER 1: Solid Header (Matching Socratic Tutor Toolbar) ───
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 14 : 20,
                          vertical: isMobile ? 12 : 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSolidHeader,
                        ),
                        child: isDesktop
                            ? _buildDesktopTier1(
                                session: session,
                                levelData: levelData,
                                lvlPct: lvlPct,
                                topicPct: topicPct,
                                totalSteps: totalSteps,
                              )
                            : isTablet
                                ? _buildTabletTier1(
                                    session: session,
                                    levelData: levelData,
                                    lvlPct: lvlPct,
                                    topicPct: topicPct,
                                    totalSteps: totalSteps,
                                  )
                                : _buildMobileTier1(
                                    session: session,
                                    levelData: levelData,
                                    lvlPct: lvlPct,
                                    topicPct: topicPct,
                                    totalSteps: totalSteps,
                                  ),
                      ),

                      // ─── TIER 2: Milestone Learning Roadmap Stepper ─────────
                      if (session.steps.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            isMobile ? 14 : 20,
                            12,
                            isMobile ? 14 : 20,
                            16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildRoadmapHeader(totalSteps),
                              const SizedBox(height: 8),
                              MilestoneRoadmapStepper(
                                steps: session.steps,
                                activeIndex: widget.activeIndex,
                                maxUnlockedIndex: widget.maxUnlockedIndex,
                                onStepTapped: widget.onStepTapped,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── DESKTOP TIER 1 (Single Line Flow: Goal Left, Metrics Right) ─────────────
  Widget _buildDesktopTier1({
    required SessionResponse session,
    required Map<String, dynamic> levelData,
    required double lvlPct,
    required double topicPct,
    required int totalSteps,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Goal Info & Badges
        Expanded(
          flex: 4,
          child: _buildGoalContextBlock(session),
        ),
        const SizedBox(width: 16),
        // 4 High-Density HUD Metrics
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLevelPill(levelData),
            const SizedBox(width: 8),
            _buildXpStreakPill(session.xpEarned),
            const SizedBox(width: 8),
            _buildLevelProgressPill(levelData, lvlPct),
            const SizedBox(width: 8),
            _buildTopicProgressPill(session.stepsCompleted, totalSteps, topicPct),
          ],
        ),
      ],
    );
  }

  // ─── TABLET TIER 1 (Stacked: Goal Top, 4 Metrics Row Underneath) ─────────────
  Widget _buildTabletTier1({
    required SessionResponse session,
    required Map<String, dynamic> levelData,
    required double lvlPct,
    required double topicPct,
    required int totalSteps,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGoalContextBlock(session),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              _buildLevelPill(levelData),
              const SizedBox(width: 8),
              _buildXpStreakPill(session.xpEarned),
              const SizedBox(width: 8),
              _buildLevelProgressPill(levelData, lvlPct),
              const SizedBox(width: 8),
              _buildTopicProgressPill(session.stepsCompleted, totalSteps, topicPct),
            ],
          ),
        ),
      ],
    );
  }

  // ─── MOBILE TIER 1 (Goal Block + Horizontal Scrollable Metrics) ──────────────
  Widget _buildMobileTier1({
    required SessionResponse session,
    required Map<String, dynamic> levelData,
    required double lvlPct,
    required double topicPct,
    required int totalSteps,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGoalContextBlock(session, isMobile: true),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              _buildLevelPill(levelData),
              const SizedBox(width: 8),
              _buildXpStreakPill(session.xpEarned),
              const SizedBox(width: 8),
              _buildLevelProgressPill(levelData, lvlPct),
              const SizedBox(width: 8),
              _buildTopicProgressPill(session.stepsCompleted, totalSteps, topicPct),
            ],
          ),
        ),
      ],
    );
  }

  // ─── GOAL & CONTEXT CLUSTER ──────────────────────────────────────────────────
  Widget _buildGoalContextBlock(SessionResponse session, {bool isMobile = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Goal Icon Accent Box
        Container(
          width: isMobile ? 32 : 36,
          height: isMobile ? 32 : 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.purple.withValues(alpha: 0.25),
                AppColors.indigo.withValues(alpha: 0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.purple.withValues(alpha: 0.40),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.purple.withValues(alpha: 0.22),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.track_changes_rounded,
            color: AppColors.lavender,
            size: isMobile ? 18 : 20,
          ),
        ),
        const SizedBox(width: 10),
        // Goal Title + Chips
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'YOUR GOAL',
                    style: AppTextStyles.badge.copyWith(
                      color: AppColors.purpleLight,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Micro Mode Chip
                  _buildMicroChip(
                    label: _formatMode(session.learningMode),
                    color: AppColors.purpleLight,
                    icon: Icons.psychology_rounded,
                  ),
                  const SizedBox(width: 6),
                  // Micro Audience Chip
                  _buildMicroChip(
                    label: _formatLevel(session.studentLevel),
                    color: AppColors.cyanLight,
                    icon: Icons.school_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                session.topic,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.h3.copyWith(
                  fontSize: isMobile ? 13 : 15,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── MICRO METRIC PILL 1: CURRENT LEVEL ──────────────────────────────────────
  Widget _buildLevelPill(Map<String, dynamic> levelData) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.purpleLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.purpleLight.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.purpleLight.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('🏆', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Lvl ${levelData['level']}',
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                (levelData['title'] as String),
                style: AppTextStyles.badge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.purpleLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── MICRO METRIC PILL 2: TOTAL XP & STREAK ─────────────────────────────────
  Widget _buildXpStreakPill(int xpEarned) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.cyanLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cyanLight.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.cyanLight.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('⭐', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$xpEarned XP',
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 10)),
                  const SizedBox(width: 2),
                  Text(
                    'Streak: 0',
                    style: AppTextStyles.badge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.cyanLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── MICRO METRIC PILL 3: LEVEL PROGRESS BAR ─────────────────────────────────
  Widget _buildLevelProgressPill(Map<String, dynamic> levelData, double lvlPct) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.glassSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.fuchsia.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Lvl ${levelData['level']} → ${(levelData['level'] as int) + 1}',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate400,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${(lvlPct * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.captionBold.copyWith(
                  color: AppColors.fuchsia,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.glassSurface.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: lvlPct,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.pinkPurpleGradient,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.fuchsia.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${levelData['xp_in_level']}/${levelData['xp_needed_for_next']}',
                style: AppTextStyles.badge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── MICRO METRIC PILL 4: TOPIC COMPLETION BAR ──────────────────────────────
  Widget _buildTopicProgressPill(int completedSteps, int totalSteps, double topicPct) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.glassSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greenMint.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Roadmap',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate400,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${(topicPct * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.captionBold.copyWith(
                  color: AppColors.greenMint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.glassSurface.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: topicPct,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.emeraldGradient,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.greenMint.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$completedSteps/$totalSteps',
                style: AppTextStyles.badge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── ROADMAP HEADER STRIP ───────────────────────────────────────────────────
  Widget _buildRoadmapHeader(int totalSteps) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.purpleLight.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.alt_route_rounded,
            color: AppColors.purpleLight,
            size: 14,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Milestone Learning Roadmap',
          style: AppTextStyles.subtitle2.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.purpleLight.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.purpleLight.withValues(alpha: 0.3)),
          ),
          child: Text(
            'Step ${widget.activeIndex + 1} of $totalSteps',
            style: AppTextStyles.badge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.lavender,
            ),
          ),
        ),
      ],
    );
  }


  // ─── MICRO CHIP HELPER ──────────────────────────────────────────────────────
  Widget _buildMicroChip({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3.5),
          Text(
            label,
            style: AppTextStyles.badge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  String _formatLevel(String raw) {
    // Strip leading/trailing underscores and whitespace, remove emojis/symbols, and convert inner underscores to spaces
    final stripped = raw
        .replaceAll(RegExp(r'^_+|_+$'), '')
        .replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true), '')
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .trim();
    final spaced = stripped.replaceAll('_', ' ').trim();
    if (spaced.isEmpty) return raw.toUpperCase();
    return spaced.toUpperCase();
  }

  String _formatMode(String raw) {
    final stripped = raw
        .replaceAll(RegExp(r'^_+|_+$'), '')
        .replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true), '')
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .trim();
    final spaced = stripped.replaceAll('_', ' ').trim();
    if (spaced.isEmpty) return raw.toUpperCase();
    return spaced.toUpperCase();
  }
}
