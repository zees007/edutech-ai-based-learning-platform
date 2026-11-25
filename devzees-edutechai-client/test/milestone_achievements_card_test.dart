import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devzees_edutechai_client/data/models/dashboard/dashboard_response.dart';
import 'package:devzees_edutechai_client/presentation/pages/dashboard/widgets/learning_mode_distribution_card.dart';
import 'package:devzees_edutechai_client/presentation/pages/dashboard/widgets/milestone_achievements_card.dart';

void main() {
  group('MilestoneAchievementsCard Redesign Tests', () {
    const sampleAchievements = [
      AchievementItem(
        id: 'bronze',
        title: 'Bronze Trophy',
        description:
            'Mastered your first learning steps (1 session, 5 steps, 3 perfect quizzes)',
        icon: 'bronze',
        unlocked: true,
      ),
      AchievementItem(
        id: 'silver',
        title: 'Silver Trophy',
        description:
            'Established active learning consistency (5 sessions, 25 steps, 8 perfect quizzes)',
        icon: 'silver',
        unlocked: true,
      ),
      AchievementItem(
        id: 'gold',
        title: 'Gold Trophy',
        description:
            'True Grand Sage dedication (10 sessions, 60 steps, 15 perfect quizzes)',
        icon: 'gold',
        unlocked: false,
      ),
      AchievementItem(
        id: 'platinum',
        title: 'Platinum Trophy',
        description:
            'Knowledge marathoner (25 sessions, 150 steps, 25 perfect quizzes)',
        icon: 'platinum',
        unlocked: false,
      ),
      AchievementItem(
        id: 'sapphire',
        title: 'Sapphire Trophy',
        description:
            'Dedicated intellectual scholar (50 sessions, 250 steps, 40 perfect quizzes)',
        icon: 'sapphire',
        unlocked: false,
      ),
      AchievementItem(
        id: 'diamond',
        title: 'Diamond Trophy',
        description:
            'The pinnacle of intellectual mastery and eternal wisdom achieved across all subjects',
        icon: 'diamond',
        unlocked: false,
      ),
    ];

    testWidgets(
        'renders modified header, 2/6 unlocked counter, progress bar, and all 6 trophy cards',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MilestoneAchievementsCard(
                achievements: sampleAchievements,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check modified header
      expect(find.text('Learner Achievements & Trophies'), findsOneWidget);
      expect(
          find.text(
              'Earn honorary trophies by staying consistent in your studies and achieving quiz excellence'),
          findsOneWidget);
      expect(find.text('2 / 6 Unlocked'), findsOneWidget);
      expect(find.text('33% Complete'), findsOneWidget);

      // Verify all trophy titles
      expect(find.text('Bronze Trophy'), findsOneWidget);
      expect(find.text('Silver Trophy'), findsOneWidget);
      expect(find.text('Gold Trophy'), findsOneWidget);
      expect(find.text('Platinum Trophy'), findsOneWidget);
      expect(find.text('Sapphire Trophy'), findsOneWidget);
      expect(find.text('Diamond Trophy'), findsOneWidget);

      // Verify tier labels
      expect(find.text('TIER I • BRONZE'), findsOneWidget);
      expect(find.text('TIER II • SILVER'), findsOneWidget);
      expect(find.text('TIER III • GOLD'), findsOneWidget);
      expect(find.text('TIER IV • PLATINUM'), findsOneWidget);
      expect(find.text('TIER V • SAPPHIRE'), findsOneWidget);
      expect(find.text('TIER VI • DIAMOND'), findsOneWidget);

      // Verify badges: 2 UNLOCKED, 4 LOCKED
      expect(find.text('UNLOCKED'), findsNWidgets(2));
      expect(find.text('LOCKED'), findsNWidgets(4));

      // Verify verified icons for unlocked trophies
      expect(find.byIcon(Icons.verified_rounded), findsNWidgets(2));

      // Verify lock icons for locked trophies
      expect(find.byIcon(Icons.lock_rounded), findsNWidgets(4));

      // Verify ColorFiltered exists for grayed-out locked trophies (4 locked)
      expect(find.byType(ColorFiltered), findsNWidgets(4));

      // Verify Image widgets are created for the trophies
      expect(find.byType(Image), findsNWidgets(6));
    });

    testWidgets('allows custom title and subtitle to be passed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MilestoneAchievementsCard(
                achievements: sampleAchievements,
                title: 'Permanent Trophy Case',
                subtitle: 'All-time cumulative milestone progress',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Permanent Trophy Case'), findsOneWidget);
      expect(find.text('All-time cumulative milestone progress'), findsOneWidget);
    });

    testWidgets(
        'scales up on hover and expands text to show full text without ellipsis truncation',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MilestoneAchievementsCard(
                achievements: sampleAchievements,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final bronzeFinder = find.text('Bronze Trophy');
      expect(bronzeFinder, findsOneWidget);

      // Before hover, verify AnimatedScale scale is 1.0
      AnimatedScale initialScaleWidget =
          tester.widget(find.byType(AnimatedScale).first);
      expect(initialScaleWidget.scale, 1.0);

      // Hover over Bronze Trophy card
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);

      await gesture.moveTo(tester.getCenter(bronzeFinder));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 250));

      // After hover, verify scale is 1.03
      AnimatedScale hoveredScaleWidget =
          tester.widget(find.byType(AnimatedScale).first);
      expect(hoveredScaleWidget.scale, 1.03);

      // Verify text maxLines is null on hover so full text is visible without ellipsis
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      final bronzeDescText = textWidgets.firstWhere(
        (t) => t.data?.contains('Mastered your first learning steps') ?? false,
      );
      expect(bronzeDescText.maxLines, isNull);
      expect(bronzeDescText.overflow, TextOverflow.visible);
    });

    testWidgets('renders empty state when achievements list is empty',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MilestoneAchievementsCard(
              achievements: [],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Learner Achievements & Trophies'), findsOneWidget);
      expect(find.text('0 / 0 Unlocked'), findsOneWidget);
      expect(find.text('No milestone achievements available.'), findsOneWidget);
    });

    testWidgets(
        'renders without overflow in narrow mobile viewport (320px width)',
        (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MilestoneAchievementsCard(
                achievements: sampleAchievements,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Learner Achievements & Trophies'), findsOneWidget);
      expect(find.text('Bronze Trophy'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders cleanly in dark mode theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: MilestoneAchievementsCard(
                achievements: sampleAchievements,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Learner Achievements & Trophies'), findsOneWidget);
      expect(find.text('Bronze Trophy'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'renders 3 trophy cards per row on desktop (1280px) and matches LearningModeDistributionCard height exactly',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const modeDist = ModeDistribution(
        visual: 12,
        deepDive: 8,
        biteSized: 5,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 4,
                      child: LearningModeDistributionCard(
                        modeDistribution: modeDist,
                        isCompact: false,
                        stretchHeight: true,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 8,
                      child: MilestoneAchievementsCard(
                        achievements: sampleAchievements,
                        crossAxisCount: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Verify exact same height between both cards
      final modeBox = tester.getRect(find.byType(LearningModeDistributionCard));
      final trophyBox = tester.getRect(find.byType(MilestoneAchievementsCard));
      expect(modeBox.height, closeTo(trophyBox.height, 0.01));

      // Verify 3 cards in first row (Bronze, Silver, Gold share the same top Y)
      final bronzeTop = tester.getTopLeft(find.text('Bronze Trophy')).dy;
      final silverTop = tester.getTopLeft(find.text('Silver Trophy')).dy;
      final goldTop = tester.getTopLeft(find.text('Gold Trophy')).dy;
      final platinumTop = tester.getTopLeft(find.text('Platinum Trophy')).dy;

      expect(bronzeTop, closeTo(silverTop, 2.0));
      expect(silverTop, closeTo(goldTop, 2.0));
      expect(platinumTop, greaterThan(bronzeTop + 40));
    });

    testWidgets(
        'renders 2 trophy cards per row on tablet (800px) without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MilestoneAchievementsCard(
                achievements: sampleAchievements,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      final bronzeTop = tester.getTopLeft(find.text('Bronze Trophy')).dy;
      final silverTop = tester.getTopLeft(find.text('Silver Trophy')).dy;
      final goldTop = tester.getTopLeft(find.text('Gold Trophy')).dy;

      expect(bronzeTop, closeTo(silverTop, 2.0));
      expect(goldTop, greaterThan(bronzeTop + 40));
    });
  });
}
