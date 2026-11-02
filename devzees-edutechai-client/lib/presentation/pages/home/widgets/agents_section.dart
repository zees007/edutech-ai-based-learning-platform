import 'dart:async';
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

class AgentsSection extends StatefulWidget {
  const AgentsSection({super.key});

  @override
  State<AgentsSection> createState() => _AgentsSectionState();
}

class _AgentsSectionState extends State<AgentsSection> {
  int _activeMobileIndex = 0;
  late final PageController _pageController;
  Timer? _autoSlideTimer;

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
    _pageController = PageController(viewportFraction: 0.88);
    _startAutoSlideTimer();
  }

  void _startAutoSlideTimer() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      if (!_pageController.hasClients) return;
      final nextIndex = (_activeMobileIndex + 1) % _agents.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
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

        if (isMobile)
          _buildMobileCarousel()
        else
          _buildDesktopGrid(context),
      ],
    );
  }

  Widget _buildMobileCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 340,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification &&
                  notification.dragDetails != null) {
                // Pause auto-rotation while user is actively swiping
                _autoSlideTimer?.cancel();
              } else if (notification is ScrollEndNotification) {
                // Resume 3-second auto-rotation after user swipe finishes
                _startAutoSlideTimer();
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _activeMobileIndex = index;
                });
              },
              itemCount: _agents.length,
              itemBuilder: (context, index) {
                final agent = _agents[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: _AgentCard(
                    agent: agent,
                    isMobile: true,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Centered Glowing Dots Indicator
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_agents.length, (index) {
              final isSelected = _activeMobileIndex == index;
              final color = _agents[index].accentColor;
              return GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 360),
                    curve: Curves.easeInOutCubic,
                  );
                  _startAutoSlideTimer();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
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
              );
            }),
          ),
        ),
      ],
    );
  }

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
          .map((agent) => _AgentCard(agent: agent, isMobile: false))
          .toList(),
    );
  }
}

class _AgentCard extends StatefulWidget {
  final _AgentData agent;
  final bool isMobile;

  const _AgentCard({
    required this.agent,
    required this.isMobile,
  });

  @override
  State<_AgentCard> createState() => _AgentCardState();
}

class _AgentCardState extends State<_AgentCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final agent = widget.agent;
    final color = agent.accentColor;

    final cardBody = AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      decoration: BoxDecoration(
        color: widget.isMobile
            ? const Color(0xFF0C0F22)
            : (_isHovered
                ? const Color(0xFF0F1226)
                : const Color(0xDD0A0D1D)),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: widget.isMobile
              ? color.withValues(alpha: 0.40)
              : (_isHovered
                  ? color.withValues(alpha: 0.55)
                  : Colors.white.withValues(alpha: 0.09)),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isMobile
                ? color.withValues(alpha: 0.16)
                : (_isHovered
                    ? color.withValues(alpha: 0.22)
                    : Colors.black.withValues(alpha: 0.45)),
            blurRadius: widget.isMobile ? 20 : (_isHovered ? 28 : 16),
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(widget.isMobile ? 20.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Glowing Vector Icon & Telemetry Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: widget.isMobile ? 44 : 48,
                  height: widget.isMobile ? 44 : 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: color.withValues(alpha: 0.38),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.28),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: Icon(
                    agent.icon,
                    color: color,
                    size: widget.isMobile ? 22 : 24,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(
                      color: color.withValues(alpha: 0.24),
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
                            BoxShadow(color: color, blurRadius: 4),
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
            SizedBox(height: widget.isMobile ? 14 : 18),

            // Role Eyebrow
            Text(
              agent.role,
              style: TextStyle(
                color: color.withValues(alpha: 0.85),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),

            // Title
            Text(
              agent.title,
              style: TextStyle(
                color: const Color(0xFFF1F5F9),
                fontSize: widget.isMobile ? 17 : 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),

            // Description
            Expanded(
              child: Text(
                agent.description,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                  height: 1.52,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Bottom Micro-Tags
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: agent.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.07),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );

    if (widget.isMobile) {
      return cardBody;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Interactive3DCard(
        maxTiltAngle: 0.07,
        perspective: 0.001,
        hoverScale: 1.025,
        glareColor: color,
        maxGlareOpacity: 0.16,
        borderRadius: BorderRadius.circular(22),
        child: cardBody,
      ),
    );
  }
}
