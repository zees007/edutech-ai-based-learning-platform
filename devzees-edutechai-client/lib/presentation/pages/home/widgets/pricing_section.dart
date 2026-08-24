import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/presentation/widgets/glass_card.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_button.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';
import 'package:go_router/go_router.dart';

class PricingSection extends StatefulWidget {
  const PricingSection({Key? key}) : super(key: key);

  @override
  State<PricingSection> createState() => _PricingSectionState();
}

class _PricingSectionState extends State<PricingSection> {
  final PageController _pageController = PageController(viewportFraction: 0.88);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    final cards = [
      const _PricingCard(
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
      const _PricingCard(
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
      const _PricingCard(
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
    ];

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
        
        if (isMobile)
          SizedBox(
            height: 720, // Tall enough for the Ultra card on mobile
            child: PageView.builder(
              controller: _pageController,
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: cards[index],
                );
              },
            ),
          )
        else
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 24),
                Expanded(child: cards[1]),
                const SizedBox(width: 24),
                Expanded(child: cards[2]),
              ],
            ),
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
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentPink.withValues(alpha: 0.35),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const Text('MOST POPULAR ⭐', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          Text(name, style: AppTextStyles.h3.copyWith(color: AppColors.accentPink)),
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
          const Spacer(),
          const SizedBox(height: 32),
          if (isPopular)
            GradientButton(
              text: buttonText,
              width: double.infinity,
              onPressed: () {
                context.go('/auth');
              },
            )
          else
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  context.go('/auth');
                },
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
