"""
EduTechAI — Payment Service (Razorpay Integration)

Handles Razorpay REST APIs (Order creation, Subscriptions, Webhook verification),
cryptographic signature verification, coupon discounts, and dynamic pricing calculation.
Includes built-in local development / mock support when API keys are not configured.
"""

from __future__ import annotations

import hashlib
import hmac
import logging
import os
import uuid
from typing import Any, Dict, Optional

import httpx

from app.exceptions import BadRequestException
from services.setting_service import SettingService

logger = logging.getLogger(__name__)


class PaymentService:
    """Unified Payment Service powered by Razorpay."""

    _instance: Optional[PaymentService] = None

    def __init__(self):
        self.key_id = os.getenv("RAZORPAY_KEY_ID", "").strip()
        self.key_secret = os.getenv("RAZORPAY_KEY_SECRET", "").strip()
        self.webhook_secret = os.getenv("RAZORPAY_WEBHOOK_SECRET", "").strip()
        self.api_base_url = "https://api.razorpay.com/v1"

    @classmethod
    def get_instance(cls) -> PaymentService:
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance

    @classmethod
    def get_provider(cls, provider_name: Optional[str] = None) -> PaymentService:
        """Returns the active Razorpay payment provider instance."""
        return cls.get_instance()

    @property
    def provider_name(self) -> str:
        return "razorpay"

    def has_live_credentials(self) -> bool:
        """Returns True if valid live/test API keys are configured."""
        return bool(self.key_id and self.key_secret)

    # ─────────────────────────────────────────────────────────────────────────
    # Pricing Catalog & Promotional Coupon Logic
    # ─────────────────────────────────────────────────────────────────────────

    @staticmethod
    def get_plan_price(tier: str, billing_cycle: str = "monthly") -> float:
        """Returns standard catalog price for a tier and billing cycle dynamically from settings."""
        tier_key = tier.lower().strip()
        cycle_key = billing_cycle.lower().strip()
        catalog = SettingService.get_pricing_catalog()

        if tier_key not in catalog:
            raise BadRequestException(
                error_code="INVALID_TIER",
                errors=f"Invalid tier '{tier}'. Must be one of {list(catalog.keys())}.",
            )

        if cycle_key not in ["monthly", "annual"]:
            cycle_key = "monthly"

        return catalog[tier_key][cycle_key]

    @staticmethod
    def validate_coupon(
        coupon_code: Optional[str], tier: str, billing_cycle: str = "monthly"
    ) -> Dict[str, float | str | bool]:
        """Validates a promotional coupon code and computes final price dynamically from settings."""
        base_price = PaymentService.get_plan_price(tier, billing_cycle)
        if not coupon_code:
            return {
                "valid": True,
                "coupon_code": "",
                "discount_percent": 0.0,
                "discount_amount": 0.0,
                "original_price": base_price,
                "final_price": base_price,
                "message": "No coupon applied.",
            }

        code_clean = coupon_code.upper().strip()
        valid_coupons = SettingService.get_valid_coupons()
        if code_clean not in valid_coupons:
            return {
                "valid": False,
                "coupon_code": code_clean,
                "discount_percent": 0.0,
                "discount_amount": 0.0,
                "original_price": base_price,
                "final_price": base_price,
                "message": f"Invalid coupon code '{code_clean}'.",
            }

        if SettingService.is_promo_coupon_expired(code_clean):
            return {
                "valid": False,
                "coupon_code": code_clean,
                "discount_percent": 0.0,
                "discount_amount": 0.0,
                "original_price": base_price,
                "final_price": base_price,
                "message": f"The promotional offer for coupon '{code_clean}' has expired.",
            }

        pct = valid_coupons[code_clean]
        discount_amount = round(base_price * (pct / 100.0), 2)
        final_price = max(0.0, round(base_price - discount_amount, 2))

        return {
            "valid": True,
            "coupon_code": code_clean,
            "discount_percent": pct,
            "discount_amount": discount_amount,
            "original_price": base_price,
            "final_price": final_price,
            "message": f"Coupon '{code_clean}' applied! Saved {pct:.0f}% (${discount_amount:.2f}).",
        }

    # ─────────────────────────────────────────────────────────────────────────
    # Razorpay Order Creation & Session Management
    # ─────────────────────────────────────────────────────────────────────────

    async def create_checkout_session(
        self,
        user_id: str,
        user_email: str,
        tier: str,
        billing_cycle: str,
        amount: float,
        currency: str = "USD",
        coupon_code: Optional[str] = None,
        extra_data: Optional[Dict[str, Any]] = None,
    ) -> Dict[str, Any]:
        """
        Creates a Razorpay Order via REST API (or dev mock if credentials are absent).
        Returns transaction details, order_id, key_id, and checkout parameters.
        """
        extra_data = extra_data or {}
        currency = currency.upper().strip() if currency else "USD"
        # Razorpay expects amounts in smallest currency sub-units (e.g. cents)
        amount_subunits = int(round(amount * 100))

        if not self.has_live_credentials():
            order_id = f"order_mock_{uuid.uuid4().hex[:14]}"
            logger.info(
                f"[PaymentService] (Dev/Mock Mode) Order created: order_id={order_id}, "
                f"user={user_id}, tier={tier}, amount={amount} {currency}"
            )
            return {
                "success": True,
                "provider": "razorpay",
                "order_id": order_id,
                "transaction_id": order_id,
                "key_id": self.key_id or "rzp_test_mock_key",
                "amount": amount,
                "amount_subunits": amount_subunits,
                "currency": currency,
                "tier": tier,
                "billing_cycle": billing_cycle,
                "checkout_url": f"https://checkout.razorpay.com/v1/checkout.js?order_id={order_id}",
                "message": "Razorpay dev order created successfully.",
            }

        # Real Razorpay Orders API call
        receipt_id = f"rcpt_{uuid.uuid4().hex[:12]}"
        payload = {
            "amount": amount_subunits,
            "currency": currency,
            "receipt": receipt_id,
            "notes": {
                "user_id": str(user_id),
                "user_email": str(user_email),
                "tier": str(tier),
                "billing_cycle": str(billing_cycle),
                "coupon_code": str(coupon_code or ""),
            },
        }

        try:
            async with httpx.AsyncClient(timeout=15.0) as client:
                res = await client.post(
                    f"{self.api_base_url}/orders",
                    auth=(self.key_id, self.key_secret),
                    json=payload,
                )

                if res.status_code in (200, 201):
                    order_data = res.json()
                    order_id = order_data.get("id")
                    logger.info(
                        f"[PaymentService] Live order created successfully: order_id={order_id}, "
                        f"amount={amount} {currency}"
                    )
                    return {
                        "success": True,
                        "provider": "razorpay",
                        "order_id": order_id,
                        "transaction_id": order_id,
                        "key_id": self.key_id,
                        "amount": amount,
                        "amount_subunits": amount_subunits,
                        "currency": currency,
                        "tier": tier,
                        "billing_cycle": billing_cycle,
                        "checkout_url": f"https://checkout.razorpay.com/v1/checkout.js?order_id={order_id}",
                        "message": "Razorpay order created successfully.",
                    }
                else:
                    err_msg = res.text
                    logger.error(f"[PaymentService] Failed to create order: {res.status_code} - {err_msg}")
                    raise BadRequestException(
                        error_code="GATEWAY_ERROR",
                        errors=f"Razorpay order creation failed: {err_msg}",
                    )
        except httpx.RequestError as exc:
            logger.error(f"[PaymentService] Network error connecting to Razorpay: {exc}")
            raise BadRequestException(
                error_code="GATEWAY_TIMEOUT",
                errors=f"Could not connect to Razorpay payment gateway: {str(exc)}",
            )

    # ─────────────────────────────────────────────────────────────────────────
    # Cryptographic Signature Verification
    # ─────────────────────────────────────────────────────────────────────────

    def verify_payment_signature(
        self,
        razorpay_order_id: str,
        razorpay_payment_id: str,
        razorpay_signature: str,
    ) -> bool:
        """
        Verifies Razorpay HMAC SHA256 payment signature.
        Formula: HMAC-SHA256(order_id + "|" + payment_id, key_secret) == signature
        """
        if not self.key_secret:
            logger.warning("[PaymentService] RAZORPAY_KEY_SECRET missing. Dev signature verified.")
            return True

        if not razorpay_order_id or not razorpay_payment_id or not razorpay_signature:
            return False

        message = f"{razorpay_order_id}|{razorpay_payment_id}".encode("utf-8")
        generated_signature = hmac.new(
            self.key_secret.encode("utf-8"),
            message,
            hashlib.sha256,
        ).hexdigest()

        return hmac.compare_digest(generated_signature, razorpay_signature)

    async def verify_webhook_signature(
        self, payload: bytes, signature_header: str
    ) -> bool:
        """Verifies Razorpay Webhook HMAC SHA256 signature."""
        secret = self.webhook_secret or self.key_secret
        if not secret:
            logger.warning("[PaymentService] No webhook secret configured. Dev signature approved.")
            return True

        if not signature_header:
            return False

        expected = hmac.new(
            secret.encode("utf-8"),
            payload,
            hashlib.sha256,
        ).hexdigest()

        return hmac.compare_digest(expected, signature_header)

    async def parse_webhook_event(
        self, payload_dict: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Parses Razorpay webhook event payloads."""
        event_type = payload_dict.get("event", "")
        payload = payload_dict.get("payload", {})
        payment_entity = payload.get("payment", {}).get("entity", {})
        order_entity = payload.get("order", {}).get("entity", {})

        notes = payment_entity.get("notes") or order_entity.get("notes") or {}

        # Determine standardized event type
        is_success = "captured" in event_type or "order.paid" in event_type or "subscription.charged" in event_type
        is_canceled = "subscription.cancelled" in event_type or "subscription.halted" in event_type

        status_str = "payment_success" if is_success else ("subscription_canceled" if is_canceled else "unknown")

        return {
            "event_type": status_str,
            "user_id": notes.get("user_id", ""),
            "transaction_id": payment_entity.get("id") or order_entity.get("id", f"rzp_{uuid.uuid4().hex[:8]}"),
            "gateway_subscription_id": payment_entity.get("subscription_id") or order_entity.get("id", ""),
            "gateway_customer_id": payment_entity.get("customer_id", ""),
            "tier": notes.get("tier", "pro"),
            "billing_cycle": notes.get("billing_cycle", "monthly"),
            "amount": float(payment_entity.get("amount", order_entity.get("amount", 0))) / 100.0,
            "currency": payment_entity.get("currency", "USD"),
            "raw_event": event_type,
        }

    async def cancel_subscription(
        self, gateway_subscription_id: str, immediate: bool = False
    ) -> bool:
        """Cancels a Razorpay subscription via API if configured."""
        if self.has_live_credentials() and gateway_subscription_id.startswith("sub_"):
            try:
                async with httpx.AsyncClient(timeout=10.0) as client:
                    await client.post(
                        f"{self.api_base_url}/subscriptions/{gateway_subscription_id}/cancel",
                        auth=(self.key_id, self.key_secret),
                        json={"cancel_at_cycle_end": 0 if immediate else 1},
                    )
            except Exception as e:
                logger.error(f"[PaymentService] Failed to cancel remote subscription: {e}")
        logger.info(f"[PaymentService] Subscription {gateway_subscription_id} canceled.")
        return True


# Backward-compatible aliases
RazorpayPaymentProvider = PaymentService
BasePaymentProvider = PaymentService
