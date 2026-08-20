"""
EduTechAI — Abstract Base Payment Provider Interface

Defines the contract that all payment provider implementations (Paddle, Razorpay, Sandbox)
must fulfill. This enables a pluggable multi-gateway architecture.
"""

from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Any, Dict, Optional


class BasePaymentProvider(ABC):
    """Abstract interface for payment gateway integrations."""

    @property
    @abstractmethod
    def provider_name(self) -> str:
        """Returns the unique code name of the payment provider (e.g. 'paddle', 'razorpay', 'sandbox')."""
        pass

    @abstractmethod
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
        Initiates a checkout session or direct payment processing.

        Returns a dict containing transaction reference, checkout URL (if hosted),
        gateway subscription/customer IDs, and status.
        """
        pass

    @abstractmethod
    async def verify_webhook_signature(
        self, payload: bytes, signature_header: str
    ) -> bool:
        """Verifies whether an incoming webhook payload originated from the authentic gateway."""
        pass

    @abstractmethod
    async def parse_webhook_event(
        self, payload_dict: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        Parses provider-specific webhook events into a standardized internal dict format:
        {
            'event_type': 'payment_success' | 'subscription_canceled' | 'payment_failed',
            'user_id': str,
            'transaction_id': str,
            'gateway_subscription_id': str,
            'gateway_customer_id': str,
            'tier': str,
            'amount': float,
            'currency': str,
        }
        """
        pass

    @abstractmethod
    async def cancel_subscription(
        self, gateway_subscription_id: str, immediate: bool = False
    ) -> bool:
        """Requests cancellation of a recurring subscription on the gateway."""
        pass
