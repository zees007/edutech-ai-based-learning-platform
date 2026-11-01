import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/presentation/widgets/glass_card.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/presentation/widgets/interactive_3d_card.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';

class AgentsSection extends StatelessWidget {
  const AgentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final int crossAxisCount = isMobile
        ? 1
        : (Responsive.isTablet(context) ? 2 : 3);

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
        const SizedBox(height: 48),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 22,
          mainAxisSpacing: 22,
          childAspectRatio: isMobile
              ? (MediaQuery.of(context).size.width < 480
                    ? 0.88
                    : (MediaQuery.of(context).size.width < 600 ? 1.08 : 1.35))
              : 1.12,
          children: const [
            _AgentCard(
              icon: Icons.hub_rounded,
              role: 'Curriculum Architect',
              status: 'DETERMINISTIC',
              title: 'Supervisor Orchestrator',
              description:
                  'Decomposes open-ended topics into progressive directed acyclic milestone graphs with prerequisite calibration.',
              tags: [
                'Step-by-Step Roadmap',
                'Low Temperature',
                'Session Graph',
              ],
              accentColor: Color(0xFF3B82F6),
            ),
            _AgentCard(
              icon: Icons.psychology_rounded,
              role: 'COGNITIVE TUTOR',
              status: 'SOCRATIC',
              title: 'Socratic Tutor',
              description:
                  'Guides conceptual inquiry using real-world anchor analogies, progressive scaffolding, and active dialogue.',
              tags: ['Mental Models', 'Guided Discovery', 'Adaptive Depth'],
              accentColor: Color(0xFF00F5D4),
            ),
            _AgentCard(
              icon: Icons.play_circle_filled_rounded,
              role: 'MULTIMEDIA CURATOR',
              status: 'CHROMADB',
              title: 'YouTube Curator',
              description:
                  'Scans video transcript vector embeddings to pinpoint exact start-and-end timestamp clips for key concepts.',
              tags: ['Vector Search', 'Precise Timestamps', 'High SNR'],
              accentColor: Color(0xFFF43F5E),
            ),
            _AgentCard(
              icon: Icons.menu_book_rounded,
              role: 'SCHOLARLY RESEARCH',
              status: '250M+ PAPERS',
              title: 'Academic Scout',
              description:
                  'Conducts live federated searches across arXiv, OpenAlex, and Semantic Scholar with verified DOI paper links.',
              tags: ['arXiv & OpenAlex', 'Live Peer Review', 'AI TL;DR'],
              accentColor: Color(0xFF10B981),
            ),
            _AgentCard(
              icon: Icons.quiz_rounded,
              role: 'EVALUATION ENGINE',
              status: 'GROUNDED',
              title: 'Formative Quiz Agent',
              description:
                  'Constructs targeted multiple-choice evaluations derived strictly from active lesson context with instant XP grading.',
              tags: ['Zero Hallucination', 'Formative Scoring', 'Instant XP'],
              accentColor: Color(0xFFF59E0B),
            ),
            _AgentCard(
              icon: Icons.auto_awesome_rounded,
              role: 'SYNTHESIS & BUS',
              status: 'REAL-TIME',
              title: 'Synthesizer Agent',
              description:
                  'Streams live blackboard state over WebSockets and compiles notes into Obsidian, Notion, Mermaid, and PDF.',
              tags: ['WebSocket Bus', 'Mermaid.js', 'Obsidian Ready'],
              accentColor: Color(0xFFA855F7),
            ),
          ],
        ),
      ],
    );
  }
}

class _AgentCard extends StatefulWidget {
  final IconData icon;
  final String role;
  final String status;
  final String title;
  final String description;
  final List<String> tags;
  final Color accentColor;

  const _AgentCard({
    required this.icon,
    required this.role,
    required this.status,
    required this.title,
    required this.description,
    required this.tags,
    required this.accentColor,
  });

  @override
  State<_AgentCard> createState() => _AgentCardState();
}

class _AgentCardState extends State<_AgentCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.accentColor;

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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          decoration: BoxDecoration(
            color: _isHovered
                ? const Color(0xFF0F1226)
                : const Color(0xDD0A0D1D),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: _isHovered
                  ? color.withValues(alpha: 0.55)
                  : Colors.white.withValues(alpha: 0.09),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? color.withValues(alpha: 0.22)
                    : Colors.black.withValues(alpha: 0.45),
                blurRadius: _isHovered ? 28 : 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Glowing Vector Icon & Telemetry Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
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
                      child: Icon(widget.icon, color: color, size: 24),
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
                            widget.status,
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
                const SizedBox(height: 18),

                // Role Eyebrow
                Text(
                  widget.role,
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
                  widget.title,
                  style: const TextStyle(
                    color: Color(0xFFF1F5F9),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),

                // Description
                Expanded(
                  child: Text(
                    widget.description,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                      height: 1.55,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Bottom Micro-Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: widget.tags.map((tag) {
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
        ),
      ),
    );
  }
}
