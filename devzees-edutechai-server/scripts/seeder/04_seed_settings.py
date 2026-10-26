"""
EduTechAI — System Settings Seeder

Seeds initial system configuration values into the `settings` table:
- Agent LLM Models
- Pro and Ultra Subscription Prices (Monthly & Annually)
- Promotional Coupons
"""

import asyncio
import os
import sys

sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from sqlalchemy import select
from models.db_models import SystemSetting
from services.database import get_db_session

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
        "code": "PRO_MONTHLY",
        "value": "19",
        "order_number": 40,
    },
    {
        "code": "PRO_ANNUALLY",
        "value": "180",
        "order_number": 50,
    },
    {
        "code": "ULTRA_MONTHLY",
        "value": "49",
        "order_number": 60,
    },
    {
        "code": "ULTRA_ANNUALLY",
        "value": "470",
        "order_number": 70,
    },
    {
        "code": "PROMO_BANNER_ENABLED",
        "value": "true",
        "order_number": 75,
    },
    {
        "code": "PROMO_BANNER_TEXT",
        "value": "🪔 Diwali Special: Celebrate with 50% OFF on all Pro & Ultra plans! Use code DIWALI50 at checkout",
        "order_number": 76,
    },
    {
        "code": "PROMO_BANNER_COUPON",
        "value": "DIWALI50",
        "order_number": 77,
    },
    {
        "code": "VALID_COUPONS",
        "value": "EDU20:20,WELCOME50:50,STUDENT10:10,EDUTECH100:100,DIWALI50:50",
        "order_number": 80,
    },
    {
        "code": "YOUTUBE_DAILY_SEARCH_LIMIT",
        "value": "100",
        "order_number": 85,
    },
    {
        "code": "FREE_YOUTUBE_LIMIT",
        "value": "1",
        "order_number": 90,
    },
    {
        "code": "PRO_YOUTUBE_LIMIT",
        "value": "3",
        "order_number": 100,
    },
    {
        "code": "ULTRA_YOUTUBE_LIMIT",
        "value": "5",
        "order_number": 110,
    },
    {
        "code": "FREE_FOLLOWUP_LIMIT",
        "value": "1",
        "order_number": 120,
    },
    {
        "code": "PRO_FOLLOWUP_LIMIT",
        "value": "5",
        "order_number": 130,
    },
]


async def seed_settings():
    print("Starting system settings seeding...")
    async with get_db_session() as db:
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
