"""add xp_earned to step_progress table

Revision ID: 0012_step_progress_xp
Revises: 0011_user_trophies
Create Date: 2026-11-22 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = '0012_step_progress_xp'
down_revision: Union[str, Sequence[str], None] = '0011_user_trophies'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def column_exists(table_name: str, column_name: str) -> bool:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    cols = [c['name'] for c in insp.get_columns(table_name)]
    return column_name in cols


def upgrade() -> None:
    if not column_exists('step_progress', 'xp_earned'):
        op.add_column(
            'step_progress',
            sa.Column('xp_earned', sa.Integer(), server_default='0', nullable=False),
        )


def downgrade() -> None:
    if column_exists('step_progress', 'xp_earned'):
        op.drop_column('step_progress', 'xp_earned')
