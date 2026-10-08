import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../data/models/learning/session_response.dart';
import '../../../../../core/providers/gamification_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import 'milestone_roadmap_stepper.dart';
import '../export/export_session_modal.dart';

/// A consolidated, ultra-premium Glassmorphic Command & Mastery Hub.
/// Merges Mastery Gamification, 4 Key Metrics, Your Goal, and the Milestone Roadmap
/// into a single cohesive container, reclaiming up to 65% of vertical viewport real estate.
class UnifiedLearningCommandHub extends ConsumerStatefulWidget {
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
  ConsumerState<UnifiedLearningCommandHub> createState() => _UnifiedLearningCommandHubState();
}

class _UnifiedLearningCommandHubState extends ConsumerState<UnifiedLearningCommandHub> {
  bool _isHovered = false;
  bool _isTopicExpanded = false;

  Map<String, dynamic> _calculateLevel(int totalXp) =>
      GamificationUtils.calculateLevelData(totalXp);

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
              color: AppColors.isDark ? const Color(0xFF11121D) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.isDark
                    ? const Color(0x1FFFFFFF)
                    : (_isHovered
                        ? AppColors.accentBlue.withValues(alpha: 0.5)
                        : AppColors.glassBorder),
                width: 1.0,
              ),
              boxShadow: AppColors.isDark
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 25,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: const Color(0x14000000),
                        blurRadius: _isHovered ? 28 : 24,
                        offset: Offset(0, _isHovered ? 10 : 8),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.isDark ? const Color(0xFF11121D) : Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ─── TIER 1: Command Hub Header Bar ───
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 14 : 16,
                          vertical: isMobile ? 10 : 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.isDark
                              ? const Color(0xFF11121D)
                              : AppColors.surfaceSolidHeader,
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.isDark
                                  ? const Color(0x14FFFFFF)
                                  : const Color(0xFFE2E8F0),
                              width: 1.0,
                            ),
                          ),
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
                        Container(
                          padding: EdgeInsets.fromLTRB(
                            isMobile ? 14 : 16,
                            10,
                            isMobile ? 14 : 16,
                            14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.isDark
                                ? const Color(0xFF11121D)
                                : Colors.transparent,
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
            const SizedBox(width: 8),
            _buildExportButton(session, totalSteps),
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
              const SizedBox(width: 8),
              _buildExportButton(session, totalSteps),
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
              const SizedBox(width: 8),
              _buildExportButton(session, totalSteps),
            ],
          ),
        ),
      ],
    );
  }

  BoxDecoration _buildPillDecoration() {
    return BoxDecoration(
      color: AppColors.isDark ? const Color(0xFF191B2B) : const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: AppColors.isDark ? const Color(0x1FFFFFFF) : const Color(0xFFE2E8F0),
        width: 1.0,
      ),
    );
  }

  // ─── GOAL & CONTEXT CLUSTER ──────────────────────────────────────────────────
  Widget _buildGoalContextBlock(SessionResponse session, {bool isMobile = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Goal Icon Accent Box
        Container(
          width: isMobile ? 30 : 34,
          height: isMobile ? 30 : 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.isDark
                ? const Color(0xFF2E1065).withValues(alpha: 0.7)
                : const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.isDark
                  ? const Color(0xFF7C3AED).withValues(alpha: 0.5)
                  : const Color(0xFFC7D2FE),
              width: 1.0,
            ),
          ),
          child: Icon(
            Icons.explore_outlined,
            color: AppColors.isDark ? const Color(0xFFC4B5FD) : const Color(0xFF4F46E5),
            size: isMobile ? 16 : 18,
          ),
        ),
        const SizedBox(width: 10),
        // Goal Title + Chips
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 4,
                children: [
                  Text(
                    'YOUR GOAL',
                    style: TextStyle(
                      color: AppColors.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  _buildMicroChip(
                    label: _formatMode(session.learningMode),
                    isViolet: true,
                    icon: Icons.visibility_outlined,
                  ),
                  _buildMicroChip(
                    label: _formatLevel(session.studentLevel),
                    isViolet: false,
                    icon: Icons.school_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 3),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isTopicExpanded = !_isTopicExpanded;
                  });
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Tooltip(
                    message: _isTopicExpanded ? 'Tap to collapse' : 'Tap to expand topic',
                    waitDuration: const Duration(milliseconds: 400),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      alignment: Alignment.topCenter,
                      child: Text(
                        session.topic,
                        maxLines: _isTopicExpanded ? null : (isMobile ? 2 : 1),
                        overflow: _isTopicExpanded ? null : TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isMobile ? 12.5 : 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.isDark ? Colors.white : AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: _buildPillDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.military_tech_rounded,
            color: Color(0xFFFBBF24),
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            'Lvl ${levelData['level']}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            (levelData['title'] as String),
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: AppColors.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // ─── MICRO METRIC PILL 2: TOTAL XP & STREAK ─────────────────────────────────
  Widget _buildXpStreakPill(int xpEarned) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: _buildPillDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: Color(0xFFFBBF24),
            size: 15,
          ),
          const SizedBox(width: 4),
          Text(
            '$xpEarned XP',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFDE68A),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '|',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '🔥 Streak: ',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          Text(
            '0',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── MICRO METRIC PILL 3: LEVEL PROGRESS BAR ────────────────────────────────
  Widget _buildLevelProgressPill(Map<String, dynamic> levelData, double lvlPct) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: lvlPct, end: lvlPct),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, animatedLvlPct, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: _buildPillDecoration(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Lvl ${levelData['level']} → ${(levelData['level'] as int) + 1}',
                style: TextStyle(
                  fontSize: 10.5,
                  color: AppColors.isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '${(animatedLvlPct * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFA78BFA),
                ),
              ),
              const SizedBox(width: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 56,
                  height: 6,
                  color: AppColors.isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: animatedLvlPct,
                    child: Container(color: const Color(0xFF8B5CF6)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${levelData['xp_in_level']}/${levelData['xp_needed_for_next']}',
                style: TextStyle(
                  fontSize: 9.5,
                  color: AppColors.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── MICRO METRIC PILL 4: TOPIC COMPLETION BAR ──────────────────────────────
  Widget _buildTopicProgressPill(int completedSteps, int totalSteps, double topicPct) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: _buildPillDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Roadmap',
            style: TextStyle(
              fontSize: 10.5,
              color: AppColors.isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '${(topicPct * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF34D399),
            ),
          ),
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 40,
              height: 6,
              color: AppColors.isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: topicPct,
                child: Container(color: const Color(0xFF10B981)),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$completedSteps/$totalSteps',
            style: TextStyle(
              fontSize: 9.5,
              color: AppColors.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // ─── EXPORT ACTION BUTTON ───────────────────────────────────────────────────
  Widget _buildExportButton(SessionResponse session, int totalSteps) {
    final bool isCompleted = totalSteps > 0 && session.stepsCompleted >= totalSteps;

    return Tooltip(
      message: isCompleted
          ? 'Export Mastered Journey (.md / .pdf)'
          : 'Complete all milestones to unlock export (${session.stepsCompleted}/$totalSteps)',
      child: InkWell(
        onTap: () {
          ExportSessionModal.show(
            context,
            sessionId: session.sessionId,
            topic: session.topic,
            totalSteps: totalSteps,
            stepsCompleted: session.stepsCompleted,
            xpEarned: session.xpEarned,
            isCompleted: isCompleted,
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: _buildPillDecoration(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.download_rounded,
                size: 14,
                color: isCompleted
                    ? const Color(0xFFA78BFA)
                    : (AppColors.isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B)),
              ),
              const SizedBox(width: 5),
              Text(
                'Export',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isCompleted
                      ? Colors.white
                      : (AppColors.isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                ),
              ),
            ],
          ),
        ),
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
    required bool isViolet,
    required IconData icon,
  }) {
    final bgColor = isViolet
        ? (AppColors.isDark ? const Color(0x994C1D95) : const Color(0xFFEDE9FE))
        : (AppColors.isDark ? const Color(0x801E3A8A) : const Color(0xFFEFF6FF));
    final borderColor = isViolet
        ? (AppColors.isDark ? const Color(0x668B5CF6) : const Color(0xFFC4B5FD))
        : (AppColors.isDark ? const Color(0x663B82F6) : const Color(0xFFBFDBFE));
    final textColor = isViolet
        ? (AppColors.isDark ? const Color(0xFFDDD6FE) : const Color(0xFF6D28D9))
        : (AppColors.isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 0.9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: textColor),
          const SizedBox(width: 3.5),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 9.5,
              color: textColor,
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
