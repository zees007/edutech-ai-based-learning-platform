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
    session_count: int
    percentage: float


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


class LearningDashboardResponse(BaseModel):
    """Consolidated learner dashboard response payload."""

    summary: DashboardSummaryDTO
    quiz_metrics: QuizMetricsDTO
    activity_heatmap: list[HeatmapDayDTO] = Field(default_factory=list)
    topic_breakdown: list[TopicBreakdownDTO] = Field(default_factory=list)
    mode_distribution: ModeDistributionDTO
    achievements: list[AchievementDTO] = Field(default_factory=list)
