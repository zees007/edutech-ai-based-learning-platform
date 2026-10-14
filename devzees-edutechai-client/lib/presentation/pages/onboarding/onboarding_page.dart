import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:devzees_edutechai_client/core/providers/onboarding_provider.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';

import 'models/onboarding_slide_data.dart';
import 'widgets/onboarding_slide.dart';
import 'widgets/onboarding_feature_card.dart';
import 'widgets/onboarding_dots_indicator.dart';
import 'widgets/onboarding_gradient_button.dart';

/// Full-screen onboarding page with 3 swipeable carousel slides.
/// Shown only on mobile, only on first launch.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  int _currentPage = 0;

  // Staggered entrance animation controllers (one per slide)
  late final AnimationController _entranceController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    // Enforce dark palette for onboarding screens to ensure solid deep canvas
    AppColors.setBrightness(Brightness.dark);

    _pageController = PageController()
      ..addListener(() {
        final page = _pageController.page ?? 0;
        final rounded = page.round();
        if (rounded != _currentPage) {
          setState(() {
            _currentPage = rounded;
          });
        }
      });

    // Entrance animation for slide content
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeIn = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));

    _entranceController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < OnboardingSlideData.slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    await ref.read(onboardingProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final slides = OnboardingSlideData.slides;
    final isLastSlide = _currentPage == slides.length - 1;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SlideTransition(
            position: _slideUp,
            child: Column(
              children: [
                // ── Top Navigation Bar ──
                _buildTopNav(isLastSlide),

                // ── PageView Slides ──
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const ClampingScrollPhysics(),
                    itemCount: slides.length,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double pageOffset = 0.0;
                          if (_pageController.hasClients &&
                              _pageController.position.haveDimensions) {
                            pageOffset = (_pageController.page ?? 0) - index;
                          }
                          return OnboardingSlide(
                            data: slides[index],
                            pageOffset: pageOffset,
                          );
                        },
                      );
                    },
                  ),
                ),

                // ── Bottom Interactive Area ──
                _buildBottomArea(slides, isLastSlide, bottomPadding),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Top navigation bar: app logo + skip button.
  Widget _buildTopNav(bool isLastSlide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── App Logo (⚡ EduTech [AI]) ──
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '⚡ ',
                style: AppTextStyles.h4.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              GradientText(
                'EduTech',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'AI',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          // ── Skip Button (hidden on last slide) ──
          AnimatedOpacity(
            opacity: isLastSlide ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: isLastSlide ? null : _completeOnboarding,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom area: feature card, dots/buttons, and optional "have account" link.
  Widget _buildBottomArea(
    List<OnboardingSlideData> slides,
    bool isLastSlide,
    double bottomPadding,
  ) {
    final currentSlide = slides[_currentPage];

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Feature Card ──
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: OnboardingFeatureCard(
              key: ValueKey(currentSlide.featureTitle),
              icon: currentSlide.featureIcon,
              title: currentSlide.featureTitle,
              description: currentSlide.featureDesc,
            ),
          ),

          const SizedBox(height: 20),

          // ── Controls: Dots + Action Button / Get Started ──
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: isLastSlide
                ? _buildLastSlideControls()
                : _buildDotAndArrowControls(),
          ),
        ],
      ),
    );
  }

  /// Slides 1 & 2: pagination dots on the left, circular next button on the right.
  Widget _buildDotAndArrowControls() {
    return Padding(
      key: const ValueKey('dot-arrow-controls'),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OnboardingDotsIndicator(
            currentPage: _currentPage,
            totalPages: OnboardingSlideData.slides.length,
          ),
          OnboardingNextButton(onPressed: _goToNextPage),
        ],
      ),
    );
  }

  /// Slide 3: dots centered above the "Get Started" button + "I already have an account".
  Widget _buildLastSlideControls() {
    return Column(
      key: const ValueKey('last-slide-controls'),
      children: [
        // Centered dots
        OnboardingDotsIndicator(
          currentPage: _currentPage,
          totalPages: OnboardingSlideData.slides.length,
        ),
        const SizedBox(height: 16),
        // Full-width Get Started button
        OnboardingGetStartedButton(onPressed: _completeOnboarding),
        const SizedBox(height: 14),
        // "I already have an account" link
        GestureDetector(
          onTap: _completeOnboarding,
          child: Text(
            'I already have an account',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
