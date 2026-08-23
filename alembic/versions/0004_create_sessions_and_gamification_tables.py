"""create_sessions_and_gamification_tables

Revision ID: 0004_sessions_gamification
Revises: 0003_subscriptions_payments
Create Date: 2026-08-22 15:15:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '0004_sessions_gamification'
down_revision: Union[str, None] = '0003_subscriptions_payments'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def table_exists(table_name: str) -> bool:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    return insp.has_table(table_name)


def upgrade() -> None:
    """Create sessions, step_progress, and gamification tables if they do not exist."""
    # 1. sessions table
    if not table_exists('sessions'):
        op.create_table(
            'sessions',
            sa.Column('id', sa.Integer(), autoincrement=True, primary_key=True, nullable=False),
            sa.Column('session_id', sa.String(length=24), nullable=False),
            sa.Column('user_id', sa.String(length=36), nullable=False),
            sa.Column('topic', sa.Text(), nullable=False),
            sa.Column('learning_mode', sa.String(length=20), nullable=False, server_default='visual'),
            sa.Column('student_level', sa.String(length=30), nullable=False, server_default='general'),
            sa.Column('total_steps', sa.Integer(), server_default='0', nullable=False),
            sa.Column('current_step_index', sa.Integer(), server_default='0', nullable=False),
            sa.Column('is_complete', sa.Boolean(), default=False, nullable=False),
            sa.Column('state_json', sa.JSON(), nullable=True),
            sa.Column('created_at', sa.DateTime(), server_default=sa.func.now(), nullable=False),
            sa.Column('updated_at', sa.DateTime(), server_default=sa.func.now(), nullable=False),
            sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        )
        op.create_index('ix_sessions_session_id', 'sessions', ['session_id'], unique=True)
        op.create_index('ix_sessions_user_id', 'sessions', ['user_id'], unique=False)

    # 2. step_progress table
    if not table_exists('step_progress'):
        op.create_table(
            'step_progress',
            sa.Column('id', sa.Integer(), autoincrement=True, primary_key=True, nullable=False),
            sa.Column('session_id', sa.String(length=24), nullable=False),
            sa.Column('step_index', sa.Integer(), nullable=False),
            sa.Column('status', sa.String(length=20), nullable=False, server_default='pending'),
            sa.Column('quiz_score', sa.Float(), nullable=True),
            sa.Column('completed_at', sa.DateTime(), nullable=True),
        )
        op.create_index('ix_step_progress_session_id', 'step_progress', ['session_id'], unique=False)

    # 3. gamification table
    if not table_exists('gamification'):
        op.create_table(
            'gamification',
            sa.Column('id', sa.Integer(), autoincrement=True, primary_key=True, nullable=False),
            sa.Column('session_id', sa.String(length=24), nullable=False),
            sa.Column('xp_earned', sa.Integer(), server_default='0', nullable=False),
            sa.Column('streak_count', sa.Integer(), server_default='0', nullable=False),
            sa.Column('level', sa.Integer(), server_default='1', nullable=False),
            sa.Column('level_title', sa.String(length=50), server_default='Curious Explorer', nullable=False),
            sa.Column('updated_at', sa.DateTime(), server_default=sa.func.now(), nullable=False),
        )
        op.create_index('ix_gamification_session_id', 'gamification', ['session_id'], unique=True)


def downgrade() -> None:
    """Drop gamification, step_progress, and sessions tables if they exist."""
    if table_exists('gamification'):
        op.drop_index('ix_gamification_session_id', table_name='gamification')
        op.drop_table('gamification')
    if table_exists('step_progress'):
        op.drop_index('ix_step_progress_session_id', table_name='step_progress')
        op.drop_table('step_progress')
    if table_exists('sessions'):
        op.drop_index('ix_sessions_user_id', table_name='sessions')
        op.drop_index('ix_sessions_session_id', table_name='sessions')
        op.drop_table('sessions')
