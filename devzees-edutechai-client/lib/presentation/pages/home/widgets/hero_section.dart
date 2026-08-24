import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_button.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';
import 'package:go_router/go_router.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Master Any Subject with a',
          textAlign: TextAlign.center,
          style: (isMobile ? AppTextStyles.h2 : AppTextStyles.h1).copyWith(
            height: 1.1,
          ),
        ),
        GradientText(
          'Team of AI Agents',
          style: (isMobile ? AppTextStyles.h2 : AppTextStyles.h1).copyWith(
            height: 1.1,
          ),
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Text(
            'Our orchestrator divides complex topics into milestones, while specialized agents guide you through Socratic dialogue, curated videos, research papers, and interactive assessments.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1.copyWith(
              fontSize: isMobile ? 16 : 18,
            ),
          ),
        ),
        const SizedBox(height: 24),
        GradientButton(
          text: 'Start Learning for Free →',
          width: isMobile ? 260 : 280,
          onPressed: () {
            context.go('/auth');
          },
        ),
      ],
    );
  }
}
