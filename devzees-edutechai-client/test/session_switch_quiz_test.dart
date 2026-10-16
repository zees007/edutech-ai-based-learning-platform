import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/data/models/learning/milestone_step.dart';
import 'package:devzees_edutechai_client/data/models/learning/session_response.dart';
import 'package:devzees_edutechai_client/presentation/pages/learning/widgets/workspace/knowledge_check_quiz.dart';
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

  group('Session Switch & Quiz Isolation Tests', () {
    testWidgets(
        'KnowledgeCheckQuiz resets submitted status when switching sessions with same step index',
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

      final submittedStep = MilestoneStep(
        index: 0,
        title: 'Step 0 in Session A',
        description: 'Test step',
        quiz: sampleQuiz,
        quizScore: 1.0,
        userAnswers: {'0': 'A'},
      );

      final unsubmittedStep = MilestoneStep(
        index: 0,
        title: 'Step 0 in Session B',
        description: 'Test step in another session',
        quiz: sampleQuiz,
        quizScore: null,
        userAnswers: null,
      );

      // 1. Render KnowledgeCheckQuiz for Session A (submitted)
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: KnowledgeCheckQuiz(
                  key: const ValueKey('quiz_sessionA_step_0'),
                  sessionId: 'sessionA',
                  stepIndex: 0,
                  step: submittedStep,
                  quiz: sampleQuiz,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // In Session A (submitted), the unsubmitted "Submit Answers" button should NOT appear
      expect(find.text('Submit Answers'), findsNothing);

      // 2. Now switch to Session B (unsubmitted step at same stepIndex 0)
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: KnowledgeCheckQuiz(
                  key: const ValueKey('quiz_sessionB_step_0'),
                  sessionId: 'sessionB',
                  stepIndex: 0,
                  step: unsubmittedStep,
                  quiz: sampleQuiz,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // In Session B, the quiz must NOT be marked submitted: "Submit Answers" must appear!
      expect(find.text('Submit Answers'), findsOneWidget);
    });

    test('loadSession does not leak quiz results when switching sessions', () async {
      final mockService = MockLearningService();

      final sessionA = SessionResponse(
        sessionId: 'session-A',
        topic: 'Flutter Architecture',
        learningMode: 'interactive',
        studentLevel: 'intermediate',
        createdAt: DateTime.now(),
        currentStepIndex: 0,
        stepsCompleted: 1,
        xpEarned: 100,
        steps: [
          MilestoneStep(
            index: 0,
            title: 'Session A Step 0',
            description: 'Desc',
            quizScore: 1.0,
            userAnswers: {'0': 'A'},
            userFullAnswers: {'0': 'A'},
          ),
          MilestoneStep(
            index: 1,
            title: 'Session A Step 1',
            description: 'Desc',
            quizScore: 0.8,
            userAnswers: {'0': 'B'},
            userFullAnswers: {'0': 'B'},
          ),
        ],
      );

      final sessionB = SessionResponse(
        sessionId: 'session-B',
        topic: 'Python Concurrency',
        learningMode: 'interactive',
        studentLevel: 'intermediate',
        createdAt: DateTime.now(),
        currentStepIndex: 0,
        stepsCompleted: 0,
        xpEarned: 0,
        steps: [
          MilestoneStep(
            index: 0,
            title: 'Session B Step 0',
            description: 'Desc',
            quizScore: null,
            userAnswers: null,
            userFullAnswers: null,
          ),
          MilestoneStep(
            index: 1,
            title: 'Session B Step 1',
            description: 'Desc',
            quizScore: null,
            userAnswers: null,
            userFullAnswers: null,
          ),
        ],
      );

      mockService.sessions['session-A'] = sessionA;
      mockService.sessions['session-B'] = sessionB;

      final container = ProviderContainer(
        overrides: [
          learningServiceProvider.overrideWithValue(mockService),
        ],
      );

      final notifier = container.read(activeSessionProvider.notifier);

      // Load Session A
      await notifier.loadSession('session-A');
      expect(container.read(activeSessionProvider).session?.sessionId, 'session-A');
      expect(container.read(activeSessionProvider).session?.steps[0].quizScore, 1.0);
      expect(container.read(activeSessionProvider).session?.steps[1].quizScore, 0.8);

      // Switch to Session B
      await notifier.loadSession('session-B');
      final currentSessionB = container.read(activeSessionProvider).session;
      expect(currentSessionB?.sessionId, 'session-B');

      // Crucial assertion: Session B's steps MUST NOT have inherited Session A's quiz results!
      expect(currentSessionB?.steps[0].quizScore, isNull);
      expect(currentSessionB?.steps[0].userAnswers, isNull);
      expect(currentSessionB?.steps[1].quizScore, isNull);
      expect(currentSessionB?.steps[1].userAnswers, isNull);
    });
  });
}
