import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/learning/session_response.dart';
import 'learning_provider.dart';
import '../services/learning_service.dart';

class ActiveSessionState {
  final SessionResponse? session;
  final int activeStepIndex;
  final bool isLoading;
  final String? error;

  ActiveSessionState({
    this.session,
    this.activeStepIndex = 0,
    this.isLoading = false,
    this.error,
  });

  ActiveSessionState copyWith({
    SessionResponse? session,
    bool clearSession = false,
    int? activeStepIndex,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ActiveSessionState(
      session: clearSession ? null : (session ?? this.session),
      activeStepIndex: activeStepIndex ?? this.activeStepIndex,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ActiveSessionNotifier extends Notifier<ActiveSessionState> {
  late final LearningService _service;

  @override
  ActiveSessionState build() {
    _service = ref.watch(learningServiceProvider);
    return ActiveSessionState();
  }

  Future<void> loadSession(String sessionId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _service.fetchSessionById(sessionId);
      
      int stepIndex = response.currentStepIndex;
      // Safety check: ensure index is within bounds
      if (response.steps.isNotEmpty && stepIndex >= response.steps.length) {
        stepIndex = 0;
      }

      state = state.copyWith(
        session: response,
        activeStepIndex: stepIndex,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setActiveStep(int index) {
    if (state.session != null && index >= 0 && index < state.session!.steps.length) {
      state = state.copyWith(activeStepIndex: index);
    }
  }

  void clearSession() {
    state = state.copyWith(clearSession: true, activeStepIndex: 0);
  }
}

final activeSessionProvider = NotifierProvider<ActiveSessionNotifier, ActiveSessionState>(() {
  return ActiveSessionNotifier();
});
