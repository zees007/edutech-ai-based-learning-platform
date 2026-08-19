"""
EduTechAI — Subscription Service Layer

Encapsulates business logic for subscription management, checkout processing,
multi-gateway payments (Paddle, Razorpay, Sandbox), ledger logging, and automatic tier-role synchronization.
"""

from __future__ import annotations

import logging
from datetime import datetime, timedelta, timezone
from typing import List, Optional

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.exceptions import BadRequestException, NotFoundException
from models.db_models import PaymentTransaction, Role, Subscription, User
from models.subscription_schemas import (
    CancelSubscriptionRequest,
    CheckoutRequest,
    CheckoutResponse,
    SubscriptionUpdateRequest,
)
from services.payment_service import PaymentService
from services.user_service import UserService

logger = logging.getLogger(__name__)

# Standard tier role names mapped to lower-case subscription tier codes
TIER_ROLE_NAME_MAP = {
    "normal": "Normal",
    "pro": "Pro",
    "ultra": "Ultra",
}


class SubscriptionService:
    """Service layer for subscription operations."""

    @staticmethod
    async def get_subscription_by_user_id(db: AsyncSession, user_id: str) -> Subscription:
        """
        Retrieve a user's subscription record. Creates default 'normal' tier if none exists.
        """
        stmt = select(Subscription).where(Subscription.user_id == user_id)
        res = await db.execute(stmt)
        sub = res.scalar_one_or_none()
        if sub is None:
            # Auto-create free tier subscription for existing user
            sub = Subscription(
                user_id=user_id,
                tier="normal",
                status="active",
                billing_cycle="monthly",
                price_amount=0.0,
                gateway_provider="sandbox",
            )
            db.add(sub)
            await db.commit()
            await db.refresh(sub)
        return sub

    @staticmethod
    async def process_checkout_and_upgrade(
        db: AsyncSession, user_id: str, dto: CheckoutRequest
    ) -> CheckoutResponse:
        """
        Processes checkout payment via requested gateway provider (Paddle/Sandbox/Razorpay),
        records PaymentTransaction in ledger, updates user subscription, and syncs database Role.
        """
        user = await UserService.get_user_by_id(db, user_id)
        target_tier = dto.tier.lower().strip()

        if target_tier not in TIER_ROLE_NAME_MAP:
            raise BadRequestException(
                error_code="INVALID_TIER",
                errors=f"Invalid target tier '{dto.tier}'. Must be 'pro' or 'ultra'.",
            )

        # 1. Compute price after coupon validation
        coupon_res = PaymentService.validate_coupon(dto.coupon_code, target_tier, dto.billing_cycle)
        if dto.coupon_code and not coupon_res["valid"]:
            raise BadRequestException(
                error_code="INVALID_COUPON",
                errors=str(coupon_res["message"]),
            )

        final_amount = float(coupon_res["final_price"])

        # 2. Select Payment Provider & execute checkout session/payment
        provider_name = dto.gateway_provider.lower().strip()
        provider = PaymentService.get_provider(provider_name)

        checkout_res = await provider.create_checkout_session(
            user_id=user_id,
            user_email=user.email,
            tier=target_tier,
            billing_cycle=dto.billing_cycle,
            amount=final_amount,
            currency="USD",
            coupon_code=dto.coupon_code,
            extra_data={
                "card_number": dto.card_number,
                "exp_month": dto.exp_month,
                "exp_year": dto.exp_year,
                "cvc": dto.cvc,
            },
        )

        if not checkout_res.get("success"):
            err_msg = str(checkout_res.get("message", "Payment processing failed."))
            raise BadRequestException(error_code="PAYMENT_FAILED", errors=err_msg)

        # 3. Expiry Calculation: Monthly (30d) vs Annual (365d)
        now = datetime.now(timezone.utc).replace(tzinfo=None)
        days = 365 if dto.billing_cycle.lower() == "annual" else 30
        period_end = now + timedelta(days=days)

        # 4. Get or Create Subscription Record
        sub_stmt = select(Subscription).where(Subscription.user_id == user_id)
        sub_res = await db.execute(sub_stmt)
        sub = sub_res.scalar_one_or_none()

        txn_id = str(checkout_res.get("transaction_id", f"txn_{now.timestamp()}"))

        if sub is None:
            sub = Subscription(
                user_id=user_id,
                tier=target_tier,
                status="active",
                billing_cycle=dto.billing_cycle,
                price_amount=final_amount,
                current_period_start=now,
                current_period_end=period_end,
                gateway_provider=provider.provider_name,
                gateway_subscription_id=checkout_res.get("gateway_subscription_id"),
                gateway_customer_id=checkout_res.get("gateway_customer_id"),
                payment_gateway_ref=txn_id,
                auto_renew=True,
                cancel_at_period_end=False,
            )
            db.add(sub)
        else:
            sub.tier = target_tier
            sub.status = "active"
            sub.billing_cycle = dto.billing_cycle
            sub.price_amount = final_amount
            sub.current_period_start = now
            sub.current_period_end = period_end
            sub.gateway_provider = provider.provider_name
            if checkout_res.get("gateway_subscription_id"):
                sub.gateway_subscription_id = checkout_res.get("gateway_subscription_id")
            if checkout_res.get("gateway_customer_id"):
                sub.gateway_customer_id = checkout_res.get("gateway_customer_id")
            sub.payment_gateway_ref = txn_id
            sub.auto_renew = True
            sub.cancel_at_period_end = False

        # 5. Log Payment Transaction
        txn = PaymentTransaction(
            transaction_id=txn_id,
            user_id=user_id,
            gateway_provider=provider.provider_name,
            amount=final_amount,
            currency="USD",
            status="completed",
            tier=target_tier,
            billing_cycle=dto.billing_cycle,
            payment_method=dto.gateway_provider.upper(),
            coupon_code=dto.coupon_code.upper() if dto.coupon_code else None,
            created_at=now,
        )
        db.add(txn)

        # 6. Synchronize Tier Role in DB
        await SubscriptionService._sync_user_role(db, user, target_tier)

        await db.commit()
        await db.refresh(sub)

        logger.info(
            f"Successfully upgraded user {user_id} to tier '{target_tier}' "
            f"via provider '{provider.provider_name}' (Txn: {txn_id})"
        )

        return CheckoutResponse(
            success=True,
            message=f"Subscription successfully upgraded to {target_tier.upper()}!",
            transaction_id=txn_id,
            tier=target_tier,
            billing_cycle=dto.billing_cycle,
            amount_paid=final_amount,
            currency="USD",
            gateway_provider=provider.provider_name,
            current_period_end=period_end,
            receipt_url=checkout_res.get("checkout_url"),
        )

    @staticmethod
    async def update_user_subscription_tier(
        db: AsyncSession, user_id: str, dto: SubscriptionUpdateRequest
    ) -> Subscription:
        """
        Direct tier update (for Admin manual management or internal webhooks).
        """
        user = await UserService.get_user_by_id(db, user_id)
        target_tier = dto.tier.lower().strip()

        if target_tier not in TIER_ROLE_NAME_MAP:
            raise BadRequestException(
                error_code="INVALID_SUBSCRIPTION_TIER",
                errors=f"Invalid tier '{dto.tier}'. Must be one of {list(TIER_ROLE_NAME_MAP.keys())}.",
            )

        stmt = select(Subscription).where(Subscription.user_id == user_id)
        res = await db.execute(stmt)
        sub = res.scalar_one_or_none()

        if sub is None:
            sub = Subscription(
                user_id=user_id,
                tier=target_tier,
                status=dto.status,
                billing_cycle=dto.billing_cycle,
                gateway_provider=dto.gateway_provider or "sandbox",
                current_period_end=dto.current_period_end,
                payment_gateway_ref=dto.payment_gateway_ref,
            )
            db.add(sub)
        else:
            sub.tier = target_tier
            sub.status = dto.status
            sub.billing_cycle = dto.billing_cycle
            if dto.gateway_provider:
                sub.gateway_provider = dto.gateway_provider
            if dto.current_period_end is not None:
                sub.current_period_end = dto.current_period_end
            if dto.payment_gateway_ref is not None:
                sub.payment_gateway_ref = dto.payment_gateway_ref

        await SubscriptionService._sync_user_role(db, user, target_tier)
        await db.commit()
        await db.refresh(sub)
        return sub

    @staticmethod
    async def cancel_user_subscription(
        db: AsyncSession, user_id: str, dto: CancelSubscriptionRequest
    ) -> Subscription:
        """
        Cancels subscription auto-renew or immediately downgrades to Free.
        """
        sub = await SubscriptionService.get_subscription_by_user_id(db, user_id)

        if sub.tier == "normal":
            raise BadRequestException(
                error_code="CANNOT_CANCEL_FREE",
                errors="User is already on the Free tier.",
            )

        # Notify Provider if gateway subscription exists
        if sub.gateway_subscription_id and sub.gateway_provider:
            provider = PaymentService.get_provider(sub.gateway_provider)
            await provider.cancel_subscription(sub.gateway_subscription_id, immediate=dto.immediate)

        if dto.immediate:
            sub.tier = "normal"
            sub.status = "canceled"
            sub.auto_renew = False
            sub.cancel_at_period_end = False
            user = await UserService.get_user_by_id(db, user_id)
            await SubscriptionService._sync_user_role(db, user, "normal")
        else:
            sub.cancel_at_period_end = True
            sub.auto_renew = False

        await db.commit()
        await db.refresh(sub)
        return sub

    @staticmethod
    async def get_user_transactions(
        db: AsyncSession, user_id: str
    ) -> List[PaymentTransaction]:
        """
        Returns all payment transactions for a specific user.
        """
        stmt = (
            select(PaymentTransaction)
            .where(PaymentTransaction.user_id == user_id)
            .order_by(PaymentTransaction.created_at.desc())
        )
        res = await db.execute(stmt)
        return list(res.scalars().all())

    @staticmethod
    async def _sync_user_role(db: AsyncSession, user: User, target_tier: str) -> None:
        """Helper to sync DB roles (Normal, Pro, Ultra) for a User entity."""
        target_role_name = TIER_ROLE_NAME_MAP[target_tier.lower()]
        r_stmt = select(Role).where(Role.name == target_role_name, Role.retired == False)
        r_res = await db.execute(r_stmt)
        target_role = r_res.scalar_one_or_none()

        tier_role_names = set(TIER_ROLE_NAME_MAP.values())
        non_tier_roles = [r for r in user.roles if r.name not in tier_role_names]

        if target_role:
            user.roles = non_tier_roles + [target_role]
        else:
            user.roles = non_tier_roles
            logger.warning(f"Target role '{target_role_name}' not found in DB during role sync.")
