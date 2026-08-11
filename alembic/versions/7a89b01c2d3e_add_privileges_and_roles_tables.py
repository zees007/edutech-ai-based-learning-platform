"""add_privileges_and_roles_tables

Revision ID: 7a89b01c2d3e
Revises: 3e6636295fe4
Create Date: 2026-08-11 12:30:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '7a89b01c2d3e'
down_revision: Union[str, Sequence[str], None] = '3e6636295fe4'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.create_table(
        'privileges',
        sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
        sa.Column('name', sa.String(length=100), nullable=False),
        sa.Column('code', sa.String(length=100), nullable=False),
        sa.Column('order_number', sa.Integer(), nullable=True),
        sa.Column('parent_id', sa.Integer(), nullable=True),
        sa.ForeignKeyConstraint(['parent_id'], ['privileges.id'], ondelete='SET NULL'),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_privileges_code'), 'privileges', ['code'], unique=True)

    op.create_table(
        'roles',
        sa.Column('id', sa.String(length=36), nullable=False),
        sa.Column('name', sa.String(length=100), nullable=False),
        sa.Column('created_at', sa.DateTime(), server_default=sa.text('CURRENT_TIMESTAMP'), nullable=False),
        sa.Column('retired', sa.Boolean(), nullable=False),
        sa.Column('retired_at', sa.DateTime(), nullable=True),
        sa.Column('retired_by', sa.String(length=36), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_roles_name'), 'roles', ['name'], unique=True)

    op.create_table(
        'role_privileges',
        sa.Column('role_id', sa.String(length=36), nullable=False),
        sa.Column('privilege_id', sa.Integer(), nullable=False),
        sa.ForeignKeyConstraint(['privilege_id'], ['privileges.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['role_id'], ['roles.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('role_id', 'privilege_id')
    )


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_table('role_privileges')
    op.drop_index(op.f('ix_roles_name'), table_name='roles')
    op.drop_table('roles')
    op.drop_index(op.f('ix_privileges_code'), table_name='privileges')
    op.drop_table('privileges')
