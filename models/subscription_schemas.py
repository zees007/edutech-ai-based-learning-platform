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
    billing_cycle: str = Field(default="monthly", description="Billing cycle: monthly, annual")
    price_amount: float = Field(default=0.0, description="Current tier recurring price")
    current_period_start: datetime
    current_period_end: datetime | None = None
    gateway_provider: str = Field(default="sandbox", description="Payment provider: paddle, razorpay, sandbox")
    gateway_subscription_id: str | None = None
    gateway_customer_id: str | None = None
    payment_gateway_ref: str | None = None
    cancel_at_period_end: bool = False
    auto_renew: bool = True

    model_config = ConfigDict(from_attributes=True)


class SubscriptionUpdateRequest(BaseModel):
    """Payload for updating/upgrading a user's subscription tier directly."""

    tier: str = Field(..., description="Target subscription tier: normal, pro, ultra")
    status: str = Field(default="active", description="Status of subscription: active, canceled, expired")
    billing_cycle: str = Field(default="monthly", description="Billing cycle: monthly, annual")
    gateway_provider: str | None = Field(default="sandbox", description="Payment gateway code")
    current_period_end: datetime | None = Field(default=None, description="Expiration date of subscription")
    payment_gateway_ref: str | None = Field(default=None, description="Payment processor reference ID")


class CheckoutRequest(BaseModel):
    """Payload to initiate or complete a subscription upgrade checkout."""

    tier: str = Field(..., description="Target subscription tier: pro, ultra")
    billing_cycle: str = Field(default="monthly", description="Billing cycle: monthly, annual")
    gateway_provider: str = Field(default="paddle", description="Selected provider: paddle, razorpay, sandbox")
    coupon_code: str | None = Field(default=None, description="Promotional coupon code")
    card_number: str | None = Field(default=None, description="Card number (Sandbox test mode)")
    exp_month: int | None = Field(default=None, description="Expiry month")
    exp_year: int | None = Field(default=None, description="Expiry year")
    cvc: str | None = Field(default=None, description="CVC code")


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

