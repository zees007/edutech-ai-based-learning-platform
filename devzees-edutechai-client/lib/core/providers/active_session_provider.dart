import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/learning/session_model.dart';
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
  final bool isSynthesizing;
  final String? error;

  ActiveSessionState({
    this.session,
    this.activeStepIndex = 0,
    this.isLoading = false,
    this.isSynthesizing = false,
    this.error,
  });

  ActiveSessionState copyWith({
    SessionResponse? session,
    bool clearSession = false,
    int? activeStepIndex,
    bool? isLoading,
    bool? isSynthesizing,
    String? error,
    bool clearError = false,
  }) {
    return ActiveSessionState(
      session: clearSession ? null : (session ?? this.session),
      activeStepIndex: activeStepIndex ?? this.activeStepIndex,
      isLoading: isLoading ?? this.isLoading,
      isSynthesizing: isSynthesizing ?? this.isSynthesizing,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ActiveSessionNotifier extends Notifier<ActiveSessionState> {
  late final LearningService _service;
  late final LearningWebSocketService _wsService;

  // ─── Performance & Render Timing Stopwatches ────────────────────────
  final Stopwatch _stepTotalStopwatch = Stopwatch();
  final Stopwatch _backendStopwatch = Stopwatch();
  final Stopwatch _apiFetchStopwatch = Stopwatch();
  final Stopwatch _uiRenderStopwatch = Stopwatch();

  int _lastBackendMs = 0;
  int _lastApiFetchMs = 0;
  int _currentTrackingStepIndex = 0;
  bool _isStepGenerationActive = false;

  @override
  ActiveSessionState build() {
    _service = ref.watch(learningServiceProvider);
    _wsService = ref.watch(learningWebSocketServiceProvider);
    
    // Listen to websocket events
    _wsService.events.listen(_onWebSocketEvent);
    
    return ActiveSessionState();
  }

  void _onWebSocketEvent(Map<String, dynamic> event) {
    final type = event['event_type'];
    final session = state.session;
    if (session == null) return;

    if (type == 'plan') {
      debugPrint('📋 [Client WS] Received "plan" event.');
      if (state.activeStepIndex < session.steps.length) {
        final step = session.steps[state.activeStepIndex];
        if (step.tutorExplanation == null) {
          _currentTrackingStepIndex = state.activeStepIndex;
          if (!_stepTotalStopwatch.isRunning) {
            _stepTotalStopwatch.reset();
            _stepTotalStopwatch.start();
          }
          _backendStopwatch.reset();
          _backendStopwatch.start();
          _isStepGenerationActive = true;

          debugPrint('🚀 [Client] Triggering backend agents for Step $_currentTrackingStepIndex (loader displayed)...');
          state = state.copyWith(isLoading: true, isSynthesizing: true);
          _wsService.sendStartStep(state.activeStepIndex);
        }
      }
      return;
    }

    if (type == 'status') {
      final statusMsg = event['status'] ?? '';
      debugPrint('⏳ [Client WS] Agent Progress: $statusMsg (+${_backendStopwatch.elapsedMilliseconds}ms)');
      return;
    }

    // Render the UI only when all agents finish their job
    if (type == 'step_complete') {
      _backendStopwatch.stop();
      _lastBackendMs = _backendStopwatch.elapsedMilliseconds;
      debugPrint('✅ [Client WS] "step_complete" received for Step $_currentTrackingStepIndex in ${_lastBackendMs}ms (${(_lastBackendMs / 1000).toStringAsFixed(2)}s). Fetching full session data...');
      loadSession(session.sessionId, fromStepComplete: true);
      return;
    }

    if (type == 'error') {
      debugPrint('❌ [Client WS] Error event received: ${event['message']}');
    }
  }

  Future<void> startNewSession({
    required String topic,
    required String mode,
    required String level,
  }) async {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🚀 [Client] Starting new journey for "$topic" ($mode, $level)...');
    _stepTotalStopwatch.reset();
    _stepTotalStopwatch.start();
    _isStepGenerationActive = true;
    _currentTrackingStepIndex = 0;

    state = state.copyWith(isLoading: true, isSynthesizing: true, clearError: true);
    try {
      final journeyApiWatch = Stopwatch()..start();
      final response = await _service.startJourney(topic: topic, mode: mode, level: level);
      journeyApiWatch.stop();
      debugPrint('📋 [Client API] Orchestrator milestone plan created in ${journeyApiWatch.elapsedMilliseconds}ms (${(journeyApiWatch.elapsedMilliseconds / 1000).toStringAsFixed(2)}s). Total steps: ${response.steps.length}');

      state = state.copyWith(
        session: response,
        activeStepIndex: 0,
        isLoading: true,
        isSynthesizing: true, // Keep neural loader visible while step 0 agents run
      );
      
      // Prepend to sessionsProvider immediately so history sidebar & recent journeys update in real time
      ref.read(sessionsProvider.notifier).prependSession(
        SessionModel(
          sessionId: response.sessionId,
          topic: response.topic,
          learningMode: response.learningMode,
          studentLevel: response.studentLevel,
          isComplete: false,
          stepsCompleted: response.stepsCompleted,
          totalSteps: response.steps.length,
          xpEarned: response.xpEarned,
          createdAt: response.createdAt,
        ),
      );

      // Connect to WebSocket and start the first step automatically via plan event
      _wsService.connect(response.sessionId);
    } catch (e) {
      _isStepGenerationActive = false;
      _stepTotalStopwatch.stop();
      state = state.copyWith(isLoading: false, isSynthesizing: false, error: e.toString());
      rethrow;
    }
  }

  Future<QuizResult?> submitStepQuiz(int stepIndex, Map<int, String> answers) async {
    final session = state.session;
    if (session == null) return null;
    
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final quizWatch = Stopwatch()..start();
      final result = await _service.submitQuiz(session.sessionId, stepIndex, answers);
      quizWatch.stop();
      debugPrint('📝 [Client API] Quiz evaluated in ${quizWatch.elapsedMilliseconds}ms. Awarded XP: ${result.xpEarned}');
      
      // Update session XP locally
      final updatedSession = session.copyWith(
        xpEarned: session.xpEarned + result.xpEarned,
      );
      
      _uiRenderStopwatch.reset();
      _uiRenderStopwatch.start();

      state = state.copyWith(
        session: updatedSession,
        isLoading: false,
      );

      // Sync progress with learning history list
      ref.read(sessionsProvider.notifier).updateSessionProgress(
        sessionId: session.sessionId,
        stepsCompleted: updatedSession.stepsCompleted,
        xpEarned: updatedSession.xpEarned,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _uiRenderStopwatch.stop();
        debugPrint('🎨 [Client UI] Quiz results rendered to screen in ${_uiRenderStopwatch.elapsedMilliseconds}ms');
      });

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

      // Sync progress with learning history list
      ref.read(sessionsProvider.notifier).updateSessionProgress(
        sessionId: session.sessionId,
        stepsCompleted: updatedSession.stepsCompleted,
        xpEarned: updatedSession.xpEarned,
        isComplete: updatedSession.stepsCompleted >= updatedSession.steps.length,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void sendFollowUpChat(String content) {
    _wsService.sendChat(content);
  }

  Future<void> loadSession(String sessionId, {bool fromStepComplete = false}) async {
    _apiFetchStopwatch.reset();
    _apiFetchStopwatch.start();

    state = state.copyWith(
      isLoading: true,
      isSynthesizing: fromStepComplete,
      clearError: true,
    );
    try {
      final response = await _service.fetchSessionById(sessionId);
      _apiFetchStopwatch.stop();
      _lastApiFetchMs = _apiFetchStopwatch.elapsedMilliseconds;
      
      int stepIndex = response.currentStepIndex;
      // Safety check: ensure index is within bounds
      if (response.steps.isNotEmpty && stepIndex >= response.steps.length) {
        stepIndex = 0;
      }

      debugPrint('📥 [Client API] Session payload retrieved in ${_lastApiFetchMs}ms. Initiating UI render for Step $stepIndex...');

      _uiRenderStopwatch.reset();
      _uiRenderStopwatch.start();

      final targetStepIndex = stepIndex;
      final wasStepGeneration = _isStepGenerationActive || fromStepComplete;

      state = state.copyWith(
        session: response,
        activeStepIndex: stepIndex,
        isLoading: false,
        isSynthesizing: false,
      );

      // Measure time until the frame is laid out and painted on screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _uiRenderStopwatch.stop();
        final renderMs = _uiRenderStopwatch.elapsedMilliseconds;

        if (wasStepGeneration && _stepTotalStopwatch.isRunning) {
          _stepTotalStopwatch.stop();
          final totalMs = _stepTotalStopwatch.elapsedMilliseconds;
          debugPrint('''
╔════════════════════════════════════════════════════════════════════
║ 🎨 [Client UI Render Performance] Step $targetStepIndex
╟────────────────────────────────────────────────────────────────────
║  • Backend Agents Pipeline (WS):   ${_lastBackendMs.toString().padLeft(6)} ms (${(_lastBackendMs / 1000).toStringAsFixed(2)}s)
║  • Session Data Fetch (HTTP API):   ${_lastApiFetchMs.toString().padLeft(6)} ms (${(_lastApiFetchMs / 1000).toStringAsFixed(2)}s)
║  • Flutter UI Build & Frame Paint:  ${renderMs.toString().padLeft(6)} ms (${(renderMs / 1000).toStringAsFixed(2)}s)
╟────────────────────────────────────────────────────────────────────
║  ⚡ TOTAL TIME TO RENDER STEP UI:    ${totalMs.toString().padLeft(6)} ms (${(totalMs / 1000).toStringAsFixed(2)}s)
╚════════════════════════════════════════════════════════════════════''');
          _isStepGenerationActive = false;
        } else {
          debugPrint('''
╔════════════════════════════════════════════════════════════════════
║ 🎨 [Client UI Render Performance] Session Loaded
╟────────────────────────────────────────────────────────────────────
║  • Session Data Fetch (HTTP API):   ${_lastApiFetchMs.toString().padLeft(6)} ms
║  • Flutter UI Build & Frame Paint:  ${renderMs.toString().padLeft(6)} ms
╟────────────────────────────────────────────────────────────────────
║  ⚡ TOTAL TIME TO RENDER UI:         ${(_lastApiFetchMs + renderMs).toString().padLeft(6)} ms
╚════════════════════════════════════════════════════════════════════''');
        }
      });
      
      // Only connect to WebSocket if it's a new session load, to avoid double "plan" events
      // when refreshing the session data after step_complete.
      if (!fromStepComplete) {
        _wsService.connect(sessionId);
      }
    } catch (e) {
      _uiRenderStopwatch.stop();
      _stepTotalStopwatch.stop();
      _isStepGenerationActive = false;
      state = state.copyWith(isLoading: false, isSynthesizing: false, error: e.toString());
    }
  }

  void setActiveStep(int index) {
    if (state.session != null && index >= 0 && index < state.session!.steps.length) {
      final step = state.session!.steps[index];
      if (step.tutorExplanation == null) {
        debugPrint('🚀 [Client] Switching to ungenerated Step $index. Requesting backend generation...');
        _currentTrackingStepIndex = index;
        _stepTotalStopwatch.reset();
        _stepTotalStopwatch.start();
        _backendStopwatch.reset();
        _backendStopwatch.start();
        _isStepGenerationActive = true;

        state = state.copyWith(activeStepIndex: index, isLoading: true, isSynthesizing: true);
        _wsService.sendStartStep(index);
      } else {
        debugPrint('🔄 [Client] Switching to cached Step $index...');
        _uiRenderStopwatch.reset();
        _uiRenderStopwatch.start();

        state = state.copyWith(activeStepIndex: index);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _uiRenderStopwatch.stop();
          debugPrint('🎨 [Client UI] Step $index UI rendered to screen in ${_uiRenderStopwatch.elapsedMilliseconds}ms (frame layout & paint)');
        });
      }
    }
  }

  void clearSession() {
    _wsService.disconnect();
    state = state.copyWith(
      clearSession: true,
      activeStepIndex: 0,
      isLoading: false,
      isSynthesizing: false,
    );
  }
}

final activeSessionProvider = NotifierProvider<ActiveSessionNotifier, ActiveSessionState>(() {
  return ActiveSessionNotifier();
});
