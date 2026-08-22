"""
EduTechAI — Unit & Integration Tests for User Subscriptions, Role Assignments, and Privileges
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
async def test_user_subscription_and_role_lifecycle(app):
    await init_db()
    test_email = f"sub_user_{uuid4().hex[:8]}@example.com"
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://testserver"
    ) as client:
        # 1. Create User (verifying dynamic assignment of 'Free' role & subscription)
        create_payload = {
            "first_name": "Sub",
            "last_name": "Tester",
            "email": test_email,
            "password": "Password123!",
        }
        res = await client.post("/api/v1/users/create", json=create_payload)
        assert res.status_code == 201, res.text
        user_data = res.json()
        user_id = user_data["id"]

        # Assign SuperAdmin role to test user so client has all privileges for test steps
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
        login_res = await client.post("/api/v1/auth/login", json={"email": test_email, "password": "Password123!"})
        assert login_res.status_code == 200

        # Verify initial roles and subscription in user creation response
        assert len(user_data["roles"]) >= 1
        assert any(r["name"] == "Free" for r in user_data["roles"])
        assert user_data["subscription"] is not None
        assert user_data["subscription"]["tier"] == "free"
        assert user_data["subscription"]["status"] == "active"

        # 2. Get User Roles & Privileges
        res = await client.get(f"/api/v1/users/{user_id}/roles")
        assert res.status_code == 200
        priv_data = res.json()
        assert priv_data["user_id"] == user_id
        assert any(r["name"] == "Free" for r in priv_data["roles"])
        assert "ET_START_LEARNING_SESSION" in priv_data["privilege_codes"]

        # 3. Upgrade Subscription Tier to 'Pro'
        upgrade_payload = {
            "tier": "pro",
            "status": "active",
            "payment_gateway_ref": "sub_stripe_12345",
        }
        res = await client.put(f"/api/v1/subscriptions/users/{user_id}/tier", json=upgrade_payload)
        assert res.status_code == 200
        sub_res = res.json()
        assert sub_res["tier"] == "pro"
        assert sub_res["status"] == "active"

        # 4. Verify User Role was automatically synchronized to 'Pro'
        res = await client.get(f"/api/v1/users/{user_id}")
        assert res.status_code == 200
        updated_user = res.json()
        role_names = [r["name"] for r in updated_user["roles"]]
        assert "Pro" in role_names
        assert "Free" not in role_names

        # Verify new privileges (e.g. ET_UPGRADE_SUBSCRIPTION)
        res = await client.get(f"/api/v1/users/{user_id}/roles")
        assert res.status_code == 200
        priv_data = res.json()
        assert "ET_UPGRADE_SUBSCRIPTION" in priv_data["privilege_codes"]

        # 5. Upgrade Subscription Tier to 'Ultra'
        ultra_payload = {
            "tier": "ultra",
            "status": "active",
        }
        res = await client.put(f"/api/v1/subscriptions/users/{user_id}/tier", json=ultra_payload)
        assert res.status_code == 200
        sub_res = res.json()
        assert sub_res["tier"] == "ultra"

        # Verify role updated to 'Ultra' and privileges updated (ET_DOWNGRADE_SUBSCRIPTION)
        res = await client.get(f"/api/v1/users/{user_id}/roles")
        assert res.status_code == 200
        priv_data = res.json()
        assert any(r["name"] == "Ultra" for r in priv_data["roles"])
        assert "ET_DOWNGRADE_SUBSCRIPTION" in priv_data["privilege_codes"]

        # 6. Downgrade Subscription Tier back to 'Free'
        downgrade_payload = {
            "tier": "free",
            "status": "active",
        }
        res = await client.put(f"/api/v1/subscriptions/users/{user_id}/tier", json=downgrade_payload)
        assert res.status_code == 200
        sub_res = res.json()
        assert sub_res["tier"] == "free"

        # Verify role reverted back to 'Free'
        res = await client.get(f"/api/v1/users/{user_id}")
        assert res.status_code == 200
        reverted_user = res.json()
        reverted_roles = [r["name"] for r in reverted_user["roles"]]
        assert "Free" in reverted_roles
        assert "Ultra" not in reverted_roles
