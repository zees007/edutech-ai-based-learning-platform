import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devzees_edutechai_client/data/models/learning/session_response.dart';
import 'package:devzees_edutechai_client/data/models/learning/milestone_step.dart';
import 'package:devzees_edutechai_client/presentation/pages/learning/widgets/workspace/unified_learning_command_hub.dart';

void main() {
  testWidgets('UnifiedLearningCommandHub renders goal, metrics and stepper cleanly', (WidgetTester tester) async {
    final session = SessionResponse(
      sessionId: 'test-session-123',
      topic: 'Introduction to Quantum Computing',
      learningMode: 'socratic',
      studentLevel: 'university',
      createdAt: DateTime.now(),
      xpEarned: 450,
      stepsCompleted: 1,
      currentStepIndex: 1,
      steps: [
        MilestoneStep(
          index: 0,
          title: 'Quantum Superposition',
          description: 'Basics of qubits in superposition',
          status: 'complete',
        ),
        MilestoneStep(
          index: 1,
          title: 'Quantum Entanglement',
          description: 'Spooky action at a distance',
          status: 'in_progress',
        ),
        MilestoneStep(
          index: 2,
          title: 'Quantum Circuits',
          description: 'Building logic gates',
          status: 'pending',
        ),
      ],
    );

    int tappedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: UnifiedLearningCommandHub(
              session: session,
              activeIndex: 1,
              maxUnlockedIndex: 1,
              onStepTapped: (index) {
                tappedIndex = index;
              },
            ),
          ),
        ),
      ),
    );

    // Verify Goal text is displayed
    expect(find.text('Introduction to Quantum Computing'), findsOneWidget);
    expect(find.text('YOUR GOAL'), findsOneWidget);

    // Verify Mode and Audience chips
    expect(find.text('SOCRATIC'), findsOneWidget);
    expect(find.text('UNIVERSITY'), findsOneWidget);

    // Verify XP stat
    expect(find.text('450 XP'), findsOneWidget);

    // Verify Roadmap title
    expect(find.text('Milestone Learning Roadmap'), findsOneWidget);
    expect(find.text('Step 2 of 3'), findsOneWidget);
  });

  testWidgets('UnifiedLearningCommandHub cleanly sanitizes student_level with trailing underscores or emojis', (WidgetTester tester) async {
    final session = SessionResponse(
      sessionId: 'test-session-456',
      topic: 'C++ Programming Basics',
      learningMode: 'deep_dive',
      studentLevel: 'middle_school_',
      createdAt: DateTime.now(),
      xpEarned: 100,
      stepsCompleted: 0,
      currentStepIndex: 0,
      steps: [
        MilestoneStep(
          index: 0,
          title: 'Intro to Syntax',
          description: 'C++ basic types',
          status: 'in_progress',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: UnifiedLearningCommandHub(
              session: session,
              activeIndex: 0,
              maxUnlockedIndex: 0,
              onStepTapped: (_) {},
            ),
          ),
        ),
      ),
    );

    // Verify sanitized labels without trailing underscore or raw snake_case
    expect(find.text('DEEP DIVE'), findsOneWidget);
    expect(find.text('MIDDLE SCHOOL'), findsOneWidget);
    expect(find.text('middle_school_'), findsNothing);
  });
}
