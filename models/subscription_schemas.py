"""
EduTechAI — Subscription Pydantic Schemas (DTOs)

Request and response models for subscription management endpoints.
"""

from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class SubscriptionResponse(BaseModel):
    """API response model for user subscription status."""

    id: int
    user_id: str
    tier: str = Field(..., description="Subscription tier: normal, pro, ultra")
    status: str = Field(..., description="Subscription status: active, canceled, expired, past_due")
    current_period_start: datetime
    current_period_end: datetime | None = None
    payment_gateway_ref: str | None = None

    model_config = ConfigDict(from_attributes=True)


class SubscriptionUpdateRequest(BaseModel):
    """Payload for updating/upgrading a user's subscription tier."""

    tier: str = Field(..., description="Target subscription tier: normal, pro, ultra")
    status: str = Field(default="active", description="Status of subscription: active, canceled, expired")
    current_period_end: datetime | None = Field(default=None, description="Expiration date of subscription")
    payment_gateway_ref: str | None = Field(default=None, description="Payment processor reference ID")
