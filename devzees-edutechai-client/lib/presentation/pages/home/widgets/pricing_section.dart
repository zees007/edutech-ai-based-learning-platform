import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/services/subscription_service.dart';
import 'package:devzees_edutechai_client/data/models/subscription/payment_models.dart';
import 'package:devzees_edutechai_client/presentation/widgets/glass_card.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_button.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';
import 'package:go_router/go_router.dart';

class PricingSection extends ConsumerStatefulWidget {
  const PricingSection({super.key});

  @override
  ConsumerState<PricingSection> createState() => _PricingSectionState();
}

class _PricingSectionState extends ConsumerState<PricingSection> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 1; // Default to Pro (index 1) on mobile
  bool _isAnnual = true; // Annual billing by default

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    final catalogAsync = ref.watch(pricingCatalogProvider);
    final catalog = catalogAsync.value ?? PricingCatalogModel.defaultCatalog;
    final proMonthly = catalog.getPrice('pro', 'monthly');
    final proAnnual = catalog.getPrice('pro', 'annual');
    final proPerMonth = (proAnnual / 12.0).round();
    final ultraMonthly = catalog.getPrice('ultra', 'monthly');
    final ultraAnnual = catalog.getPrice('ultra', 'annual');
    final ultraPerMonth = (ultraAnnual / 12.0).round();

    final cards = [
      _PricingCard(
        name: 'Free',
        price: '\$0',
        billingCycle: 'forever free',
        description: 'Essential multi-agent tutoring for curious learners and quick revisions.',
        features: [
          '10 AI Sessions / month',
          '1 Follow-Up Question / step',
          '1 YouTube Video Clip / step',
          'Bite-Sized & Visual Modes',
          'Milestone Quizzes & XP Tracking',
          'All 5 Cognitive Education Levels',
          'Session History & Resumption',
        ],
        buttonText: 'Start Free Now',
        accentColor: const Color(0xFF64748B),
      ),
      _PricingCard(
        name: 'Pro',
        price: _isAnnual ? '\$$proPerMonth' : '\$$proMonthly',
        billingCycle: _isAnnual ? '/mo (\$$proAnnual billed annually)' : '/month',
        originalPrice: _isAnnual ? '\$$proMonthly/mo' : null,
        description: 'Full agent squad, visual DAGs, research preprints & Markdown export.',
        features: [
          'Unlimited AI Sessions',
          '5 Follow-Up Questions / step',
          '3 YouTube Clips / step (Vector)',
          'Visual & Deep-Dive Modes',
          'Academic Preprints & AI TL;DR',
          'Step Content Regeneration',
          'Markdown (.md) Export (Mermaid)',
          '1.5x XP Multiplier Boost',
        ],
        buttonText: 'Get Started with Pro',
        isPopular: true,
        accentColor: const Color(0xFF3B82F6),
      ),
      _PricingCard(
        name: 'Ultra',
        price: _isAnnual ? '\$$ultraPerMonth' : '\$$ultraMonthly',
        billingCycle: _isAnnual ? '/mo (\$$ultraAnnual billed annually)' : '/month',
        originalPrice: _isAnnual ? '\$$ultraMonthly/mo' : null,
        description: 'Unrestricted multi-agent power, full-text research, styled PDF & 2x XP.',
        features: [
          'Everything in Pro +',
          'Unlimited Follow-Up Chat Turns',
          '5 YouTube Video Clips / step',
          'Full-Text Academic Research (PDF)',
          'Executive Styled PDF (.pdf) Export',
          'Priority Model Routing & Low Latency',
          '2x XP Boost & Accelerated Levels',
          '24/7 Priority Support',
        ],
        buttonText: 'Upgrade to Ultra',
        accentColor: const Color(0xFFA855F7),
      ),
    ];

    return Column(
      children: [
        // Section Header Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.28)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.16),
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
                  color: Color(0xFF3B82F6),
                  boxShadow: [
                    BoxShadow(color: Color(0xFF3B82F6), blurRadius: 8, spreadRadius: 1),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'TRANSPARENT TIERED PLANS',
                style: TextStyle(
                  color: Color(0xFFBFDBFE),
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
          'Predictable Pricing. Exponential Growth.',
          style: (isMobile ? AppTextStyles.h3 : AppTextStyles.h2).copyWith(
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Text(
            'Start free with 10 sessions every month. Upgrade as your research complexity and academic goals expand.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1.copyWith(
              color: const Color(0xFF94A3B8),
              fontSize: isMobile ? 15 : 17,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Monthly / Annual Toggle
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color(0xDD0A0D1D),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
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
                      color: !_isAnnual ? const Color(0xFF060814) : const Color(0xFF94A3B8),
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
                          color: _isAnnual ? const Color(0xFF060814) : const Color(0xFF94A3B8),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          catalog.getGlobalAnnualSavingsLabel(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
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
        const SizedBox(height: 22),

        // Risk-reversal assurance
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: const [
            _PricingTrustChip(text: '10 Free Sessions Monthly'),
            _PricingTrustChip(text: 'No Credit Card Required'),
            _PricingTrustChip(text: '1-Click Cancellation Anytime'),
          ],
        ),
        const SizedBox(height: 48),

        if (isMobile)
          Column(
            children: [
              SizedBox(
                height: 720,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: cards.length,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                      color: isSelected ? const Color(0xFF3B82F6) : Colors.white24,
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
        Container(
          padding: EdgeInsets.all(isMobile ? 24 : 32),
          decoration: BoxDecoration(
            color: const Color(0xDD0A0D1D),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 30,
              ),
            ],
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.account_balance_rounded,
                            color: Color(0xFF60A5FA),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            'EduTech AI for Universities & Research Labs',
                            textAlign: isMobile ? TextAlign.center : TextAlign.start,
                            style: TextStyle(
                              color: const Color(0xFFF1F5F9),
                              fontSize: isMobile ? 15 : 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Campus-wide seat licensing, dedicated LMS/Canvas LTI integration, private model endpoints, and departmental telemetry analytics.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13.5,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () {
                        context.go('/auth');
                      },
                      icon: const Icon(Icons.business_center_rounded, size: 16),
                      label: const Text('Contact Solutions Architect', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF3B82F6), width: 1.2),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.10),
                      ),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.account_balance_rounded,
                                  color: Color(0xFF60A5FA),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'EduTech AI for Universities & Research Labs',
                                  style: TextStyle(
                                    color: Color(0xFFF1F5F9),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Campus-wide seat licensing, dedicated LMS/Canvas LTI integration, private model endpoints, and departmental telemetry analytics.',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13.5,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    OutlinedButton.icon(
                      onPressed: () {
                        context.go('/auth');
                      },
                      icon: const Icon(Icons.business_center_rounded, size: 16),
                      label: const Text('Contact Solutions Architect', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF3B82F6), width: 1.2),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.10),
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
  final Color accentColor;

  const _PricingCard({
    required this.name,
    required this.price,
    required this.billingCycle,
    this.originalPrice,
    required this.description,
    required this.features,
    required this.buttonText,
    this.isPopular = false,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isPopular ? const Color(0xFF0F132C) : const Color(0xDD0A0D1D),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPopular
              ? const Color(0xFF3B82F6).withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.09),
          width: isPopular ? 1.8 : 1.2,
        ),
        boxShadow: isPopular
            ? [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.22),
                  blurRadius: 36,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular)
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.auto_awesome_rounded, size: 12, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'MOST POPULAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Text(
            name,
            style: TextStyle(
              color: isPopular ? const Color(0xFF60A5FA) : const Color(0xFFF1F5F9),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  billingCycle,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (originalPrice != null) ...[
            const SizedBox(height: 2),
            Text(
              'Regular $originalPrice',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withValues(alpha: 0.08)),
          const SizedBox(height: 20),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 17,
                  height: 17,
                  decoration: BoxDecoration(
                    color: isPopular
                        ? const Color(0xFF00F5D4).withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: isPopular ? const Color(0xFF00F5D4) : Colors.white70,
                    size: 12,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    f,
                    style: const TextStyle(
                      color: Color(0xFFE2E8F0),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 20),
          const SizedBox(height: 24),
          if (isPopular)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => context.go('/auth'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        buttonText,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 16),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => context.go('/auth'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFF1F5F9),
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor: Colors.white.withValues(alpha: 0.03),
                  textStyle: const TextStyle(
                    fontSize: 14,
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
              color: Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
