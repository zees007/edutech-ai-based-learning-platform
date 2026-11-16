"""Create subscription_tiers table and link to subscriptions

Revision ID: 0009_create_subscription_tiers_table
Revises: 0008_session_usage_logs
Create Date: 2026-11-14 12:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "0009_subscription_tiers"
down_revision: Union[str, Sequence[str], None] = "0008_session_usage_logs"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema to include subscription_tiers table and subscriptions.tier_id."""
    op.create_table(
        "subscription_tiers",
        sa.Column("id", sa.String(length=36), nullable=False),
        sa.Column("created_at", sa.DateTime(), server_default=sa.text("now()"), nullable=False),
        sa.Column("retired", sa.Boolean(), server_default=sa.text("false"), nullable=False),
        sa.Column("retired_at", sa.DateTime(), nullable=True),
        sa.Column("retired_by", sa.String(length=36), nullable=True),
        sa.Column("slug", sa.String(length=50), nullable=False),
        sa.Column("name", sa.String(length=100), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("role_id", sa.String(length=36), nullable=False),
        sa.Column("price_monthly", sa.Float(), server_default=sa.text("0.0"), nullable=False),
        sa.Column("price_annual", sa.Float(), server_default=sa.text("0.0"), nullable=False),
        sa.Column("currency", sa.String(length=10), server_default=sa.text("'USD'"), nullable=False),
        sa.Column("monthly_session_limit", sa.Integer(), nullable=True),
        sa.Column("follow_up_limit_per_step", sa.Integer(), nullable=True),
        sa.Column("youtube_limit_per_step", sa.Integer(), nullable=True),
        sa.Column("is_public", sa.Boolean(), server_default=sa.text("true"), nullable=False),
        sa.Column("order_index", sa.Integer(), server_default=sa.text("0"), nullable=False),
        sa.ForeignKeyConstraint(["role_id"], ["roles.id"], ondelete="RESTRICT"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_subscription_tiers_slug"), "subscription_tiers", ["slug"], unique=True)
    op.create_index(op.f("ix_subscription_tiers_role_id"), "subscription_tiers", ["role_id"], unique=False)

    # Add tier_id foreign key column to subscriptions table
    op.add_column("subscriptions", sa.Column("tier_id", sa.String(length=36), nullable=True))
    op.create_foreign_key(
        "fk_subscriptions_tier_id",
        "subscriptions",
        "subscription_tiers",
        ["tier_id"],
        ["id"],
        ondelete="SET NULL",
    )
    op.create_index(op.f("ix_subscriptions_tier_id"), "subscriptions", ["tier_id"], unique=False)


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_constraint("fk_subscriptions_tier_id", "subscriptions", type_="foreignkey")
    op.drop_index(op.f("ix_subscriptions_tier_id"), table_name="subscriptions")
    op.drop_column("subscriptions", "tier_id")

    op.drop_index(op.f("ix_subscription_tiers_role_id"), table_name="subscription_tiers")
    op.drop_index(op.f("ix_subscription_tiers_slug"), table_name="subscription_tiers")
    op.drop_table("subscription_tiers")
