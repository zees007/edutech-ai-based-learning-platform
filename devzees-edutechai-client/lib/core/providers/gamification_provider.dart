import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Centralized gamification levels and helpers matching backend gamification.py
class GamificationUtils {
  static const levels = [
    {"level": 1, "xp_required": 0, "title": "Curious Explorer"},
    {"level": 2, "xp_required": 100, "title": "Knowledge Seeker"},
    {"level": 3, "xp_required": 300, "title": "Quick Learner"},
    {"level": 4, "xp_required": 600, "title": "Deep Thinker"},
    {"level": 5, "xp_required": 1000, "title": "Rising Scholar"},
    {"level": 6, "xp_required": 1500, "title": "Concept Master"},
    {"level": 7, "xp_required": 2200, "title": "Wisdom Weaver"},
    {"level": 8, "xp_required": 3000, "title": "Knowledge Architect"},
    {"level": 9, "xp_required": 4000, "title": "Enlightened Mind"},
    {"level": 10, "xp_required": 5500, "title": "Grand Sage"},
  ];

  static int calculateLevel(int totalXp) {
    for (var i = levels.length - 1; i >= 0; i--) {
      if (totalXp >= (levels[i]["xp_required"] as int)) {
        return levels[i]["level"] as int;
      }
    }
    return 1;
  }

  static String getLevelTitle(int level) {
    for (final lvl in levels) {
      if ((lvl["level"] as int) == level) {
        return lvl["title"] as String;
      }
    }
    return 'Level $level';
  }

  static Map<String, dynamic> calculateLevelData(int totalXp) {
    var current = levels[0];
    Map<String, Object>? nextLevel = levels.length > 1 ? levels[1] : null;

    for (var i = 0; i < levels.length; i++) {
      final levelInfo = levels[i];
      if (totalXp >= (levelInfo["xp_required"] as int)) {
        current = levelInfo;
        nextLevel = (i + 1 < levels.length) ? levels[i + 1] : null;
      } else {
        break;
      }
    }

    int xpInLevel;
    int xpNeeded;
    double progress;

    if (nextLevel != null) {
      xpInLevel = totalXp - (current["xp_required"] as int);
      xpNeeded = (nextLevel["xp_required"] as int) - (current["xp_required"] as int);
      progress = xpNeeded > 0 ? (xpInLevel / xpNeeded) : 1.0;
    } else {
      xpInLevel = totalXp - (current["xp_required"] as int);
      xpNeeded = 0;
      progress = 1.0;
    }

    return {
      "level": current["level"] as int,
      "title": current["title"] as String,
      "total_xp": totalXp,
      "xp_for_current_level": current["xp_required"] as int,
      "xp_for_next_level": nextLevel != null ? (nextLevel["xp_required"] as int) : (current["xp_required"] as int),
      "xp_in_level": xpInLevel,
      "xp_needed_for_next": xpNeeded,
      "progress": progress.clamp(0.0, 1.0),
      "is_max_level": nextLevel == null,
    };
  }
}

class GamificationEvent {
  final int xpEarned;
  final int totalXp;
  final int level;
  final String levelTitle;
  final DateTime timestamp;

  GamificationEvent({
    required this.xpEarned,
    required this.totalXp,
    required this.level,
    required this.levelTitle,
    required this.timestamp,
  });
}

class GamificationEventNotifier extends Notifier<GamificationEvent?> {
  Completer<void>? _dismissCompleter;

  @override
  GamificationEvent? build() {
    return null;
  }

  /// True if a level-up celebration overlay is currently visible and not yet dismissed
  bool get isCelebrating =>
      state != null && _dismissCompleter != null && !_dismissCompleter!.isCompleted;

  /// Awaits until the user dismisses the celebration or the auto-dismiss timer completes.
  /// Includes a 5s safety timeout to prevent stalling workflow.
  Future<void> get onDismissed {
    if (_dismissCompleter == null || _dismissCompleter!.isCompleted) {
      return Future.value();
    }
    return _dismissCompleter!.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        dismiss();
      },
    );
  }

  void triggerEvent({
    required int xpEarned,
    required int totalXp,
    required int level,
    required String levelTitle,
  }) {
    if (_dismissCompleter != null && !_dismissCompleter!.isCompleted) {
      _dismissCompleter!.complete();
    }
    _dismissCompleter = Completer<void>();
    state = GamificationEvent(
      xpEarned: xpEarned,
      totalXp: totalXp,
      level: level,
      levelTitle: levelTitle,
      timestamp: DateTime.now(),
    );
  }

  void dismiss() {
    if (_dismissCompleter != null && !_dismissCompleter!.isCompleted) {
      _dismissCompleter!.complete();
    }
    state = null;
  }
}

final gamificationEventProvider =
    NotifierProvider<GamificationEventNotifier, GamificationEvent?>(() {
  return GamificationEventNotifier();
});

class JourneyCompleteEvent {
  final String sessionId;
  final String topic;
  final int totalSteps;
  final int totalXp;
  final int bonusXp;
  final double? averageQuizScore;
  final DateTime timestamp;

  JourneyCompleteEvent({
    required this.sessionId,
    required this.topic,
    required this.totalSteps,
    required this.totalXp,
    required this.bonusXp,
    this.averageQuizScore,
    required this.timestamp,
  });
}

class JourneyCompleteNotifier extends Notifier<JourneyCompleteEvent?> {
  @override
  JourneyCompleteEvent? build() => null;

  void triggerEvent({
    required String sessionId,
    required String topic,
    required int totalSteps,
    required int totalXp,
    required int bonusXp,
    double? averageQuizScore,
  }) {
    state = JourneyCompleteEvent(
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

final journeyCompleteProvider =
    NotifierProvider<JourneyCompleteNotifier, JourneyCompleteEvent?>(() {
  return JourneyCompleteNotifier();
});

