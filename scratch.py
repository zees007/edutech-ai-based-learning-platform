import asyncio
from services.database import get_db_session
from models.db_models import User, Role
from sqlalchemy.orm import selectinload
from sqlalchemy import select

async def run():
    async with get_db_session() as db:
        res = await db.execute(select(User).options(selectinload(User.roles)).where(User.email == "free@gmail.com"))
        u = res.scalar_one_or_none()
        print("User:", u.email if u else None)
        print("Roles:", [r.name for r in u.roles] if u else None)

if __name__ == "__main__":
    asyncio.run(run())
