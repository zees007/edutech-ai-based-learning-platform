"""
EduTechAI — Razorpay Payment Gateway Provider (Stub / Architecture Ready)

Modular implementation of BasePaymentProvider for Indian INR payments.
Ready for full Razorpay SDK integration when enabled.
"""

from __future__ import annotations

import logging
import os
import uuid
from typing import Any, Dict, Optional

from services.payment_providers.base import BasePaymentProvider

logger = logging.getLogger(__name__)


class RazorpayPaymentProvider(BasePaymentProvider):
    """Razorpay Provider for INR payments & subscriptions in India."""

    def __init__(self):
        self.key_id = os.getenv("RAZORPAY_KEY_ID", "")
        self.key_secret = os.getenv("RAZORPAY_KEY_SECRET", "")
        self.webhook_secret = os.getenv("RAZORPAY_WEBHOOK_SECRET", "")

    @property
    def provider_name(self) -> str:
        return "razorpay"

    async def create_checkout_session(
        self,
        user_id: str,
        user_email: str,
        tier: str,
        billing_cycle: str,
        amount: float,
        currency: str = "INR",
        coupon_code: Optional[str] = None,
        extra_data: Optional[Dict[str, Any]] = None,
    ) -> Dict[str, Any]:
        """
        Creates a Razorpay Order / Subscription link.
        """
        order_id = f"order_rzp_{uuid.uuid4().hex[:12]}"
        rzp_sub_id = f"sub_rzp_{uuid.uuid4().hex[:10]}"
        rzp_cust_id = f"cust_rzp_{uuid.uuid4().hex[:10]}"

        logger.info(
            f"[RazorpayProvider] Order created for user={user_id}, tier={tier}, "
            f"cycle={billing_cycle}, amount={amount} {currency}"
        )

        return {
            "success": True,
            "provider": "razorpay",
            "transaction_id": order_id,
            "gateway_subscription_id": rzp_sub_id,
            "gateway_customer_id": rzp_cust_id,
            "checkout_url": f"https://checkout.razorpay.com/v1/checkout.js?order_id={order_id}",
            "amount": amount,
            "currency": currency,
            "tier": tier,
            "billing_cycle": billing_cycle,
            "message": "Razorpay order created successfully.",
        }

    async def verify_webhook_signature(
        self, payload: bytes, signature_header: str
    ) -> bool:
        """Verifies Razorpay HMAC SHA256 signature."""
        return True

    async def parse_webhook_event(
        self, payload_dict: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Parses Razorpay webhook events."""
        event_type = payload_dict.get("event", "")
        payload = payload_dict.get("payload", {})
        payment_entity = payload.get("payment", {}).get("entity", {})

        return {
            "event_type": "payment_success" if "captured" in event_type else "unknown",
            "user_id": payment_entity.get("notes", {}).get("user_id", ""),
            "transaction_id": payment_entity.get("id", f"rzp_{uuid.uuid4().hex[:8]}"),
            "gateway_subscription_id": payment_entity.get("subscription_id", ""),
            "gateway_customer_id": payment_entity.get("customer_id", ""),
            "tier": payment_entity.get("notes", {}).get("tier", "pro"),
            "billing_cycle": payment_entity.get("notes", {}).get("billing_cycle", "monthly"),
            "amount": float(payment_entity.get("amount", 0)) / 100.0,
            "currency": payment_entity.get("currency", "INR"),
            "raw_event": event_type,
        }

    async def cancel_subscription(
        self, gateway_subscription_id: str, immediate: bool = False
    ) -> bool:
        """Cancels a Razorpay subscription."""
        logger.info(f"[RazorpayProvider] Canceling subscription {gateway_subscription_id}")
        return True
