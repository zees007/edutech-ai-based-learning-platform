import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/providers/active_session_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import 'unified_learning_command_hub.dart';
import 'split_learning_workspace.dart';

class ActiveLearningWorkspace extends ConsumerWidget {
  const ActiveLearningWorkspace({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeState = ref.watch(activeSessionProvider);
    final session = activeState.session;

    if (session == null) {
      return const SizedBox.shrink();
    }

    final int maxUnlockedIndex = (session.currentStepIndex > session.stepsCompleted
            ? session.currentStepIndex
            : session.stepsCompleted)
        .clamp(0, session.steps.isNotEmpty ? session.steps.length - 1 : 0);

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 10.0),
              child: UnifiedLearningCommandHub(
                session: session,
                activeIndex: activeState.activeStepIndex,
                maxUnlockedIndex: maxUnlockedIndex,
                onStepTapped: (index) {
                  ref.read(activeSessionProvider.notifier).setActiveStep(index);
                },
              ),
            ),
          ),
        ];
      },
      // Main Content Area — Now uses the dual-panel split workspace
      body: _StepContentContainer(
        activeState: activeState,
        session: session,
      ),
    );
  }
}

class _StepContentContainer extends ConsumerStatefulWidget {
  final ActiveSessionState activeState;
  final dynamic session;

  const _StepContentContainer({
    required this.activeState,
    required this.session,
  });

  @override
  ConsumerState<_StepContentContainer> createState() => _StepContentContainerState();
}

class _StepContentContainerState extends ConsumerState<_StepContentContainer> {
  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.activeState.activeStepIndex;
    final totalSteps = widget.session.steps.length;
    final maxUnlockedIndex = (widget.session.currentStepIndex > widget.session.stepsCompleted
            ? widget.session.currentStepIndex
            : widget.session.stepsCompleted)
        .clamp(0, totalSteps > 0 ? totalSteps - 1 : 0);

    final currentStep = widget.session.steps[currentIndex];

    // Check quiz gating: disable forward navigation if quiz is pending
    final hasQuiz = currentStep.quiz != null && currentStep.quiz!.isNotEmpty;
    final isQuizDone = currentStep.quizScore != null || currentStep.userAnswers != null;
    final isQuizGated = hasQuiz && !isQuizDone;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: AppColors.commandHubGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
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
      child: widget.activeState.isLoading
        ? const Padding(
            padding: EdgeInsets.all(48),
            child: Center(child: CircularProgressIndicator()),
          )
        : widget.session.steps.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Premium Floating Toolbar ───
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSolidHeader,
                  ),
                  child: Row(
                    children: [
                      // Left label & Step Navigation
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceDeep,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('🧩', style: TextStyle(fontSize: 14)),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Socratic Tutor',
                              style: AppTextStyles.subtitle2,
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.accentGreen,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accentGreen.withValues(alpha: 0.6),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Online',
                              style: AppTextStyles.captionBold.copyWith(
                                color: AppColors.accentGreen,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Flexible(
                              child: _buildStepToolbarNav(
                                currentIndex: currentIndex,
                                maxUnlockedIndex: maxUnlockedIndex,
                                totalSteps: totalSteps,
                                isPrerequisite: currentStep.isPrerequisite,
                                prerequisiteNote: currentStep.prerequisite,
                                status: currentStep.status,
                                isQuizGated: isQuizGated,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ─── Dual-Panel Split Workspace ───
                Expanded(
                  child: SplitLearningWorkspace(
                    key: ValueKey('split_step_$currentIndex'),
                    session: widget.session,
                    activeState: widget.activeState,
                    currentStepIndex: currentIndex,
                  ),
                ),
              ],
            )
          : Center(
              child: Text(
                'No steps available.',
                style: AppTextStyles.bodyPrimary.copyWith(color: AppColors.textMuted),
              ),
            ),
    );
  }

  Widget _buildStepToolbarNav({
    required int currentIndex,
    required int maxUnlockedIndex,
    required int totalSteps,
    bool isPrerequisite = false,
    String? prerequisiteNote,
    String status = 'pending',
    bool isQuizGated = false,
  }) {
    final canGoBack = currentIndex > 0;
    final isReviewing = currentIndex < maxUnlockedIndex;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Previous Step quick button
        if (canGoBack)
          Tooltip(
            message: 'Go back to previous step ($currentIndex)',
            child: InkWell(
              onTap: () {
                ref.read(activeSessionProvider.notifier).setActiveStep(currentIndex - 1);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.glassSurface.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_back_ios_new_rounded, size: 11, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'Prev',
                      style: AppTextStyles.badge.copyWith(fontSize: 11, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (canGoBack) const SizedBox(width: 8),
        // Step pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isReviewing
                ? AppColors.cyanLight.withValues(alpha: 0.15)
                : AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isReviewing
                  ? AppColors.cyanLight.withValues(alpha: 0.45)
                  : AppColors.primary.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Step ${currentIndex + 1} of $totalSteps',
                style: AppTextStyles.badge.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: isReviewing ? AppColors.cyanLight : AppColors.purpleLight,
                ),
              ),
              if (isReviewing) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.cyanLight.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Review Mode',
                    style: AppTextStyles.badge.copyWith(fontSize: 9, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildStepStatusPill(status),
        if (isPrerequisite) ...[
          const SizedBox(width: 8),
          Tooltip(
            message: prerequisiteNote != null && prerequisiteNote.trim().isNotEmpty
                ? 'Prerequisite concept: $prerequisiteNote'
                : 'Foundational prerequisite milestone step',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                gradient: AppColors.amberGradient,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentAmber.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.school_rounded, size: 12, color: Colors.white),
                  const SizedBox(width: 5),
                  Text(
                    'Prerequisite',
                    style: AppTextStyles.badge.copyWith(
                      fontSize: 11,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        // Next Step button — disabled when quiz is gated
        if (currentIndex < maxUnlockedIndex) ...[
          const SizedBox(width: 8),
          Tooltip(
            message: isQuizGated
                ? 'Complete the quiz first to proceed'
                : 'Go forward to Step ${currentIndex + 2}',
            child: InkWell(
              onTap: isQuizGated
                  ? null
                  : () {
                      ref.read(activeSessionProvider.notifier).setActiveStep(currentIndex + 1);
                    },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  gradient: isQuizGated
                      ? LinearGradient(
                          colors: [
                            AppColors.glassSurface.withValues(alpha: 0.1),
                            AppColors.glassSurface.withValues(alpha: 0.05),
                          ],
                        )
                      : AppColors.royalBlueIndigoGradient,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isQuizGated
                        ? AppColors.glassBorder
                        : AppColors.purpleLight.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isQuizGated) ...[
                      Icon(Icons.lock_rounded, size: 11, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      'Next',
                      style: AppTextStyles.badge.copyWith(
                        fontSize: 11,
                        color: isQuizGated ? AppColors.textMuted : Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: isQuizGated ? AppColors.textMuted : Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

Widget _buildStepStatusPill(String rawStatus, {bool compact = false}) {
  final status = rawStatus.toLowerCase();
  final isComplete = status == 'complete';
  final isInProgress = status == 'in_progress';

  Color textColor;
  Color bgColor;
  Color borderColor;
  IconData icon;
  String label;

  if (isComplete) {
    textColor = AppColors.accentGreen;
    bgColor = AppColors.accentGreen.withValues(alpha: 0.15);
    borderColor = AppColors.accentGreen.withValues(alpha: 0.45);
    icon = Icons.check_circle_rounded;
    label = 'Completed';
  } else if (isInProgress) {
    textColor = AppColors.purpleLight;
    bgColor = AppColors.purpleLight.withValues(alpha: 0.15);
    borderColor = AppColors.purpleLight.withValues(alpha: 0.45);
    icon = Icons.bolt_rounded;
    label = 'In Progress';
  } else {
    textColor = AppColors.slate400;
    bgColor = AppColors.glassSurface.withValues(alpha: 0.06);
    borderColor = AppColors.glassBorder;
    icon = Icons.schedule_rounded;
    label = 'Pending';
  }

  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: compact ? 7 : 9,
      vertical: compact ? 3 : 5,
    ),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(compact ? 6 : 8),
      border: Border.all(color: borderColor, width: 0.9),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: compact ? 11 : 12, color: textColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.badge.copyWith(
            fontSize: compact ? 10 : 11,
            color: textColor,
            letterSpacing: 0.2,
          ),
        ),
      ],
    ),
  );
}
