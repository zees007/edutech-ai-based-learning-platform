"""
EduTechAI — Subscription Management REST Router

API endpoints for managing user subscription tiers:
- GET /api/v1/subscriptions/users/{user_id}      — Get user subscription
- PUT /api/v1/subscriptions/users/{user_id}/tier — Upgrade/downgrade user tier
"""

from __future__ import annotations

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from models.subscription_schemas import SubscriptionResponse, SubscriptionUpdateRequest
from services.database import get_db
from services.subscription_service import SubscriptionService

router = APIRouter()


@router.get("/subscriptions/users/{user_id}", response_model=SubscriptionResponse)
async def get_user_subscription(
    user_id: str,
    db: AsyncSession = Depends(get_db),
):
    """Retrieve active subscription details for a user."""
    sub = await SubscriptionService.get_subscription_by_user_id(db, user_id)
    return SubscriptionResponse.model_validate(sub)


@router.put("/subscriptions/users/{user_id}/tier", response_model=SubscriptionResponse)
async def update_user_subscription_tier(
    user_id: str,
    request: SubscriptionUpdateRequest,
    db: AsyncSession = Depends(get_db),
):
    """
    Upgrade or downgrade a user's subscription tier (normal, pro, ultra).
    Automatically updates the user's assigned role in the database.
    """
    sub = await SubscriptionService.update_user_subscription_tier(db, user_id, request)
    return SubscriptionResponse.model_validate(sub)
