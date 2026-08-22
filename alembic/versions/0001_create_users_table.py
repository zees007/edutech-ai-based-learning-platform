"""create_users_table

Revision ID: 0001_users
Revises: None
Create Date: 2026-08-22 15:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '0001_users'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def table_exists(table_name: str) -> bool:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    return insp.has_table(table_name)


def upgrade() -> None:
    """Create users table if it does not already exist."""
    if not table_exists('users'):
        op.create_table(
            'users',
            sa.Column('id', sa.String(length=36), primary_key=True, nullable=False),
            sa.Column('first_name', sa.String(length=100), nullable=False),
            sa.Column('last_name', sa.String(length=100), nullable=False),
            sa.Column('email', sa.String(length=255), nullable=False),
            sa.Column('password_hash', sa.String(length=255), nullable=False),
            sa.Column('mobile', sa.String(length=20), nullable=True),
            sa.Column('country', sa.String(length=100), nullable=True),
            sa.Column('created_at', sa.DateTime(), server_default=sa.func.now(), nullable=False),
            sa.Column('retired', sa.Boolean(), default=False, nullable=False),
            sa.Column('retired_at', sa.DateTime(), nullable=True),
            sa.Column('retired_by', sa.String(length=36), nullable=True),
        )
        op.create_index('ix_users_email', 'users', ['email'], unique=True)


def downgrade() -> None:
    """Drop users table if it exists."""
    if table_exists('users'):
        op.drop_index('ix_users_email', table_name='users')
        op.drop_table('users')
