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
            admin_role = (await db.execute(select(Role).where(Role.name.in_(["SuperAdmin", "Admin"])))).scalars().first()
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
            admin_role = (await db.execute(select(Role).where(Role.name.in_(["SuperAdmin", "Admin"])))).scalars().first()
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


@pytest.mark.asyncio
async def test_change_password_security(app):
    """
    Test security and permissions for Change Password:
    1. Regular user self-service permission (no admin role needed)
    2. IDOR prevention (cannot change another user's password)
    3. Same password prevention
    4. Token and session invalidation for old access tokens
    5. Old refresh token revocation
    6. Seamless credential renewal for active session
    7. Authentication with new password
    """
    import asyncio
    await init_db()
    email_1 = f"reguser1_{uuid4().hex[:8]}@example.com"
    email_2 = f"reguser2_{uuid4().hex[:8]}@example.com"
    pwd_initial = "InitialPass123!"
    pwd_new = "UpdatedPass456!"

    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://testserver"
    ) as client1, AsyncClient(
        transport=ASGITransport(app=app), base_url="http://testserver"
    ) as client2:
        # 1. Create two regular users (no Admin role assigned)
        u1_res = await client1.post("/api/v1/users/create", json={
            "first_name": "Regular",
            "last_name": "One",
            "email": email_1,
            "password": pwd_initial,
        })
        assert u1_res.status_code == 201
        u1_id = u1_res.json()["id"]

        u2_res = await client2.post("/api/v1/users/create", json={
            "first_name": "Regular",
            "last_name": "Two",
            "email": email_2,
            "password": pwd_initial,
        })
        assert u2_res.status_code == 201
        u2_id = u2_res.json()["id"]

        # 2. Login user 1
        login1_res = await client1.post("/api/v1/auth/login", json={"email": email_1, "password": pwd_initial})
        assert login1_res.status_code == 200
        old_access_token_1 = login1_res.json()["access_token"]
        old_refresh_token_1 = login1_res.json()["refresh_token"]

        # 3. User 1 attempts to change User 2's password -> must fail with 403 Forbidden
        idor_res = await client1.patch(f"/api/v1/users/{u2_id}/change-password", json={
            "old_password": pwd_initial,
            "new_password": pwd_new,
            "confirm_password": pwd_new,
        })
        assert idor_res.status_code == 403
        assert idor_res.json()["error_code"] == "PERMISSION_DENIED"

        # 4. User 1 attempts to change to SAME password -> must fail with 400 SAME_PASSWORD
        same_pwd_res = await client1.patch(f"/api/v1/users/{u1_id}/change-password", json={
            "old_password": pwd_initial,
            "new_password": pwd_initial,
            "confirm_password": pwd_initial,
        })
        assert same_pwd_res.status_code == 400
        assert same_pwd_res.json()["error_code"] == "SAME_PASSWORD"

        # Sleep briefly so token iat differs from old token iat
        await asyncio.sleep(1)

        # 5. Regular User 1 successfully changes own password (self-service!)
        change_res = await client1.patch(f"/api/v1/users/{u1_id}/change-password", json={
            "old_password": pwd_initial,
            "new_password": pwd_new,
            "confirm_password": pwd_new,
        })
        assert change_res.status_code == 200
        assert change_res.json()["message"] == "Password has been changed successfully"
        new_access_token_1 = change_res.json()["access_token"]
        assert new_access_token_1 != old_access_token_1

        # 6. Verify that User 1's OLD access token is now rejected as TOKEN_REVOKED
        revoked_check = await client2.get(
            "/api/v1/auth/me",
            headers={"Authorization": f"Bearer {old_access_token_1}"},
        )
        assert revoked_check.status_code == 401
        assert revoked_check.json()["error_code"] == "TOKEN_REVOKED"

        # 7. Verify that User 1's OLD refresh token is revoked
        refresh_check = await client2.post(
            "/api/v1/auth/refresh",
            json={"refresh_token": old_refresh_token_1},
        )
        assert refresh_check.status_code == 401

        # 8. Verify that User 1's new session continues to work seamlessly
        me_res = await client1.get("/api/v1/auth/me")
        assert me_res.status_code == 200
        assert me_res.json()["email"] == email_1

        # 9. Verify login with the new password works
        new_login = await client2.post("/api/v1/auth/login", json={"email": email_1, "password": pwd_new})
        assert new_login.status_code == 200

        # 10. Verify login with old password fails
        old_login = await client2.post("/api/v1/auth/login", json={"email": email_1, "password": pwd_initial})
        assert old_login.status_code == 401

        # 11. Verify ET_CHANGE_PASSWORD privilege enforcement:
        # Strip roles from User 2 and verify change-password is forbidden (403)
        from models.db_models import User
        from services.database import get_db_session
        from sqlalchemy import select
        async with get_db_session() as db:
            u2_db = (await db.execute(select(User).where(User.id == u2_id))).scalar_one()
            u2_db.roles = []
            await db.commit()

        login2_res = await client2.post("/api/v1/auth/login", json={"email": email_2, "password": pwd_initial})
        assert login2_res.status_code == 200

        no_priv_res = await client2.patch(f"/api/v1/users/{u2_id}/change-password", json={
            "old_password": pwd_initial,
            "new_password": pwd_new,
            "confirm_password": pwd_new,
        })
        assert no_priv_res.status_code == 403
        assert no_priv_res.json()["error_code"] == "PERMISSION_DENIED"
        assert "ET_CHANGE_PASSWORD" in str(no_priv_res.json()["errors"])

