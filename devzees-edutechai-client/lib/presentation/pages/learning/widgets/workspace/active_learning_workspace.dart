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
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      padding: const EdgeInsets.all(24),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: widget.activeState.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : widget.session.steps.isNotEmpty
          ? Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Space for icons
                      const SizedBox(height: 64.0),
                      
                      // The Expandable Panel inline
                      AnimatedSize(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutQuart,
                        alignment: Alignment.topRight,
                        child: _activeOverlay != null
                          ? Container(
                              margin: const EdgeInsets.only(bottom: 24, top: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.85), // Glassy without blur
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                  topRight: Radius.circular(4), // Chat bubble tail
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    spreadRadius: -5,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: _activeOverlay!,
                              ),
                            )
                          : const SizedBox(height: 0),
                      ),
                      
                      // Main Content
                      widget.buildStepContent(widget.session.steps[widget.activeState.activeStepIndex]),
                    ],
                  ),
                ),
                
                // Floating Icons (Top Right)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Row(
                    children: [
                      if (widget.session.steps[widget.activeState.activeStepIndex].videos != null && 
                          widget.session.steps[widget.activeState.activeStepIndex].videos!.isNotEmpty)
                        _GlassyIconButton(
                          emoji: '🎬', 
                          tooltip: 'Recommended YouTube Video Clips & Timestamps', 
                          onTap: () {
                             if (_activeOverlay is RecommendedVideos) {
                               _closeOverlay();
                             } else {
                               _showOverlay(RecommendedVideos(videos: widget.session.steps[widget.activeState.activeStepIndex].videos));
                             }
                          }
                        ),
                      const SizedBox(width: 12),
                      if (widget.session.steps[widget.activeState.activeStepIndex].papers != null && 
                          widget.session.steps[widget.activeState.activeStepIndex].papers!.isNotEmpty)
                        _GlassyIconButton(
                          emoji: '📚', 
                          tooltip: 'Academic Research Papers', 
                          onTap: () {
                             if (_activeOverlay is AcademicPapers) {
                               _closeOverlay();
                             } else {
                               _showOverlay(AcademicPapers(papers: widget.session.steps[widget.activeState.activeStepIndex].papers));
                             }
                          }
                        ),
                    ],
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

class _GlassyIconButton extends StatefulWidget {
  final String emoji;
  final String tooltip;
  final VoidCallback onTap;

  const _GlassyIconButton({
    required this.emoji,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_GlassyIconButton> createState() => _GlassyIconButtonState();
}

class _GlassyIconButtonState extends State<_GlassyIconButton> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _floatAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      textStyle: GoogleFonts.inter(color: Colors.white, fontSize: 12),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: child,
              );
            },
            child: AnimatedScale(
              scale: _isPressed ? 0.85 : (_isHovered ? 1.05 : 1.0),
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _isHovered ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isHovered ? AppColors.primary.withValues(alpha: 0.6) : AppColors.primary.withValues(alpha: 0.3), 
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: _isHovered ? 0.4 : 0.2),
                      blurRadius: _isHovered ? 16 : 10,
                    ),
                  ],
                ),
                child: Text(widget.emoji, style: const TextStyle(fontSize: 20)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
