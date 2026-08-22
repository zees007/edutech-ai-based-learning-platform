import asyncio
import os
import sys

# Add the project root to the Python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from sqlalchemy import select
from models.db_models import User, Role
from services.database import get_db_session, init_db
from config import get_settings
from services.auth_service import AuthService
from services.user_service import UserService

async def seed_users():
    settings = get_settings()
    await init_db(settings)

    async with get_db_session() as session:
        # Get roles
        roles = {}
        for role_name in ["Free", "Pro", "Ultra"]:
            res = await session.execute(select(Role).where(Role.name == role_name))
            role = res.scalar_one_or_none()
            if role:
                roles[role_name] = role
        
        users_to_create = [
            {"email": "free@test.com", "first": "Free", "last": "User", "role": "Free"},
            {"email": "pro@test.com", "first": "Pro", "last": "User", "role": "Pro"},
            {"email": "ultra@test.com", "first": "Ultra", "last": "User", "role": "Ultra"},
        ]

        for u_data in users_to_create:
            res = await session.execute(select(User).where(User.email == u_data["email"]))
            if not res.scalar_one_or_none():
                user = User(
                    first_name=u_data["first"],
                    last_name=u_data["last"],
                    email=u_data["email"],
                    password_hash=UserService.hash_password("password123"),
                    retired=False,
                )
                session.add(user)
                if u_data["role"] in roles:
                    user.roles.append(roles[u_data["role"]])
                print(f"Created user {u_data['email']} with role {u_data['role']}")
            else:
                print(f"User {u_data['email']} already exists.")
        
        await session.commit()
        print("Users seeded successfully.")

if __name__ == "__main__":
    asyncio.run(seed_users())
