import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/providers/active_session_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import 'socratic_tutor_chat.dart';
import 'learning_resources_panel.dart';

/// A dual-panel layout that splits the learning workspace into:
///   • Left Panel (55%): Socratic Tutor Chat
///   • Right Panel (45%): Tabbed Resources (Videos, Papers, Quiz)
///
/// Features:
///   - Draggable divider to resize panels
///   - Maximize/restore button on each panel header
///   - Mobile: collapses to 4-tab layout (Tutor, Videos, Papers, Quiz)
class SplitLearningWorkspace extends ConsumerStatefulWidget {
  final dynamic session;
  final ActiveSessionState activeState;
  final int currentStepIndex;

  const SplitLearningWorkspace({
    super.key,
    required this.session,
    required this.activeState,
    required this.currentStepIndex,
  });

  @override
  ConsumerState<SplitLearningWorkspace> createState() =>
      _SplitLearningWorkspaceState();
}

class _SplitLearningWorkspaceState
    extends ConsumerState<SplitLearningWorkspace> with TickerProviderStateMixin {
  // Panel split ratio (left panel fraction)
  double _splitRatio = 0.55;

  // Which panel is maximized (null = none)
  _MaximizedPanel? _maximizedPanel;

  // Animation controller for maximize transitions
  late AnimationController _maximizeAnim;
  late Animation<double> _maximizeCurve;

  @override
  void initState() {
    super.initState();
    _maximizeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _maximizeCurve = CurvedAnimation(
      parent: _maximizeAnim,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _maximizeAnim.dispose();
    super.dispose();
  }

  void _toggleMaximize(_MaximizedPanel panel) {
    setState(() {
      if (_maximizedPanel == panel) {
        _maximizedPanel = null;
        _maximizeAnim.reverse();
      } else {
        _maximizedPanel = panel;
        _maximizeAnim.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = widget.session.steps[widget.currentStepIndex];
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    if (isMobile) {
      return _MobileTabbedWorkspace(
        session: widget.session,
        activeState: widget.activeState,
        currentStep: currentStep,
        stepIndex: widget.currentStepIndex,
      );
    }

    return _buildDesktopSplitLayout(currentStep);
  }

  Widget _buildDesktopSplitLayout(dynamic currentStep) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final totalHeight = constraints.maxHeight;

        // When maximized, one panel takes full space
        if (_maximizedPanel != null) {
          return AnimatedBuilder(
            animation: _maximizeCurve,
            builder: (context, _) {
              return _maximizedPanel == _MaximizedPanel.left
                  ? _buildPanel(
                      width: totalWidth,
                      height: totalHeight,
                      isLeft: true,
                      currentStep: currentStep,
                      isMaximized: true,
                    )
                  : _buildPanel(
                      width: totalWidth,
                      height: totalHeight,
                      isLeft: false,
                      currentStep: currentStep,
                      isMaximized: true,
                    );
            },
          );
        }

        final leftWidth = totalWidth * _splitRatio;
        final rightWidth = totalWidth - leftWidth - 6; // 6px for divider

        return Row(
          children: [
            _buildPanel(
              width: leftWidth,
              height: totalHeight,
              isLeft: true,
              currentStep: currentStep,
              isMaximized: false,
            ),
            _buildDraggableDivider(totalWidth),
            _buildPanel(
              width: rightWidth,
              height: totalHeight,
              isLeft: false,
              currentStep: currentStep,
              isMaximized: false,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPanel({
    required double width,
    required double height,
    required bool isLeft,
    required dynamic currentStep,
    required bool isMaximized,
  }) {
    final panelType =
        isLeft ? _MaximizedPanel.left : _MaximizedPanel.right;

    return SizedBox(
      width: width,
      height: height,
      child: Column(
        children: [
          // Panel header
          _PanelHeader(
            title: isLeft ? 'Socratic Tutor' : 'Learning Resources',
            icon: isLeft
                ? Icons.psychology_rounded
                : Icons.library_books_rounded,
            accentColor: isLeft ? AppColors.primary : AppColors.accentCyan,
            isMaximized: isMaximized,
            onToggleMaximize: () => _toggleMaximize(panelType),
          ),
          // Panel content
          Expanded(
            child: isLeft
                ? _buildChatPanel(currentStep)
                : _buildResourcesPanel(currentStep),
          ),
        ],
      ),
    );
  }

  Widget _buildChatPanel(dynamic currentStep) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(color: AppColors.glassBorder, width: 0.5),
        ),
      ),
      child: (currentStep.tutorExplanation != null ||
              (currentStep.socraticQuestions != null &&
                  currentStep.socraticQuestions!.isNotEmpty))
          ? SocraticTutorChat(
              key: ValueKey('socratic_step_${currentStep.index}'),
              stepIndex: currentStep.index,
              tutorExplanation: currentStep.tutorExplanation,
              socraticQuestions: currentStep.socraticQuestions,
              conversationHistory: currentStep.conversationHistory,
              stepTitle: currentStep.title,
            )
          : Center(
              child: Text(
                'Socratic Tutor is preparing...',
                style: AppTextStyles.bodyPrimary.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
    );
  }

  Widget _buildResourcesPanel(dynamic currentStep) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(color: AppColors.glassBorder, width: 0.5),
        ),
      ),
      child: LearningResourcesPanel(
        key: ValueKey('resources_step_${currentStep.index}'),
        currentStep: currentStep,
        session: widget.session,
        stepIndex: widget.currentStepIndex,
        onNextStep: () async {
          await ref
              .read(activeSessionProvider.notifier)
              .markStepComplete(currentStep.index);
          ref
              .read(activeSessionProvider.notifier)
              .setActiveStep(currentStep.index + 1);
        },
      ),
    );
  }

  Widget _buildDraggableDivider(double totalWidth) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            _splitRatio += details.delta.dx / totalWidth;
            _splitRatio = _splitRatio.clamp(0.30, 0.70);
          });
        },
        child: Container(
          width: 6,
          decoration: BoxDecoration(
            color: AppColors.glassBorder.withValues(alpha: 0.3),
          ),
          child: Center(
            child: Container(
              width: 3,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _MaximizedPanel { left, right }

/// Premium panel header with title, accent dot, and maximize/restore button.
class _PanelHeader extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final bool isMaximized;
  final VoidCallback onToggleMaximize;

  const _PanelHeader({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.isMaximized,
    required this.onToggleMaximize,
  });

  @override
  State<_PanelHeader> createState() => _PanelHeaderState();
}

class _PanelHeaderState extends State<_PanelHeader> {
  bool _isMaxHovered = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSolidHeader,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: widget.accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              widget.icon,
              size: 14,
              color: widget.accentColor,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            widget.title,
            style: AppTextStyles.subtitle2.copyWith(
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
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
          const Spacer(),
          // Maximize / Restore button
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _isMaxHovered = true),
            onExit: (_) => setState(() => _isMaxHovered = false),
            child: GestureDetector(
              onTap: widget.onToggleMaximize,
              child: Tooltip(
                message: widget.isMaximized ? 'Restore Panel' : 'Maximize Panel',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _isMaxHovered
                        ? AppColors.glassSurface.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _isMaxHovered
                          ? AppColors.glassBorder
                          : Colors.transparent,
                    ),
                  ),
                  child: Icon(
                    widget.isMaximized
                        ? Icons.close_fullscreen_rounded
                        : Icons.open_in_full_rounded,
                    size: 14,
                    color: _isMaxHovered
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mobile layout: 4 tabs — Tutor, Videos, Papers, Quiz.
class _MobileTabbedWorkspace extends ConsumerStatefulWidget {
  final dynamic session;
  final ActiveSessionState activeState;
  final dynamic currentStep;
  final int stepIndex;

  const _MobileTabbedWorkspace({
    required this.session,
    required this.activeState,
    required this.currentStep,
    required this.stepIndex,
  });

  @override
  ConsumerState<_MobileTabbedWorkspace> createState() =>
      _MobileTabbedWorkspaceState();
}

class _MobileTabbedWorkspaceState
    extends ConsumerState<_MobileTabbedWorkspace>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.currentStep;
    final hasVideos = step.videos != null && step.videos!.isNotEmpty;
    final hasPapers = step.papers != null && step.papers!.isNotEmpty;
    final hasQuiz = step.quiz != null && step.quiz!.isNotEmpty;
    final isQuizDone = step.quizScore != null || step.userAnswers != null;

    return Column(
      children: [
        // Tab bar
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceSolidHeader,
            border: Border(
              bottom: BorderSide(color: AppColors.glassBorder, width: 0.5),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: false,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2.5,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textMuted,
            labelStyle: AppTextStyles.captionBold.copyWith(fontSize: 11),
            unselectedLabelStyle: AppTextStyles.caption.copyWith(fontSize: 11),
            tabs: [
              const Tab(
                icon: Icon(Icons.psychology_rounded, size: 18),
                text: 'Tutor',
              ),
              Tab(
                icon: Badge(
                  isLabelVisible: hasVideos,
                  smallSize: 6,
                  backgroundColor: AppColors.accentRose,
                  child: const Icon(Icons.play_circle_outline_rounded, size: 18),
                ),
                text: 'Videos',
              ),
              Tab(
                icon: Badge(
                  isLabelVisible: hasPapers,
                  smallSize: 6,
                  backgroundColor: AppColors.blueLight,
                  child: const Icon(Icons.science_outlined, size: 18),
                ),
                text: 'Papers',
              ),
              Tab(
                icon: hasQuiz
                    ? (isQuizDone
                        ? const Icon(Icons.check_circle_rounded,
                            size: 18, color: AppColors.accentGreen)
                        : Badge(
                            smallSize: 6,
                            backgroundColor: AppColors.accentAmber,
                            child: const Icon(Icons.quiz_outlined, size: 18),
                          ))
                    : const Icon(Icons.quiz_outlined, size: 18),
                text: 'Quiz',
              ),
            ],
          ),
        ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tutor tab
              _buildTutorTab(step),
              // Videos tab
              _buildVideosTab(step),
              // Papers tab
              _buildPapersTab(step),
              // Quiz tab
              _buildQuizTab(step),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTutorTab(dynamic step) {
    if (step.tutorExplanation != null ||
        (step.socraticQuestions != null &&
            step.socraticQuestions!.isNotEmpty)) {
      return SocraticTutorChat(
        key: ValueKey('mobile_socratic_${step.index}'),
        stepIndex: step.index,
        tutorExplanation: step.tutorExplanation,
        socraticQuestions: step.socraticQuestions,
        conversationHistory: step.conversationHistory,
        stepTitle: step.title,
      );
    }
    return Center(
      child: Text(
        'Socratic Tutor is preparing...',
        style: AppTextStyles.bodyPrimary.copyWith(color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildVideosTab(dynamic step) {
    if (step.videos == null || step.videos!.isEmpty) {
      return _buildEmptyState(
        icon: Icons.play_circle_outline_rounded,
        label: 'No videos available for this step',
        color: AppColors.accentRose,
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: LearningResourcesPanel.buildVideosContent(step.videos),
    );
  }

  Widget _buildPapersTab(dynamic step) {
    if (step.papers == null || step.papers!.isEmpty) {
      return _buildEmptyState(
        icon: Icons.science_outlined,
        label: 'No papers available for this step',
        color: AppColors.blueLight,
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: LearningResourcesPanel.buildPapersContent(
        step.papers,
        '${widget.session.topic}: ${step.title}',
      ),
    );
  }

  Widget _buildQuizTab(dynamic step) {
    if (step.quiz == null || step.quiz!.isEmpty) {
      return _buildEmptyState(
        icon: Icons.quiz_outlined,
        label: 'No quiz available for this step',
        color: AppColors.rose,
      );
    }
    return LearningResourcesPanel.buildQuizContent(
      quiz: step.quiz,
      stepIndex: widget.stepIndex,
      onNextStep: () async {
        await ref
            .read(activeSessionProvider.notifier)
            .markStepComplete(step.index);
        ref
            .read(activeSessionProvider.notifier)
            .setActiveStep(step.index + 1);
      },
      onQuizSubmitted: () {},
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
