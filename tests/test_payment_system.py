"""
EduTechAI — Unit & Integration Tests for Payment Gateway System, Checkout, Coupons & Ledger
"""

from uuid import uuid4
import pytest
from httpx import ASGITransport, AsyncClient

from app.main import create_app
from services.database import init_db
from services.payment_service import PaymentService


@pytest.fixture
def app():
    return create_app()


def test_payment_service_coupon_validation():
    # Test valid coupon EDU20 (20% off Pro monthly $19.00 -> $15.20)
    res = PaymentService.validate_coupon("EDU20", tier="pro", billing_cycle="monthly")
    assert res["valid"] is True
    assert res["discount_percent"] == 20.0
    assert res["discount_amount"] == 3.8
    assert res["final_price"] == 15.2

    # Test valid coupon WELCOME50 (50% off Ultra annual $470.00 -> $235.00)
    res_annual = PaymentService.validate_coupon("WELCOME50", tier="ultra", billing_cycle="annual")
    assert res_annual["valid"] is True
    assert res_annual["discount_percent"] == 50.0
    assert res_annual["final_price"] == 235.0

    # Test invalid coupon
    invalid_res = PaymentService.validate_coupon("INVALID_CODE", tier="pro")
    assert invalid_res["valid"] is False
    assert invalid_res["final_price"] == 19.0


@pytest.mark.asyncio
async def test_checkout_flow_and_transaction_ledger(app):
    await init_db()
    test_email = f"pay_user_{uuid4().hex[:8]}@example.com"
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://testserver"
    ) as client:
        # 1. Sign up test user
        res = await client.post(
            "/api/v1/users/create",
            json={
                "first_name": "Pay",
                "last_name": "User",
                "email": test_email,
                "password": "Password123!",
            },
        )
        assert res.status_code == 201
        user_id = res.json()["id"]

        # 2. Login
        login_res = await client.post(
            "/api/v1/auth/login", json={"email": test_email, "password": "Password123!"}
        )
        assert login_res.status_code == 200

        # 3. Test Coupon Validation Endpoint
        v_res = await client.post(
            "/api/v1/subscriptions/validate-coupon",
            json={"coupon_code": "EDU20", "tier": "pro", "billing_cycle": "monthly"},
        )
        assert v_res.status_code == 200
        assert v_res.json()["valid"] is True
        assert v_res.json()["final_price"] == 15.2

        # 4. Perform Subscription Checkout via Sandbox Payment Gateway
        checkout_payload = {
            "tier": "pro",
            "billing_cycle": "monthly",
            "gateway_provider": "sandbox",
            "coupon_code": "EDU20",
            "card_number": "4242 4242 4242 4242",
            "exp_month": 12,
            "exp_year": 2028,
            "cvc": "123",
        }
        chk_res = await client.post("/api/v1/subscriptions/checkout", json=checkout_payload)
        assert chk_res.status_code == 200
        chk_data = chk_res.json()
        assert chk_data["success"] is True
        assert chk_data["tier"] == "pro"
        assert chk_data["amount_paid"] == 15.2
        assert chk_data["gateway_provider"] == "sandbox"
        assert chk_data["transaction_id"] is not None

        # 5. Retrieve Subscription Details & Verify Status
        sub_res = await client.get(f"/api/v1/subscriptions/users/{user_id}")
        assert sub_res.status_code == 200
        sub_info = sub_res.json()
        assert sub_info["tier"] == "pro"
        assert sub_info["billing_cycle"] == "monthly"
        assert sub_info["gateway_provider"] == "sandbox"

        # 6. Retrieve Payment Transaction History & Verify Ledger Record
        tx_res = await client.get(f"/api/v1/subscriptions/users/{user_id}/transactions")
        assert tx_res.status_code == 200
        tx_list = tx_res.json()
        assert len(tx_list) >= 1
        assert tx_list[0]["tier"] == "pro"
        assert tx_list[0]["amount"] == 15.2
        assert tx_list[0]["coupon_code"] == "EDU20"
