"""add_user_id_to_sessions

Revision ID: 9b12c3d4e5f6
Revises: 7a89b01c2d3e
Create Date: 2026-08-17 12:50:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '9b12c3d4e5f6'
down_revision: Union[str, Sequence[str], None] = '7a89b01c2d3e'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    with op.batch_alter_table('sessions') as batch_op:
        batch_op.add_column(
            sa.Column('user_id', sa.String(length=36), nullable=False)
        )
        batch_op.create_index(batch_op.f('ix_sessions_user_id'), ['user_id'], unique=False)
        batch_op.create_foreign_key(
            'fk_sessions_user_id_users',
            'users',
            ['user_id'],
            ['id'],
            ondelete='CASCADE'
        )


def downgrade() -> None:
    """Downgrade schema."""
    with op.batch_alter_table('sessions') as batch_op:
        batch_op.drop_constraint('fk_sessions_user_id_users', type_='foreignkey')
        batch_op.drop_index(batch_op.f('ix_sessions_user_id'))
        batch_op.drop_column('user_id')
