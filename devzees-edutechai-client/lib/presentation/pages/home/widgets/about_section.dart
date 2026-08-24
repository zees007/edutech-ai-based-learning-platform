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
        
        // Metric Stats Cards
        if (isMobile)
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: const [
              _StatCard(number: '6', label: 'AI Agents'),
              _StatCard(number: '5', label: 'Education Levels'),
              _StatCard(number: '100%', label: 'Academic Integration'),
              _StatCard(number: '10', label: 'Progression Levels'),
            ],
          )
        else
          Row(
            children: const [
              Expanded(child: _StatCard(number: '6', label: 'AI Agents')),
              SizedBox(width: 16),
              Expanded(child: _StatCard(number: '5', label: 'Education Levels')),
              SizedBox(width: 16),
              Expanded(child: _StatCard(number: '100%', label: 'Academic Integration')),
              SizedBox(width: 16),
              Expanded(child: _StatCard(number: '10', label: 'Progression Levels')),
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

class _StatCard extends StatelessWidget {
  final String number;
  final String label;

  const _StatCard({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(number, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
