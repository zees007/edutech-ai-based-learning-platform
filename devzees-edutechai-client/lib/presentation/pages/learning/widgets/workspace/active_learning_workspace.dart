import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/providers/active_session_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import 'milestone_roadmap_stepper.dart';
import 'socratic_tutor_chat.dart';
import 'recommended_videos.dart';
import 'academic_papers.dart';
import 'knowledge_check_quiz.dart';

class ActiveLearningWorkspace extends ConsumerWidget {
  const ActiveLearningWorkspace({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeState = ref.watch(activeSessionProvider);
    final session = activeState.session;

    if (session == null) {
      return const SizedBox.shrink();
    }

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Column(
              children: [
        // Gamification Dashboard Section
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 1000;
                  final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1000;
                  final isMobile = constraints.maxWidth < 600;
                  final levelData = _calculateLevel(session.xpEarned);
                  final int totalSteps = session.steps.isNotEmpty ? session.steps.length : 1;
                  final double topicPct = session.stepsCompleted / totalSteps;

                  final topTitleContent = Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF472B6), Color(0xFFC084FC)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEC4899).withValues(alpha: 0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text('🏆', style: TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Mastery Dashboard',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFFAFAFA),
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Real-time learning milestone progress & XP rewards',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFFE9D5FF).withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );

                  final modePills = Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildModePill(
                        label: 'Mode',
                        emoji: '🎨',
                        value: session.learningMode,
                        accentColor: const Color(0xFFC084FC),
                        backgroundColor: const Color(0xFFC084FC).withValues(alpha: 0.1),
                      ),
                      _buildModePill(
                        label: 'Audience',
                        emoji: '🏫',
                        value: session.studentLevel,
                        accentColor: const Color(0xFF60A5FA),
                        backgroundColor: const Color(0xFF60A5FA).withValues(alpha: 0.1),
                      ),
                    ],
                  );

                  return Column(
                    children: [
                      // Top Title Card
                      _buildJourneyGlassContainer(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 20, 
                          vertical: isMobile ? 12 : 16
                        ),
                        child: isMobile
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  topTitleContent,
                                  const SizedBox(height: 16),
                                  modePills,
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: topTitleContent),
                                  const SizedBox(width: 16),
                                  modePills,
                                ],
                              ),
                      ),
                      const SizedBox(height: 16),
                      // 4 Metric Cards
                      Builder(
                        builder: (context) {
                          final card1 = _buildGlassMetricCard(
                            'Current Level',
                            'Lvl ${levelData['level']}',
                            levelData['title'] as String,
                            const Color(0xFFC084FC),
                            statGradient: const LinearGradient(
                              colors: [Color(0xFFF472B6), Color(0xFFC084FC)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          );
                          final card2 = _buildGlassMetricCard(
                            'Total XP Earned',
                            '${session.xpEarned}',
                            'Streak: 0 🔥',
                            const Color(0xFF38BDF8),
                            leadingStatIcon: const Icon(Icons.star_rounded, color: Colors.white, size: 32),
                            statGradient: const LinearGradient(
                              colors: [Color(0xFFF472B6), Color(0xFFC084FC)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          );
                          final card3 = _buildGlassProgressCard(
                            'Level Progress (Lvl ${levelData['level']} → ${(levelData['level'] as int) + 1})',
                            '${session.xpEarned} / ${levelData['xp_for_next_level']} XP',
                            '(${levelData['xp_in_level']}/${levelData['xp_needed_for_next']} in Lvl)',
                            levelData['progress'] as double,
                            const [Color(0xFFF472B6), Color(0xFFC084FC)],
                            const Color(0xFFF472B6),
                          );
                          final card4 = _buildGlassProgressCard(
                            'Topic Completion',
                            '${session.stepsCompleted} of $totalSteps Steps',
                            '(${(topicPct * 100).toStringAsFixed(0)}%)',
                            topicPct,
                            const [Color(0xFF34D399), Color(0xFF6EE7B7)],
                            const Color(0xFF34D399),
                          );

                          if (isDesktop) {
                            return IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(flex: 1, child: card1),
                                  const SizedBox(width: 16),
                                  Expanded(flex: 1, child: card2),
                                  const SizedBox(width: 16),
                                  Expanded(flex: 2, child: card3),
                                  const SizedBox(width: 16),
                                  Expanded(flex: 2, child: card4),
                                ],
                              ),
                            );
                          } else if (isTablet) {
                            return Column(
                              children: [
                                IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(child: card1),
                                      const SizedBox(width: 16),
                                      Expanded(child: card2),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(child: card3),
                                      const SizedBox(width: 16),
                                      Expanded(child: card4),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          } else {
                            // Mobile Carousel
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              clipBehavior: Clip.none,
                              child: Row(
                                children: [
                                  SizedBox(width: 200, child: card1),
                                  const SizedBox(width: 12),
                                  SizedBox(width: 200, child: card2),
                                  const SizedBox(width: 12),
                                  SizedBox(width: 240, child: card3),
                                  const SizedBox(width: 12),
                                  SizedBox(width: 240, child: card4),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        // Milestone Stepper and Query
        if (session.steps.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Asked Query
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC084FC).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFC084FC).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'YOUR GOAL',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFC084FC),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        session.topic,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Roadmap Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC084FC).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.route_rounded,
                        color: Color(0xFFC084FC),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Milestone Learning Roadmap',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFAFAFA),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                MilestoneRoadmapStepper(
                  steps: session.steps,
                  activeIndex: activeState.activeStepIndex,
                  onStepTapped: (index) {
                    ref.read(activeSessionProvider.notifier).setActiveStep(index);
                  },
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.white.withValues(alpha: 0.1), thickness: 1),
                const SizedBox(height: 8),
              ],
            ),
          ),
              ],
            ),
          ),
        ];
      },
      // Main Content Area for Active Step
      body: _StepContentContainer(
        activeState: activeState,
        session: session,
        buildStepContent: _buildStepContent,
      ),
    );
  }

  Map<String, dynamic> _calculateLevel(int totalXp) {
    const levels = [
      {"level": 1, "xp_required": 0, "title": "Curious Explorer"},
      {"level": 2, "xp_required": 100, "title": "Knowledge Seeker"},
      {"level": 3, "xp_required": 300, "title": "Quick Learner"},
      {"level": 4, "xp_required": 600, "title": "Deep Thinker"},
      {"level": 5, "xp_required": 1000, "title": "Rising Scholar"},
      {"level": 6, "xp_required": 1500, "title": "Concept Master"},
      {"level": 7, "xp_required": 2200, "title": "Wisdom Weaver"},
      {"level": 8, "xp_required": 3000, "title": "Knowledge Architect"},
      {"level": 9, "xp_required": 4000, "title": "Enlightened Mind"},
      {"level": 10, "xp_required": 5500, "title": "Grand Sage"},
    ];

    var current = levels[0];
    var nextLevel = levels.length > 1 ? levels[1] : null;

    for (var i = 0; i < levels.length; i++) {
      final levelInfo = levels[i];
      if (totalXp >= (levelInfo["xp_required"] as int)) {
        current = levelInfo;
        nextLevel = (i + 1 < levels.length) ? levels[i + 1] : null;
      } else {
        break;
      }
    }

    int xpInLevel;
    int xpNeeded;
    double progress;

    if (nextLevel != null) {
      xpInLevel = totalXp - (current["xp_required"] as int);
      xpNeeded = (nextLevel["xp_required"] as int) - (current["xp_required"] as int);
      progress = xpNeeded > 0 ? (xpInLevel / xpNeeded) : 1.0;
    } else {
      xpInLevel = totalXp - (current["xp_required"] as int);
      xpNeeded = 0;
      progress = 1.0;
    }

    return {
      "level": current["level"],
      "title": current["title"],
      "total_xp": totalXp,
      "xp_for_current_level": current["xp_required"],
      "xp_for_next_level": nextLevel != null ? nextLevel["xp_required"] : current["xp_required"],
      "xp_in_level": xpInLevel,
      "xp_needed_for_next": xpNeeded,
      "progress": progress,
    };
  }



  Widget _buildJourneyGlassContainer({required Widget child, EdgeInsetsGeometry? padding}) {
    return _AnimatedGlassContainer(
      padding: padding,
      child: child,
    );
  }

  Widget _buildModePill({
    required String label,
    required String emoji,
    required String value,
    required Color accentColor,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.15),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              color: accentColor.withValues(alpha: 0.9),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassMetricCard(
    String label, 
    String stat, 
    String subtitle, 
    Color subtitleColor, {
    Color statColor = const Color(0xFFFAFAFA),
    Widget? leadingStatIcon,
    Gradient? statGradient,
  }) {
    Widget statWidget = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leadingStatIcon != null) ...[
          leadingStatIcon,
          const SizedBox(width: 8),
        ],
        Text(
          stat,
          style: GoogleFonts.inter(
            color: statGradient != null ? Colors.white : statColor,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );

    if (statGradient != null) {
      statWidget = ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => statGradient.createShader(bounds),
        child: statWidget,
      );
    }

    return _buildJourneyGlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8).withValues(alpha: 0.85),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          statWidget,
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              color: subtitleColor,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGlassProgressCard(
    String label, 
    String statMain, 
    String statSub, 
    double progress, 
    List<Color> gradientColors, 
    Color glowColor
  ) {
    return _buildJourneyGlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8).withValues(alpha: 0.85),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$statMain ',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFF1F5F9),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: statSub,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withValues(alpha: 0.4),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(dynamic step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.title,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          step.description,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        if (step.tutorExplanation != null) ...[
          Text(
            'Tutor Explanation',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            step.tutorExplanation!,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
        ],

        if (step.socraticQuestions != null && step.socraticQuestions!.isNotEmpty) ...[
          SocraticTutorChat(socraticQuestions: step.socraticQuestions),
          const SizedBox(height: 32),
        ],
        if (step.quiz != null && step.quiz!.isNotEmpty) ...[
          KnowledgeCheckQuiz(quiz: step.quiz),
          const SizedBox(height: 32),
        ],
      ],
    );
  }
}

class _AnimatedGlassContainer extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _AnimatedGlassContainer({
    required this.child,
    this.padding,
  });

  @override
  State<_AnimatedGlassContainer> createState() => _AnimatedGlassContainerState();
}

class _AnimatedGlassContainerState extends State<_AnimatedGlassContainer> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -2.0 : 0, 0),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Main Glass Container Background
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xF00F172A), // rgba(15, 23, 42, 0.94)
                            Color(0xE61A112E), // rgba(26, 17, 46, 0.9)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: _isHovered
                              ? const Color(0xD9A855F7) // rgba(168, 85, 247, 0.85)
                              : const Color(0x73A855F7), // rgba(168, 85, 247, 0.45)
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: _isHovered
                                ? const Color(0x33A855F7) // 0.2 alpha
                                : const Color(0x1EA855F7), // 0.12 alpha
                            blurRadius: _isHovered ? 45 : 35,
                            blurStyle: BlurStyle.inner,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // The content
            Container(
              padding: widget.padding,
              child: widget.child,
            ),
            // Top Glowing Neon Bar
            Positioned(
              top: 0,
              left: 20,
              right: 20,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isHovered ? 1.0 : 0.8,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.accentPink,
                        AppColors.primary,
                        AppColors.accentBlue,
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentPink,
                        blurRadius: _isHovered ? 22 : 15,
                      ),
                      BoxShadow(
                        color: AppColors.primary,
                        blurRadius: _isHovered ? 30 : 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepContentContainer extends StatefulWidget {
  final ActiveSessionState activeState;
  final dynamic session;
  final Widget Function(dynamic) buildStepContent;

  const _StepContentContainer({
    required this.activeState,
    required this.session,
    required this.buildStepContent,
  });

  @override
  State<_StepContentContainer> createState() => _StepContentContainerState();
}

class _StepContentContainerState extends State<_StepContentContainer> {
  Widget? _activeOverlay;


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
    final currentStep = widget.session.steps[widget.activeState.activeStepIndex];
    final hasVideos = currentStep.videos != null && currentStep.videos!.isNotEmpty;
    final hasPapers = currentStep.papers != null && currentStep.papers!.isNotEmpty;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.04),
            Colors.white.withValues(alpha: 0.015),
            const Color(0xFF1A112E).withValues(alpha: 0.3),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.04),
            blurRadius: 40,
            spreadRadius: -10,
            offset: const Offset(0, 8),
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
                if (hasVideos || hasPapers)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0F172A).withValues(alpha: 0.7),
                          const Color(0xFF1A112E).withValues(alpha: 0.5),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.06),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Left label
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: const Color(0xFF34D399),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF34D399).withValues(alpha: 0.5),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'RESOURCES',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.4),
                                letterSpacing: 1.5,
                              ),
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

                // ─── Scrollable Content (Overlay + Step Content) ───
                Expanded(
                  child: SingleChildScrollView(
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
                        widget.buildStepContent(widget.session.steps[widget.activeState.activeStepIndex]),
                      ],
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
