import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/presentation/widgets/glass_card.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';

class AgentsSection extends StatelessWidget {
  const AgentsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final int crossAxisCount = isMobile ? 1 : (Responsive.isTablet(context) ? 2 : 3);

    return Column(
      children: [
        GradientText('The Agent Squad', style: AppTextStyles.h2),
        const SizedBox(height: 16),
        Text(
          'Six specialized AI agents working in parallel via shared memory to deliver your personalized curriculum.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body1,
        ),
        const SizedBox(height: 48),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: isMobile ? 1.5 : 1.2,
          children: const [
            _AgentCard(
              icon: '🎯',
              title: 'Orchestrator',
              description: 'Supervisor agent. Decomposes topics into structured milestone steps.',
              iconColor: AppColors.primary,
            ),
            _AgentCard(
              icon: '💬',
              title: 'Socratic Tutor',
              description: 'Guided questioning, real-world analogies, and conceptual scaffolding.',
              iconColor: AppColors.accentBlue,
            ),
            _AgentCard(
              icon: '🎬',
              title: 'YouTube Curator',
              description: 'Finds videos and pinpoints exact timestamp clips for each milestone.',
              iconColor: AppColors.accentCyan,
            ),
            _AgentCard(
              icon: '📚',
              title: 'Academic Researcher',
              description: 'Curates open-access papers with AI-generated key takeaways.',
              iconColor: AppColors.accentGreen,
            ),
            _AgentCard(
              icon: '📝',
              title: 'Dynamic Quiz',
              description: 'Generates contextual MCQs with instant grading and XP rewards.',
              iconColor: AppColors.accentAmber,
            ),
            _AgentCard(
              icon: '📊',
              title: 'Gamification Engine',
              description: 'Streak tracking, level progression (1-10), and session persistence.',
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
  final String title;
  final String description;
  final Color iconColor;

  const _AgentCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      isGlowing: true, // Agent cards have a permanent slight glow
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: iconColor.withValues(alpha: 0.3)),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.h4),
          const SizedBox(height: 8),
          Text(description, style: AppTextStyles.body2),
        ],
      ),
    );
  }
}
