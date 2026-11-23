import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:devzees_edutechai_client/core/providers/dashboard_provider.dart';
import 'package:devzees_edutechai_client/data/models/dashboard/dashboard_response.dart';
import 'package:devzees_edutechai_client/presentation/pages/dashboard/widgets/learner_standing_hud.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final mockStanding = LearnerStanding(
    totalXp: 1850,
    highestTrophyId: 'diamond',
    highestTrophyTitle: 'Diamond Trophy',
    nextTrophyId: 'diamond',
    nextTrophyTitle: 'Diamond Trophy',
    trophyProgressFraction: 0.75,
    currentStreak: 7,
    longestStreak: 14,
    nextTrophyRequirements: const [
      TrophyRequirement(
        label: 'Complete 10 Sessions',
        current: 10,
        required: 10,
        met: true,
      ),
      TrophyRequirement(
        label: 'Maintain 7-Day Streak',
        current: 7,
        required: 7,
        met: true,
      ),
      TrophyRequirement(
        label: 'Master 5 Quizzes with 100%',
        current: 3,
        required: 5,
        met: false,
      ),
    ],
    achievements: const [
      AchievementItem(
        id: 'bronze',
        title: 'Bronze Trophy',
        description: '',
        icon: 'bronze',
        unlocked: true,
      ),
      AchievementItem(
        id: 'silver',
        title: 'Silver Trophy',
        description: '',
        icon: 'silver',
        unlocked: true,
      ),
      AchievementItem(
        id: 'gold',
        title: 'Gold Trophy',
        description: '',
        icon: 'gold',
        unlocked: true,
      ),
      AchievementItem(
        id: 'platinum',
        title: 'Platinum Trophy',
        description: '',
        icon: 'platinum',
        unlocked: false,
      ),
      AchievementItem(
        id: 'sapphire',
        title: 'Sapphire Trophy',
        description: '',
        icon: 'sapphire',
        unlocked: false,
      ),
      AchievementItem(
        id: 'diamond',
        title: 'Diamond Trophy',
        description: '',
        icon: 'diamond',
        unlocked: false,
      ),
    ],
  );

  Widget createTestWidget({
    required double width,
    required double height,
    bool isTopBar = true,
  }) {
    return ProviderScope(
      overrides: [
        learnerStandingProvider.overrideWith(
          () => _MockStandingNotifier(mockStanding),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: width,
            height: height,
            child: LearnerStandingHud(isTopBar: isTopBar),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'renders desktop single-row with requested sequence and tooltips (no arrows/popovers)',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createTestWidget(width: 1280, height: 800, isTopBar: true),
      );
      await tester.pumpAndSettle();

      // 1. Diamond Trophy & Current pill
      expect(find.text('Diamond Trophy'), findsOneWidget);
      expect(find.text('Current'), findsOneWidget);

      // 2. Trophies Unlock
      expect(find.text('3 / 6'), findsOneWidget);

      // 3. Total XP Rewards
      expect(find.text('Total XP Rewards'), findsOneWidget);
      expect(find.text('1,850'), findsOneWidget);
      expect(find.text('XP'), findsOneWidget);

      // 4. Streak
      expect(find.text('Daily Streak'), findsOneWidget);
      expect(find.text('7 Days'), findsOneWidget);

      // Verify NO chevron navigation arrows are present
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);

      // Verify Tooltip widgets exist for informative feedback
      expect(find.byType(Tooltip), findsWidgets);

      final tooltips = tester.widgetList<Tooltip>(find.byType(Tooltip)).toList();
      final messages = tooltips.map((t) => t.message).toList();

      // Verify polished tooltip copy (Option A)
      expect(
        messages.any((m) => m?.contains('Current Trophy: Diamond Trophy') == true),
        isTrue,
      );
      expect(
        messages.any((m) => m?.contains('3 of 6 Trophies Unlocked') == true),
        isTrue,
      );
      expect(
        messages.any((m) => m?.contains('Lifetime XP: 1,850 XP') == true),
        isTrue,
      );
      expect(
        messages.any((m) => m?.contains('Daily Streak: 7 Days') == true && m?.contains('Personal Best Record: 14 Days') == true),
        isTrue,
      );
    },
  );

  testWidgets('renders mobile deck cleanly without overflows', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      createTestWidget(width: 375, height: 812, isTopBar: true),
    );
    await tester.pumpAndSettle();

    // Row 1
    expect(find.text('Diamond Trophy'), findsOneWidget);
    expect(find.text('Current'), findsOneWidget);

    // Row 2 & 3
    expect(find.text('3 / 6'), findsOneWidget);
    expect(find.text('Total XP Rewards'), findsOneWidget);
    expect(find.text('1,850'), findsOneWidget);
    expect(find.text('Streak'), findsOneWidget);
    expect(find.text('7 Days'), findsOneWidget);

    // Verify no navigation arrows
    expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);

    // Verify pinned hamburger icon on left and theme toggle on right
    expect(find.byIcon(Icons.menu_rounded), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'renders narrow mobile (320x568) and responds to tap for tooltips',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createTestWidget(width: 320, height: 568, isTopBar: true),
      );
      await tester.pumpAndSettle();

      // Verify all badges and pinned actions render on narrow mobile
      expect(find.byIcon(Icons.menu_rounded), findsOneWidget);
      expect(find.text('Diamond Trophy'), findsOneWidget);
      expect(find.text('3 / 6'), findsOneWidget);
      expect(find.text('1,850'), findsOneWidget);
      expect(find.text('7 Days'), findsOneWidget);

      // Tap on Diamond Trophy badge to verify tap-triggered tooltip
      await tester.tap(find.text('Diamond Trophy'));
      await tester.pumpAndSettle();

      expect(find.byType(Tooltip), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('renders standalone card mode cleanly', (tester) async {
    tester.view.physicalSize = const Size(600, 400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      createTestWidget(width: 600, height: 400, isTopBar: false),
    );
    await tester.pumpAndSettle();

    expect(find.text('Diamond Trophy'), findsOneWidget);
    expect(find.text('Current'), findsOneWidget);
    expect(find.text('3 / 6'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('verifies Option A tooltip messages for Gold Trophy with next Platinum Trophy', (tester) async {
    const goldStanding = LearnerStanding(
      totalXp: 10500,
      highestTrophyId: 'gold',
      highestTrophyTitle: 'Gold Trophy',
      nextTrophyId: 'platinum',
      nextTrophyTitle: 'Platinum Trophy',
      trophyProgressFraction: 0.75,
      currentStreak: 5,
      longestStreak: 14,
      achievements: [
        AchievementItem(id: 'bronze', title: 'Bronze Trophy', description: '', icon: 'bronze', unlocked: true),
        AchievementItem(id: 'silver', title: 'Silver Trophy', description: '', icon: 'silver', unlocked: true),
        AchievementItem(id: 'gold', title: 'Gold Trophy', description: '', icon: 'gold', unlocked: true),
        AchievementItem(id: 'platinum', title: 'Platinum Trophy', description: '', icon: 'platinum', unlocked: false),
        AchievementItem(id: 'sapphire', title: 'Sapphire Trophy', description: '', icon: 'sapphire', unlocked: false),
        AchievementItem(id: 'diamond', title: 'Diamond Trophy', description: '', icon: 'diamond', unlocked: false),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          learnerStandingProvider.overrideWith(
            () => _MockStandingNotifier(goldStanding),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 1280,
              height: 800,
              child: LearnerStandingHud(isTopBar: true),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final tooltips = tester.widgetList<Tooltip>(find.byType(Tooltip)).toList();
    final messages = tooltips.map((t) => t.message).toList();

    // 1. Trophy: Current Trophy: Gold Trophy / Next to Achieve: Platinum Trophy
    expect(
      messages.any((m) => m == 'Current Trophy: Gold Trophy\nNext to Achieve: Platinum Trophy'),
      isTrue,
    );

    // 2. Unlock: 3 of 6 Trophies Unlocked / Next: Platinum Trophy (75% to unlock)
    expect(
      messages.any((m) => m == '3 of 6 Trophies Unlocked\nNext: Platinum Trophy (75% to unlock)'),
      isTrue,
    );

    // 3. XP: Lifetime XP: 10,500 XP / Earned across sessions, milestones & quizzes
    expect(
      messages.any((m) => m == 'Lifetime XP: 10,500 XP\nEarned across sessions, milestones & quizzes'),
      isTrue,
    );

    // 4. Streak: Daily Streak: 5 Days / Personal Best Record: 14 Days
    expect(
      messages.any((m) => m == 'Daily Streak: 5 Days\nPersonal Best Record: 14 Days'),
      isTrue,
    );
  });

  testWidgets('displays Bronze Trophy with Locked badge and encouraging tooltip when unranked', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const unrankedStanding = LearnerStanding(
      totalXp: 120,
      highestTrophyId: null,
      highestTrophyTitle: 'Unranked',
      nextTrophyId: 'bronze',
      nextTrophyTitle: 'Bronze Trophy',
      trophyProgressFraction: 0.15,
      currentStreak: 1,
      longestStreak: 1,
      achievements: [
        AchievementItem(id: 'bronze', title: 'Bronze Trophy', description: '', icon: 'bronze', unlocked: false),
        AchievementItem(id: 'silver', title: 'Silver Trophy', description: '', icon: 'silver', unlocked: false),
        AchievementItem(id: 'gold', title: 'Gold Trophy', description: '', icon: 'gold', unlocked: false),
        AchievementItem(id: 'platinum', title: 'Platinum Trophy', description: '', icon: 'platinum', unlocked: false),
        AchievementItem(id: 'sapphire', title: 'Sapphire Trophy', description: '', icon: 'sapphire', unlocked: false),
        AchievementItem(id: 'diamond', title: 'Diamond Trophy', description: '', icon: 'diamond', unlocked: false),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          learnerStandingProvider.overrideWith(
            () => _MockStandingNotifier(unrankedStanding),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 1280,
              height: 800,
              child: LearnerStandingHud(isTopBar: true),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Should display "Bronze Trophy" as aspirational target, NOT "Unranked"
    expect(find.text('Bronze Trophy'), findsOneWidget);
    expect(find.text('Unranked'), findsNothing);

    // 2. Should display amber "Locked" badge, NOT "Current"
    expect(find.text('Locked'), findsOneWidget);
    expect(find.text('Current'), findsNothing);
    expect(find.byIcon(Icons.lock_rounded), findsWidgets);

    // 3. Tooltip should contain the encouraging prompt
    final tooltips = tester.widgetList<Tooltip>(find.byType(Tooltip)).toList();
    final messages = tooltips.map((t) => t.message).toList();
    expect(
      messages.any((m) => m?.contains('Continue learning to unlock your first Bronze Trophy! 🏆') == true),
      isTrue,
    );

    // 4. A grayscale ColorFiltered layer must be applied to the locked trophy asset
    expect(find.byType(ColorFiltered), findsOneWidget);

    // 5. When locked, hovering should NOT scale up the trophy (it stays locked at 1.0)
    final animatedScaleFinder = find.byType(AnimatedScale);
    final initialScale = tester.widget<AnimatedScale>(animatedScaleFinder.first);
    expect(initialScale.scale, equals(1.0));

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);

    await gesture.moveTo(tester.getCenter(find.text('Bronze Trophy')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    final hoveredScale = tester.widget<AnimatedScale>(animatedScaleFinder.first);
    expect(hoveredScale.scale, equals(1.0)); // Stays 1.0, nothing happens on hover when locked
  });

  testWidgets('verifies grayscale locked state and no hover scale in dark theme when locked', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const unrankedStanding = LearnerStanding(
      totalXp: 120,
      highestTrophyId: null,
      highestTrophyTitle: 'Unranked',
      nextTrophyId: 'bronze',
      nextTrophyTitle: 'Bronze Trophy',
      trophyProgressFraction: 0.15,
      currentStreak: 1,
      longestStreak: 1,
      achievements: [
        AchievementItem(id: 'bronze', title: 'Bronze Trophy', description: '', icon: 'bronze', unlocked: false),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          learnerStandingProvider.overrideWith(
            () => _MockStandingNotifier(unrankedStanding),
          ),
        ],
        child: MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: SizedBox(
              width: 1280,
              height: 800,
              child: LearnerStandingHud(isTopBar: true),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bronze Trophy'), findsOneWidget);
    expect(find.text('Locked'), findsOneWidget);
    expect(find.byType(ColorFiltered), findsOneWidget);

    final animatedScaleFinder = find.byType(AnimatedScale);
    final scaleWidget = tester.widget<AnimatedScale>(animatedScaleFinder.first);
    expect(scaleWidget.scale, equals(1.0));
  });

  testWidgets('trophy image scales up on mouse hover and resets on exit', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      createTestWidget(width: 1280, height: 800, isTopBar: true),
    );
    await tester.pumpAndSettle();

    final animatedScaleFinder = find.byType(AnimatedScale);
    expect(animatedScaleFinder, findsWidgets);

    // Initial scale is 1.0
    final initialScaleWidget = tester.widget<AnimatedScale>(animatedScaleFinder.first);
    expect(initialScaleWidget.scale, equals(1.0));

    // Simulate mouse hover over the trophy crest
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);

    await gesture.moveTo(tester.getCenter(animatedScaleFinder.first));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // After hover, scale increases to 1.25
    final hoveredScaleWidget = tester.widget<AnimatedScale>(animatedScaleFinder.first);
    expect(hoveredScaleWidget.scale, equals(1.25));

    // Move mouse away
    await gesture.moveTo(Offset.zero);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Scale resets to 1.0
    final resetScaleWidget = tester.widget<AnimatedScale>(animatedScaleFinder.first);
    expect(resetScaleWidget.scale, equals(1.0));
  });
}

class _MockStandingNotifier extends LearnerStandingNotifier {
  final LearnerStanding mockStanding;
  _MockStandingNotifier(this.mockStanding);

  @override
  Future<LearnerStanding> build() async => mockStanding;
}
