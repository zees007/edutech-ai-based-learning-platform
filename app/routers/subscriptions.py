"""
EduTechAI — Subscription Management REST Router

API endpoints for managing user subscription tiers, multi-gateway payments,
coupons, ledger history, and cancellations.
"""

from __future__ import annotations

from typing import List

from fastapi import APIRouter, Depends, Header, Request
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies import get_current_user, require_privilege
from app.privileges_config import (
    ET_DOWNGRADE_SUBSCRIPTION,
    ET_UPGRADE_SUBSCRIPTION,
    ET_VIEW_SUBSCRIPTION,
)
from models.db_models import User
from models.subscription_schemas import (
    CancelSubscriptionRequest,
    CheckoutRequest,
    CheckoutResponse,
    CouponValidateRequest,
    CouponValidateResponse,
    PaymentTransactionResponse,
    SubscriptionResponse,
    SubscriptionUpdateRequest,
)
from services.database import get_db
from services.payment_service import PaymentService
from services.subscription_service import SubscriptionService

router = APIRouter()


@router.get(
    "/subscriptions/users/{user_id}",
    response_model=SubscriptionResponse,
    dependencies=[Depends(require_privilege(ET_VIEW_SUBSCRIPTION))],
)
async def get_user_subscription(
    user_id: str,
    db: AsyncSession = Depends(get_db),
):
    """Retrieve active subscription details for a user."""
    sub = await SubscriptionService.get_subscription_by_user_id(db, user_id)
    return SubscriptionResponse.model_validate(sub)


@router.put(
    "/subscriptions/users/{user_id}/tier",
    response_model=SubscriptionResponse,
    dependencies=[Depends(require_privilege(ET_UPGRADE_SUBSCRIPTION, ET_DOWNGRADE_SUBSCRIPTION))],
)
async def update_user_subscription_tier(
    user_id: str,
    request: SubscriptionUpdateRequest,
    db: AsyncSession = Depends(get_db),
):
    """
    Directly upgrade or downgrade a user's subscription tier (normal, pro, ultra).
    Automatically updates the user's assigned role in the database.
    """
    sub = await SubscriptionService.update_user_subscription_tier(db, user_id, request)
    return SubscriptionResponse.model_validate(sub)


@router.post(
    "/subscriptions/checkout",
    response_model=CheckoutResponse,
)
async def checkout_subscription(
    request: CheckoutRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Initiate or complete subscription upgrade via requested gateway (Paddle, Sandbox, Razorpay).
    """
    return await SubscriptionService.process_checkout_and_upgrade(
        db=db, user_id=current_user.id, dto=request
    )


@router.post(
    "/subscriptions/validate-coupon",
    response_model=CouponValidateResponse,
)
async def validate_coupon(
    request: CouponValidateRequest,
):
    """Validate a promotional coupon code and calculate discounted pricing."""
    res = PaymentService.validate_coupon(
        coupon_code=request.coupon_code,
        tier=request.tier,
        billing_cycle=request.billing_cycle,
    )
    return CouponValidateResponse(
        valid=bool(res["valid"]),
        coupon_code=str(res["coupon_code"]),
        discount_percent=float(res["discount_percent"]),
        discount_amount=float(res["discount_amount"]),
        original_price=float(res["original_price"]),
        final_price=float(res["final_price"]),
        message=str(res["message"]),
    )


@router.get(
    "/subscriptions/users/{user_id}/transactions",
    response_model=List[PaymentTransactionResponse],
    dependencies=[Depends(require_privilege(ET_VIEW_SUBSCRIPTION))],
)
async def get_user_transactions(
    user_id: str,
    db: AsyncSession = Depends(get_db),
):
    """Get payment transaction history for a specific user."""
    txns = await SubscriptionService.get_user_transactions(db, user_id)
    return [PaymentTransactionResponse.model_validate(t) for t in txns]


@router.post(
    "/subscriptions/users/{user_id}/cancel",
    response_model=SubscriptionResponse,
)
async def cancel_subscription(
    user_id: str,
    request: CancelSubscriptionRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Cancel subscription auto-renewal or downgrade user immediately."""
    sub = await SubscriptionService.cancel_user_subscription(db, user_id, request)
    return SubscriptionResponse.model_validate(sub)


@router.post(
    "/subscriptions/webhooks/{provider}",
)
async def handle_payment_webhook(
    provider: str,
    request: Request,
    db: AsyncSession = Depends(get_db),
):
    """
    Webhook endpoint for payment gateways (Paddle, Razorpay, etc.).
    """
    p_instance = PaymentService.get_provider(provider)
    raw_body = await request.body()
    sig_header = request.headers.get("paddle-signature") or request.headers.get("x-razorpay-signature") or ""

    is_valid = await p_instance.verify_webhook_signature(raw_body, sig_header)
    if not is_valid:
        return {"status": "error", "message": "Invalid webhook signature."}

    payload_json = await request.json()
    event_data = await p_instance.parse_webhook_event(payload_json)

    if event_data.get("event_type") == "payment_success" and event_data.get("user_id"):
        tier = str(event_data.get("tier", "pro"))
        cycle = str(event_data.get("billing_cycle", "monthly"))
        sub_req = SubscriptionUpdateRequest(
            tier=tier,
            status="active",
            billing_cycle=cycle,
            gateway_provider=provider,
            payment_gateway_ref=str(event_data.get("transaction_id", "")),
        )
        await SubscriptionService.update_user_subscription_tier(db, event_data["user_id"], sub_req)

    return {"status": "ok", "provider": provider}
