import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../data/models/learning/session_response.dart';
import '../../../../../core/providers/gamification_provider.dart';
import '../../../../../core/utils/learning_metadata_utils.dart';
import '../../../../../core/theme/theme_palette.dart';
import '../../../../../core/theme/text_styles.dart';
import 'milestone_roadmap_stepper.dart';
import '../export/export_session_modal.dart';
import '../../../../../presentation/widgets/theme_toggle_button.dart';

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
        final isMobile = constraints.maxWidth < 650;
        final isCompactDesktop = constraints.maxWidth < 1320;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── TIER 1: Command Hub Header Bar (Desktop & Tablet only) ───
            if (!isMobile)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: context.appColors.topBarBackground,
                  border: Border(
                    bottom: BorderSide(
                      color: context.appColors.border,
                      width: 1.0,
                    ),
                  ),
                ),
                child: _buildTier1Header(
                  session: session,
                  levelData: levelData,
                  lvlPct: lvlPct,
                  topicPct: topicPct,
                  totalSteps: totalSteps,
                  isCompact: isCompactDesktop,
                ),
              ),

            // ─── TIER 2: Milestone Learning Roadmap Stepper ─────────
            if (session.steps.isNotEmpty)
              Container(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 12 : 24,
                  10,
                  isMobile ? 12 : 24,
                  12,
                ),
                decoration: BoxDecoration(
                  color: context.appColors.topBarBackground,
                  border: Border(
                    bottom: BorderSide(
                      color: context.appColors.border,
                      width: 1.0,
                    ),
                  ),
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
        );
      },
    );
  }

  // ─── TIER 1: Unified Two-Row Command Bar ────────────────────────────────────
  // Row 1: Mode & Education Level Pills (Left) & 5 HUD Metrics + Theme Switcher (Right)
  // Row 2: "YOUR GOAL" with Target Icon + Full-Width Topic Details Text
  Widget _buildTier1Header({
    required SessionResponse session,
    required Map<String, dynamic> levelData,
    required double lvlPct,
    required double topicPct,
    required int totalSteps,
    required bool isCompact,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── ROW 1: Mode & Education Level (Left) + All 5 HUD Metrics + Theme Toggle (Right) ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Learning Mode & Education Level (same pill size as other 5 HUD pills)
            _buildModePill(session.learningMode),
            const SizedBox(width: 8),
            _buildEducationLevelPill(session.studentLevel),
            const SizedBox(width: 12),
            // Right: All 5 Metric Pills (Horizontally scrollable if tight)
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLevelPill(levelData, isCompact: isCompact),
                      const SizedBox(width: 8),
                      _buildXpStreakPill(session.xpEarned, isCompact: isCompact),
                      const SizedBox(width: 8),
                      _buildLevelProgressPill(levelData, lvlPct),
                      const SizedBox(width: 8),
                      _buildTopicProgressPill(session.stepsCompleted, totalSteps, topicPct),
                      const SizedBox(width: 8),
                      _buildExportButton(session, totalSteps),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Dedicated vertical separator & pinned Theme Toggle
            Container(
              height: 20,
              width: 1,
              color: context.appColors.border,
            ),
            const SizedBox(width: 12),
            const ThemeToggleButton(size: 30),
          ],
        ),
        const SizedBox(height: 10),
        // ─── ROW 2: "YOUR GOAL" with Icon + Full-Width Topic Details Text ─────
        _buildGoalTopicRow(session),
      ],
    );
  }

  BoxDecoration _buildPillDecoration() {
    return BoxDecoration(
      color: context.isDarkMode ? const Color(0xFF191B2B) : const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: context.isDarkMode ? const Color(0x1FFFFFFF) : const Color(0xFFE2E8F0),
        width: 1.0,
      ),
    );
  }

  // ─── MODE PILL (Full-sized HUD pill matching the other 5 pills) ─────────────
  Widget _buildModePill(String mode) {
    final Color textColor = context.isDarkMode ? const Color(0xFFC084FC) : const Color(0xFF7C3AED);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: _buildPillDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LearningMetadataUtils.getModeIcon(mode),
            color: textColor,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            LearningMetadataUtils.formatBadgeLabel(mode),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ─── EDUCATION LEVEL PILL (Full-sized HUD pill matching the other 5 pills) ──
  Widget _buildEducationLevelPill(String level) {
    final Color textColor = context.isDarkMode ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: _buildPillDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LearningMetadataUtils.getLevelIcon(level),
            color: textColor,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            LearningMetadataUtils.formatBadgeLabel(level),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ─── ROW 2: UNIFIED GOAL PILL + TOPIC DETAILS TEXT ──────────────────────────
  Widget _buildGoalTopicRow(SessionResponse session) {
    final Color accentColor =
        context.isDarkMode ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8);

    return Row(
      crossAxisAlignment:
          _isTopicExpanded ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        // Unified "YOUR GOAL" Pill (matches Row 1 pill geometry)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: _buildPillDecoration(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.track_changes_rounded,
                color: accentColor,
                size: 15,
              ),
              const SizedBox(width: 5),
              Text(
                'YOUR GOAL',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Full Width Goal Topic Details with click to expand
        Expanded(
          child: _buildTopicDetails(session),
        ),
      ],
    );
  }

  // ─── GOAL TOPIC DETAILS (Expandable only when overflowing 1 line) ────────────
  Widget _buildTopicDetails(SessionResponse session) {
    final textStyle = TextStyle(
      fontSize: 13.5,
      fontWeight: FontWeight.w600,
      color: context.isDarkMode ? Colors.white : context.appColors.textPrimary,
      letterSpacing: -0.2,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: session.topic, style: textStyle),
          maxLines: 1,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);
        final bool overflowsSingleLine = textPainter.didExceedMaxLines;
        textPainter.dispose();

        final textWidget = AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topLeft,
          child: Text(
            session.topic,
            maxLines: _isTopicExpanded ? null : 1,
            overflow: _isTopicExpanded ? null : TextOverflow.ellipsis,
            style: textStyle,
          ),
        );

        if (!overflowsSingleLine && !_isTopicExpanded) {
          return textWidget;
        }

        return SelectionContainer.disabled(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            opaque: true,
            child: Tooltip(
              message: _isTopicExpanded ? 'Tap to collapse' : 'Tap to expand topic',
              waitDuration: const Duration(milliseconds: 400),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    _isTopicExpanded = !_isTopicExpanded;
                  });
                },
                child: SizedBox(
                  width: double.infinity,
                  child: textWidget,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── MICRO METRIC PILL 1: CURRENT LEVEL ──────────────────────────────────────
  Widget _buildLevelPill(Map<String, dynamic> levelData, {bool isCompact = false}) {
    final int level = levelData['level'] as int;
    final String title = levelData['title'] as String;
    final String description = GamificationUtils.getLevelDescription(level);

    return Tooltip(
      message: 'Level $level • $title\n$description',
      waitDuration: const Duration(milliseconds: 350),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 10, vertical: 6),
        decoration: _buildPillDecoration(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.military_tech_rounded,
              color: context.isDarkMode ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
              size: 15,
            ),
            const SizedBox(width: 5),
            Text(
              'Lvl $level',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.isDarkMode ? Colors.white : context.appColors.textPrimary,
              ),
            ),
            if (!isCompact) ...[
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: context.isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── MICRO METRIC PILL 2: TOTAL XP & STREAK ─────────────────────────────────
  Widget _buildXpStreakPill(int xpEarned, {bool isCompact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 10, vertical: 6),
      decoration: _buildPillDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            color: context.isDarkMode ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
            size: 15,
          ),
          const SizedBox(width: 4),
          Text(
            '$xpEarned XP',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: context.isDarkMode ? const Color(0xFFFDE68A) : const Color(0xFFB45309),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '|',
            style: TextStyle(
              fontSize: 11,
              color: context.isDarkMode ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isCompact ? '🔥 ' : '🔥 Streak: ',
            style: TextStyle(
              fontSize: 11,
              color: context.isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          Text(
            '0',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: context.isDarkMode ? Colors.white : context.appColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── MICRO METRIC PILL 3: LEVEL PROGRESS BAR ────────────────────────────────
  Widget _buildLevelProgressPill(Map<String, dynamic> levelData, double lvlPct) {
    final int currentLevel = levelData['level'] as int;
    final int xpInLevel = levelData['xp_in_level'] as int;
    final int xpNeeded = levelData['xp_needed_for_next'] as int;
    final int totalXp = levelData['total_xp'] as int;
    final bool isMaxLevel = levelData['is_max_level'] as bool? ?? false;
    final int xpRemaining = (xpNeeded - xpInLevel).clamp(0, xpNeeded);

    final String tooltipMessage = isMaxLevel
        ? 'Max Level $currentLevel reached ($totalXp total XP)'
        : '$xpInLevel / $xpNeeded XP in Level $currentLevel ($xpRemaining XP to Level ${currentLevel + 1})';

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: lvlPct, end: lvlPct),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, animatedLvlPct, child) {
        return Tooltip(
          message: tooltipMessage,
          waitDuration: const Duration(milliseconds: 350),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: _buildPillDecoration(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isMaxLevel
                      ? 'Lvl $currentLevel • MAX'
                      : 'Lvl $currentLevel → ${currentLevel + 1}',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: context.isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
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
                    color: context.isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: animatedLvlPct,
                      child: Container(color: const Color(0xFF8B5CF6)),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isMaxLevel ? 'MAX' : '$xpInLevel/$xpNeeded XP',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: context.isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
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
              color: context.isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
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
              color: context.isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
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
              color: context.isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // ─── EXPORT ACTION BUTTON ───────────────────────────────────────────────────
  Widget _buildExportButton(SessionResponse session, int totalSteps) {
    final bool isCompleted = totalSteps > 0 && session.stepsCompleted >= totalSteps;
    final Color iconColor = isCompleted
        ? (context.isDarkMode ? const Color(0xFFC084FC) : const Color(0xFF7C3AED))
        : (context.isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B));
    final Color textColor = isCompleted
        ? (context.isDarkMode ? const Color(0xFFC084FC) : const Color(0xFF7C3AED))
        : (context.isDarkMode ? Colors.white : context.appColors.textPrimary);

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
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: _buildPillDecoration().copyWith(
            border: isCompleted
                ? Border.all(
                    color: context.isDarkMode
                        ? const Color(0x66C084FC)
                        : const Color(0x407C3AED),
                    width: 1.0,
                  )
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.download_rounded,
                size: 14,
                color: iconColor,
              ),
              const SizedBox(width: 5),
              Text(
                'Export',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isCompleted ? FontWeight.w700 : FontWeight.w600,
                  color: textColor,
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
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: _buildPillDecoration().copyWith(
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.alt_route_rounded,
            color: context.isDarkMode ? const Color(0xFFC084FC) : const Color(0xFF7C3AED),
            size: 14,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Milestone Learning Roadmap',
          style: AppTextStyles.subtitle2.copyWith(
            fontWeight: FontWeight.w800,
            color: context.appColors.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
