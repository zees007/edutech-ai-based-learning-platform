"""create_roles_and_privileges_tables

Revision ID: 0002_roles_privileges
Revises: 0001_users
Create Date: 2026-08-22 15:05:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '0002_roles_privileges'
down_revision: Union[str, None] = '0001_users'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def table_exists(table_name: str) -> bool:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    return insp.has_table(table_name)


def upgrade() -> None:
    """Create privileges, roles, role_privileges, and user_roles tables if they do not exist."""
    # 1. privileges table
    if not table_exists('privileges'):
        op.create_table(
            'privileges',
            sa.Column('id', sa.Integer(), autoincrement=True, primary_key=True, nullable=False),
            sa.Column('name', sa.String(length=100), nullable=False),
            sa.Column('code', sa.String(length=100), nullable=False),
            sa.Column('order_number', sa.Integer(), nullable=True, default=0),
            sa.Column('parent_id', sa.Integer(), nullable=True),
            sa.ForeignKeyConstraint(['parent_id'], ['privileges.id'], ondelete='SET NULL'),
        )
        op.create_index('ix_privileges_code', 'privileges', ['code'], unique=True)

    # 2. roles table
    if not table_exists('roles'):
        op.create_table(
            'roles',
            sa.Column('id', sa.String(length=36), primary_key=True, nullable=False),
            sa.Column('name', sa.String(length=100), nullable=False),
            sa.Column('created_at', sa.DateTime(), server_default=sa.func.now(), nullable=False),
            sa.Column('retired', sa.Boolean(), default=False, nullable=False),
            sa.Column('retired_at', sa.DateTime(), nullable=True),
            sa.Column('retired_by', sa.String(length=36), nullable=True),
        )
        op.create_index('ix_roles_name', 'roles', ['name'], unique=True)

    # 3. role_privileges (many-to-many junction)
    if not table_exists('role_privileges'):
        op.create_table(
            'role_privileges',
            sa.Column('role_id', sa.String(length=36), nullable=False),
            sa.Column('privilege_id', sa.Integer(), nullable=False),
            sa.ForeignKeyConstraint(['role_id'], ['roles.id'], ondelete='CASCADE'),
            sa.ForeignKeyConstraint(['privilege_id'], ['privileges.id'], ondelete='CASCADE'),
            sa.PrimaryKeyConstraint('role_id', 'privilege_id'),
        )

    # 4. user_roles (many-to-many junction)
    if not table_exists('user_roles'):
        op.create_table(
            'user_roles',
            sa.Column('user_id', sa.String(length=36), nullable=False),
            sa.Column('role_id', sa.String(length=36), nullable=False),
            sa.Column('assigned_at', sa.DateTime(), server_default=sa.func.now(), nullable=False),
            sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
            sa.ForeignKeyConstraint(['role_id'], ['roles.id'], ondelete='CASCADE'),
            sa.PrimaryKeyConstraint('user_id', 'role_id'),
        )


def downgrade() -> None:
    """Drop user_roles, role_privileges, roles, and privileges tables if they exist."""
    if table_exists('user_roles'):
        op.drop_table('user_roles')
    if table_exists('role_privileges'):
        op.drop_table('role_privileges')
    if table_exists('roles'):
        op.drop_index('ix_roles_name', table_name='roles')
        op.drop_table('roles')
    if table_exists('privileges'):
        op.drop_index('ix_privileges_code', table_name='privileges')
        op.drop_table('privileges')
