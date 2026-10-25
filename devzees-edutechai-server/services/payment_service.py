"""
EduTechAI — Payment Service & Factory Manager

Provides unified payment processing, provider selection (Paddle, Razorpay, Sandbox),
coupon discount verification, pricing calculation, and webhook handling.
"""

from __future__ import annotations

import logging
import os
from typing import Dict, Optional

from app.exceptions import BadRequestException
from services.payment_providers import (
    BasePaymentProvider,
    PaddlePaymentProvider,
    RazorpayPaymentProvider,
    SandboxPaymentProvider,
)
from services.setting_service import SettingService

logger = logging.getLogger(__name__)

# Fallback definitions (dynamically populated from SettingService)
PRICING_CATALOG: Dict[str, Dict[str, float]] = SettingService.get_pricing_catalog()
VALID_COUPONS: Dict[str, float] = SettingService.get_valid_coupons()


class PaymentService:
    """Factory and Orchestrator for Payment Gateway Providers."""

    _providers: Dict[str, BasePaymentProvider] = {
        "paddle": PaddlePaymentProvider(),
        "razorpay": RazorpayPaymentProvider(),
        "sandbox": SandboxPaymentProvider(),
    }

    @classmethod
    def get_provider(cls, provider_name: Optional[str] = None) -> BasePaymentProvider:
        """
        Retrieves the payment provider instance. Defaults to 'razorpay' (or DEFAULT_PAYMENT_GATEWAY)
        if unspecified or unsupported.
        """
        default_provider = os.getenv("DEFAULT_PAYMENT_GATEWAY", "razorpay").lower().strip()
        provider_key = (provider_name or default_provider).lower().strip()
        if provider_key not in cls._providers:
            logger.warning(
                f"[PaymentService] Unknown provider '{provider_name}'. Defaulting to {default_provider}."
            )
            provider_key = default_provider if default_provider in cls._providers else "razorpay"
        return cls._providers[provider_key]

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
    def validate_coupon(coupon_code: Optional[str], tier: str, billing_cycle: str = "monthly") -> Dict[str, float | str | bool]:
        """
        Validates a promotional coupon code and computes final price dynamically from settings.
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

