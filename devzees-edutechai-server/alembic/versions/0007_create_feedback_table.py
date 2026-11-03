"""Create feedback table

Revision ID: 0007_create_feedback_table
Revises: 0006_create_settings_table
Create Date: 2026-11-03 19:30:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "0007_create_feedback_table"
down_revision: Union[str, Sequence[str], None] = "0006_create_settings_table"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.create_table(
        "feedbacks",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("feedback_id", sa.String(length=36), nullable=False),
        sa.Column("session_id", sa.String(length=24), nullable=False),
        sa.Column("user_id", sa.String(length=36), nullable=False),
        sa.Column("rating", sa.Integer(), nullable=False),
        sa.Column("quote", sa.String(length=250), nullable=False),
        sa.Column("education_level", sa.String(length=50), nullable=False),
        sa.Column("user_country", sa.String(length=100), nullable=True),
        sa.Column("topic_tag", sa.String(length=150), nullable=False),
        sa.Column("is_public_consent", sa.Boolean(), server_default=sa.text("true"), nullable=False),
        sa.Column("status", sa.String(length=20), server_default=sa.text("'pending'"), nullable=False),
        sa.Column("admin_notes", sa.String(length=255), nullable=True),
        sa.Column("created_at", sa.DateTime(), server_default=sa.text("now()"), nullable=False),
        sa.Column("updated_at", sa.DateTime(), server_default=sa.text("now()"), nullable=False),
        sa.ForeignKeyConstraint(["session_id"], ["sessions.session_id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("session_id", "user_id", name="uq_session_user_feedback"),
    )
    op.create_index(op.f("ix_feedbacks_feedback_id"), "feedbacks", ["feedback_id"], unique=True)
    op.create_index(op.f("ix_feedbacks_session_id"), "feedbacks", ["session_id"], unique=False)
    op.create_index(op.f("ix_feedbacks_user_id"), "feedbacks", ["user_id"], unique=False)
    op.create_index(op.f("ix_feedbacks_status"), "feedbacks", ["status"], unique=False)


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_index(op.f("ix_feedbacks_status"), table_name="feedbacks")
    op.drop_index(op.f("ix_feedbacks_user_id"), table_name="feedbacks")
    op.drop_index(op.f("ix_feedbacks_session_id"), table_name="feedbacks")
    op.drop_index(op.f("ix_feedbacks_feedback_id"), table_name="feedbacks")
    op.drop_table("feedbacks")

