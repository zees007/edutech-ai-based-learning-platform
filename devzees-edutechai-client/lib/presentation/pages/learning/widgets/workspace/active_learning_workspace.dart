import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/providers/active_session_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import 'socratic_tutor_chat.dart';
import 'recommended_videos.dart';
import 'academic_papers.dart';
import 'knowledge_check_quiz.dart';
import 'unified_learning_command_hub.dart';

class ActiveLearningWorkspace extends ConsumerWidget {
  const ActiveLearningWorkspace({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeState = ref.watch(activeSessionProvider);
    final session = activeState.session;

    if (session == null) {
      return const SizedBox.shrink();
    }

    final int totalSteps = session.steps.isNotEmpty ? session.steps.length : 1;
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
      // Main Content Area for Active Step
      body: _StepContentContainer(
        activeState: activeState,
        session: session,
        buildStepContent: (step) => _buildStepContent(step, ref),
      ),
    );
  }

  Widget _buildStepContent(dynamic step, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (step.tutorExplanation != null || (step.socraticQuestions != null && step.socraticQuestions!.isNotEmpty)) ...[
          SocraticTutorChat(
            key: ValueKey('socratic_step_${step.index}'),
            stepIndex: step.index,
            tutorExplanation: step.tutorExplanation,
            socraticQuestions: step.socraticQuestions,
            conversationHistory: step.conversationHistory,
            stepTitle: step.title,
          ),
          const SizedBox(height: 32),
        ],
        if (step.quiz != null && step.quiz!.isNotEmpty) ...[
          KnowledgeCheckQuiz(
            key: ValueKey('quiz_step_${step.index}'),
            quiz: step.quiz,
            stepIndex: step.index,
            onNextStep: () async {
              await ref.read(activeSessionProvider.notifier).markStepComplete(step.index);
              ref.read(activeSessionProvider.notifier).setActiveStep(step.index + 1);
            },
          ),
          const SizedBox(height: 32),
        ],
      ],
    );
  }
}

class _StepContentContainer extends ConsumerStatefulWidget {
  final ActiveSessionState activeState;
  final dynamic session;
  final Widget Function(dynamic) buildStepContent;

  const _StepContentContainer({
    required this.activeState,
    required this.session,
    required this.buildStepContent,
  });

  @override
  ConsumerState<_StepContentContainer> createState() => _StepContentContainerState();
}

class _StepContentContainerState extends ConsumerState<_StepContentContainer> {
  Widget? _activeOverlay;
  final ScrollController _contentScrollController = ScrollController();

  @override
  void dispose() {
    _contentScrollController.dispose();
    super.dispose();
  }

  void _showOverlay(Widget child) {
    setState(() {
      _activeOverlay = child;
    });
  }

  void _closeOverlay() {
    setState(() {
      _activeOverlay = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.activeState.activeStepIndex;
    final totalSteps = widget.session.steps.length;
    final maxUnlockedIndex = (widget.session.currentStepIndex > widget.session.stepsCompleted
            ? widget.session.currentStepIndex
            : widget.session.stepsCompleted)
        .clamp(0, totalSteps > 0 ? totalSteps - 1 : 0);

    final currentStep = widget.session.steps[currentIndex];
    final hasVideos = currentStep.videos != null && currentStep.videos!.isNotEmpty;
    final hasPapers = currentStep.papers != null && currentStep.papers!.isNotEmpty;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xB31E293B), // rgba(30, 41, 59, 0.7)
            Color(0xCC0F172A), // rgba(15, 23, 42, 0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x59000000), // rgba(0, 0, 0, 0.35)
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Color(0x14A855F7), // rgba(168, 85, 247, 0.08) inset
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
                  decoration: const BoxDecoration(
                    color: Color(0xCC140D21), // rgba(20, 13, 33, 0.8)
                  ),
                  child: Row(
                    children: [
                      // Left label & Step Navigation
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(14, 17, 23, 1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('🧩', style: TextStyle(fontSize: 14)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Socratic Tutor',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFAFAFA),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.6),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Online',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF10B981),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          _buildStepToolbarNav(
                            currentIndex: currentIndex,
                            maxUnlockedIndex: maxUnlockedIndex,
                            totalSteps: totalSteps,
                            isPrerequisite: currentStep.isPrerequisite,
                            prerequisiteNote: currentStep.prerequisite,
                            status: currentStep.status,
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Action Buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasVideos)
                            _PremiumActionButton(
                              icon: Icons.play_circle_outline_rounded,
                              label: 'Videos',
                              accentColor: const Color(0xFFFF6B6B),
                              secondaryColor: const Color(0xFFFFAB76),
                              isActive: _activeOverlay is RecommendedVideos,
                              onTap: () {
                                if (_activeOverlay is RecommendedVideos) {
                                  _closeOverlay();
                                } else {
                                  _showOverlay(RecommendedVideos(videos: currentStep.videos));
                                }
                              },
                            ),
                          if (hasVideos && hasPapers) const SizedBox(width: 10),
                          if (hasPapers)
                            _PremiumActionButton(
                              icon: Icons.science_outlined,
                              label: 'Papers',
                              accentColor: const Color(0xFF60A5FA),
                              secondaryColor: const Color(0xFF818CF8),
                              isActive: _activeOverlay is AcademicPapers,
                              onTap: () {
                                if (_activeOverlay is AcademicPapers) {
                                  _closeOverlay();
                                } else {
                                  _showOverlay(
                                    AcademicPapers(
                                      papers: currentStep.papers,
                                      initialTopic: '${widget.session.topic}: ${currentStep.title}',
                                    ),
                                  );
                                }
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ─── Scrollable Content (Overlay + Step Content + Bottom Nav) ───
                Expanded(
                  child: ScrollbarTheme(
                    data: ScrollbarThemeData(
                      thumbColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.dragged)) {
                          return const Color(0xFF64748B); // Slate-500
                        }
                        if (states.contains(WidgetState.hovered)) {
                          return const Color(0xFF475569).withValues(alpha: 0.9); // Slate-600
                        }
                        return const Color(0xFF334155).withValues(alpha: 0.65); // Slate-700, matches #1E293B / #0F172A card bg
                      }),
                      trackColor: WidgetStateProperty.all(Colors.transparent),
                      trackBorderColor: WidgetStateProperty.all(Colors.transparent),
                      radius: const Radius.circular(8),
                      thickness: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.hovered) || states.contains(WidgetState.dragged)) {
                          return 6.0;
                        }
                        return 4.0;
                      }),
                      crossAxisMargin: 2.0,
                      mainAxisMargin: 4.0,
                    ),
                    child: Scrollbar(
                      controller: _contentScrollController,
                      child: SingleChildScrollView(
                        controller: _contentScrollController,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ─── Expandable Overlay Panel ───
                            AnimatedSize(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutQuart,
                              alignment: Alignment.topCenter,
                              child: _activeOverlay != null
                                ? Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 24),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF0F172A).withValues(alpha: 0.95),
                                          const Color(0xFF1A112E).withValues(alpha: 0.9),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.08),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.25),
                                          blurRadius: 24,
                                          spreadRadius: -8,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: _activeOverlay!,
                                    ),
                                  )
                                : const SizedBox(height: 0),
                            ),

                            // ─── Main Step Content ───
                            widget.buildStepContent(widget.session.steps[currentIndex]),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: Text(
                'No steps available.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
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
  }) {
    final canGoBack = currentIndex > 0;
    final canGoForward = currentIndex < maxUnlockedIndex;
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
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_back_ios_new_rounded, size: 11, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'Prev',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
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
                ? const Color(0xFF06B6D4).withValues(alpha: 0.15)
                : AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isReviewing
                  ? const Color(0xFF06B6D4).withValues(alpha: 0.45)
                  : AppColors.primary.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Step ${currentIndex + 1} of $totalSteps',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: isReviewing ? const Color(0xFF22D3EE) : const Color(0xFFC084FC),
                ),
              ),
              if (isReviewing) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Review Mode',
                    style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white),
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
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
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
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (canGoForward) const SizedBox(width: 8),
        // Next Step quick button
        if (canGoForward)
          Tooltip(
            message: 'Go forward to Step ${currentIndex + 2}',
            child: InkWell(
              onTap: () {
                ref.read(activeSessionProvider.notifier).setActiveStep(currentIndex + 1);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0x33A855F7), Color(0x333B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Next',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Premium pill-shaped action button with gradient border, icon + label,
/// neon glow, and active-state indicator.
class _PremiumActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final Color secondaryColor;
  final bool isActive;
  final VoidCallback onTap;

  const _PremiumActionButton({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.secondaryColor,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_PremiumActionButton> createState() => _PremiumActionButtonState();
}

class _PremiumActionButtonState extends State<_PremiumActionButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showGlow = _isHovered || widget.isActive;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            final double glowSpread = widget.isActive
                ? 0.6 + (_pulseAnimation.value * 0.25)
                : (_isHovered ? 0.35 : 0.0);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.isActive
                      ? [
                          widget.accentColor.withValues(alpha: 0.2),
                          widget.secondaryColor.withValues(alpha: 0.12),
                        ]
                      : [
                          Colors.white.withValues(alpha: _isHovered ? 0.08 : 0.04),
                          Colors.white.withValues(alpha: _isHovered ? 0.04 : 0.02),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isActive
                      ? widget.accentColor.withValues(alpha: 0.6)
                      : (_isHovered
                          ? widget.accentColor.withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.1)),
                  width: 1,
                ),
                boxShadow: showGlow
                    ? [
                        BoxShadow(
                          color: widget.accentColor.withValues(alpha: glowSpread * 0.5),
                          blurRadius: 16,
                          spreadRadius: -2,
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    size: 16,
                    color: widget.isActive
                        ? widget.accentColor
                        : (_isHovered
                            ? widget.accentColor.withValues(alpha: 0.9)
                            : Colors.white.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    widget.label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.isActive
                          ? Colors.white
                          : (_isHovered
                              ? Colors.white.withValues(alpha: 0.9)
                              : Colors.white.withValues(alpha: 0.55)),
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (widget.isActive) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: widget.accentColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.accentColor.withValues(alpha: 0.6),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
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
    textColor = const Color(0xFF10B981);
    bgColor = const Color(0xFF10B981).withValues(alpha: 0.15);
    borderColor = const Color(0xFF10B981).withValues(alpha: 0.45);
    icon = Icons.check_circle_rounded;
    label = 'Completed';
  } else if (isInProgress) {
    textColor = const Color(0xFFC084FC);
    bgColor = const Color(0xFFC084FC).withValues(alpha: 0.15);
    borderColor = const Color(0xFFC084FC).withValues(alpha: 0.45);
    icon = Icons.bolt_rounded;
    label = 'In Progress';
  } else {
    textColor = const Color(0xFF94A3B8);
    bgColor = Colors.white.withValues(alpha: 0.06);
    borderColor = Colors.white.withValues(alpha: 0.15);
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
          style: GoogleFonts.inter(
            fontSize: compact ? 10 : 11,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: 0.2,
          ),
        ),
      ],
    ),
  );
}
