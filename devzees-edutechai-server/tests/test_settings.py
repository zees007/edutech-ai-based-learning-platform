"""
EduTechAI — Tests for Dynamic System Settings Service & Admin Endpoints
"""

import pytest
from httpx import ASGITransport, AsyncClient

from app.main import create_app
from config import get_settings
from services.payment_service import PaymentService
from services.setting_service import SettingService


def test_setting_service_default_fallbacks():
    # 1. Test LLM models default resolution
    assert SettingService.get_agent_model("orchestrator") == "openai/gpt-oss-20b"
    assert SettingService.get_agent_model("socratic_tutor") == "openai/gpt-oss-20b"
    assert SettingService.get_agent_model("quiz_agent") == "openai/gpt-oss-20b"

    # Test config.py fallback hook
    settings = get_settings()
    assert settings.get_model_for_agent("orchestrator") == "openai/gpt-oss-20b"

    # 2. Test Pricing Catalog parsing
    catalog = SettingService.get_pricing_catalog()
    assert catalog["free"]["monthly"] == 0.0
    assert catalog["pro"]["monthly"] == 19.0
    assert catalog["pro"]["annual"] == 180.0
    assert catalog["ultra"]["monthly"] == 49.0
    assert catalog["ultra"]["annual"] == 470.0

    # 3. Test Coupons parsing
    coupons = SettingService.get_valid_coupons()
    assert coupons["EDU20"] == 20.0
    assert coupons["WELCOME50"] == 50.0
    assert coupons["STUDENT10"] == 10.0
    assert coupons["EDUTECH100"] == 100.0


def test_payment_service_dynamic_pricing_and_coupons():
    # Verify PaymentService transparently delegates to SettingService
    price_pro_monthly = PaymentService.get_plan_price("pro", "monthly")
    assert price_pro_monthly == 19.0

    price_ultra_annual = PaymentService.get_plan_price("ultra", "annual")
    assert price_ultra_annual == 470.0

    # Test coupon discount computation
    res = PaymentService.validate_coupon("EDU20", "pro", "monthly")
    assert res["valid"] is True
    assert res["discount_percent"] == 20.0
    assert res["final_price"] == 15.20


def test_setting_service_cache_update():
    # Simulate updating a model in memory
    original_model = SettingService.get_agent_model("orchestrator")
    SettingService._cache["ORCHESTRATOR_MODEL"] = "llama-3.3-70b-versatile"
    assert SettingService.get_agent_model("orchestrator") == "llama-3.3-70b-versatile"
    assert get_settings().get_model_for_agent("orchestrator") == "llama-3.3-70b-versatile"

    # Reset back to original
    SettingService._cache["ORCHESTRATOR_MODEL"] = original_model
    assert SettingService.get_agent_model("orchestrator") == original_model


def test_dynamic_youtube_and_followup_limits():
    settings = get_settings()

    # 1. Test default limits
    assert settings.youtube_daily_search_limit == 100
    assert settings.free_youtube_limit == 1
    assert settings.pro_youtube_limit == 3
    assert settings.ultra_youtube_limit == 5
    assert settings.free_followup_limit == 1
    assert settings.pro_followup_limit == 5

    # 2. Simulate updating limit dynamically in SettingService cache
    SettingService._cache["YOUTUBE_DAILY_SEARCH_LIMIT"] = "5000"
    SettingService._cache["FREE_YOUTUBE_LIMIT"] = "2"
    SettingService._cache["PRO_FOLLOWUP_LIMIT"] = "8"

    assert settings.youtube_daily_search_limit == 5000
    assert settings.free_youtube_limit == 2
    assert settings.pro_followup_limit == 8

    # Reset cache back to original
    SettingService._cache["YOUTUBE_DAILY_SEARCH_LIMIT"] = "100"
    SettingService._cache["FREE_YOUTUBE_LIMIT"] = "1"
    SettingService._cache["PRO_FOLLOWUP_LIMIT"] = "5"
    assert settings.youtube_daily_search_limit == 100
    assert settings.free_youtube_limit == 1
    assert settings.pro_followup_limit == 5


