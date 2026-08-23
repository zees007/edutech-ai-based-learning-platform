import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/presentation/widgets/glass_card.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return Column(
      children: [
        GradientText('About EduTech AI', style: AppTextStyles.h2),
        const SizedBox(height: 16),
        Text(
          'Transforming education through multi-agent intelligence, academic rigor, and gamified cognitive science.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body1,
        ),
        const SizedBox(height: 48),
        
        // Metric Stats Row
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: const [
            _StatPill(number: '6', label: 'AI Agents'),
            _StatPill(number: '5', label: 'Education Levels'),
            _StatPill(number: '100%', label: 'Academic Integration'),
            _StatPill(number: '10', label: 'Progression Levels'),
          ],
        ),
        const SizedBox(height: 48),
        
        // Unified Mission & Technology Card
        GlassCard(
          padding: EdgeInsets.all(isMobile ? 24 : 48),
          child: Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: isMobile ? 0 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🚀 Our Mission', style: AppTextStyles.h3),
                    const SizedBox(height: 16),
                    Text(
                      'Traditional online learning often relies on passive video watching and static, one-size-fits-all quizzes. EduTech AI was built to pioneer a new paradigm: Interactive Multi-Agent Learning.\n\nWe combine autonomous LLM supervisor orchestrators with specialized worker agents that act as your personal 24/7 tutor—breaking down complex subjects into bite-sized milestones and testing your understanding with Socratic questioning.',
                      style: AppTextStyles.body1,
                    ),
                  ],
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(width: 48),
                Container(width: 1, height: 200, color: AppColors.glassBorder),
                const SizedBox(width: 48),
              ],
              if (isMobile) const SizedBox(height: 32),
              Expanded(
                flex: isMobile ? 0 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🧠 Engineered for Deep Mastery', style: AppTextStyles.h3),
                    const SizedBox(height: 16),
                    Text(
                      'Built on top of a state-persisted supervisor-worker architecture, EduTech AI connects directly to leading academic databases (arXiv, OpenAlex, Semantic Scholar) and curated video timestamps.\n\nWhether you are a high school student grasping basic physics or a researcher analyzing machine learning papers, our system adapts to your cognitive level in real time.',
                      style: AppTextStyles.body1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final String number;
  final String label;

  const _StatPill({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(number, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
