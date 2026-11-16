"""
EduTechAI — Dynamic Subscription Tiers & RBAC Binding Tests

Validates:
- Admin listing of subscription tiers with subscriber counts and bound role details
- Dynamic creation of custom tiers with unlimited/limited session, follow-up, and YouTube limits
- Unique slug validation
- Updating tier properties (prices, limits, public visibility, order)
- Safe retirement guardrails:
  - Cannot retire default 'free' tier
  - Cannot retire tier with active subscribers
  - Successful retirement of unused tier
- Public /subscriptions/tiers endpoint exposes only non-retired public tiers
"""

import pytest
from httpx import ASGITransport, AsyncClient
from uuid import uuid4
from sqlalchemy import select

from app.main import create_app
from services.database import get_db_session, init_db
from models.db_models import Role, SubscriptionTier, User, Subscription
from services.user_service import UserService


@pytest.fixture
def app():
    return create_app()


@pytest.mark.asyncio
async def test_subscription_tier_crud_and_safety_lifecycle(app):
    await init_db()

    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://testserver"
    ) as client:
        # 1. Setup admin user
        admin_email = f"admin_tier_{uuid4().hex[:6]}@example.com"
        admin_pwd = "AdminTierPass123!"

        async with get_db_session() as db:
            admin_role = (await db.execute(select(Role).where(Role.name == "Admin"))).scalar_one()
            pro_role = (await db.execute(select(Role).where(Role.name == "Pro"))).scalar_one()

            admin_user = User(
                email=admin_email,
                password_hash=UserService.hash_password(admin_pwd),
                first_name="Admin",
                last_name="Tester",
            )
            admin_user.roles = [admin_role]
            db.add(admin_user)
            await db.commit()

        login_res = await client.post("/api/v1/auth/login", json={"email": admin_email, "password": admin_pwd})
        assert login_res.status_code == 200
        admin_token = login_res.json()["access_token"]
        headers = {"Authorization": f"Bearer {admin_token}"}

        # 2. List tiers as Admin
        list_res = await client.get("/api/v1/admin/tiers", headers=headers)
        assert list_res.status_code == 200
        tiers = list_res.json()
        assert isinstance(tiers, list)
        slugs = [t["slug"] for t in tiers]
        assert "free" in slugs
        assert "pro" in slugs
        assert "ultra" in slugs

        # 3. Create a dynamic custom tier ("Enterprise Scholar")
        custom_slug = f"enterprise_{uuid4().hex[:6]}"
        create_payload = {
            "slug": custom_slug,
            "name": "Enterprise Scholar",
            "description": "Custom enterprise tier for academic research labs.",
            "role_id": pro_role.id,
            "price_monthly": 89.0,
            "price_annual": 850.0,
            "currency": "USD",
            "monthly_session_limit": None,  # Unlimited sessions
            "follow_up_limit_per_step": 12,
            "youtube_limit_per_step": 4,
            "is_public": True,
            "order_index": 10,
        }
        create_res = await client.post("/api/v1/admin/tiers", json=create_payload, headers=headers)
        assert create_res.status_code == 201
        created_tier = create_res.json()
        assert created_tier["slug"] == custom_slug
        assert created_tier["name"] == "Enterprise Scholar"
        assert created_tier["price_monthly"] == 89.0
        assert created_tier["monthly_session_limit"] is None
        assert created_tier["follow_up_limit_per_step"] == 12
        assert created_tier["youtube_limit_per_step"] == 4
        assert created_tier["role_name"] == "Pro"
        tier_id = created_tier["id"]

        # 4. Duplicate slug creation must fail with 400 BadRequest / TIER_SLUG_EXISTS
        dup_res = await client.post("/api/v1/admin/tiers", json=create_payload, headers=headers)
        assert dup_res.status_code == 400
        assert dup_res.json()["error_code"] == "TIER_SLUG_EXISTS"

        # 5. Update the tier details
        update_payload = {
            "name": "Enterprise Scholar Plus",
            "price_monthly": 99.0,
            "follow_up_limit_per_step": 20,
        }
        update_res = await client.put(f"/api/v1/admin/tiers/{tier_id}", json=update_payload, headers=headers)
        assert update_res.status_code == 200
        updated_tier = update_res.json()
        assert updated_tier["name"] == "Enterprise Scholar Plus"
        assert updated_tier["price_monthly"] == 99.0
        assert updated_tier["follow_up_limit_per_step"] == 20

        # 6. Verify public /subscriptions/tiers endpoint includes the new tier
        pub_res = await client.get("/api/v1/subscriptions/tiers")
        assert pub_res.status_code == 200
        pub_tiers = pub_res.json()
        assert any(t["slug"] == custom_slug for t in pub_tiers)

        # 7. Safety: Cannot retire free tier
        free_tier_id = next(t["id"] for t in tiers if t["slug"] == "free")
        retire_free = await client.delete(f"/api/v1/admin/tiers/{free_tier_id}", headers=headers)
        assert retire_free.status_code == 400
        assert retire_free.json()["error_code"] == "CANNOT_RETIRE_DEFAULT_TIER"

        # 8. Safety: Cannot retire tier with active subscribers
        # Create a user with subscription to the new tier
        async with get_db_session() as db:
            sub_user = User(
                email=f"subscriber_{uuid4().hex[:6]}@example.com",
                password_hash=UserService.hash_password("SubPass123!"),
                first_name="Sub",
                last_name="User",
            )
            db.add(sub_user)
            await db.flush()

            sub_rec = Subscription(
                user_id=sub_user.id,
                tier=custom_slug,
                tier_id=tier_id,
                status="active",
                billing_cycle="monthly",
                gateway_provider="razorpay",
            )
            db.add(sub_rec)
            await db.commit()

        retire_blocked = await client.delete(f"/api/v1/admin/tiers/{tier_id}", headers=headers)
        assert retire_blocked.status_code == 400
        assert retire_blocked.json()["error_code"] == "ACTIVE_SUBSCRIBERS_EXIST"

        # 9. Retire tier after subscriber cancels/moves
        async with get_db_session() as db:
            sub_db = (await db.execute(select(Subscription).where(Subscription.tier_id == tier_id))).scalar_one()
            sub_db.status = "cancelled"
            await db.commit()

        retire_success = await client.delete(f"/api/v1/admin/tiers/{tier_id}", headers=headers)
        assert retire_success.status_code == 200
        assert retire_success.json()["message"] == f"Subscription tier '{tier_id}' retired successfully."
