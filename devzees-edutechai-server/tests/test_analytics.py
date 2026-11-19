"""
EduTechAI — Tests for AnalyticsService & Learner Performance Dashboard
"""

from datetime import datetime, timedelta, timezone
from uuid import uuid4
import pytest
from sqlalchemy import select

from models.db_models import GamificationRecord, SessionRecord, StepProgress
from models.schemas import LearningMode, MilestoneStep, StepStatus
from models.shared_memory import SharedMemory
from models.user_schemas import UserCreateRequest
from services.analytics_service import AnalyticsService
from services.database import get_db_session, init_db
from services.session_manager import SessionManager
from services.user_service import UserService


@pytest.mark.asyncio
async def test_analytics_service_empty_user():
    """Verify default clean metrics for a brand new user with no sessions."""
    await init_db()
    async with get_db_session() as db:
        user_req = UserCreateRequest(
            first_name="BrandNew",
            last_name="Learner",
            email=f"newbie_{uuid4().hex[:8]}@example.com",
            password="SecurePassword123!",
        )
        user = await UserService.create_user(db, user_req)

        dashboard = await AnalyticsService.get_user_dashboard(db, user_id=user.id, time_range="30d")

        assert dashboard.summary.total_sessions == 0
        assert dashboard.summary.completed_sessions == 0
        assert dashboard.summary.completion_rate == 0.0
        assert dashboard.summary.total_steps_mastered == 0
        assert dashboard.summary.total_study_minutes == 0
        assert dashboard.summary.total_xp == 0
        assert dashboard.summary.current_level == 1
        assert dashboard.summary.level_title == "Curious Explorer"
        assert dashboard.quiz_metrics.total_quizzes_taken == 0
        assert len(dashboard.quiz_metrics.accuracy_trend) == 0
        assert len(dashboard.quiz_metrics.concepts_needing_reinforcement) == 0
        assert dashboard.mode_distribution.visual == 0
        assert dashboard.mode_distribution.deep_dive == 0
        assert dashboard.mode_distribution.bite_sized == 0


@pytest.mark.asyncio
async def test_analytics_service_active_user_metrics():
    """Verify precise calculation of sessions, steps, 3-question quizzes, clamping, and achievements."""
    await init_db()
    sm = SessionManager()
    now = datetime.utcnow()

    async with get_db_session() as db:
        # 1. Create User
        user_req = UserCreateRequest(
            first_name="Active",
            last_name="Scholar",
            email=f"scholar_{uuid4().hex[:8]}@example.com",
            password="SecurePassword123!",
        )
        user = await UserService.create_user(db, user_req)
        user_id = user.id

    # 2. Create Session 1 (Visual Mode, Completed, 3 steps)
    mem1 = SharedMemory(
        user_id=user_id,
        topic="Python Concurrency",
        learning_mode=LearningMode.VISUAL,
        student_level="undergraduate",
    )
    mem1.steps = [
        MilestoneStep(index=0, title="Event Loop", description="Core loop", status=StepStatus.COMPLETE),
        MilestoneStep(index=1, title="Coroutines", description="Async/Await", status=StepStatus.COMPLETE),
        MilestoneStep(index=2, title="Tasks & Futures", description="Task grouping", status=StepStatus.COMPLETE),
    ]
    mem1.current_step_index = 3
    mem1.steps_completed = 3
    mem1.xp_earned = 280
    await sm.create_session(mem1, user_id=user_id)

    # 3. Create Session 2 (Deep Dive Mode, In Progress, 2 steps)
    mem2 = SharedMemory(
        user_id=user_id,
        topic="Quantum Computing",
        learning_mode=LearningMode.DEEP_DIVE,
        student_level="graduate",
    )
    mem2.steps = [
        MilestoneStep(index=0, title="Qubit Superposition", description="Quantum states", status=StepStatus.COMPLETE),
        MilestoneStep(index=1, title="Quantum Entanglement", description="Bell states", status=StepStatus.IN_PROGRESS),
    ]
    mem2.current_step_index = 1
    mem2.steps_completed = 1
    mem2.xp_earned = 140
    await sm.create_session(mem2, user_id=user_id)

    # 4. Populate quiz scores & completion dates into step_progress
    async with get_db_session() as db:
        # Session 1 steps
        sp_res1 = await db.execute(
            select(StepProgress).where(StepProgress.session_id == mem1.session_id).order_by(StepProgress.step_index)
        )
        steps1 = list(sp_res1.scalars().all())
        steps1[0].status = "complete"
        steps1[0].quiz_score = 1.0  # 3/3 correct
        steps1[0].completed_at = now - timedelta(days=2, hours=2)

        steps1[1].status = "complete"
        steps1[1].quiz_score = 0.67  # 2/3 correct
        steps1[1].completed_at = now - timedelta(days=2, hours=1, minutes=45)  # 15 min gap (normal)

        steps1[2].status = "complete"
        steps1[2].quiz_score = 0.33  # 1/3 correct -> WEAK CONCEPT!
        steps1[2].completed_at = now - timedelta(days=2, hours=1)  # 45 min gap (clamped to 10 min)

        # Mark session 1 complete
        s_res1 = await db.execute(select(SessionRecord).where(SessionRecord.session_id == mem1.session_id))
        s_rec1 = s_res1.scalar_one()
        s_rec1.is_complete = True

        # Session 2 steps
        sp_res2 = await db.execute(
            select(StepProgress).where(StepProgress.session_id == mem2.session_id).order_by(StepProgress.step_index)
        )
        steps2 = list(sp_res2.scalars().all())
        steps2[0].status = "complete"
        steps2[0].quiz_score = 1.0  # 3/3 correct
        steps2[0].completed_at = now - timedelta(days=1)

        await db.commit()

    # 5. Fetch Dashboard
    async with get_db_session() as db:
        dashboard = await AnalyticsService.get_user_dashboard(db, user_id=user_id, time_range="30d")

        # Verify Summary
        assert dashboard.summary.total_sessions == 2
        assert dashboard.summary.completed_sessions == 1
        assert dashboard.summary.completion_rate == 50.0
        assert dashboard.summary.total_steps_mastered == 4
        assert dashboard.summary.total_study_minutes > 0
        assert dashboard.summary.total_xp == 420  # 280 + 140
        assert dashboard.summary.current_level >= 5  # 420 XP reaches Level 5 (Rising Scholar at 380 XP)
        assert dashboard.summary.level_title == "Rising Scholar"

        # Verify 3-Question Quiz Metrics
        assert dashboard.quiz_metrics.total_quizzes_taken == 4
        assert dashboard.quiz_metrics.total_questions_evaluated == 12  # 4 quizzes * 3
        assert dashboard.quiz_metrics.perfect_quizzes_count == 2  # Two 100% quizzes
        # Accuracy: (1.0 + 0.67 + 0.33 + 1.0) / 4 = 0.75 -> 75.0%
        assert 74.0 <= dashboard.summary.average_quiz_score_overall <= 76.0

        # Verify Weak Concepts
        assert len(dashboard.quiz_metrics.concepts_needing_reinforcement) == 1
        weak = dashboard.quiz_metrics.concepts_needing_reinforcement[0]
        assert weak.session_id == mem1.session_id
        assert weak.step_index == 2
        assert weak.correct_count == 1
        assert weak.total_questions == 3
        assert weak.step_title == "Tasks & Futures"

        # Verify Mode Distribution
        assert dashboard.mode_distribution.visual == 1
        assert dashboard.mode_distribution.deep_dive == 1
        assert dashboard.mode_distribution.bite_sized == 0

        # Verify 6-Tier Prestige Achievements
        assert len(dashboard.achievements) == 6
        expected_ids = {"bronze", "silver", "gold", "platinum", "sapphire", "diamond"}
        assert {a.id for a in dashboard.achievements} == expected_ids
        bronze_ach = next((a for a in dashboard.achievements if a.id == "bronze"), None)
        assert bronze_ach is not None
        assert bronze_ach.title == "Bronze Trophy"
        # In this test setup, user has completed 1 session, 4 steps, 2 perfect quizzes (Bronze requires 5 steps, 3 quizzes)
        assert bronze_ach.unlocked is False


@pytest.mark.asyncio
async def test_get_standing_and_performance_api_endpoints():
    """Verify GET /api/v1/learning/analytics/standing and /performance return 200 with ET_DASHBOARD."""
    from httpx import ASGITransport, AsyncClient
    from app.main import create_app
    from services.auth_service import AuthService

    app = create_app()
    await init_db()

    async with get_db_session() as db:
        user_req = UserCreateRequest(
            first_name="Endpoint",
            last_name="Tester",
            email=f"endpoint_{uuid4().hex[:8]}@example.com",
            password="SecurePassword123!",
        )
        user = await UserService.create_user(db, user_req)
        access_token = AuthService.create_access_token({"sub": user.id})

    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        headers = {"Authorization": f"Bearer {access_token}"}

        # 1. Test Standing Endpoint
        resp_standing = await ac.get("/api/v1/learning/analytics/standing", headers=headers)
        assert resp_standing.status_code == 200
        standing_data = resp_standing.json()
        assert "total_xp" in standing_data
        assert "current_level" in standing_data
        assert "level_title" in standing_data
        assert "current_streak" in standing_data
        assert "longest_streak" in standing_data
        assert "achievements" in standing_data
        assert standing_data["current_level"] == 1
        assert standing_data["level_title"] == "Curious Explorer"
        assert len(standing_data["achievements"]) == 6
        expected_ids = ["bronze", "silver", "gold", "platinum", "sapphire", "diamond"]
        assert [a["id"] for a in standing_data["achievements"]] == expected_ids

        # 2. Test Performance Endpoint (Preset 30d)
        resp_perf = await ac.get("/api/v1/learning/analytics/performance?time_range=30d", headers=headers)
        assert resp_perf.status_code == 200
        perf_data = resp_perf.json()
        assert perf_data["time_range"] == "30d"
        assert "summary" in perf_data
        assert "quiz_metrics" in perf_data
        assert "activity_heatmap" in perf_data
        assert "topic_breakdown" in perf_data
        assert "mode_distribution" in perf_data

        # 3. Test Custom Date Range with Timezone Offset
        today_str = datetime.utcnow().strftime("%Y-%m-%d")
        week_ago_str = (datetime.utcnow() - timedelta(days=7)).strftime("%Y-%m-%d")
        resp_custom = await ac.get(
            f"/api/v1/learning/analytics/performance?time_range=custom&start_date={week_ago_str}&end_date={today_str}&tz_offset_minutes=180",
            headers=headers,
        )
        assert resp_custom.status_code == 200
        custom_data = resp_custom.json()
        assert custom_data["time_range"] == "custom"
        assert custom_data["start_date"] is not None
        assert custom_data["end_date"] is not None

        # 4. Test 2-Year Date Range Exceeded Validation (HTTP 422)
        resp_too_long = await ac.get(
            "/api/v1/learning/analytics/performance?time_range=custom&start_date=2020-01-01&end_date=2024-01-01",
            headers=headers,
        )
        assert resp_too_long.status_code == 422
        assert "cannot exceed 730 days" in resp_too_long.text

        # 5. Test Inverted Dates (HTTP 400)
        resp_inverted = await ac.get(
            f"/api/v1/learning/analytics/performance?time_range=custom&start_date={today_str}&end_date={week_ago_str}",
            headers=headers,
        )
        assert resp_inverted.status_code == 400
        assert "cannot be after end_date" in resp_inverted.text

        # 6. Test Missing Custom Dates (HTTP 422)
        resp_missing = await ac.get(
            "/api/v1/learning/analytics/performance?time_range=custom",
            headers=headers,
        )
        assert resp_missing.status_code == 422
        assert "required for custom time range" in resp_missing.text

        # 7. Test Admin User Inspection RBAC
        # Create second user
        async with get_db_session() as db:
            other_user_req = UserCreateRequest(
                first_name="Other",
                last_name="Student",
                email=f"other_{uuid4().hex[:8]}@example.com",
                password="SecurePassword123!",
            )
            other_user = await UserService.create_user(db, other_user_req)
            other_user_id = other_user.id

        # Regular user without ET_VIEW_USER / ET_ALL trying to view other user's standing -> 403 Forbidden
        resp_forbidden = await ac.get(
            f"/api/v1/learning/analytics/standing?user_id={other_user_id}",
            headers=headers,
        )
        assert resp_forbidden.status_code == 403
        assert "Permission required" in resp_forbidden.text

        # Create Admin user with Admin role (possesses ET_ALL)
        async with get_db_session() as db:
            from models.db_models import Role
            admin_user_req = UserCreateRequest(
                first_name="Super",
                last_name="Admin",
                email=f"admin_{uuid4().hex[:8]}@example.com",
                password="SecurePassword123!",
            )
            admin_user = await UserService.create_user(db, admin_user_req)
            role_res = await db.execute(select(Role).where(Role.name == "Admin"))
            admin_role = role_res.scalar_one_or_none()
            if admin_role:
                admin_user.roles = [admin_role]
                await db.commit()
            admin_token = AuthService.create_access_token({"sub": admin_user.id})

        admin_headers = {"Authorization": f"Bearer {admin_token}"}
        # Admin inspecting other user's standing -> 200 OK
        resp_admin_standing = await ac.get(
            f"/api/v1/learning/analytics/standing?user_id={other_user_id}",
            headers=admin_headers,
        )
        assert resp_admin_standing.status_code == 200
        assert resp_admin_standing.json()["current_level"] == 1

        # Admin inspecting nonexistent user -> 404 Not Found
        resp_not_found = await ac.get(
            f"/api/v1/learning/analytics/standing?user_id={uuid4()}",
            headers=admin_headers,
        )
        assert resp_not_found.status_code == 404


def test_prestige_trophy_ladder_evaluation():
    """Verify dynamic evaluation logic for all 6 prestige trophies."""
    from services.analytics_service import AnalyticsService

    # 1. Base / New user: 0 everything -> all locked
    achievements = AnalyticsService._evaluate_achievements(
        total_steps=0,
        completed_sessions=0,
        perfect_quizzes=0,
        longest_streak=0,
        total_xp=0,
    )
    assert len(achievements) == 6
    assert all(a.unlocked is False for a in achievements)

    # 2. Bronze unlocked: 1 session, 5 steps, 3 perfect quizzes
    ach_bronze = AnalyticsService._evaluate_achievements(
        total_steps=5,
        completed_sessions=1,
        perfect_quizzes=3,
        longest_streak=1,
        total_xp=300,
    )
    by_id = {a.id: a for a in ach_bronze}
    assert by_id["bronze"].unlocked is True
    assert by_id["silver"].unlocked is False

    # 3. Gold boundary test: 10 sessions, 60 steps, 15 perfect quizzes, 2-day streak (needs 3-day) -> Gold locked
    ach_almost_gold = AnalyticsService._evaluate_achievements(
        total_steps=65,
        completed_sessions=10,
        perfect_quizzes=16,
        longest_streak=2,  # Short of 3
        total_xp=1200,
    )
    by_id = {a.id: a for a in ach_almost_gold}
    assert by_id["silver"].unlocked is True
    assert by_id["gold"].unlocked is False

    # 4. Gold unlocked: Meets 3-day streak + 1,000 XP
    ach_gold = AnalyticsService._evaluate_achievements(
        total_steps=60,
        completed_sessions=10,
        perfect_quizzes=15,
        longest_streak=3,
        total_xp=1000,
    )
    by_id = {a.id: a for a in ach_gold}
    assert by_id["bronze"].unlocked is True
    assert by_id["silver"].unlocked is True
    assert by_id["gold"].unlocked is True
    assert by_id["platinum"].unlocked is False

    # 5. Diamond unlocked: 100 sessions, 500 steps, 75 perfect quizzes, 30-day streak
    ach_diamond = AnalyticsService._evaluate_achievements(
        total_steps=500,
        completed_sessions=100,
        perfect_quizzes=75,
        longest_streak=30,
        total_xp=15000,
    )
    assert all(a.unlocked is True for a in ach_diamond)

