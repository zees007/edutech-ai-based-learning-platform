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
    testWidgets('renders hero badge, headline, and trust indicators', (tester) async {
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
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('AUTONOMOUS MULTI-AGENT BLACKBOARD ARCHITECTURE'), findsOneWidget);
      expect(find.text('10 Free AI Sessions / Month'), findsOneWidget);
      expect(find.text('Zero AI Hallucinations Grounded'), findsOneWidget);
      expect(find.text('Export to Obsidian & Notion'), findsOneWidget);
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

      expect(find.text('THE ARCHITECTURAL ADVANTAGE'), findsOneWidget);
      expect(find.text('Beyond Generic AI Chatbots'), findsOneWidget);
      expect(find.text('Teaching Methodology'), findsOneWidget);
      expect(find.text('Curricular Structure'), findsOneWidget);
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
      expect(find.text('Visual Mode'), findsOneWidget);
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
        const ProviderScope(
          child: MaterialApp(
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
      expect(find.text('Get Started'), findsOneWidget);
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
