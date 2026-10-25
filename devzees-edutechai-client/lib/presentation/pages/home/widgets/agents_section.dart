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
    final int crossAxisCount = isMobile ? 1 : (Responsive.isTablet(context) ? 2 : 3);

    return Column(
      children: [
        // Section Header Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9061F9).withValues(alpha: 0.14),
                blurRadius: 16,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF9061F9),
                  boxShadow: [
                    BoxShadow(color: Color(0xFF9061F9), blurRadius: 6),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'AUTONOMOUS AGENT SQUAD',
                style: TextStyle(
                  color: Color(0xFFD4D8E8),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GradientText('The Agent Squad', style: AppTextStyles.h2),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Text(
            'Six specialized AI agents working in parallel via shared memory to deliver your personalized curriculum.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1.copyWith(
              color: const Color(0xFFB9BECF),
              height: 1.55,
            ),
          ),
        ),
        const SizedBox(height: 48),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: isMobile ? 1.45 : 1.18,
          children: const [
            _AgentCard(
              icon: '🎯',
              role: 'SUPERVISOR',
              title: 'Orchestrator',
              description: 'Decomposes open-ended topics into milestone graphs and prerequisite warmups.',
              iconColor: AppColors.primary,
            ),
            _AgentCard(
              icon: '💬',
              role: 'COGNITIVE TUTOR',
              title: 'Socratic Tutor',
              description: 'Guided inquiry, daily-life mental models, and contextual dialogue adapted to your level.',
              iconColor: AppColors.accentBlue,
            ),
            _AgentCard(
              icon: '🎬',
              role: 'MULTIMEDIA CURATOR',
              title: 'YouTube Curator',
              description: 'Scans video transcript vector embeddings to pinpoint exact start-and-end timestamp clips.',
              iconColor: AppColors.accentCyan,
            ),
            _AgentCard(
              icon: '📚',
              role: 'SCHOLARLY RESEARCH',
              title: 'Academic Researcher',
              description: 'Direct live query across 250M+ peer-reviewed papers on arXiv, Semantic Scholar, and OpenAlex.',
              iconColor: AppColors.accentGreen,
            ),
            _AgentCard(
              icon: '📝',
              role: 'GROUNDED TESTING',
              title: 'Quiz Agent',
              description: 'Formative MCQs strictly grounded on the current lesson with immediate XP scoring.',
              iconColor: AppColors.accentAmber,
            ),
            _AgentCard(
              icon: '⚡',
              role: 'TELEMETRY ENGINE',
              title: 'Synthesizer Agent',
              description: 'Streams live blackboard state over WebSockets and exports to Obsidian & Notion markdown.',
              iconColor: AppColors.accentPink,
            ),
          ],
        ),
      ],
    );
  }
}

class _AgentCard extends StatelessWidget {
  final String icon;
  final String role;
  final String title;
  final String description;
  final Color iconColor;

  const _AgentCard({
    required this.icon,
    required this.role,
    required this.title,
    required this.description,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Interactive3DCard(
      maxTiltAngle: 0.08,
      perspective: 0.001,
      hoverScale: 1.02,
      glareColor: iconColor,
      maxGlareOpacity: 0.15,
      borderRadius: BorderRadius.circular(24),
      child: GlassCard(
        isGlowing: false,
        padding: const EdgeInsets.all(26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: iconColor.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withValues(alpha: 0.22),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Text(icon, style: const TextStyle(fontSize: 22)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(color: iconColor.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    role,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: AppTextStyles.h4.copyWith(
                color: const Color(0xFFEEF0F6),
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppTextStyles.body2.copyWith(
                color: const Color(0xFFB9BECF),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
