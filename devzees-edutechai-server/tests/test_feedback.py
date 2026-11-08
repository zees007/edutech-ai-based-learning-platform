"""
EduTechAI — Feedback & Testimonials Tests

Validates:
- Learner submission with +30 XP bonus
- 250 character limit on quotes
- Duplicate submission prevention
- Strict admin-only access to submitted feedback
- Admin toggling of 'featured' status and admin notes
- Public homepage endpoint displaying strictly featured feedback
"""

import importlib.util
from pathlib import Path
import uuid
import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy import select

from app.main import create_app
from models.db_models import Role, User
from models.user_schemas import UserCreateRequest
from services.auth_service import AuthService
from services.database import get_db_session, init_db
from services.session_manager import SessionManager
from services.user_service import UserService
from models.shared_memory import SharedMemory
from models.schemas import LearningMode


@pytest.fixture
def app():
    return create_app()


async def _run_privilege_seed():
    """Seed system privileges and role privileges into database."""
    seed_path = Path(__file__).parent.parent / "scripts" / "seeder" / "02_seed_privileges_and_roles.py"
    spec = importlib.util.spec_from_file_location("seed_privs", str(seed_path))
    seed_module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(seed_module)
    await seed_module.seed_privileges_and_roles()


async def _create_test_user_with_role(db, role_name: str, email_prefix: str) -> tuple[User, str]:
    """Helper to create a user with a specific role and generate an auth token."""
    user_req = UserCreateRequest(
        first_name="Test",
        last_name=role_name,
        email=f"{email_prefix}_{uuid.uuid4().hex[:6]}@example.com",
        password="Password123!",
        country="United States",
    )
    user = await UserService.create_user(db, user_req)

    if role_name != "Free":
        role_res = await db.execute(select(Role).where(Role.name == role_name, Role.retired.is_(False)))
        role = role_res.scalar_one_or_none()
        if role:
            user = await UserService.assign_roles_to_user(db, user.id, [role.id])

    token = AuthService.create_access_token({"sub": user.id, "email": user.email})
    return user, token


@pytest.mark.asyncio
async def test_feedback_end_to_end_flow(app):
    """End-to-end test of the feedback lifecycle."""
    await init_db()
    await _run_privilege_seed()
    sm = SessionManager()

    async with get_db_session() as db:
        # Create learner user (Free role has ET_SUBMIT_FEEDBACK)
        learner, learner_token = await _create_test_user_with_role(db, "Free", "learner")
        # Create admin user (Admin role has ET_ALL)
        admin, admin_token = await _create_test_user_with_role(db, "Admin", "admin")

    # Create a completed session for the learner (SessionManager auto-creates GamificationRecord)
    memory = SharedMemory(
        user_id=learner.id,
        topic="Quantum Computing",
        learning_mode=LearningMode.VISUAL,
        student_level="undergraduate",
    )
    memory.xp_earned = 100
    session_rec = await sm.create_session(memory, user_id=learner.id)
    session_id = session_rec.session_id

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # 1. Unauthenticated submission should fail (401)
        unauth_resp = await client.post(
            "/api/v1/feedback",
            json={
                "session_id": session_id,
                "rating": 5,
                "quote": "Amazing Socratic tutor experience!",
                "is_public_consent": True,
            },
        )
        assert unauth_resp.status_code == 401

        # 2. Quote exceeding 250 characters should fail validation (422)
        long_quote = "A" * 251
        long_resp = await client.post(
            "/api/v1/feedback",
            headers={"Authorization": f"Bearer {learner_token}"},
            json={
                "session_id": session_id,
                "rating": 5,
                "quote": long_quote,
                "is_public_consent": True,
            },
        )
        assert long_resp.status_code == 422

        # 3. Successful submission by learner (+30 XP)
        valid_quote = "The visual diagrams and Socratic hints made quantum gates click instantly."
        submit_resp = await client.post(
            "/api/v1/feedback",
            headers={"Authorization": f"Bearer {learner_token}"},
            json={
                "session_id": session_id,
                "rating": 5,
                "quote": valid_quote,
                "is_public_consent": True,
            },
        )
        assert submit_resp.status_code == 200
        data = submit_resp.json()
        assert data["xp_awarded"] == 30
        assert data["total_xp"] == 130
        feedback_id = data["feedback_id"]

        # 4. Duplicate submission for same session must be rejected (400)
        dup_resp = await client.post(
            "/api/v1/feedback",
            headers={"Authorization": f"Bearer {learner_token}"},
            json={
                "session_id": session_id,
                "rating": 4,
                "quote": "Trying to submit twice to get more XP",
                "is_public_consent": True,
            },
        )
        assert dup_resp.status_code == 400
        assert dup_resp.json()["error_code"] == "FEEDBACK_ALREADY_SUBMITTED"

        # 5. Public endpoint should NOT show it yet (status is 'pending')
        pub_resp = await client.get("/api/v1/feedback/public")
        assert pub_resp.status_code == 200
        public_items = pub_resp.json()
        assert not any(item["feedback_id"] == feedback_id for item in public_items)

        # 6. Learner cannot access admin feedback listing (403 Forbidden)
        learner_admin_resp = await client.get(
            "/api/v1/admin/feedback",
            headers={"Authorization": f"Bearer {learner_token}"},
        )
        assert learner_admin_resp.status_code == 403

        # 7. Admin lists feedback and sees pending item
        admin_list_resp = await client.get(
            "/api/v1/admin/feedback?status=pending",
            headers={"Authorization": f"Bearer {admin_token}"},
        )
        assert admin_list_resp.status_code == 200
        admin_data = admin_list_resp.json()
        assert admin_data["total"] >= 1
        assert any(item["feedback_id"] == feedback_id for item in admin_data["items"])

        # 8. Admin features the feedback and adds a private note
        status_resp = await client.patch(
            f"/api/v1/admin/feedback/{feedback_id}/status",
            headers={"Authorization": f"Bearer {admin_token}"},
            json={
                "status": "featured",
                "admin_notes": "Great testimonial for Visual mode!",
            },
        )
        assert status_resp.status_code == 200
        updated = status_resp.json()
        assert updated["status"] == "featured"
        assert updated["admin_notes"] == "Great testimonial for Visual mode!"

        # 9. Now the public homepage endpoint DOES return it!
        pub_featured_resp = await client.get("/api/v1/feedback/public")
        assert pub_featured_resp.status_code == 200
        featured_items = pub_featured_resp.json()
        matching = [item for item in featured_items if item["feedback_id"] == feedback_id]
        assert len(matching) == 1
        assert matching[0]["quote"] == valid_quote
        assert matching[0]["rating"] == 5
        assert matching[0]["education_level"] == "Undergraduate"
        assert matching[0]["country"] == "United States"

        # 10. Admin unfeatures (archives) the feedback
        unfeature_resp = await client.patch(
            f"/api/v1/admin/feedback/{feedback_id}/status",
            headers={"Authorization": f"Bearer {admin_token}"},
            json={
                "status": "archived",
                "admin_notes": "Archived after homepage rotation",
            },
        )
        assert unfeature_resp.status_code == 200
        assert unfeature_resp.json()["status"] == "archived"

        # 11. Public endpoint no longer returns it
        pub_after_archive = await client.get("/api/v1/feedback/public")
        assert not any(item["feedback_id"] == feedback_id for item in pub_after_archive.json())
