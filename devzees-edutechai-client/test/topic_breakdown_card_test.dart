import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devzees_edutechai_client/data/models/dashboard/dashboard_response.dart';
import 'package:devzees_edutechai_client/presentation/pages/dashboard/widgets/topic_breakdown_card.dart';

void main() {
  group('TopicBreakdownCard Widget Tests', () {
    testWidgets('renders dynamic header and journey items with status, steps, and percentage',
        (tester) async {
      const items = [
        TopicBreakdownItem(
          topic: 'Advanced Quantum Computing: Superposition & Entanglement In Depth',
          sessionCount: 1,
          percentage: 100.0,
          sessionId: 'sess_1',
          isComplete: true,
          completedSteps: 5,
          totalSteps: 5,
          learningMode: 'visual',
        ),
        TopicBreakdownItem(
          topic: 'Chemical Bonding Fundamentals',
          sessionCount: 1,
          percentage: 75.0,
          sessionId: 'sess_2',
          isComplete: false,
          completedSteps: 3,
          totalSteps: 4,
          learningMode: 'deep_dive',
        ),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TopicBreakdownCard(topicBreakdown: items),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify dynamic header
      expect(find.text('Top 2 Learning Journey Mastery Breakdown'), findsOneWidget);
      expect(find.text('Ranked by completion progress in the selected period'), findsOneWidget);

      // Verify topics with tooltip
      expect(
        find.text('Advanced Quantum Computing: Superposition & Entanglement In Depth'),
        findsOneWidget,
      );
      expect(find.text('Chemical Bonding Fundamentals'), findsOneWidget);

      // Verify status badges
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);

      // Verify steps count badges
      expect(find.text('5/5 steps'), findsOneWidget);
      expect(find.text('3/4 steps'), findsOneWidget);

      // Verify percentage pills
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);

      // Verify mode pills
      expect(find.text('Visual'), findsOneWidget);
      expect(find.text('Deep Dive'), findsOneWidget);
    });

    testWidgets('renders empty state with Start New Journey button when no journeys exist',
        (tester) async {
      bool startJourneyTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TopicBreakdownCard(
              topicBreakdown: const [],
              onStartNewJourney: () {
                startJourneyTapped = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Learning Journey Mastery Breakdown'), findsOneWidget);
      expect(find.text('No Journeys in This Period'), findsOneWidget);
      expect(find.text('Start New Journey'), findsOneWidget);

      // Tap button
      await tester.tap(find.text('Start New Journey'));
      await tester.pumpAndSettle();

      expect(startJourneyTapped, isTrue);
    });
  });
}
