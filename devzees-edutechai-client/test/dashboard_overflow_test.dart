import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:devzees_edutechai_client/core/providers/dashboard_provider.dart';
import 'package:devzees_edutechai_client/core/providers/auth_provider.dart';
import 'package:devzees_edutechai_client/data/models/auth/user_current_profile_response.dart';
import 'package:devzees_edutechai_client/data/models/dashboard/dashboard_response.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';
import 'package:devzees_edutechai_client/presentation/pages/dashboard/widgets/dashboard_header.dart';
import 'package:devzees_edutechai_client/presentation/pages/dashboard/widgets/learning_dashboard_view.dart';
import 'package:devzees_edutechai_client/presentation/pages/dashboard/widgets/mobile_dashboard_top_bar.dart';
import 'package:devzees_edutechai_client/presentation/pages/learning/widgets/mobile/mobile_learning_top_bar.dart';
import 'package:devzees_edutechai_client/presentation/widgets/theme_toggle_button.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final dummyDashboardData = DashboardResponse(
    summary: const DashboardSummary(
      totalSessions: 12,
      completedSessions: 8,
      completionRate: 66.7,
      totalStepsMastered: 45,
      totalStudyMinutes: 240,
      averageQuizScoreOverall: 88.5,
      totalXp: 1250,
      currentLevel: 4,
      levelTitle: 'Knowledge Adept',
      xpProgressInLevel: 250,
      xpNeededForNext: 500,
      isMaxLevel: false,
      currentStreak: 5,
      longestStreak: 12,
    ),
    quizMetrics: const QuizMetrics(
      totalQuizzesTaken: 15,
      totalQuestionsEvaluated: 45,
      questionsCorrect: 39,
      perfectQuizzesCount: 9,
      accuracyTrend: [
        QuizAccuracyTrendItem(
          date: '2026-11-10',
          sessionId: 's1',
          topic: 'Neural Networks',
          stepIndex: 0,
          stepTitle: 'Perceptron Foundations',
          stepScore: 66.7,
          sessionAvgScore: 75.0,
        ),
        QuizAccuracyTrendItem(
          date: '2026-11-12',
          sessionId: 's1',
          topic: 'Neural Networks',
          stepIndex: 1,
          stepTitle: 'Backpropagation Gradient Descent',
          stepScore: 100.0,
          sessionAvgScore: 88.0,
        ),
      ],
      conceptsNeedingReinforcement: [
        WeakConceptItem(
          sessionId: 's2',
          topic: 'Transformers Architecture',
          stepIndex: 2,
          stepTitle: 'Multi-Head Attention Layers',
          quizScore: 33.3,
          correctCount: 1,
          totalQuestions: 3,
        ),
      ],
    ),
    activityHeatmap: const [
      HeatmapDayItem(
        date: '2026-11-17',
        stepsCount: 6,
        xpEarned: 180,
        activeMinutes: 45,
      ),
      HeatmapDayItem(
        date: '2026-11-18',
        stepsCount: 4,
        xpEarned: 120,
        activeMinutes: 30,
      ),
    ],
    topicBreakdown: const [
      TopicBreakdownItem(
        topic: 'Neural Networks & Deep Learning',
        sessionCount: 6,
        percentage: 50.0,
      ),
      TopicBreakdownItem(
        topic: 'Transformers & LLMs',
        sessionCount: 4,
        percentage: 33.3,
      ),
    ],
    modeDistribution: const ModeDistribution(
      visual: 5,
      deepDive: 4,
      biteSized: 3,
    ),
    achievements: const [
      AchievementItem(
        id: 'ach_1',
        title: 'Trailblazer',
        description: 'Complete your first milestone journey.',
        unlocked: true,
        icon: 'flag',
      ),
      AchievementItem(
        id: 'ach_2',
        title: 'Sharpshooter',
        description: 'Score 100% on any 3-question milestone check.',
        unlocked: true,
        icon: 'bullseye',
      ),
      AchievementItem(
        id: 'ach_3',
        title: 'On Fire',
        description: 'Maintain an active study streak for 3 consecutive days.',
        unlocked: false,
        icon: 'flame',
      ),
    ],
  );

  Widget createDashboardWidget({
    required double width,
    required double height,
  }) {
    return ProviderScope(
      overrides: [
        dashboardProvider.overrideWith(
          () => _MockDashboardNotifier(dummyDashboardData),
        ),
        learnerStandingProvider.overrideWith(
          () => _MockLearnerStandingNotifier(dummyDashboardData.achievements),
        ),
        authProvider.overrideWith(() => _MockAuthNotifier()),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) {
            final isMobile = Responsive.isMobile(context);
            return Scaffold(
              appBar: isMobile
                  ? const MobileDashboardTopBar()
                  : null,
              body: SizedBox(
                width: width,
                height: height,
                child: const LearningDashboardView(),
              ),
            );
          },
        ),
      ),
    );
  }

  testWidgets(
    'renders cleanly on standard desktop (1280x800) without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createDashboardWidget(width: 1000, height: 800));
      await tester.pumpAndSettle();

      expect(find.text('Growth & Mastery Analytics'), findsOneWidget);
      expect(find.text('Active Study Time'), findsOneWidget);
      expect(find.text('Quiz Comprehension & Accuracy Curve'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'renders cleanly on intermediate screen (900x700 with sidebar) without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(900, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Simulated content width after 280px sidebar = 620px
      await tester.pumpWidget(createDashboardWidget(width: 620, height: 700));
      await tester.pumpAndSettle();

      expect(find.text('Growth & Mastery Analytics'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('renders cleanly on mobile viewport (375x812) without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createDashboardWidget(width: 375, height: 812));
    await tester.pumpAndSettle();

    expect(find.text('Growth & Mastery Analytics'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders cleanly on narrow mobile (320x568) without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createDashboardWidget(width: 320, height: 568));
    await tester.pumpAndSettle();

    expect(find.text('Growth & Mastery Analytics'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'renders command hub header with gradient title and theme toggle',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createDashboardWidget(width: 1280, height: 800));
      await tester.pumpAndSettle();

      expect(find.text('Growth & Mastery Analytics'), findsOneWidget);
      expect(find.byType(ThemeToggleButton), findsOneWidget);
      expect(find.text('ANALYTICS HUB'), findsNothing);
      expect(find.text('LIVE SYNC'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}

class _MockDashboardNotifier extends DashboardNotifier {
  final DashboardResponse _mockData;
  _MockDashboardNotifier(this._mockData);

  @override
  DashboardState build() {
    return DashboardState(isLoading: false, data: _mockData, timeRange: '30d');
  }

  @override
  Future<void> loadDashboard({
    String? timeRange,
    DateTime? startDate,
    DateTime? endDate,
  }) async {}

  @override
  Future<void> setCustomDateRange(DateTime start, DateTime end) async {}

  @override
  Future<void> setTimeRange(String newRange) async {}

  @override
  Future<void> refresh() async {}
}

class _MockLearnerStandingNotifier extends LearnerStandingNotifier {
  final List<AchievementItem> achievements;

  _MockLearnerStandingNotifier([this.achievements = const []]);

  @override
  Future<LearnerStanding> build() async {
    return LearnerStanding(
      totalXp: 1250,
      highestTrophyId: 'bronze',
      highestTrophyTitle: 'Bronze Trophy',
      nextTrophyId: 'silver',
      nextTrophyTitle: 'Silver Trophy',
      trophyProgressFraction: 0.65,
      currentStreak: 5,
      longestStreak: 12,
      achievements: achievements,
    );
  }
}

class _MockAuthNotifier extends AuthNotifier {
  @override
  AuthState build() {
    return AuthState(
      status: AuthStatus.authenticated,
      user: UserCurrentProfileResponse(
        id: 'u1',
        email: 'test@example.com',
        firstName: 'Zeeshan',
        lastName: 'Learner',
        createdAt: DateTime.now(),
      ),
    );
  }
}
