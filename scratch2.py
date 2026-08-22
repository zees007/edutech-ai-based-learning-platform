import asyncio
from services.database import get_db_session
from models.db_models import User, Role
from sqlalchemy.orm import selectinload
from sqlalchemy import select
from app.dependencies import has_privilege
from app.privileges_config import ET_UNLIMITED_FOLLOW_UPS
from config import get_settings

async def run():
    async with get_db_session() as db:
        res = await db.execute(select(User).options(selectinload(User.roles).selectinload(Role.privileges)).where(User.email == "free@gmail.com"))
        u = res.scalar_one_or_none()
        print("User:", u.email if u else None)
        print("Roles:", [r.name for r in u.roles] if u else None)
        print("Privileges:", [p.code for r in u.roles for p in r.privileges] if u else None)
        print("Is unlimited:", has_privilege(u, ET_UNLIMITED_FOLLOW_UPS) if u else False)
        settings = get_settings()
        print("free_youtube_limit:", settings.free_youtube_limit)
        print("pro_youtube_limit:", settings.pro_youtube_limit)
        print("free_followup_limit:", settings.free_followup_limit)

if __name__ == "__main__":
    asyncio.run(run())
