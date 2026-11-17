import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dashboard/dashboard_response.dart';
import '../services/dashboard_service.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService();
});

class DashboardState {
  final bool isLoading;
  final String? error;
  final String timeRange;
  final DashboardResponse? data;

  const DashboardState({
    this.isLoading = false,
    this.error,
    this.timeRange = '30d',
    this.data,
  });

  DashboardState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? timeRange,
    DashboardResponse? data,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      timeRange: timeRange ?? this.timeRange,
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

  Future<void> loadDashboard({String? timeRange}) async {
    final activeRange = timeRange ?? state.timeRange;
    state = state.copyWith(isLoading: true, clearError: true, timeRange: activeRange);

    try {
      final response = await _service.fetchDashboard(timeRange: activeRange);
      state = state.copyWith(isLoading: false, data: response);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> setTimeRange(String newRange) async {
    if (state.timeRange == newRange && !state.isLoading) return;
    await loadDashboard(timeRange: newRange);
  }

  Future<void> refresh() async {
    await loadDashboard(timeRange: state.timeRange);
  }
}

final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(() {
  return DashboardNotifier();
});
