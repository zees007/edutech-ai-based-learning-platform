"""
EduTechAI — Database Service

SQLAlchemy async engine and session factory. Reads DATABASE_URL from config.

To switch from SQLite to PostgreSQL, just change .env:
    DATABASE_URL=postgresql+asyncpg://user:pass@localhost:5432/edutechai
And install asyncpg:
    pip install asyncpg
"""

from __future__ import annotations

import asyncio
import logging
from contextlib import asynccontextmanager
from typing import AsyncGenerator

from sqlalchemy import text
from sqlalchemy.ext.asyncio import (
    AsyncEngine,
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)

from config import Settings, get_settings
from models.db_models import Base

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

    # Reset engine singleton if active event loop has changed across Streamlit reruns
    if _engine is not None and current_loop is not None and _engine_loop is not current_loop:
        _engine = None
        _session_factory = None
        _engine_loop = None

    if _engine is None:
        settings = settings or get_settings()
        connect_args = {}
        # SQLite needs check_same_thread=False for async
        if "sqlite" in settings.database_url:
            connect_args["check_same_thread"] = False
        elif "postgresql" in settings.database_url:
            # Route all queries and table creation exclusively to the target schema
            # Disable prepared statement caching for compatibility with PgBouncer / Supabase pooler
            connect_args["statement_cache_size"] = 0
            connect_args["prepared_statement_cache_size"] = 0
            schema = settings.database_schema
            if schema:
                connect_args["server_settings"] = {
                    "search_path": f'"{schema}"'
                }
        _engine = create_async_engine(
            settings.database_url,
            echo=settings.debug,
            connect_args=connect_args,
            pool_pre_ping=True,
            pool_recycle=300,
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
        import asyncio
        from alembic import command
        from alembic.config import Config

        alembic_cfg = Config("alembic.ini")
        await asyncio.to_thread(command.upgrade, alembic_cfg, "head")
        logger.info("Automatic database migrations (Alembic) executed successfully.")
    except Exception as e:
        logger.warning(f"Auto-migration check notice: {e}")


async def init_db(settings: Settings | None = None) -> None:
    """
    Initialize the database — create schema, tables, and run pending migrations.
    Called once during application startup.

    A module-level flag (_db_initialized) ensures this is a true no-op on any
    subsequent call within the same process lifetime, making screen switches fast.
    """
    global _db_initialized
    if _db_initialized:
        logger.debug("Database already initialized — skipping redundant init_db() call.")
        return

    settings = settings or get_settings()
    if not settings.auto_create_tables:
        logger.info("Automatic DDL table creation is disabled (AUTO_CREATE_TABLES=false).")
        _db_initialized = True
        return

    # Ensure data directory exists for SQLite
    if "sqlite" in settings.database_url:
        settings.data_dir  # This creates the dir via the property

    engine = _get_engine(settings)
    async with engine.begin() as conn:
        if "postgresql" in settings.database_url and settings.database_schema:
            schema = settings.database_schema
            await conn.execute(text(f'CREATE SCHEMA IF NOT EXISTS "{schema}";'))
        await conn.run_sync(Base.metadata.create_all)
    logger.info(f"Database tables created/verified in schema '{settings.database_schema}'.")

    # Automatically run pending migrations on server restart
    await run_auto_migrations()

    _db_initialized = True
    logger.info("Database initialization complete — future calls will be skipped.")



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
