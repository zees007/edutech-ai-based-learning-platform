import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dashboard/dashboard_response.dart';
import '../services/dashboard_service.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService();
});

// ── 1. Learner Standing Provider (All-time HUD) ──────────────────────
class LearnerStandingNotifier extends AsyncNotifier<LearnerStanding> {
  @override
  Future<LearnerStanding> build() async {
    final service = ref.watch(dashboardServiceProvider);
    return service.fetchStanding();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(dashboardServiceProvider);
      return service.fetchStanding();
    });
  }
}

final learnerStandingProvider = AsyncNotifierProvider<LearnerStandingNotifier, LearnerStanding>(() {
  return LearnerStandingNotifier();
});

// ── 2. Performance Filter & Analytics Providers ───────────────────────
class PerformanceFilterState {
  final String rangeKey; // '7d', '30d', '90d', '1y', 'all', 'custom'
  final DateTime? customStart;
  final DateTime? customEnd;

  const PerformanceFilterState({
    this.rangeKey = '30d',
    this.customStart,
    this.customEnd,
  });

  PerformanceFilterState copyWith({
    String? rangeKey,
    DateTime? customStart,
    DateTime? customEnd,
    bool clearCustomDates = false,
  }) {
    return PerformanceFilterState(
      rangeKey: rangeKey ?? this.rangeKey,
      customStart: clearCustomDates ? null : (customStart ?? this.customStart),
      customEnd: clearCustomDates ? null : (customEnd ?? this.customEnd),
    );
  }
}

class PerformanceFilterNotifier extends Notifier<PerformanceFilterState> {
  @override
  PerformanceFilterState build() {
    return const PerformanceFilterState(rangeKey: '30d');
  }

  void setFilter(PerformanceFilterState filter) {
    state = filter;
  }

  void setRangeKey(String rangeKey) {
    state = state.copyWith(rangeKey: rangeKey, clearCustomDates: rangeKey != 'custom');
  }

  void setCustomRange(DateTime start, DateTime end) {
    state = PerformanceFilterState(rangeKey: 'custom', customStart: start, customEnd: end);
  }
}

final performanceFilterProvider =
    NotifierProvider<PerformanceFilterNotifier, PerformanceFilterState>(() {
  return PerformanceFilterNotifier();
});

final performanceAnalyticsProvider = FutureProvider<PeriodPerformance>((ref) async {
  final filter = ref.watch(performanceFilterProvider);
  final service = ref.watch(dashboardServiceProvider);
  return service.fetchPerformance(
    timeRange: filter.rangeKey,
    startDate: filter.customStart,
    endDate: filter.customEnd,
  );
});

// ── 3. Unified Dashboard Provider (Backward-Compatible) ──────────────
class DashboardState {
  final bool isLoading;
  final String? error;
  final String timeRange;
  final DateTime? customStart;
  final DateTime? customEnd;
  final DashboardResponse? data;

  const DashboardState({
    this.isLoading = false,
    this.error,
    this.timeRange = '30d',
    this.customStart,
    this.customEnd,
    this.data,
  });

  DashboardState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? timeRange,
    DateTime? customStart,
    DateTime? customEnd,
    DashboardResponse? data,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      timeRange: timeRange ?? this.timeRange,
      customStart: customStart ?? this.customStart,
      customEnd: customEnd ?? this.customEnd,
      data: data ?? this.data,
    );
  }
}

class DashboardNotifier extends Notifier<DashboardState> {
  late DashboardService _service;

  @override
  DashboardState build() {
    _service = ref.watch(dashboardServiceProvider);
    return const DashboardState(isLoading: true);
  }

  Future<void> loadDashboard({
    String? timeRange,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final activeRange = timeRange ?? state.timeRange;
    final activeStart = startDate ?? state.customStart;
    final activeEnd = endDate ?? state.customEnd;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      timeRange: activeRange,
      customStart: activeStart,
      customEnd: activeEnd,
    );

    try {
      final response = await _service.fetchDashboard(
        timeRange: activeRange,
        startDate: activeStart,
        endDate: activeEnd,
      );
      state = state.copyWith(isLoading: false, data: response);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> setTimeRange(String newRange) async {
    if (state.timeRange == newRange && newRange != 'custom' && !state.isLoading) return;
    await loadDashboard(timeRange: newRange);
  }

  Future<void> setCustomDateRange(DateTime start, DateTime end) async {
    await loadDashboard(
      timeRange: 'custom',
      startDate: start,
      endDate: end,
    );
  }

  Future<void> refresh() async {
    await loadDashboard(
      timeRange: state.timeRange,
      startDate: state.customStart,
      endDate: state.customEnd,
    );
  }
}

final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(() {
  return DashboardNotifier();
});

// ── 4. Admin User Dashboard Provider (For inspecting any user) ────────
class UserDashboardParams {
  final String userId;
  final String timeRange;

  const UserDashboardParams({
    required this.userId,
    this.timeRange = '30d',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserDashboardParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          timeRange == other.timeRange;

  @override
  int get hashCode => userId.hashCode ^ timeRange.hashCode;
}

final userDashboardFutureProvider =
    FutureProvider.family<DashboardResponse, UserDashboardParams>((ref, params) async {
  final service = ref.watch(dashboardServiceProvider);
  return service.fetchDashboard(userId: params.userId, timeRange: params.timeRange);
});

final userStandingFutureProvider =
    FutureProvider.family<LearnerStanding, String>((ref, userId) async {
  final service = ref.watch(dashboardServiceProvider);
  return service.fetchStanding(userId: userId);
});
