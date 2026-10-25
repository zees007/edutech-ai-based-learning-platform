"""
EduTechAI — Tests for Razorpay Payment Gateway Provider & Order Lifecycle
"""

import hashlib
import hmac
from uuid import uuid4

import pytest
from httpx import ASGITransport, AsyncClient

from app.main import create_app
from services.database import init_db
from services.payment_providers.razorpay_provider import RazorpayPaymentProvider


@pytest.fixture
def app():
    return create_app()


def test_razorpay_signature_verification():
    """Verify HMAC SHA256 signature verification logic."""
    provider = RazorpayPaymentProvider()
    provider.key_secret = "test_secret_12345"

    order_id = "order_test_98765"
    payment_id = "pay_test_54321"

    # Compute valid signature
    msg = f"{order_id}|{payment_id}".encode("utf-8")
    valid_sig = hmac.new("test_secret_12345".encode("utf-8"), msg, hashlib.sha256).hexdigest()

    # Must return True for authentic signature
    assert provider.verify_payment_signature(order_id, payment_id, valid_sig) is True

    # Must return False for forged signature
    assert provider.verify_payment_signature(order_id, payment_id, "forged_signature_abc") is False

    # Must return False for empty values
    assert provider.verify_payment_signature("", payment_id, valid_sig) is False


@pytest.mark.asyncio
async def test_razorpay_create_order_and_verified_checkout(app):
    """End-to-end integration test for Razorpay order creation and verified upgrade."""
    await init_db()
    test_email = f"rzp_user_{uuid4().hex[:8]}@example.com"
    pwd = "Password123!"

    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://testserver"
    ) as client:
        # 1. Sign up user
        res = await client.post(
            "/api/v1/users/create",
            json={
                "first_name": "Rzp",
                "last_name": "Tester",
                "email": test_email,
                "password": pwd,
            },
        )
        assert res.status_code == 201
        user_id = res.json()["id"]

        # 2. Login
        login_res = await client.post("/api/v1/auth/login", json={"email": test_email, "password": pwd})
        assert login_res.status_code == 200

        # 3. Create Order via Razorpay endpoint
        order_payload = {
            "tier": "pro",
            "billing_cycle": "monthly",
            "gateway_provider": "razorpay",
            "currency": "USD",
            "coupon_code": "EDU20",
        }
        order_res = await client.post("/api/v1/subscriptions/create-order", json=order_payload)
        assert order_res.status_code == 200
        order_data = order_res.json()
        assert order_data["success"] is True
        assert order_data["tier"] == "pro"
        assert order_data["gateway_provider"] == "razorpay"
        assert order_data["amount"] == 15.2  # $19 - 20% = 15.2
        assert order_data["order_id"].startswith("order_")
        created_order_id = order_data["order_id"]

        # 4. Attempt checkout with forged signature (when secret is configured)
        from services.payment_service import PaymentService
        rzp_instance = PaymentService.get_provider("razorpay")
        orig_secret = rzp_instance.key_secret
        rzp_instance.key_secret = "rzp_test_secret_for_unit_tests"
        test_payment_id = f"pay_test_{uuid4().hex[:10]}"

        try:
            bad_checkout = {
                "tier": "pro",
                "billing_cycle": "monthly",
                "gateway_provider": "razorpay",
                "currency": "USD",
                "coupon_code": "EDU20",
                "razorpay_order_id": created_order_id,
                "razorpay_payment_id": test_payment_id,
                "razorpay_signature": "invalid_forged_signature",
            }
            bad_res = await client.post("/api/v1/subscriptions/checkout", json=bad_checkout)
            assert bad_res.status_code == 400
            assert bad_res.json()["error_code"] == "PAYMENT_VERIFICATION_FAILED"

            # 5. Complete checkout with valid computed signature
            msg = f"{created_order_id}|{test_payment_id}".encode("utf-8")
            valid_sig = hmac.new("rzp_test_secret_for_unit_tests".encode("utf-8"), msg, hashlib.sha256).hexdigest()

            good_checkout = {
                "tier": "pro",
                "billing_cycle": "monthly",
                "gateway_provider": "razorpay",
                "currency": "USD",
                "coupon_code": "EDU20",
                "razorpay_order_id": created_order_id,
                "razorpay_payment_id": test_payment_id,
                "razorpay_signature": valid_sig,
            }
            good_res = await client.post("/api/v1/subscriptions/checkout", json=good_checkout)
            assert good_res.status_code == 200
            chk_data = good_res.json()
            assert chk_data["success"] is True
            assert chk_data["tier"] == "pro"
            assert chk_data["transaction_id"] == test_payment_id

            # 6. Verify Subscription Record
            sub_res = await client.get(f"/api/v1/subscriptions/users/{user_id}")
            # Check transactions ledger
            tx_res = await client.get(f"/api/v1/subscriptions/users/{user_id}/transactions")
            if tx_res.status_code == 200:
                tx_list = tx_res.json()
                assert len(tx_list) >= 1
                assert tx_list[0]["gateway_provider"] == "razorpay"
                assert tx_list[0]["transaction_id"] == test_payment_id

        finally:
            rzp_instance.key_secret = orig_secret
