import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devzees_edutechai_client/data/models/learning/session_response.dart';
import 'package:devzees_edutechai_client/presentation/pages/learning/widgets/workspace/unified_learning_command_hub.dart';

SessionResponse _buildSession({
  String topic = 'Binary Search Trees',
  String learningMode = 'Deep Dive 🔬',
  String studentLevel = 'High School 🎒',
  int xpEarned = 75,
}) {
  return SessionResponse(
    sessionId: 'sess-1',
    topic: topic,
    learningMode: learningMode,
    studentLevel: studentLevel,
    createdAt: DateTime(2026, 1, 1),
    xpEarned: xpEarned,
  );
}

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: SelectionArea(
          child: SingleChildScrollView(child: child),
        ),
      ),
    ),
  );
}

void main() {
  group('UnifiedLearningCommandHub', () {
    testWidgets('short single-line topic does not attach expand tooltip', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrap(
          UnifiedLearningCommandHub(
            session: _buildSession(topic: 'Short Topic'),
            activeIndex: 0,
            maxUnlockedIndex: 0,
            onStepTapped: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Short Topic'), findsOneWidget);
      expect(find.byTooltip('Tap to expand topic'), findsNothing);
      expect(find.byTooltip('Tap to collapse'), findsNothing);
    });

    testWidgets('long overflowing topic shows expand tooltip and toggles on tap', (tester) async {
      tester.view.physicalSize = const Size(1000, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const longTopic =
          'Understanding Distributed Consensus Algorithms Including Raft, Paxos, Byzantine Fault Tolerance, and Quorum Replication Across Unreliable Networks';

      await tester.pumpWidget(
        _wrap(
          UnifiedLearningCommandHub(
            session: _buildSession(topic: longTopic),
            activeIndex: 0,
            maxUnlockedIndex: 0,
            onStepTapped: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Tap to expand topic'), findsOneWidget);
      final topicMouseRegion = tester.widget<MouseRegion>(
        find.ancestor(
          of: find.text(longTopic),
          matching: find.byWidgetPredicate(
            (w) => w is MouseRegion && w.cursor == SystemMouseCursors.click,
          ),
        ).first,
      );
      expect(topicMouseRegion.opaque, isTrue);

      await tester.tap(find.text(longTopic));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Tap to collapse'), findsOneWidget);
    });

    testWidgets('renders mode and education level specific icons', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrap(
          UnifiedLearningCommandHub(
            session: _buildSession(
              learningMode: 'Deep Dive 🔬',
              studentLevel: 'High School 🎒',
            ),
            activeIndex: 0,
            maxUnlockedIndex: 0,
            onStepTapped: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('DEEP DIVE'), findsOneWidget);
      expect(find.text('HIGH SCHOOL'), findsOneWidget);
      expect(find.byIcon(Icons.biotech_rounded), findsOneWidget);
      expect(find.byIcon(Icons.backpack_rounded), findsOneWidget);
    });

    testWidgets('displays relative level XP progress and handles max level cleanly', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrap(
          UnifiedLearningCommandHub(
            session: _buildSession(xpEarned: 75),
            activeIndex: 0,
            maxUnlockedIndex: 0,
            onStepTapped: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // At 75 total XP: Level 2 starts at 60, Level 3 at 140 -> 15/80 XP
      expect(find.text('Lvl 2 → 3'), findsOneWidget);
      expect(find.text('15/80 XP'), findsOneWidget);
      expect(
        find.byTooltip(
          'Level 2 • Knowledge Seeker\nActively questioning assumptions and broadening core horizons.',
        ),
        findsOneWidget,
      );

      await tester.pumpWidget(
        _wrap(
          UnifiedLearningCommandHub(
            session: _buildSession(xpEarned: 1050),
            activeIndex: 0,
            maxUnlockedIndex: 0,
            onStepTapped: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Lvl 10 • MAX'), findsOneWidget);
      expect(find.text('MAX'), findsOneWidget);
      expect(find.text('Lvl 10 → 11'), findsNothing);
    });
  });
}
