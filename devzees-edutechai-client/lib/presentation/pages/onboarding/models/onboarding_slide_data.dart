import 'package:flutter/material.dart';

/// Data model for a single onboarding slide.
class OnboardingSlideData {
  final String eyebrow;
  final String titleLine1;
  final String titleLine2Gradient;
  final String subtitle;
  final String imagePath;
  final String featureTitle;
  final String featureDesc;
  final IconData featureIcon;

  const OnboardingSlideData({
    required this.eyebrow,
    required this.titleLine1,
    required this.titleLine2Gradient,
    required this.subtitle,
    required this.imagePath,
    required this.featureTitle,
    required this.featureDesc,
    required this.featureIcon,
  });

  /// The three onboarding slides matching the reference designs.
  static const List<OnboardingSlideData> slides = [
    // ── Slide 1: Socratic Tutoring ──
    OnboardingSlideData(
      eyebrow: 'LEARN DIFFERENTLY',
      titleLine1: 'Your Curiosity,',
      titleLine2Gradient: 'Our AI Tutor',
      subtitle:
          'Get Socratic guidance, not direct answers. We help you think, explore and truly understand.',
      imagePath: 'assets/images/onboarding/slide_1.jpg',
      featureTitle: 'Socratic Tutoring',
      featureDesc: 'Guiding questions, everyday analogies, real understanding.',
      featureIcon: Icons.psychology_rounded,
    ),
    // ── Slide 2: Powerful Learning Tools ──
    OnboardingSlideData(
      eyebrow: 'EXPLORE MORE',
      titleLine1: 'Everything You Need,',
      titleLine2Gradient: 'In One Place',
      subtitle:
          'From videos to research papers, quizzes to gamification — all the tools you need for deeper, smarter learning.',
      imagePath: 'assets/images/onboarding/slide_2.jpg',
      featureTitle: 'Powerful Learning Tools',
      featureDesc:
          'Videos, research, quizzes, gamification and 3 learning modes — all in one.',
      featureIcon: Icons.grid_view_rounded,
    ),
    // ── Slide 3: Track & Achieve ──
    OnboardingSlideData(
      eyebrow: 'YOUR JOURNEY',
      titleLine1: 'Learn, Grow,',
      titleLine2Gradient: 'Achieve',
      subtitle:
          'Track your progress, unlock rewards, export your sessions and keep learning at your own pace.',
      imagePath: 'assets/images/onboarding/slide_3.jpg',
      featureTitle: 'Track & Achieve',
      featureDesc:
          'Earn XP, maintain streaks, export sessions and reach your goals.',
      featureIcon: Icons.emoji_events_rounded,
    ),
  ];
}
