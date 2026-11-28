"""
EduTechAI — Database Service

SQLAlchemy async engine and session factory. Reads DATABASE_URL from config.

Uses PostgreSQL via asyncpg driver.
"""

from __future__ import annotations

import asyncio
import logging
from contextlib import asynccontextmanager
from pathlib import Path
from typing import AsyncGenerator

from sqlalchemy import text
from sqlalchemy.ext.asyncio import (
    AsyncEngine,
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)

from config import Settings, get_settings

logger = logging.getLogger(__name__)

# ─── Module-level singletons ─────────────────────────────────────
_engine: AsyncEngine | None = None
_engine_loop: asyncio.AbstractEventLoop | None = None
_session_factory: async_sessionmaker[AsyncSession] | None = None
_db_initialized: bool = False  # Guard: ensures init_db() is a no-op after first run


def _get_engine(settings: Settings | None = None) -> AsyncEngine:
    """Create or return the singleton async engine, bound to active event loop."""
    global _engine, _engine_loop, _session_factory
    try:
        current_loop = asyncio.get_running_loop()
    except RuntimeError:
        current_loop = None

    # Reset engine singleton if active event loop has changed across async tasks
    if _engine is not None and current_loop is not None and _engine_loop is not current_loop:
        _engine = None
        _session_factory = None
        _engine_loop = None

    if _engine is None:
        settings = settings or get_settings()
        connect_args = {}
        if "postgresql" in settings.database_url:
            # Route all queries and table creation exclusively to the target schema
            # Disable prepared statement caching for compatibility with PgBouncer / Supabase pooler
            connect_args["statement_cache_size"] = 0
            connect_args["prepared_statement_cache_size"] = 0
            schema = settings.database_schema
            if schema:
                connect_args["server_settings"] = {
                    "search_path": f'"{schema}"'
                }
        engine_kwargs: dict = {
            "echo": settings.db_echo,
            "connect_args": connect_args,
            "pool_pre_ping": True,
            "pool_recycle": 300,
        }
        if "postgresql" in settings.database_url:
            engine_kwargs["pool_size"] = settings.db_pool_size
            engine_kwargs["max_overflow"] = settings.db_max_overflow
            engine_kwargs["pool_timeout"] = settings.db_pool_timeout

        _engine = create_async_engine(
            settings.database_url,
            **engine_kwargs,
        )
        _engine_loop = current_loop
        logger.info(
            f"Database engine created: {settings.database_url.split('://')[0]}"
            f" (schema: {settings.database_schema if 'postgresql' in settings.database_url else 'default'})"
        )
    return _engine


def _get_session_factory(settings: Settings | None = None) -> async_sessionmaker[AsyncSession]:
    """Create or return the singleton session factory bound to current loop engine."""
    global _session_factory
    engine = _get_engine(settings)
    if _session_factory is None or _session_factory.kw.get("bind") is not engine:
        _session_factory = async_sessionmaker(
            bind=engine,
            class_=AsyncSession,
            expire_on_commit=False,
        )
    return _session_factory


def async_session_factory(settings: Settings | None = None) -> AsyncSession:
    """Return a new AsyncSession instance bound to the active event loop engine."""
    return _get_session_factory(settings)()


async def run_auto_migrations() -> None:
    """
    Run Alembic database migrations automatically on server startup.
    This applies any pending schema updates (e.g. new columns, new tables).
    """
    try:
        from alembic import command
        from alembic.config import Config

        alembic_ini = Path(__file__).resolve().parent.parent / "alembic.ini"
        alembic_cfg = Config(str(alembic_ini))
        await asyncio.to_thread(command.upgrade, alembic_cfg, "head")
        logger.info("Automatic database migrations (Alembic) executed successfully.")
    except Exception as e:
        logger.warning(f"Auto-migration check notice: {e}")


async def _verify_schema_exists(engine: AsyncEngine, settings: Settings) -> None:
    """Verify database connectivity and ensure the target PostgreSQL schema exists."""
    async with engine.connect() as conn:
        if "postgresql" in settings.database_url and settings.database_schema:
            result = await conn.execute(
                text(
                    "SELECT 1 FROM information_schema.schemata WHERE schema_name = :schema"
                ),
                {"schema": settings.database_schema},
            )
            if result.scalar_one_or_none() is None:
                raise RuntimeError(
                    f"Database schema '{settings.database_schema}' does not exist "
                    "and AUTO_CREATE_TABLES=false."
                )
        else:
            await conn.execute(text("SELECT 1"))


async def init_db(settings: Settings | None = None) -> None:
    """
    Initialize the database — create schema/tables when enabled, verify connectivity,
    and warm the dynamic settings cache. Called once during application startup.

    A module-level flag (_db_initialized) ensures this is a true no-op on any
    subsequent call within the same process lifetime, making screen switches fast.
    """
    global _db_initialized
    if _db_initialized:
        logger.debug("Database already initialized — skipping redundant init_db() call.")
        return

    settings = settings or get_settings()
    engine = _get_engine(settings)

    if settings.auto_create_tables:
        async with engine.begin() as conn:
            if "postgresql" in settings.database_url and settings.database_schema:
                schema = settings.database_schema
                await conn.execute(text(f'CREATE SCHEMA IF NOT EXISTS "{schema}";'))

        # Automatically run pending Alembic migrations on server startup
        await run_auto_migrations()
    else:
        logger.info(
            "Automatic DDL table creation is disabled (AUTO_CREATE_TABLES=false). "
            "Skipping schema creation and migrations."
        )
        await _verify_schema_exists(engine, settings)

    # Pre-warm dynamic system settings in-memory cache
    try:
        from services.setting_service import SettingService
        async with get_db_session() as session:
            await SettingService.sync_cache_from_db(session)
    except Exception as e:
        logger.debug(f"Initial settings cache sync notice: {e}")

    _db_initialized = True
    logger.info(f"Database initialization complete in schema '{settings.database_schema}'. Future calls will be skipped.")




async def close_db() -> None:
    """Close the database engine. Called during application shutdown."""
    global _engine, _engine_loop, _session_factory, _db_initialized
    if _engine is not None:
        try:
            await _engine.dispose()
        except Exception:
            pass
        _engine = None
        _engine_loop = None
        _session_factory = None
        _db_initialized = False  # Allow re-initialization on next startup
        logger.info("Database engine closed.")


@asynccontextmanager
async def get_db_session() -> AsyncGenerator[AsyncSession, None]:
    """
    Async context manager for database sessions.

    Usage:
        async with get_db_session() as session:
            result = await session.execute(select(SessionRecord))
    """
    factory = _get_session_factory()
    async with factory() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """
    FastAPI dependency for database sessions.

    Usage in routes:
        @router.get("/sessions")
        async def list_sessions(db: AsyncSession = Depends(get_db)):
            ...
    """
    factory = _get_session_factory()
    async with factory() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
