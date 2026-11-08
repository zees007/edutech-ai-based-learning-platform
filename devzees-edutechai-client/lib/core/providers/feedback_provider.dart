import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/feedback/feedback_model.dart';
import '../services/feedback_service.dart';

/// Provider for fetching homepage featured testimonials.
final publicTestimonialsProvider =
    FutureProvider<List<PublicFeedbackModel>>((ref) async {
  final service = ref.watch(feedbackServiceProvider);
  return await service.getPublicFeaturedFeedback();
});

/// Event triggered when all session steps are mastered, presenting the feedback dialog first.
class FeedbackPromptEvent {
  final String sessionId;
  final String topic;
  final int totalSteps;
  final int totalXp;
  final int bonusXp;
  final double? averageQuizScore;
  final DateTime timestamp;

  FeedbackPromptEvent({
    required this.sessionId,
    required this.topic,
    required this.totalSteps,
    required this.totalXp,
    required this.bonusXp,
    this.averageQuizScore,
    required this.timestamp,
  });
}

class FeedbackPromptNotifier extends Notifier<FeedbackPromptEvent?> {
  @override
  FeedbackPromptEvent? build() => null;

  void triggerEvent({
    required String sessionId,
    required String topic,
    required int totalSteps,
    required int totalXp,
    required int bonusXp,
    double? averageQuizScore,
  }) {
    state = FeedbackPromptEvent(
      sessionId: sessionId,
      topic: topic,
      totalSteps: totalSteps,
      totalXp: totalXp,
      bonusXp: bonusXp,
      averageQuizScore: averageQuizScore,
      timestamp: DateTime.now(),
    );
  }

  void dismiss() {
    state = null;
  }
}

final feedbackPromptProvider =
    NotifierProvider<FeedbackPromptNotifier, FeedbackPromptEvent?>(() {
  return FeedbackPromptNotifier();
});

/// Admin State for managing submitted feedbacks.
class AdminFeedbackState {
  final bool isLoading;
  final String? errorMessage;
  final List<AdminFeedbackModel> items;
  final int total;
  final AdminFeedbackSummaryMetrics? metrics;
  final String selectedStatus; // 'all', 'pending', 'featured', 'archived'
  final String searchQuery;
  final int page;
  final int pageSize;
  final Set<String> updatingFeedbackIds;

  const AdminFeedbackState({
    this.isLoading = false,
    this.errorMessage,
    this.items = const [],
    this.total = 0,
    this.metrics,
    this.selectedStatus = 'pending',
    this.searchQuery = '',
    this.page = 0,
    this.pageSize = 10,
    this.updatingFeedbackIds = const {},
  });

  bool isFeedbackUpdating(String feedbackId) =>
      updatingFeedbackIds.contains(feedbackId);

  AdminFeedbackState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<AdminFeedbackModel>? items,
    int? total,
    AdminFeedbackSummaryMetrics? metrics,
    String? selectedStatus,
    String? searchQuery,
    int? page,
    int? pageSize,
    Set<String>? updatingFeedbackIds,
  }) {
    return AdminFeedbackState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      items: items ?? this.items,
      total: total ?? this.total,
      metrics: metrics ?? this.metrics,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      updatingFeedbackIds: updatingFeedbackIds ?? this.updatingFeedbackIds,
    );
  }
}

class AdminFeedbackNotifier extends Notifier<AdminFeedbackState> {
  @override
  AdminFeedbackState build() {
    return const AdminFeedbackState();
  }

  Future<void> loadFeedbacks({
    String? status,
    String? query,
    int? page,
  }) async {
    final currentStatus = status ?? state.selectedStatus;
    final currentQuery = query ?? state.searchQuery;
    final currentPage = page ?? state.page;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      selectedStatus: currentStatus,
      searchQuery: currentQuery,
      page: currentPage,
    );

    try {
      final service = ref.read(feedbackServiceProvider);
      final response = await service.getAdminFeedbacks(
        status: currentStatus,
        lookupText: currentQuery,
        page: currentPage,
        size: state.pageSize,
      );

      state = state.copyWith(
        isLoading: false,
        items: response.items,
        total: response.total,
        metrics: response.metrics,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<bool> updateStatus({
    required String feedbackId,
    required String newStatus,
    String? adminNotes,
  }) async {
    // Immediately mark item as updating so UI displays an inline loader
    final nextUpdating = Set<String>.from(state.updatingFeedbackIds)
      ..add(feedbackId);
    state = state.copyWith(
      updatingFeedbackIds: nextUpdating,
      errorMessage: null,
    );

    try {
      final service = ref.read(feedbackServiceProvider);
      final updatedItem = await service.updateFeedbackStatus(
        feedbackId: feedbackId,
        status: newStatus,
        adminNotes: adminNotes,
      );

      // Invalidate public testimonials cache so homepage immediately reflects change
      ref.invalidate(publicTestimonialsProvider);

      // Compute local metrics update
      final oldItemIndex = state.items.indexWhere(
        (it) => it.feedbackId == feedbackId,
      );
      final oldStatus =
          oldItemIndex != -1 ? state.items[oldItemIndex].status : null;

      AdminFeedbackSummaryMetrics? updatedMetrics = state.metrics;
      if (updatedMetrics != null && oldStatus != null && oldStatus != newStatus) {
        int pendingDelta = 0;
        int featuredDelta = 0;
        int archivedDelta = 0;

        if (oldStatus == 'pending') pendingDelta--;
        if (oldStatus == 'featured') featuredDelta--;
        if (oldStatus == 'archived') archivedDelta--;

        if (newStatus == 'pending') pendingDelta++;
        if (newStatus == 'featured') featuredDelta++;
        if (newStatus == 'archived') archivedDelta++;

        updatedMetrics = AdminFeedbackSummaryMetrics(
          totalCount: updatedMetrics.totalCount,
          pendingCount: (updatedMetrics.pendingCount + pendingDelta).clamp(
            0,
            999999,
          ),
          featuredCount: (updatedMetrics.featuredCount + featuredDelta).clamp(
            0,
            999999,
          ),
          archivedCount: (updatedMetrics.archivedCount + archivedDelta).clamp(
            0,
            999999,
          ),
          averageRating: updatedMetrics.averageRating,
        );
      }

      // Update state in-place with the returned updated item (zero wait for full re-fetch)
      final updatedItems = state.items.map((it) {
        return it.feedbackId == feedbackId ? updatedItem : it;
      }).toList();

      final finishUpdating = Set<String>.from(state.updatingFeedbackIds)
        ..remove(feedbackId);

      state = state.copyWith(
        items: updatedItems,
        metrics: updatedMetrics,
        updatingFeedbackIds: finishUpdating,
      );

      return true;
    } catch (e) {
      final finishUpdating = Set<String>.from(state.updatingFeedbackIds)
        ..remove(feedbackId);
      state = state.copyWith(
        updatingFeedbackIds: finishUpdating,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }
}

final adminFeedbackProvider =
    NotifierProvider<AdminFeedbackNotifier, AdminFeedbackState>(() {
  return AdminFeedbackNotifier();
});
