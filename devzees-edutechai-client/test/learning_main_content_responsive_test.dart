import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devzees_edutechai_client/core/providers/auth_provider.dart';
import 'package:devzees_edutechai_client/core/providers/learning_provider.dart';
import 'package:devzees_edutechai_client/core/providers/session_quota_provider.dart';
import 'package:devzees_edutechai_client/core/services/subscription_service.dart';
import 'package:devzees_edutechai_client/data/models/learning/session_model.dart';
import 'package:devzees_edutechai_client/data/models/subscription/payment_models.dart';
import 'package:devzees_edutechai_client/presentation/pages/learning/widgets/main_content/learning_main_content.dart';
import 'package:devzees_edutechai_client/presentation/pages/learning/widgets/main_content/recent_journey_card.dart';
import 'package:devzees_edutechai_client/presentation/pages/learning/widgets/main_content/recent_journey_skeleton.dart';

class _MockAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => AuthState(status: AuthStatus.unauthenticated);
}

class _MockSessionsNotifier extends SessionsNotifier {
  final SessionsState initialState;
  _MockSessionsNotifier(this.initialState);

  @override
  SessionsState build() => initialState;
}

class _MockSessionQuotaNotifier extends SessionQuotaNotifier {
  @override
  SessionQuotaState build() => const SessionQuotaState();

  @override
  Future<void> fetchQuota() async {}
}

List<SessionModel> _sampleSessions() {
  return [
    SessionModel(
      sessionId: 's1',
      topic: 'Distributed Consensus & Raft',
      learningMode: 'Deep Dive 🔬',
      studentLevel: 'Undergraduate 🏛️',
      isComplete: false,
      stepsCompleted: 2,
      totalSteps: 6,
      xpEarned: 120,
      createdAt: DateTime(2026, 1, 1),
    ),
    SessionModel(
      sessionId: 's2',
      topic: 'Quantum Entanglement Basics',
      learningMode: 'Visual 🎬',
      studentLevel: 'High School 🎒',
      isComplete: false,
      stepsCompleted: 1,
      totalSteps: 5,
      xpEarned: 60,
      createdAt: DateTime(2026, 1, 2),
    ),
    SessionModel(
      sessionId: 's3',
      topic: 'Transformer Self-Attention',
      learningMode: 'Bite-Sized ⚡',
      studentLevel: 'Graduate 🎓',
      isComplete: false,
      stepsCompleted: 3,
      totalSteps: 4,
      xpEarned: 180,
      createdAt: DateTime(2026, 1, 3),
    ),
  ];
}

Widget _buildTestApp({
  required SessionsState sessionsState,
  required bool isMobile,
  bool includeSidebar = false,
}) {
  const mockCatalog = PricingCatalogModel(currency: 'USD', tiers: {});
  return ProviderScope(
    overrides: [
      authProvider.overrideWith(() => _MockAuthNotifier()),
      sessionsProvider.overrideWith(() => _MockSessionsNotifier(sessionsState)),
      sessionQuotaProvider.overrideWith(() => _MockSessionQuotaNotifier()),
      pricingCatalogProvider.overrideWith((ref) => Future.value(mockCatalog)),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: includeSidebar
            ? Row(
                children: [
                  const SizedBox(width: 280),
                  Expanded(child: LearningMainContent(isMobile: isMobile)),
                ],
              )
            : LearningMainContent(isMobile: isMobile),
      ),
    ),
  );
}

void main() {
  group('LearningMainContent Responsive Recent Journeys', () {
    testWidgets('mobile uses clipped horizontal carousel without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildTestApp(
          sessionsState: SessionsState(items: _sampleSessions()),
          isMobile: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RecentJourneyCard), findsNWidgets(3));
      final scrollView = tester.widget<SingleChildScrollView>(
        find.byWidgetPredicate(
          (w) =>
              w is SingleChildScrollView &&
              w.scrollDirection == Axis.horizontal &&
              w.clipBehavior == Clip.hardEdge,
        ),
      );
      expect(scrollView.clipBehavior, Clip.hardEdge);
      expect(tester.takeException(), isNull);
    });

    testWidgets('mobile loading skeletons use clipped horizontal carousel without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildTestApp(
          sessionsState: SessionsState(isLoading: true),
          isMobile: true,
        ),
      );
      await tester.pump();

      expect(find.byType(RecentJourneySkeletonCard), findsNWidgets(3));
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is SingleChildScrollView &&
              w.scrollDirection == Axis.horizontal &&
              w.clipBehavior == Clip.hardEdge,
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('tablet (768px with 280px sidebar) displays all 3 compact cards in one row', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildTestApp(
          sessionsState: SessionsState(items: _sampleSessions()),
          isMobile: false,
          includeSidebar: true,
        ),
      );
      await tester.pumpAndSettle();

      final cards = tester.widgetList<RecentJourneyCard>(find.byType(RecentJourneyCard)).toList();
      expect(cards.length, 3);
      expect(cards.every((c) => c.isCompact), isTrue);

      // All 3 cards sit on the same row and inside the right edge of the 768px viewport
      final box0 = tester.getRect(find.byType(RecentJourneyCard).at(0));
      final box1 = tester.getRect(find.byType(RecentJourneyCard).at(1));
      final box2 = tester.getRect(find.byType(RecentJourneyCard).at(2));
      expect((box0.top - box1.top).abs(), lessThan(1.0));
      expect((box1.top - box2.top).abs(), lessThan(1.0));
      expect(box2.right, lessThanOrEqualTo(768.0));
      expect(tester.takeException(), isNull);
    });

    testWidgets('desktop (1440px with 280px sidebar) displays all 3 standard cards cleanly', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildTestApp(
          sessionsState: SessionsState(items: _sampleSessions()),
          isMobile: false,
          includeSidebar: true,
        ),
      );
      await tester.pumpAndSettle();

      final cards = tester.widgetList<RecentJourneyCard>(find.byType(RecentJourneyCard)).toList();
      expect(cards.length, 3);
      expect(cards.every((c) => !c.isCompact), isTrue);
      expect(tester.takeException(), isNull);
    });
  });
}
