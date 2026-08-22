import asyncio
import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from sqlalchemy import select
from sqlalchemy.orm import selectinload
from models.db_models import User, Role
from services.database import get_db_session, init_db
from config import get_settings

async def inspect_user():
    settings = get_settings()
    await init_db(settings)

    async with get_db_session() as session:
        stmt = (
            select(User)
            .options(selectinload(User.roles).selectinload(Role.privileges))
            .where(User.email == "free@gmail.com")
        )
        res = await session.execute(stmt)
        user = res.scalar_one_or_none()
        
        if not user:
            print("User free@gmail.com not found!")
            return
            
        print(f"User: {user.email}")
        print("Roles:")
        for r in user.roles:
            print(f"  - {r.name}")
            print(f"    Privileges: {len(r.privileges)}")
            for p in r.privileges:
                if p.code in ["ET_ALL", "ET_UNLIMITED_FOLLOW_UPS", "ET_REGENERATE_STEP"]:
                    print(f"      * {p.code}")

if __name__ == "__main__":
    asyncio.run(inspect_user())
