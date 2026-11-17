"""
EduTechAI — Analytics Service

Consolidates and computes personal learning performance, quiz metrics,
habits, topic mastery, and gamified achievement stats for the learner dashboard.
"""

from __future__ import annotations

from datetime import datetime, timedelta, timezone
import logging
from typing import Any

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from models.dashboard_schemas import (
    AchievementDTO,
    DashboardSummaryDTO,
    HeatmapDayDTO,
    LearningDashboardResponse,
    ModeDistributionDTO,
    QuizAccuracyTrendItemDTO,
    QuizMetricsDTO,
    TopicBreakdownDTO,
    WeakConceptDTO,
)
from models.db_models import GamificationRecord, SessionRecord, StepProgress
from services.gamification import calculate_level

logger = logging.getLogger(__name__)

# Mode median durations in minutes (for idle break clamping)
MODE_MEDIAN_MINUTES: dict[str, int] = {
    "bite_sized": 5,
    "visual": 10,
    "deep_dive": 18,
}
DEFAULT_STEP_MINUTES = 10
MAX_STEP_ACTIVE_WINDOW_MINUTES = 30


def _to_naive_utc(dt: datetime | None) -> datetime | None:
    """Normalize datetime to naive UTC for safe comparison with PostgreSQL TIMESTAMP WITHOUT TIME ZONE."""
    if dt is None:
        return None
    if dt.tzinfo is not None:
        return dt.astimezone(timezone.utc).replace(tzinfo=None)
    return dt


class AnalyticsService:
    """Service for computing user-level learning statistics and performance data."""

    @staticmethod
    async def get_user_dashboard(
        db: AsyncSession,
        user_id: str,
        time_range: str = "30d",
    ) -> LearningDashboardResponse:
        """
        Aggregate learning statistics for the specified user and time window.

        Args:
            db: Async SQLAlchemy database session.
            user_id: The UUID of the authenticated learner.
            time_range: '7d', '30d', or 'all'.
        """
        now = datetime.utcnow()
        start_date: datetime | None = None
        if time_range == "7d":
            start_date = now - timedelta(days=7)
        elif time_range == "30d":
            start_date = now - timedelta(days=30)
        elif time_range == "90d":
            start_date = now - timedelta(days=90)
        # 'all' leaves start_date as None

        # ── 1. Fetch All User Sessions ─────────────────────────────────
        sessions_query = (
            select(SessionRecord)
            .where(SessionRecord.user_id == user_id)
            .order_by(SessionRecord.created_at.desc())
        )
        sessions_res = await db.execute(sessions_query)
        all_user_sessions = list(sessions_res.scalars().all())

        # Filter sessions for the active time window if requested
        if start_date:
            filtered_sessions = [
                s for s in all_user_sessions
                if s.created_at and _to_naive_utc(s.created_at) >= start_date
            ]
        else:
            filtered_sessions = all_user_sessions

        session_lookup: dict[str, SessionRecord] = {s.session_id: s for s in all_user_sessions}
        filtered_session_ids: set[str] = {s.session_id: s for s in filtered_sessions}

        # ── 2. Fetch All StepProgress Records ──────────────────────────
        sp_query = (
            select(StepProgress)
            .join(SessionRecord, StepProgress.session_id == SessionRecord.session_id)
            .where(SessionRecord.user_id == user_id)
            .order_by(StepProgress.completed_at.asc().nulls_last())
        )
        sp_res = await db.execute(sp_query)
        all_step_records = list(sp_res.scalars().all())

        # ── 3. Calculate All-Time Cumulative XP & Overall Level ────────
        xp_query = (
            select(func.coalesce(func.sum(GamificationRecord.xp_earned), 0))
            .join(SessionRecord, GamificationRecord.session_id == SessionRecord.session_id)
            .where(SessionRecord.user_id == user_id)
        )
        xp_res = await db.execute(xp_query)
        total_all_time_xp = int(xp_res.scalar_one() or 0)
        level_info = calculate_level(total_all_time_xp)

        # ── 4. Calculate Streak Information ────────────────────────────
        completed_dates_set: set[str] = set()
        for sp in all_step_records:
            if sp.status == "complete" and sp.completed_at:
                completed_dates_set.add(sp.completed_at.strftime("%Y-%m-%d"))

        current_streak, longest_streak = AnalyticsService._calculate_streaks(completed_dates_set, now)

        # ── 5. Process Steps for Active Time & Clamped Duration ────────
        # Group steps by session to compute clamped step-delta duration
        steps_by_session: dict[str, list[StepProgress]] = {}
        for sp in all_step_records:
            steps_by_session.setdefault(sp.session_id, []).append(sp)

        total_study_minutes = 0
        heatmap_data: dict[str, dict[str, int]] = {}

        for session_id, steps in steps_by_session.items():
            session = session_lookup.get(session_id)
            if not session:
                continue

            mode = (session.learning_mode or "visual").lower()
            mode_median = MODE_MEDIAN_MINUTES.get(mode, DEFAULT_STEP_MINUTES)
            completed_steps = [sp for sp in steps if sp.status == "complete" and sp.completed_at]
            completed_steps.sort(key=lambda x: _to_naive_utc(x.completed_at) or datetime.min)

            last_timestamp = _to_naive_utc(session.created_at) or datetime.utcnow()
            for idx, sp in enumerate(completed_steps):
                sp_completed = _to_naive_utc(sp.completed_at)
                if not sp_completed:
                    continue

                # Compute delta from last step (or session creation)
                delta_minutes = (sp_completed - last_timestamp).total_seconds() / 60.0
                if 0 < delta_minutes <= MAX_STEP_ACTIVE_WINDOW_MINUTES:
                    effective_minutes = int(round(delta_minutes))
                else:
                    # Idle break or gap -> clamp to standard median
                    effective_minutes = mode_median

                last_timestamp = sp_completed

                # Filter for dashboard summary time window
                is_in_window = True
                if start_date:
                    is_in_window = sp_completed >= start_date

                if is_in_window:
                    total_study_minutes += effective_minutes

                # Record activity on heatmap (last 90 days)
                day_key = sp_completed.strftime("%Y-%m-%d")
                if day_key not in heatmap_data:
                    heatmap_data[day_key] = {"steps_count": 0, "xp_earned": 0, "active_minutes": 0}
                heatmap_data[day_key]["steps_count"] += 1
                heatmap_data[day_key]["active_minutes"] += effective_minutes
                # Award ~50 XP per completed step + quiz estimate
                step_xp = 50 + (round(sp.quiz_score * 60) if sp.quiz_score is not None else 0)
                heatmap_data[day_key]["xp_earned"] += step_xp

        # ── 6. Process 3-Question Quiz Metrics & Accuracy Trendline ───
        weak_concepts: list[WeakConceptDTO] = []
        accuracy_trend: list[QuizAccuracyTrendItemDTO] = []

        total_quiz_count = 0
        sum_quiz_scores = 0.0
        perfect_count = 0

        # Sort all steps chronologically for trendline
        sorted_steps_with_quiz = [
            sp for sp in all_step_records
            if sp.quiz_score is not None
        ]
        sorted_steps_with_quiz.sort(key=lambda x: _to_naive_utc(x.completed_at) or datetime.min)

        session_scores_accumulator: dict[str, list[float]] = {}

        for sp in sorted_steps_with_quiz:
            session = session_lookup.get(sp.session_id)
            if not session:
                continue

            sp_completed = _to_naive_utc(sp.completed_at)
            # Respect time window for quiz metrics if filtered
            if start_date and sp_completed and sp_completed < start_date:
                continue

            score = float(sp.quiz_score)
            total_quiz_count += 1
            sum_quiz_scores += score
            if score >= 1.0:
                perfect_count += 1

            # Extract step title from session.state_json if available
            step_title = AnalyticsService._extract_step_title(session, sp.step_index)

            # Track session running average
            session_scores_accumulator.setdefault(sp.session_id, []).append(score)
            running_avg = sum(session_scores_accumulator[sp.session_id]) / len(session_scores_accumulator[sp.session_id])

            date_str = (sp_completed or _to_naive_utc(session.created_at) or now).strftime("%Y-%m-%d")
            accuracy_trend.append(
                QuizAccuracyTrendItemDTO(
                    date=date_str,
                    session_id=sp.session_id,
                    topic=session.topic,
                    step_index=sp.step_index,
                    step_title=step_title,
                    step_score=round(score * 100.0, 1),
                    session_avg_score=round(running_avg * 100.0, 1),
                )
            )

            # Check for weak concepts (score <= 50%, i.e. 0/3 or 1/3 correct needing reinforcement)
            if score <= 0.50:
                correct_ans = int(round(score * 3))
                weak_concepts.append(
                    WeakConceptDTO(
                        session_id=sp.session_id,
                        topic=session.topic,
                        step_index=sp.step_index,
                        step_title=step_title,
                        quiz_score=round(score * 100.0, 1),
                        correct_count=correct_ans,
                        total_questions=3,
                        completed_at=sp.completed_at,
                    )
                )

        avg_quiz_score_overall = (
            round((sum_quiz_scores / total_quiz_count) * 100.0, 1)
            if total_quiz_count > 0 else 0.0
        )
        total_questions_evaluated = total_quiz_count * 3
        questions_correct = int(round(sum_quiz_scores * 3))

        # ── 7. Calculate Topics & Modes ───────────────────────────────
        topic_counts: dict[str, int] = {}
        mode_counts = {"visual": 0, "deep_dive": 0, "bite_sized": 0}

        for s in filtered_sessions:
            clean_topic = s.topic.strip().title() if s.topic else "General Study"
            topic_counts[clean_topic] = topic_counts.get(clean_topic, 0) + 1

            mode_key = (s.learning_mode or "visual").lower()
            if mode_key in mode_counts:
                mode_counts[mode_key] += 1
            else:
                mode_counts["visual"] += 1

        total_filtered_sessions = len(filtered_sessions)
        topic_breakdown: list[TopicBreakdownDTO] = []
        for top_name, count in sorted(topic_counts.items(), key=lambda x: x[1], reverse=True)[:6]:
            pct = round((count / total_filtered_sessions) * 100.0, 1) if total_filtered_sessions > 0 else 0.0
            topic_breakdown.append(TopicBreakdownDTO(topic=top_name, session_count=count, percentage=pct))

        # ── 8. Summary DTO ────────────────────────────────────────────
        completed_sessions_count = sum(1 for s in filtered_sessions if s.is_complete)
        completion_rate = (
            round((completed_sessions_count / total_filtered_sessions) * 100.0, 1)
            if total_filtered_sessions > 0 else 0.0
        )
        mastered_steps_count = sum(
            1 for sp in all_step_records
            if sp.status == "complete" and (not start_date or (_to_naive_utc(sp.completed_at) and _to_naive_utc(sp.completed_at) >= start_date))
        )

        summary_dto = DashboardSummaryDTO(
            total_sessions=total_filtered_sessions,
            completed_sessions=completed_sessions_count,
            completion_rate=completion_rate,
            total_steps_mastered=mastered_steps_count,
            total_study_minutes=total_study_minutes,
            average_quiz_score_overall=avg_quiz_score_overall,
            total_xp=total_all_time_xp,
            current_level=level_info["level"],
            level_title=level_info["title"],
            xp_progress_in_level=level_info["xp_in_level"],
            xp_needed_for_next=level_info["xp_needed_for_next"],
            is_max_level=level_info.get("is_max_level", False),
            current_streak=current_streak,
            longest_streak=longest_streak,
        )

        # ── 9. Activity Heatmap List (Last 90 Days) ───────────────────
        heatmap_days: list[HeatmapDayDTO] = []
        for d_str, data in sorted(heatmap_data.items()):
            heatmap_days.append(
                HeatmapDayDTO(
                    date=d_str,
                    steps_count=data["steps_count"],
                    xp_earned=data["xp_earned"],
                    active_minutes=data["active_minutes"],
                )
            )

        # ── 10. Dynamic Milestone Achievements ────────────────────────
        achievements = AnalyticsService._evaluate_achievements(
            total_steps=mastered_steps_count,
            completed_sessions=completed_sessions_count,
            perfect_quizzes=perfect_count,
            longest_streak=longest_streak,
            deep_dive_count=mode_counts["deep_dive"],
            distinct_topics=len(topic_counts),
            total_xp=total_all_time_xp,
        )

        return LearningDashboardResponse(
            summary=summary_dto,
            quiz_metrics=QuizMetricsDTO(
                total_quizzes_taken=total_quiz_count,
                total_questions_evaluated=total_questions_evaluated,
                questions_correct=questions_correct,
                perfect_quizzes_count=perfect_count,
                accuracy_trend=accuracy_trend[-20:],  # Last 20 quiz points for clean charting
                concepts_needing_reinforcement=weak_concepts[:8],  # Top 8 weak concepts needing review
            ),
            activity_heatmap=heatmap_days,
            topic_breakdown=topic_breakdown,
            mode_distribution=ModeDistributionDTO(
                visual=mode_counts["visual"],
                deep_dive=mode_counts["deep_dive"],
                bite_sized=mode_counts["bite_sized"],
            ),
            achievements=achievements,
        )

    @staticmethod
    def _extract_step_title(session: SessionRecord, step_index: int) -> str:
        """Safely extract the step title from session.state_json."""
        if session.state_json and isinstance(session.state_json, dict):
            steps = session.state_json.get("steps", [])
            if 0 <= step_index < len(steps):
                step_obj = steps[step_index]
                if isinstance(step_obj, dict) and "title" in step_obj:
                    return str(step_obj["title"])
        return f"Step {step_index + 1}"

    @staticmethod
    def _calculate_streaks(active_dates_set: set[str], now: datetime) -> tuple[int, int]:
        """Calculate current active daily streak and all-time longest daily streak."""
        if not active_dates_set:
            return 0, 0

        # Parse and sort unique dates
        date_objs = sorted(
            [datetime.strptime(d, "%Y-%m-%d").date() for d in active_dates_set]
        )
        if not date_objs:
            return 0, 0

        # Calculate longest streak
        longest = 1
        current_streak_len = 1
        for i in range(1, len(date_objs)):
            if date_objs[i] == date_objs[i - 1] + timedelta(days=1):
                current_streak_len += 1
                if current_streak_len > longest:
                    longest = current_streak_len
            elif date_objs[i] > date_objs[i - 1] + timedelta(days=1):
                current_streak_len = 1

        # Calculate current streak
        today = now.date()
        yesterday = today - timedelta(days=1)
        latest_date = date_objs[-1]

        # Streak is active if user studied today or yesterday
        current = 0
        if latest_date in (today, yesterday):
            idx = len(date_objs) - 1
            current = 1
            curr_d = latest_date
            while idx > 0:
                prev_d = date_objs[idx - 1]
                if prev_d == curr_d - timedelta(days=1):
                    current += 1
                    curr_d = prev_d
                    idx -= 1
                else:
                    break

        return current, max(longest, current)

    @staticmethod
    def _evaluate_achievements(
        total_steps: int,
        completed_sessions: int,
        perfect_quizzes: int,
        longest_streak: int,
        deep_dive_count: int,
        distinct_topics: int,
        total_xp: int,
    ) -> list[AchievementDTO]:
        """Dynamically evaluate milestone achievements from aggregate performance."""
        return [
            AchievementDTO(
                id="first_step",
                title="First Step",
                description="Mastered your first learning milestone step",
                unlocked=total_steps >= 1,
                icon="flag",
            ),
            AchievementDTO(
                id="first_journey",
                title="Journey Pioneer",
                description="Completed an entire learning roadmap to 100%",
                unlocked=completed_sessions >= 1,
                icon="trophy",
            ),
            AchievementDTO(
                id="sharp_mind",
                title="Sharp Mind",
                description="Scored 100% (3/3) on 5 different milestone quizzes",
                unlocked=perfect_quizzes >= 5,
                icon="bullseye",
            ),
            AchievementDTO(
                id="habit_builder",
                title="Habit Builder",
                description="Maintained an active study streak of 3+ consecutive days",
                unlocked=longest_streak >= 3,
                icon="flame",
            ),
            AchievementDTO(
                id="deep_diver",
                title="Deep Diver",
                description="Completed 2+ sessions in rigorous Deep Dive research mode",
                unlocked=deep_dive_count >= 2,
                icon="compass",
            ),
            AchievementDTO(
                id="polymath",
                title="Polymath",
                description="Explored concepts across 3 or more distinct topics",
                unlocked=distinct_topics >= 3,
                icon="books",
            ),
            AchievementDTO(
                id="grand_sage",
                title="Grand Sage",
                description="Reached Level 10 by amassing over 1,000 all-time XP",
                unlocked=total_xp >= 1000,
                icon="crown",
            ),
        ]
