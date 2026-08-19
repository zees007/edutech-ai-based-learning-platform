"""
EduTechAI — Subscription Upgrade & Billing UI Components

Renders the interactive Subscription Upgrade Modal (@st.dialog) with billing cycle toggles,
multi-gateway payment selection (Paddle, Razorpay, Sandbox), promo code discounts,
and real-time order breakdown. Also renders the User Billing & Subscription Management Portal.
"""

from __future__ import annotations

import asyncio
import logging
from typing import Any

import streamlit as st
import streamlit.components.v1 as components

from services.payment_service import PaymentService

logger = logging.getLogger(__name__)


def run_async(coro: Any) -> Any:
    """Helper to run async coroutines in Streamlit sync context."""
    try:
        loop = asyncio.get_event_loop()
    except RuntimeError:
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
    return loop.run_until_complete(coro)


@st.dialog("⚡ Upgrade Your EduTechAI Subscription", width="large")
def render_subscription_upgrade_dialog(default_tier: str = "pro"):
    """
    Renders the interactive subscription upgrade dialog with multi-gateway checkout.
    """
    up = st.session_state.get("user_profile")
    user_id = getattr(up, "id", None) if up else None
    user_email = getattr(up, "email", "student@edutech.ai") if up else "student@edutech.ai"

    # Confetti particle burst helper
    components.html(
        """
        <script src="https://cdn.jsdelivr.net/npm/canvas-confetti@1.9.2/dist/confetti.browser.min.js"></script>
        """,
        height=0,
    )

    st.markdown(
        """
        <div style="text-align: center; margin-bottom: 1.2rem;">
            <span style="background: linear-gradient(135deg, #A855F7, #EC4899); color: white; padding: 4px 14px; border-radius: 20px; font-weight: 700; font-size: 0.85rem; letter-spacing: 1px;">
                PREMIUM LEARNING TIER
            </span>
            <h2 style="margin-top: 0.6rem; font-size: 1.8rem; font-weight: 800; color: #F8FAFC;">
                Elevate to <span style="background: linear-gradient(135deg, #3B82F6, #8B5CF6, #EC4899); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">
                """ + default_tier.upper() + """</span> Tier
            </h2>
            <p style="color: #94A3B8; font-size: 0.95rem; margin-top: -0.3rem;">
                Unlock unlimited AI sessions, deep research paper curation, video clips, and accelerated XP boosts.
            </p>
        </div>
        """,
        unsafe_allow_html=True,
    )

    # 1. Tier & Plan Selector
    target_tier = default_tier.lower()
    if target_tier not in ["pro", "ultra"]:
        target_tier = "pro"

    # 2. Billing Cycle Radio Toggle
    st.markdown("##### 1️⃣ Select Billing Cycle")
    cycle_choice = st.radio(
        "Billing Cycle:",
        options=["Monthly Billing", "Annual Billing (Save 20% ⚡)"],
        index=0,
        horizontal=True,
        key="sub_dlg_cycle",
        label_visibility="collapsed",
    )
    billing_cycle = "annual" if "Annual" in cycle_choice else "monthly"

    # 3. Payment Gateway Choice
    st.markdown("##### 2️⃣ Select Payment Method")
    gw_choice = st.radio(
        "Payment Provider:",
        options=[
            "💳 Paddle (Cards / PayPal / Apple Pay)",
            "🇮🇳 Razorpay (India - UPI / NetBanking)",
            "🧪 Sandbox Instant Checkout (Test Mode)",
        ],
        index=0,
        horizontal=True,
        key="sub_dlg_gw",
        label_visibility="collapsed",
    )

    if "Paddle" in gw_choice:
        provider_code = "paddle"
    elif "Razorpay" in gw_choice:
        provider_code = "razorpay"
    else:
        provider_code = "sandbox"

    # 4. Promo Coupon Input
    st.markdown("##### 3️⃣ Promotional Coupon")
    c1, c2 = st.columns([3, 1])
    with c1:
        coupon_input = st.text_input(
            "Promo Code",
            placeholder="Enter promo code (e.g. EDU20)",
            key="sub_dlg_coupon",
            label_visibility="collapsed",
        )
    with c2:
        st.markdown("<div style='height: 2px;'></div>", unsafe_allow_html=True)
        apply_btn = st.button("Apply", key="sub_dlg_apply_coupon", use_container_width=True)

    coupon_res = PaymentService.validate_coupon(coupon_input, target_tier, billing_cycle)
    if coupon_input:
        if coupon_res["valid"]:
            st.success(f"✅ {coupon_res['message']}")
        else:
            st.error(f"❌ {coupon_res['message']}")

    # 5. Sandbox Test Card Details (if Sandbox provider selected)
    card_num, exp_m, exp_y, cvc_val = None, None, None, None
    if provider_code == "sandbox":
        with st.expander("🧪 Sandbox Test Card Form", expanded=False):
            sc1, sc2 = st.columns([2, 1])
            with sc1:
                card_num = st.text_input("Card Number", value="4242 4242 4242 4242", key="sbx_card_num")
            with sc2:
                cvc_val = st.text_input("CVC", value="123", key="sbx_cvc")
            ec1, ec2 = st.columns(2)
            with ec1:
                exp_m = st.number_input("Exp Month", min_value=1, max_value=12, value=12, key="sbx_expm")
            with ec2:
                exp_y = st.number_input("Exp Year", min_value=2026, max_value=2035, value=2028, key="sbx_expy")

    # 6. Order Summary Box
    orig_price = float(coupon_res["original_price"])
    disc_amount = float(coupon_res["discount_amount"])
    final_price = float(coupon_res["final_price"])

    summary_html = f"""
    <div style="background: rgba(30, 41, 59, 0.7); border: 1px solid rgba(148, 163, 184, 0.2); border-radius: 12px; padding: 16px; margin: 16px 0;">
        <div style="display: flex; justify-content: space-between; margin-bottom: 8px; color: #CBD5E1; font-size: 0.95rem;">
            <span>Plan: <b>{target_tier.upper()} ({billing_cycle.capitalize()})</b></span>
            <span>${orig_price:.2f} USD</span>
        </div>
        """
    if disc_amount > 0:
        summary_html += f"""
        <div style="display: flex; justify-content: space-between; margin-bottom: 8px; color: #10B981; font-size: 0.95rem;">
            <span>Discount ({coupon_res['coupon_code']}):</span>
            <span>-${disc_amount:.2f} USD</span>
        </div>
        """
    summary_html += f"""
        <hr style="border: 0; border-top: 1px solid rgba(255,255,255,0.1); margin: 10px 0;" />
        <div style="display: flex; justify-content: space-between; color: #F8FAFC; font-size: 1.25rem; font-weight: 800;">
            <span>Total Due Today:</span>
            <span style="color: #38BDF8;">${final_price:.2f} USD</span>
        </div>
    </div>
    """
    st.markdown(summary_html, unsafe_allow_html=True)

    # 7. Complete Checkout Action Button
    checkout_label = f"🚀 Complete Payment — ${final_price:.2f}"
    if st.button(checkout_label, type="primary", key="btn_sub_checkout", use_container_width=True):
        if not user_id:
            st.session_state["show_upgrade_modal"] = False
            st.session_state["auth_tab"] = "signup"
            st.session_state["view"] = "auth"
            st.toast("🔒 Please sign in to complete subscription payment.", icon="🔒")
            st.rerun()

        with st.spinner("Processing secure payment..."):
            try:
                from models.subscription_schemas import CheckoutRequest
                from services.database import get_db_session
                from services.subscription_service import SubscriptionService
                from services.auth_service import AuthService
                from services.user_service import UserService

                req = CheckoutRequest(
                    tier=target_tier,
                    billing_cycle=billing_cycle,
                    gateway_provider=provider_code,
                    coupon_code=coupon_input if coupon_res["valid"] else None,
                    card_number=card_num,
                    exp_month=exp_m,
                    exp_year=exp_y,
                    cvc=cvc_val,
                )

                async def _do_checkout():
                    async with get_db_session() as db:
                        res = await SubscriptionService.process_checkout_and_upgrade(db, user_id, req)
                        u = await UserService.get_user_by_id(db, user_id)
                        p = AuthService.get_user_current_profile(u)
                        return res, p

                res_obj, updated_profile = run_async(_do_checkout())

                st.session_state["user_profile"] = updated_profile
                st.session_state["show_upgrade_modal"] = False
                if "target_upgrade_tier" in st.session_state:
                    del st.session_state["target_upgrade_tier"]

                # Fire celebratory JS confetti
                st.components.v1.html(
                    """
                    <script>
                      if (window.parent && window.parent.confetti) {
                        window.parent.confetti({
                          particleCount: 180,
                          spread: 100,
                          origin: { y: 0.5 }
                        });
                      }
                    </script>
                    """,
                    height=0,
                )

                st.toast(f"🎉 Congratulations! You are now on the {target_tier.upper()} Tier!", icon="⭐")
                st.rerun()

            except Exception as ex:
                logger.error(f"Checkout error: {ex}", exc_info=True)
                st.error(f"Payment failed: {ex}")


@st.dialog("💳 Subscription & Billing Portal", width="large")
def render_user_billing_portal_dialog():
    """Dialog wrapper for the user billing portal."""
    render_user_billing_portal()


def render_user_billing_portal():
    """
    Renders the Billing & Subscription portal tab in the user profile settings.
    Displays active plan, payment provider, renewal dates, cancellation CTA, and transaction history.
    """
    up = st.session_state.get("user_profile")
    if not up:
        st.info("Please sign in to view subscription and billing details.")
        return

    user_id = up.id
    current_tier = getattr(up, "tier", "normal").upper()

    st.markdown("### 💳 Subscription & Billing Portal")
    st.markdown("Manage your membership plan, payment provider, and billing history.")

    col1, col2 = st.columns([1, 1])

    with col1:
        st.markdown(
            f"""
            <div style="background: rgba(30, 41, 59, 0.8); border: 1px solid rgba(148, 163, 184, 0.2); border-radius: 12px; padding: 20px;">
                <div style="color: #94A3B8; font-size: 0.85rem; font-weight: 700;">CURRENT PLAN</div>
                <div style="font-size: 1.8rem; font-weight: 800; color: #F8FAFC; margin: 4px 0;">{current_tier} TIER</div>
                <div style="color: #38BDF8; font-weight: 600; font-size: 0.95rem;">Status: Active</div>
            </div>
            """,
            unsafe_allow_html=True,
        )

        st.markdown("<br>", unsafe_allow_html=True)

        if current_tier != "ULTRA":
            if st.button("⚡ Upgrade Subscription", key="btn_portal_upgrade", type="primary", use_container_width=True):
                st.session_state["target_upgrade_tier"] = "ultra" if current_tier == "PRO" else "pro"
                st.session_state["show_upgrade_modal"] = True
                st.rerun()

    with col2:
        if current_tier != "NORMAL":
            st.markdown("##### Manage Auto-Renewal")
            st.write("Need to pause or cancel auto-renew? You will retain access until the end of your billing cycle.")
            if st.button("Cancel Auto-Renew", key="btn_cancel_sub", use_container_width=True):
                try:
                    from models.subscription_schemas import CancelSubscriptionRequest
                    from services.database import get_db_session
                    from services.subscription_service import SubscriptionService
                    from services.auth_service import AuthService
                    from services.user_service import UserService

                    async def _cancel():
                        async with get_db_session() as db:
                            await SubscriptionService.cancel_user_subscription(
                                db, user_id, CancelSubscriptionRequest(immediate=False)
                            )
                            u = await UserService.get_user_by_id(db, user_id)
                            return AuthService.get_user_current_profile(u)

                    p = run_async(_cancel())
                    st.session_state["user_profile"] = p
                    st.toast("Subscription auto-renew canceled.", icon="ℹ️")
                    st.rerun()
                except Exception as ex:
                    st.error(f"Error canceling subscription: {ex}")

    st.markdown("---")
    st.markdown("#### 📜 Transaction History & Payment Ledger")

    try:
        from services.database import get_db_session
        from services.subscription_service import SubscriptionService

        async def _fetch_txns():
            async with get_db_session() as db:
                return await SubscriptionService.get_user_transactions(db, user_id)

        txns = run_async(_fetch_txns())
        if txns:
            data = [
                {
                    "Date": t.created_at.strftime("%Y-%m-%d %H:%M"),
                    "Transaction ID": t.transaction_id,
                    "Provider": t.gateway_provider.upper(),
                    "Tier": t.tier.upper(),
                    "Cycle": t.billing_cycle.capitalize(),
                    "Amount": f"${t.amount:.2f} {t.currency}",
                    "Status": t.status.upper(),
                }
                for t in txns
            ]
            st.dataframe(data, use_container_width=True)
        else:
            st.info("No past transactions found.")
    except Exception as ex:
        logger.warning(f"Could not load transactions: {ex}")
