"""Create session_usage_logs table

Revision ID: 0008_session_usage_logs
Revises: 0007_create_feedback_table
Create Date: 2026-11-11 12:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "0008_session_usage_logs"
down_revision: Union[str, Sequence[str], None] = "0007_create_feedback_table"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.create_table(
        "session_usage_logs",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("user_id", sa.String(length=36), nullable=False),
        sa.Column("session_id", sa.String(length=24), nullable=False),
        sa.Column("action", sa.String(length=50), server_default=sa.text("'cancelled_in_synthesis'"), nullable=False),
        sa.Column("created_at", sa.DateTime(), server_default=sa.text("now()"), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_session_usage_logs_user_id"), "session_usage_logs", ["user_id"], unique=False)
    op.create_index(op.f("ix_session_usage_logs_session_id"), "session_usage_logs", ["session_id"], unique=False)
    op.create_index(op.f("ix_session_usage_logs_created_at"), "session_usage_logs", ["created_at"], unique=False)


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_index(op.f("ix_session_usage_logs_created_at"), table_name="session_usage_logs")
    op.drop_index(op.f("ix_session_usage_logs_session_id"), table_name="session_usage_logs")
    op.drop_index(op.f("ix_session_usage_logs_user_id"), table_name="session_usage_logs")
    op.drop_table("session_usage_logs")

