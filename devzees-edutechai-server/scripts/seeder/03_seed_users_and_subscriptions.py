import asyncio
import os
import sys

sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from sqlalchemy import select
from sqlalchemy.orm import selectinload
from models.db_models import User, Role, Subscription
from services.user_service import UserService
from services.database import get_db_session
from datetime import datetime, timezone, timedelta

USERS = [
    {"email": "admin@gmail.com", "role": "Admin", "tier": "ultra"},
    {"email": "free@gmail.com", "role": "Free", "tier": "free"},
    {"email": "pro@gmail.com", "role": "Pro", "tier": "pro"},
    {"email": "ultra@gmail.com", "role": "Ultra", "tier": "ultra"}
]
PASSWORD = "Test2day@"

async def seed_users_and_subscriptions():
    print("Starting user and subscription seeding...")
    async with get_db_session() as db:
        roles_res = await db.execute(select(Role))
        roles = {r.name: r for r in roles_res.scalars().all()}
        
        hashed_pwd = UserService.hash_password(PASSWORD)
        
        for u_data in USERS:
            # Create or update user
            res = await db.execute(select(User).options(selectinload(User.roles)).where(User.email == u_data["email"]))
            user = res.scalar_one_or_none()
            
            if not user:
                user = User(
                    email=u_data["email"],
                    password_hash=hashed_pwd,
                    first_name=u_data["role"],
                    last_name="User"
                )
                if u_data["role"] in roles:
                    user.roles = [roles[u_data["role"]]]
                db.add(user)
                await db.flush()
            else:
                if u_data["role"] in roles:
                    user.roles = [roles[u_data["role"]]]
                
                
            # Assign subscription
            res_sub = await db.execute(select(Subscription).where(Subscription.user_id == user.id))
            sub = res_sub.scalar_one_or_none()
            
            if not sub:
                sub = Subscription(
                    user_id=user.id,
                    tier=u_data["tier"],
                    status="active",
                    billing_cycle="monthly",
                    current_period_start=datetime.now(timezone.utc).replace(tzinfo=None),
                    current_period_end=(datetime.now(timezone.utc) + timedelta(days=30)).replace(tzinfo=None),
                    auto_renew=True
                )
                db.add(sub)
            else:
                sub.tier = u_data["tier"]
                sub.status = "active"

        await db.commit()
        print(f"Users and Subscriptions seeded successfully. Default password is '{PASSWORD}'.")

if __name__ == "__main__":
    asyncio.run(seed_users_and_subscriptions())
