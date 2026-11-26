"""
Unit tests for database initialization behavior with AUTO_CREATE_TABLES=true/false.
"""

from contextlib import asynccontextmanager
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from config import Settings
from services import database


class _FakeResult:
    def __init__(self, value):
        self._value = value

    def scalar_one_or_none(self):
        return self._value


@pytest.fixture(autouse=True)
def _reset_db_initialized():
    original = database._db_initialized
    database._db_initialized = False
    yield
    database._db_initialized = original


@pytest.mark.asyncio
async def test_init_db_disabled_ddl_still_verifies_schema_and_syncs_settings():
    settings = Settings(
        database_url="postgresql+asyncpg://user:pass@localhost:5432/edutechai",
        database_schema="edutechAI",
        auto_create_tables=False,
    )

    mock_conn = AsyncMock()
    mock_conn.execute.return_value = _FakeResult(1)

    @asynccontextmanager
    async def fake_connect():
        yield mock_conn

    mock_engine = MagicMock()
    mock_engine.connect = fake_connect

    mock_session = AsyncMock()

    @asynccontextmanager
    async def fake_get_db_session():
        yield mock_session

    with (
        patch.object(database, "_get_engine", return_value=mock_engine),
        patch.object(database, "run_auto_migrations", new_callable=AsyncMock) as mock_migrate,
        patch.object(database, "get_db_session", fake_get_db_session),
        patch("services.setting_service.SettingService.sync_cache_from_db", new_callable=AsyncMock) as mock_sync,
    ):
        await database.init_db(settings)

    mock_migrate.assert_not_awaited()
    mock_conn.execute.assert_awaited_once()
    sql_text = str(mock_conn.execute.call_args.args[0])
    assert "information_schema.schemata" in sql_text
    mock_sync.assert_awaited_once_with(mock_session)
    assert database._db_initialized is True


@pytest.mark.asyncio
async def test_init_db_disabled_ddl_raises_if_schema_missing():
    settings = Settings(
        database_url="postgresql+asyncpg://user:pass@localhost:5432/edutechai",
        database_schema="missing_schema",
        auto_create_tables=False,
    )

    mock_conn = AsyncMock()
    mock_conn.execute.return_value = _FakeResult(None)

    @asynccontextmanager
    async def fake_connect():
        yield mock_conn

    mock_engine = MagicMock()
    mock_engine.connect = fake_connect

    with (
        patch.object(database, "_get_engine", return_value=mock_engine),
        patch.object(database, "run_auto_migrations", new_callable=AsyncMock) as mock_migrate,
    ):
        with pytest.raises(RuntimeError, match="missing_schema"):
            await database.init_db(settings)

    mock_migrate.assert_not_awaited()
    assert database._db_initialized is False


@pytest.mark.asyncio
async def test_init_db_enabled_ddl_creates_schema_migrates_and_syncs_settings():
    settings = Settings(
        database_url="postgresql+asyncpg://user:pass@localhost:5432/edutechai",
        database_schema="edutechAI",
        auto_create_tables=True,
    )

    mock_conn = AsyncMock()

    @asynccontextmanager
    async def fake_begin():
        yield mock_conn

    mock_engine = MagicMock()
    mock_engine.begin = fake_begin

    mock_session = AsyncMock()

    @asynccontextmanager
    async def fake_get_db_session():
        yield mock_session

    with (
        patch.object(database, "_get_engine", return_value=mock_engine),
        patch.object(database, "run_auto_migrations", new_callable=AsyncMock) as mock_migrate,
        patch.object(database, "get_db_session", fake_get_db_session),
        patch("services.setting_service.SettingService.sync_cache_from_db", new_callable=AsyncMock) as mock_sync,
    ):
        await database.init_db(settings)

    mock_conn.execute.assert_awaited_once()
    assert 'CREATE SCHEMA IF NOT EXISTS "edutechAI";' in str(mock_conn.execute.call_args.args[0])
    mock_migrate.assert_awaited_once()
    mock_sync.assert_awaited_once_with(mock_session)
    assert database._db_initialized is True
