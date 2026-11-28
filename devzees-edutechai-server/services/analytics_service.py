"""
EduTechAI — Analytics Service

Consolidates and computes personal learning performance, quiz metrics,
habits, topic mastery, and gamified achievement stats for the learner dashboard.
"""

from __future__ import annotations

from datetime import date, datetime, timedelta, timezone
import logging
from typing import Any

from sqlalchemy import and_, bindparam, case, func, or_, select, text, true
from sqlalchemy.ext.asyncio import AsyncSession

from app.exceptions import BadRequestException, UnprocessableEntityException
from models.dashboard_schemas import (
    AchievementDTO,
    DashboardSummaryDTO,
    HeatmapDayDTO,
    LearnerStandingResponse,
    LearningDashboardResponse,
    ModeDistributionDTO,
    PeriodPerformanceResponse,
    PeriodSummaryDTO,
    QuizAccuracyTrendItemDTO,
    QuizMetricsDTO,
    TopicBreakdownDTO,
    TrophyRequirementDTO,
    WeakConceptDTO,
)
from models.db_models import GamificationRecord, SessionRecord, StepProgress, UserTrophy
from services.cache import BoundedTTLCache
from services.gamification import calculate_level

logger = logging.getLogger(__name__)

# Bounded in-memory LRU+TTL cache for all-time LearnerStandingResponse (no Redis)
CACHE_TTL_SECONDS = 300  # 5 minutes
STANDING_CACHE_MAXSIZE = 10000
_standing_cache: BoundedTTLCache[LearnerStandingResponse] = BoundedTTLCache(
    maxsize=STANDING_CACHE_MAXSIZE,
    ttl_seconds=float(CACHE_TTL_SECONDS),
    sliding=False,
)

# Mode median durations in minutes (for idle break clamping)
MODE_MEDIAN_MINUTES: dict[str, int] = {
    "bite_sized": 5,
    "visual": 10,
    "deep_dive": 18,
}
DEFAULT_STEP_MINUTES = 10
MAX_STEP_ACTIVE_WINDOW_MINUTES = 30

# ─── Prestige Trophy Definitions ──────────────────────────────────
TROPHY_ORDER: list[str] = ["bronze", "silver", "gold", "platinum", "sapphire", "diamond"]

TROPHY_THRESHOLDS: dict[str, dict[str, int]] = {
    "bronze": {"sessions": 1, "steps": 5, "quizzes": 3, "streak": 0, "xp": 0},
    "silver": {"sessions": 5, "steps": 25, "quizzes": 8, "streak": 2, "xp": 0},
    "gold": {"sessions": 10, "steps": 60, "quizzes": 15, "streak": 3, "xp": 1000},
    "platinum": {"sessions": 25, "steps": 150, "quizzes": 25, "streak": 7, "xp": 0},
    "sapphire": {"sessions": 50, "steps": 250, "quizzes": 40, "streak": 14, "xp": 0},
    "diamond": {"sessions": 100, "steps": 500, "quizzes": 75, "streak": 30, "xp": 0},
}

TROPHY_DISPLAY_NAMES: dict[str, str] = {
    "bronze": "Bronze Trophy",
    "silver": "Silver Trophy",
    "gold": "Gold Trophy",
    "platinum": "Platinum Trophy",
    "sapphire": "Sapphire Trophy",
    "diamond": "Diamond Trophy",
}


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
    def invalidate_standing_cache(user_id: str | None = None) -> None:
        """Invalidate in-memory standing cache for a user or all users."""
        if user_id:
            _standing_cache.pop(user_id, None)
        else:
            _standing_cache.clear()

    @staticmethod
    async def get_user_standing(
        db: AsyncSession,
        user_id: str,
    ) -> LearnerStandingResponse:
        """
        Retrieve all-time cumulative standing: Level, XP, Streaks, and permanent achievements.
        Results are cached in memory for sub-5ms responses and evicted on progression events.
        """
        now = datetime.now(timezone.utc).replace(tzinfo=None)
        cached = _standing_cache.get(user_id)
        if cached is not None:
            return cached

        # 1. Consolidated CTE query for XP, Session aggregates, and Step aggregates (3 queries -> 1 round trip)
        xp_cte = (
            select(
                func.coalesce(func.sum(GamificationRecord.xp_earned), 0).label("total_all_time_xp")
            )
            .join(SessionRecord, GamificationRecord.session_id == SessionRecord.session_id)
            .where(SessionRecord.user_id == user_id)
            .cte("xp_stats")
        )
        session_cte = (
            select(
                func.count(case((SessionRecord.is_complete == True, 1))).label("completed_sessions"),
                func.count(
                    case(
                        (
                            (func.lower(SessionRecord.learning_mode) == "deep_dive")
                            & (SessionRecord.is_complete == True),
                            1,
                        )
                    )
                ).label("deep_dive_count"),
                func.count(func.distinct(func.lower(func.trim(SessionRecord.topic)))).label(
                    "distinct_topics"
                ),
            )
            .where(SessionRecord.user_id == user_id)
            .cte("session_stats")
        )
        step_cte = (
            select(
                func.count(StepProgress.id).label("total_steps"),
                func.count(case((StepProgress.quiz_score >= 1.0, 1))).label("perfect_quizzes"),
            )
            .join(SessionRecord, StepProgress.session_id == SessionRecord.session_id)
            .where(
                SessionRecord.user_id == user_id,
                StepProgress.status == "complete",
            )
            .cte("step_stats")
        )
        combined_stats_query = select(
            xp_cte.c.total_all_time_xp,
            session_cte.c.completed_sessions,
            session_cte.c.deep_dive_count,
            session_cte.c.distinct_topics,
            step_cte.c.total_steps,
            step_cte.c.perfect_quizzes,
        ).select_from(
            xp_cte.join(session_cte, true()).join(step_cte, true())
        )
        stats_row = (await db.execute(combined_stats_query)).one()
        total_all_time_xp = int(stats_row.total_all_time_xp or 0)
        completed_sessions = int(stats_row.completed_sessions or 0)
        deep_dive_count = int(stats_row.deep_dive_count or 0)
        distinct_topics = int(stats_row.distinct_topics or 0)
        total_steps = int(stats_row.total_steps or 0)
        perfect_quizzes = int(stats_row.perfect_quizzes or 0)

        # 2. Query only distinct active calendar dates for streak calculation
        sp_dates_query = (
            select(func.distinct(func.date(StepProgress.completed_at)))
            .join(SessionRecord, StepProgress.session_id == SessionRecord.session_id)
            .where(
                SessionRecord.user_id == user_id,
                StepProgress.status == "complete",
                StepProgress.completed_at.isnot(None),
            )
        )
        sp_dates_res = await db.execute(sp_dates_query)
        active_dates_set = {
            d.strftime("%Y-%m-%d") if hasattr(d, "strftime") else str(d)
            for (d,) in sp_dates_res.all()
            if d
        }
        current_streak, longest_streak = AnalyticsService._calculate_streaks(active_dates_set, now)

        # 4. Trophy Persistence & Evaluation (All-Time)
        persisted_query = (
            select(UserTrophy.trophy_id, UserTrophy.unlocked_at)
            .where(UserTrophy.user_id == user_id)
        )
        persisted_res = await db.execute(persisted_query)
        persisted_trophies: dict[str, datetime] = {
            row.trophy_id: row.unlocked_at for row in persisted_res.all()
        }

        evaluated = AnalyticsService._evaluate_achievements(
            total_steps=total_steps,
            completed_sessions=completed_sessions,
            perfect_quizzes=perfect_quizzes,
            longest_streak=longest_streak,
            deep_dive_count=deep_dive_count,
            distinct_topics=distinct_topics,
            total_xp=total_all_time_xp,
        )

        now_utc = datetime.now(timezone.utc).replace(tzinfo=None)
        final_achievements: list[AchievementDTO] = []
        newly_unlocked: list[UserTrophy] = []

        for ach in evaluated:
            if ach.id in persisted_trophies:
                ach.unlocked = True
                ach.unlocked_at = persisted_trophies[ach.id]
            elif ach.unlocked:
                ach.unlocked_at = now_utc
                newly_unlocked.append(
                    UserTrophy(
                        user_id=user_id,
                        trophy_id=ach.id,
                        unlocked_at=now_utc,
                    )
                )
            final_achievements.append(ach)

        if newly_unlocked:
            db.add_all(newly_unlocked)
            await db.flush()

        trophy_identity = AnalyticsService._compute_trophy_identity(
            achievements=final_achievements,
            completed_sessions=completed_sessions,
            total_steps=total_steps,
            perfect_quizzes=perfect_quizzes,
            longest_streak=longest_streak,
            total_xp=total_all_time_xp,
        )

        response = LearnerStandingResponse(
            total_xp=total_all_time_xp,
            highest_trophy_id=trophy_identity["highest_trophy_id"],
            highest_trophy_title=trophy_identity["highest_trophy_title"],
            next_trophy_id=trophy_identity["next_trophy_id"],
            next_trophy_title=trophy_identity["next_trophy_title"],
            next_trophy_requirements=trophy_identity["next_trophy_requirements"],
            trophy_progress_fraction=trophy_identity["trophy_progress_fraction"],
            current_streak=current_streak,
            longest_streak=longest_streak,
            achievements=final_achievements,
        )

        _standing_cache[user_id] = response
        return response

    @staticmethod
    def _compute_trophy_identity(
        achievements: list[AchievementDTO],
        completed_sessions: int,
        total_steps: int,
        perfect_quizzes: int,
        longest_streak: int,
        total_xp: int = 0,
    ) -> dict[str, Any]:
        """Compute highest unlocked trophy, next trophy, requirements, and progress fraction."""
        unlocked_ids = {a.id for a in achievements if a.unlocked}

        highest_trophy_id: str | None = None
        highest_trophy_title: str = "Unranked"
        for tid in reversed(TROPHY_ORDER):
            if tid in unlocked_ids:
                highest_trophy_id = tid
                highest_trophy_title = TROPHY_DISPLAY_NAMES[tid]
                break

        if highest_trophy_id == "diamond":
            return {
                "highest_trophy_id": "diamond",
                "highest_trophy_title": TROPHY_DISPLAY_NAMES["diamond"],
                "next_trophy_id": None,
                "next_trophy_title": None,
                "next_trophy_requirements": None,
                "trophy_progress_fraction": 1.0,
            }

        if highest_trophy_id is None:
            next_idx = 0
        else:
            next_idx = TROPHY_ORDER.index(highest_trophy_id) + 1

        next_trophy_id: str | None = None
        next_trophy_title: str | None = None
        next_requirements: list[TrophyRequirementDTO] | None = None
        progress_fraction = 0.0

        if next_idx < len(TROPHY_ORDER):
            next_trophy_id = TROPHY_ORDER[next_idx]
            next_trophy_title = TROPHY_DISPLAY_NAMES[next_trophy_id]
            thresholds = TROPHY_THRESHOLDS[next_trophy_id]

            current_vals = {
                "sessions": completed_sessions,
                "steps": total_steps,
                "quizzes": perfect_quizzes,
                "streak": longest_streak,
                "xp": total_xp,
            }

            label_map = {
                "sessions": "Sessions",
                "steps": "Steps",
                "quizzes": "Perfect Quizzes",
                "streak": "Day Streak",
                "xp": "Total XP",
            }

            reqs: list[TrophyRequirementDTO] = []
            ratios: list[float] = []
            for key, required in thresholds.items():
                if required <= 0:
                    continue
                current = current_vals[key]
                is_met = current >= required
                ratio = min(1.0, current / required) if required > 0 else 1.0
                ratios.append(ratio)
                reqs.append(
                    TrophyRequirementDTO(
                        label=label_map[key],
                        current=current,
                        required=required,
                        met=is_met,
                    )
                )

            next_requirements = reqs
            progress_fraction = (sum(ratios) / len(ratios)) if ratios else 0.0

        return {
            "highest_trophy_id": highest_trophy_id,
            "highest_trophy_title": highest_trophy_title,
            "next_trophy_id": next_trophy_id,
            "next_trophy_title": next_trophy_title,
            "next_trophy_requirements": next_requirements,
            "trophy_progress_fraction": round(progress_fraction, 3),
        }

    @staticmethod
    async def get_user_performance(
        db: AsyncSession,
        user_id: str,
        time_range: str = "30d",
        start_date: date | None = None,
        end_date: date | None = None,
        tz_offset_minutes: int = 0,
    ) -> PeriodPerformanceResponse:
        """
        Compute interval-scoped performance analytics for the selected window.
        Supports 7d, 30d, 90d, 1y, all, and custom date range with client timezone alignment.
        """
        valid_ranges = {"7d", "30d", "90d", "1y", "all", "custom"}
        if time_range not in valid_ranges:
            raise BadRequestException(
                "INVALID_TIME_RANGE",
                f"Invalid time_range '{time_range}'. Must be one of: {', '.join(sorted(valid_ranges))}.",
            )

        now = datetime.now(timezone.utc).replace(tzinfo=None)
        window_start: datetime | None = None
        window_end: datetime = now

        if time_range == "7d":
            window_start = now - timedelta(days=7)
        elif time_range == "30d":
            window_start = now - timedelta(days=30)
        elif time_range == "90d":
            window_start = now - timedelta(days=90)
        elif time_range == "1y":
            window_start = now - timedelta(days=365)
        elif time_range == "all":
            window_start = None
        elif time_range == "custom":
            if not start_date or not end_date:
                raise UnprocessableEntityException(
                    "MISSING_DATE_RANGE",
                    "Both start_date and end_date are required for custom time range.",
                )
            if start_date > end_date:
                raise BadRequestException(
                    "INVALID_DATE_RANGE",
                    "start_date cannot be after end_date.",
                )
            if (end_date - start_date).days > 730:
                raise UnprocessableEntityException(
                    "DATE_RANGE_EXCEEDED",
                    "The selected date range cannot exceed 730 days (2 years). Please choose a shorter window.",
                )
            tz_delta = timedelta(minutes=tz_offset_minutes)
            window_start = datetime.combine(start_date, datetime.min.time()) - tz_delta
            window_end = datetime.combine(end_date, datetime.max.time()) - tz_delta

        # 1. Fetch StepProgress (projected scalar columns, SQL-filtered by window when set)
        sp_filters = [SessionRecord.user_id == user_id]
        if window_start is not None:
            # Include a 30-min lookback before window_start so active-window step clamping
            # sees the immediate predecessor timestamp without loading all historical steps.
            lookback_start = window_start - timedelta(minutes=MAX_STEP_ACTIVE_WINDOW_MINUTES)
            sp_filters.append(
                or_(
                    and_(
                        StepProgress.completed_at >= lookback_start,
                        StepProgress.completed_at <= window_end,
                    ),
                    and_(
                        StepProgress.quiz_score.isnot(None),
                        StepProgress.completed_at.is_(None),
                    ),
                )
            )

        sp_query = (
            select(
                StepProgress.session_id,
                StepProgress.step_index,
                StepProgress.status,
                StepProgress.quiz_score,
                StepProgress.completed_at,
                StepProgress.xp_earned,
            )
            .join(SessionRecord, StepProgress.session_id == SessionRecord.session_id)
            .where(*sp_filters)
            .order_by(StepProgress.completed_at.asc().nulls_last())
        )
        sp_res = await db.execute(sp_query)
        all_step_records = sp_res.all()

        step_session_ids = list({sp.session_id for sp in all_step_records})

        # 2. Fetch User Sessions (projected scalar columns only — NEVER loads state_json)
        sess_filters = [SessionRecord.user_id == user_id]
        if window_start is not None:
            window_sess_or = [
                and_(
                    SessionRecord.created_at >= window_start,
                    SessionRecord.created_at <= window_end,
                ),
                and_(
                    SessionRecord.is_complete == True,
                    SessionRecord.updated_at >= window_start,
                    SessionRecord.updated_at <= window_end,
                ),
            ]
            if step_session_ids:
                window_sess_or.append(SessionRecord.session_id.in_(step_session_ids))
            sess_filters.append(or_(*window_sess_or))

        sessions_query = (
            select(
                SessionRecord.session_id,
                SessionRecord.topic,
                SessionRecord.learning_mode,
                SessionRecord.total_steps,
                SessionRecord.is_complete,
                SessionRecord.created_at,
                SessionRecord.updated_at,
            )
            .where(*sess_filters)
            .order_by(SessionRecord.created_at.desc())
        )
        sessions_res = await db.execute(sessions_query)
        all_user_sessions = sessions_res.all()
        session_lookup = {s.session_id: s for s in all_user_sessions}

        # 2b. When window-filtered, fetch SQL-aggregated step totals & last_completed_at
        #     only for candidate sessions so topic_breakdown % and completion timestamps
        #     remain exact even for sessions spanning across window boundaries.
        session_step_agg: dict[str, tuple[int, int, datetime | None]] = {}
        if window_start is not None and session_lookup:
            agg_query = (
                select(
                    StepProgress.session_id,
                    func.count(StepProgress.id).label("total_rows"),
                    func.count(case((StepProgress.status == "complete", 1))).label("completed_rows"),
                    func.max(
                        case((StepProgress.status == "complete", StepProgress.completed_at))
                    ).label("last_completed_at"),
                )
                .where(StepProgress.session_id.in_(list(session_lookup.keys())))
                .group_by(StepProgress.session_id)
            )
            agg_res = await db.execute(agg_query)
            for row in agg_res.all():
                session_step_agg[row.session_id] = (
                    int(row.total_rows or 0),
                    int(row.completed_rows or 0),
                    row.last_completed_at,
                )

        # 3. Process Steps, Duration Clamping & Heatmap
        steps_by_session: dict[str, list[Any]] = {}
        for sp in all_step_records:
            steps_by_session.setdefault(sp.session_id, []).append(sp)

        total_study_minutes = 0
        heatmap_data: dict[str, dict[str, int]] = {}
        mastered_steps_count = 0
        xp_earned_in_period = 0
        active_session_ids: set[str] = set()
        completed_session_ids: set[str] = set()

        for session_id, session in session_lookup.items():
            steps = steps_by_session.get(session_id, [])
            mode = (session.learning_mode or "visual").lower()
            mode_median = MODE_MEDIAN_MINUTES.get(mode, DEFAULT_STEP_MINUTES)
            completed_steps = [sp for sp in steps if sp.status == "complete" and sp.completed_at]
            completed_steps.sort(key=lambda x: _to_naive_utc(x.completed_at) or datetime.min)

            last_timestamp = _to_naive_utc(session.created_at) or datetime.now(timezone.utc).replace(tzinfo=None)
            for sp in completed_steps:
                sp_completed = _to_naive_utc(sp.completed_at)
                if not sp_completed:
                    continue

                delta_minutes = (sp_completed - last_timestamp).total_seconds() / 60.0
                if 0 < delta_minutes <= MAX_STEP_ACTIVE_WINDOW_MINUTES:
                    effective_minutes = int(round(delta_minutes))
                else:
                    effective_minutes = mode_median

                last_timestamp = sp_completed

                is_in_window = True
                if window_start:
                    is_in_window = (sp_completed >= window_start and sp_completed <= window_end)

                if is_in_window:
                    total_study_minutes += effective_minutes
                    mastered_steps_count += 1
                    active_session_ids.add(session_id)

                    if sp.xp_earned is not None and sp.xp_earned > 0:
                        step_xp = sp.xp_earned
                    else:
                        step_xp = 10 + (round(sp.quiz_score * 70) if sp.quiz_score is not None else 0)
                    xp_earned_in_period += step_xp

                    day_key = sp_completed.strftime("%Y-%m-%d")
                    if day_key not in heatmap_data:
                        heatmap_data[day_key] = {"steps_count": 0, "xp_earned": 0, "active_minutes": 0}
                    heatmap_data[day_key]["steps_count"] += 1
                    heatmap_data[day_key]["active_minutes"] += effective_minutes
                    heatmap_data[day_key]["xp_earned"] += step_xp

            # Completion consistency: evaluate if session finished in window
            if session.is_complete and (steps or session_id in session_step_agg):
                completion_ts = None
                if completed_steps:
                    completion_ts = _to_naive_utc(completed_steps[-1].completed_at)
                elif session_id in session_step_agg and session_step_agg[session_id][2]:
                    completion_ts = _to_naive_utc(session_step_agg[session_id][2])
                if not completion_ts and session.updated_at:
                    completion_ts = _to_naive_utc(session.updated_at)

                if completion_ts:
                    if not window_start or (completion_ts >= window_start and completion_ts <= window_end):
                        completed_session_ids.add(session_id)
                        active_session_ids.add(session_id)

        # Also count sessions initiated in the window
        for s in all_user_sessions:
            s_created = _to_naive_utc(s.created_at)
            if s_created:
                if not window_start or (s_created >= window_start and s_created <= window_end):
                    active_session_ids.add(s.session_id)
                    if s.is_complete and s.session_id not in completed_session_ids:
                        s_updated = _to_naive_utc(s.updated_at)
                        if not window_start or (s_updated and s_updated >= window_start and s_updated <= window_end):
                            completed_session_ids.add(s.session_id)

        # 4. Quizzes & Accuracy Trendline
        weak_concepts: list[WeakConceptDTO] = []
        accuracy_trend: list[QuizAccuracyTrendItemDTO] = []
        total_quiz_count = 0
        sum_quiz_scores = 0.0
        perfect_count = 0

        sorted_steps_with_quiz = [sp for sp in all_step_records if sp.quiz_score is not None]
        sorted_steps_with_quiz.sort(key=lambda x: _to_naive_utc(x.completed_at) or datetime.min)

        quiz_steps_in_window = []
        for sp in sorted_steps_with_quiz:
            if sp.session_id not in session_lookup:
                continue
            sp_completed = _to_naive_utc(sp.completed_at)
            if window_start and sp_completed and (sp_completed < window_start or sp_completed > window_end):
                continue
            quiz_steps_in_window.append(sp)

        # Fetch ONLY step titles for sessions that have quizzes in the window
        step_titles_map = await AnalyticsService._fetch_step_titles(
            db, list({sp.session_id for sp in quiz_steps_in_window})
        )

        session_scores_accumulator: dict[str, list[float]] = {}

        for sp in quiz_steps_in_window:
            session = session_lookup[sp.session_id]
            sp_completed = _to_naive_utc(sp.completed_at)

            score = float(sp.quiz_score)
            total_quiz_count += 1
            sum_quiz_scores += score
            if score >= 1.0:
                perfect_count += 1

            step_title = step_titles_map.get((sp.session_id, sp.step_index), f"Step {sp.step_index + 1}")
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

        # 5. Learning Journey Mastery Breakdown & Mode Distribution
        total_active_sessions = len(active_session_ids)
        journeys: list[TopicBreakdownDTO] = []
        mode_counts = {"visual": 0, "deep_dive": 0, "bite_sized": 0}
        for sid in active_session_ids:
            s = session_lookup.get(sid)
            if not s:
                continue

            mode_key = (s.learning_mode or "visual").lower()
            if mode_key in mode_counts:
                mode_counts[mode_key] += 1
            else:
                mode_counts["visual"] += 1

            if sid in session_step_agg:
                total_step_rows, completed_count, _ = session_step_agg[sid]
            else:
                steps = steps_by_session.get(sid, [])
                completed_count = sum(1 for sp in steps if sp.status == "complete")
                total_step_rows = len(steps)

            total = s.total_steps if s.total_steps and s.total_steps > 0 else total_step_rows

            if s.is_complete:
                pct = 100.0
                if total == 0:
                    total = max(completed_count, 1)
                completed_count = total
            else:
                pct = round((completed_count / total) * 100.0, 1) if total > 0 else 0.0
                if pct >= 100.0:
                    pct = 99.0

            clean_topic = s.topic.strip() if s.topic else "General Study"

            journeys.append(
                TopicBreakdownDTO(
                    topic=clean_topic,
                    session_count=1,
                    percentage=pct,
                    session_id=s.session_id,
                    is_complete=s.is_complete,
                    completed_steps=completed_count,
                    total_steps=total,
                    learning_mode=mode_key,
                )
            )

        # Sort journeys by completion percentage descending, then by most recently updated
        journeys.sort(
            key=lambda j: (
                j.percentage,
                _to_naive_utc(session_lookup[j.session_id].updated_at)
                or _to_naive_utc(session_lookup[j.session_id].created_at)
                or datetime.min,
            ),
            reverse=True,
        )
        topic_breakdown: list[TopicBreakdownDTO] = journeys[:10]

        # 6. Period Summary & Completion Rates
        completed_sessions_count = len(completed_session_ids)
        completion_rate = (
            round((completed_sessions_count / total_active_sessions) * 100.0, 1)
            if total_active_sessions > 0 else 0.0
        )

        period_summary = PeriodSummaryDTO(
            total_sessions=total_active_sessions,
            completed_sessions=completed_sessions_count,
            completion_rate=completion_rate,
            total_steps_mastered=mastered_steps_count,
            total_study_minutes=total_study_minutes,
            xp_earned_in_period=xp_earned_in_period,
            average_quiz_score_overall=avg_quiz_score_overall,
        )

        # 7. Activity Heatmap List
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

        return PeriodPerformanceResponse(
            time_range=time_range,
            start_date=window_start,
            end_date=window_end,
            summary=period_summary,
            quiz_metrics=QuizMetricsDTO(
                total_quizzes_taken=total_quiz_count,
                total_questions_evaluated=total_questions_evaluated,
                questions_correct=questions_correct,
                perfect_quizzes_count=perfect_count,
                accuracy_trend=accuracy_trend,  # All trend points for smooth scrollable charting
                concepts_needing_reinforcement=weak_concepts[:8],
            ),
            activity_heatmap=heatmap_days,
            topic_breakdown=topic_breakdown,
            mode_distribution=ModeDistributionDTO(
                visual=mode_counts["visual"],
                deep_dive=mode_counts["deep_dive"],
                bite_sized=mode_counts["bite_sized"],
            ),
        )

    @staticmethod
    async def get_user_dashboard(
        db: AsyncSession,
        user_id: str,
        time_range: str = "30d",
    ) -> LearningDashboardResponse:
        """
        Legacy consolidated dashboard method combining standing and performance.
        Preserved for test compatibility.
        """
        standing = await AnalyticsService.get_user_standing(db, user_id=user_id)
        performance = await AnalyticsService.get_user_performance(db, user_id=user_id, time_range=time_range)
        level_info = calculate_level(standing.total_xp)

        summary_dto = DashboardSummaryDTO(
            total_sessions=performance.summary.total_sessions,
            completed_sessions=performance.summary.completed_sessions,
            completion_rate=performance.summary.completion_rate,
            total_steps_mastered=performance.summary.total_steps_mastered,
            total_study_minutes=performance.summary.total_study_minutes,
            average_quiz_score_overall=performance.summary.average_quiz_score_overall,
            total_xp=standing.total_xp,
            current_level=level_info["level"],
            level_title=level_info["title"],
            xp_progress_in_level=level_info["xp_in_level"],
            xp_needed_for_next=level_info["xp_needed_for_next"],
            is_max_level=level_info.get("is_max_level", False),
            current_streak=standing.current_streak,
            longest_streak=standing.longest_streak,
        )

        quiz_metrics = performance.quiz_metrics
        quiz_metrics.accuracy_trend = quiz_metrics.accuracy_trend[-20:]

        return LearningDashboardResponse(
            summary=summary_dto,
            quiz_metrics=quiz_metrics,
            activity_heatmap=performance.activity_heatmap,
            topic_breakdown=performance.topic_breakdown,
            mode_distribution=performance.mode_distribution,
            achievements=standing.achievements,
        )

    @staticmethod
    async def _fetch_step_titles(
        db: AsyncSession,
        session_ids: list[str],
    ) -> dict[tuple[str, int], str]:
        """
        Extract only (session_id, step_index) -> step title without loading full state_json blobs.
        Uses PostgreSQL JSONB array extraction when running on Postgres, with a generic fallback.
        """
        if not session_ids:
            return {}

        titles: dict[tuple[str, int], str] = {}
        dialect_name = db.bind.dialect.name if db.bind is not None else ""

        if dialect_name == "postgresql":
            stmt = text(
                """
                SELECT s.session_id,
                       (arr.ord - 1)::int AS step_index,
                       arr.elem->>'title' AS title
                FROM sessions s
                CROSS JOIN LATERAL jsonb_array_elements(
                    CASE
                        WHEN s.state_json IS NOT NULL
                             AND jsonb_typeof((s.state_json::jsonb) -> 'steps') = 'array'
                        THEN (s.state_json::jsonb) -> 'steps'
                        ELSE '[]'::jsonb
                    END
                ) WITH ORDINALITY AS arr(elem, ord)
                WHERE s.session_id IN :session_ids
                """
            ).bindparams(bindparam("session_ids", expanding=True))
            res = await db.execute(stmt, {"session_ids": session_ids})
            for row in res.all():
                if row.title is not None:
                    titles[(row.session_id, int(row.step_index))] = str(row.title)
            return titles

        # Generic fallback for non-PostgreSQL dialects (e.g., SQLite in isolated tests)
        stmt = select(SessionRecord.session_id, SessionRecord.state_json).where(
            SessionRecord.session_id.in_(session_ids)
        )
        res = await db.execute(stmt)
        for sid, state_json in res.all():
            if state_json and isinstance(state_json, dict):
                steps = state_json.get("steps", [])
                for idx, step_obj in enumerate(steps):
                    if isinstance(step_obj, dict) and "title" in step_obj and step_obj["title"] is not None:
                        titles[(sid, idx)] = str(step_obj["title"])
        return titles

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
        deep_dive_count: int = 0,
        distinct_topics: int = 0,
        total_xp: int = 0,
    ) -> list[AchievementDTO]:
        """
        Dynamically evaluate the 6-tier prestige trophy ladder from aggregate performance:
        Bronze -> Silver -> Gold -> Platinum -> Sapphire -> Diamond.
        """
        return [
            AchievementDTO(
                id="bronze",
                title="Bronze Trophy",
                description="Mastered your first learning steps (1 session, 5 steps, 3 perfect quizzes)",
                unlocked=(
                    completed_sessions >= 1
                    and total_steps >= 5
                    and perfect_quizzes >= 3
                ),
                icon="bronze",
            ),
            AchievementDTO(
                id="silver",
                title="Silver Trophy",
                description="Established active learning consistency (5 sessions, 25 steps, 8 perfect quizzes, 2-day streak)",
                unlocked=(
                    completed_sessions >= 5
                    and total_steps >= 25
                    and perfect_quizzes >= 8
                    and longest_streak >= 2
                ),
                icon="silver",
            ),
            AchievementDTO(
                id="gold",
                title="Gold Trophy",
                description="True Grand Sage dedication (10 sessions, 60 steps, 15 perfect quizzes, 3-day streak, Level 10 Grand Sage)",
                unlocked=(
                    completed_sessions >= 10
                    and total_steps >= 60
                    and perfect_quizzes >= 15
                    and longest_streak >= 3
                    and total_xp >= 1000
                ),
                icon="gold",
            ),
            AchievementDTO(
                id="platinum",
                title="Platinum Trophy",
                description="Knowledge marathoner (25 sessions, 150 steps, 25 perfect quizzes, 7-day streak)",
                unlocked=(
                    completed_sessions >= 25
                    and total_steps >= 150
                    and perfect_quizzes >= 25
                    and longest_streak >= 7
                ),
                icon="platinum",
            ),
            AchievementDTO(
                id="sapphire",
                title="Sapphire Trophy",
                description="Dedicated intellectual scholar (50 sessions, 250 steps, 40 perfect quizzes, 14-day streak)",
                unlocked=(
                    completed_sessions >= 50
                    and total_steps >= 250
                    and perfect_quizzes >= 40
                    and longest_streak >= 14
                ),
                icon="sapphire",
            ),
            AchievementDTO(
                id="diamond",
                title="Diamond Trophy",
                description="The Apex Century master (100 sessions, 500 steps, 75 perfect quizzes, 30-day streak)",
                unlocked=(
                    completed_sessions >= 100
                    and total_steps >= 500
                    and perfect_quizzes >= 75
                    and longest_streak >= 30
                ),
                icon="diamond",
            ),
        ]
