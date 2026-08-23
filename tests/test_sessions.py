"""
EduTechAI — Tests for User-Linked Session Management, Paginated History, and Resume
"""

import asyncio
from datetime import datetime
from uuid import uuid4
import pytest
from httpx import ASGITransport, AsyncClient

from app.main import create_app
from models.db_models import GamificationRecord, SessionRecord, StepProgress, User
from models.schemas import LearningMode, MilestoneStep, StepResult, StepStatus
from models.shared_memory import SharedMemory
from models.user_schemas import SearchDTO, UserCreateRequest
from services.database import get_db_session, init_db
from services.session_manager import SessionManager
from services.user_service import UserService


@pytest.fixture
def app():
    return create_app()


@pytest.mark.asyncio
async def test_session_lifecycle_and_user_linkage():
    """Verify session creation, user linkage, step progress updates, and deserialization."""
    await init_db()
    sm = SessionManager()

    # 1. Create a User
    async with get_db_session() as db:
        user_req = UserCreateRequest(
            first_name="Alice",
            last_name="Learner",
            email=f"alice_{uuid4().hex[:8]}@example.com",
            password="SecurePassword123!",
        )
        user = await UserService.create_user(db, user_req)
        user_id = user.id

    # 2. Create a SharedMemory session for this user
    memory = SharedMemory(
        user_id=user_id,
        topic="Photosynthesis Process",
        learning_mode=LearningMode.VISUAL,
        student_level="high_school",
    )
    memory.steps = [
        MilestoneStep(index=0, title="Light Reactions", description="Absorb photons", status=StepStatus.COMPLETE),
        MilestoneStep(index=1, title="Calvin Cycle", description="Carbon fixation", status=StepStatus.COMPLETE),
        MilestoneStep(index=2, title="ATP Synthesis", description="ATP Synthase", status=StepStatus.IN_PROGRESS),
        MilestoneStep(index=3, title="Glucose Formation", description="Hexose synthesis", status=StepStatus.PENDING),
    ]
    memory.current_step_index = 2
    memory.xp_earned = 150

    record = await sm.create_session(memory, user_id=user_id)
    assert record.session_id == memory.session_id
    assert record.user_id == user_id
    assert record.total_steps == 4
    assert record.is_complete is False

    # 3. Retrieve and deserialize SharedMemory
    restored = await sm.get_session(memory.session_id)
    assert restored is not None
    assert restored.session_id == memory.session_id
    assert restored.user_id == user_id
    assert restored.topic == "Photosynthesis Process"
    assert restored.current_step_index == 2
    assert len(restored.steps) == 4
    assert restored.steps[0].status == StepStatus.COMPLETE
    assert restored.steps[2].status == StepStatus.IN_PROGRESS
    assert restored.xp_earned == 150


@pytest.mark.asyncio
async def test_session_history_sorting_and_pagination():
    """
    Verify that search_user_sessions():
    - Sorts incomplete sessions (is_complete=False) to the top, followed by completed sessions.
    - Uses 0-indexed pagination (page=0, size=2, etc.).
    - Filters by lookupText across topic, mode, and student level.
    """
    await init_db()
    sm = SessionManager()

    # Create test user
    async with get_db_session() as db:
        user_req = UserCreateRequest(
            first_name="Bob",
            last_name="Student",
            email=f"bob_{uuid4().hex[:8]}@example.com",
            password="SecurePassword123!",
        )
        user = await UserService.create_user(db, user_req)
        user_id = user.id

    # Create 3 sessions:
    # 1. Completed session (created first)
    s1 = SharedMemory(
        user_id=user_id,
        topic="Classical Mechanics",
        learning_mode=LearningMode.DEEP_DIVE,
        student_level="undergraduate",
    )
    s1.steps = [MilestoneStep(index=0, title="Newton Laws", description="Laws of motion", status=StepStatus.COMPLETE)]
    s1.current_step_index = 1
    s1.steps_completed = 1
    # is_complete property will be True because current_step_index >= total_steps
    await sm.create_session(s1, user_id=user_id)

    # 2. Incomplete session A (Quantum Entanglement)
    await asyncio.sleep(0.05)
    s2 = SharedMemory(
        user_id=user_id,
        topic="Quantum Entanglement",
        learning_mode=LearningMode.VISUAL,
        student_level="undergraduate",
    )
    s2.steps = [
        MilestoneStep(index=0, title="EPR Paradox", description="Paradox explanation", status=StepStatus.COMPLETE),
        MilestoneStep(index=1, title="Bell Inequalities", description="Bell tests", status=StepStatus.IN_PROGRESS),
    ]
    s2.current_step_index = 1
    await sm.create_session(s2, user_id=user_id)

    # 3. Incomplete session B (Machine Learning Transformers) - latest
    await asyncio.sleep(0.05)
    s3 = SharedMemory(
        user_id=user_id,
        topic="Machine Learning Transformers",
        learning_mode=LearningMode.BITE_SIZED,
        student_level="graduate",
    )
    s3.steps = [
        MilestoneStep(index=0, title="Attention Mechanism", description="Attention layer", status=StepStatus.IN_PROGRESS),
        MilestoneStep(index=1, title="Self-Attention Layers", description="Self-attention", status=StepStatus.PENDING),
    ]
    s3.current_step_index = 0
    await sm.create_session(s3, user_id=user_id)

    # ── Test 1: Full list sorting (incomplete on top, newest first) ──
    dto_all = SearchDTO(page=0, size=10, sortBy="updated_at", isDesc=True)
    items, total = await sm.search_user_sessions(user_id=user_id, dto=dto_all, status_filter="all")

    assert total == 3
    assert len(items) == 3
    # Top 2 must be incomplete (is_complete == False)
    assert items[0]["is_complete"] is False
    assert items[1]["is_complete"] is False
    # Bottom 1 must be completed (is_complete == True)
    assert items[2]["is_complete"] is True
    # The newest incomplete session should be first
    assert items[0]["topic"] == "Machine Learning Transformers"
    assert items[1]["topic"] == "Quantum Entanglement"
    assert items[2]["topic"] == "Classical Mechanics"

    # ── Test 2: 0-indexed pagination (page=0 vs page=1 with size=2) ──
    dto_p0 = SearchDTO(page=0, size=2)
    items_p0, total_p0 = await sm.search_user_sessions(user_id=user_id, dto=dto_p0)
    assert total_p0 == 3
    assert len(items_p0) == 2
    assert items_p0[0]["topic"] == "Machine Learning Transformers"
    assert items_p0[1]["topic"] == "Quantum Entanglement"

    dto_p1 = SearchDTO(page=1, size=2)
    items_p1, total_p1 = await sm.search_user_sessions(user_id=user_id, dto=dto_p1)
    assert total_p1 == 3
    assert len(items_p1) == 1
    assert items_p1[0]["topic"] == "Classical Mechanics"

    # ── Test 3: Status filtering ──
    items_act, total_act = await sm.search_user_sessions(user_id=user_id, dto=dto_all, status_filter="in_progress")
    assert total_act == 2
    assert all(i["is_complete"] is False for i in items_act)

    items_done, total_done = await sm.search_user_sessions(user_id=user_id, dto=dto_all, status_filter="completed")
    assert total_done == 1
    assert items_done[0]["topic"] == "Classical Mechanics"

    # ── Test 4: Multi-field search lookup ──
    # Search by topic substring
    dto_search_topic = SearchDTO(page=0, size=10, lookupText="Quantum")
    items_sq, total_sq = await sm.search_user_sessions(user_id=user_id, dto=dto_search_topic)
    assert total_sq == 1
    assert items_sq[0]["topic"] == "Quantum Entanglement"

    # Search by learning mode
    dto_search_mode = SearchDTO(page=0, size=10, lookupText="deep_dive")
    items_sm, total_sm = await sm.search_user_sessions(user_id=user_id, dto=dto_search_mode)
    assert total_sm == 1
    assert items_sm[0]["topic"] == "Classical Mechanics"


@pytest.mark.asyncio
async def test_session_user_isolation_and_deletion():
    """Verify that users can only view and delete their own sessions."""
    await init_db()
    sm = SessionManager()

    # User 1 & User 2
    async with get_db_session() as db:
        u1 = await UserService.create_user(
            db, UserCreateRequest(first_name="U1", last_name="Test", email=f"u1_{uuid4().hex[:8]}@example.com", password="Pass12345!")
        )
        u2 = await UserService.create_user(
            db, UserCreateRequest(first_name="U2", last_name="Test", email=f"u2_{uuid4().hex[:8]}@example.com", password="Pass12345!")
        )
        u1_id = u1.id
        u2_id = u2.id

    # Create session for User 1
    s_u1 = SharedMemory(user_id=u1_id, topic="User 1 Topic")
    s_u1.steps = [MilestoneStep(index=0, title="Intro", description="Intro step")]
    await sm.create_session(s_u1, user_id=u1_id)

    # Create session for User 2
    s_u2 = SharedMemory(user_id=u2_id, topic="User 2 Topic")
    s_u2.steps = [MilestoneStep(index=0, title="Intro", description="Intro step")]
    await sm.create_session(s_u2, user_id=u2_id)

    # User 1 should only see their session
    dto = SearchDTO(page=0, size=10)
    u1_items, u1_tot = await sm.search_user_sessions(user_id=u1_id, dto=dto)
    assert u1_tot == 1
    assert u1_items[0]["session_id"] == s_u1.session_id

    # User 2 attempting to delete User 1's session should fail
    del_forbidden = await sm.delete_session(session_id=s_u1.session_id, user_id=u2_id)
    assert del_forbidden is False
    # Session must still exist
    assert await sm.get_session(s_u1.session_id) is not None

    # User 1 deleting their own session succeeds
    del_ok = await sm.delete_session(session_id=s_u1.session_id, user_id=u1_id)
    assert del_ok is True
    assert await sm.get_session(s_u1.session_id) is None


@pytest.mark.asyncio
async def test_rest_api_sessions_endpoint(app):
    """Verify REST API endpoint GET /api/sessions and DELETE /api/sessions/{session_id}."""
    await init_db()
    email = f"api_user_{uuid4().hex[:8]}@example.com"
    password = "ApiPassword123!"

    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://testserver"
    ) as client:
        # 1. Register user
        reg_res = await client.post(
            "/api/v1/users/create",
            json={"first_name": "API", "last_name": "Tester", "email": email, "password": password},
        )
        assert reg_res.status_code == 201

        # 2. Login to get cookie
        login_res = await client.post(
            "/api/v1/auth/login",
            json={"email": email, "password": password},
        )
        assert login_res.status_code == 200

        # 3. Create a session via /api/learn
        learn_res = await client.post(
            "/api/learn",
            json={"topic": "Black Holes & Event Horizons", "learning_mode": "visual", "student_level": "general"},
        )
        assert learn_res.status_code == 200
        session_id = learn_res.json()["session_id"]

        # 4. Search sessions via GET /api/sessions
        hist_res = await client.get("/api/sessions?page=0&size=10")
        assert hist_res.status_code == 200
        data = hist_res.json()
        assert data["total"] >= 1
        assert any(s["session_id"] == session_id for s in data["items"])

        # 5. Delete session via DELETE /api/sessions/{session_id}
        del_res = await client.delete(f"/api/sessions/{session_id}")
        assert del_res.status_code == 200

        # 6. Verify session is gone
        after_del_res = await client.get(f"/api/sessions/{session_id}")
        assert after_del_res.status_code == 404
