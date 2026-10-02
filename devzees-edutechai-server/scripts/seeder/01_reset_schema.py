import asyncio
import os
import sys

# Add project root to sys.path
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from sqlalchemy import text
from services.database import _get_engine
from config import get_settings

async def reset_schema():
    print("Resetting database schema...")
    settings = get_settings()
    engine = _get_engine()
    
    async with engine.begin() as conn:
        schema_name = settings.database_schema or "public"
        print(f"Dropping and recreating schema: {schema_name}...")
        await conn.execute(text(f'DROP SCHEMA IF EXISTS "{schema_name}" CASCADE;'))
        await conn.execute(text(f'CREATE SCHEMA "{schema_name}";'))
        await conn.execute(text(f'GRANT ALL ON SCHEMA "{schema_name}" TO public;'))
        
    await engine.dispose()
    
    print("Running Alembic migrations...")
    project_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    os.chdir(project_root)
    os.system(".venv\\Scripts\\alembic.exe upgrade head")
    print("Database reset complete.")

if __name__ == "__main__":
    asyncio.run(reset_schema())
