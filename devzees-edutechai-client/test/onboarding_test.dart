import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:devzees_edutechai_client/core/providers/onboarding_provider.dart';
import 'package:devzees_edutechai_client/presentation/pages/onboarding/models/onboarding_slide_data.dart';
import 'package:devzees_edutechai_client/presentation/pages/onboarding/widgets/onboarding_dots_indicator.dart';
import 'package:devzees_edutechai_client/presentation/pages/onboarding/widgets/onboarding_feature_card.dart';
import 'package:devzees_edutechai_client/presentation/pages/onboarding/widgets/onboarding_gradient_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnboardingSlideData Tests', () {
    test('contains exactly 3 slides matching requirements', () {
      expect(OnboardingSlideData.slides.length, 3);
    });

    test('Slide 1: Socratic Tutoring contents', () {
      final slide1 = OnboardingSlideData.slides[0];
      expect(slide1.eyebrow, 'LEARN DIFFERENTLY');
      expect(slide1.titleLine1, 'Your Curiosity,');
      expect(slide1.titleLine2Gradient, 'Our AI Tutor');
      expect(slide1.featureTitle, 'Socratic Tutoring');
      expect(slide1.imagePath, 'assets/images/onboarding/slide_1.jpg');
    });

    test('Slide 2: Powerful Learning Tools contents', () {
      final slide2 = OnboardingSlideData.slides[1];
      expect(slide2.eyebrow, 'EXPLORE MORE');
      expect(slide2.titleLine1, 'Everything You Need,');
      expect(slide2.titleLine2Gradient, 'In One Place');
      expect(slide2.featureTitle, 'Powerful Learning Tools');
      expect(slide2.imagePath, 'assets/images/onboarding/slide_2.jpg');
    });

    test('Slide 3: Track & Achieve contents', () {
      final slide3 = OnboardingSlideData.slides[2];
      expect(slide3.eyebrow, 'YOUR JOURNEY');
      expect(slide3.titleLine1, 'Learn, Grow,');
      expect(slide3.titleLine2Gradient, 'Achieve');
      expect(slide3.featureTitle, 'Track & Achieve');
      expect(slide3.imagePath, 'assets/images/onboarding/slide_3.jpg');
    });
  });

  group('OnboardingNotifier & Provider Tests', () {
    test('initial state is false when no flag in SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      expect(container.read(onboardingProvider), isFalse);
    });

    test('completeOnboarding sets flag and state to true', () async {
      SharedPreferences.setMockInitialValues({'hasSeenOnboarding': false});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      expect(container.read(onboardingProvider), isFalse);

      await container.read(onboardingProvider.notifier).completeOnboarding();

      expect(container.read(onboardingProvider), isTrue);
      expect(prefs.getBool('hasSeenOnboarding'), isTrue);

      // Reset
      await container.read(onboardingProvider.notifier).resetOnboarding();
      expect(container.read(onboardingProvider), isFalse);
      expect(prefs.getBool('hasSeenOnboarding'), isNull);
    });
  });

  group('Onboarding Widgets UI Tests', () {
    testWidgets('OnboardingDotsIndicator renders 3 dots with active one wider',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OnboardingDotsIndicator(currentPage: 0, totalPages: 3),
          ),
        ),
      );

      final row = find.byType(Row);
      expect(row, findsOneWidget);

      final containers = tester.widgetList<AnimatedContainer>(
        find.descendant(of: row, matching: find.byType(AnimatedContainer)),
      ).toList();

      expect(containers.length, 3);
      // Active dot (index 0) width is 24, inactive are 8
      expect(containers[0].constraints?.maxWidth ?? 24.0, 24.0);
      expect(containers[1].constraints?.maxWidth ?? 8.0, 8.0);
      expect(containers[2].constraints?.maxWidth ?? 8.0, 8.0);
    });

    testWidgets('OnboardingFeatureCard displays title, description and icon',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OnboardingFeatureCard(
              icon: Icons.psychology_rounded,
              title: 'Socratic Tutoring',
              description: 'Guiding questions, everyday analogies.',
            ),
          ),
        ),
      );

      expect(find.text('Socratic Tutoring'), findsOneWidget);
      expect(find.text('Guiding questions, everyday analogies.'), findsOneWidget);
      expect(find.byIcon(Icons.psychology_rounded), findsOneWidget);
    });

    testWidgets('OnboardingNextButton triggers callback on tap',
        (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingNextButton(onPressed: () => tapped = true),
          ),
        ),
      );

      expect(find.byType(OnboardingNextButton), findsOneWidget);
      await tester.tap(find.byType(OnboardingNextButton));
      expect(tapped, isTrue);
    });

    testWidgets('OnboardingGetStartedButton triggers callback on tap',
        (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingGetStartedButton(onPressed: () => tapped = true),
          ),
        ),
      );

      expect(find.text('Get Started'), findsOneWidget);
      await tester.tap(find.text('Get Started'));
      expect(tapped, isTrue);
    });
  });
}
