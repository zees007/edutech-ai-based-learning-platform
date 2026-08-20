"""
EduTechAI — Sandbox Payment Gateway Provider Implementation

Simulates real-time credit card processing, coupon verification, and instant checkout
for testing and demo environments without needing live API keys.
"""

from __future__ import annotations

import logging
import uuid
from typing import Any, Dict, Optional

from services.payment_providers.base import BasePaymentProvider

logger = logging.getLogger(__name__)


class SandboxPaymentProvider(BasePaymentProvider):
    """Sandbox Test Provider."""

    @property
    def provider_name(self) -> str:
        return "sandbox"

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
        Simulates card validation & instant transaction completion.
        """
        extra_data = extra_data or {}
        card_num = str(extra_data.get("card_number", "")).replace(" ", "").replace("-", "")

        # Simple test card failure trigger (e.g. card ending in 0000 fails)
        if card_num.endswith("0000"):
            return {
                "success": False,
                "provider": "sandbox",
                "message": "Payment Declined: Test card declined by issuing bank (Code 4002).",
            }

        transaction_id = f"sbx_txn_{uuid.uuid4().hex[:12]}"
        sub_id = f"sub_sbx_{uuid.uuid4().hex[:10]}"
        cust_id = f"ctm_sbx_{uuid.uuid4().hex[:10]}"

        logger.info(
            f"[SandboxProvider] Transaction {transaction_id} approved for user={user_id}, "
            f"tier={tier}, cycle={billing_cycle}, amount=${amount}"
        )

        return {
            "success": True,
            "provider": "sandbox",
            "transaction_id": transaction_id,
            "gateway_subscription_id": sub_id,
            "gateway_customer_id": cust_id,
            "amount": amount,
            "currency": currency,
            "tier": tier,
            "billing_cycle": billing_cycle,
            "message": "Sandbox payment completed successfully.",
        }

    async def verify_webhook_signature(
        self, payload: bytes, signature_header: str
    ) -> bool:
        return True

    async def parse_webhook_event(
        self, payload_dict: Dict[str, Any]
    ) -> Dict[str, Any]:
        return {
            "event_type": "payment_success",
            "user_id": payload_dict.get("user_id", ""),
            "transaction_id": payload_dict.get("transaction_id", f"sbx_{uuid.uuid4().hex[:8]}"),
            "gateway_subscription_id": payload_dict.get("subscription_id", ""),
            "gateway_customer_id": payload_dict.get("customer_id", ""),
            "tier": payload_dict.get("tier", "pro"),
            "billing_cycle": payload_dict.get("billing_cycle", "monthly"),
            "amount": float(payload_dict.get("amount", 0.0)),
            "currency": "USD",
            "raw_event": "sandbox.test_completed",
        }

    async def cancel_subscription(
        self, gateway_subscription_id: str, immediate: bool = False
    ) -> bool:
        logger.info(f"[SandboxProvider] Canceled subscription {gateway_subscription_id}")
        return True
