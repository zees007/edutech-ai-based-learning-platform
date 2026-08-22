import asyncio
import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from sqlalchemy import select
from sqlalchemy.orm import selectinload
from models.db_models import Role
from services.database import get_db_session, init_db
from config import get_settings

async def test():
    await init_db(get_settings())
    async with get_db_session() as session:
        res = await session.execute(select(Role).options(selectinload(Role.privileges)).where(Role.name=='Free'))
        role = res.scalar_one_or_none()
        if role:
            print(f"Free Privileges: {[p.code for p in role.privileges]}")
        
        # also print user free@gmail.com explicitly just in case
        from models.db_models import User
        res_u = await session.execute(select(User).options(selectinload(User.roles).selectinload(Role.privileges)).where(User.email=='free@gmail.com'))
        u = res_u.scalar_one_or_none()
        if u:
            print("free@gmail.com roles:", [r.name for r in u.roles])

if __name__ == "__main__":
    asyncio.run(test())
