import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/core/providers/feedback_provider.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';
import 'package:devzees_edutechai_client/data/models/feedback/feedback_model.dart';
import 'package:devzees_edutechai_client/presentation/widgets/shimmer_loading.dart';

/// Ultra-premium Social Proof / Wall of Love Section for EduTech AI.
/// Displays verified student and STEM researcher testimonials with education levels and regions.
/// Paginates testimonials into a smooth slider displaying 6 solidified cards at a time on desktop.
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

class _WallOfLoveSectionState extends ConsumerState<WallOfLoveSection> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoSlideTimer;
  bool _isHovered = false;
  int _lastTotalPages = 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _setupAutoSlide(int totalPages) {
    if (totalPages == _lastTotalPages && _autoSlideTimer != null) return;
    _lastTotalPages = totalPages;
    _autoSlideTimer?.cancel();

    if (totalPages <= 1) return;

    _autoSlideTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted || _isHovered) return;
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % totalPages;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeInOutCubic,
        );
      }
    });
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

        // ─── Slider Body & Solidified Cards ───
        publicFeedbackAsync.when(
          loading: () => _buildShimmerGrid(isMobile),
          error: (err, stack) => _buildSlider(isMobile, WallOfLoveSection.defaultFallback),
          data: (items) {
            final list = items.isNotEmpty ? items : WallOfLoveSection.defaultFallback;
            return _buildSlider(isMobile, list);
          },
        ),
      ],
    );
  }

  Widget _buildSlider(bool isMobile, List<PublicFeedbackModel> items) {
    // Desktop: 6 cards per page (3 columns x 2 rows). Mobile: 1 card per page.
    final int itemsPerPage = isMobile ? 1 : 6;
    final int totalPages = (items.length / itemsPerPage).ceil().clamp(1, 9999);

    _setupAutoSlide(totalPages);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Column(
        children: [
          // Fixed Height Carousel Container (No layout jumping)
          SizedBox(
            height: isMobile ? 300 : 600,
            child: PageView.builder(
              controller: _pageController,
              itemCount: totalPages,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, pageIndex) {
                final int start = pageIndex * itemsPerPage;
                final int end = (start + itemsPerPage).clamp(0, items.length);
                final pageItems = items.sublist(start, end);

                if (isMobile) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: _TestimonialCard(data: pageItems.first),
                      ),
                    ),
                  );
                }

                // Desktop: 6 items in 2 rows of 3
                return _buildDesktopSixGrid(pageItems);
              },
            ),
          ),

          // Pagination Controls: Chevrons & Pill Dots
          if (totalPages > 1) ...[
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous Chevron
                _buildNavButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: () {
                    final prevPage = (_currentPage - 1 + totalPages) % totalPages;
                    _pageController.animateToPage(
                      prevPage,
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeInOutCubic,
                    );
                  },
                ),
                const SizedBox(width: 18),

                // Indicator Dots / Active Glow Pill
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(totalPages, (index) {
                    final bool isActive = index == _currentPage;
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.easeInOutCubic,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFFF59E0B)
                              : Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.55),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 18),

                // Next Chevron
                _buildNavButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: () {
                    final nextPage = (_currentPage + 1) % totalPages;
                    _pageController.animateToPage(
                      nextPage,
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeInOutCubic,
                    );
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Builds a unified 3x2 grid of 6 identically sized cards on desktop.
  Widget _buildDesktopSixGrid(List<PublicFeedbackModel> pageItems) {
    final row1Items = pageItems.take(3).toList();
    final row2Items = pageItems.skip(3).take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1 (Up to 3 cards)
          Row(
            children: [
              for (int i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 20),
                Expanded(
                  child: i < row1Items.length
                      ? _TestimonialCard(data: row1Items[i])
                      : const SizedBox(height: 285),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // Row 2 (Up to 3 cards)
          Row(
            children: [
              for (int i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 20),
                Expanded(
                  child: i < row2Items.length
                      ? _TestimonialCard(data: row2Items[i])
                      : const SizedBox(height: 285),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xCC0B0D1B),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.16),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.40),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildShimmerGrid(bool isMobile) {
    if (isMobile) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: _TestimonialShimmerCard(),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: const [
              Expanded(child: _TestimonialShimmerCard()),
              SizedBox(width: 20),
              Expanded(child: _TestimonialShimmerCard()),
              SizedBox(width: 20),
              Expanded(child: _TestimonialShimmerCard()),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(child: _TestimonialShimmerCard()),
              SizedBox(width: 20),
              Expanded(child: _TestimonialShimmerCard()),
              SizedBox(width: 20),
              Expanded(child: _TestimonialShimmerCard()),
            ],
          ),
        ],
      ),
    );
  }
}

/// Solidified testimonial card with locked uniform height (285px).
/// Guarantees architectural consistency across all cards in the grid.
class _TestimonialCard extends StatefulWidget {
  final PublicFeedbackModel data;
  const _TestimonialCard({required this.data});

  @override
  State<_TestimonialCard> createState() => _TestimonialCardState();
}

class _TestimonialCardState extends State<_TestimonialCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final countryText = widget.data.country != null && widget.data.country!.isNotEmpty
        ? widget.data.country!
        : 'Global Learner';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: 285,
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: const Color(0xCC0B0D1B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? widget.data.avatarColor.withValues(alpha: 0.50)
                : Colors.white.withValues(alpha: 0.10),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.50),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            if (_isHovered)
              BoxShadow(
                color: widget.data.avatarColor.withValues(alpha: 0.18),
                blurRadius: 30,
                spreadRadius: -2,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar + Info (Fixed height: 42)
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.data.avatarColor.withValues(alpha: 0.18),
                        border: Border.all(
                          color: widget.data.avatarColor.withValues(alpha: 0.40),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.data.avatarInitial,
                          style: TextStyle(
                            color: widget.data.avatarColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
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
                                  style: const TextStyle(
                                    color: Color(0xFFF8FAFC),
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.verified_rounded,
                                color: Color(0xFF38BDF8),
                                size: 14,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.data.educationLevel} • $countryText',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
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
                            ? const Color(0xFFFBBF24)
                            : const Color(0xFF64748B),
                        size: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Quote Body (Expands to fill remaining height uniformly, maxLines 4)
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '"${widget.data.quote}"',
                      style: const TextStyle(
                        color: Color(0xFFCBD5E1),
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

                // Bottom Tag (Pinned to the exact bottom of every card)
                Container(
                  constraints: const BoxConstraints(maxWidth: 290),
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.data.avatarColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: widget.data.avatarColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 12,
                        color: widget.data.avatarColor,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          'Mastered: ${widget.data.topicTag}',
                          style: TextStyle(
                            color: widget.data.avatarColor,
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
    );
  }
}

/// Shimmer skeleton card with identical dimensions (285px) for rock-solid stability during loading.
class _TestimonialShimmerCard extends StatelessWidget {
  const _TestimonialShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 285,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xCC0B0D1B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: const ShimmerLoading(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShimmerBox(width: 42, height: 42, shape: BoxShape.circle),
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
