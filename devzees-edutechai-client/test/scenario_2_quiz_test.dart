import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/data/models/learning/milestone_step.dart';
import 'package:devzees_edutechai_client/data/models/learning/session_response.dart';
import 'package:devzees_edutechai_client/data/models/learning/quiz_result.dart';
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

  @override
  Future<QuizResult> submitQuiz(
    String sessionId,
    int stepIndex,
    Map<int, String> answers,
  ) async {
    return const QuizResult(
      stepIndex: 1,
      totalQuestions: 1,
      correctCount: 1,
      score: 1.0,
      xpEarned: 20,
      feedback: [
        QuestionFeedback(
          questionIndex: 0,
          isCorrect: true,
          studentAnswer: 'A: A language',
          correctAnswer: 'A',
          explanation: 'Python is a programming language.',
        ),
      ],
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'Scenario 2: User submits quiz at step 1, navigates to step 0, and returns to step 1 -> submitted quiz persists',
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
      sessionId: 'session-scenario-2',
      topic: 'Python',
      learningMode: 'interactive',
      studentLevel: 'beginner',
      createdAt: DateTime.now(),
      currentStepIndex: 1,
      stepsCompleted: 1,
      xpEarned: 0,
      steps: [
        MilestoneStep(
          index: 0,
          title: 'Step 0: Intro',
          description: 'Introduction',
          quiz: sampleQuiz,
          status: 'complete',
          quizScore: 1.0,
          userAnswers: {'0': 'A'},
          userFullAnswers: {'0': 'A'},
        ),
        MilestoneStep(
          index: 1,
          title: 'Step 1: Variables',
          description: 'Variables and types',
          quiz: sampleQuiz,
          status: 'in_progress',
          quizScore: null,
          userAnswers: null,
          userFullAnswers: null,
        ),
      ],
    );

    final mockService = MockLearningService();
    mockService.sessions['session-scenario-2'] = session;

    final container = ProviderContainer(
      overrides: [
        learningServiceProvider.overrideWithValue(mockService),
      ],
    );

    // Initial load session
    await container.read(activeSessionProvider.notifier).loadSession('session-scenario-2');

    // 1. Render LearningResourcesPanel for Step 1
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: LearningResourcesPanel(
              key: const ValueKey('resources_step_1'),
              currentStep: container.read(activeSessionProvider).session!.steps[1],
              session: container.read(activeSessionProvider).session!,
              stepIndex: 1,
              onNextStep: () async {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // In step 1 initially, quiz is not completed, so tab is 0 (Videos)
    // Switch to Tab 2 (Quiz)
    final quizTab = find.text('Quiz');
    expect(quizTab, findsOneWidget);
    await tester.tap(quizTab);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify "Submit Answers" button is present
    expect(find.text('Submit Answers'), findsOneWidget);

    // Select option A (index 0)
    final optionA = find.text('A language');
    expect(optionA, findsOneWidget);
    await tester.tap(optionA);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Tap "Submit Answers"
    final submitBtn = find.text('Submit Answers');
    await tester.tap(submitBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // After submitting:
    // "Submit Answers" should be gone, score/feedback should be shown
    expect(find.text('Submit Answers'), findsNothing);
    expect(find.text('100% Score'), findsOneWidget);

    // 2. Now user moves to Step 0 to review!
    container.read(activeSessionProvider.notifier).setActiveStep(0);
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

    // 3. Now user comes back to Step 1!
    container.read(activeSessionProvider.notifier).setActiveStep(1);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: LearningResourcesPanel(
              key: const ValueKey('resources_step_1'),
              currentStep: container.read(activeSessionProvider).session!.steps[1],
              session: container.read(activeSessionProvider).session!,
              stepIndex: 1,
              onNextStep: () async {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // CRITICAL ASSERTION FOR SCENARIO 2:
    // Step 1 quiz MUST STILL BE SUBMITTED!
    // "Submit Answers" must NOT be visible!
    // "100% Score" must be visible!
    expect(find.text('Submit Answers'), findsNothing);
    expect(find.text('100% Score'), findsOneWidget);
  });
}
