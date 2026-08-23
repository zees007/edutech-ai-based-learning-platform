"""
EduTechAI — Payment Service & Factory Manager

Provides unified payment processing, provider selection (Paddle, Razorpay, Sandbox),
coupon discount verification, pricing calculation, and webhook handling.
"""

from __future__ import annotations

import logging
from typing import Dict, Optional

from app.exceptions import BadRequestException
from services.payment_providers import (
    BasePaymentProvider,
    PaddlePaymentProvider,
    RazorpayPaymentProvider,
    SandboxPaymentProvider,
)

logger = logging.getLogger(__name__)

# Standard Plan Base Pricing Structure
PRICING_CATALOG: Dict[str, Dict[str, float]] = {
    "free": {"monthly": 0.0, "annual": 0.0},
    "pro": {"monthly": 19.0, "annual": 180.0},    # ~$15/mo billed annually (~20% off)
    "ultra": {"monthly": 49.0, "annual": 470.0},   # ~$39/mo billed annually (~20% off)
}

# Promotional Coupons Registry
VALID_COUPONS: Dict[str, float] = {
    "EDU20": 20.0,       # 20% Off
    "WELCOME50": 50.0,   # 50% Off First Month/Year
    "STUDENT10": 10.0,   # 10% Off Student Discount
    "EDUTECH100": 100.0, # 100% Off VIP
}


class PaymentService:
    """Factory and Orchestrator for Payment Gateway Providers."""

    _providers: Dict[str, BasePaymentProvider] = {
        "paddle": PaddlePaymentProvider(),
        "razorpay": RazorpayPaymentProvider(),
        "sandbox": SandboxPaymentProvider(),
    }

    @classmethod
    def get_provider(cls, provider_name: str = "paddle") -> BasePaymentProvider:
        """
        Retrieves the payment provider instance. Falls back to 'paddle' or 'sandbox'
        if the requested provider is unsupported.
        """
        provider_key = provider_name.lower().strip()
        if provider_key not in cls._providers:
            logger.warning(f"[PaymentService] Unknown provider '{provider_name}'. Defaulting to Paddle.")
            provider_key = "paddle"
        return cls._providers[provider_key]

    @staticmethod
    def get_plan_price(tier: str, billing_cycle: str = "monthly") -> float:
        """Returns standard catalog price for a tier and billing cycle."""
        tier_key = tier.lower().strip()
        cycle_key = billing_cycle.lower().strip()

        if tier_key not in PRICING_CATALOG:
            raise BadRequestException(
                error_code="INVALID_TIER",
                errors=f"Invalid tier '{tier}'. Must be one of {list(PRICING_CATALOG.keys())}.",
            )

        if cycle_key not in ["monthly", "annual"]:
            cycle_key = "monthly"

        return PRICING_CATALOG[tier_key][cycle_key]

    @staticmethod
    def validate_coupon(coupon_code: Optional[str], tier: str, billing_cycle: str = "monthly") -> Dict[str, float | str | bool]:
        """
        Validates a promotional coupon code and computes final price.
        """
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
        if code_clean not in VALID_COUPONS:
            return {
                "valid": False,
                "coupon_code": code_clean,
                "discount_percent": 0.0,
                "discount_amount": 0.0,
                "original_price": base_price,
                "final_price": base_price,
                "message": f"Invalid coupon code '{code_clean}'.",
            }

        pct = VALID_COUPONS[code_clean]
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
