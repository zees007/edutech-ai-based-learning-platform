"""add step_progress composite index

Revision ID: 0010_step_progress_index
Revises: 0009_subscription_tiers
Create Date: 2026-11-20 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = '0010_step_progress_index'
down_revision: Union[str, Sequence[str], None] = '0009_subscription_tiers'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def index_exists(index_name: str, table_name: str) -> bool:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    indexes = insp.get_indexes(table_name)
    return any(idx.get('name') == index_name for idx in indexes)


def upgrade() -> None:
    if not index_exists('ix_step_progress_session_status', 'step_progress'):
        op.create_index(
            'ix_step_progress_session_status',
            'step_progress',
            ['session_id', 'status'],
            unique=False,
        )


def downgrade() -> None:
    if index_exists('ix_step_progress_session_status', 'step_progress'):
        op.drop_index('ix_step_progress_session_status', table_name='step_progress')
