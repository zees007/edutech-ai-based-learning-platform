import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/data/models/learning/session_response.dart';
import 'package:devzees_edutechai_client/data/models/learning/milestone_step.dart';
import 'package:devzees_edutechai_client/core/providers/gamification_provider.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/presentation/pages/learning/widgets/export/export_session_modal.dart';

/// An ultra-premium, glassmorphic Mobile Command Hub Bottom Sheet.
/// Matches the mobile sidebar theme colors and provides Goal details,
/// Gamification progress, full Milestone timeline, and Export actions.
class MobileCommandHubSheet extends StatefulWidget {
  final SessionResponse session;
  final int activeIndex;
  final int maxUnlockedIndex;
  final ValueChanged<int> onStepTapped;

  const MobileCommandHubSheet({
    super.key,
    required this.session,
    required this.activeIndex,
    required this.maxUnlockedIndex,
    required this.onStepTapped,
  });

  static Future<void> show(
    BuildContext context, {
    required SessionResponse session,
    required int activeIndex,
    required int maxUnlockedIndex,
    required ValueChanged<int> onStepTapped,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (modalContext) => MobileCommandHubSheet(
        session: session,
        activeIndex: activeIndex,
        maxUnlockedIndex: maxUnlockedIndex,
        onStepTapped: (index) {
          Navigator.of(modalContext).pop();
          onStepTapped(index);
        },
      ),
    );
  }

  @override
  State<MobileCommandHubSheet> createState() => _MobileCommandHubSheetState();
}

class _MobileCommandHubSheetState extends State<MobileCommandHubSheet> {
  Map<String, dynamic> _calculateLevel(int totalXp) =>
      GamificationUtils.calculateLevelData(totalXp);

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final int totalSteps = session.steps.isNotEmpty ? session.steps.length : 1;
    final double topicPct = (session.stepsCompleted / totalSteps).clamp(0.0, 1.0);
    final levelData = _calculateLevel(session.xpEarned);
    final double lvlPct = (levelData['progress'] as double).clamp(0.0, 1.0);
    final screenHeight = MediaQuery.of(context).size.height;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.88),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.sidebarBackground,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(
                color: AppColors.glassBorder,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 32,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top drag handle
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textMuted.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Sheet Title Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.hub_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Command & Mastery Hub',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'Progress, Gamification & Milestones',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        splashRadius: 18,
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, thickness: 1, color: AppColors.glassBorder),

                // Scrollable content
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Goal Context Card
                        _buildGoalCard(session),
                        const SizedBox(height: 12),

                        // 2. Gamification Metrics HUD
                        _buildGamificationCard(
                          session: session,
                          levelData: levelData,
                          lvlPct: lvlPct,
                          topicPct: topicPct,
                          totalSteps: totalSteps,
                        ),
                        const SizedBox(height: 16),

                        // 3. Milestone Learning Roadmap List
                        _buildRoadmapSection(session, totalSteps),
                        const SizedBox(height: 18),

                        // 4. Export Journey Button
                        _buildExportSection(session, totalSteps),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── GOAL CONTEXT CARD ─────────────────────────────────────────────────────
  Widget _buildGoalCard(SessionResponse session) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'YOUR GOAL',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              _buildMicroChip(
                label: _formatMode(session.learningMode),
                isViolet: true,
                icon: Icons.psychology_rounded,
              ),
              const SizedBox(width: 6),
              _buildMicroChip(
                label: _formatLevel(session.studentLevel),
                isViolet: false,
                icon: Icons.school_rounded,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            session.topic,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.35,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ─── GAMIFICATION CARD ─────────────────────────────────────────────────────
  Widget _buildGamificationCard({
    required SessionResponse session,
    required Map<String, dynamic> levelData,
    required double lvlPct,
    required double topicPct,
    required int totalSteps,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level Title & XP row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accentAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.military_tech_rounded,
                  size: 16,
                  color: AppColors.accentAmber,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lvl ${levelData['level']} • ${levelData['title']}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${levelData['xp_in_level']}/${levelData['xp_needed_for_next']} XP to Level ${(levelData['level'] as int) + 1}',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(lvlPct * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.adaptivePurpleLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Level progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: double.infinity,
              height: 7,
              color: AppColors.trackNeutral,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: lvlPct,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.accentViolet, AppColors.purpleLight],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 3 Stats Pills Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricMiniBox(
                  icon: Icons.star_rounded,
                  iconColor: AppColors.accentAmber,
                  label: 'Total XP',
                  value: '${session.xpEarned}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricMiniBox(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: AppColors.accentRose,
                  label: 'Streak',
                  value: '0 Days',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricMiniBox(
                  icon: Icons.alt_route_rounded,
                  iconColor: AppColors.accentGreen,
                  label: 'Progress',
                  value: '${session.stepsCompleted}/$totalSteps',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricMiniBox({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.sidebarBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: iconColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── MILESTONE ROADMAP SECTION ─────────────────────────────────────────────
  Widget _buildRoadmapSection(SessionResponse session, int totalSteps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.alt_route_rounded,
              size: 16,
              color: AppColors.adaptivePurpleLight,
            ),
            const SizedBox(width: 6),
            Text(
              'Milestone Learning Roadmap',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Steps list
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: session.steps.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final step = session.steps[index];
            final isActive = index == widget.activeIndex;
            final isCompleted =
                index < session.stepsCompleted || step.status == 'complete';
            final isUnlocked = index <= widget.maxUnlockedIndex;
            final bool isJourneyComplete = totalSteps > 0 && session.stepsCompleted >= totalSteps;
            final int inProcessIndex = session.stepsCompleted.clamp(0, totalSteps - 1);
            final bool isCurrentJourneyStep = !isJourneyComplete &&
                !isCompleted &&
                (index == inProcessIndex || step.status == 'in_progress');

            return _buildTimelineStepItem(
              step: step,
              index: index,
              isActive: isActive,
              isCompleted: isCompleted,
              isUnlocked: isUnlocked,
              isCurrentJourneyStep: isCurrentJourneyStep,
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimelineStepItem({
    required MilestoneStep step,
    required int index,
    required bool isActive,
    required bool isCompleted,
    required bool isUnlocked,
    required bool isCurrentJourneyStep,
  }) {
    final bool isReviewing = isActive && isCompleted;

    Color borderColor;
    Color bgColor;

    if (isReviewing) {
      borderColor = AppColors.cyanLight.withValues(alpha: 0.50);
      bgColor = AppColors.cyanLight.withValues(alpha: 0.12);
    } else if (isActive) {
      borderColor = AppColors.primary.withValues(alpha: 0.45);
      bgColor = AppColors.primary.withValues(alpha: 0.12);
    } else if (isCurrentJourneyStep) {
      borderColor = AppColors.primary.withValues(alpha: 0.35);
      bgColor = AppColors.primary.withValues(alpha: 0.06);
    } else if (isCompleted) {
      borderColor = AppColors.accentGreen.withValues(alpha: 0.35);
      bgColor = AppColors.accentGreen.withValues(alpha: 0.08);
    } else {
      borderColor = AppColors.glassBorder;
      bgColor = AppColors.chipBackground;
    }

    return GestureDetector(
      onTap: isUnlocked ? () => widget.onStepTapped(index) : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Status Icon Circle
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.accentGreen
                    : (isActive || isCurrentJourneyStep)
                        ? AppColors.primary
                        : (isUnlocked
                            ? AppColors.textSecondary.withValues(alpha: 0.2)
                            : Colors.transparent),
                border: isUnlocked && !isCompleted && !isActive && !isCurrentJourneyStep
                    ? Border.all(color: AppColors.textMuted, width: 1.2)
                    : (!isUnlocked
                        ? Border.all(color: AppColors.textMuted.withValues(alpha: 0.4), width: 1.0)
                        : null),
              ),
              child: isCompleted
                  ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                  : (isActive || isCurrentJourneyStep)
                      ? const Icon(Icons.play_arrow_rounded, size: 16, color: Colors.white)
                      : !isUnlocked
                          ? Icon(Icons.lock_outline_rounded,
                              size: 13, color: AppColors.textMuted)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
            ),
            const SizedBox(width: 10),

            // Step Title & Status text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'STEP ${index + 1}',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: isReviewing
                              ? AppColors.cyanLight
                              : (isActive || isCurrentJourneyStep)
                                  ? AppColors.primary
                                  : isCompleted
                                      ? AppColors.accentGreen
                                      : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (isReviewing)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.cyanLight.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.cyanLight.withValues(alpha: 0.45),
                              width: 0.8,
                            ),
                          ),
                          child: const Text(
                            'REVIEWING',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.cyanLight,
                            ),
                          ),
                        )
                      else if (isActive || isCurrentJourneyStep)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: isActive ? 0.2 : 0.14),
                            borderRadius: BorderRadius.circular(4),
                            border: !isActive
                                ? Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.35),
                                    width: 0.8,
                                  )
                                : null,
                          ),
                          child: const Text(
                            'IN PROCESS',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      else if (isCompleted)
                        Text(
                          '• Completed',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentGreen,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                      color: isUnlocked
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            if (isUnlocked && !isActive)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isCurrentJourneyStep) ...[
                    Text(
                      'Resume',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 3),
                  ],
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: isCurrentJourneyStep
                        ? AppColors.primary
                        : AppColors.textMuted,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ─── EXPORT SECTION ────────────────────────────────────────────────────────
  Widget _buildExportSection(SessionResponse session, int totalSteps) {
    final bool isCompleted = totalSteps > 0 && session.stepsCompleted >= totalSteps;

    return OutlinedButton.icon(
      onPressed: () {
        Navigator.of(context).pop();
        ExportSessionModal.show(
          context,
          sessionId: session.sessionId,
          topic: session.topic,
          totalSteps: session.steps.length,
          stepsCompleted: session.stepsCompleted,
          xpEarned: session.xpEarned,
          isCompleted: isCompleted,
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(
          color: AppColors.glassBorder,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: const Icon(Icons.file_download_outlined, size: 16),
      label: const Text(
        'Export Learning Journey',
        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
      ),
    );
  }

  // ─── MICRO CHIP HELPER ──────────────────────────────────────────────────────
  Widget _buildMicroChip({
    required String label,
    required bool isViolet,
    required IconData icon,
  }) {
    final textColor = isViolet
        ? AppColors.adaptivePurpleLight
        : AppColors.adaptiveBlueLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.sidebarBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 4),
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
