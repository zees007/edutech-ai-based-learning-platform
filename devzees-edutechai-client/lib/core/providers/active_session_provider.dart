import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/learning/session_response.dart';
import '../../data/models/learning/quiz_result.dart';
import 'learning_provider.dart';
import '../services/learning_service.dart';
import '../services/learning_websocket_service.dart';

final learningWebSocketServiceProvider = Provider<LearningWebSocketService>((ref) {
  final service = LearningWebSocketService();
  ref.onDispose(() => service.disconnect());
  return service;
});

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
  late final LearningWebSocketService _wsService;

  @override
  ActiveSessionState build() {
    _service = ref.watch(learningServiceProvider);
    _wsService = ref.watch(learningWebSocketServiceProvider);
    
    // Listen to websocket events
    _wsService.events.listen(_onWebSocketEvent);
    
    return ActiveSessionState();
  }

  void _onWebSocketEvent(Map<String, dynamic> event) {
    // Handle incoming events like explanation_chunk, quiz, etc.
    final type = event['event_type'];
    if (type == 'explanation_chunk' || type == 'quiz' || type == 'step_complete') {
      // In a real app, we would deeply merge this into the session steps.
      // For now, we will trigger a refresh to load the latest state from backend
      // or selectively apply the updates to state.session.
      // To prevent infinite loops with polling, we only update specific parts.
      // E.g., appending chunks to chat history.
      print('WebSocket Event: $type');
      if (type == 'step_complete' && state.session != null) {
        // Option 1: Refresh full session
        loadSession(state.session!.sessionId);
      }
    }
  }

  Future<void> startNewSession({
    required String topic,
    required String mode,
    required String level,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _service.startJourney(topic: topic, mode: mode, level: level);
      state = state.copyWith(
        session: response,
        activeStepIndex: 0,
        isLoading: false,
      );
      
      // Connect to WebSocket and start the first step
      _wsService.connect(response.sessionId);
      _wsService.sendStartStep(0);
      
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      throw e;
    }
  }

  Future<QuizResult?> submitStepQuiz(int stepIndex, Map<int, String> answers) async {
    final session = state.session;
    if (session == null) return null;
    
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _service.submitQuiz(session.sessionId, stepIndex, answers);
      
      // Update session XP locally
      final updatedSession = session.copyWith(
        xpEarned: session.xpEarned + result.xpEarned,
      );
      
      state = state.copyWith(
        session: updatedSession,
        isLoading: false,
      );
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<void> markStepComplete(int stepIndex) async {
    final session = state.session;
    if (session == null) return;
    
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _service.completeStep(session.sessionId, stepIndex);
      
      // Update XP locally
      final awardedXp = data['xp_earned'] as int? ?? 0;
      final updatedSession = session.copyWith(
        xpEarned: session.xpEarned + awardedXp,
        stepsCompleted: session.stepsCompleted + 1,
      );
      
      state = state.copyWith(
        session: updatedSession,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void sendFollowUpChat(String content) {
    _wsService.sendChat(content);
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
      
      if (!_wsService.isConnected) {
        _wsService.connect(sessionId);
      }
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
    _wsService.disconnect();
    state = state.copyWith(clearSession: true, activeStepIndex: 0);
  }
}

final activeSessionProvider = NotifierProvider<ActiveSessionNotifier, ActiveSessionState>(() {
  return ActiveSessionNotifier();
});
