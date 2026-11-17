import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/widgets/home_navbar.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/widgets/hero_section.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/widgets/cta_footer.dart';

void main() {
  group('HomePage Full Hand Cursor Tests', () {
    testWidgets('1. Top Navbar menu items, Sign In, and Get Started buttons have click cursor and disabled selection', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SelectionArea(
                child: HomeNavbar(
                  onNavTap: (_) {},
                  isScrolled: false,
                ),
              ),
            ),
          ),
        ),
      );
      // Pump past entrance block delays
      await tester.pump(const Duration(milliseconds: 300));

      // Brand logo
      final brandText = find.text('EduTech');
      expect(brandText, findsOneWidget);
      final brandRegion = tester.widget<MouseRegion>(
        find.ancestor(of: brandText, matching: find.byType(MouseRegion)).first,
      );
      expect(brandRegion.cursor, SystemMouseCursors.click);
      expect(brandRegion.opaque, isTrue);

      // Nav menu items: Workspace, Modes, Compare, Agents, Pricing, FAQ
      final navTitles = ['Workspace', 'Modes', 'Compare', 'Agents', 'Pricing', 'FAQ'];
      for (final title in navTitles) {
        final itemFinder = find.text(title);
        expect(itemFinder, findsOneWidget);
        final itemRegion = tester.widget<MouseRegion>(
          find.ancestor(of: itemFinder, matching: find.byType(MouseRegion)).first,
        );
        expect(itemRegion.cursor, SystemMouseCursors.click);
        expect(itemRegion.opaque, isTrue);
      }

      // Sign In button
      final signInFinder = find.text('Sign In');
      expect(signInFinder, findsOneWidget);
      final signInRegion = tester.widget<MouseRegion>(
        find.ancestor(of: signInFinder, matching: find.byType(MouseRegion)).first,
      );
      expect(signInRegion.cursor, SystemMouseCursors.click);
      expect(signInRegion.opaque, isTrue);

      // Get Started button
      final getStartedFinder = find.text('Get Started');
      expect(getStartedFinder, findsOneWidget);
      final getStartedRegion = tester.widget<MouseRegion>(
        find.ancestor(of: getStartedFinder, matching: find.byType(MouseRegion)).first,
      );
      expect(getStartedRegion.cursor, SystemMouseCursors.click);
      expect(getStartedRegion.opaque, isTrue);

      // Verify that SelectionContainer.disabled wraps these items
      final disabledContainers = find.descendant(
        of: find.byType(HomeNavbar),
        matching: find.byType(SelectionContainer),
      );
      expect(disabledContainers, findsWidgets);

      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('2 & 3. Start Learning for free and Watch a demo buttons have click cursor and disabled selection', (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SelectionArea(
                child: SingleChildScrollView(
                  child: HeroSection(
                    onExploreTap: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      // Pump past entrance block delays
      await tester.pump(const Duration(milliseconds: 800));

      // 2. Start Learning for Free
      final startLearningText = find.text('Start Learning for Free');
      expect(startLearningText, findsOneWidget);
      final startLearningRegion = tester.widget<MouseRegion>(
        find.ancestor(of: startLearningText, matching: find.byType(MouseRegion)).first,
      );
      expect(startLearningRegion.cursor, SystemMouseCursors.click);
      expect(startLearningRegion.opaque, isTrue);

      // 3. Watch a Demo
      final watchDemoText = find.text('Watch a Demo');
      expect(watchDemoText, findsOneWidget);
      final watchDemoRegion = tester.widget<MouseRegion>(
        find.ancestor(of: watchDemoText, matching: find.byType(MouseRegion)).first,
      );
      expect(watchDemoRegion.cursor, SystemMouseCursors.click);
      expect(watchDemoRegion.opaque, isTrue);

      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('4. Get Started Free in CTA footer has click cursor and disabled selection', (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SelectionArea(
                child: SingleChildScrollView(
                  child: CtaFooter(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      final getStartedFreeText = find.text('Get Started Free →');
      expect(getStartedFreeText, findsOneWidget);
      final getStartedFreeRegion = tester.widget<MouseRegion>(
        find.ancestor(of: getStartedFreeText, matching: find.byType(MouseRegion)).first,
      );
      expect(getStartedFreeRegion.cursor, SystemMouseCursors.click);
      expect(getStartedFreeRegion.opaque, isTrue);

      await tester.pump(const Duration(seconds: 1));
    });
  });
}
