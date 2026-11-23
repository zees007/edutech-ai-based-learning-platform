"""create user_trophies table

Revision ID: 0011_user_trophies
Revises: 0010_step_progress_index
Create Date: 2026-11-20 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = '0011_user_trophies'
down_revision: Union[str, Sequence[str], None] = '0010_step_progress_index'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def table_exists(table_name: str) -> bool:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    return insp.has_table(table_name)


def upgrade() -> None:
    if not table_exists('user_trophies'):
        op.create_table(
            'user_trophies',
            sa.Column('id', sa.Integer(), autoincrement=True, primary_key=True),
            sa.Column('user_id', sa.String(36), nullable=False),
            sa.Column('trophy_id', sa.String(20), nullable=False),
            sa.Column('unlocked_at', sa.DateTime(), nullable=False),
            sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
            sa.UniqueConstraint('user_id', 'trophy_id', name='uq_user_trophy'),
        )
        op.create_index('ix_user_trophies_user_id', 'user_trophies', ['user_id'])


def downgrade() -> None:
    if table_exists('user_trophies'):
        op.drop_index('ix_user_trophies_user_id', table_name='user_trophies')
        op.drop_table('user_trophies')
