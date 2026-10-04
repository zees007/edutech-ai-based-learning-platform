import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/learning/session_model.dart';
import '../../data/models/learning/session_response.dart';
import '../../data/models/learning/milestone_step.dart';
import '../../data/models/learning/quiz_result.dart';
import 'learning_provider.dart';
import '../services/learning_service.dart';
import '../services/learning_websocket_service.dart';
import 'gamification_provider.dart';

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
  final Set<int> curatingVideoSteps;
  final String? error;

  ActiveSessionState({
    this.session,
    this.activeStepIndex = 0,
    this.isLoading = false,
    this.isSynthesizing = false,
    this.curatingVideoSteps = const {},
    this.error,
  });

  ActiveSessionState copyWith({
    SessionResponse? session,
    bool clearSession = false,
    int? activeStepIndex,
    bool? isLoading,
    bool? isSynthesizing,
    Set<int>? curatingVideoSteps,
    String? error,
    bool clearError = false,
  }) {
    return ActiveSessionState(
      session: clearSession ? null : (session ?? this.session),
      activeStepIndex: activeStepIndex ?? this.activeStepIndex,
      isLoading: isLoading ?? this.isLoading,
      isSynthesizing: isSynthesizing ?? this.isSynthesizing,
      curatingVideoSteps: curatingVideoSteps ?? this.curatingVideoSteps,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ActiveSessionNotifier extends Notifier<ActiveSessionState> {
  late LearningService _service;
  late LearningWebSocketService _wsService;

  // ─── Performance & Render Timing Stopwatches ────────────────────────
  final Stopwatch _stepTotalStopwatch = Stopwatch();
  final Stopwatch _backendStopwatch = Stopwatch();
  final Stopwatch _apiFetchStopwatch = Stopwatch();
  final Stopwatch _uiRenderStopwatch = Stopwatch();

  int _lastBackendMs = 0;
  int _lastApiFetchMs = 0;
  int _currentTrackingStepIndex = 0;
  bool _isStepGenerationActive = false;
  bool _isRegenerating = false;

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
          // Guard: block only if generation is already running for a DIFFERENT step.
          // When setActiveStep() reconnects the WS and returns early, it sets
          // _isStepGenerationActive=true for THIS step — we must allow that through.
          if (_isStepGenerationActive && _currentTrackingStepIndex != state.activeStepIndex) {
            debugPrint('⚠️ [Client WS] "plan" guard blocked — generation already active for Step $_currentTrackingStepIndex.');
            return;
          }

          _currentTrackingStepIndex = state.activeStepIndex;
          if (!_stepTotalStopwatch.isRunning) {
            _stepTotalStopwatch.reset();
            _stepTotalStopwatch.start();
          }
          _backendStopwatch.reset();
          _backendStopwatch.start();
          _isStepGenerationActive = true;

          debugPrint('🚀 [Client] Triggering backend agents for Step $_currentTrackingStepIndex via plan event...');
          
          final updatedCurating = Set<int>.from(state.curatingVideoSteps)..add(state.activeStepIndex);

          // Only show the massive full-screen neural loader for the very first step of a new journey.
          // For all other steps (e.g. regenerating), use the seamless inline workspace loader.
          final isBrandNewJourney = state.activeStepIndex == 0 && session.stepsCompleted == 0 && !_isRegenerating;
          if (isBrandNewJourney) {
            state = state.copyWith(isLoading: true, isSynthesizing: true, curatingVideoSteps: updatedCurating);
          } else {
            state = state.copyWith(curatingVideoSteps: updatedCurating);
          }
          
          debugPrint('📤 [Client WS] Sending start_step for Step ${state.activeStepIndex}...');
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

    // Progressive hydration: YouTube Curator finished indexing in background
    if (type == 'step_videos_ready') {
      final stepIdx = event['step_index'] as int? ?? state.activeStepIndex;
      final rawVideos = event['videos'] as List<dynamic>? ?? [];
      final durationMs = (event['duration_ms'] as num?)?.toDouble();

      final durationText = durationMs != null && durationMs > 0
          ? '${durationMs.toStringAsFixed(0)} ms (${(durationMs / 1000).toStringAsFixed(2)}s)'
          : 'completed';

      debugPrint('''
╔════════════════════════════════════════════════════════════════════
║ 🎬 [YouTubeCuratorAgent Completed] Step $stepIdx
╟────────────────────────────────────────────────────────────────────
║  • Curation & Transcript Indexing:  $durationText
║  • Video Clips Curated:             ${rawVideos.length} clip(s)
║  • UI State:                        Shimmer Skeleton -> Video Cards hydrated
╚════════════════════════════════════════════════════════════════════''');

      final currentSession = state.session;
      if (currentSession != null && stepIdx >= 0 && stepIdx < currentSession.steps.length) {
        final updatedSteps = List<MilestoneStep>.from(currentSession.steps);
        updatedSteps[stepIdx] = updatedSteps[stepIdx].copyWith(videos: rawVideos);
        final updatedCurating = Set<int>.from(state.curatingVideoSteps)..remove(stepIdx);

        state = state.copyWith(
          session: currentSession.copyWith(steps: updatedSteps),
          curatingVideoSteps: updatedCurating,
        );
      }
      return;
    }

    // Render the UI only when all core agents finish their job
    if (type == 'step_complete') {
      _backendStopwatch.stop();
      _isRegenerating = false;
      _lastBackendMs = _backendStopwatch.elapsedMilliseconds;
      debugPrint('✅ [Client WS] "step_complete" received for Step $_currentTrackingStepIndex in ${_lastBackendMs}ms (${(_lastBackendMs / 1000).toStringAsFixed(2)}s). Fetching full session data...');
      loadSession(session.sessionId, fromStepComplete: true, silent: true);
      return;
    }

    if (type == 'perf_summary') {
      final stepIdx = event['step_index'] as int? ?? -1;
      final timings = event['timings_ms'] as Map<String, dynamic>? ?? {};
      final youtubeStatus = event['youtube_status'] as String? ?? '';
      final total = (timings['total_backend_ms'] as num?)?.toDouble() ?? 0;
      final tutor = (timings['SocraticTutorAgent'] as num?)?.toDouble() ?? 0;
      final youtubeNum = (timings['YouTubeCuratorAgent'] as num?)?.toDouble();
      final academic = (timings['AcademicResearcherAgent'] as num?)?.toDouble() ?? 0;
      final quiz = (timings['QuizAgent'] as num?)?.toDouble() ?? 0;
      final dbPersist = (timings['db_persist'] as num?)?.toDouble() ?? 0;
      final parallelGather = (timings['parallel_gather_wall'] as num?)?.toDouble() ?? 0;

      String youtubeLine;
      if (youtubeNum != null && youtubeNum > 0) {
        youtubeLine = '${youtubeNum.toStringAsFixed(0).padLeft(6)} ms';
      } else if (youtubeStatus == 'cached') {
        youtubeLine = '     0 ms (cached)';
      } else if (youtubeStatus == 'in_background' || youtubeNum == null) {
        youtubeLine = '⏳ in background...';
      } else {
        youtubeLine = '     0 ms';
      }

      debugPrint('''
╔════════════════════════════════════════════════════════════════════
║ 🖥️  [Backend Perf Summary] Step $stepIdx
╟────────────────────────────────────────────────────────────────────
║  • SocraticTutorAgent (stream):  ${tutor.toStringAsFixed(0).padLeft(6)} ms
║  • YouTubeCuratorAgent:          $youtubeLine
║  • AcademicResearcherAgent:      ${academic.toStringAsFixed(0).padLeft(6)} ms
║  • QuizAgent:                    ${quiz.toStringAsFixed(0).padLeft(6)} ms
║  • Parallel gather wall:         ${parallelGather.toStringAsFixed(0).padLeft(6)} ms
║  • DB Persist (update_session):  ${dbPersist.toStringAsFixed(0).padLeft(6)} ms
╟────────────────────────────────────────────────────────────────────
║  ⚡ Total backend time:           ${total.toStringAsFixed(0).padLeft(6)} ms (${(total / 1000).toStringAsFixed(2)}s)
╚════════════════════════════════════════════════════════════════════''');
      return;
    }

    if (type == 'xp_update') {
      final xpEarned = event['xp_earned'] as int? ?? 0;
      final totalXp = event['total_xp'] as int? ?? session.xpEarned;
      final newLevel = event['level'] as int? ?? GamificationUtils.calculateLevel(totalXp);
      final levelTitle = event['level_title'] as String? ?? GamificationUtils.getLevelTitle(newLevel);
      
      debugPrint('🌟 [Client WS] XP Update: +$xpEarned XP (Total: $totalXp) - $levelTitle (Lvl $newLevel)');
      
      final oldLevel = GamificationUtils.calculateLevel(session.xpEarned);
      
      // Update the local session state with the new XP
      final updatedSession = session.copyWith(
        xpEarned: totalXp,
      );
      state = state.copyWith(session: updatedSession);
      
      // Only trigger celebration if level actually increased
      if (newLevel > oldLevel) {
        ref.read(gamificationEventProvider.notifier).triggerEvent(
          xpEarned: xpEarned,
          totalXp: totalXp,
          level: newLevel,
          levelTitle: levelTitle,
        );
      }
      return;
    }

    if (type == 'error') {
      debugPrint('❌ [Client WS] Error event received: ${event['message']}');
      _isStepGenerationActive = false;
      _isRegenerating = false;
      _stepTotalStopwatch.stop();
      _backendStopwatch.stop();
      state = state.copyWith(
        isLoading: false,
        isSynthesizing: false,
        error: event['message']?.toString() ?? 'An error occurred during step synthesis',
      );
      return;
    }

    if (type == 'ws_closed') {
      debugPrint('⚠️ [Client WS] Connection closed.');
      if (_isStepGenerationActive || state.isLoading) {
        _isStepGenerationActive = false;
        _isRegenerating = false;
        _stepTotalStopwatch.stop();
        _backendStopwatch.stop();
        state = state.copyWith(
          isLoading: false,
          isSynthesizing: false,
          error: 'Connection to learning server was closed. Please try reloading or regenerating the step.',
        );
      }
      return;
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
    _currentTrackingStepIndex = 0;

    state = state.copyWith(isLoading: true, isSynthesizing: true, clearError: true);
    try {
      final journeyApiWatch = Stopwatch()..start();
      final response = await _service.startJourney(topic: topic, mode: mode, level: level);
      journeyApiWatch.stop();
      debugPrint('📋 [Client API] Orchestrator milestone plan created in ${journeyApiWatch.elapsedMilliseconds}ms (${(journeyApiWatch.elapsedMilliseconds / 1000).toStringAsFixed(2)}s). Total steps: ${response.steps.length}');

      final updatedCurating = Set<int>.from(state.curatingVideoSteps)..add(0);
      state = state.copyWith(
        session: response,
        activeStepIndex: 0,
        isLoading: true,
        isSynthesizing: true, // Keep neural loader visible while step 0 agents run
        curatingVideoSteps: updatedCurating,
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
    
    state = state.copyWith(clearError: true);
    try {
      final quizWatch = Stopwatch()..start();
      final result = await _service.submitQuiz(session.sessionId, stepIndex, answers);
      quizWatch.stop();
      debugPrint('📝 [Client API] Quiz evaluated in ${quizWatch.elapsedMilliseconds}ms. Awarded XP: ${result.xpEarned}');
      
      final oldLevel = GamificationUtils.calculateLevel(session.xpEarned);
      final totalXp = session.xpEarned + result.xpEarned;
      final newLevel = GamificationUtils.calculateLevel(totalXp);
      final leveledUp = newLevel > oldLevel;

      // Update session XP and step quiz score/answers locally
      final updatedSteps = List<MilestoneStep>.from(session.steps);
      if (stepIndex >= 0 && stepIndex < updatedSteps.length) {
        final currentStep = updatedSteps[stepIndex];
        final stringKeyAnswers = answers.map((k, v) => MapEntry(k.toString(), v));
        updatedSteps[stepIndex] = currentStep.copyWith(
          quizScore: result.score,
          userAnswers: stringKeyAnswers,
          userFullAnswers: stringKeyAnswers,
        );
      }

      final updatedSession = session.copyWith(
        xpEarned: totalXp,
        steps: updatedSteps,
      );
      
      _uiRenderStopwatch.reset();
      _uiRenderStopwatch.start();

      state = state.copyWith(
        session: updatedSession,
      );

      // Sync progress with learning history list
      ref.read(sessionsProvider.notifier).updateSessionProgress(
        sessionId: session.sessionId,
        stepsCompleted: updatedSession.stepsCompleted,
        xpEarned: updatedSession.xpEarned,
      );

      // Instant level-up celebration trigger for quiz submit
      if (leveledUp) {
        final levelTitle = GamificationUtils.getLevelTitle(newLevel);
        ref.read(gamificationEventProvider.notifier).triggerEvent(
          xpEarned: result.xpEarned,
          totalXp: totalXp,
          level: newLevel,
          levelTitle: levelTitle,
        );
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _uiRenderStopwatch.stop();
        debugPrint('🎨 [Client UI] Quiz results rendered to screen in ${_uiRenderStopwatch.elapsedMilliseconds}ms');
      });

      return result;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<bool> markStepComplete(int stepIndex) async {
    final session = state.session;
    if (session == null) return false;
    
    state = state.copyWith(clearError: true);
    try {
      final oldLevel = GamificationUtils.calculateLevel(session.xpEarned);
      final data = await _service.completeStep(session.sessionId, stepIndex);
      
      // Update XP locally
      final awardedXp = data['xp_earned'] as int? ?? 0;
      final totalXp = data['total_xp'] as int? ?? (session.xpEarned + awardedXp);
      final newLevel = GamificationUtils.calculateLevel(totalXp);
      final bool leveledUp = newLevel > oldLevel;

      final nextStepIdx = data['next_step_index'] as int? ?? session.currentStepIndex;
      final newStepsCompleted = (session.stepsCompleted + 1).clamp(0, session.steps.length);

      final updatedSteps = List<MilestoneStep>.from(session.steps);
      if (stepIndex >= 0 && stepIndex < updatedSteps.length) {
        final currentStep = updatedSteps[stepIndex];
        updatedSteps[stepIndex] = currentStep.copyWith(
          status: 'complete',
        );
      }

      final updatedSession = session.copyWith(
        xpEarned: totalXp,
        stepsCompleted: newStepsCompleted,
        currentStepIndex: nextStepIdx,
        steps: updatedSteps,
      );
      
      state = state.copyWith(
        session: updatedSession,
      );

      // Sync progress with learning history list
      ref.read(sessionsProvider.notifier).updateSessionProgress(
        sessionId: session.sessionId,
        stepsCompleted: updatedSession.stepsCompleted,
        xpEarned: updatedSession.xpEarned,
        isComplete: updatedSession.stepsCompleted >= updatedSession.steps.length,
      );

      if (leveledUp) {
        final levelTitle = GamificationUtils.getLevelTitle(newLevel);
        ref.read(gamificationEventProvider.notifier).triggerEvent(
          xpEarned: awardedXp,
          totalXp: totalXp,
          level: newLevel,
          levelTitle: levelTitle,
        );
      }

      return leveledUp;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Completes the current step, pauses if a level-up celebration is shown,
  /// and advances to the next step once the celebration modal is dismissed.
  /// If completing the final step, triggers the Journey Complete celebration!
  Future<void> completeAndAdvanceStep(int stepIndex) async {
    final session = state.session;
    if (session == null) return;

    bool leveledUp = false;
    final currentStep = session.steps[stepIndex];
    if (currentStep.status != 'complete') {
      leveledUp = await markStepComplete(stepIndex);
    } else {
      debugPrint('⏭️ [Client] Step $stepIndex is already complete. Skipping completion API call.');
    }

    // If level-up occurred or celebration overlay is active, wait for user to dismiss
    final gamificationNotifier = ref.read(gamificationEventProvider.notifier);
    if (leveledUp || gamificationNotifier.isCelebrating) {
      await gamificationNotifier.onDismissed;
    }

    final updatedSession = state.session;
    if (updatedSession == null) return;

    final bool isLastStep = stepIndex >= updatedSession.steps.length - 1;

    if (isLastStep) {
      // 1. Optimistic completion: ensure all steps are marked complete in local state
      final completedSteps = updatedSession.steps.map((s) => s.copyWith(status: 'complete')).toList();
      final fullyCompletedSession = updatedSession.copyWith(
        stepsCompleted: updatedSession.steps.length,
        steps: completedSteps,
      );
      state = state.copyWith(session: fullyCompletedSession);

      // Sync progress with learning history list
      ref.read(sessionsProvider.notifier).updateSessionProgress(
        sessionId: updatedSession.sessionId,
        stepsCompleted: updatedSession.steps.length,
        xpEarned: fullyCompletedSession.xpEarned,
        isComplete: true,
      );

      // Calculate average quiz score across steps
      double totalScore = 0.0;
      int quizCount = 0;
      for (final s in updatedSession.steps) {
        if (s.quizScore != null) {
          totalScore += s.quizScore!;
          quizCount++;
        }
      }
      final avgScore = quizCount > 0 ? (totalScore / quizCount) : null;

      ref.read(journeyCompleteProvider.notifier).triggerEvent(
        sessionId: updatedSession.sessionId,
        topic: updatedSession.topic,
        totalSteps: updatedSession.steps.length,
        totalXp: updatedSession.xpEarned,
        bonusXp: 100,
        averageQuizScore: avgScore,
      );

      // 2. Fire silent background sync immediately while celebration modal is animating
      loadSession(updatedSession.sessionId, silent: true);
      return;
    }

    // Now transition to the next step (triggers NeuralInferenceLoader if ungenerated)
    setActiveStep(stepIndex + 1);
  }

  /// Displays the Journey Complete celebration modal with summary metrics and stats.
  /// Used in Review Mode when the student taps "Journey Completed" or "View Summary".
  void showJourneySummary() {
    final session = state.session;
    if (session == null || session.steps.isEmpty) return;

    double totalScore = 0.0;
    int quizCount = 0;
    for (final s in session.steps) {
      if (s.quizScore != null) {
        totalScore += s.quizScore!;
        quizCount++;
      }
    }
    final avgScore = quizCount > 0 ? (totalScore / quizCount) : null;

    ref.read(journeyCompleteProvider.notifier).triggerEvent(
      sessionId: session.sessionId,
      topic: session.topic,
      totalSteps: session.steps.length,
      totalXp: session.xpEarned,
      bonusXp: 0,
      averageQuizScore: avgScore,
    );
  }

  /// Failsafe invoked when the Journey Complete celebration is dismissed.
  /// Locks local state into the completed review mode and triggers a silent sync.
  void ensureJourneyCompleted() {
    final session = state.session;
    if (session == null || session.steps.isEmpty) return;

    final completedSteps = session.steps.map((s) => s.copyWith(status: 'complete')).toList();
    final fullyCompletedSession = session.copyWith(
      stepsCompleted: session.steps.length,
      steps: completedSteps,
    );
    state = state.copyWith(session: fullyCompletedSession);

    // Sync progress with learning history list
    ref.read(sessionsProvider.notifier).updateSessionProgress(
      sessionId: session.sessionId,
      stepsCompleted: session.steps.length,
      xpEarned: fullyCompletedSession.xpEarned,
      isComplete: true,
    );

    // Reconcile with server silently in background
    loadSession(session.sessionId, silent: true);
  }

  /// Regenerates the content for a specific step.
  Future<void> regenerateCurrentStep(int stepIndex) async {
    final session = state.session;
    if (session == null || stepIndex < 0 || stepIndex >= session.steps.length) return;

    _isRegenerating = true;
    _isStepGenerationActive = true;

    // 1. Trigger backend API
    try {
      await _service.regenerateStep(session.sessionId, stepIndex);
    } catch (e) {
      _isRegenerating = false;
      debugPrint('Failed to trigger regeneration on backend: $e');
      return;
    }

    // 2. Optimistic update: clear step content to show loading state
    final currentStep = session.steps[stepIndex];
    final clearedStep = currentStep.copyWith(
      tutorExplanation: null,
      socraticQuestions: [],
      quiz: [],
      quizScore: null,
      userAnswers: {},
      userFullAnswers: {},
      followUpCount: 0,
    );

    final updatedSteps = List<MilestoneStep>.from(session.steps)..[stepIndex] = clearedStep;
    final updatedSession = session.copyWith(steps: updatedSteps);
    
    state = state.copyWith(session: updatedSession);
    
    // 3. Re-fetch session to poll for newly generated content
    loadSession(session.sessionId, silent: true);

    // 4. Trigger the backend agents to start generating the cleared step
    if (!_wsService.isConnected) {
      debugPrint('Reconnecting WebSocket for regeneration...');
      _wsService.connect(session.sessionId);
    }
    _wsService.sendStartStep(stepIndex);
  }

  /// Check if the quiz for a given step has been completed.
  bool isQuizCompletedForStep(int stepIndex) {
    final session = state.session;
    if (session == null) return true; // No session = no gating
    if (stepIndex < 0 || stepIndex >= session.steps.length) return true;
    final step = session.steps[stepIndex];
    // No quiz means no gating
    if (step.quiz == null || step.quiz!.isEmpty) return true;
    // Quiz is completed if score or non-empty answers exist
    return step.quizScore != null ||
        (step.userAnswers != null &&
            step.userAnswers!.isNotEmpty &&
            step.userAnswers!.values.any(
                (v) => v != null && v.toString().trim().isNotEmpty));
  }

  void sendFollowUpChat(String content) {
    final session = state.session;
    if (session != null && !_wsService.isConnected) {
      debugPrint('Reconnecting WebSocket for session ${session.sessionId}...');
      _wsService.connect(session.sessionId);
    }
    _wsService.sendChat(content);
  }

  Future<void> loadSession(String sessionId, {bool fromStepComplete = false, bool silent = false}) async {
    _apiFetchStopwatch.reset();
    _apiFetchStopwatch.start();

    if (!silent) {
      state = state.copyWith(
        isLoading: true,
        isSynthesizing: fromStepComplete,
        clearError: true,
      );
    }
    try {
      var response = await _service.fetchSessionById(sessionId);
      _apiFetchStopwatch.stop();
      _lastApiFetchMs = _apiFetchStopwatch.elapsedMilliseconds;
      
      int stepIndex = response.currentStepIndex;
      // Safety check: ensure index is within bounds (stay on final milestone upon completion)
      if (response.steps.isNotEmpty && stepIndex >= response.steps.length) {
        stepIndex = response.steps.length - 1;
      }

      // Preserve quiz results from local state when the server response has
      // empty quiz fields (prevents wiping submitted answers on session reload).
      final existingSession = state.session;
      if (existingSession != null && existingSession.steps.isNotEmpty) {
        for (int i = 0; i < response.steps.length && i < existingSession.steps.length; i++) {
          final localStep = existingSession.steps[i];
          final serverStep = response.steps[i];

          final bool localHasQuiz = localStep.quizScore != null ||
              (localStep.userAnswers != null && localStep.userAnswers!.isNotEmpty);
          final bool serverLacksQuiz = serverStep.quizScore == null ||
              serverStep.userAnswers == null ||
              serverStep.userAnswers!.isEmpty;

          if (localHasQuiz && serverLacksQuiz) {
            response = response.copyWith(
              steps: List.from(response.steps)
                ..[i] = serverStep.copyWith(
                  quizScore: serverStep.quizScore ?? localStep.quizScore,
                  userAnswers: (serverStep.userAnswers != null && serverStep.userAnswers!.isNotEmpty)
                      ? serverStep.userAnswers
                      : localStep.userAnswers,
                  userFullAnswers: (serverStep.userFullAnswers != null && serverStep.userFullAnswers!.isNotEmpty)
                      ? serverStep.userFullAnswers
                      : (localStep.userFullAnswers ?? localStep.userAnswers),
                ),
            );
          }
        }
      }

      // When loading after step_complete or silent sync, preserve the user's current view
      // position instead of jumping to the server's currentStepIndex.
      if ((fromStepComplete || silent) && existingSession != null) {
        stepIndex = state.activeStepIndex;
        // Ensure the index is still valid with the new response
        if (stepIndex >= response.steps.length) {
          stepIndex = response.steps.isNotEmpty ? response.steps.length - 1 : 0;
        }
      }

      debugPrint('📥 [Client API] Session payload retrieved in ${_lastApiFetchMs}ms (silent: $silent). Initiating UI render for Step $stepIndex...');

      _uiRenderStopwatch.reset();
      _uiRenderStopwatch.start();

      final targetStepIndex = stepIndex;
      final wasStepGeneration = _isStepGenerationActive || fromStepComplete;

      // If the loaded step already has videos, remove it from curatingVideoSteps
      final updatedCurating = Set<int>.from(state.curatingVideoSteps);
      if (stepIndex >= 0 && stepIndex < response.steps.length) {
        final loadedStep = response.steps[stepIndex];
        if (loadedStep.videos != null && loadedStep.videos!.isNotEmpty) {
          updatedCurating.remove(stepIndex);
        }
      }

      state = state.copyWith(
        session: response,
        activeStepIndex: stepIndex,
        isLoading: false,
        isSynthesizing: false,
        curatingVideoSteps: updatedCurating,
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
      // when refreshing the session data after step_complete or silent sync.
      if (!fromStepComplete && !silent) {
        _wsService.connect(sessionId);
      }
    } catch (e) {
      _uiRenderStopwatch.stop();
      _stepTotalStopwatch.stop();
      _isStepGenerationActive = false;
      if (!silent) {
        state = state.copyWith(isLoading: false, isSynthesizing: false, error: e.toString());
      }
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

        final updatedCurating = Set<int>.from(state.curatingVideoSteps)..add(index);
        state = state.copyWith(
          activeStepIndex: index,
          isLoading: true,
          isSynthesizing: true,
          curatingVideoSteps: updatedCurating,
        );

        // BUG FIX (Issue 2 — infinite loader): The WS connection is closed by the
        // server after step_complete is processed. If not reconnected before sending
        // start_step, the message is silently dropped and the loader spins forever.
        final session = state.session!;
        if (!_wsService.isConnected) {
          debugPrint('🔌 [Client WS] Connection is closed. Reconnecting before sending start_step for Step $index...');
          _wsService.connect(session.sessionId);
          // The WS will emit a "plan" event on connect; sendStartStep is handled there.
          // We return here to avoid a double start_step send.
          return;
        }

        debugPrint('📤 [Client WS] Sending start_step for Step $index (connection already open)');
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
    _isStepGenerationActive = false;
    _isRegenerating = false;
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
