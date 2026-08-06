"""
EduTechAI — Database Service

SQLAlchemy async engine and session factory. Reads DATABASE_URL from config.

To switch from SQLite to PostgreSQL, just change .env:
    DATABASE_URL=postgresql+asyncpg://user:pass@localhost:5432/edutechai
And install asyncpg:
    pip install asyncpg
"""

from __future__ import annotations

import logging
from contextlib import asynccontextmanager
from typing import AsyncGenerator

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
_session_factory: async_sessionmaker[AsyncSession] | None = None


def _get_engine(settings: Settings | None = None) -> AsyncEngine:
    """Create or return the singleton async engine."""
    global _engine
    if _engine is None:
        settings = settings or get_settings()
        connect_args = {}
        # SQLite needs check_same_thread=False for async
        if "sqlite" in settings.database_url:
            connect_args["check_same_thread"] = False
        _engine = create_async_engine(
            settings.database_url,
            echo=settings.debug,
            connect_args=connect_args,
        )
        logger.info(f"Database engine created: {settings.database_url.split('://')[0]}")
    return _engine


def _get_session_factory(settings: Settings | None = None) -> async_sessionmaker[AsyncSession]:
    """Create or return the singleton session factory."""
    global _session_factory
    if _session_factory is None:
        engine = _get_engine(settings)
        _session_factory = async_sessionmaker(
            bind=engine,
            class_=AsyncSession,
            expire_on_commit=False,
        )
    return _session_factory


async def init_db(settings: Settings | None = None) -> None:
    """
    Initialize the database — create all tables if they don't exist.
    Called once during application startup.
    """
    settings = settings or get_settings()
    # Ensure data directory exists for SQLite
    if "sqlite" in settings.database_url:
        settings.data_dir  # This creates the dir via the property

    engine = _get_engine(settings)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    logger.info("Database tables created/verified.")


async def close_db() -> None:
    """Close the database engine. Called during application shutdown."""
    global _engine, _session_factory
    if _engine is not None:
        await _engine.dispose()
        _engine = None
        _session_factory = None
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
