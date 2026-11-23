"""
EduTechAI — Subscription Pydantic Schemas (DTOs)

Request and response models for subscription management endpoints.
"""

from __future__ import annotations

from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class SubscriptionResponse(BaseModel):
    """API response model for user subscription status."""

    id: int
    user_id: str
    tier: str = Field(..., description="Subscription tier slug: free, pro, ultra or custom")
    tier_id: str | None = Field(default=None, description="Bound subscription tier UUID")
    status: str = Field(..., description="Subscription status: active, canceled, expired, past_due")
    billing_cycle: str = Field(default="monthly", description="Billing cycle: monthly, annual")
    price_amount: float = Field(default=0.0, description="Current tier recurring price")
    current_period_start: datetime
    current_period_end: datetime | None = None
    gateway_provider: str = Field(default="razorpay", description="Payment provider: razorpay")
    gateway_subscription_id: str | None = None
    gateway_customer_id: str | None = None
    payment_gateway_ref: str | None = None
    cancel_at_period_end: bool = False
    auto_renew: bool = True

    model_config = ConfigDict(from_attributes=True)


class SubscriptionUpdateRequest(BaseModel):
    """Payload for updating/upgrading a user's subscription tier directly."""

    tier: str = Field(..., description="Target subscription tier: free, pro, ultra")
    status: str = Field(default="active", description="Status of subscription: active, canceled, expired")
    billing_cycle: str = Field(default="monthly", description="Billing cycle: monthly, annual")
    gateway_provider: str | None = Field(default="razorpay", description="Payment gateway code")
    current_period_end: datetime | None = Field(default=None, description="Expiration date of subscription")
    payment_gateway_ref: str | None = Field(default=None, description="Payment processor reference ID")


class CreateOrderRequest(BaseModel):
    """Payload to initiate a payment order with the gateway (Razorpay)."""

    tier: str = Field(..., description="Target subscription tier: pro, ultra")
    billing_cycle: str = Field(default="monthly", description="Billing cycle: monthly, annual")
    gateway_provider: str = Field(default="razorpay", description="Payment provider: razorpay")
    coupon_code: str | None = Field(default=None, description="Promotional coupon code")
    currency: str = Field(default="USD", description="Currency code (USD)")


class CreateOrderResponse(BaseModel):
    """Order initialization result for client-side checkout popup."""

    success: bool
    order_id: str
    key_id: str
    amount: float
    amount_subunits: int
    currency: str
    tier: str
    billing_cycle: str
    gateway_provider: str
    user_name: str | None = None
    user_email: str | None = None
    user_mobile: str | None = None
    message: str | None = None


class CheckoutRequest(BaseModel):
    """Payload to initiate or complete a subscription upgrade checkout."""

    tier: str = Field(..., description="Target subscription tier: pro, ultra")
    billing_cycle: str = Field(default="monthly", description="Billing cycle: monthly, annual")
    gateway_provider: str = Field(default="razorpay", description="Payment provider: razorpay")
    coupon_code: str | None = Field(default=None, description="Promotional coupon code")
    currency: str = Field(default="USD", description="Payment currency: USD")
    # Razorpay payment verification fields
    razorpay_order_id: str | None = Field(default=None, description="Razorpay order reference ID")
    razorpay_payment_id: str | None = Field(default=None, description="Razorpay payment transaction ID")
    razorpay_signature: str | None = Field(default=None, description="Razorpay HMAC SHA256 payment signature")


class CheckoutResponse(BaseModel):
    """Result payload from checkout process."""

    success: bool
    message: str
    transaction_id: str | None = None
    tier: str
    billing_cycle: str
    amount_paid: float
    currency: str = "USD"
    gateway_provider: str
    current_period_end: datetime | None = None
    receipt_url: str | None = None
    order_id: str | None = None
    key_id: str | None = None


class CouponValidateRequest(BaseModel):
    """Payload to validate a discount coupon."""

    coupon_code: str
    tier: str
    billing_cycle: str = "monthly"


class CouponValidateResponse(BaseModel):
    """Validation response for coupon code."""

    valid: bool
    coupon_code: str
    discount_percent: float = 0.0
    discount_amount: float = 0.0
    original_price: float = 0.0
    final_price: float = 0.0
    message: str


class PaymentTransactionResponse(BaseModel):
    """Response DTO for ledger transaction records."""

    id: int
    transaction_id: str
    user_id: str
    gateway_provider: str
    amount: float
    currency: str
    status: str
    tier: str
    billing_cycle: str
    payment_method: str | None = None
    coupon_code: str | None = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class CancelSubscriptionRequest(BaseModel):
    """Payload for canceling or resuming subscription auto-renew."""

    reason: str | None = None
    immediate: bool = False


class TierPriceInfo(BaseModel):
    """Price amounts for monthly and annual billing cycles."""

    monthly: float
    annual: float


class PromoBannerInfo(BaseModel):
    """Promotional announcement banner configuration."""

    enabled: bool = False
    text: str = ""
    coupon_code: str = ""
    discount_percent: float = 0.0
    valid_until: str | None = None
    is_expired: bool = False


class PricingCatalogResponse(BaseModel):
    """Public catalog response of all available tier prices and promotional campaign banner."""

    currency: str = "USD"
    tiers: dict[str, TierPriceInfo]
    promo_banner: PromoBannerInfo | None = None


# ─── Dynamic Subscription Tier Schemas ───────────────────────────────

class SubscriptionTierResponse(BaseModel):
    """DTO for a dynamic subscription tier record."""

    id: str
    slug: str
    name: str
    description: str | None = None
    role_id: str
    role_name: str | None = None
    price_monthly: float = 0.0
    price_annual: float = 0.0
    currency: str = "USD"
    monthly_session_limit: int | None = None
    follow_up_limit_per_step: int | None = None
    youtube_limit_per_step: int | None = None
    streak_multiplier: float = 1.0
    is_public: bool = True
    order_index: int = 0
    retired: bool = False
    created_at: datetime
    active_subscribers_count: int = 0

    model_config = ConfigDict(from_attributes=True)


class SubscriptionTierCreateRequest(BaseModel):
    """Payload to create a new dynamic subscription tier."""

    slug: str = Field(..., min_length=2, max_length=50, description="Unique slug identifier (e.g. 'enterprise')")
    name: str = Field(..., min_length=2, max_length=100, description="Human readable display name")
    description: str | None = None
    role_id: str = Field(..., description="ID of the Role to bind to this tier")
    price_monthly: float = Field(default=0.0, ge=0.0)
    price_annual: float = Field(default=0.0, ge=0.0)
    currency: str = Field(default="USD", max_length=10)
    monthly_session_limit: int | None = Field(default=None, description="Monthly AI session limit (null = unlimited)")
    follow_up_limit_per_step: int | None = Field(default=None, description="Max follow-up chat turns per step (null = unlimited)")
    youtube_limit_per_step: int | None = Field(default=None, description="Max curated videos per step (null = unlimited)")
    streak_multiplier: float = Field(default=1.0, ge=1.0, le=5.0, description="Streak XP multiplier (e.g. 1.0, 1.5, 2.0)")
    is_public: bool = Field(default=True, description="Whether visible on landing/pricing catalog")
    order_index: int = Field(default=0, description="Display order sequence")


class SubscriptionTierUpdateRequest(BaseModel):
    """Payload to update an existing subscription tier."""

    name: str | None = None
    description: str | None = None
    role_id: str | None = None
    price_monthly: float | None = None
    price_annual: float | None = None
    currency: str | None = None
    monthly_session_limit: int | None = None
    follow_up_limit_per_step: int | None = None
    youtube_limit_per_step: int | None = None
    streak_multiplier: float | None = Field(default=None, ge=1.0, le=5.0)
    is_public: bool | None = None
    order_index: int | None = None
