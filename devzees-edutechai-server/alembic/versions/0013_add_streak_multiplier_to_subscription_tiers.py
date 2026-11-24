"""add streak_multiplier to subscription_tiers table

Revision ID: 0013_tier_streak_multiplier
Revises: 0012_step_progress_xp
Create Date: 2026-11-23 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = '0013_tier_streak_multiplier'
down_revision: Union[str, Sequence[str], None] = '0012_step_progress_xp'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def column_exists(table_name: str, column_name: str) -> bool:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    cols = [c['name'] for c in insp.get_columns(table_name)]
    return column_name in cols


def upgrade() -> None:
    if not column_exists('subscription_tiers', 'streak_multiplier'):
        op.add_column(
            'subscription_tiers',
            sa.Column('streak_multiplier', sa.Float(), server_default='1.0', nullable=False),
        )
        # Update existing tiers with their calibrated multipliers
        bind = op.get_bind()
        bind.execute(sa.text("UPDATE subscription_tiers SET streak_multiplier = 1.5 WHERE LOWER(slug) = 'pro'"))
        bind.execute(sa.text("UPDATE subscription_tiers SET streak_multiplier = 2.0 WHERE LOWER(slug) = 'ultra'"))
        bind.execute(sa.text("UPDATE subscription_tiers SET streak_multiplier = 1.0 WHERE LOWER(slug) = 'free'"))


def downgrade() -> None:
    if column_exists('subscription_tiers', 'streak_multiplier'):
        op.drop_column('subscription_tiers', 'streak_multiplier')
