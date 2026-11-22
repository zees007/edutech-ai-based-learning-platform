import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/core/providers/auth_provider.dart';
import 'package:devzees_edutechai_client/core/providers/dashboard_provider.dart';
import 'package:devzees_edutechai_client/core/providers/learning_provider.dart';
import 'package:devzees_edutechai_client/core/providers/active_session_provider.dart';
import 'package:devzees_edutechai_client/data/models/auth/user_current_profile_response.dart';
import 'package:devzees_edutechai_client/data/models/dashboard/dashboard_response.dart';
import 'package:devzees_edutechai_client/core/services/dashboard_service.dart';

class _FakeDashboardService extends DashboardService {
  String currentUserId = 'ultra_id';

  @override
  Future<LearnerStanding> fetchStanding({String? userId}) async {
    final effectiveId = userId ?? currentUserId;
    if (effectiveId == 'ultra_id') {
      return const LearnerStanding(
        totalXp: 1050,
        highestTrophyId: 'gold',
        highestTrophyTitle: 'Gold Trophy',
        nextTrophyId: 'platinum',
        nextTrophyTitle: 'Platinum Trophy',
        trophyProgressFraction: 0.5,
        currentStreak: 3,
        longestStreak: 5,
        achievements: [
          AchievementItem(id: 'bronze', title: 'Bronze Trophy', description: '', icon: 'bronze', unlocked: true),
          AchievementItem(id: 'silver', title: 'Silver Trophy', description: '', icon: 'silver', unlocked: true),
          AchievementItem(id: 'gold', title: 'Gold Trophy', description: '', icon: 'gold', unlocked: true),
          AchievementItem(id: 'platinum', title: 'Platinum Trophy', description: '', icon: 'platinum', unlocked: false),
          AchievementItem(id: 'sapphire', title: 'Sapphire Trophy', description: '', icon: 'sapphire', unlocked: false),
          AchievementItem(id: 'diamond', title: 'Diamond Trophy', description: '', icon: 'diamond', unlocked: false),
        ],
      );
    } else {
      return const LearnerStanding(
        totalXp: 320,
        highestTrophyId: null,
        highestTrophyTitle: 'Unranked',
        nextTrophyId: 'bronze',
        nextTrophyTitle: 'Bronze Trophy',
        trophyProgressFraction: 0.6,
        currentStreak: 0,
        longestStreak: 1,
        achievements: [
          AchievementItem(id: 'bronze', title: 'Bronze Trophy', description: '', icon: 'bronze', unlocked: false),
          AchievementItem(id: 'silver', title: 'Silver Trophy', description: '', icon: 'silver', unlocked: false),
          AchievementItem(id: 'gold', title: 'Gold Trophy', description: '', icon: 'gold', unlocked: false),
          AchievementItem(id: 'platinum', title: 'Platinum Trophy', description: '', icon: 'platinum', unlocked: false),
          AchievementItem(id: 'sapphire', title: 'Sapphire Trophy', description: '', icon: 'sapphire', unlocked: false),
          AchievementItem(id: 'diamond', title: 'Diamond Trophy', description: '', icon: 'diamond', unlocked: false),
        ],
      );
    }
  }

  @override
  Future<DashboardResponse> fetchDashboard({
    String? userId,
    String timeRange = '30d',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final effectiveId = userId ?? currentUserId;
    if (effectiveId == 'ultra_id') {
      return const DashboardResponse(
        summary: DashboardSummary(totalXp: 1050, currentStreak: 3),
        quizMetrics: QuizMetrics(),
        activityHeatmap: [],
        topicBreakdown: [],
        modeDistribution: ModeDistribution(),
        achievements: [
          AchievementItem(id: 'bronze', title: 'Bronze Trophy', description: '', icon: 'bronze', unlocked: true),
          AchievementItem(id: 'silver', title: 'Silver Trophy', description: '', icon: 'silver', unlocked: true),
          AchievementItem(id: 'gold', title: 'Gold Trophy', description: '', icon: 'gold', unlocked: true),
        ],
      );
    } else {
      return const DashboardResponse(
        summary: DashboardSummary(totalXp: 320, currentStreak: 0),
        quizMetrics: QuizMetrics(),
        activityHeatmap: [],
        topicBreakdown: [],
        modeDistribution: ModeDistribution(),
        achievements: [],
      );
    }
  }
}

void main() {
  test('Riverpod state cleanly purges and switches standing between user accounts', () async {
    final fakeService = _FakeDashboardService();
    final container = ProviderContainer(
      overrides: [
        dashboardServiceProvider.overrideWithValue(fakeService),
      ],
    );
    addTearDown(container.dispose);

    final ultraProfile = UserCurrentProfileResponse(
      id: 'ultra_id',
      email: 'ultra@gmail.com',
      firstName: 'Ultra',
      lastName: 'User',
      createdAt: DateTime.now(),
      roles: ['USER'],
      privilegeCodes: ['ET_DASHBOARD'],
    );

    final freeProfile = UserCurrentProfileResponse(
      id: 'free_id',
      email: 'free@gmail.com',
      firstName: 'Free',
      lastName: 'User',
      createdAt: DateTime.now(),
      roles: ['USER'],
      privilegeCodes: ['ET_DASHBOARD'],
    );

    // 1. Simulate initial ultra login
    fakeService.currentUserId = 'ultra_id';
    container.read(authProvider.notifier).setUser(ultraProfile);

    expect(container.read(currentUserIdProvider), 'ultra_id');

    // Read standing for ultra
    final ultraStanding = await container.read(learnerStandingProvider.future);
    expect(ultraStanding.highestTrophyTitle, 'Gold Trophy');
    expect(ultraStanding.totalXp, 1050);
    expect(ultraStanding.currentStreak, 3);
    expect(ultraStanding.achievements.where((a) => a.unlocked).length, 3);

    // 2. Perform forceLogout / sign out
    container.read(authProvider.notifier).forceLogout();

    expect(container.read(currentUserIdProvider), isNull);

    // Standing should reset to unranked empty standing immediately
    final loggedOutStanding = await container.read(learnerStandingProvider.future);
    expect(loggedOutStanding.highestTrophyTitle, 'Unranked');
    expect(loggedOutStanding.totalXp, 0);
    expect(loggedOutStanding.achievements, isEmpty);

    // Dashboard state data, sessions, and active session should be clean
    expect(container.read(dashboardProvider).data, isNull);
    expect(container.read(sessionsProvider).items, isEmpty);
    expect(container.read(activeSessionProvider).session, isNull);

    // 3. Login as free@gmail.com
    fakeService.currentUserId = 'free_id';
    container.read(authProvider.notifier).setUser(freeProfile);

    expect(container.read(currentUserIdProvider), 'free_id');

    // Standing should now be fetched for free@gmail.com
    final freeStanding = await container.read(learnerStandingProvider.future);
    expect(freeStanding.highestTrophyTitle, 'Unranked');
    expect(freeStanding.totalXp, 320);
    expect(freeStanding.currentStreak, 0);
    expect(freeStanding.achievements.where((a) => a.unlocked).length, 0);
    expect(freeStanding.nextTrophyTitle, 'Bronze Trophy');
  });
}
