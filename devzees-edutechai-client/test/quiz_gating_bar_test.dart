import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/data/models/learning/milestone_step.dart';
import 'package:devzees_edutechai_client/data/models/learning/session_response.dart';
import 'package:devzees_edutechai_client/presentation/pages/learning/widgets/workspace/learning_resources_panel.dart';
import 'package:devzees_edutechai_client/core/providers/learning_provider.dart';
import 'package:devzees_edutechai_client/core/providers/active_session_provider.dart';
import 'package:devzees_edutechai_client/core/services/learning_service.dart';

class MockLearningService extends LearningService {
  final Map<String, SessionResponse> sessions = {};

  @override
  Future<SessionResponse> fetchSessionById(String sessionId) async {
    final s = sessions[sessionId];
    if (s != null) return s;
    throw Exception('Session not found: $sessionId');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'Gating bar: banner text click does not open modal; Next Step button opens modal; Take Quiz switches to Quiz tab',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final sampleQuiz = [
      {
        'index': 0,
        'question': 'What is Python?',
        'options': ['A: A language', 'B: A snake', 'C: A car', 'D: A plane'],
        'correct_answer': 'A',
        'explanation': 'Python is a programming language.',
      }
    ];

    final session = SessionResponse(
      sessionId: 'session-gating-test',
      topic: 'Python',
      learningMode: 'interactive',
      studentLevel: 'beginner',
      createdAt: DateTime.now(),
      currentStepIndex: 0,
      stepsCompleted: 0,
      xpEarned: 0,
      steps: [
        MilestoneStep(
          index: 0,
          title: 'Step 0: Intro',
          description: 'Introduction',
          quiz: sampleQuiz,
          status: 'in_progress',
          quizScore: null,
          userAnswers: null,
          userFullAnswers: null,
        ),
        MilestoneStep(
          index: 1,
          title: 'Step 1: Next',
          description: 'Next step',
          quiz: sampleQuiz,
          status: 'not_started',
        ),
      ],
    );

    final mockService = MockLearningService();
    mockService.sessions['session-gating-test'] = session;

    final container = ProviderContainer(
      overrides: [
        learningServiceProvider.overrideWithValue(mockService),
      ],
    );

    await container.read(activeSessionProvider.notifier).loadSession('session-gating-test');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: LearningResourcesPanel(
              key: const ValueKey('resources_step_0'),
              currentStep: container.read(activeSessionProvider).session!.steps[0],
              session: container.read(activeSessionProvider).session!,
              stepIndex: 0,
              onNextStep: () async {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify the guidance banner is visible
    final guidanceTextFinder = find.text('Complete Knowledge Check quiz to unlock next step');
    expect(guidanceTextFinder, findsOneWidget);

    // 1. Click on the guidance text banner: Modal MUST NOT open!
    await tester.tap(guidanceTextFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Knowledge Check Required'), findsNothing);

    // 2. Click on the "Next Step" button: Modal MUST open!
    final nextStepBtn = find.text('Next Step');
    expect(nextStepBtn, findsOneWidget);
    await tester.tap(nextStepBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Knowledge Check Required'), findsOneWidget);
    final takeQuizFinder = find.widgetWithText(ElevatedButton, 'Take Quiz');
    expect(takeQuizFinder, findsOneWidget);
    final elevatedBtn = tester.widget<ElevatedButton>(takeQuizFinder);
    expect(elevatedBtn.style?.mouseCursor?.resolve({}), SystemMouseCursors.click);

    // 3. Click "Take Quiz" button: Modal closes AND quiz content becomes visible!
    await tester.tap(takeQuizFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Modal is gone
    expect(find.text('Knowledge Check Required'), findsNothing);

    // Quiz tab content is now active and visible
    expect(find.text('Submit Answers'), findsOneWidget);
    expect(find.text('What is Python?'), findsOneWidget);
  });
}
