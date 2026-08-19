"""add_payment_transactions_and_subscription_fields

Revision ID: a1b2c3d4e5f6
Revises: 9b12c3d4e5f6
Create Date: 2026-08-19 11:35:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'a1b2c3d4e5f6'
down_revision: Union[str, Sequence[str], None] = '9b12c3d4e5f6'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    with op.batch_alter_table('subscriptions') as batch_op:
        batch_op.add_column(sa.Column('billing_cycle', sa.String(length=20), nullable=False, server_default='monthly'))
        batch_op.add_column(sa.Column('price_amount', sa.Float(), nullable=False, server_default='0.0'))
        batch_op.add_column(sa.Column('gateway_provider', sa.String(length=50), nullable=False, server_default='sandbox'))
        batch_op.add_column(sa.Column('gateway_subscription_id', sa.String(length=255), nullable=True))
        batch_op.add_column(sa.Column('gateway_customer_id', sa.String(length=255), nullable=True))
        batch_op.add_column(sa.Column('gateway_metadata', sa.JSON(), nullable=True))
        batch_op.add_column(sa.Column('cancel_at_period_end', sa.Boolean(), nullable=False, server_default='0'))
        batch_op.add_column(sa.Column('auto_renew', sa.Boolean(), nullable=False, server_default='1'))

    op.create_table(
        'payment_transactions',
        sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
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
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.text('CURRENT_TIMESTAMP')),
        sa.ForeignKeyConstraint(['subscription_id'], ['subscriptions.id'], ondelete='SET NULL'),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_payment_transactions_transaction_id'), 'payment_transactions', ['transaction_id'], unique=True)
    op.create_index(op.f('ix_payment_transactions_user_id'), 'payment_transactions', ['user_id'], unique=False)


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_index(op.f('ix_payment_transactions_user_id'), table_name='payment_transactions')
    op.drop_index(op.f('ix_payment_transactions_transaction_id'), table_name='payment_transactions')
    op.drop_table('payment_transactions')

    with op.batch_alter_table('subscriptions') as batch_op:
        batch_op.drop_column('auto_renew')
        batch_op.drop_column('cancel_at_period_end')
        batch_op.drop_column('gateway_metadata')
        batch_op.drop_column('gateway_customer_id')
        batch_op.drop_column('gateway_subscription_id')
        batch_op.drop_column('gateway_provider')
        batch_op.drop_column('price_amount')
        batch_op.drop_column('billing_cycle')
