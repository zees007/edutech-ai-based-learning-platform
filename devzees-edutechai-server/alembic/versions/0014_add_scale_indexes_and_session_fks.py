"""add high-priority composite indexes and session foreign keys

Revision ID: 0014_scale_indexes_session_fks
Revises: 0013_tier_streak_multiplier
Create Date: 2026-11-26 22:28:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "0014_scale_indexes_session_fks"
down_revision: Union[str, Sequence[str], None] = "0013_tier_streak_multiplier"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def index_exists(index_name: str, table_name: str) -> bool:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    indexes = insp.get_indexes(table_name)
    return any(idx.get("name") == index_name for idx in indexes)


def fk_exists(fk_name: str, table_name: str, constrained_col: str, referred_table: str) -> bool:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    fks = insp.get_foreign_keys(table_name)
    return any(
        fk.get("name") == fk_name
        or (
            fk.get("referred_table") == referred_table
            and fk.get("constrained_columns") == [constrained_col]
        )
        for fk in fks
    )


def upgrade() -> None:
    # H1: Composite indexes on sessions
    if not index_exists("ix_sessions_user_created", "sessions"):
        op.create_index(
            "ix_sessions_user_created",
            "sessions",
            ["user_id", "created_at"],
            unique=False,
        )
    if not index_exists("ix_sessions_user_complete_updated", "sessions"):
        op.create_index(
            "ix_sessions_user_complete_updated",
            "sessions",
            ["user_id", "is_complete", "updated_at"],
            unique=False,
        )

    # H2: Composite index on session_usage_logs
    if not index_exists("ix_session_usage_user_created", "session_usage_logs"):
        op.create_index(
            "ix_session_usage_user_created",
            "session_usage_logs",
            ["user_id", "created_at"],
            unique=False,
        )

    # H3: Composite unique index on step_progress(session_id, step_index)
    if not index_exists("ix_step_progress_session_step", "step_progress"):
        op.create_index(
            "ix_step_progress_session_step",
            "step_progress",
            ["session_id", "step_index"],
            unique=True,
        )

    # H4: Composite indexes on refresh_tokens
    if not index_exists("ix_refresh_token_user_active", "refresh_tokens"):
        op.create_index(
            "ix_refresh_token_user_active",
            "refresh_tokens",
            ["user_id", "revoked_at"],
            unique=False,
        )
    if not index_exists("ix_refresh_token_family_active", "refresh_tokens"):
        op.create_index(
            "ix_refresh_token_family_active",
            "refresh_tokens",
            ["family_id", "revoked_at"],
            unique=False,
        )

    # H5: Clean orphaned child rows, then add CASCADE ForeignKeys to sessions.session_id
    op.execute(
        """
        DELETE FROM step_progress sp
        WHERE NOT EXISTS (
            SELECT 1 FROM sessions s WHERE s.session_id = sp.session_id
        )
        """
    )
    op.execute(
        """
        DELETE FROM gamification g
        WHERE NOT EXISTS (
            SELECT 1 FROM sessions s WHERE s.session_id = g.session_id
        )
        """
    )

    if not fk_exists("fk_step_progress_session_id", "step_progress", "session_id", "sessions"):
        op.create_foreign_key(
            "fk_step_progress_session_id",
            "step_progress",
            "sessions",
            ["session_id"],
            ["session_id"],
            ondelete="CASCADE",
        )

    if not fk_exists("fk_gamification_session_id", "gamification", "session_id", "sessions"):
        op.create_foreign_key(
            "fk_gamification_session_id",
            "gamification",
            "sessions",
            ["session_id"],
            ["session_id"],
            ondelete="CASCADE",
        )


def downgrade() -> None:
    if fk_exists("fk_gamification_session_id", "gamification", "session_id", "sessions"):
        op.drop_constraint("fk_gamification_session_id", "gamification", type_="foreignkey")
    if fk_exists("fk_step_progress_session_id", "step_progress", "session_id", "sessions"):
        op.drop_constraint("fk_step_progress_session_id", "step_progress", type_="foreignkey")

    if index_exists("ix_refresh_token_family_active", "refresh_tokens"):
        op.drop_index("ix_refresh_token_family_active", table_name="refresh_tokens")
    if index_exists("ix_refresh_token_user_active", "refresh_tokens"):
        op.drop_index("ix_refresh_token_user_active", table_name="refresh_tokens")
    if index_exists("ix_step_progress_session_step", "step_progress"):
        op.drop_index("ix_step_progress_session_step", table_name="step_progress")
    if index_exists("ix_session_usage_user_created", "session_usage_logs"):
        op.drop_index("ix_session_usage_user_created", table_name="session_usage_logs")
    if index_exists("ix_sessions_user_complete_updated", "sessions"):
        op.drop_index("ix_sessions_user_complete_updated", table_name="sessions")
    if index_exists("ix_sessions_user_created", "sessions"):
        op.drop_index("ix_sessions_user_created", table_name="sessions")
