import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/core/services/subscription_service.dart';
import 'package:devzees_edutechai_client/data/models/subscription/payment_models.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';
import 'package:go_router/go_router.dart';

class _PricingCardRenderData {
  final int index;
  final _PricingCard card;
  final double delta;
  final double absDelta;
  final double focusWeight;

  const _PricingCardRenderData({
    required this.index,
    required this.card,
    required this.delta,
    required this.absDelta,
    required this.focusWeight,
  });
}

class PricingSection extends ConsumerStatefulWidget {
  const PricingSection({super.key});

  @override
  ConsumerState<PricingSection> createState() => _PricingSectionState();
}

class _PricingSectionState extends ConsumerState<PricingSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  Animation<double>? _scrollAnimation;

  // Default to Pro tier (index 1) in center focus
  double _scrollOffset = 1.0;
  Timer? _autoSlideTimer;
  bool _isDragging = false;
  bool _isAnnual = true; // Annual billing by default

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    );
    _animController.addListener(() {
      if (_scrollAnimation != null) {
        _scrollOffset = _scrollAnimation!.value;
      }
    });
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {});
      }
    });
    _startAutoSlideTimer();
  }

  void _startAutoSlideTimer() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || _animController.isAnimating || _isDragging) return;
      _animateToOffset((_scrollOffset.round() + 1).toDouble());
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _animateToOffset(
    double targetOffset, {
    Duration duration = const Duration(milliseconds: 1150),
    Curve curve = const Cubic(0.25, 0.10, 0.20, 1.0),
  }) {
    if (!mounted) return;
    _animController.stop();
    _scrollAnimation = Tween<double>(
      begin: _scrollOffset,
      end: targetOffset,
    ).animate(CurvedAnimation(parent: _animController, curve: curve));
    _animController.duration = duration;
    _animController.reset();
    _animController.forward();
  }

  double _getCircularDelta(int index, double current, int n) {
    if (n <= 0) return 0.0;
    double d = (index.toDouble() - current) % n.toDouble();
    if (d > n / 2.0) {
      d -= n.toDouble();
    } else if (d < -n / 2.0) {
      d += n.toDouble();
    }
    return d;
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
        key: const ValueKey('pricing_tier_free'),
        name: 'Free',
        price: '\$0',
        billingCycle: 'forever free',
        description:
            'Essential multi-agent tutoring for curious learners and quick revisions.',
        features: const [
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
        key: const ValueKey('pricing_tier_pro'),
        name: 'Pro',
        price: _isAnnual ? '\$$proPerMonth' : '\$$proMonthly',
        billingCycle:
            _isAnnual ? '/mo (\$$proAnnual billed annually)' : '/month',
        originalPrice: _isAnnual ? '\$$proMonthly/mo' : null,
        description:
            'Full agent squad, visual DAGs, research preprints & Markdown export.',
        features: const [
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
        key: const ValueKey('pricing_tier_ultra'),
        name: 'Ultra',
        price: _isAnnual ? '\$$ultraPerMonth' : '\$$ultraMonthly',
        billingCycle:
            _isAnnual ? '/mo (\$$ultraAnnual billed annually)' : '/month',
        originalPrice: _isAnnual ? '\$$ultraMonthly/mo' : null,
        description:
            'Unrestricted multi-agent power, full-text research, styled PDF & 2x XP.',
        features: const [
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
            border: Border.all(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.28)),
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
                    BoxShadow(
                        color: Color(0xFF3B82F6),
                        blurRadius: 8,
                        spreadRadius: 1),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                      color: !_isAnnual
                          ? const Color(0xFF060814)
                          : const Color(0xFF94A3B8),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                          color: _isAnnual
                              ? const Color(0xFF060814)
                              : const Color(0xFF94A3B8),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2.5),
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

        // Desktop multi-column grid/row or Mobile 3D single-card slider
        if (isMobile)
          _buildMobile3dSlider(cards)
        else
          _buildDesktopRow(cards),

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
                            color:
                                const Color(0xFF3B82F6).withValues(alpha: 0.15),
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
                            textAlign:
                                isMobile ? TextAlign.center : TextAlign.start,
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
                      label: const Text('Contact Solutions Architect',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                            color: Color(0xFF3B82F6), width: 1.2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        backgroundColor:
                            const Color(0xFF3B82F6).withValues(alpha: 0.10),
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
                                  color: const Color(0xFF3B82F6)
                                      .withValues(alpha: 0.15),
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
                      label: const Text('Contact Solutions Architect',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                            color: Color(0xFF3B82F6), width: 1.2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        backgroundColor:
                            const Color(0xFF3B82F6).withValues(alpha: 0.10),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  /// Desktop: 3 pricing cards displayed in a balanced row with hover zoom & lift
  Widget _buildDesktopRow(List<_PricingCard> cards) {
    return IntrinsicHeight(
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
    );
  }

  /// Mobile view: Exactly ONE card in view at rest (maxVisibleDelta = 0.85) with silky scale-up/down transitions & glowing dots
  Widget _buildMobile3dSlider(List<_PricingCard> cards) {
    return Column(
      children: [
        SizedBox(
          height: 720,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double viewportWidth = constraints.maxWidth;
              final double cardWidth = math.min(viewportWidth - 32.0, 360.0);
              const double cardHeight = 690.0;

              // Exactly one card visible at rest on mobile view
              const double maxVisibleDelta = 0.85;
              final double spacingRadius = viewportWidth * 0.90;
              const double angleStep = 0.50;

              return AnimatedBuilder(
                animation: _animController,
                builder: (context, _) {
                  final double currentOffset = _animController.isAnimating
                      ? (_scrollAnimation?.value ?? _scrollOffset)
                      : _scrollOffset;

                  // Transition progress factor between integer cards [0.0 .. 0.5]
                  final double fractionalShift =
                      (currentOffset - currentOffset.round()).abs();
                  // Bell-curve motion factor peaking at midpoint of slide change:
                  final double transitionFactor =
                      math.sin(fractionalShift * math.pi);
                  // Dynamic scale compression dip (-6.5%) during active sliding
                  final double transitionScaleDip =
                      1.0 - (transitionFactor * 0.065);

                  final visibleData = <_PricingCardRenderData>[];
                  for (int i = 0; i < cards.length; i++) {
                    final double delta =
                        _getCircularDelta(i, currentOffset, cards.length);
                    final double absDelta = delta.abs();
                    if (absDelta <= maxVisibleDelta) {
                      final double clamped = absDelta.clamp(0.0, 0.85);
                      final double t = (0.85 - clamped) / 0.85;
                      final double focusWeight = t * t * (3.0 - 2.0 * t);

                      visibleData.add(_PricingCardRenderData(
                        index: i,
                        card: cards[i],
                        delta: delta,
                        absDelta: absDelta,
                        focusWeight: focusWeight,
                      ));
                    }
                  }

                  // Sort descending so background cards paint first and center hero card paints last
                  visibleData
                      .sort((a, b) => b.absDelta.compareTo(a.absDelta));

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragStart: (_) {
                      _isDragging = true;
                      _autoSlideTimer?.cancel();
                      _animController.stop();
                    },
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        _scrollOffset -= details.primaryDelta! / 220.0;
                      });
                    },
                    onHorizontalDragEnd: (details) {
                      _isDragging = false;
                      final velocity = details.primaryVelocity ?? 0.0;
                      double target = _scrollOffset;
                      if (velocity.abs() > 250) {
                        target += velocity > 0 ? -1.0 : 1.0;
                      }
                      _animateToOffset(target.roundToDouble());
                      _startAutoSlideTimer();
                    },
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            Colors.white,
                            Colors.white,
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.03, 0.97, 1.0],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstIn,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: visibleData.map((data) {
                          final double delta = data.delta;
                          final double absDelta = data.absDelta;
                          final double focusWeight = data.focusWeight;
                          final card = data.card;

                          final double xOffset =
                              spacingRadius * math.sin(delta * angleStep);
                          final double rotateY =
                              (-delta * 0.32).clamp(-0.85, 0.85);

                          final double baseScale;
                          if (absDelta <= 1.0) {
                            baseScale = 0.85 +
                                0.15 * math.cos(absDelta * (math.pi / 2.0));
                          } else {
                            baseScale = (0.85 - ((absDelta - 1.0) * 0.10))
                                .clamp(0.60, 0.85);
                          }

                          final double scale = (baseScale * transitionScaleDip)
                              .clamp(0.56, 1.0);

                          final double opacity = absDelta < 0.35
                              ? 1.0
                              : (math.pow(0.55, absDelta).toDouble())
                                  .clamp(0.20, 1.0);

                          return Center(
                            key: ValueKey('pricing_mobile_${card.name}'),
                            child: Transform.translate(
                              offset: Offset(xOffset, 0),
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(rotateY),
                                child: Transform.scale(
                                  scale: scale,
                                  child: Opacity(
                                    opacity: opacity,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        if (absDelta > 0.35) {
                                          _animateToOffset(
                                              _scrollOffset + delta);
                                        }
                                      },
                                      child: card.copyWith(
                                        isMobile: true,
                                        focusWeight: focusWeight,
                                        width: cardWidth,
                                        height: cardHeight,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 18),

        // Centered Glowing Indicator Dots
        AnimatedBuilder(
          animation: _animController,
          builder: (context, _) {
            final double currentOffset = _animController.isAnimating
                ? (_scrollAnimation?.value ?? _scrollOffset)
                : _scrollOffset;
            final int activeIndex =
                (currentOffset.round() % cards.length + cards.length) %
                    cards.length;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(cards.length, (index) {
                final isSelected = activeIndex == index;
                final color = cards[index].accentColor;

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    final double delta =
                        _getCircularDelta(index, currentOffset, cards.length);
                    _animateToOffset(_scrollOffset + delta);
                    _startAutoSlideTimer();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      width: isSelected ? 24 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color
                            : Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.70),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}

class _PricingCard extends StatefulWidget {
  final String name;
  final String price;
  final String billingCycle;
  final String? originalPrice;
  final String description;
  final List<String> features;
  final String buttonText;
  final bool isPopular;
  final Color accentColor;
  final bool isMobile;
  final double focusWeight;
  final double? width;
  final double? height;

  const _PricingCard({
    super.key,
    required this.name,
    required this.price,
    required this.billingCycle,
    this.originalPrice,
    required this.description,
    required this.features,
    required this.buttonText,
    this.isPopular = false,
    required this.accentColor,
    this.isMobile = false,
    this.focusWeight = 1.0,
    this.width,
    this.height,
  });

  _PricingCard copyWith({
    bool? isMobile,
    double? focusWeight,
    double? width,
    double? height,
  }) {
    return _PricingCard(
      key: key,
      name: name,
      price: price,
      billingCycle: billingCycle,
      originalPrice: originalPrice,
      description: description,
      features: features,
      buttonText: buttonText,
      isPopular: isPopular,
      accentColor: accentColor,
      isMobile: isMobile ?? this.isMobile,
      focusWeight: focusWeight ?? this.focusWeight,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  @override
  State<_PricingCard> createState() => _PricingCardState();
}

class _PricingCardState extends State<_PricingCard> {
  bool _isCardHovered = false;

  @override
  Widget build(BuildContext context) {
    final color =
        widget.isPopular ? const Color(0xFF3B82F6) : widget.accentColor;

    if (!widget.isMobile) {
      // Desktop Row Card with smooth interactive hover zoom & elevation lift
      return MouseRegion(
        onEnter: (_) => setState(() => _isCardHovered = true),
        onExit: (_) => setState(() => _isCardHovered = false),
        child: AnimatedScale(
          scale: _isCardHovered ? 1.025 : 1.0,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(
              0,
              _isCardHovered ? -6.0 : 0.0,
              0,
            ),
            decoration: BoxDecoration(
              color: widget.isPopular
                  ? (_isCardHovered
                      ? const Color(0xFF141938)
                      : const Color(0xFF0F132C))
                  : (_isCardHovered
                      ? const Color(0xFF10142A)
                      : const Color(0xDD0A0D1D)),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.isPopular
                    ? (_isCardHovered
                        ? const Color(0xFF60A5FA)
                        : const Color(0xFF3B82F6).withValues(alpha: 0.6))
                    : (_isCardHovered
                        ? color.withValues(alpha: 0.50)
                        : Colors.white.withValues(alpha: 0.09)),
                width: widget.isPopular ? 1.8 : (_isCardHovered ? 1.5 : 1.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: _isCardHovered ? 0.65 : 0.45,
                  ),
                  blurRadius: _isCardHovered ? 36 : 22,
                  offset: Offset(0, _isCardHovered ? 14 : 8),
                ),
                if (widget.isPopular || _isCardHovered)
                  BoxShadow(
                    color: color.withValues(
                      alpha: widget.isPopular
                          ? (_isCardHovered ? 0.35 : 0.22)
                          : (_isCardHovered ? 0.25 : 0.0),
                    ),
                    blurRadius: _isCardHovered ? 40 : 28,
                    spreadRadius: _isCardHovered ? 2 : 0,
                  ),
              ],
            ),
            padding: const EdgeInsets.all(28),
            child: _buildCardContent(context, 1.0, false),
          ),
        ),
      );
    }

    // Mobile Slider Card with Center-Only Zoom & Focus Interpolation
    final bool isMidCard = widget.focusWeight > 0.70;
    final bool isZoomed = isMidCard && _isCardHovered;
    final double w = isMidCard
        ? math.max(widget.focusWeight, _isCardHovered ? 1.0 : 0.0)
        : widget.focusWeight;

    return MouseRegion(
      onEnter: (_) => setState(() => _isCardHovered = true),
      onExit: (_) => setState(() => _isCardHovered = false),
      child: AnimatedScale(
        scale: isZoomed ? 1.035 : 1.0,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: widget.width ?? 350,
          height: widget.height ?? 690,
          transform: Matrix4.translationValues(
            0,
            -6.0 * w + (isZoomed ? -4.0 : 0.0),
            0,
          ),
          decoration: BoxDecoration(
            color: Color.lerp(
              const Color(0xDD0A0D1D),
              widget.isPopular
                  ? const Color(0xF00F132C)
                  : const Color(0xF20B0E20),
              w,
            )!,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Color.lerp(
                Colors.white.withValues(alpha: 0.09),
                widget.isPopular
                    ? const Color(0xFF60A5FA)
                    : color.withValues(alpha: 0.65),
                w,
              )!,
              width: widget.isPopular ? 1.8 : (1.2 + 0.4 * w),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.35 + 0.30 * w + (isZoomed ? 0.15 : 0.0),
                ),
                blurRadius: 18 + 18 * w + (isZoomed ? 10 : 0),
                offset: Offset(0, 8 + 6 * w),
              ),
              if (w > 0.1 || isZoomed)
                BoxShadow(
                  color: color.withValues(
                    alpha: isZoomed ? 0.35 : (0.24 * w),
                  ),
                  blurRadius: 24 + 18 * w,
                  spreadRadius: isZoomed ? 1 : 0,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildCardContent(context, w, true),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, double w, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isPopular)
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
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
                  Icon(Icons.auto_awesome_rounded,
                      size: 12, color: Colors.white),
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
          widget.name,
          style: TextStyle(
            color: widget.isPopular
                ? const Color(0xFF60A5FA)
                : const Color(0xFFF1F5F9),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              widget.price,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                widget.billingCycle,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        if (widget.originalPrice != null) ...[
          const SizedBox(height: 2),
          Text(
            'Regular ${widget.originalPrice}',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
        const SizedBox(height: 10),
        Text(
          widget.description,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 16),
        Divider(color: Colors.white.withValues(alpha: 0.08)),
        const SizedBox(height: 16),
        ...widget.features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 9.5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: widget.isPopular
                          ? const Color(0xFF00F5D4).withValues(alpha: 0.18)
                          : Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: widget.isPopular
                          ? const Color(0xFF00F5D4)
                          : Colors.white70,
                      size: 11,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      f,
                      style: const TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            )),
        const Spacer(),
        const SizedBox(height: 12),
        if (widget.isPopular)
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
                      widget.buttonText,
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
              child: Text(widget.buttonText),
            ),
          ),
      ],
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
