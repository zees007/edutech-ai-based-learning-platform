import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/presentation/widgets/glass_card.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/presentation/widgets/interactive_3d_card.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

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
                color: const Color(0xFF2B68F6).withValues(alpha: 0.14),
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
                  color: Color(0xFF2B68F6),
                  boxShadow: [
                    BoxShadow(color: Color(0xFF2B68F6), blurRadius: 6),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'SYSTEM CAPABILITIES',
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
        GradientText('Why EduTech AI?', style: AppTextStyles.h2),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Text(
            'Everything you need for an AI-powered learning experience, built from the ground up.',
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
            _FeatureCard(
              icon: '🧩',
              title: 'Adaptive Milestones',
              description: 'AI decomposes any topic into 4-7 structured steps with automatic prerequisite detection.',
              iconColor: AppColors.primary,
            ),
            _FeatureCard(
              icon: '💬',
              title: 'Socratic Dialogue',
              description: 'Never dry lectures. Guided questions and everyday analogies adapted to your education level.',
              iconColor: AppColors.accentBlue,
            ),
            _FeatureCard(
              icon: '🎬',
              title: 'Video Deep-Linking',
              description: 'Curated YouTube clips that jump to the exact timestamp where your concept is explained.',
              iconColor: AppColors.accentCyan,
            ),
            _FeatureCard(
              icon: '📚',
              title: 'Research Curation',
              description: 'Open-access papers from arXiv, Semantic Scholar & OpenAlex with AI-generated takeaways.',
              iconColor: AppColors.accentGreen,
            ),
            _FeatureCard(
              icon: '📝',
              title: 'Dynamic Quizzes',
              description: 'Contextual MCQs after each milestone with instant grading and detailed explanations.',
              iconColor: AppColors.accentAmber,
            ),
            _FeatureCard(
              icon: '🏆',
              title: 'XP & Gamification',
              description: 'Streaks, XP rewards, and a 10-level progression system to keep you motivated.',
              iconColor: AppColors.accentPink,
            ),
          ],
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final Color iconColor;

  const _FeatureCard({
    required this.icon,
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
      maxGlareOpacity: 0.12,
      borderRadius: BorderRadius.circular(24),
      child: GlassCard(
        padding: const EdgeInsets.all(26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: iconColor.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.2),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Text(icon, style: const TextStyle(fontSize: 24)),
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
