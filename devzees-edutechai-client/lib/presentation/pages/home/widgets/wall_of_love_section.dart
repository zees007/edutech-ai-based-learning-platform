import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/core/providers/feedback_provider.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';
import 'package:devzees_edutechai_client/data/models/feedback/feedback_model.dart';
import 'package:devzees_edutechai_client/presentation/widgets/shimmer_loading.dart';

/// Ultra-premium 3D Spatial Cylindrical Wheel Carousel
/// modeled after Alex Tkachev's Felix Koenig animation with luxury easing
/// and unified continuous scale up/down breathing transitions.
class WallOfLoveSection extends ConsumerStatefulWidget {
  const WallOfLoveSection({super.key});

  /// Default fallback testimonials used while loading or in offline/test environments.
  static final List<PublicFeedbackModel> defaultFallback = [
    const PublicFeedbackModel(
      feedbackId: 'default_1',
      name: 'Marcus Chen',
      educationLevel: 'Undergraduate',
      country: 'United States',
      avatarColor: Color(0xFF2B68F6),
      quote:
          'ChatGPT kept giving me walls of text that felt convincing until I tried solving the problem set. EduTech AI\'s Socratic Tutor broke the Hamiltonian down into progressive hints that forced me to derive the proof myself.',
      topicTag: 'Quantum Mechanics & Schrodinger Equation',
      avatarInitial: 'MC',
      rating: 5,
    ),
    const PublicFeedbackModel(
      feedbackId: 'default_2',
      name: 'Dr. Elena Rostova',
      educationLevel: 'Postdoctoral',
      country: 'Germany',
      avatarColor: Color(0xFF10B981),
      quote:
          'The vector video deep-linking and direct arXiv citations save me 15+ hours weekly. Instead of scrubbing 2-hour lectures, it drops me at the exact 90-second segment where the mathematical mechanism is animated.',
      topicTag: 'CRISPR-Cas9 Gene Editing Mechanisms',
      avatarInitial: 'ER',
      rating: 5,
    ),
    const PublicFeedbackModel(
      feedbackId: 'default_3',
      name: 'Priya Sharma',
      educationLevel: 'Graduate',
      country: 'United Kingdom',
      avatarColor: Color(0xFF8B5CF6),
      quote:
          'Exporting my masterclasses directly into Obsidian with native Mermaid.js flowcharts and LaTeX formulas is game-changing. My entire second brain is structured with zero manual copy-pasting.',
      topicTag: 'Organic Chemistry Reaction Mechanisms',
      avatarInitial: 'PS',
      rating: 5,
    ),
    const PublicFeedbackModel(
      feedbackId: 'default_4',
      name: 'David Kim',
      educationLevel: 'Graduate',
      country: 'Canada',
      avatarColor: Color(0xFFF59E0B),
      quote:
          'Bite-Sized mode is my secret weapon. In 10 minutes over coffee, I get a clear mental model of complex distributed consensus algorithms like Raft and Paxos without fluffy jargon.',
      topicTag: 'Distributed Systems & Raft Consensus Algorithm',
      avatarInitial: 'DK',
      rating: 5,
    ),
    const PublicFeedbackModel(
      feedbackId: 'default_5',
      name: 'Sofia Al-Mansoor',
      educationLevel: 'High School',
      country: 'United Arab Emirates',
      avatarColor: Color(0xFF00F5D4),
      quote:
          'Switching from High School to Undergraduate level on the fly is incredible. Whenever a concept feels too simple, I bump the cognitive slider and immediately get deeper mathematical rigor.',
      topicTag: 'Linear Algebra & Matrix Transformations',
      avatarInitial: 'SA',
      rating: 5,
    ),
    const PublicFeedbackModel(
      feedbackId: 'default_6',
      name: 'Lucas Vance',
      educationLevel: 'Undergraduate',
      country: 'Australia',
      avatarColor: Color(0xFFEC4899),
      quote:
          'The formative quizzes are actually grounded in what I just learned—zero hallucinations, no irrelevant trivia. And the streak tracking genuinely keeps me accountable every single day.',
      topicTag: 'Causal Inference & Econometrics',
      avatarInitial: 'LV',
      rating: 5,
    ),
  ];

  @override
  ConsumerState<WallOfLoveSection> createState() => _WallOfLoveSectionState();
}

class _CardRenderData {
  final int index;
  final PublicFeedbackModel item;
  final double delta;
  final double absDelta;
  final double focusWeight;

  const _CardRenderData({
    required this.index,
    required this.item,
    required this.delta,
    required this.absDelta,
    required this.focusWeight,
  });
}

class _WallOfLoveSectionState extends ConsumerState<WallOfLoveSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  Animation<double>? _scrollAnimation;

  double _scrollOffset = 0.0;
  Timer? _autoSlideTimer;
  bool _isHovered = false;
  int _lastItemCount = 0;

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
        setState(() {}); // Settle final state
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  /// Silky, luxurious cubic bezier curve with gentle onset and majestic feathered settling.
  void _animateToOffset(
    double targetOffset, {
    Duration duration = const Duration(milliseconds: 1150),
    Curve curve = const Cubic(0.25, 0.1, 0.20, 1.0),
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

  void _setupAutoSlide(int itemCount) {
    if (itemCount == _lastItemCount && _autoSlideTimer != null) return;
    _lastItemCount = itemCount;
    _autoSlideTimer?.cancel();

    if (itemCount <= 1) return;

    _autoSlideTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted || _isHovered || _animController.isAnimating) return;
      _animateToOffset((_scrollOffset.round() + 1).toDouble());
    });
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
    final publicFeedbackAsync = ref.watch(publicTestimonialsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ─── Section Header Badge ───
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xCC090B18),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.16),
                blurRadius: 18,
                spreadRadius: -2,
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
                  color: Color(0xFFF59E0B),
                  boxShadow: [
                    BoxShadow(color: Color(0xFFF59E0B), blurRadius: 6),
                  ],
                ),
              ),
              const SizedBox(width: 9),
              const Text(
                'STUDENT & RESEARCHER REPUTATION',
                style: TextStyle(
                  color: Color(0xFFFDE68A),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        GradientText(
          'Loved by Ambitious Learners Worldwide',
          style: (isMobile ? AppTextStyles.h3 : AppTextStyles.h2).copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1.0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            'From undergraduates mastering quantum algorithms to researchers exploring CRISPR mechanisms—see why serious learners choose our autonomous cognitive squad over generic chatbots.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1.copyWith(
              color: const Color(0xFF94A3B8),
              fontSize: isMobile ? 14.5 : 16.5,
              height: 1.60,
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(height: 48),

        // ─── 3D Cylindrical Wheel Carousel ───
        publicFeedbackAsync.when(
          loading: () => _buildShimmerWheel(context, isMobile),
          error: (err, stack) => _build3dCylindricalWheel(WallOfLoveSection.defaultFallback),
          data: (items) {
            final list = items.isNotEmpty ? items : WallOfLoveSection.defaultFallback;
            return _build3dCylindricalWheel(list);
          },
        ),
      ],
    );
  }

  Widget _build3dCylindricalWheel(List<PublicFeedbackModel> items) {
    _setupAutoSlide(items.length);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Column(
        children: [
          // ─── 3D Wheel Stage Area ───
          SizedBox(
            height: 380,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double viewportWidth = constraints.maxWidth;

                // Responsive cylindrical geometry parameters:
                final double maxVisibleDelta;
                final double spacingRadius;
                final double angleStep;

                if (viewportWidth >= 1200) {
                  maxVisibleDelta = 3.5;
                  spacingRadius = 880.0;
                  angleStep = 0.40;
                } else if (viewportWidth >= 800) {
                  maxVisibleDelta = 2.5;
                  spacingRadius = 600.0;
                  angleStep = 0.44;
                } else {
                  // Only one card visible at rest on mobile view
                  maxVisibleDelta = 0.85;
                  spacingRadius = viewportWidth * 0.90;
                  angleStep = 0.50;
                }

                final double cardWidth = math.min(viewportWidth - 32.0, 370.0);

                return AnimatedBuilder(
                  animation: _animController,
                  builder: (context, _) {
                    final double currentOffset = _animController.isAnimating
                        ? (_scrollAnimation?.value ?? _scrollOffset)
                        : _scrollOffset;

                    // Transition progress factor between integer cards [0.0 .. 0.5]
                    final double fractionalShift = (currentOffset - currentOffset.round()).abs();
                    // Bell-curve motion factor peaking at midpoint of slide change:
                    final double transitionFactor = math.sin(fractionalShift * math.pi);
                    // Dynamic scale compression dip (-6.5%) during active sliding
                    final double transitionScaleDip = 1.0 - (transitionFactor * 0.065);

                    // Compute exact relative offset and continuous focus weight for each item
                    final visibleData = <_CardRenderData>[];
                    for (int i = 0; i < items.length; i++) {
                      final double delta = _getCircularDelta(i, currentOffset, items.length);
                      final double absDelta = delta.abs();
                      if (absDelta <= maxVisibleDelta) {
                        // Smooth cubic Hermite focus interpolation (0.0 background -> 1.0 center hero)
                        final double clamped = absDelta.clamp(0.0, 0.85);
                        final double t = (0.85 - clamped) / 0.85;
                        final double focusWeight = t * t * (3.0 - 2.0 * t);

                        visibleData.add(_CardRenderData(
                          index: i,
                          item: items[i],
                          delta: delta,
                          absDelta: absDelta,
                          focusWeight: focusWeight,
                        ));
                      }
                    }

                    // CRITICAL 3D DEPTH SORTING:
                    // Sort by absolute distance from center descending.
                    // Cards furthest in background (largest absDelta) are added FIRST,
                    // and the active center hero card (absDelta ~ 0) is added LAST.
                    visibleData.sort((a, b) => b.absDelta.compareTo(a.absDelta));

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragStart: (_) {
                        _animController.stop();
                      },
                      onHorizontalDragUpdate: (details) {
                        final double sensitivity = viewportWidth >= 800 ? 300.0 : 220.0;
                        setState(() {
                          _scrollOffset -= details.primaryDelta! / sensitivity;
                        });
                      },
                      onHorizontalDragEnd: (details) {
                        final velocity = details.primaryVelocity ?? 0.0;
                        double target = _scrollOffset;
                        if (velocity.abs() > 300) {
                          target += velocity > 0 ? -1.0 : 1.0;
                        }
                        _animateToOffset(target.roundToDouble());
                      },
                      child: ShaderMask(
                        // Soft vignette fadeout at left and right edges matching reference image
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
                            stops: [0.0, 0.05, 0.95, 1.0],
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.dstIn,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: visibleData.map((data) {
                            final double delta = data.delta;
                            final double absDelta = data.absDelta;
                            final double focusWeight = data.focusWeight;
                            final item = data.item;

                            // 3D Cylindrical physics calculations:
                            // Horizontal displacement along cylindrical curve with generous spacing
                            final double xOffset = spacingRadius * math.sin(delta * angleStep);

                            // Y-axis perspective rotation: cards on left face right, cards on right face left
                            final double rotateY = (-delta * 0.36).clamp(-0.85, 0.85);

                            // Base spatial scale along the 3D cylinder:
                            // Center card has a cosine crown at 1.0, scaling smoothly down to flanks
                            final double baseScale;
                            if (absDelta <= 1.0) {
                              baseScale = 0.85 + 0.15 * math.cos(absDelta * (math.pi / 2.0));
                            } else {
                              baseScale = (0.85 - ((absDelta - 1.0) * 0.10)).clamp(0.60, 0.85);
                            }

                            // Final scale: dynamic scale down during change, blooming scale up when locking into center
                            final double scale = (baseScale * transitionScaleDip).clamp(0.56, 1.0);

                            // Pronounced depth translucency falloff:
                            // Center card is 100% solid, while behind cards fade into the background
                            final double opacity = absDelta < 0.35
                                ? 1.0
                                : (math.pow(0.50, absDelta).toDouble()).clamp(0.12, 1.0);

                            return Center(
                              key: ValueKey('testimonial_card_${item.feedbackId}'),
                              child: Transform.translate(
                                offset: Offset(xOffset, 0),
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001) // Camera perspective
                                    ..rotateY(rotateY),
                                  child: Transform.scale(
                                    scale: scale,
                                    child: Opacity(
                                      opacity: opacity,
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          if (absDelta > 0.35) {
                                            _animateToOffset(_scrollOffset + delta);
                                          }
                                        },
                                        child: _TestimonialCard(
                                          data: item,
                                          focusWeight: focusWeight,
                                          cardWidth: cardWidth,
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
        ],
      ),
    );
  }

  Widget _buildShimmerWheel(BuildContext context, bool isMobile) {
    return SizedBox(
      height: 380,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _TestimonialShimmerCard(),
              SizedBox(width: 20),
              _TestimonialShimmerCard(),
              SizedBox(width: 20),
              _TestimonialShimmerCard(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Solidified testimonial card with locked uniform dimensions (370px x 290px).
/// Features unified continuous frame-by-frame focus weight interpolation.
class _TestimonialCard extends StatefulWidget {
  final PublicFeedbackModel data;
  final double focusWeight;
  final double? cardWidth;

  const _TestimonialCard({
    required this.data,
    this.focusWeight = 1.0,
    this.cardWidth,
  });

  @override
  State<_TestimonialCard> createState() => _TestimonialCardState();
}

class _TestimonialCardState extends State<_TestimonialCard> {
  bool _isCardHovered = false;

  @override
  Widget build(BuildContext context) {
    final countryText = widget.data.country != null && widget.data.country!.isNotEmpty
        ? widget.data.country!
        : 'Global Learner';

    // Only the mid/center card on focus qualifies for hover zoom and highlight
    final bool isMidCard = widget.focusWeight > 0.70;
    final bool isZoomed = isMidCard && _isCardHovered;
    final double w = isMidCard
        ? math.max(widget.focusWeight, _isCardHovered ? 1.0 : 0.0)
        : widget.focusWeight;

    return MouseRegion(
      onEnter: (_) => setState(() => _isCardHovered = true),
      onExit: (_) => setState(() => _isCardHovered = false),
      child: AnimatedScale(
        scale: isZoomed ? 1.045 : 1.0,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: widget.cardWidth ?? 370,
          height: 290,
          transform: Matrix4.translationValues(
            0,
            -6.0 * w + (isZoomed ? -4.0 : 0.0),
            0,
          ),
          decoration: BoxDecoration(
            color: Color.lerp(
              const Color(0x66080A16),
              const Color(0xF20B0D1E),
              w,
            )!,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Color.lerp(
                Colors.white.withValues(alpha: 0.08),
                widget.data.avatarColor.withValues(alpha: 0.70),
                w,
              )!,
              width: 1.0 + 0.5 * w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.30 + 0.35 * w + (isZoomed ? 0.15 : 0.0),
                ),
                blurRadius: 14 + 16 * w + (isZoomed ? 8 : 0),
                offset: Offset(0, 6 + 4 * w),
              ),
              if (w > 0.05 || isZoomed)
                BoxShadow(
                  color: widget.data.avatarColor.withValues(
                    alpha: isZoomed ? 0.38 : (0.30 * w),
                  ),
                  blurRadius: 20 + 18 * w + (isZoomed ? 10 : 0),
                  spreadRadius: isZoomed ? 0 : -2,
                ),
            ],
          ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar + Info (Fixed height: 44)
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.data.avatarColor.withValues(alpha: 0.12 + 0.10 * w),
                        border: Border.all(
                          color: widget.data.avatarColor.withValues(alpha: 0.30 + 0.35 * w),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.data.avatarInitial,
                          style: TextStyle(
                            color: widget.data.avatarColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  widget.data.name,
                                  style: TextStyle(
                                    color: Color.lerp(
                                      const Color(0xFFCBD5E1),
                                      const Color(0xFFF8FAFC),
                                      w,
                                    ),
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.verified_rounded,
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.50 + 0.50 * w),
                                size: 14,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.data.educationLevel} • $countryText',
                            style: TextStyle(
                              color: Color.lerp(
                                const Color(0xFF64748B),
                                const Color(0xFF94A3B8),
                                w,
                              ),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Stars Row (Fixed height: 16)
                Row(
                  children: List.generate(
                    5,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 3),
                      child: Icon(
                        index < widget.data.rating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: index < widget.data.rating
                            ? Color.lerp(
                                const Color(0x99FBBF24),
                                const Color(0xFFFBBF24),
                                w,
                              )
                            : const Color(0xFF475569),
                        size: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Quote Body (Expanded uniformly, maxLines 4)
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '"${widget.data.quote}"',
                      style: TextStyle(
                        color: Color.lerp(
                          const Color(0xFF94A3B8),
                          const Color(0xFFF1F5F9),
                          w,
                        ),
                        fontSize: 13,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Bottom Tag (Pinned to the exact bottom line)
                Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: widget.data.avatarColor.withValues(alpha: 0.06 + 0.10 * w),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: widget.data.avatarColor.withValues(alpha: 0.14 + 0.18 * w),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 12,
                        color: widget.data.avatarColor.withValues(alpha: 0.60 + 0.40 * w),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          'Mastered: ${widget.data.topicTag}',
                          style: TextStyle(
                            color: widget.data.avatarColor.withValues(alpha: 0.70 + 0.30 * w),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  }
}

/// Shimmer skeleton card with identical dimensions (370px x 290px) for rock-solid stability during loading.
class _TestimonialShimmerCard extends StatelessWidget {
  const _TestimonialShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 370,
      height: 290,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xCC0B0D1B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: const ShimmerLoading(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShimmerBox(width: 44, height: 44, shape: BoxShape.circle),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 110, height: 14, borderRadius: BorderRadius.all(Radius.circular(4))),
                    SizedBox(height: 6),
                    ShimmerBox(width: 80, height: 10, borderRadius: BorderRadius.all(Radius.circular(4))),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            ShimmerBox(width: 90, height: 14, borderRadius: BorderRadius.all(Radius.circular(4))),
            SizedBox(height: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: double.infinity, height: 12, borderRadius: BorderRadius.all(Radius.circular(4))),
                  SizedBox(height: 6),
                  ShimmerBox(width: double.infinity, height: 12, borderRadius: BorderRadius.all(Radius.circular(4))),
                  SizedBox(height: 6),
                  ShimmerBox(width: 180, height: 12, borderRadius: BorderRadius.all(Radius.circular(4))),
                ],
              ),
            ),
            SizedBox(height: 10),
            ShimmerBox(width: 140, height: 22, borderRadius: BorderRadius.all(Radius.circular(6))),
          ],
        ),
      ),
    );
  }
}
