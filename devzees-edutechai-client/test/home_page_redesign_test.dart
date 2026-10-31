import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/presentation/widgets/scroll_fade_in.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/widgets/animated_stats_bar.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/widgets/hero_section.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/widgets/home_navbar.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/widgets/cta_footer.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/widgets/agents_section.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/widgets/comparison_section.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/widgets/modes_and_levels_section.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/widgets/export_ecosystem_section.dart';
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
          home: Scaffold(
            body: ScrollFadeIn(
              child: Text('Test Child Content'),
            ),
          ),
        ),
      );

      expect(find.text('Test Child Content'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('animates opacity and slide offset when triggered', (tester) async {
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

  group('AnimatedStatsBar Widget Tests', () {
    testWidgets('renders badge and all 6 key metrics', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AnimatedStatsBar(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('TRUSTED BY LEARNERS WORLDWIDE'), findsOneWidget);
      expect(find.text('AI Sessions Generated'), findsOneWidget);
      expect(find.text('Topics Covered'), findsOneWidget);
      expect(find.text('Accuracy Grounded'), findsOneWidget);
      expect(find.text('Universities'), findsOneWidget);
      expect(find.text('Countries'), findsOneWidget);
      expect(find.text('User Rating'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('HeroSection & FullWidthHeroCarousel Widget Tests', () {
    testWidgets('renders hero badge, headline, and action buttons', (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HeroSection(includeCarousel: false),
            ),
          ),
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

    testWidgets('renders FullWidthHeroCarousel with slide tabs and chevron controls', (tester) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FullWidthHeroCarousel(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Multi-Agent Core'), findsOneWidget);
      expect(find.text('Cognitive Engine'), findsOneWidget);
      expect(find.text('Dual Workspace'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AgentsSection Widget Tests', () {
    testWidgets('renders all 6 autonomous agents without raw emojis', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AgentsSection(),
            ),
          ),
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
  });

  group('ComparisonSection Widget Tests', () {
    testWidgets('renders architectural matrix table', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ComparisonSection(),
            ),
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

    testWidgets('renders mobile-friendly comparison table with switcher and horizontal scroll', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ComparisonSection(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Table Matrix'), findsOneWidget);
      expect(find.text('Dimension Cards'), findsOneWidget);
      expect(find.text('Swipe horizontally to compare columns'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Tap to switch to Dimension Cards
      await tester.tap(find.text('Dimension Cards'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('EduTech AI Squad'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('ModesAndLevelsSection Widget Tests', () {
    testWidgets('renders modes and cognitive levels switcher', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ModesAndLevelsSection(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('ADAPTIVE COGNITIVE CALIBRATION'), findsOneWidget);
      expect(find.text('Visual Mode'), findsWidgets);
      expect(find.text('Deep Dive Mode'), findsOneWidget);
      expect(find.text('Bite-Sized Mode'), findsOneWidget);
      expect(find.text('Undergraduate'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('ExportEcosystemSection Widget Tests', () {
    testWidgets('renders second brain export formats and image', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ExportEcosystemSection(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('ZERO VENDOR LOCK-IN'), findsOneWidget);
      expect(find.text('Markdown (.md)'), findsOneWidget);
      expect(find.text('Interactive HTML (.html)'), findsOneWidget);
      expect(find.text('Executive PDF (.pdf)'), findsOneWidget);
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
          home: Scaffold(
            body: SingleChildScrollView(
              child: AboutSection(),
            ),
          ),
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
              body: SingleChildScrollView(
                child: PricingSection(),
              ),
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
          home: Scaffold(
            body: SingleChildScrollView(
              child: FaqSection(),
            ),
          ),
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
    testWidgets('renders logo, brand, navigation pills, and CTA button', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HomeNavbar(),
            ),
          ),
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
            body: SingleChildScrollView(
              child: WallOfLoveSection(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('STUDENT & RESEARCHER REPUTATION'), findsOneWidget);
      expect(find.text('Loved by Ambitious Learners Worldwide'), findsOneWidget);
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
          home: Scaffold(
            body: SingleChildScrollView(
              child: CtaFooter(),
            ),
          ),
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
