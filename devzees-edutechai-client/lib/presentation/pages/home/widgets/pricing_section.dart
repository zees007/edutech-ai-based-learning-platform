import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/presentation/widgets/glass_card.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_button.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';

class PricingSection extends StatelessWidget {
  const PricingSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return Column(
      children: [
        GradientText('Choose Your Path', style: AppTextStyles.h2),
        const SizedBox(height: 16),
        Text(
          'Flexible plans designed for every type of learner.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body1,
        ),
        const SizedBox(height: 48),
        
        Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: isMobile ? 0 : 1,
              child: const _PricingCard(
                name: 'Free',
                price: '\$0',
                description: 'Essential AI tutoring for curious learners starting out.',
                features: [
                  '10 AI Sessions / month',
                  '1 Follow-Up Question / step',
                  '1 YouTube Video / step',
                  'Bite-Sized Learning Mode',
                  'Milestone Quizzes & XP',
                  'All 5 Education Levels',
                  'Session History & Recovery',
                ],
                buttonText: 'Start Free',
              ),
            ),
            if (isMobile) const SizedBox(height: 24) else const SizedBox(width: 24),
            Expanded(
              flex: isMobile ? 0 : 1,
              child: const _PricingCard(
                name: 'Pro',
                price: '\$19',
                description: 'Full agent squad, visual modes, research preprints & Markdown export.',
                features: [
                  'Unlimited AI Sessions',
                  '5 Follow-Up Questions / step',
                  '3 YouTube Videos / step (Clips)',
                  'Visual & Deep-Dive Modes',
                  'Academic Preprints & AI TL;DR',
                  'Step Content Regeneration',
                  'Markdown (.md) Export',
                  '1.5x XP Multiplier',
                ],
                buttonText: 'Upgrade to Pro ⚡',
                isPopular: true,
              ),
            ),
            if (isMobile) const SizedBox(height: 24) else const SizedBox(width: 24),
            Expanded(
              flex: isMobile ? 0 : 1,
              child: const _PricingCard(
                name: 'Ultra',
                price: '\$49',
                description: 'Unrestricted multi-agent squad, full research, PDF export & 2x XP.',
                features: [
                  'Everything in Pro +',
                  'Unlimited Follow-Up Chat',
                  '5 YouTube Videos / step',
                  'Full-Text Academic Research',
                  'Markdown + PDF (.pdf) Export',
                  'Priority Multi-Agent Exec',
                  '2x XP Boost & Fast Leveling',
                  '24/7 Priority Support',
                ],
                buttonText: 'Select Ultra ✨',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PricingCard extends StatelessWidget {
  final String name;
  final String price;
  final String description;
  final List<String> features;
  final String buttonText;
  final bool isPopular;

  const _PricingCard({
    required this.name,
    required this.price,
    required this.description,
    required this.features,
    required this.buttonText,
    this.isPopular = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      isGlowing: isPopular,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary),
              ),
              child: const Text('MOST POPULAR ⭐', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          Text(name, style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(price, style: AppTextStyles.h1),
              const Text('/mo', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Text(description, style: AppTextStyles.body2),
          const SizedBox(height: 24),
          const Divider(color: AppColors.glassBorder),
          const SizedBox(height: 24),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(Icons.check, color: AppColors.primary, size: 18),
                const SizedBox(width: 12),
                Expanded(child: Text(f, style: AppTextStyles.body2)),
              ],
            ),
          )),
          const SizedBox(height: 32),
          if (isPopular)
            GradientButton(
              text: buttonText,
              width: double.infinity,
              onPressed: () {},
            )
          else
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.glassBase,
                  side: const BorderSide(color: AppColors.glassBorder),
                ),
                child: Text(buttonText),
              ),
            ),
        ],
      ),
    );
  }
}
