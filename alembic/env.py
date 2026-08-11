import asyncio
import logging
from logging.config import fileConfig
from pathlib import Path
import sys

from sqlalchemy import pool
from sqlalchemy.engine import Connection
from sqlalchemy.ext.asyncio import create_async_engine

from alembic import context

# Ensure workspace root is on sys.path so config and models can be imported
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from config import get_settings
from models.db_models import Base

# Alembic Config object
config = context.config

if config.config_file_name is not None:
    fileConfig(config.config_file_name)

target_metadata = Base.metadata

settings = get_settings()
db_url = settings.database_url
schema_name = settings.database_schema if "postgresql" in db_url else None

# Set dynamically from settings / .env
config.set_main_option("sqlalchemy.url", db_url)


def include_object(object, name, type_, reflected, compare_to):
    """Filter to ensure Alembic only inspects edutechAI schema and ignores Supabase system schemas."""
    if type_ == "schema":
        return name == schema_name if schema_name else True
    if reflected and getattr(object, "schema", None) is not None:
        if schema_name:
            return object.schema == schema_name
    return True


def run_migrations_offline() -> None:
    """Run migrations in 'offline' mode."""
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
        version_table_schema=schema_name,
        include_schemas=True if schema_name else False,
        include_object=include_object,
    )

    with context.begin_transaction():
        context.run_migrations()


def do_run_migrations(connection: Connection) -> None:
    context.configure(
        connection=connection,
        target_metadata=target_metadata,
        version_table_schema=schema_name,
        include_schemas=True if schema_name else False,
        include_object=include_object,
    )

    with context.begin_transaction():
        context.run_migrations()


async def run_async_migrations() -> None:
    """Run migrations using async engine."""
    connect_args = {}
    if "sqlite" in db_url:
        connect_args["check_same_thread"] = False
    elif "postgresql" in db_url:
        connect_args["statement_cache_size"] = 0
        connect_args["prepared_statement_cache_size"] = 0
        if schema_name:
            connect_args["server_settings"] = {"search_path": f'"{schema_name}"'}

    connectable = create_async_engine(
        db_url,
        poolclass=pool.NullPool,
        connect_args=connect_args,
    )

    async with connectable.connect() as connection:
        await connection.run_sync(do_run_migrations)

    await connectable.dispose()


def run_migrations_online() -> None:
    """Run migrations in 'online' mode."""
    asyncio.run(run_async_migrations())


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
