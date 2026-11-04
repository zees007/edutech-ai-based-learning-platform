import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/presentation/widgets/interactive_3d_card.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';

class _AgentData {
  final IconData icon;
  final String role;
  final String status;
  final String title;
  final String description;
  final List<String> tags;
  final Color accentColor;

  const _AgentData({
    required this.icon,
    required this.role,
    required this.status,
    required this.title,
    required this.description,
    required this.tags,
    required this.accentColor,
  });
}

class _AgentCardRenderData {
  final int index;
  final _AgentData agent;
  final double delta;
  final double absDelta;
  final double focusWeight;

  const _AgentCardRenderData({
    required this.index,
    required this.agent,
    required this.delta,
    required this.absDelta,
    required this.focusWeight,
  });
}

/// Autonomous Agent Squad Section.
/// Displays an interactive 3D grid on Desktop/Tablet and a unified single-card
/// 3D Spatial Cylindrical Wheel Slider on Mobile with silky scale transitions.
class AgentsSection extends StatefulWidget {
  const AgentsSection({super.key});

  @override
  State<AgentsSection> createState() => _AgentsSectionState();
}

class _AgentsSectionState extends State<AgentsSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  Animation<double>? _scrollAnimation;

  double _scrollOffset = 0.0;
  Timer? _autoSlideTimer;
  bool _isHovered = false;

  static const List<_AgentData> _agents = [
    _AgentData(
      icon: Icons.hub_rounded,
      role: 'Curriculum Architect',
      status: 'DETERMINISTIC',
      title: 'Supervisor Orchestrator',
      description:
          'Decomposes open-ended topics into progressive directed acyclic milestone graphs with prerequisite calibration.',
      tags: [
        'Step-by-Step Roadmap',
        'Prerequisite Check',
        'Session Memory',
      ],
      accentColor: Color(0xFF3B82F6),
    ),
    _AgentData(
      icon: Icons.psychology_rounded,
      role: 'COGNITIVE TUTOR',
      status: 'SOCRATIC',
      title: 'Socratic Tutor',
      description:
          'Guides conceptual inquiry using real-world anchor analogies, progressive scaffolding, and active dialogue.',
      tags: ['Mental Models', 'Guided Discovery', 'Adaptive Depth'],
      accentColor: Color(0xFF00F5D4),
    ),
    _AgentData(
      icon: Icons.play_circle_filled_rounded,
      role: 'MULTIMEDIA CURATOR',
      status: 'CHROMADB',
      title: 'YouTube Curator',
      description:
          'Scans video transcript vector embeddings to pinpoint exact start-and-end timestamp clips for key concepts.',
      tags: ['Vector Search', 'Precise Timestamps', 'High SNR'],
      accentColor: Color(0xFFF43F5E),
    ),
    _AgentData(
      icon: Icons.menu_book_rounded,
      role: 'SCHOLARLY RESEARCH',
      status: '250M+ PAPERS',
      title: 'Academic Scout',
      description:
          'Conducts live federated searches across arXiv, OpenAlex, and Semantic Scholar with verified DOI paper links.',
      tags: ['arXiv & OpenAlex', 'Live Peer Review', 'AI TL;DR'],
      accentColor: Color(0xFF10B981),
    ),
    _AgentData(
      icon: Icons.quiz_rounded,
      role: 'EVALUATION ENGINE',
      status: 'GROUNDED',
      title: 'Formative Quiz Agent',
      description:
          'Constructs targeted multiple-choice evaluations derived strictly from active lesson context with instant XP grading.',
      tags: ['Zero Hallucination', 'Formative Scoring', 'Instant XP'],
      accentColor: Color(0xFFF59E0B),
    ),
    _AgentData(
      icon: Icons.auto_awesome_rounded,
      role: 'SYNTHESIS & BUS',
      status: 'REAL-TIME',
      title: 'Synthesizer Agent',
      description:
          'Streams live blackboard state over WebSockets and compiles notes into Obsidian, Notion, Mermaid, and PDF.',
      tags: ['WebSocket Bus', 'Mermaid.js', 'Obsidian Ready'],
      accentColor: Color(0xFFA855F7),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    );
    _animController.addListener(() {
      if (_scrollAnimation != null) {
        _scrollOffset = _scrollAnimation!.value;
      }
    });
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {});
      }
    });
    _startAutoSlideTimer();
  }

  void _startAutoSlideTimer() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || _isHovered || _animController.isAnimating) return;
      _animateToOffset((_scrollOffset.round() + 1).toDouble());
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  /// Silky, luxurious cubic bezier curve with gentle onset and majestic feathered settling.
  void _animateToOffset(
    double targetOffset, {
    Duration duration = const Duration(milliseconds: 1150),
    Curve curve = const Cubic(0.25, 0.10, 0.20, 1.0),
  }) {
    if (!mounted) return;
    _animController.stop();
    _scrollAnimation = Tween<double>(
      begin: _scrollOffset,
      end: targetOffset,
    ).animate(CurvedAnimation(parent: _animController, curve: curve));
    _animController.duration = duration;
    _animController.reset();
    _animController.forward();
  }

  double _getCircularDelta(int index, double current, int n) {
    if (n <= 0) return 0.0;
    double d = (index.toDouble() - current) % n.toDouble();
    if (d > n / 2.0) {
      d -= n.toDouble();
    } else if (d < -n / 2.0) {
      d += n.toDouble();
    }
    return d;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return Column(
      children: [
        // Section Header Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.28),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.18),
                blurRadius: 18,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF8B5CF6),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF8B5CF6),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'AUTONOMOUS AGENT SQUAD',
                style: TextStyle(
                  color: Color(0xFFDDD6FE),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        GradientText(
          'Six Specialized Autonomous Agents. One Unified Mind.',
          style: (isMobile ? AppTextStyles.h3 : AppTextStyles.h2).copyWith(
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            'Rather than a single monolithic prompt, EduTech AI orchestrates six dedicated AI micro-agents operating in parallel over a shared blackboard memory architecture.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1.copyWith(
              color: const Color(0xFF94A3B8),
              fontSize: isMobile ? 15 : 17,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 40),

        // Display Desktop 6-agent Grid or Unified Mobile Single-Card 3D Slider
        if (isMobile)
          _buildMobile3dSlider()
        else
          _buildDesktopGrid(context),
      ],
    );
  }

  /// Desktop & Tablet view: Displays all 6 agents in a multi-column grid with Interactive3DCard
  Widget _buildDesktopGrid(BuildContext context) {
    final int crossAxisCount = Responsive.isTablet(context) ? 2 : 3;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 22,
      mainAxisSpacing: 22,
      childAspectRatio: 1.12,
      children: _agents
          .map((agent) => _AgentCard(
                key: ValueKey('agent_grid_${agent.title}'),
                agent: agent,
                isMobile: false,
              ))
          .toList(),
    );
  }

  /// Mobile view: Exactly ONE card in view at rest (maxVisibleDelta = 0.85) with silky scale-up/down transitions
  Widget _buildMobile3dSlider() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Column(
        children: [
          SizedBox(
            height: 340,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double viewportWidth = constraints.maxWidth;
                final double cardWidth = math.min(viewportWidth - 32.0, 360.0);
                const double cardHeight = 290.0;

                // Exactly one card visible at rest on mobile view
                const double maxVisibleDelta = 0.85;
                final double spacingRadius = viewportWidth * 0.90;
                const double angleStep = 0.50;

                return AnimatedBuilder(
                  animation: _animController,
                  builder: (context, _) {
                    final double currentOffset = _animController.isAnimating
                        ? (_scrollAnimation?.value ?? _scrollOffset)
                        : _scrollOffset;

                    // Transition progress factor between integer cards [0.0 .. 0.5]
                    final double fractionalShift =
                        (currentOffset - currentOffset.round()).abs();
                    // Bell-curve motion factor peaking at midpoint of slide change:
                    final double transitionFactor =
                        math.sin(fractionalShift * math.pi);
                    // Dynamic scale compression dip (-6.5%) during active sliding
                    final double transitionScaleDip =
                        1.0 - (transitionFactor * 0.065);

                    final visibleData = <_AgentCardRenderData>[];
                    for (int i = 0; i < _agents.length; i++) {
                      final double delta =
                          _getCircularDelta(i, currentOffset, _agents.length);
                      final double absDelta = delta.abs();
                      if (absDelta <= maxVisibleDelta) {
                        final double clamped = absDelta.clamp(0.0, 0.85);
                        final double t = (0.85 - clamped) / 0.85;
                        final double focusWeight = t * t * (3.0 - 2.0 * t);

                        visibleData.add(_AgentCardRenderData(
                          index: i,
                          agent: _agents[i],
                          delta: delta,
                          absDelta: absDelta,
                          focusWeight: focusWeight,
                        ));
                      }
                    }

                    // Sort descending so background cards paint first and center hero card paints last
                    visibleData.sort((a, b) => b.absDelta.compareTo(a.absDelta));

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragStart: (_) {
                        _autoSlideTimer?.cancel();
                        _animController.stop();
                      },
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          _scrollOffset -= details.primaryDelta! / 220.0;
                        });
                      },
                      onHorizontalDragEnd: (details) {
                        final velocity = details.primaryVelocity ?? 0.0;
                        double target = _scrollOffset;
                        if (velocity.abs() > 250) {
                          target += velocity > 0 ? -1.0 : 1.0;
                        }
                        _animateToOffset(target.roundToDouble());
                        _startAutoSlideTimer();
                      },
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.transparent,
                              Colors.white,
                              Colors.white,
                              Colors.transparent,
                            ],
                            stops: [0.0, 0.04, 0.96, 1.0],
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.dstIn,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: visibleData.map((data) {
                            final double delta = data.delta;
                            final double absDelta = data.absDelta;
                            final double focusWeight = data.focusWeight;
                            final agent = data.agent;

                            final double xOffset =
                                spacingRadius * math.sin(delta * angleStep);
                            final double rotateY =
                                (-delta * 0.36).clamp(-0.85, 0.85);

                            final double baseScale;
                            if (absDelta <= 1.0) {
                              baseScale = 0.85 +
                                  0.15 * math.cos(absDelta * (math.pi / 2.0));
                            } else {
                              baseScale = (0.85 - ((absDelta - 1.0) * 0.10))
                                  .clamp(0.60, 0.85);
                            }

                            final double scale = (baseScale * transitionScaleDip)
                                .clamp(0.56, 1.0);

                            final double opacity = absDelta < 0.35
                                ? 1.0
                                : (math.pow(0.50, absDelta).toDouble())
                                    .clamp(0.12, 1.0);

                            return Center(
                              key: ValueKey('agent_card_${agent.title}'),
                              child: Transform.translate(
                                offset: Offset(xOffset, 0),
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001)
                                    ..rotateY(rotateY),
                                  child: Transform.scale(
                                    scale: scale,
                                    child: Opacity(
                                      opacity: opacity,
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          if (absDelta > 0.35) {
                                            _animateToOffset(
                                                _scrollOffset + delta);
                                          }
                                        },
                                        child: _AgentCard(
                                          agent: agent,
                                          isMobile: true,
                                          focusWeight: focusWeight,
                                          width: cardWidth,
                                          height: cardHeight,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Centered Glowing Indicator Dots
          AnimatedBuilder(
            animation: _animController,
            builder: (context, _) {
              final double currentOffset = _animController.isAnimating
                  ? (_scrollAnimation?.value ?? _scrollOffset)
                  : _scrollOffset;
              final int activeIndex =
                  (currentOffset.round() % _agents.length + _agents.length) %
                      _agents.length;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_agents.length, (index) {
                  final isSelected = activeIndex == index;
                  final color = _agents[index].accentColor;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      final double delta = _getCircularDelta(
                          index, currentOffset, _agents.length);
                      _animateToOffset(_scrollOffset + delta);
                      _startAutoSlideTimer();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        width: isSelected ? 24 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color
                              : Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.70),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Agent card component supporting both Desktop Interactive3DCard grid and Mobile 3D slider.
class _AgentCard extends StatefulWidget {
  final _AgentData agent;
  final bool isMobile;
  final double focusWeight;
  final double? width;
  final double? height;

  const _AgentCard({
    super.key,
    required this.agent,
    this.isMobile = false,
    this.focusWeight = 1.0,
    this.width,
    this.height,
  });

  @override
  State<_AgentCard> createState() => _AgentCardState();
}

class _AgentCardState extends State<_AgentCard> {
  bool _isCardHovered = false;

  @override
  Widget build(BuildContext context) {
    final agent = widget.agent;
    final color = agent.accentColor;

    if (!widget.isMobile) {
      // Desktop Grid Card with Interactive3DCard (perspective tilt & glare)
      return MouseRegion(
        onEnter: (_) => setState(() => _isCardHovered = true),
        onExit: (_) => setState(() => _isCardHovered = false),
        child: Interactive3DCard(
          maxTiltAngle: 0.07,
          perspective: 0.001,
          hoverScale: 1.025,
          glareColor: color,
          maxGlareOpacity: 0.16,
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            decoration: BoxDecoration(
              color: _isCardHovered
                  ? const Color(0xFF0F1226)
                  : const Color(0xDD0A0D1D),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: _isCardHovered
                    ? color.withValues(alpha: 0.55)
                    : Colors.white.withValues(alpha: 0.09),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isCardHovered
                      ? color.withValues(alpha: 0.22)
                      : Colors.black.withValues(alpha: 0.45),
                  blurRadius: _isCardHovered ? 28 : 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildCardContent(context, agent, color, 1.0, false),
            ),
          ),
        ),
      );
    }

    // Mobile Slider Card with Center Zoom & Focus Interpolation
    final bool isMidCard = widget.focusWeight > 0.70;
    final bool isZoomed = isMidCard && _isCardHovered;
    final double w = isMidCard
        ? math.max(widget.focusWeight, _isCardHovered ? 1.0 : 0.0)
        : widget.focusWeight;

    return MouseRegion(
      onEnter: (_) => setState(() => _isCardHovered = true),
      onExit: (_) => setState(() => _isCardHovered = false),
      child: AnimatedScale(
        scale: isZoomed ? 1.045 : 1.0,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: widget.width ?? 340,
          height: widget.height ?? 290,
          transform: Matrix4.translationValues(
            0,
            -6.0 * w + (isZoomed ? -4.0 : 0.0),
            0,
          ),
          decoration: BoxDecoration(
            color: Color.lerp(
              const Color(0x66080A16),
              const Color(0xF20B0D1E),
              w,
            )!,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Color.lerp(
                Colors.white.withValues(alpha: 0.08),
                color.withValues(alpha: 0.70),
                w,
              )!,
              width: 1.0 + 0.5 * w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.30 + 0.35 * w + (isZoomed ? 0.15 : 0.0),
                ),
                blurRadius: 14 + 16 * w + (isZoomed ? 8 : 0),
                offset: Offset(0, 6 + 4 * w),
              ),
              if (w > 0.05 || isZoomed)
                BoxShadow(
                  color: color.withValues(
                    alpha: isZoomed ? 0.38 : (0.30 * w),
                  ),
                  blurRadius: 20 + 18 * w + (isZoomed ? 10 : 0),
                  spreadRadius: isZoomed ? 0 : -2,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: _buildCardContent(context, agent, color, w, true),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(
    BuildContext context,
    _AgentData agent,
    Color color,
    double w,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Row: Glowing Vector Icon & Telemetry Pill
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: isMobile ? 44 : 48,
              height: isMobile ? 44 : 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12 + 0.10 * w),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: color.withValues(alpha: 0.30 + 0.35 * w),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15 + 0.25 * w),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: Icon(
                agent.icon,
                color: color,
                size: isMobile ? 22 : 24,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.06 + 0.08 * w),
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: color.withValues(alpha: 0.16 + 0.20 * w),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      boxShadow: [
                        BoxShadow(
                          color: color,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    agent.status,
                    style: TextStyle(
                      color: color,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 14 : 16),

        // Role Eyebrow
        Text(
          agent.role,
          style: TextStyle(
            color: color.withValues(alpha: 0.70 + 0.30 * w),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 3),

        // Title
        Text(
          agent.title,
          style: TextStyle(
            color: Color.lerp(
              const Color(0xFFCBD5E1),
              const Color(0xFFF8FAFC),
              w,
            ),
            fontSize: isMobile ? 17 : 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),

        // Description
        Expanded(
          child: Text(
            agent.description,
            style: TextStyle(
              color: Color.lerp(
                const Color(0xFF94A3B8),
                const Color(0xFFCBD5E1),
                w,
              ),
              fontSize: 12.5,
              height: 1.5,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 10),

        // Bottom Micro-Tags
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: agent.tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3.5,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03 + 0.04 * w),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06 + 0.06 * w),
                ),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  color: Color.lerp(
                    const Color(0xFF94A3B8),
                    const Color(0xFFCBD5E1),
                    w,
                  ),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
