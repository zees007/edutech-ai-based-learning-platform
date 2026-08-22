"""create_subscriptions_and_payments_tables

Revision ID: 0003_subscriptions_payments
Revises: 0002_roles_privileges
Create Date: 2026-08-22 15:10:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '0003_subscriptions_payments'
down_revision: Union[str, None] = '0002_roles_privileges'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def table_exists(table_name: str) -> bool:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    return insp.has_table(table_name)


def upgrade() -> None:
    """Create subscriptions and payment_transactions tables if they do not exist."""
    # 1. subscriptions table
    if not table_exists('subscriptions'):
        op.create_table(
            'subscriptions',
            sa.Column('id', sa.Integer(), autoincrement=True, primary_key=True, nullable=False),
            sa.Column('user_id', sa.String(length=36), nullable=False),
            sa.Column('tier', sa.String(length=50), nullable=False, server_default='free'),
            sa.Column('status', sa.String(length=50), nullable=False, server_default='active'),
            sa.Column('billing_cycle', sa.String(length=20), nullable=False, server_default='monthly'),
            sa.Column('price_amount', sa.Float(), nullable=False, server_default='0.0'),
            sa.Column('current_period_start', sa.DateTime(), server_default=sa.func.now(), nullable=False),
            sa.Column('current_period_end', sa.DateTime(), nullable=True),
            sa.Column('gateway_provider', sa.String(length=50), nullable=False, server_default='sandbox'),
            sa.Column('gateway_subscription_id', sa.String(length=255), nullable=True),
            sa.Column('gateway_customer_id', sa.String(length=255), nullable=True),
            sa.Column('gateway_metadata', sa.JSON(), nullable=True),
            sa.Column('payment_gateway_ref', sa.String(length=255), nullable=True),
            sa.Column('cancel_at_period_end', sa.Boolean(), default=False, nullable=False),
            sa.Column('auto_renew', sa.Boolean(), default=True, nullable=False),
            sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        )
        op.create_index('ix_subscriptions_user_id', 'subscriptions', ['user_id'], unique=True)
        op.create_index('ix_subscriptions_tier', 'subscriptions', ['tier'], unique=False)

    # 2. payment_transactions table
    if not table_exists('payment_transactions'):
        op.create_table(
            'payment_transactions',
            sa.Column('id', sa.Integer(), autoincrement=True, primary_key=True, nullable=False),
            sa.Column('transaction_id', sa.String(length=100), nullable=False),
            sa.Column('user_id', sa.String(length=36), nullable=False),
            sa.Column('subscription_id', sa.Integer(), nullable=True),
            sa.Column('gateway_provider', sa.String(length=50), nullable=False, server_default='paddle'),
            sa.Column('amount', sa.Float(), nullable=False),
            sa.Column('currency', sa.String(length=10), nullable=False, server_default='USD'),
            sa.Column('status', sa.String(length=30), nullable=False, server_default='completed'),
            sa.Column('tier', sa.String(length=30), nullable=False),
            sa.Column('billing_cycle', sa.String(length=20), nullable=False, server_default='monthly'),
            sa.Column('payment_method', sa.String(length=50), nullable=True),
            sa.Column('coupon_code', sa.String(length=50), nullable=True),
            sa.Column('created_at', sa.DateTime(), server_default=sa.func.now(), nullable=False),
            sa.ForeignKeyConstraint(['subscription_id'], ['subscriptions.id'], ondelete='SET NULL'),
            sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        )
        op.create_index('ix_payment_transactions_transaction_id', 'payment_transactions', ['transaction_id'], unique=True)
        op.create_index('ix_payment_transactions_user_id', 'payment_transactions', ['user_id'], unique=False)


def downgrade() -> None:
    """Drop payment_transactions and subscriptions tables if they exist."""
    if table_exists('payment_transactions'):
        op.drop_index('ix_payment_transactions_user_id', table_name='payment_transactions')
        op.drop_index('ix_payment_transactions_transaction_id', table_name='payment_transactions')
        op.drop_table('payment_transactions')
    if table_exists('subscriptions'):
        op.drop_index('ix_subscriptions_tier', table_name='subscriptions')
        op.drop_index('ix_subscriptions_user_id', table_name='subscriptions')
        op.drop_table('subscriptions')
