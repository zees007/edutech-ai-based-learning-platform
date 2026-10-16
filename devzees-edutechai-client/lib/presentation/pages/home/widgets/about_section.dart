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
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF60A5FA).withValues(alpha: 0.14),
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
                  color: Color(0xFF60A5FA),
                  boxShadow: [
                    BoxShadow(color: Color(0xFF60A5FA), blurRadius: 6),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'COGNITIVE RESEARCH & ARCHITECTURE',
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
        GradientText('About EduTech AI', style: AppTextStyles.h2),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Text(
            'Transforming education through multi-agent intelligence, academic rigor, and gamified cognitive science.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1.copyWith(
              color: const Color(0xFFB9BECF),
              height: 1.55,
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
              _StatCard(number: '6', label: 'AI Agents', color: Color(0xFF2B68F6)),
              _StatCard(number: '5', label: 'Education Levels', color: Color(0xFF00F5D4)),
              _StatCard(number: '100%', label: 'Academic Grounding', color: Color(0xFF10B981)),
              _StatCard(number: '10', label: 'Progression Levels', color: Color(0xFFE879F9)),
            ],
          )
        else
          Row(
            children: const [
              Expanded(child: _StatCard(number: '6', label: 'AI Agents', color: Color(0xFF2B68F6))),
              SizedBox(width: 16),
              Expanded(child: _StatCard(number: '5', label: 'Education Levels', color: Color(0xFF00F5D4))),
              SizedBox(width: 16),
              Expanded(child: _StatCard(number: '100%', label: 'Academic Grounding', color: Color(0xFF10B981))),
              SizedBox(width: 16),
              Expanded(child: _StatCard(number: '10', label: 'Progression Levels', color: Color(0xFFE879F9))),
            ],
          ),
        const SizedBox(height: 48),

        // Unified Mission & Technology Card
        GlassCard(
          padding: EdgeInsets.all(isMobile ? 24 : 44),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMissionContent(),
                    const SizedBox(height: 32),
                    _buildMasteryContent(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildMissionContent()),
                    const SizedBox(width: 48),
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
          children: const [
            Text('🚀', style: TextStyle(fontSize: 22)),
            SizedBox(width: 10),
            Text(
              'Our Mission',
              style: TextStyle(
                color: Color(0xFFEEF0F6),
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Traditional online learning often relies on passive video watching and static, one-size-fits-all quizzes. EduTech AI was built to pioneer a new paradigm: Interactive Multi-Agent Learning.\n\nWe combine autonomous LLM supervisor orchestrators with specialized worker agents that act as your personal 24/7 tutor—breaking down complex subjects into bite-sized milestones and testing your understanding with Socratic questioning.',
          style: AppTextStyles.body1.copyWith(
            color: const Color(0xFFB9BECF),
            height: 1.6,
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
          children: const [
            Text('🧠', style: TextStyle(fontSize: 22)),
            SizedBox(width: 10),
            Text(
              'Engineered for Deep Mastery',
              style: TextStyle(
                color: Color(0xFFEEF0F6),
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Built on top of a state-persisted supervisor-worker architecture, EduTech AI connects directly to leading academic databases (arXiv, OpenAlex, Semantic Scholar) and curated video timestamps.\n\nWhether you are a high school student grasping basic physics or a researcher analyzing machine learning papers, our system adapts to your cognitive level in real time.',
          style: AppTextStyles.body1.copyWith(
            color: const Color(0xFFB9BECF),
            height: 1.6,
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

  const _StatCard({
    required this.number,
    required this.label,
    required this.color,
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
      child: GlassCard(
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFFB9BECF),
                letterSpacing: 0.2,
              ),
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
