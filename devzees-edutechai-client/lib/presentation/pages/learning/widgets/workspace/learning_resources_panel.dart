import 'dart:ui';
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

  static Widget buildPapersContent(List<dynamic>? papers, [String? topic]) {
    return AcademicPapers(papers: papers);
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
  int _activeTabIndex = 0;
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
    _tabController.addListener(_onTabControllerChanged);

    // Check if quiz is already completed
    final step = widget.currentStep;
    if (_isQuizCompleted(step)) {
      _quizSubmitted = true;
    }
  }

  void _onTabControllerChanged() {
    if (_activeTabIndex != _tabController.index) {
      setState(() {
        _activeTabIndex = _tabController.index;
      });
    }
  }

  void _onSelectTab(int index) {
    _tabController.animateTo(index);
    setState(() {
      _activeTabIndex = index;
    });
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
      setState(() {
        _activeTabIndex = 0;
      });
    } else if (!_quizSubmitted && _isQuizCompleted(widget.currentStep)) {
      _quizSubmitted = true;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabControllerChanged);
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
        // Premium Segmented Tab Bar Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceSolidHeader.withValues(alpha: 0.65),
            border: Border(
              bottom: BorderSide(color: AppColors.glassBorder, width: 0.8),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.glassBorderSubtle,
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                _ResourceTabItem(
                  index: 0,
                  isActive: _activeTabIndex == 0,
                  label: 'Videos',
                  icon: Icons.play_circle_outline_rounded,
                  accentColor: AppColors.accentRose,
                  badgeCount: hasVideos ? step.videos!.length : 0,
                  badgeColor: AppColors.accentRose,
                  onTap: () => _onSelectTab(0),
                ),
                const SizedBox(width: 4),
                _ResourceTabItem(
                  index: 1,
                  isActive: _activeTabIndex == 1,
                  label: 'Papers',
                  icon: Icons.science_outlined,
                  accentColor: AppColors.blueLight,
                  badgeCount: hasPapers ? step.papers!.length : 0,
                  badgeColor: AppColors.accentBlue,
                  onTap: () => _onSelectTab(1),
                ),
                const SizedBox(width: 4),
                _ResourceTabItem(
                  index: 2,
                  isActive: _activeTabIndex == 2,
                  label: 'Quiz',
                  icon: Icons.quiz_outlined,
                  accentColor: isQuizDone ? AppColors.accentGreen : AppColors.accentAmber,
                  leadingWidget: hasQuiz && isQuizDone
                      ? Container(
                          width: 17,
                          height: 17,
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentGreen.withValues(alpha: 0.4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 11,
                            color: Colors.white,
                          ),
                        )
                      : (hasQuiz && !isQuizDone
                          ? _PulsingDot(color: AppColors.accentGreen)
                          : null),
                  onTap: () => _onSelectTab(2),
                ),
              ],
            ),
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
      _showQuizRequiredModal(context);
      return;
    }

    // Quiz completed: advance to next step
    await widget.onNextStep();
  }

  void _showQuizRequiredModal(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.surfaceDark.withValues(alpha: 0.96),
                        AppColors.surfaceDeep.withValues(alpha: 0.94),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.55),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Themed Icon badge + Close Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.25),
                                  AppColors.accentRose.withValues(alpha: 0.15),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.4),
                              ),
                            ),
                            child: const Icon(
                              Icons.quiz_rounded,
                              size: 22,
                              color: AppColors.purpleLight,
                            ),
                          ),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => Navigator.of(dialogContext).pop(),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.06),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.glassBorder),
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Title
                      Text(
                        'Knowledge Check Required',
                        style: AppTextStyles.h4.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Text(
                        'Please complete the Knowledge Check quiz first to move to the next step of learning. Testing your knowledge ensures you have mastered these concepts.',
                        style: AppTextStyles.body2.copyWith(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Hint / Info Box
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline_rounded,
                              size: 16,
                              color: AppColors.accentAmber,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Interactive questions are waiting in the Quiz tab.',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.lavender,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textMuted,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: AppTextStyles.button.copyWith(
                                fontSize: 12.5,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(dialogContext).pop();
                                _onSelectTab(2);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(9),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.play_arrow_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Take Quiz',
                                      style: AppTextStyles.badge.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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

/// Interactive segmented tab item with premium tactile hover and active glows.
class _ResourceTabItem extends StatefulWidget {
  final int index;
  final bool isActive;
  final String label;
  final IconData icon;
  final Color accentColor;
  final Widget? leadingWidget;
  final int badgeCount;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _ResourceTabItem({
    required this.index,
    required this.isActive,
    required this.label,
    required this.icon,
    required this.accentColor,
    this.leadingWidget,
    this.badgeCount = 0,
    this.badgeColor,
    required this.onTap,
  });

  @override
  State<_ResourceTabItem> createState() => _ResourceTabItemState();
}

class _ResourceTabItemState extends State<_ResourceTabItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isActive;
    final isHovered = _isHovered;

    final Color textColor = isActive
        ? AppColors.textPrimary
        : (isHovered ? AppColors.textSlate : AppColors.textMuted);

    final Color iconColor = isActive
        ? widget.accentColor
        : (isHovered ? widget.accentColor.withValues(alpha: 0.9) : AppColors.textMuted);

    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: isActive
                  ? LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: isHovered ? 0.28 : 0.22),
                        AppColors.purpleDeep.withValues(alpha: isHovered ? 0.20 : 0.14),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isActive
                  ? null
                  : (isHovered ? AppColors.primary.withValues(alpha: 0.09) : Colors.transparent),
              border: Border.all(
                color: isActive
                    ? AppColors.primary.withValues(alpha: isHovered ? 0.70 : 0.50)
                    : (isHovered ? AppColors.primary.withValues(alpha: 0.28) : Colors.transparent),
                width: 1,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: isHovered ? 0.28 : 0.18),
                        blurRadius: isHovered ? 12 : 8,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : (isHovered
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            blurRadius: 8,
                          ),
                        ]
                      : null),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.leadingWidget != null)
                  widget.leadingWidget!
                else
                  Icon(widget.icon, size: 16, color: iconColor),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    widget.label,
                    style: AppTextStyles.captionBold.copyWith(
                      fontSize: 12,
                      color: textColor,
                      fontWeight: isActive
                          ? FontWeight.w700
                          : (isHovered ? FontWeight.w600 : FontWeight.w500),
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.badgeCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    width: widget.badgeCount > 9 ? null : 18,
                    height: 18,
                    padding: widget.badgeCount > 9
                        ? const EdgeInsets.symmetric(horizontal: 5)
                        : EdgeInsets.zero,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: widget.badgeColor ?? AppColors.primary,
                      shape: widget.badgeCount > 9 ? BoxShape.rectangle : BoxShape.circle,
                      borderRadius: widget.badgeCount > 9
                          ? BorderRadius.circular(9)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: (widget.badgeColor ?? AppColors.primary).withValues(alpha: 0.35),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${widget.badgeCount}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
