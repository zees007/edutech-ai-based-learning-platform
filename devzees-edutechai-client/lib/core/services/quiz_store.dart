import '../../data/models/learning/quiz_result.dart';

/// In-memory store for unsubmitted quiz draft answers across tab/step switches.
class QuizDraftStore {
  static final Map<String, Map<int, int>> _selectedAnswers = {};
  static final Map<String, Map<int, String>> _textAnswers = {};

  static String _key(String sessionId, int stepIndex) =>
      '${sessionId}_$stepIndex';

  static Map<int, int>? getSelectedAnswers(String sessionId, int stepIndex) {
    final key = _key(sessionId, stepIndex);
    final data = _selectedAnswers[key];
    return data != null ? Map<int, int>.from(data) : null;
  }

  static Map<int, String>? getTextAnswers(String sessionId, int stepIndex) {
    final key = _key(sessionId, stepIndex);
    final data = _textAnswers[key];
    return data != null ? Map<int, String>.from(data) : null;
  }

  static void saveDraft({
    required String sessionId,
    required int stepIndex,
    required Map<int, int> selectedAnswers,
    required Map<int, String> textAnswers,
  }) {
    final key = _key(sessionId, stepIndex);
    _selectedAnswers[key] = Map<int, int>.from(selectedAnswers);
    _textAnswers[key] = Map<int, String>.from(textAnswers);
  }

  static void clearDraft(String sessionId, int stepIndex) {
    final key = _key(sessionId, stepIndex);
    _selectedAnswers.remove(key);
    _textAnswers.remove(key);
  }

  static void clearSession(String sessionId) {
    _selectedAnswers.removeWhere((k, _) => k.startsWith('${sessionId}_'));
    _textAnswers.removeWhere((k, _) => k.startsWith('${sessionId}_'));
  }

  static void clearAll() {
    _selectedAnswers.clear();
    _textAnswers.clear();
  }
}

/// In-memory store for submitted quiz results and answers across tab/step switches.
/// Ensures that when a student submits a quiz and reviews earlier steps before advancing,
/// their evaluated score, full feedback, XP, and selected options persist without reset.
class QuizSubmissionStore {
  static final Map<String, QuizResult> _results = {};
  static final Map<String, Map<int, int>> _selectedAnswers = {};
  static final Map<String, Map<int, String>> _textAnswers = {};

  static String _key(String sessionId, int stepIndex) =>
      '${sessionId}_$stepIndex';

  static bool hasSubmission(String sessionId, int stepIndex) {
    final key = _key(sessionId, stepIndex);
    return _results.containsKey(key) || _selectedAnswers.containsKey(key);
  }

  static QuizResult? getResult(String sessionId, int stepIndex) {
    final key = _key(sessionId, stepIndex);
    return _results[key];
  }

  static Map<int, int>? getSelectedAnswers(String sessionId, int stepIndex) {
    final key = _key(sessionId, stepIndex);
    final data = _selectedAnswers[key];
    return data != null ? Map<int, int>.from(data) : null;
  }

  static Map<int, String>? getTextAnswers(String sessionId, int stepIndex) {
    final key = _key(sessionId, stepIndex);
    final data = _textAnswers[key];
    return data != null ? Map<int, String>.from(data) : null;
  }

  static void saveSubmission({
    required String sessionId,
    required int stepIndex,
    required QuizResult result,
    required Map<int, int> selectedAnswers,
    required Map<int, String> textAnswers,
  }) {
    final key = _key(sessionId, stepIndex);
    _results[key] = result;
    _selectedAnswers[key] = Map<int, int>.from(selectedAnswers);
    _textAnswers[key] = Map<int, String>.from(textAnswers);
  }

  static void clearSubmission(String sessionId, int stepIndex) {
    final key = _key(sessionId, stepIndex);
    _results.remove(key);
    _selectedAnswers.remove(key);
    _textAnswers.remove(key);
  }

  static void clearSession(String sessionId) {
    _results.removeWhere((k, _) => k.startsWith('${sessionId}_'));
    _selectedAnswers.removeWhere((k, _) => k.startsWith('${sessionId}_'));
    _textAnswers.removeWhere((k, _) => k.startsWith('${sessionId}_'));
  }

  static void clearAll() {
    _results.clear();
    _selectedAnswers.clear();
    _textAnswers.clear();
  }
}
