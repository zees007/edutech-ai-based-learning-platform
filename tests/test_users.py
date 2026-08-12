"""
EduTechAI — Tests for User Management APIs & Exception Handling
"""

from uuid import uuid4

import pytest
from httpx import ASGITransport, AsyncClient

from app.main import create_app


from services.database import init_db


@pytest.fixture
def app():
    return create_app()


@pytest.mark.asyncio
async def test_user_lifecycle(app):
    await init_db()
    test_email = f"test_{uuid4().hex[:8]}@example.com"
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://testserver"
    ) as client:
        # 1. Create User
        create_payload = {
            "first_name": "Test",
            "last_name": "User",
            "email": test_email,
            "password": "SecurePassword123!",
            "mobile": "+1234567890",
            "country": "USA",
        }
        res = await client.post("/api/v1/users/create", json=create_payload)
        assert res.status_code == 201, res.text
        data = res.json()
        assert data["first_name"] == "Test"
        assert data["email"] == test_email
        assert "password" not in data
        assert "password_hash" not in data
        assert data["retired"] is False
        user_id = data["id"]

        # Assign SuperAdmin role to test user so client has all privileges
        from models.db_models import Role, User
        from services.database import get_db_session
        from sqlalchemy import select
        async with get_db_session() as db:
            user_obj = (await db.execute(select(User).where(User.id == user_id))).scalar_one()
            admin_role = (await db.execute(select(Role).where(Role.name == "SuperAdmin"))).scalar_one_or_none()
            if admin_role:
                user_obj.roles.append(admin_role)
                await db.commit()

        # Login to receive access_token cookie
        login_res = await client.post("/api/v1/auth/login", json={"email": test_email, "password": "SecurePassword123!"})
        assert login_res.status_code == 200

        # 2. Get User By ID
        res = await client.get(f"/api/v1/users/{user_id}")
        assert res.status_code == 200
        assert res.json()["id"] == user_id
        assert "password" not in res.json()
        assert "password_hash" not in res.json()

        # 3. Edit User Profile (without password)
        edit_payload = {
            "first_name": "UpdatedName",
            "country": "Canada",
        }
        res = await client.put(f"/api/v1/users/{user_id}/edit", json=edit_payload)
        assert res.status_code == 200
        assert res.json()["first_name"] == "UpdatedName"
        assert res.json()["country"] == "Canada"

        # 4. Change Password (mismatched confirm_password check)
        mismatch_pwd_payload = {
            "old_password": "SecurePassword123!",
            "new_password": "NewSecurePassword456!",
            "confirm_password": "DifferentPassword789!",
        }
        res = await client.patch(f"/api/v1/users/{user_id}/change-password", json=mismatch_pwd_payload)
        assert res.status_code == 422
        val_err_json = res.json()
        assert val_err_json["http_status"] == 422
        assert val_err_json["error_code"] == "VALIDATION_ERROR"
        assert "new_password and confirm_password do not match." in val_err_json["errors"]

        # 5. Change Password (invalid old_password check)
        invalid_pwd_payload = {
            "old_password": "WrongOldPassword!",
            "new_password": "NewSecurePassword456!",
            "confirm_password": "NewSecurePassword456!",
        }
        res = await client.patch(f"/api/v1/users/{user_id}/change-password", json=invalid_pwd_payload)
        assert res.status_code == 400
        assert res.json()["error_code"] == "INVALID_OLD_PASSWORD"

        # 6. Change Password (successful — returns message)
        valid_pwd_payload = {
            "old_password": "SecurePassword123!",
            "new_password": "NewSecurePassword456!",
            "confirm_password": "NewSecurePassword456!",
        }
        res = await client.patch(f"/api/v1/users/{user_id}/change-password", json=valid_pwd_payload)
        assert res.status_code == 200
        assert res.json()["message"] == "Password has been changed successfully"

        # 7. Search Active Users (Filtered using camelCase params, 0-indexed page)
        search_params = {
            "page": 0,
            "size": 10,
            "sortBy": "firstName",
            "isDesc": False,
            "lookupText": "UpdatedName",
        }
        res = await client.get("/api/v1/users/search", params=search_params)
        assert res.status_code == 200
        search_data = res.json()
        assert search_data["page"] == 0
        assert search_data["total"] >= 1
        assert any(item["id"] == user_id for item in search_data["items"])

        # 8. Soft Retire User (using DELETE method)
        res = await client.delete(f"/api/v1/users/{user_id}/retire")
        assert res.status_code == 200
        assert res.json()["message"] == "User retired successfully"

        # Create active admin user & login to run search as active user after test user retirement
        admin_email = f"active_admin_{uuid4().hex[:8]}@example.com"
        admin_payload = {
            "first_name": "Active",
            "last_name": "Admin",
            "email": admin_email,
            "password": "SecurePassword123!",
        }
        create_adm_res = await client.post("/api/v1/users/create", json=admin_payload)
        assert create_adm_res.status_code == 201
        adm_id = create_adm_res.json()["id"]

        async with get_db_session() as db:
            adm_obj = (await db.execute(select(User).where(User.id == adm_id))).scalar_one()
            admin_role = (await db.execute(select(Role).where(Role.name == "SuperAdmin"))).scalar_one_or_none()
            if admin_role:
                adm_obj.roles.append(admin_role)
                await db.commit()

        login_adm_res = await client.post("/api/v1/auth/login", json={"email": admin_email, "password": "SecurePassword123!"})
        assert login_adm_res.status_code == 200

        # 9. Verify retired user is EXCLUDED from active user search results
        res = await client.get("/api/v1/users/search", params={"lookupText": "UpdatedName"})
        assert res.status_code == 200
        search_data_after_retire = res.json()
        assert not any(item["id"] == user_id for item in search_data_after_retire["items"])

        # 10. Verify duplicate email conflict exception
        res = await client.post("/api/v1/users/create", json=create_payload)
        # Should raise 409 APIError
        assert res.status_code == 409
        err_json = res.json()
        assert err_json["error_code"] == "EMAIL_ALREADY_EXISTS"
        assert err_json["http_status"] == 409
        assert err_json["path_uri"] == "/api/v1/users/create"
