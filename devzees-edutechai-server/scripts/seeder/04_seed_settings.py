"""
EduTechAI — System Settings Seeder

Seeds initial global system configuration values into the `settings` table:
- Agent LLM Models
- Promo Banner & Promotional Coupons
- Global YouTube Daily Search Limit

Note: Subscription Tier pricing and per-user limits (sessions, follow-ups, YouTube)
are managed dynamically in the `subscription_tiers` table via `02_seed_privileges_and_roles.py`
and the Admin Panel "Subscription Tiers" CRUD tab.
"""

import asyncio
import os
import sys

sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from sqlalchemy import delete, select
from models.db_models import SystemSetting
from services.database import get_db_session

# Obsolete settings that are now managed dynamically in subscription_tiers table
OBSOLETE_TIER_SETTINGS = [
    "PRO_MONTHLY",
    "PRO_ANNUALLY",
    "ULTRA_MONTHLY",
    "ULTRA_ANNUALLY",
    "FREE_YOUTUBE_LIMIT",
    "PRO_YOUTUBE_LIMIT",
    "ULTRA_YOUTUBE_LIMIT",
    "FREE_FOLLOWUP_LIMIT",
    "PRO_FOLLOWUP_LIMIT",
    "FREE_MONTHLY_SESSION_LIMIT",
]

DEFAULT_SETTINGS = [
    {
        "code": "ORCHESTRATOR_MODEL",
        "value": "openai/gpt-oss-20b",
        "order_number": 10,
    },
    {
        "code": "SOCRATIC_TUTOR_MODEL",
        "value": "openai/gpt-oss-20b",
        "order_number": 20,
    },
    {
        "code": "QUIZ_AGENT_MODEL",
        "value": "openai/gpt-oss-20b",
        "order_number": 30,
    },
    {
        "code": "PROMO_BANNER_ENABLED",
        "value": "true",
        "order_number": 40,
    },
    {
        "code": "PROMO_BANNER_TEXT",
        "value": "⚡ Special Offer: Celebrate with 50% OFF on all Pro & Ultra plans! Use code DIWALI50 at checkout",
        "order_number": 50,
    },
    {
        "code": "PROMO_BANNER_COUPON",
        "value": "DIWALI50",
        "order_number": 60,
    },
    {
        "code": "PROMO_VALIDITY",
        "value": "2026-11-15 23:59:59",
        "order_number": 70,
    },
    {
        "code": "VALID_COUPONS",
        "value": "EDU20:20,WELCOME50:50,STUDENT10:10,EDUTECH100:100,DIWALI50:50",
        "order_number": 80,
    },
    {
        "code": "YOUTUBE_DAILY_SEARCH_LIMIT",
        "value": "100",
        "order_number": 90,
    },
]


async def seed_settings():
    print("Starting system settings seeding...")
    async with get_db_session() as db:
        # 1. Clean up obsolete tier settings migrated to subscription_tiers table
        del_stmt = delete(SystemSetting).where(SystemSetting.code.in_(OBSOLETE_TIER_SETTINGS))
        del_res = await db.execute(del_stmt)
        if del_res.rowcount and del_res.rowcount > 0:
            print(f"Removed {del_res.rowcount} obsolete tier settings migrated to subscription_tiers table.")

        # 2. Insert or update core global system settings
        inserted_count = 0
        updated_count = 0
        for item in DEFAULT_SETTINGS:
            stmt = select(SystemSetting).where(SystemSetting.code == item["code"])
            res = await db.execute(stmt)
            existing = res.scalar_one_or_none()

            if not existing:
                setting = SystemSetting(
                    code=item["code"],
                    value=str(item["value"]),
                    order_number=item["order_number"],
                )
                db.add(setting)
                inserted_count += 1
            else:
                existing.order_number = item["order_number"]
                updated_count += 1

        await db.commit()
        print(f"System settings seeded successfully! (Inserted: {inserted_count}, Checked/Updated: {updated_count})")


if __name__ == "__main__":
    asyncio.run(seed_settings())
