import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/presentation/widgets/glass_card.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_button.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';
import 'package:go_router/go_router.dart';

class PricingSection extends StatefulWidget {
  const PricingSection({super.key});

  @override
  State<PricingSection> createState() => _PricingSectionState();
}

class _PricingSectionState extends State<PricingSection> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;
  bool _isAnnual = true; // Annual billing by default

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    final cards = [
      _PricingCard(
        name: 'Free',
        price: '\$0',
        billingCycle: 'forever free',
        description: 'Essential multi-agent tutoring for curious learners starting out.',
        features: [
          '10 AI Sessions / month',
          '1 Follow-Up Question / step',
          '1 YouTube Video / step (Clips)',
          'Bite-Sized & Visual Modes',
          'Milestone Quizzes & XP',
          'All 5 Education Levels',
          'Session History & Recovery',
        ],
        buttonText: 'Start Free Now',
      ),
      _PricingCard(
        name: 'Pro',
        price: _isAnnual ? '\$15' : '\$19',
        billingCycle: _isAnnual ? '/mo (billed annually)' : '/month',
        originalPrice: _isAnnual ? '\$19/mo' : null,
        description: 'Full agent squad, visual modes, research preprints & Markdown export.',
        features: [
          'Unlimited AI Sessions',
          '5 Follow-Up Questions / step',
          '3 YouTube Videos / step (Clips)',
          'Visual & Deep-Dive Modes',
          'Academic Preprints & AI TL;DR',
          'Step Content Regeneration',
          'Markdown (.md) Export (Mermaid)',
          '1.5x XP Multiplier Boost',
        ],
        buttonText: 'Upgrade to Pro ⚡',
        isPopular: true,
      ),
      _PricingCard(
        name: 'Ultra',
        price: _isAnnual ? '\$39' : '\$49',
        billingCycle: _isAnnual ? '/mo (billed annually)' : '/month',
        originalPrice: _isAnnual ? '\$49/mo' : null,
        description: 'Unrestricted multi-agent squad, full research, PDF export & 2x XP.',
        features: [
          'Everything in Pro +',
          'Unlimited Follow-Up Chat Turns',
          '5 YouTube Videos / step',
          'Full-Text Academic Research (PDF)',
          'Executive Styled PDF (.pdf) Export',
          'Priority Multi-Agent Exec & Low Latency',
          '2x XP Boost & Accelerated Levels',
          '24/7 Priority Support',
        ],
        buttonText: 'Select Ultra ✨',
      ),
    ];

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
                color: const Color(0xFFE879F9).withValues(alpha: 0.14),
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
                  color: Color(0xFFE879F9),
                  boxShadow: [
                    BoxShadow(color: Color(0xFFE879F9), blurRadius: 6),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'TRANSPARENT TIERED PLANS',
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
        GradientText('Choose Your Learning Path', style: AppTextStyles.h2),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Text(
            'Start free with 10 sessions every month. Upgrade as your curiosity and academic needs expand.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1,
          ),
        ),
        const SizedBox(height: 32),

        // Monthly / Annual Toggle
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xCC090A14),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => setState(() => _isAnnual = false),
                borderRadius: BorderRadius.circular(9999),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: !_isAnnual ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(9999),
                    boxShadow: !_isAnnual
                        ? [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.25),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    'Monthly',
                    style: TextStyle(
                      color: !_isAnnual ? const Color(0xFF04050C) : const Color(0xFFB9BECF),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => setState(() => _isAnnual = true),
                borderRadius: BorderRadius.circular(9999),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isAnnual ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(9999),
                    boxShadow: _isAnnual
                        ? [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.25),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Annual',
                        style: TextStyle(
                          color: _isAnnual ? const Color(0xFF04050C) : const Color(0xFFB9BECF),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _isAnnual ? const Color(0xFF10B981) : const Color(0xFF10B981).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          'SAVE 20%',
                          style: TextStyle(
                            color: _isAnnual ? Colors.white : const Color(0xFF10B981),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Risk-reversal assurance
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: const [
            _PricingTrustChip(text: '10 Free Sessions Monthly'),
            _PricingTrustChip(text: 'No Credit Card Required'),
            _PricingTrustChip(text: 'Cancel Anytime With 1-Click'),
          ],
        ),
        const SizedBox(height: 48),

        if (isMobile)
          Column(
            children: [
              SizedBox(
                height: 780,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: cards.length,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: cards[index],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(cards.length, (index) {
                  final isSelected = _currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isSelected ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ],
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

        const SizedBox(height: 56),

        // Enterprise & University Callout Banner
        GlassCard(
          padding: EdgeInsets.all(isMobile ? 24 : 32),
          child: Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
                      children: [
                        const Text('🏫', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Text(
                          'EduTech AI for Universities & Research Labs',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Campus-wide seat licensing, dedicated LMS/Canvas LTI integration, private model endpoints, and departmental analytics.',
                      textAlign: isMobile ? TextAlign.center : TextAlign.start,
                      style: AppTextStyles.body2.copyWith(color: AppColors.textSlate),
                    ),
                  ],
                ),
              ),
              if (isMobile) const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  context.go('/auth');
                },
                icon: const Icon(Icons.business_center_outlined, size: 16),
                label: const Text('Contact Solutions Architect', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
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
  final String billingCycle;
  final String? originalPrice;
  final String description;
  final List<String> features;
  final String buttonText;
  final bool isPopular;

  const _PricingCard({
    required this.name,
    required this.price,
    required this.billingCycle,
    this.originalPrice,
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
              const SizedBox(width: 6),
              Flexible(
                child: Text(billingCycle, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ),
            ],
          ),
          if (originalPrice != null) ...[
            const SizedBox(height: 2),
            Text(
              'Regular $originalPrice',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Text(description, style: AppTextStyles.body2),
          const SizedBox(height: 20),
          Divider(color: AppColors.glassBorder),
          const SizedBox(height: 20),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(Icons.check, color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(f, style: AppTextStyles.body2)),
              ],
            ),
          )),
          const Spacer(),
          const SizedBox(height: 24),
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
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: AppColors.glassBorder),
                  ),
                  elevation: 0,
                  textStyle: AppTextStyles.button.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(buttonText),
              ),
            ),
        ],
      ),
    );
  }
}

class _PricingTrustChip extends StatelessWidget {
  final String text;
  const _PricingTrustChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF10B981),
            size: 13,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFB9BECF),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

