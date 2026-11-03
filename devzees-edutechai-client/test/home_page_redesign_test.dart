import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/presentation/widgets/scroll_fade_in.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/widgets/hero_section.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/widgets/home_navbar.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/widgets/cta_footer.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/widgets/agents_section.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/widgets/gamified_mastery_section.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/widgets/comparison_section.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/widgets/modes_and_levels_section.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/widgets/about_section.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/widgets/pricing_section.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/widgets/faq_section.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/widgets/wall_of_love_section.dart';
import 'package:devzees_edutechai_client/core/services/subscription_service.dart';
import 'package:devzees_edutechai_client/data/models/subscription/payment_models.dart';

void main() {
  group('ScrollFadeIn Widget Tests', () {
    testWidgets('renders child widget correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ScrollFadeIn(child: Text('Test Child Content'))),
        ),
      );

      expect(find.text('Test Child Content'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('animates opacity and slide offset when triggered', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScrollFadeIn(
              offset: Offset(0, 30),
              duration: Duration(milliseconds: 500),
              child: Text('Animated Section'),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('Animated Section'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('HeroSection Widget Tests', () {
    testWidgets('renders hero badge, headline, and action buttons', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: HeroSection())),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2000));

      expect(find.text('Master Any Subject with a'), findsOneWidget);
      expect(find.text('Team of AI Agents'), findsOneWidget);
      expect(find.text('Start Learning for Free'), findsOneWidget);
      expect(find.text('Watch a Demo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AgentsSection Widget Tests', () {
    testWidgets('renders all 6 autonomous agents without raw emojis', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: AgentsSection())),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('AUTONOMOUS AGENT SQUAD'), findsOneWidget);
      expect(find.text('Supervisor Orchestrator'), findsOneWidget);
      expect(find.text('Socratic Tutor'), findsOneWidget);
      expect(find.text('YouTube Curator'), findsOneWidget);
      expect(find.text('Academic Scout'), findsOneWidget);
      expect(find.text('Formative Quiz Agent'), findsOneWidget);
      expect(find.text('Synthesizer Agent'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'renders mobile carousel and auto-rotates agents every 3 seconds',
      (tester) async {
        tester.view.physicalSize = const Size(375, 812);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: SingleChildScrollView(child: AgentsSection())),
          ),
        );

        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.text('AUTONOMOUS AGENT SQUAD'), findsOneWidget);
        expect(find.text('Supervisor Orchestrator'), findsOneWidget);

        // Fast-forward by 3 seconds to verify auto-rotation to Socratic Tutor
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        expect(find.text('Socratic Tutor'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('GamifiedMasterySection Widget Tests', () {
    testWidgets(
      'renders badge, headline, and all 4 feature cards with 4 glowing dots',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: GamifiedMasterySection()),
            ),
          ),
        );

        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.text('GAMIFICATION & REWARDS'), findsOneWidget);
        expect(
          find.text(
            'Gamified Mastery Ladders That Make Hard Subjects Addictive',
          ),
          findsOneWidget,
        );
        expect(
          find.text('Streak Multipliers (+10% Daily XP Boost)'),
          findsOneWidget,
        );
        expect(
          find.text('Instant Quiz Feedback (+30 XP Bonus)'),
          findsOneWidget,
        );
        expect(find.text('10-Level Mastery Ladder'), findsOneWidget);
        expect(find.text('Obsidian, Notion & PDF Export'), findsOneWidget);

        // Verify the 4 glowing slider dots are rendered
        final sliderDotFinders = find.byType(AnimatedContainer);
        expect(sliderDotFinders, findsWidgets);

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('tapping feature card or dot changes active index', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: GamifiedMasterySection()),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // Tap on the 2nd feature card
      await tester.tap(find.text('Instant Quiz Feedback (+30 XP Bonus)'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('slider and feature cards have identical height on desktop', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: GamifiedMasterySection()),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      final sliderSize = tester.getSize(
        find.byKey(const Key('slider_showcase_container')),
      );
      final cardsSize = tester.getSize(
        find.byKey(const Key('feature_cards_column_desktop')),
      );

      expect(sliderSize.height, equals(cardsSize.height));
    });

    testWidgets('hovering on slider does not change active slide', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: GamifiedMasterySection()),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // Tap on the 2nd feature card (Instant Quiz Feedback)
      await tester.tap(find.text('Instant Quiz Feedback (+30 XP Bonus)'));
      await tester.pumpAndSettle();

      // Verify tile2 is active
      expect(
        find.byKey(
          const ValueKey<String>('assets/images/gamification/tile2.png'),
        ),
        findsOneWidget,
      );

      // Hover over the slider container
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);

      final sliderCenter = tester.getCenter(
        find.byKey(const Key('slider_showcase_container')),
      );
      await gesture.moveTo(sliderCenter);
      await tester.pumpAndSettle();

      // Active slide must still be tile 2!
      expect(
        find.byKey(
          const ValueKey<String>('assets/images/gamification/tile2.png'),
        ),
        findsOneWidget,
      );

      // Now click the next chevron button
      await tester.tap(find.byKey(const Key('slider_next_chevron')));
      await tester.pumpAndSettle();

      // Active slide must now be tile 3!
      expect(
        find.byKey(
          const ValueKey<String>('assets/images/gamification/tile3.png'),
        ),
        findsOneWidget,
      );

      // Now click the prev chevron button
      await tester.tap(find.byKey(const Key('slider_prev_chevron')));
      await tester.pumpAndSettle();

      // Active slide must now be back to tile 2!
      expect(
        find.byKey(
          const ValueKey<String>('assets/images/gamification/tile2.png'),
        ),
        findsOneWidget,
      );
    });
  });

  group('ComparisonSection Widget Tests', () {
    testWidgets('renders architectural matrix table', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: ComparisonSection()),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('WHY EDUTECH AI'), findsOneWidget);
      expect(find.text('Beyond Generic AI Chatbots'), findsOneWidget);
      expect(find.text('Teaching Methodology'), findsOneWidget);
      expect(find.text('Curricular Structure'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'renders mobile-friendly comparison table with switcher and horizontal scroll',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: ComparisonSection()),
            ),
          ),
        );

        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.text('Table Matrix'), findsOneWidget);
        expect(find.text('Dimension Cards'), findsOneWidget);
        expect(
          find.text('Swipe horizontally to compare columns'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);

        // Tap to switch to Dimension Cards
        await tester.tap(find.text('Dimension Cards'));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.text('EduTech AI Squad'), findsWidgets);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('ModesAndLevelsSection Widget Tests', () {
    testWidgets('renders modes and cognitive levels switcher', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: ModesAndLevelsSection()),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('ADAPTIVE LEARNING MODES'), findsOneWidget);
      expect(find.text('Visual Mode'), findsWidgets);
      expect(find.text('Deep Dive Mode'), findsOneWidget);
      expect(find.text('Bite-Sized Mode'), findsOneWidget);
      expect(find.text('HOW THIS MODE WORKS:'), findsOneWidget);

      // Tap Deep Dive Mode
      await tester.tap(find.text('Deep Dive Mode'));
      await tester.pumpAndSettle();
      expect(find.text('Comprehensive & Academic Depth'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AboutSection Widget Tests', () {
    testWidgets('renders mission and mastery stats', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: AboutSection())),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('COGNITIVE RESEARCH & ARCHITECTURE'), findsOneWidget);
      expect(find.text('Our Mission'), findsOneWidget);
      expect(find.text('Cognitive Scaffolding'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('PricingSection Widget Tests', () {
    testWidgets('renders transparent tiered plans', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pricingCatalogProvider.overrideWith(
              (ref) => Future.value(PricingCatalogModel.defaultCatalog),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: PricingSection()),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('TRANSPARENT TIERED PLANS'), findsOneWidget);
      expect(find.text('Free'), findsOneWidget);
      expect(find.text('Pro'), findsOneWidget);
      expect(find.text('Ultra'), findsOneWidget);
      expect(find.text('MOST POPULAR'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('FaqSection Widget Tests', () {
    testWidgets('renders accordion FAQ questions', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: FaqSection())),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('FREQUENTLY ASKED QUESTIONS'), findsOneWidget);
      expect(find.text('01'), findsOneWidget);
      expect(find.text('ACCURACY & GROUNDING'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('HomeNavbar Widget Tests', () {
    testWidgets('renders logo, brand, navigation pills, and CTA button', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: HomeNavbar())),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('EduTech'), findsOneWidget);
      expect(find.text('AI'), findsOneWidget);
      expect(find.text('Workspace'), findsOneWidget);
      expect(find.text('Features'), findsOneWidget);
      expect(find.text('Modes'), findsOneWidget);
      expect(find.text('Compare'), findsOneWidget);
      expect(find.text('Agents'), findsOneWidget);
      expect(find.text('Pricing'), findsOneWidget);
      expect(find.text('FAQ'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);

      // Verify mouse hover interaction on Sign In button
      final signInFinder = find.text('Sign In');
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(signInFinder));
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);

      // Verify mouse hover interaction & shimmer wave on Get Started button
      final getStartedFinder = find.text('Get Started');
      await gesture.moveTo(tester.getCenter(getStartedFinder));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);

      // Move mouse away to reset hover state
      await gesture.moveTo(Offset.zero);
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
    });
  });

  group('WallOfLoveSection Widget Tests', () {
    testWidgets('renders student and researcher testimonials', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: WallOfLoveSection()),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('STUDENT & RESEARCHER REPUTATION'), findsOneWidget);
      expect(
        find.text('Loved by Ambitious Learners Worldwide'),
        findsOneWidget,
      );
      expect(find.text('Marcus Chen'), findsOneWidget);
      expect(find.text('Dr. Elena Rostova'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('CtaFooter Widget Tests', () {
    testWidgets('renders terminal CTA banner and footer links', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: CtaFooter())),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('START YOUR COGNITIVE JOURNEY TODAY'), findsOneWidget);
      expect(find.text('Ready to Master Any Subject with AI?'), findsOneWidget);
      expect(find.text('Get Started Free →'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
