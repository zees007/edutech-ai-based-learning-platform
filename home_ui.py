"""
EduTechAI — Landing Page (Matches Reference Design)

Pixel-accurate recreation of the reference landing page with:
- Top navbar: Logo + nav links + Sign In / Get Started
- Hero section with radial gradient, pill badge, headline, subtitle, CTA, hero image
- Agent Squad section: 3x2 grid of agent cards with icon squares
- Pricing section: 3 tier cards (Normal, Pro highlighted, Ultra)
- CTA banner: "Ready to Accelerate Your Learning?"
- Footer: Logo, copyright, links
- Strict auth guard: login required to access AI Learning Journey
"""

from __future__ import annotations

import asyncio
import base64
import logging
import os
import streamlit as st

logger = logging.getLogger(__name__)


# ─── Helper Functions ────────────────────────────────────────────
def run_async(coro):
    """Run an async coroutine inside Streamlit's sync execution loop."""
    try:
        loop = asyncio.get_event_loop()
    except RuntimeError:
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
    return loop.run_until_complete(coro)


def _get_hero_image_base64() -> str:
    """Load hero image as base64 for embedding in HTML."""
    img_path = os.path.join(os.path.dirname(__file__), "hero_dashboard.png")
    if os.path.exists(img_path):
        with open(img_path, "rb") as f:
            return base64.b64encode(f.read()).decode()
    return ""


# ─── CSS: Exact Match to Reference Design ────────────────────────
HOME_CSS = """
<style>
    /* ── Reset & Global ────────────────────────────── */
    .stApp {
        background-color: #0B1120 !important;
    }

    section[data-testid="stSidebar"] {
        display: none !important;
    }

    /* ── Navbar ─────────────────────────────────────── */
    .et-navbar {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 0.9rem 0;
        margin-bottom: 0;
    }

    .et-navbar-logo {
        font-size: 1.25rem;
        font-weight: 800;
        color: #FAFAFA;
        letter-spacing: -0.3px;
    }

    .et-navbar-links {
        display: flex;
        gap: 28px;
    }

    .et-navbar-links a {
        color: #94A3B8;
        font-size: 0.88rem;
        font-weight: 500;
        text-decoration: none;
        transition: color 0.2s;
    }

    .et-navbar-links a:hover {
        color: #FAFAFA;
    }

    .et-navbar-right {
        display: flex;
        align-items: center;
        gap: 16px;
    }

    .et-btn-signin {
        color: #94A3B8;
        font-size: 0.88rem;
        font-weight: 500;
        background: none;
        border: none;
        cursor: pointer;
        transition: color 0.2s;
    }

    .et-btn-signin:hover {
        color: #FAFAFA;
    }

    .et-btn-getstarted {
        background: linear-gradient(135deg, #6366F1 0%, #8B5CF6 100%);
        color: #FAFAFA;
        font-size: 0.85rem;
        font-weight: 600;
        padding: 8px 20px;
        border-radius: 8px;
        border: none;
        cursor: pointer;
        transition: opacity 0.2s;
    }

    .et-btn-getstarted:hover {
        opacity: 0.9;
    }

    /* ── Hero ───────────────────────────────────────── */
    .et-hero {
        text-align: center;
        padding: 3.5rem 1rem 2rem 1rem;
        background: radial-gradient(ellipse at 50% 0%, rgba(99, 102, 241, 0.18) 0%, rgba(11, 17, 32, 0) 65%);
    }

    .et-hero-pill {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        background: rgba(99, 102, 241, 0.12);
        border: 1px solid rgba(99, 102, 241, 0.3);
        color: #818CF8;
        font-size: 0.82rem;
        font-weight: 600;
        padding: 6px 18px;
        border-radius: 24px;
        margin-bottom: 1.8rem;
    }

    .et-hero h1 {
        font-size: 3.2rem;
        font-weight: 800;
        color: #FAFAFA;
        line-height: 1.12;
        letter-spacing: -1.5px;
        margin-bottom: 1.2rem;
        max-width: 780px;
        margin-left: auto;
        margin-right: auto;
    }

    .et-hero p {
        font-size: 1.05rem;
        color: #94A3B8;
        max-width: 680px;
        margin: 0 auto 2rem auto;
        line-height: 1.7;
    }

    .et-hero-cta {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        background: linear-gradient(135deg, #6366F1 0%, #8B5CF6 100%);
        color: #FAFAFA;
        font-size: 0.95rem;
        font-weight: 600;
        padding: 12px 28px;
        border-radius: 8px;
        border: none;
        cursor: pointer;
        text-decoration: none;
        transition: opacity 0.2s, transform 0.2s;
        margin-bottom: 2.5rem;
    }

    .et-hero-cta:hover {
        opacity: 0.9;
        transform: translateY(-1px);
    }

    .et-hero-image {
        max-width: 900px;
        width: 100%;
        margin: 0 auto;
        border-radius: 16px;
        overflow: hidden;
        box-shadow: 0 25px 80px -15px rgba(99, 102, 241, 0.25), 0 0 60px rgba(99, 102, 241, 0.08);
    }

    .et-hero-image img {
        width: 100%;
        display: block;
        border-radius: 16px;
    }

    /* ── Agents Section ────────────────────────────── */
    .et-agents-section {
        padding: 4rem 0 3rem 0;
        text-align: center;
    }

    .et-agents-section h2 {
        font-size: 2rem;
        font-weight: 800;
        color: #FAFAFA;
        margin-bottom: 0.5rem;
    }

    .et-agents-section .et-subtitle {
        font-size: 1rem;
        color: #94A3B8;
        max-width: 620px;
        margin: 0 auto 2.5rem auto;
        line-height: 1.6;
    }

    .et-agent-card {
        background: #111A2E;
        border: 1px solid #1E293B;
        border-radius: 12px;
        padding: 1.5rem;
        text-align: left;
        transition: border-color 0.2s;
        min-height: 180px;
    }

    .et-agent-card:hover {
        border-color: #334155;
    }

    .et-agent-icon {
        width: 44px;
        height: 44px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.2rem;
        margin-bottom: 1rem;
    }

    .et-agent-icon-orchestrator { background: rgba(139, 92, 246, 0.15); color: #A78BFA; }
    .et-agent-icon-tutor        { background: rgba(59, 130, 246, 0.15); color: #60A5FA; }
    .et-agent-icon-youtube       { background: rgba(6, 182, 212, 0.15); color: #22D3EE; }
    .et-agent-icon-researcher   { background: rgba(16, 185, 129, 0.15); color: #34D399; }
    .et-agent-icon-quiz         { background: rgba(251, 191, 36, 0.15); color: #FBBF24; }
    .et-agent-icon-gamification { background: rgba(236, 72, 153, 0.15); color: #F472B6; }

    .et-agent-card h4 {
        font-size: 1rem;
        font-weight: 700;
        color: #FAFAFA;
        margin-bottom: 0.4rem;
        display: flex;
        align-items: center;
        gap: 4px;
    }

    .et-agent-card h4 .et-chevron {
        color: #475569;
        font-size: 0.85rem;
    }

    .et-agent-card p {
        font-size: 0.85rem;
        color: #94A3B8;
        line-height: 1.5;
        margin: 0;
    }

    /* ── Pricing Section ───────────────────────────── */
    .et-pricing-section {
        padding: 4rem 0 3rem 0;
        text-align: center;
    }

    .et-pricing-section h2 {
        font-size: 2rem;
        font-weight: 800;
        color: #FAFAFA;
        margin-bottom: 0.5rem;
    }

    .et-pricing-section .et-subtitle {
        font-size: 1rem;
        color: #94A3B8;
        margin-bottom: 2.5rem;
    }

    .et-tier-card {
        background: #111A2E;
        border: 1px solid #1E293B;
        border-radius: 12px;
        padding: 2rem 1.5rem;
        text-align: left;
        position: relative;
        height: 100%;
        display: flex;
        flex-direction: column;
    }

    .et-tier-card-pro {
        border: 2px solid #6366F1;
        box-shadow: 0 0 30px rgba(99, 102, 241, 0.12);
    }

    .et-tier-badge-popular {
        position: absolute;
        top: -12px;
        right: 20px;
        background: #6366F1;
        color: #FAFAFA;
        font-size: 0.68rem;
        font-weight: 700;
        padding: 3px 10px;
        border-radius: 6px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    .et-tier-label {
        font-size: 0.82rem;
        font-weight: 700;
        color: #94A3B8;
        margin-bottom: 0.3rem;
    }

    .et-tier-label span {
        color: #6366F1;
    }

    .et-tier-price {
        font-size: 2.8rem;
        font-weight: 900;
        color: #FAFAFA;
        line-height: 1;
        margin-bottom: 0.5rem;
    }

    .et-tier-price sub {
        font-size: 1rem;
        font-weight: 400;
        color: #64748B;
    }

    .et-tier-desc {
        font-size: 0.88rem;
        color: #94A3B8;
        margin-bottom: 1.5rem;
        line-height: 1.5;
        min-height: 45px;
    }

    .et-tier-feature {
        display: flex;
        align-items: center;
        gap: 10px;
        font-size: 0.88rem;
        color: #CBD5E1;
        margin-bottom: 0.55rem;
    }

    .et-tier-feature .check {
        color: #10B981;
        font-weight: 700;
        font-size: 0.9rem;
    }

    .et-tier-btn {
        display: block;
        width: 100%;
        text-align: center;
        padding: 10px 0;
        border-radius: 8px;
        font-size: 0.88rem;
        font-weight: 600;
        cursor: pointer;
        transition: opacity 0.2s;
        text-decoration: none;
        margin-top: auto;
        border: 1px solid #1E293B;
        background: transparent;
        color: #FAFAFA;
    }

    .et-tier-btn:hover {
        border-color: #334155;
    }

    .et-tier-btn-primary {
        background: linear-gradient(135deg, #6366F1 0%, #8B5CF6 100%);
        border: none;
        color: #FAFAFA;
    }

    .et-tier-btn-primary:hover {
        opacity: 0.9;
    }

    /* ── CTA Banner ────────────────────────────────── */
    .et-cta-banner {
        text-align: center;
        padding: 4rem 1rem;
        background: linear-gradient(180deg, #0B1120 0%, #111A2E 50%, #0B1120 100%);
        border-top: 1px solid #1E293B;
        border-bottom: 1px solid #1E293B;
        margin: 2rem 0;
    }

    .et-cta-banner h2 {
        font-size: 2rem;
        font-weight: 800;
        color: #FAFAFA;
        margin-bottom: 0.8rem;
    }

    .et-cta-banner p {
        font-size: 1rem;
        color: #94A3B8;
        max-width: 560px;
        margin: 0 auto 2rem auto;
        line-height: 1.6;
    }

    .et-cta-btn {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        background: transparent;
        color: #FAFAFA;
        font-size: 0.9rem;
        font-weight: 600;
        padding: 10px 24px;
        border-radius: 8px;
        border: 1px solid #334155;
        cursor: pointer;
        transition: border-color 0.2s;
        text-decoration: none;
    }

    .et-cta-btn:hover {
        border-color: #6366F1;
    }

    /* ── Footer ────────────────────────────────────── */
    .et-footer {
        padding: 2rem 0;
        border-top: 1px solid #1E293B;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .et-footer-left {
        color: #64748B;
        font-size: 0.82rem;
    }

    .et-footer-left span {
        font-weight: 700;
        color: #94A3B8;
    }

    .et-footer-links {
        display: flex;
        gap: 24px;
    }

    .et-footer-links a {
        color: #64748B;
        font-size: 0.82rem;
        text-decoration: none;
        transition: color 0.2s;
    }

    .et-footer-links a:hover {
        color: #FAFAFA;
    }
</style>
"""


def render_home_page():
    """Renders the landing page matching the reference design exactly."""
    st.markdown(HOME_CSS, unsafe_allow_html=True)

    # Initialize state
    if "view" not in st.session_state:
        st.session_state["view"] = "home"
    if "user_profile" not in st.session_state:
        st.session_state["user_profile"] = None
    if "billing_cycle" not in st.session_state:
        st.session_state["billing_cycle"] = "monthly"

    user_profile = st.session_state.get("user_profile")
    current_view = st.session_state.get("view", "home")

    # Route to auth view if requested
    if current_view == "auth":
        _render_auth_view()
        return

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    #  NAVBAR
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    nav_col1, nav_col2, nav_col3, nav_col4 = st.columns([2, 3, 1.2, 1.8])

    with nav_col1:
        st.markdown(
            '<div class="et-navbar-logo">⚡ EduTech AI</div>',
            unsafe_allow_html=True,
        )

    with nav_col2:
        st.markdown(
            """
            <div class="et-navbar-links" style="padding-top: 4px;">
                <a href="#agents">Features</a>
                <a href="#agents">Agents</a>
                <a href="#pricing">Pricing</a>
                <a href="#about">About</a>
            </div>
            """,
            unsafe_allow_html=True,
        )

    with nav_col3:
        if user_profile:
            u_tier = (user_profile.subscription.tier if user_profile.subscription else "normal").upper()
            st.markdown(
                f'<div style="color: #94A3B8; font-size: 0.85rem; padding-top: 4px;">👋 <b>{user_profile.first_name}</b> · <span style="color: #818CF8; font-weight: 700;">{u_tier}</span></div>',
                unsafe_allow_html=True,
            )
        else:
            if st.button("Sign In", key="nav_signin", use_container_width=True):
                st.session_state["auth_tab"] = "login"
                st.session_state["view"] = "auth"
                st.rerun()

    with nav_col4:
        if user_profile:
            logout_col1, logout_col2 = st.columns(2)
            with logout_col1:
                if st.button("🎓 Learn", key="nav_learn", use_container_width=True, type="primary"):
                    st.session_state["view"] = "learning"
                    st.rerun()
            with logout_col2:
                if st.button("Logout", key="nav_logout", use_container_width=True):
                    st.session_state["user_profile"] = None
                    st.toast("Logged out.", icon="ℹ️")
                    st.rerun()
        else:
            if st.button("Get Started", key="nav_getstarted", type="primary", use_container_width=True):
                st.session_state["auth_tab"] = "signup"
                st.session_state["view"] = "auth"
                st.rerun()

    st.markdown("<hr style='border: 1px solid #1E293B; margin: 0.5rem 0 0 0;' />", unsafe_allow_html=True)

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    #  HERO SECTION
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    hero_img_b64 = _get_hero_image_base64()
    hero_img_html = f'<div class="et-hero-image"><img src="data:image/png;base64,{hero_img_b64}" alt="AI Multi-Agent Dashboard" /></div>' if hero_img_b64 else ""

    st.markdown(
        f"""
        <div class="et-hero">
            <div class="et-hero-pill">
                🤖 &nbsp; Meet Your Multi-Agent AI System
            </div>
            <h1>Master Any Subject with a Team<br/>of AI Agents.</h1>
            <p>
                Experience a new paradigm in learning. Our orchestrator divides complex topics into milestones,
                while specialized agents guide you through videos, research, and interactive assessments.
            </p>
        </div>
        """,
        unsafe_allow_html=True,
    )

    # Hero CTA Button (Streamlit native for interactivity)
    cta_space_l, cta_col, cta_space_r = st.columns([2.5, 1.5, 2.5])
    with cta_col:
        if st.button("Start Learning for Free →", key="hero_cta", type="primary", use_container_width=True):
            if not user_profile:
                st.session_state["auth_tab"] = "login"
                st.session_state["view"] = "auth"
                st.toast("🔒 Please sign in or create an account to start learning.", icon="🔒")
                st.rerun()
            else:
                st.session_state["view"] = "learning"
                st.rerun()

    # Hero Image
    if hero_img_html:
        st.markdown(
            f'<div style="display: flex; justify-content: center; padding: 1.5rem 0 3rem 0;">{hero_img_html}</div>',
            unsafe_allow_html=True,
        )

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    #  AGENT SQUAD SECTION
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    st.markdown('<a name="agents"></a>', unsafe_allow_html=True)
    st.markdown(
        """
        <div class="et-agents-section">
            <h2>The Agent Squad</h2>
            <p class="et-subtitle">
                A specialized team working in parallel to deliver a comprehensive, structured, and
                engaging learning experience.
            </p>
        </div>
        """,
        unsafe_allow_html=True,
    )

    # Row 1: Orchestrator, Socratic Tutor, YouTube Curator
    ag1, ag2, ag3 = st.columns(3)

    with ag1:
        st.markdown(
            """
            <div class="et-agent-card">
                <div class="et-agent-icon et-agent-icon-orchestrator">🎯</div>
                <h4>Orchestrator <span class="et-chevron">‹›</span></h4>
                <p>Topic decomposition into structured milestones.</p>
            </div>
            """,
            unsafe_allow_html=True,
        )

    with ag2:
        st.markdown(
            """
            <div class="et-agent-card">
                <div class="et-agent-icon et-agent-icon-tutor">💬</div>
                <h4>Socratic Tutor <span class="et-chevron">‹›</span></h4>
                <p>Guided questioning and conceptual analogies.</p>
            </div>
            """,
            unsafe_allow_html=True,
        )

    with ag3:
        st.markdown(
            """
            <div class="et-agent-card">
                <div class="et-agent-icon et-agent-icon-youtube">🎬</div>
                <h4>YouTube Curator</h4>
                <p>Deep-linked video timestamps for milestones.</p>
            </div>
            """,
            unsafe_allow_html=True,
        )

    st.markdown("<br/>", unsafe_allow_html=True)

    # Row 2: Academic Researcher, Dynamic Quiz, Gamification Engine
    ag4, ag5, ag6 = st.columns(3)

    with ag4:
        st.markdown(
            """
            <div class="et-agent-card">
                <div class="et-agent-icon et-agent-icon-researcher">📚</div>
                <h4>Academic Researcher <span class="et-chevron">‹›</span></h4>
                <p>AI summaries of research papers (arXiv, Semantic Scholar).</p>
            </div>
            """,
            unsafe_allow_html=True,
        )

    with ag5:
        st.markdown(
            """
            <div class="et-agent-card">
                <div class="et-agent-icon et-agent-icon-quiz">📝</div>
                <h4>Dynamic Quiz</h4>
                <p>Contextual MCQs with instant actionable feedback.</p>
            </div>
            """,
            unsafe_allow_html=True,
        )

    with ag6:
        st.markdown(
            """
            <div class="et-agent-card">
                <div class="et-agent-icon et-agent-icon-gamification">📊</div>
                <h4>Gamification Engine</h4>
                <p>Streak tracking, achievements, and exp progression (1-10).</p>
            </div>
            """,
            unsafe_allow_html=True,
        )

    st.markdown("<br/><br/>", unsafe_allow_html=True)

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    #  PRICING SECTION
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    st.markdown('<a name="pricing"></a>', unsafe_allow_html=True)
    st.markdown(
        """
        <div class="et-pricing-section">
            <h2>Choose Your Path</h2>
            <p class="et-subtitle">Flexible plans designed for every type of learner.</p>
        </div>
        """,
        unsafe_allow_html=True,
    )

    tier1, tier2, tier3 = st.columns(3)

    # ── Normal Tier ──
    with tier1:
        st.markdown(
            """
            <div class="et-tier-card">
                <div>
                    <div class="et-tier-label">Normal</div>
                    <div class="et-tier-price">$0<sub>/mo</sub></div>
                    <div class="et-tier-desc">Essential AI tutoring and basic milestone journeys.</div>
                    <hr style="border: 1px solid #1E293B;" />
                    <div class="et-tier-feature"><span class="check">✓</span> 5 AI Learning Sessions / mo</div>
                    <div class="et-tier-feature"><span class="check">✓</span> Standard Socratic Tutor</div>
                    <div class="et-tier-feature"><span class="check">✓</span> 3 Education Levels</div>
                    <div class="et-tier-feature"><span class="check">✓</span> Milestone Step Journey</div>
                    <div class="et-tier-feature"><span class="check">✓</span> Basic Quizzes & XP</div>
                </div>
            </div>
            """,
            unsafe_allow_html=True,
        )
        st.markdown("<div style='height: 12px'></div>", unsafe_allow_html=True)
        if st.button("Start Free", key="tier_normal_btn", use_container_width=True):
            _handle_tier_select("normal")

    # ── Pro Tier (Most Popular) ──
    with tier2:
        st.markdown(
            """
            <div class="et-tier-card et-tier-card-pro">
                <div class="et-tier-badge-popular">MOST POPULAR</div>
                <div>
                    <div class="et-tier-label">Pro <span>⭐</span></div>
                    <div class="et-tier-price">$19<sub>/mo</sub></div>
                    <div class="et-tier-desc">Full agent squad access, deep research & immersive, and advanced analytics.</div>
                    <hr style="border: 1px solid #1E293B;" />
                    <div class="et-tier-feature"><span class="check">✓</span> <b>Unlimited</b> AI Sessions</div>
                    <div class="et-tier-feature"><span class="check">✓</span> All 5 Education Levels</div>
                    <div class="et-tier-feature"><span class="check">✓</span> Visual & Deep-Dive Modes</div>
                    <div class="et-tier-feature"><span class="check">✓</span> <b>YouTube Deep-Linking</b></div>
                    <div class="et-tier-feature"><span class="check">✓</span> Academic Paper Curation</div>
                    <div class="et-tier-feature"><span class="check">✓</span> <b>1.5x XP Multiplier</b></div>
                </div>
            </div>
            """,
            unsafe_allow_html=True,
        )
        st.markdown("<div style='height: 12px'></div>", unsafe_allow_html=True)
        if st.button("Upgrade to Pro", key="tier_pro_btn", type="primary", use_container_width=True):
            _handle_tier_select("pro")

    # ── Ultra Tier ──
    with tier3:
        st.markdown(
            """
            <div class="et-tier-card">
                <div>
                    <div class="et-tier-label">Ultra</div>
                    <div class="et-tier-price">$49<sub>/mo</sub></div>
                    <div class="et-tier-desc">Unlimited priority processing, 1-on-1 agent customization, and early access.</div>
                    <hr style="border: 1px solid #1E293B;" />
                    <div class="et-tier-feature"><span class="check">✓</span> Everything in Pro +</div>
                    <div class="et-tier-feature"><span class="check">✓</span> Priority Multi-Agent Execution</div>
                    <div class="et-tier-feature"><span class="check">✓</span> Unlimited Paper Downloads</div>
                    <div class="et-tier-feature"><span class="check">✓</span> Custom Socratic Persona</div>
                    <div class="et-tier-feature"><span class="check">✓</span> <b>2x XP Boost</b></div>
                    <div class="et-tier-feature"><span class="check">✓</span> 24/7 AI Support</div>
                </div>
            </div>
            """,
            unsafe_allow_html=True,
        )
        st.markdown("<div style='height: 12px'></div>", unsafe_allow_html=True)
        if st.button("Select Ultra", key="tier_ultra_btn", use_container_width=True):
            _handle_tier_select("ultra")

    st.markdown("<br/>", unsafe_allow_html=True)

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    #  CTA BANNER
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    st.markdown(
        """
        <div class="et-cta-banner">
            <h2>Ready to Accelerate Your Learning?</h2>
            <p>
                Join thousands of students and professionals mastering complex topics faster with
                EduTech AI.
            </p>
        </div>
        """,
        unsafe_allow_html=True,
    )

    cta_bottom_l, cta_bottom_c, cta_bottom_r = st.columns([2.5, 1.5, 2.5])
    with cta_bottom_c:
        if st.button("Get Started Free →", key="bottom_cta", use_container_width=True):
            if not user_profile:
                st.session_state["auth_tab"] = "signup"
                st.session_state["view"] = "auth"
                st.toast("🔒 Create an account to get started!", icon="🔒")
                st.rerun()
            else:
                st.session_state["view"] = "learning"
                st.rerun()

    st.markdown("<br/>", unsafe_allow_html=True)

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    #  FOOTER
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    st.markdown('<a name="about"></a>', unsafe_allow_html=True)
    st.markdown(
        """
        <div class="et-footer">
            <div class="et-footer-left">
                <span>EduTech AI</span><br/>
                © 2024 EduTech AI. Empowering cognitive research through education.
            </div>
            <div class="et-footer-links">
                <a href="#">Terms of Service</a>
                <a href="#">Privacy Policy</a>
                <a href="#">Contact Support</a>
                <a href="#">Documentation</a>
            </div>
        </div>
        """,
        unsafe_allow_html=True,
    )


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  AUTH VIEW (Sign In & Sign Up)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
def _render_auth_view():
    """Renders the Sign In & Sign Up auth card."""
    # Minimal navbar for auth page
    back_col, _, logo_col = st.columns([1, 4, 1])
    with back_col:
        if st.button("← Back to Home", key="auth_back"):
            st.session_state["view"] = "home"
            st.rerun()
    with logo_col:
        st.markdown('<div class="et-navbar-logo" style="text-align: right;">⚡ EduTech AI</div>', unsafe_allow_html=True)

    st.markdown("<hr style='border: 1px solid #1E293B; margin: 0.5rem 0 2rem 0;' />", unsafe_allow_html=True)

    # Centered auth form
    st.markdown(
        """
        <div style="text-align: center; margin-bottom: 2rem;">
            <h2 style="font-weight: 800; color: #FAFAFA; margin-bottom: 0.4rem;">Welcome to EduTech AI</h2>
            <p style="color: #94A3B8;">Sign in to your account or create a new one to start learning.</p>
        </div>
        """,
        unsafe_allow_html=True,
    )

    auth_l, auth_c, auth_r = st.columns([1.2, 2, 1.2])

    with auth_c:
        tab_login, tab_signup = st.tabs(["🔐 Sign In", "✨ Create Account"])

        # ── TAB: Sign In ──
        with tab_login:
            with st.form("signin_form"):
                email_input = st.text_input("Email Address", placeholder="student@example.com")
                password_input = st.text_input("Password", type="password")
                submit_signin = st.form_submit_button("Sign In", type="primary", use_container_width=True)

            if submit_signin:
                if not email_input or not password_input:
                    st.error("Please provide both email and password.")
                else:
                    with st.spinner("Authenticating..."):
                        try:
                            from services.auth_service import AuthService
                            from services.database import get_db_session

                            async def _do_login():
                                async with get_db_session() as db:
                                    user = await AuthService.authenticate_user(db, email_input.strip(), password_input)
                                    return AuthService.get_user_current_profile(user)

                            profile = run_async(_do_login())
                            st.session_state["user_profile"] = profile
                            st.session_state["view"] = "learning"
                            st.toast(f"Welcome back, {profile.first_name}! 🎉", icon="✅")
                            st.rerun()
                        except Exception as e:
                            st.error(f"Sign in failed: {e}")

            st.markdown("---")
            st.caption("⚡ Quick Demo Access:")
            q1, q2 = st.columns(2)
            with q1:
                if st.button("🔑 Demo Student", key="demo_student", use_container_width=True):
                    _quick_demo_login("student@edutech.ai", "student123")
            with q2:
                if st.button("⚡ Demo Pro User", key="demo_pro", use_container_width=True):
                    _quick_demo_login("pro@edutech.ai", "pro123")

        # ── TAB: Sign Up ──
        with tab_signup:
            selected_tier = st.session_state.get("selected_tier", "normal")

            with st.form("signup_form"):
                fname = st.text_input("First Name", placeholder="Jane")
                lname = st.text_input("Last Name", placeholder="Doe")
                signup_email = st.text_input("Email Address", placeholder="jane.doe@example.com")
                signup_password = st.text_input("Password", type="password")
                tier_choice = st.selectbox(
                    "Subscription Tier",
                    options=["normal", "pro", "ultra"],
                    index=["normal", "pro", "ultra"].index(selected_tier) if selected_tier in ["normal", "pro", "ultra"] else 0,
                    format_func=lambda x: f"{x.upper()} Tier",
                )
                submit_signup = st.form_submit_button("Create Account & Start Learning", type="primary", use_container_width=True)

            if submit_signup:
                if not fname or not signup_email or not signup_password:
                    st.error("Please fill in all required fields.")
                else:
                    with st.spinner("Creating your account..."):
                        try:
                            from models.user_schemas import UserCreateRequest
                            from services.auth_service import AuthService
                            from services.database import get_db_session
                            from services.user_service import UserService

                            async def _do_signup():
                                async with get_db_session() as db:
                                    req = UserCreateRequest(
                                        first_name=fname.strip(),
                                        last_name=lname.strip() if lname else "User",
                                        email=signup_email.strip(),
                                        password=signup_password,
                                        subscription_tier=tier_choice,
                                    )
                                    created_user = await UserService.create_user(db, req)
                                    return AuthService.get_user_current_profile(created_user)

                            profile = run_async(_do_signup())
                            st.session_state["user_profile"] = profile
                            st.session_state["view"] = "learning"
                            st.toast(f"Welcome to EduTech AI, {profile.first_name}! 🎉", icon="🎉")
                            st.rerun()
                        except Exception as e:
                            st.error(f"Registration failed: {e}")


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  BACKEND HELPERS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
def _quick_demo_login(email: str, pass_word: str):
    """Executes demo login or creates fallback demo profile."""
    try:
        from services.auth_service import AuthService
        from services.database import get_db_session

        async def _do_login():
            async with get_db_session() as db:
                user = await AuthService.authenticate_user(db, email, pass_word)
                return AuthService.get_user_current_profile(user)

        profile = run_async(_do_login())
        st.session_state["user_profile"] = profile
        st.session_state["view"] = "learning"
        st.toast(f"Logged in as {profile.first_name}", icon="⚡")
        st.rerun()
    except Exception:
        from models.auth_schemas import UserCurrentProfileResponse
        from models.subscription_schemas import SubscriptionResponse
        from datetime import datetime, timezone

        tier_name = "pro" if "pro" in email else "normal"
        st.session_state["user_profile"] = UserCurrentProfileResponse(
            id="demo-user-123",
            first_name="Demo",
            last_name="Learner",
            email=email,
            created_at=datetime.now(timezone.utc),
            roles=["student"],
            subscription=SubscriptionResponse(
                id=1,
                user_id="demo-user-123",
                tier=tier_name,
                status="active",
                current_period_start=datetime.now(timezone.utc),
            ),
            privilege_codes=["ET_VIEW_LESSON", "ET_TAKE_QUIZ", "ET_VIEW_SUBSCRIPTION"],
        )
        st.session_state["view"] = "learning"
        st.toast(f"Demo Session ({tier_name.upper()} Tier)", icon="⚡")
        st.rerun()


def _handle_tier_select(target_tier: str):
    """Handles tier button click — enforces auth and updates subscription."""
    user_profile = st.session_state.get("user_profile")
    st.session_state["selected_tier"] = target_tier

    if not user_profile:
        st.session_state["auth_tab"] = "signup"
        st.session_state["view"] = "auth"
        st.toast(f"🔒 Sign in or create an account to select {target_tier.upper()} Tier.", icon="🔒")
        st.rerun()
    else:
        try:
            from models.subscription_schemas import SubscriptionUpdateRequest
            from services.database import get_db_session
            from services.subscription_service import SubscriptionService
            from services.auth_service import AuthService
            from services.user_service import UserService

            async def _update_tier():
                async with get_db_session() as db:
                    await SubscriptionService.update_user_subscription_tier(
                        db,
                        user_id=user_profile.id,
                        request=SubscriptionUpdateRequest(tier=target_tier),
                    )
                    u = await UserService.get_user_by_id(db, user_profile.id)
                    return AuthService.get_user_current_profile(u)

            updated_profile = run_async(_update_tier())
            st.session_state["user_profile"] = updated_profile
            st.toast(f"Subscription updated to {target_tier.upper()}!", icon="⭐")
            st.rerun()
        except Exception as e:
            st.toast(f"Tier selected: {target_tier.upper()}", icon="⚡")
            st.session_state["view"] = "learning"
            st.rerun()
