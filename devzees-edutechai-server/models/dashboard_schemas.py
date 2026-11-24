from __future__ import annotations

from datetime import datetime
from pydantic import BaseModel, Field


class DashboardSummaryDTO(BaseModel):
    """Overall learning summary metrics."""

    total_sessions: int = Field(default=0, description="Total started learning sessions")
    completed_sessions: int = Field(default=0, description="Total completed learning sessions")
    completion_rate: float = Field(default=0.0, description="Completion percentage (0.0 to 100.0)")
    total_steps_mastered: int = Field(default=0, description="Count of completed milestone steps")
    total_study_minutes: int = Field(default=0, description="Estimated active study minutes with idle clamping")
    average_quiz_score_overall: float = Field(default=0.0, description="Average quiz accuracy % across all steps")
    total_xp: int = Field(default=0, description="Total cumulative XP earned across all sessions")
    current_level: int = Field(default=1, description="Calculated user all-time level (1 to 10)")
    level_title: str = Field(default="Curious Explorer", description="Title for the user level")
    xp_progress_in_level: int = Field(default=0, description="XP earned towards current level threshold")
    xp_needed_for_next: int = Field(default=60, description="Remaining XP needed for next level")
    is_max_level: bool = Field(default=False, description="True if max level 10 reached")
    current_streak: int = Field(default=0, description="Current consecutive active days")
    longest_streak: int = Field(default=0, description="Personal record consecutive active days")


class QuizAccuracyTrendItemDTO(BaseModel):
    """A single data point on the chronological quiz accuracy curve."""

    date: str = Field(description="ISO Date YYYY-MM-DD")
    session_id: str = Field(description="Session identifier")
    topic: str = Field(description="Session topic")
    step_index: int = Field(description="Step index (0-indexed)")
    step_title: str = Field(description="Milestone step title")
    step_score: float = Field(description="Score for this 3-question quiz (0.0 to 100.0)")
    session_avg_score: float = Field(default=0.0, description="Average quiz score for the session so far")


class WeakConceptDTO(BaseModel):
    """A milestone step where quiz comprehension was sub-70% (0/3 or 1/3 correct)."""

    session_id: str
    topic: str
    step_index: int
    step_title: str
    quiz_score: float = Field(description="Percentage score (0.0 to 100.0)")
    correct_count: int = Field(default=0, description="Number of questions correct (0 or 1)")
    total_questions: int = Field(default=3, description="Always 3 questions")
    completed_at: datetime | None = None


class QuizMetricsDTO(BaseModel):
    """Aggregate quiz evaluation data."""

    total_quizzes_taken: int = Field(default=0, description="Count of 3-question quizzes submitted")
    total_questions_evaluated: int = Field(default=0, description="Total questions (quizzes * 3)")
    questions_correct: int = Field(default=0, description="Total correct answers")
    perfect_quizzes_count: int = Field(default=0, description="Quizzes with 3/3 (100%) correct")
    accuracy_trend: list[QuizAccuracyTrendItemDTO] = Field(default_factory=list)
    concepts_needing_reinforcement: list[WeakConceptDTO] = Field(default_factory=list)


class HeatmapDayDTO(BaseModel):
    """Daily learning activity density for calendar heatmap."""

    date: str = Field(description="YYYY-MM-DD")
    steps_count: int = Field(default=0)
    xp_earned: int = Field(default=0)
    active_minutes: int = Field(default=0)


class TopicBreakdownDTO(BaseModel):
    """Subject and topic mastery distribution."""

    topic: str
    session_count: int = 1
    percentage: float
    session_id: str | None = None
    is_complete: bool = False
    completed_steps: int = 0
    total_steps: int = 0
    learning_mode: str | None = None


class ModeDistributionDTO(BaseModel):
    """Distribution across all 3 supported learning modes."""

    visual: int = Field(default=0, description="Visual 🎬 mode count")
    deep_dive: int = Field(default=0, description="Deep Dive 🔬 mode count")
    bite_sized: int = Field(default=0, description="Bite-Sized ⚡ mode count")


class AchievementDTO(BaseModel):
    """Dynamic milestone achievement / trophy."""

    id: str
    title: str
    description: str
    unlocked: bool = False
    unlocked_at: datetime | None = None
    icon: str


class TrophyRequirementDTO(BaseModel):
    """Progress toward a specific trophy requirement."""

    label: str = Field(description="Requirement label (e.g. Sessions, Steps, Perfect Quizzes, Day Streak)")
    current: int = Field(default=0, description="Current progress value")
    required: int = Field(default=0, description="Required target value")
    met: bool = Field(default=False, description="Whether requirement is met")


class LearnerStandingResponse(BaseModel):
    """All-time cumulative standing and permanent achievements (HUD)."""

    total_xp: int = Field(default=0, description="Total cumulative XP earned across all sessions")

    highest_trophy_id: str | None = Field(default=None, description="ID of highest unlocked trophy (e.g. 'gold'), None if unranked")
    highest_trophy_title: str = Field(default="Unranked", description="Display title of highest unlocked trophy")
    next_trophy_id: str | None = Field(default=None, description="ID of next trophy to unlock, None if Diamond achieved")
    next_trophy_title: str | None = Field(default=None, description="Display title of next trophy")
    next_trophy_requirements: list[TrophyRequirementDTO] | None = Field(default=None, description="Detailed progress toward each requirement of next trophy")
    trophy_progress_fraction: float = Field(default=0.0, description="0.0 to 1.0 overall progress toward next trophy")

    current_streak: int = Field(default=0, description="Current consecutive active days")
    longest_streak: int = Field(default=0, description="Personal record consecutive active days")
    achievements: list[AchievementDTO] = Field(default_factory=list, description="All-time permanent milestone achievements")


class PeriodSummaryDTO(BaseModel):
    """Performance summary metrics scoped to the selected time window."""

    total_sessions: int = Field(default=0, description="Total sessions active or completed in window")
    completed_sessions: int = Field(default=0, description="Total completed sessions in window")
    completion_rate: float = Field(default=0.0, description="Completion percentage in window (0.0 to 100.0)")
    total_steps_mastered: int = Field(default=0, description="Count of milestone steps completed in window")
    total_study_minutes: int = Field(default=0, description="Estimated active study minutes with idle clamping in window")
    xp_earned_in_period: int = Field(default=0, description="XP earned strictly within the selected window")
    average_quiz_score_overall: float = Field(default=0.0, description="Average quiz accuracy % across steps in window")


class PeriodPerformanceResponse(BaseModel):
    """Interval-scoped performance analytics payload."""

    time_range: str = Field(description="Selected time range: 7d, 30d, 90d, 1y, all, or custom")
    start_date: datetime | None = Field(default=None, description="Start timestamp of the period in UTC")
    end_date: datetime | None = Field(default=None, description="End timestamp of the period in UTC")
    summary: PeriodSummaryDTO = Field(description="Performance summary metrics for the period")
    quiz_metrics: QuizMetricsDTO = Field(description="Quiz metrics and accuracy trendline in period")
    activity_heatmap: list[HeatmapDayDTO] = Field(default_factory=list, description="Daily activity for the period")
    topic_breakdown: list[TopicBreakdownDTO] = Field(default_factory=list, description="Topics studied in period")
    mode_distribution: ModeDistributionDTO = Field(description="Learning modes used in period")


class LearningDashboardResponse(BaseModel):
    """Consolidated learner dashboard response payload."""

    summary: DashboardSummaryDTO
    quiz_metrics: QuizMetricsDTO
    activity_heatmap: list[HeatmapDayDTO] = Field(default_factory=list)
    topic_breakdown: list[TopicBreakdownDTO] = Field(default_factory=list)
    mode_distribution: ModeDistributionDTO
    achievements: list[AchievementDTO] = Field(default_factory=list)
