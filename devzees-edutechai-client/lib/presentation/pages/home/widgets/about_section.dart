import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/presentation/widgets/glass_card.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/presentation/widgets/interactive_3d_card.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return Column(
      children: [
        // Section Header Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.28)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.16),
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
                  color: Color(0xFF38BDF8),
                  boxShadow: [
                    BoxShadow(color: Color(0xFF38BDF8), blurRadius: 8, spreadRadius: 1),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'COGNITIVE RESEARCH & ARCHITECTURE',
                style: TextStyle(
                  color: Color(0xFFBAE6FD),
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
          'Engineered for Deep Intellectual Mastery',
          style: (isMobile ? AppTextStyles.h3 : AppTextStyles.h2).copyWith(
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            'We believe the future of education is not passive video streaming or shallow chatbot summaries. It is interactive, autonomous, multi-agent cognitive co-learning.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1.copyWith(
              color: const Color(0xFF94A3B8),
              fontSize: isMobile ? 15 : 17,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 48),

        // Metric Stats Cards
        if (isMobile)
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.25,
            children: const [
              _StatCard(number: '6', label: 'AI Agents', color: Color(0xFF3B82F6), icon: Icons.hub_rounded),
              _StatCard(number: '5', label: 'Cognitive Levels', color: Color(0xFF00F5D4), icon: Icons.school_rounded),
              _StatCard(number: '100%', label: 'Strictly Grounded', color: Color(0xFF10B981), icon: Icons.verified_rounded),
              _StatCard(number: '10', label: 'Progression Tiers', color: Color(0xFFA855F7), icon: Icons.military_tech_rounded),
            ],
          )
        else
          Row(
            children: const [
              Expanded(child: _StatCard(number: '6', label: 'AI Specialists', color: Color(0xFF3B82F6), icon: Icons.hub_rounded)),
              SizedBox(width: 16),
              Expanded(child: _StatCard(number: '5', label: 'Cognitive Levels', color: Color(0xFF00F5D4), icon: Icons.school_rounded)),
              SizedBox(width: 16),
              Expanded(child: _StatCard(number: '100%', label: 'Strictly Grounded', color: Color(0xFF10B981), icon: Icons.verified_rounded)),
              SizedBox(width: 16),
              Expanded(child: _StatCard(number: '10', label: 'Progression Tiers', color: Color(0xFFA855F7), icon: Icons.military_tech_rounded)),
            ],
          ),
        const SizedBox(height: 40),

        // Unified Mission & Technology Card
        Container(
          decoration: BoxDecoration(
            color: const Color(0xDD0A0D1D),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.10),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 36,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: EdgeInsets.all(isMobile ? 24 : 40),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMissionContent(),
                    const SizedBox(height: 32),
                    Divider(color: Colors.white.withValues(alpha: 0.08)),
                    const SizedBox(height: 32),
                    _buildMasteryContent(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildMissionContent()),
                    Container(
                      width: 1,
                      height: 220,
                      margin: const EdgeInsets.symmetric(horizontal: 36),
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    Expanded(child: _buildMasteryContent()),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildMissionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
                ),
              ),
              child: const Icon(
                Icons.rocket_launch_rounded,
                color: Color(0xFF60A5FA),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Our Mission',
              style: TextStyle(
                color: Color(0xFFF1F5F9),
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Traditional online learning often relies on passive video watching and static, one-size-fits-all quizzes. EduTech AI was built to pioneer a new paradigm: Interactive Multi-Agent Cognitive Learning.\n\nWe combine an autonomous LLM supervisor orchestrator with specialized worker agents that act as your personal 24/7 research team—breaking down open-ended topics into rigorous milestones and validating comprehension with Socratic inquiry.',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14,
            height: 1.65,
          ),
        ),
      ],
    );
  }

  Widget _buildMasteryContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF00F5D4).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF00F5D4).withValues(alpha: 0.35),
                ),
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: Color(0xFF00F5D4),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Cognitive Scaffolding',
              style: TextStyle(
                color: Color(0xFFF1F5F9),
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Built on top of a state-persisted supervisor-worker blackboard architecture, EduTech AI connects directly to verified academic databases (arXiv, OpenAlex, Semantic Scholar) and indexed video embeddings.\n\nWhether you are a high school student grasping Newtonian physics or a researcher analyzing deep learning papers, our system calibrates to your cognitive bandwidth in real time.',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14,
            height: 1.65,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String number;
  final String label;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.number,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Interactive3DCard(
      maxTiltAngle: 0.08,
      perspective: 0.001,
      hoverScale: 1.025,
      glareColor: color,
      maxGlareOpacity: 0.15,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xDD0A0D1D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 18,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.2,
                  ),
                ),
                Icon(icon, size: 16, color: color.withValues(alpha: 0.7)),
              ],
            ),
            const SizedBox(height: 10),
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Colors.white,
                  color,
                ],
              ).createShader(Rect.fromLTWH(0, 0, bounds.width > 0 ? bounds.width : 100, 40)),
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
