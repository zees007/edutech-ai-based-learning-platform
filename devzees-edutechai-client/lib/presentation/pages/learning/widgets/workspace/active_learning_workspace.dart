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
    final isQuizDone = currentStep.quizScore != null ||
        (currentStep.userAnswers != null &&
            currentStep.userAnswers!.isNotEmpty &&
            currentStep.userAnswers!.values.any(
                (v) => v != null && v.toString().trim().isNotEmpty));
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
          ? SplitLearningWorkspace(
              key: ValueKey('split_step_$currentIndex'),
              session: widget.session,
              activeState: widget.activeState,
              currentStepIndex: currentIndex,
              totalSteps: totalSteps,
              maxUnlockedIndex: maxUnlockedIndex,
              isQuizGated: isQuizGated,
              onStepChange: (index) {
                ref.read(activeSessionProvider.notifier).setActiveStep(index);
              },
            )
          : Center(
              child: Text(
                'No steps available.',
                style: AppTextStyles.bodyPrimary.copyWith(color: AppColors.textMuted),
              ),
            ),
    );
  }
}
