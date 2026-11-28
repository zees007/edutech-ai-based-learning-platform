"""add medium-priority trigram, partial, and covering indexes

Revision ID: 0015_medium_scale_indexes
Revises: 0014_scale_indexes_session_fks
Create Date: 2026-11-27 15:05:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "0015_medium_scale_indexes"
down_revision: Union[str, Sequence[str], None] = "0014_scale_indexes_session_fks"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def index_exists(index_name: str, table_name: str) -> bool:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    indexes = insp.get_indexes(table_name)
    return any(idx.get("name") == index_name for idx in indexes)


def upgrade() -> None:
    # M2 & M3: Enable pg_trgm and create GIN trigram indexes for ILIKE '%term%' queries
    op.execute("CREATE EXTENSION IF NOT EXISTS pg_trgm")

    if not index_exists("ix_users_fname_trgm", "users"):
        op.execute("CREATE INDEX ix_users_fname_trgm ON users USING gin (first_name gin_trgm_ops)")
    if not index_exists("ix_users_lname_trgm", "users"):
        op.execute("CREATE INDEX ix_users_lname_trgm ON users USING gin (last_name gin_trgm_ops)")
    if not index_exists("ix_users_email_trgm", "users"):
        op.execute("CREATE INDEX ix_users_email_trgm ON users USING gin (email gin_trgm_ops)")
    if not index_exists("ix_users_mobile_trgm", "users"):
        op.execute("CREATE INDEX ix_users_mobile_trgm ON users USING gin (mobile gin_trgm_ops)")
    if not index_exists("ix_sessions_topic_trgm", "sessions"):
        op.execute("CREATE INDEX ix_sessions_topic_trgm ON sessions USING gin (topic gin_trgm_ops)")

    # M5: Partial covering index for public featured testimonials query
    if not index_exists("ix_feedbacks_featured", "feedbacks"):
        op.execute(
            "CREATE INDEX ix_feedbacks_featured ON feedbacks (updated_at DESC) "
            "WHERE status = 'featured' AND is_public_consent = true"
        )

    # M6: Composite index for payment transaction history sorted by created_at DESC
    if not index_exists("ix_payment_txn_user_created", "payment_transactions"):
        op.execute(
            "CREATE INDEX ix_payment_txn_user_created ON payment_transactions (user_id, created_at DESC)"
        )

    # Covering index for subscription tier/status counts in AdminService
    if not index_exists("ix_subscriptions_tier_status", "subscriptions"):
        op.create_index(
            "ix_subscriptions_tier_status",
            "subscriptions",
            ["tier", "status"],
            unique=False,
        )


def downgrade() -> None:
    if index_exists("ix_subscriptions_tier_status", "subscriptions"):
        op.drop_index("ix_subscriptions_tier_status", table_name="subscriptions")
    op.execute("DROP INDEX IF EXISTS ix_payment_txn_user_created")
    op.execute("DROP INDEX IF EXISTS ix_feedbacks_featured")
    op.execute("DROP INDEX IF EXISTS ix_sessions_topic_trgm")
    op.execute("DROP INDEX IF EXISTS ix_users_mobile_trgm")
    op.execute("DROP INDEX IF EXISTS ix_users_email_trgm")
    op.execute("DROP INDEX IF EXISTS ix_users_lname_trgm")
    op.execute("DROP INDEX IF EXISTS ix_users_fname_trgm")
