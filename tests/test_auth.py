"""
EduTechAI — Tests for JWT Authentication & Authorization APIs and Dependencies
"""

from uuid import uuid4
import pytest
from httpx import ASGITransport, AsyncClient
from fastapi import APIRouter, Depends

from app.dependencies import get_current_user, require_privilege, require_role
from app.main import create_app
from models.db_models import User
from services.database import init_db


@pytest.fixture
def app():
    app_instance = create_app()

    # Add temporary test endpoints for testing privilege and role guards
    test_router = APIRouter(prefix="/api/v1/test-guard")

    @test_router.get("/user-read", dependencies=[Depends(require_privilege("ET_START_LEARNING_SESSION"))])
    async def guarded_user_read():
        return {"access": "granted"}

    @test_router.get("/super-admin", dependencies=[Depends(require_role("SuperAdmin"))])
    async def guarded_super_admin():
        return {"access": "granted"}

    app_instance.include_router(test_router)
    return app_instance


@pytest.mark.asyncio
async def test_auth_full_lifecycle(app):
    await init_db()
    test_email = f"auth_{uuid4().hex[:8]}@example.com"
    test_password = "SecurePassword123!"

    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://testserver"
    ) as client:
        # 1. Create a User profile
        create_payload = {
            "first_name": "Auth",
            "last_name": "Tester",
            "email": test_email,
            "password": test_password,
            "mobile": "+19998887777",
            "country": "Germany",
        }
        create_res = await client.post("/api/v1/users/create", json=create_payload)
        assert create_res.status_code == 201, create_res.text
        user_id = create_res.json()["id"]

        # 2. Login with wrong password (should fail 401)
        bad_login_res = await client.post(
            "/api/v1/auth/login",
            json={"email": test_email, "password": "WrongPassword123!"},
        )
        assert bad_login_res.status_code == 401
        assert bad_login_res.json()["error_code"] == "INVALID_CREDENTIALS"

        # 3. Login with correct credentials (should set cookie and return 200)
        login_res = await client.post(
            "/api/v1/auth/login",
            json={"email": test_email, "password": test_password},
        )
        assert login_res.status_code == 200
        assert login_res.json()["message"] == "Logged in successfully"

        # Verify access_token cookie is present
        assert "access_token" in login_res.cookies
        token = login_res.cookies["access_token"]
        assert token is not None and len(token) > 20

        # 4. Access /api/v1/auth/me using the set cookie
        me_res = await client.get("/api/v1/auth/me")
        assert me_res.status_code == 200, me_res.text
        profile = me_res.json()
        assert profile["id"] == user_id
        assert profile["email"] == test_email
        assert profile["first_name"] == "Auth"
        assert isinstance(profile["roles"], list)
        assert "Normal" in profile["roles"]
        assert all(isinstance(r, str) for r in profile["roles"])
        assert isinstance(profile["privilege_codes"], list)
        assert profile["subscription"]["tier"] == "normal"

        # 5. Access /api/v1/test-guard/user-read (Normal user role has USER_READ privilege)
        guard_res = await client.get("/api/v1/test-guard/user-read")
        assert guard_res.status_code == 200
        assert guard_res.json()["access"] == "granted"

        # 6. Access /api/v1/test-guard/super-admin (Normal user lacks SuperAdmin role -> should 403)
        role_guard_res = await client.get("/api/v1/test-guard/super-admin")
        assert role_guard_res.status_code == 403
        assert role_guard_res.json()["error_code"] == "ROLE_REQUIRED"

        # 7. Test Bearer Token header fallback with a fresh unauthenticated client
        async with AsyncClient(
            transport=ASGITransport(app=app), base_url="http://testserver"
        ) as unauth_client:
            unauth_me = await unauth_client.get("/api/v1/auth/me")
            assert unauth_me.status_code == 401
            assert unauth_me.json()["error_code"] == "UNAUTHORIZED"

            header_me = await unauth_client.get(
                "/api/v1/auth/me",
                headers={"Authorization": f"Bearer {token}"},
            )
            assert header_me.status_code == 200
            assert header_me.json()["id"] == user_id

        # 8. Logout (clears cookie in current client)
        logout_res = await client.post("/api/v1/auth/logout")
        assert logout_res.status_code == 200
        assert logout_res.json()["message"] == "Logged out successfully"

        # Verify endpoint access after logout is unauthorized
        me_after_logout = await client.get("/api/v1/auth/me")
        assert me_after_logout.status_code == 401
