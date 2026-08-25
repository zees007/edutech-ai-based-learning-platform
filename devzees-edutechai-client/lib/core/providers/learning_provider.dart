import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/learning/session_model.dart';
import '../services/learning_service.dart';

final learningServiceProvider = Provider<LearningService>((ref) {
  return LearningService();
});

class SessionsState {
  final List<SessionModel> items;
  final bool isLoading;
  final bool isFetchingMore;
  final String? error;
  final int total;
  final int page;
  final int size;
  final String? lookupText;
  final String statusFilter;
  final bool hasReachedMax;

  SessionsState({
    this.items = const [],
    this.isLoading = false,
    this.isFetchingMore = false,
    this.error,
    this.total = 0,
    this.page = 0,
    this.size = 20,
    this.lookupText,
    this.statusFilter = 'all',
    this.hasReachedMax = false,
  });

  SessionsState copyWith({
    List<SessionModel>? items,
    bool? isLoading,
    bool? isFetchingMore,
    String? error,
    bool clearError = false,
    int? total,
    int? page,
    int? size,
    String? lookupText,
    bool clearLookupText = false,
    String? statusFilter,
    bool? hasReachedMax,
  }) {
    return SessionsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      error: clearError ? null : (error ?? this.error),
      total: total ?? this.total,
      page: page ?? this.page,
      size: size ?? this.size,
      lookupText: clearLookupText ? null : (lookupText ?? this.lookupText),
      statusFilter: statusFilter ?? this.statusFilter,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class SessionsNotifier extends Notifier<SessionsState> {
  late final LearningService _service;

  @override
  SessionsState build() {
    _service = ref.watch(learningServiceProvider);
    return SessionsState();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, clearError: true, page: 0, items: [], hasReachedMax: false);
    try {
      final response = await _service.fetchSessions(
        page: 0,
        size: state.size,
        lookupText: state.lookupText,
        statusFilter: state.statusFilter,
      );
      
      state = state.copyWith(
        items: response.items,
        total: response.total,
        isLoading: false,
        hasReachedMax: response.items.length < state.size,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isFetchingMore || state.hasReachedMax) return;
    
    state = state.copyWith(isFetchingMore: true, clearError: true);
    
    try {
      final nextPage = state.page + 1;
      final response = await _service.fetchSessions(
        page: nextPage,
        size: state.size,
        lookupText: state.lookupText,
        statusFilter: state.statusFilter,
      );

      state = state.copyWith(
        items: [...state.items, ...response.items],
        total: response.total,
        page: nextPage,
        isFetchingMore: false,
        hasReachedMax: response.items.length < state.size,
      );
    } catch (e) {
      state = state.copyWith(isFetchingMore: false, error: e.toString());
    }
  }

  void updateSearch(String query) {
    if (query.trim().isEmpty) {
      state = state.copyWith(clearLookupText: true);
    } else {
      state = state.copyWith(lookupText: query.trim());
    }
    loadInitial();
  }

  void updateFilter(String filter) {
    if (state.statusFilter != filter) {
      state = state.copyWith(statusFilter: filter);
      loadInitial();
    }
  }
}

final sessionsProvider = NotifierProvider<SessionsNotifier, SessionsState>(() {
  return SessionsNotifier();
});
