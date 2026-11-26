import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devzees_edutechai_client/core/providers/active_session_provider.dart';
import 'package:devzees_edutechai_client/core/providers/auth_provider.dart';
import 'package:devzees_edutechai_client/core/providers/learning_provider.dart';
import 'package:devzees_edutechai_client/core/providers/session_quota_provider.dart';
import 'package:devzees_edutechai_client/core/providers/user_provider.dart';
import 'package:devzees_edutechai_client/core/theme/theme_palette.dart';
import 'package:devzees_edutechai_client/data/models/auth/user_current_profile_response.dart';
import 'package:devzees_edutechai_client/data/models/learning/milestone_step.dart';
import 'package:devzees_edutechai_client/data/models/learning/session_model.dart';
import 'package:devzees_edutechai_client/data/models/learning/session_response.dart';
import 'package:devzees_edutechai_client/presentation/pages/admin/widgets/admin_sidebar.dart';
import 'package:devzees_edutechai_client/presentation/pages/learning/learning_page.dart';
import 'package:devzees_edutechai_client/presentation/pages/learning/widgets/workspace/unified_learning_command_hub.dart';
import 'package:devzees_edutechai_client/presentation/widgets/smooth_collapsible_sidebar.dart';

class _MockAuthNotifier extends AuthNotifier {
  final UserCurrentProfileResponse user;
  _MockAuthNotifier(this.user);

  @override
  AuthState build() => AuthState(status: AuthStatus.authenticated, user: user);
}

class _MockSessionsNotifier extends SessionsNotifier {
  final SessionsState initialState;
  _MockSessionsNotifier(this.initialState);

  @override
  SessionsState build() => initialState;

  @override
  Future<void> loadInitial() async {}
}

class _MockActiveSessionNotifier extends ActiveSessionNotifier {
  final ActiveSessionState initialState;
  _MockActiveSessionNotifier(this.initialState);

  @override
  ActiveSessionState build() => initialState;
}

class _MockSessionQuotaNotifier extends SessionQuotaNotifier {
  @override
  SessionQuotaState build() => const SessionQuotaState();

  @override
  Future<void> fetchQuota() async {}
}

UserCurrentProfileResponse _mockUser() => UserCurrentProfileResponse(
      id: 'u1',
      firstName: 'Zeeshan',
      lastName: 'Khan',
      email: 'zeeshan@example.com',
      createdAt: DateTime(2026, 1, 1),
      privilegeCodes: const ['LEARNING_DASHBOARD_VIEW', 'ADMIN_ACCESS'],
    );

List<SessionModel> _mockSessions() => [
      SessionModel(
        sessionId: 's1',
        topic: 'Distributed Consensus & Raft Protocol Deep Dive',
        learningMode: 'Deep Dive 🔬',
        studentLevel: 'Undergraduate 🏛️',
        isComplete: false,
        stepsCompleted: 2,
        totalSteps: 6,
        xpEarned: 1200,
        createdAt: DateTime(2026, 1, 1),
      ),
      SessionModel(
        sessionId: 's2',
        topic: 'Quantum Entanglement',
        learningMode: 'Visual 🎬',
        studentLevel: 'High School 🎒',
        isComplete: true,
        stepsCompleted: 5,
        totalSteps: 5,
        xpEarned: 350,
        createdAt: DateTime(2026, 1, 2),
      ),
    ];

SessionResponse _mockSessionResponse() => SessionResponse(
      sessionId: 's1',
      topic: 'Distributed Consensus & Raft Protocol Deep Dive',
      learningMode: 'Deep Dive 🔬',
      studentLevel: 'Undergraduate 🏛️',
      createdAt: DateTime(2026, 1, 1),
      stepsCompleted: 2,
      xpEarned: 120,
      steps: const [
        MilestoneStep(
          index: 0,
          title: 'Leader Election',
          description: 'How Raft elects a cluster leader.',
          status: 'complete',
        ),
        MilestoneStep(
          index: 1,
          title: 'Log Replication',
          description: 'How entries replicate across followers.',
          status: 'in_progress',
        ),
      ],
    );

Future<void> _pumpAnimationFrames(
  WidgetTester tester, {
  int frameCount = 24,
  Duration step = const Duration(milliseconds: 16),
}) async {
  for (int i = 0; i < frameCount; i++) {
    await tester.pump(step);
    final exception = tester.takeException();
    expect(
      exception,
      isNull,
      reason: 'Unexpected layout/overflow exception on animation frame $i: $exception',
    );
  }
}

void main() {
  group('Sidebar expand/collapse overflow checks', () {
    testWidgets(
      'LearningPage collapses and expands sidebar across all animation frames without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final user = _mockUser();
        final sessionResponse = _mockSessionResponse();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(() => _MockAuthNotifier(user)),
              userProvider.overrideWith((ref) async => user),
              sessionsProvider.overrideWith(
                () => _MockSessionsNotifier(
                  SessionsState(items: _mockSessions(), total: 2),
                ),
              ),
              activeSessionProvider.overrideWith(
                () => _MockActiveSessionNotifier(
                  ActiveSessionState(session: sessionResponse),
                ),
              ),
              sessionQuotaProvider.overrideWith(() => _MockSessionQuotaNotifier()),
            ],
            child: MaterialApp(
              home: LearningPage(
                child: Column(
                  children: [
                    UnifiedLearningCommandHub(
                      session: sessionResponse,
                      activeIndex: 1,
                      maxUnlockedIndex: 1,
                      onStepTapped: (_) {},
                    ),
                    const Expanded(child: SizedBox.expand()),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(tester.takeException(), isNull);

        // Collapse sidebar (280 -> 80)
        await tester.tap(find.byIcon(Icons.menu_open));
        await _pumpAnimationFrames(tester, frameCount: 25);
        expect(find.byIcon(Icons.menu), findsOneWidget);

        // Expand sidebar (80 -> 280)
        await tester.tap(find.byIcon(Icons.menu));
        await _pumpAnimationFrames(tester, frameCount: 25);
        expect(find.byIcon(Icons.menu_open), findsOneWidget);
      },
    );

    testWidgets(
      'LearningPage collapses and expands cleanly at tablet width (800px) with command hub',
      (tester) async {
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final user = _mockUser();
        final sessionResponse = _mockSessionResponse();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(() => _MockAuthNotifier(user)),
              userProvider.overrideWith((ref) async => user),
              sessionsProvider.overrideWith(
                () => _MockSessionsNotifier(
                  SessionsState(items: _mockSessions(), total: 2),
                ),
              ),
              activeSessionProvider.overrideWith(
                () => _MockActiveSessionNotifier(
                  ActiveSessionState(session: sessionResponse),
                ),
              ),
              sessionQuotaProvider.overrideWith(() => _MockSessionQuotaNotifier()),
            ],
            child: MaterialApp(
              home: LearningPage(
                child: Column(
                  children: [
                    UnifiedLearningCommandHub(
                      session: sessionResponse,
                      activeIndex: 1,
                      maxUnlockedIndex: 1,
                      onStepTapped: (_) {},
                    ),
                    const Expanded(child: SizedBox.expand()),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(tester.takeException(), isNull);

        // Collapse (280 -> 80)
        await tester.tap(find.byIcon(Icons.menu_open));
        await _pumpAnimationFrames(tester, frameCount: 25);

        // Expand (80 -> 280)
        await tester.tap(find.byIcon(Icons.menu));
        await _pumpAnimationFrames(tester, frameCount: 25);

        // Verify SingleChildScrollView in command hub clips cleanly when visible
        final scrollViews = tester.widgetList<SingleChildScrollView>(
          find.descendant(
            of: find.byType(UnifiedLearningCommandHub),
            matching: find.byType(SingleChildScrollView),
          ),
        );
        for (final sv in scrollViews) {
          expect(sv.clipBehavior, isNot(Clip.none));
        }
      },
    );

    testWidgets(
      'AdminSidebar collapses and expands inside SmoothCollapsibleSidebar without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        bool expanded = true;

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                final colors = context.appColors;
                return Scaffold(
                  body: Row(
                    children: [
                      SmoothCollapsibleSidebar(
                        expanded: expanded,
                        expandedWidth: 260,
                        collapsedWidth: 80,
                        backgroundColor: colors.sidebarBackground,
                        borderColor: colors.border,
                        expandedBuilder: (_) => AdminSidebar(
                          selected: AdminSection.users,
                          expanded: true,
                          onSectionChanged: (_) {},
                        ),
                        collapsedBuilder: (_) => AdminSidebar(
                          selected: AdminSection.users,
                          expanded: false,
                          onSectionChanged: (_) {},
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            key: const Key('admin_toggle'),
                            icon: const Icon(Icons.swap_horiz),
                            onPressed: () => setState(() => expanded = !expanded),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(tester.takeException(), isNull);
        // At rest expanded: only expanded AdminSidebar is mounted
        expect(find.text('User Directory'), findsOneWidget);

        // Collapse (260 -> 80)
        await tester.tap(find.byKey(const Key('admin_toggle')));
        await _pumpAnimationFrames(tester, frameCount: 25);
        expect(find.text('User Directory'), findsNothing);

        // Mid-flight rapid reversal (80 -> 260 -> interrupt at 100ms -> back to 80)
        await tester.tap(find.byKey(const Key('admin_toggle')));
        await _pumpAnimationFrames(tester, frameCount: 6);
        await tester.tap(find.byKey(const Key('admin_toggle')));
        await _pumpAnimationFrames(tester, frameCount: 25);
        expect(find.text('User Directory'), findsNothing);

        // Expand (80 -> 260)
        await tester.tap(find.byKey(const Key('admin_toggle')));
        await _pumpAnimationFrames(tester, frameCount: 25);
        expect(find.text('User Directory'), findsOneWidget);
      },
    );
  });
}
