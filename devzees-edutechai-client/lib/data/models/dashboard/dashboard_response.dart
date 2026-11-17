class DashboardSummary {
  final int totalSessions;
  final int completedSessions;
  final double completionRate;
  final int totalStepsMastered;
  final int totalStudyMinutes;
  final double averageQuizScoreOverall;
  final int totalXp;
  final int currentLevel;
  final String levelTitle;
  final int xpProgressInLevel;
  final int xpNeededForNext;
  final bool isMaxLevel;
  final int currentStreak;
  final int longestStreak;

  const DashboardSummary({
    this.totalSessions = 0,
    this.completedSessions = 0,
    this.completionRate = 0.0,
    this.totalStepsMastered = 0,
    this.totalStudyMinutes = 0,
    this.averageQuizScoreOverall = 0.0,
    this.totalXp = 0,
    this.currentLevel = 1,
    this.levelTitle = 'Curious Explorer',
    this.xpProgressInLevel = 0,
    this.xpNeededForNext = 60,
    this.isMaxLevel = false,
    this.currentStreak = 0,
    this.longestStreak = 0,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalSessions: (json['total_sessions'] as num?)?.toInt() ?? 0,
      completedSessions: (json['completed_sessions'] as num?)?.toInt() ?? 0,
      completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0.0,
      totalStepsMastered: (json['total_steps_mastered'] as num?)?.toInt() ?? 0,
      totalStudyMinutes: (json['total_study_minutes'] as num?)?.toInt() ?? 0,
      averageQuizScoreOverall: (json['average_quiz_score_overall'] as num?)?.toDouble() ?? 0.0,
      totalXp: (json['total_xp'] as num?)?.toInt() ?? 0,
      currentLevel: (json['current_level'] as num?)?.toInt() ?? 1,
      levelTitle: json['level_title'] as String? ?? 'Curious Explorer',
      xpProgressInLevel: (json['xp_progress_in_level'] as num?)?.toInt() ?? 0,
      xpNeededForNext: (json['xp_needed_for_next'] as num?)?.toInt() ?? 60,
      isMaxLevel: json['is_max_level'] as bool? ?? false,
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
    );
  }
}

class QuizAccuracyTrendItem {
  final String date;
  final String sessionId;
  final String topic;
  final int stepIndex;
  final String stepTitle;
  final double stepScore;
  final double sessionAvgScore;

  const QuizAccuracyTrendItem({
    required this.date,
    required this.sessionId,
    required this.topic,
    required this.stepIndex,
    required this.stepTitle,
    required this.stepScore,
    required this.sessionAvgScore,
  });

  factory QuizAccuracyTrendItem.fromJson(Map<String, dynamic> json) {
    return QuizAccuracyTrendItem(
      date: json['date'] as String? ?? '',
      sessionId: json['session_id'] as String? ?? '',
      topic: json['topic'] as String? ?? '',
      stepIndex: (json['step_index'] as num?)?.toInt() ?? 0,
      stepTitle: json['step_title'] as String? ?? '',
      stepScore: (json['step_score'] as num?)?.toDouble() ?? 0.0,
      sessionAvgScore: (json['session_avg_score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class WeakConceptItem {
  final String sessionId;
  final String topic;
  final int stepIndex;
  final String stepTitle;
  final double quizScore;
  final int correctCount;
  final int totalQuestions;
  final DateTime? completedAt;

  const WeakConceptItem({
    required this.sessionId,
    required this.topic,
    required this.stepIndex,
    required this.stepTitle,
    required this.quizScore,
    this.correctCount = 0,
    this.totalQuestions = 3,
    this.completedAt,
  });

  factory WeakConceptItem.fromJson(Map<String, dynamic> json) {
    return WeakConceptItem(
      sessionId: json['session_id'] as String? ?? '',
      topic: json['topic'] as String? ?? '',
      stepIndex: (json['step_index'] as num?)?.toInt() ?? 0,
      stepTitle: json['step_title'] as String? ?? '',
      quizScore: (json['quiz_score'] as num?)?.toDouble() ?? 0.0,
      correctCount: (json['correct_count'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['total_questions'] as num?)?.toInt() ?? 3,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
    );
  }
}

class QuizMetrics {
  final int totalQuizzesTaken;
  final int totalQuestionsEvaluated;
  final int questionsCorrect;
  final int perfectQuizzesCount;
  final List<QuizAccuracyTrendItem> accuracyTrend;
  final List<WeakConceptItem> conceptsNeedingReinforcement;

  const QuizMetrics({
    this.totalQuizzesTaken = 0,
    this.totalQuestionsEvaluated = 0,
    this.questionsCorrect = 0,
    this.perfectQuizzesCount = 0,
    this.accuracyTrend = const [],
    this.conceptsNeedingReinforcement = const [],
  });

  factory QuizMetrics.fromJson(Map<String, dynamic> json) {
    return QuizMetrics(
      totalQuizzesTaken: (json['total_quizzes_taken'] as num?)?.toInt() ?? 0,
      totalQuestionsEvaluated: (json['total_questions_evaluated'] as num?)?.toInt() ?? 0,
      questionsCorrect: (json['questions_correct'] as num?)?.toInt() ?? 0,
      perfectQuizzesCount: (json['perfect_quizzes_count'] as num?)?.toInt() ?? 0,
      accuracyTrend: (json['accuracy_trend'] as List<dynamic>?)
              ?.map((e) => QuizAccuracyTrendItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      conceptsNeedingReinforcement: (json['concepts_needing_reinforcement'] as List<dynamic>?)
              ?.map((e) => WeakConceptItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class HeatmapDayItem {
  final String date;
  final int stepsCount;
  final int xpEarned;
  final int activeMinutes;

  const HeatmapDayItem({
    required this.date,
    this.stepsCount = 0,
    this.xpEarned = 0,
    this.activeMinutes = 0,
  });

  factory HeatmapDayItem.fromJson(Map<String, dynamic> json) {
    return HeatmapDayItem(
      date: json['date'] as String? ?? '',
      stepsCount: (json['steps_count'] as num?)?.toInt() ?? 0,
      xpEarned: (json['xp_earned'] as num?)?.toInt() ?? 0,
      activeMinutes: (json['active_minutes'] as num?)?.toInt() ?? 0,
    );
  }
}

class TopicBreakdownItem {
  final String topic;
  final int sessionCount;
  final double percentage;

  const TopicBreakdownItem({
    required this.topic,
    required this.sessionCount,
    required this.percentage,
  });

  factory TopicBreakdownItem.fromJson(Map<String, dynamic> json) {
    return TopicBreakdownItem(
      topic: json['topic'] as String? ?? '',
      sessionCount: (json['session_count'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ModeDistribution {
  final int visual;
  final int deepDive;
  final int biteSized;

  const ModeDistribution({
    this.visual = 0,
    this.deepDive = 0,
    this.biteSized = 0,
  });

  int get total => visual + deepDive + biteSized;

  double get visualPercentage => total > 0 ? (visual / total) * 100 : 0.0;
  double get deepDivePercentage => total > 0 ? (deepDive / total) * 100 : 0.0;
  double get biteSizedPercentage => total > 0 ? (biteSized / total) * 100 : 0.0;

  factory ModeDistribution.fromJson(Map<String, dynamic> json) {
    return ModeDistribution(
      visual: (json['visual'] as num?)?.toInt() ?? 0,
      deepDive: (json['deep_dive'] as num?)?.toInt() ?? 0,
      biteSized: (json['bite_sized'] as num?)?.toInt() ?? 0,
    );
  }
}

class AchievementItem {
  final String id;
  final String title;
  final String description;
  final bool unlocked;
  final DateTime? unlockedAt;
  final String icon;

  const AchievementItem({
    required this.id,
    required this.title,
    required this.description,
    this.unlocked = false,
    this.unlockedAt,
    required this.icon,
  });

  factory AchievementItem.fromJson(Map<String, dynamic> json) {
    return AchievementItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      unlocked: json['unlocked'] as bool? ?? false,
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.tryParse(json['unlocked_at'] as String)
          : null,
      icon: json['icon'] as String? ?? 'trophy',
    );
  }
}

class DashboardResponse {
  final DashboardSummary summary;
  final QuizMetrics quizMetrics;
  final List<HeatmapDayItem> activityHeatmap;
  final List<TopicBreakdownItem> topicBreakdown;
  final ModeDistribution modeDistribution;
  final List<AchievementItem> achievements;

  const DashboardResponse({
    required this.summary,
    required this.quizMetrics,
    this.activityHeatmap = const [],
    this.topicBreakdown = const [],
    required this.modeDistribution,
    this.achievements = const [],
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      summary: json['summary'] != null
          ? DashboardSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : const DashboardSummary(),
      quizMetrics: json['quiz_metrics'] != null
          ? QuizMetrics.fromJson(json['quiz_metrics'] as Map<String, dynamic>)
          : const QuizMetrics(),
      activityHeatmap: (json['activity_heatmap'] as List<dynamic>?)
              ?.map((e) => HeatmapDayItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      topicBreakdown: (json['topic_breakdown'] as List<dynamic>?)
              ?.map((e) => TopicBreakdownItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      modeDistribution: json['mode_distribution'] != null
          ? ModeDistribution.fromJson(json['mode_distribution'] as Map<String, dynamic>)
          : const ModeDistribution(),
      achievements: (json['achievements'] as List<dynamic>?)
              ?.map((e) => AchievementItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
