import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import 'recommended_videos.dart';
import 'academic_papers.dart';
import 'knowledge_check_quiz.dart';

/// Tabbed resource panel with 3 tabs: Videos, Papers, Quiz.
/// Includes a pinned quiz gating bar at the bottom.
class LearningResourcesPanel extends ConsumerStatefulWidget {
  final dynamic currentStep;
  final dynamic session;
  final int stepIndex;
  final Future<void> Function() onNextStep;

  const LearningResourcesPanel({
    super.key,
    required this.currentStep,
    required this.session,
    required this.stepIndex,
    required this.onNextStep,
  });

  @override
  ConsumerState<LearningResourcesPanel> createState() =>
      _LearningResourcesPanelState();

  // ─── Static builders for mobile tab reuse ─────────────────────

  static Widget buildVideosContent(List<dynamic>? videos) {
    if (videos == null || videos.isEmpty) return const SizedBox.shrink();
    return RecommendedVideos(videos: videos);
  }

  static Widget buildPapersContent(List<dynamic>? papers, String topic) {
    if (papers == null || papers.isEmpty) {
      return AcademicPapers(papers: papers, initialTopic: topic);
    }
    return AcademicPapers(papers: papers, initialTopic: topic);
  }

  static Widget buildQuizContent({
    required List<dynamic>? quiz,
    required int stepIndex,
    required Future<void> Function() onNextStep,
    required VoidCallback onQuizSubmitted,
  }) {
    if (quiz == null || quiz.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.rose.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.quiz_outlined,
                  size: 32, color: AppColors.rose.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 12),
            Text(
              'No quiz available for this step',
              style:
                  AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: KnowledgeCheckQuiz(
        key: ValueKey('quiz_step_$stepIndex'),
        quiz: quiz,
        stepIndex: stepIndex,
        onNextStep: onNextStep,
        onQuizSubmitted: onQuizSubmitted,
      ),
    );
  }
}

class _LearningResourcesPanelState
    extends ConsumerState<LearningResourcesPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _quizSubmitted = false;

  bool _isQuizCompleted(dynamic step) {
    if (step == null) return false;
    if (step.quizScore != null) return true;
    if (step.userAnswers != null && step.userAnswers is Map) {
      final map = step.userAnswers as Map;
      if (map.isNotEmpty &&
          map.values.any((v) => v != null && v.toString().trim().isNotEmpty)) {
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Check if quiz is already completed
    final step = widget.currentStep;
    if (_isQuizCompleted(step)) {
      _quizSubmitted = true;
    }
  }

  @override
  void didUpdateWidget(covariant LearningResourcesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stepIndex != widget.stepIndex) {
      _quizSubmitted = false;
      final step = widget.currentStep;
      if (_isQuizCompleted(step)) {
        _quizSubmitted = true;
      }
      // Reset to first tab on step change
      _tabController.animateTo(0);
    } else if (!_quizSubmitted && _isQuizCompleted(widget.currentStep)) {
      _quizSubmitted = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onQuizSubmitted() {
    setState(() {
      _quizSubmitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.currentStep;
    final hasVideos = step.videos != null && step.videos!.isNotEmpty;
    final hasPapers = step.papers != null && step.papers!.isNotEmpty;
    final hasQuiz = step.quiz != null && step.quiz!.isNotEmpty;
    final isQuizDone = _quizSubmitted || _isQuizCompleted(step);

    return Column(
      children: [
        // Tab bar
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.5),
            border: Border(
              bottom:
                  BorderSide(color: AppColors.glassBorder, width: 0.5),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: false,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textMuted,
            labelStyle: AppTextStyles.captionBold.copyWith(fontSize: 12),
            unselectedLabelStyle:
                AppTextStyles.caption.copyWith(fontSize: 12),
            tabs: [
              _buildTab(
                icon: Icons.play_circle_outline_rounded,
                label: 'Videos',
                badgeColor: hasVideos ? AppColors.accentRose : null,
                count: hasVideos ? step.videos!.length : 0,
              ),
              _buildTab(
                icon: Icons.science_outlined,
                label: 'Papers',
                badgeColor: hasPapers ? AppColors.blueLight : null,
                count: hasPapers ? step.papers!.length : 0,
              ),
              _buildQuizTab(
                hasQuiz: hasQuiz,
                isQuizDone: isQuizDone,
              ),
            ],
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Videos tab
              _buildVideosTab(step),
              // Papers tab
              _buildPapersTab(step),
              // Quiz tab
              _buildQuizTab2(step),
            ],
          ),
        ),

        // ─── Quiz Gating / Advance Bar (pinned at bottom) ───
        if (hasQuiz)
          _buildGatingBar(context, isQuizDone)
        else if (widget.stepIndex < (widget.session.steps.length - 1))
          _buildNoQuizAdvanceBar(),
      ],
    );
  }

  Widget _buildTab({
    required IconData icon,
    required String label,
    Color? badgeColor,
    int count = 0,
  }) {
    return Tab(
      height: 42,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Badge(
            isLabelVisible: badgeColor != null && count > 0,
            label: Text(
              '$count',
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
            ),
            backgroundColor: badgeColor ?? Colors.transparent,
            child: Icon(icon, size: 16),
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildQuizTab({
    required bool hasQuiz,
    required bool isQuizDone,
  }) {
    return Tab(
      height: 42,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasQuiz && isQuizDone)
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.accentGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentGreen.withValues(alpha: 0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 12,
                color: Colors.white,
              ),
            )
          else if (hasQuiz && !isQuizDone)
            _PulsingDot(color: AppColors.accentAmber)
          else
            const Icon(Icons.quiz_outlined, size: 16),
          const SizedBox(width: 6),
          const Text('Quiz'),
        ],
      ),
    );
  }

  Widget _buildVideosTab(dynamic step) {
    if (step.videos == null || step.videos!.isEmpty) {
      return _buildEmptyState(
        icon: Icons.play_circle_outline_rounded,
        label: 'No recommended videos for this step',
        color: AppColors.accentRose,
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: RecommendedVideos(videos: step.videos),
    );
  }

  Widget _buildPapersTab(dynamic step) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: AcademicPapers(
        papers: step.papers,
        initialTopic: '${widget.session.topic}: ${step.title}',
      ),
    );
  }

  Widget _buildQuizTab2(dynamic step) {
    if (step.quiz == null || step.quiz!.isEmpty) {
      return _buildEmptyState(
        icon: Icons.quiz_outlined,
        label: 'No quiz available for this step',
        color: AppColors.rose,
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: KnowledgeCheckQuiz(
        key: ValueKey('quiz_step_${step.index}'),
        quiz: step.quiz,
        stepIndex: widget.stepIndex,
        onNextStep: widget.onNextStep,
        onQuizSubmitted: _onQuizSubmitted,
      ),
    );
  }

  void _handleNextStep(BuildContext context, bool isQuizDone) async {
    if (!isQuizDone) {
      // 1. Switch to the Quiz tab so the user can easily take it
      _tabController.animateTo(2);

      // 2. Show floating warning message with quick action
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.quiz_outlined, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Please complete the Knowledge Check quiz first to move to the next step of learning.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.accentRose,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'Take Quiz',
            textColor: Colors.white,
            onPressed: () {
              _tabController.animateTo(2);
            },
          ),
        ),
      );
      return;
    }

    // Quiz completed: advance to next step
    await widget.onNextStep();
  }

  Widget _buildGatingBar(BuildContext context, bool isQuizDone) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentGreen.withValues(alpha: 0.2),
            AppColors.emerald.withValues(alpha: 0.1),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.accentGreen.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Left indicator and guidance text
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (!isQuizDone) {
                  _handleNextStep(context, isQuizDone);
                }
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      isQuizDone
                          ? Icons.check_circle_rounded
                          : Icons.quiz_rounded,
                      size: 14,
                      color: AppColors.accentGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isQuizDone
                          ? 'Quiz complete! Tap to proceed to next step →'
                          : 'Complete Knowledge Check quiz to unlock next step',
                      style: AppTextStyles.captionBold.copyWith(
                        color: AppColors.accentGreen,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Green Next Step Button
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Tooltip(
              message: isQuizDone
                  ? 'Proceed to next step'
                  : 'Complete Knowledge Check quiz first to advance',
              child: GestureDetector(
                onTap: () => _handleNextStep(context, isQuizDone),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.accentGreen, AppColors.greenDeep],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentGreen.withValues(alpha: 0.35),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Next Step',
                        style: AppTextStyles.badge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoQuizAdvanceBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSolidHeader,
        border: Border(
          top: BorderSide(
            color: AppColors.glassBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.accentCyan.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 14,
              color: AppColors.accentCyan,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Explore resources above, or proceed when ready',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              await widget.onNextStep();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Next Step',
                    style: AppTextStyles.badge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 12, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: color.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

/// Pulsing dot indicator for pending quiz.
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: _animation.value),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color
                    .withValues(alpha: _animation.value * 0.5),
                blurRadius: 6,
              ),
            ],
          ),
        );
      },
    );
  }
}
