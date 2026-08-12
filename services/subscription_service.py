"""
EduTechAI — Subscription Service Layer

Encapsulates business logic for subscription status management and automatic tier-role synchronization.
"""

from __future__ import annotations

import logging
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.exceptions import BadRequestException, NotFoundException
from models.db_models import Role, Subscription, User
from models.subscription_schemas import SubscriptionUpdateRequest
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
        Retrieve a user's subscription record. Raises NotFoundException if not found.
        """
        stmt = select(Subscription).where(Subscription.user_id == user_id)
        res = await db.execute(stmt)
        sub = res.scalar_one_or_none()
        if sub is None:
            raise NotFoundException(
                error_code="SUBSCRIPTION_NOT_FOUND",
                errors=f"Subscription for user ID '{user_id}' was not found.",
            )
        return sub

    @staticmethod
    async def update_user_subscription_tier(
        db: AsyncSession, user_id: str, dto: SubscriptionUpdateRequest
    ) -> Subscription:
        """
        Update a user's subscription tier and status. Automatically synchronizes
        tier-specific roles (Normal, Pro, Ultra) in user_roles.
        """
        user = await UserService.get_user_by_id(db, user_id)

        target_tier = dto.tier.lower().strip()
        if target_tier not in TIER_ROLE_NAME_MAP:
            valid_tiers = list(TIER_ROLE_NAME_MAP.keys())
            raise BadRequestException(
                error_code="INVALID_SUBSCRIPTION_TIER",
                errors=f"Invalid tier '{dto.tier}'. Must be one of {valid_tiers}.",
            )

        # Get existing subscription or create new
        stmt = select(Subscription).where(Subscription.user_id == user_id)
        res = await db.execute(stmt)
        sub = res.scalar_one_or_none()

        if sub is None:
            sub = Subscription(
                user_id=user_id,
                tier=target_tier,
                status=dto.status,
                current_period_end=dto.current_period_end,
                payment_gateway_ref=dto.payment_gateway_ref,
            )
            db.add(sub)
        else:
            sub.tier = target_tier
            sub.status = dto.status
            if dto.current_period_end is not None:
                sub.current_period_end = dto.current_period_end
            if dto.payment_gateway_ref is not None:
                sub.payment_gateway_ref = dto.payment_gateway_ref

        # Synchronize Tier Role in DB
        target_role_name = TIER_ROLE_NAME_MAP[target_tier]
        r_stmt = select(Role).where(Role.name == target_role_name, Role.retired == False)
        r_res = await db.execute(r_stmt)
        target_role = r_res.scalar_one_or_none()

        # Remove any existing tier roles (Normal, Pro, Ultra) from user.roles
        tier_role_names = set(TIER_ROLE_NAME_MAP.values())
        non_tier_roles = [r for r in user.roles if r.name not in tier_role_names]

        if target_role:
            user.roles = non_tier_roles + [target_role]
        else:
            user.roles = non_tier_roles
            logger.warning(f"Target role '{target_role_name}' not found in DB during subscription update.")

        await db.commit()
        await db.refresh(sub)
        logger.info(f"Subscription updated for user {user_id}: tier='{target_tier}', status='{dto.status}'")
        return sub
