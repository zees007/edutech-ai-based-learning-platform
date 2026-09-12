import 'dart:ui';
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
///   - Draggable divider to resize panels (thin 1px themed line)
///   - Maximize/restore button → expands panel to true fullscreen overlay
///   - Mobile: collapses to 4-tab layout (Tutor, Videos, Papers, Quiz)
///   - Left panel header includes step nav, status, prerequisite info
class SplitLearningWorkspace extends ConsumerStatefulWidget {
  final dynamic session;
  final ActiveSessionState activeState;
  final int currentStepIndex;
  final int totalSteps;
  final int maxUnlockedIndex;
  final bool isQuizGated;
  final ValueChanged<int> onStepChange;

  const SplitLearningWorkspace({
    super.key,
    required this.session,
    required this.activeState,
    required this.currentStepIndex,
    required this.totalSteps,
    required this.maxUnlockedIndex,
    required this.isQuizGated,
    required this.onStepChange,
  });

  @override
  ConsumerState<SplitLearningWorkspace> createState() =>
      _SplitLearningWorkspaceState();
}

class _SplitLearningWorkspaceState
    extends ConsumerState<SplitLearningWorkspace> {
  // Panel split ratio (left panel fraction)
  double _splitRatio = 0.55;

  // Fullscreen overlay
  OverlayEntry? _fullscreenOverlay;
  _MaximizedPanel? _fullscreenPanel;

  @override
  void dispose() {
    _removeFullscreenOverlay();
    super.dispose();
  }

  void _removeFullscreenOverlay() {
    _fullscreenOverlay?.remove();
    _fullscreenOverlay = null;
    _fullscreenPanel = null;
  }

  void _toggleFullscreen(_MaximizedPanel panel) {
    if (_fullscreenPanel == panel) {
      // Restore
      _removeFullscreenOverlay();
      setState(() {});
      return;
    }

    _removeFullscreenOverlay();

    final currentStep = widget.session.steps[widget.currentStepIndex];

    _fullscreenPanel = panel;
    _fullscreenOverlay = OverlayEntry(
      builder: (context) => _FullscreenPanelOverlay(
        panel: panel,
        currentStep: currentStep,
        session: widget.session,
        stepIndex: widget.currentStepIndex,
        totalSteps: widget.totalSteps,
        maxUnlockedIndex: widget.maxUnlockedIndex,
        isQuizGated: widget.isQuizGated,
        onStepChange: widget.onStepChange,
        onClose: () {
          _removeFullscreenOverlay();
          setState(() {});
        },
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

    Overlay.of(context).insert(_fullscreenOverlay!);
    setState(() {});
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
        totalSteps: widget.totalSteps,
        maxUnlockedIndex: widget.maxUnlockedIndex,
        onStepChange: widget.onStepChange,
      );
    }

    return _buildDesktopSplitLayout(currentStep);
  }

  Widget _buildDesktopSplitLayout(dynamic currentStep) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final totalHeight = constraints.maxHeight;

        const dividerWidth = 9.0;
        final availableWidth = totalWidth - dividerWidth;
        final leftWidth = (availableWidth * _splitRatio).clamp(250.0, availableWidth - 250.0);
        final rightWidth = availableWidth - leftWidth;

        return Row(
          children: [
            _buildPanel(
              width: leftWidth,
              height: totalHeight,
              isLeft: true,
              currentStep: currentStep,
            ),
            _buildDraggableDivider(totalWidth),
            _buildPanel(
              width: rightWidth,
              height: totalHeight,
              isLeft: false,
              currentStep: currentStep,
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleNextStep(dynamic currentStep) async {
    await ref
        .read(activeSessionProvider.notifier)
        .markStepComplete(currentStep.index);
    ref
        .read(activeSessionProvider.notifier)
        .setActiveStep(currentStep.index + 1);
  }

  Widget _buildPanel({
    required double width,
    required double height,
    required bool isLeft,
    required dynamic currentStep,
  }) {
    final panelType =
        isLeft ? _MaximizedPanel.left : _MaximizedPanel.right;

    return SizedBox(
      width: width,
      height: height,
      child: Column(
        children: [
          // Panel header
          isLeft
              ? _TutorPanelHeader(
                  currentIndex: widget.currentStepIndex,
                  totalSteps: widget.totalSteps,
                  maxUnlockedIndex: widget.maxUnlockedIndex,
                  isPrerequisite: currentStep.isPrerequisite,
                  prerequisiteNote: currentStep.prerequisite,
                  status: currentStep.status,
                  isQuizGated: widget.isQuizGated,
                  onStepChange: widget.onStepChange,
                  onNextStep: () => _handleNextStep(currentStep),
                  onToggleFullscreen: () => _toggleFullscreen(panelType),
                )
              : _ResourcesPanelHeader(
                  onToggleFullscreen: () => _toggleFullscreen(panelType),
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
        // Invisible hit area wider than visual line for easy dragging
        child: Container(
          width: 9,
          color: Colors.transparent,
          child: Center(
            child: Container(
              width: 1,
              color: AppColors.glassBorder,
            ),
          ),
        ),
      ),
    );
  }
}

enum _MaximizedPanel { left, right }

// ═══════════════════════════════════════════════════════════════════
// Fullscreen Overlay — occupies the entire screen
// ═══════════════════════════════════════════════════════════════════

class _FullscreenPanelOverlay extends ConsumerWidget {
  final _MaximizedPanel panel;
  final dynamic currentStep;
  final dynamic session;
  final int stepIndex;
  final int totalSteps;
  final int maxUnlockedIndex;
  final bool isQuizGated;
  final ValueChanged<int> onStepChange;
  final VoidCallback onClose;
  final Future<void> Function() onNextStep;

  const _FullscreenPanelOverlay({
    required this.panel,
    required this.currentStep,
    required this.session,
    required this.stepIndex,
    required this.totalSteps,
    required this.maxUnlockedIndex,
    required this.isQuizGated,
    required this.onStepChange,
    required this.onClose,
    required this.onNextStep,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: AppColors.background,
      child: Column(
        children: [
          // Header
          panel == _MaximizedPanel.left
              ? _TutorPanelHeader(
                  currentIndex: stepIndex,
                  totalSteps: totalSteps,
                  maxUnlockedIndex: maxUnlockedIndex,
                  isPrerequisite: currentStep.isPrerequisite,
                  prerequisiteNote: currentStep.prerequisite,
                  status: currentStep.status,
                  isQuizGated: isQuizGated,
                  onStepChange: onStepChange,
                  onNextStep: onNextStep,
                  isFullscreen: true,
                  onToggleFullscreen: onClose,
                )
              : _ResourcesPanelHeader(
                  isFullscreen: true,
                  onToggleFullscreen: onClose,
                ),
          // Content
          Expanded(
            child: panel == _MaximizedPanel.left
                ? _buildFullscreenChat()
                : _buildFullscreenResources(ref),
          ),
        ],
      ),
    );
  }

  Widget _buildFullscreenChat() {
    return (currentStep.tutorExplanation != null ||
            (currentStep.socraticQuestions != null &&
                currentStep.socraticQuestions!.isNotEmpty))
        ? SocraticTutorChat(
            key: ValueKey('fullscreen_socratic_${currentStep.index}'),
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
          );
  }

  Widget _buildFullscreenResources(WidgetRef ref) {
    return LearningResourcesPanel(
      key: ValueKey('fullscreen_resources_${currentStep.index}'),
      currentStep: currentStep,
      session: session,
      stepIndex: stepIndex,
      onNextStep: onNextStep,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Tutor Panel Header — Socratic Tutor • Online + Step Nav + Status
// ═══════════════════════════════════════════════════════════════════

class _TutorPanelHeader extends StatefulWidget {
  final int currentIndex;
  final int totalSteps;
  final int maxUnlockedIndex;
  final bool isPrerequisite;
  final String? prerequisiteNote;
  final String status;
  final bool isQuizGated;
  final ValueChanged<int> onStepChange;
  final Future<void> Function()? onNextStep;
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;

  const _TutorPanelHeader({
    required this.currentIndex,
    required this.totalSteps,
    required this.maxUnlockedIndex,
    this.isPrerequisite = false,
    this.prerequisiteNote,
    this.status = 'pending',
    required this.isQuizGated,
    required this.onStepChange,
    this.onNextStep,
    this.isFullscreen = false,
    required this.onToggleFullscreen,
  });

  @override
  State<_TutorPanelHeader> createState() => _TutorPanelHeaderState();
}

class _TutorPanelHeaderState extends State<_TutorPanelHeader> {
  bool _isMaxHovered = false;

  @override
  Widget build(BuildContext context) {
    final isReviewing = widget.currentIndex < widget.maxUnlockedIndex;
    final canGoBack = widget.currentIndex > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surfaceSolidHeader,
      ),
      child: Row(
        children: [
          // ─── Tutor icon + "Socratic Tutor" + Online dot ───
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.25),
                  AppColors.accentCyan.withValues(alpha: 0.25),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.accentCyan.withValues(alpha: 0.45),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentCyan.withValues(alpha: 0.25),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              size: 14,
              color: AppColors.accentCyan,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Socratic Tutor',
            style: AppTextStyles.subtitle2.copyWith(fontSize: 13),
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
          const SizedBox(width: 4),
          Text(
            'Online',
            style: AppTextStyles.captionBold.copyWith(
              color: AppColors.accentGreen,
              fontSize: 10,
            ),
          ),
          const SizedBox(width: 12),

          // ─── Step Nav: Prev + Step pill + Status + Prerequisite + Next ───
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Previous Step
                  if (canGoBack) ...[
                    _StepNavButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      label: 'Prev',
                      tooltip: 'Go back to previous step (${widget.currentIndex})',
                      onTap: () => widget.onStepChange(widget.currentIndex - 1),
                      useGradient: true,
                    ),
                    const SizedBox(width: 6),
                  ],
                  // Step pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isReviewing
                          ? AppColors.cyanLight.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
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
                          'Step ${widget.currentIndex + 1}/${widget.totalSteps}',
                          style: AppTextStyles.badge.copyWith(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isReviewing ? AppColors.cyanLight : AppColors.purpleLight,
                          ),
                        ),
                        if (isReviewing) ...[
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.cyanLight.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              'Review',
                              style: AppTextStyles.badge.copyWith(fontSize: 8, color: Colors.white),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Prerequisite badge
                  if (widget.isPrerequisite) ...[
                    const SizedBox(width: 6),
                    Tooltip(
                      message: widget.prerequisiteNote != null &&
                              widget.prerequisiteNote!.trim().isNotEmpty
                          ? 'Prerequisite: ${widget.prerequisiteNote}'
                          : 'Foundational prerequisite step',
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: AppColors.amberGradient,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.school_rounded, size: 10, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'Prereq',
                              style: AppTextStyles.badge.copyWith(
                                fontSize: 9.5,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  // Next Step button (only displayed when reviewing previous completed steps; hidden when in process step)
                  if (isReviewing &&
                      widget.status.toLowerCase() != 'in_progress' &&
                      widget.currentIndex < widget.maxUnlockedIndex) ...[
                    const SizedBox(width: 6),
                    _StepNavButton(
                      icon: Icons.arrow_forward_ios_rounded,
                      label: 'Next',
                      tooltip: 'Go to Step ${widget.currentIndex + 2}',
                      onTap: () => widget.onStepChange(widget.currentIndex + 1),
                      iconAfterLabel: true,
                      useGradient: true,
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),
          // ─── Maximize / Restore button ───
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _isMaxHovered = true),
            onExit: (_) => setState(() => _isMaxHovered = false),
            child: GestureDetector(
              onTap: widget.onToggleFullscreen,
              child: Tooltip(
                message: widget.isFullscreen ? 'Exit Fullscreen' : 'Fullscreen',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(5),
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
                    widget.isFullscreen
                        ? Icons.close_fullscreen_rounded
                        : Icons.open_in_full_rounded,
                    size: 13,
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

// ═══════════════════════════════════════════════════════════════════
// Resources Panel Header — Minimal: icon + title + fullscreen
// ═══════════════════════════════════════════════════════════════════

class _ResourcesPanelHeader extends StatefulWidget {
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;

  const _ResourcesPanelHeader({
    this.isFullscreen = false,
    required this.onToggleFullscreen,
  });

  @override
  State<_ResourcesPanelHeader> createState() => _ResourcesPanelHeaderState();
}

class _ResourcesPanelHeaderState extends State<_ResourcesPanelHeader> {
  bool _isMaxHovered = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surfaceSolidHeader,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.accentCyan.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.library_books_rounded,
              size: 14,
              color: AppColors.accentCyan,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Learning Resources',
            style: AppTextStyles.subtitle2.copyWith(fontSize: 13),
          ),
          const Spacer(),
          // Maximize / Restore button
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _isMaxHovered = true),
            onExit: (_) => setState(() => _isMaxHovered = false),
            child: GestureDetector(
              onTap: widget.onToggleFullscreen,
              child: Tooltip(
                message: widget.isFullscreen ? 'Exit Fullscreen' : 'Fullscreen',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(5),
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
                    widget.isFullscreen
                        ? Icons.close_fullscreen_rounded
                        : Icons.open_in_full_rounded,
                    size: 13,
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

// ═══════════════════════════════════════════════════════════════════
// Compact Step Nav Button — Prev / Next in the header
// ═══════════════════════════════════════════════════════════════════

class _StepNavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback? onTap;
  final bool iconAfterLabel;
  final bool useGradient;

  const _StepNavButton({
    required this.icon,
    required this.label,
    required this.tooltip,
    this.onTap,
    this.iconAfterLabel = false,
    this.useGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            gradient: useGradient ? AppColors.royalBlueIndigoGradient : null,
            color: useGradient
                ? null
                : AppColors.glassSurface.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: useGradient
                  ? AppColors.purpleLight.withValues(alpha: 0.4)
                  : AppColors.glassBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!iconAfterLabel) ...[
                Icon(icon, size: 10, color: Colors.white),
                const SizedBox(width: 3),
              ],
              Text(
                label,
                style: AppTextStyles.badge.copyWith(
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
              if (iconAfterLabel) ...[
                const SizedBox(width: 3),
                Icon(icon, size: 10, color: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════
// Mobile layout: 4 tabs — Tutor, Videos, Papers, Quiz
// ═══════════════════════════════════════════════════════════════════

class _MobileTabbedWorkspace extends ConsumerStatefulWidget {
  final dynamic session;
  final ActiveSessionState activeState;
  final dynamic currentStep;
  final int stepIndex;
  final int totalSteps;
  final int maxUnlockedIndex;
  final ValueChanged<int> onStepChange;

  const _MobileTabbedWorkspace({
    required this.session,
    required this.activeState,
    required this.currentStep,
    required this.stepIndex,
    required this.totalSteps,
    required this.maxUnlockedIndex,
    required this.onStepChange,
  });

  @override
  ConsumerState<_MobileTabbedWorkspace> createState() =>
      _MobileTabbedWorkspaceState();
}

class _MobileTabbedWorkspaceState
    extends ConsumerState<_MobileTabbedWorkspace>
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
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabControllerChanged);
    if (_isQuizCompleted(widget.currentStep)) {
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
  void didUpdateWidget(covariant _MobileTabbedWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stepIndex != widget.stepIndex) {
      _quizSubmitted = false;
      if (_isQuizCompleted(widget.currentStep)) {
        _quizSubmitted = true;
      }
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

  Future<void> _handleNextStep(BuildContext context, bool isQuizDone) async {
    if (!isQuizDone) {
      _showQuizRequiredModal(context);
      return;
    }

    await ref
        .read(activeSessionProvider.notifier)
        .markStepComplete(widget.currentStep.index);
    ref
        .read(activeSessionProvider.notifier)
        .setActiveStep(widget.currentStep.index + 1);
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
                                _onSelectTab(3); // Tab 3 is Quiz on mobile
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

  Widget _buildMobileStepHeader() {
    final step = widget.currentStep;
    final canGoBack = widget.stepIndex > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSolidHeader,
        border: Border(
          bottom: BorderSide(
            color: AppColors.glassBorder,
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        children: [
          if (canGoBack) ...[
            GestureDetector(
              onTap: () => widget.onStepChange(widget.stepIndex - 1),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.glassBase,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              'Step ${widget.stepIndex + 1}/${widget.totalSteps}',
              style: AppTextStyles.badge.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppColors.purpleLight,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              step.title?.toString() ?? 'Learning Step',
              style: AppTextStyles.subtitle2.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileGatingBar(BuildContext context, bool isQuizDone) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentGreen.withValues(alpha: 0.20),
            AppColors.emerald.withValues(alpha: 0.10),
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
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _handleNextStep(context, isQuizDone),
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isQuizDone
                            ? 'Quiz complete! Tap to advance →'
                            : 'Complete quiz to unlock next step',
                        style: AppTextStyles.captionBold.copyWith(
                          color: AppColors.accentGreen,
                          fontSize: 11.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _handleNextStep(context, isQuizDone),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
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
          ],
        ),
      ),
    );
  }

  Widget _buildMobileNoQuizAdvanceBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSolidHeader,
        border: Border(
          top: BorderSide(
            color: AppColors.glassBorder,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
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
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ready to continue learning',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _handleNextStep(context, true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
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
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.currentStep;
    final hasVideos = step.videos != null && step.videos!.isNotEmpty;
    final hasPapers = step.papers != null && step.papers!.isNotEmpty;
    final hasQuiz = step.quiz != null && step.quiz!.isNotEmpty;
    final isQuizDone = _quizSubmitted || _isQuizCompleted(step);
    final isLastStep = widget.stepIndex >= (widget.totalSteps - 1);

    return Column(
      children: [
        // Mobile Step Orientation Header
        _buildMobileStepHeader(),

        // Premium Segmented Tab Bar Header (Mobile)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                _MobileWorkspaceTabItem(
                  index: 0,
                  isActive: _activeTabIndex == 0,
                  label: 'Tutor',
                  icon: Icons.smart_toy_rounded,
                  accentColor: AppColors.primary,
                  onTap: () => _onSelectTab(0),
                ),
                const SizedBox(width: 3),
                _MobileWorkspaceTabItem(
                  index: 1,
                  isActive: _activeTabIndex == 1,
                  label: 'Videos',
                  icon: Icons.play_circle_outline_rounded,
                  accentColor: AppColors.accentRose,
                  hasBadge: hasVideos,
                  badgeColor: AppColors.accentRose,
                  onTap: () => _onSelectTab(1),
                ),
                const SizedBox(width: 3),
                _MobileWorkspaceTabItem(
                  index: 2,
                  isActive: _activeTabIndex == 2,
                  label: 'Papers',
                  icon: Icons.science_outlined,
                  accentColor: AppColors.blueLight,
                  hasBadge: hasPapers,
                  badgeColor: AppColors.blueLight,
                  onTap: () => _onSelectTab(2),
                ),
                const SizedBox(width: 3),
                _MobileWorkspaceTabItem(
                  index: 3,
                  isActive: _activeTabIndex == 3,
                  label: 'Quiz',
                  icon: Icons.quiz_outlined,
                  accentColor: isQuizDone ? AppColors.accentGreen : AppColors.accentAmber,
                  leadingWidget: hasQuiz
                      ? (isQuizDone
                          ? Container(
                              width: 15,
                              height: 15,
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
                                size: 10,
                                color: Colors.white,
                              ),
                            )
                          : Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.accentAmber,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accentAmber.withValues(alpha: 0.5),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ))
                      : null,
                  onTap: () => _onSelectTab(3),
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

        // Pinned Bottom Advance / Gating Bar
        if (hasQuiz)
          _buildMobileGatingBar(context, isQuizDone)
        else if (!isLastStep)
          _buildMobileNoQuizAdvanceBar(context),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: LearningResourcesPanel.buildPapersContent(
        step.papers,
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
      onNextStep: () => _handleNextStep(context, true),
      onQuizSubmitted: () {
        setState(() {
          _quizSubmitted = true;
        });
      },
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

/// Interactive segmented tab item for mobile workspace tabs.
class _MobileWorkspaceTabItem extends StatefulWidget {
  final int index;
  final bool isActive;
  final String label;
  final IconData icon;
  final Color accentColor;
  final bool hasBadge;
  final Color? badgeColor;
  final Widget? leadingWidget;
  final VoidCallback onTap;

  const _MobileWorkspaceTabItem({
    required this.index,
    required this.isActive,
    required this.label,
    required this.icon,
    required this.accentColor,
    this.hasBadge = false,
    this.badgeColor,
    this.leadingWidget,
    required this.onTap,
  });

  @override
  State<_MobileWorkspaceTabItem> createState() =>
      _MobileWorkspaceTabItemState();
}

class _MobileWorkspaceTabItemState extends State<_MobileWorkspaceTabItem> {
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
        : (isHovered
            ? widget.accentColor.withValues(alpha: 0.85)
            : AppColors.textMuted);

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
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: isActive
                  ? LinearGradient(
                      colors: [
                        AppColors.primary
                            .withValues(alpha: isHovered ? 0.28 : 0.22),
                        AppColors.purpleDeep
                            .withValues(alpha: isHovered ? 0.20 : 0.14),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isActive
                  ? null
                  : (isHovered
                      ? AppColors.primary.withValues(alpha: 0.09)
                      : Colors.transparent),
              border: Border.all(
                color: isActive
                    ? AppColors.primary
                        .withValues(alpha: isHovered ? 0.70 : 0.50)
                    : (isHovered
                        ? AppColors.primary.withValues(alpha: 0.28)
                        : Colors.transparent),
                width: 1,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary
                            .withValues(alpha: isHovered ? 0.28 : 0.18),
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
              children: [
                if (widget.leadingWidget != null)
                  widget.leadingWidget!
                else
                  Icon(widget.icon, size: 16, color: iconColor),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    widget.label,
                    style: AppTextStyles.captionBold.copyWith(
                      fontSize: 11.5,
                      color: textColor,
                      fontWeight: isActive
                          ? FontWeight.w700
                          : (isHovered ? FontWeight.w600 : FontWeight.w500),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.hasBadge) ...[
                  const SizedBox(width: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: widget.badgeColor ?? AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (widget.badgeColor ?? AppColors.primary)
                              .withValues(alpha: 0.5),
                          blurRadius: 3,
                        ),
                      ],
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
