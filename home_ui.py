# -*- coding: utf-8 -*-
"""
EduTechAI — Glassy AI-Driven Landing Page (n8n.io Inspired)

Premium glassmorphism aesthetic with:
- Deep midnight navy background (#0E0918) with radial gradient glows
- Frosted glass cards with backdrop-filter blur & luminous borders
- CSS keyframe animations (pulse glow, floating, gradient rotation)
- Concise feature cards with glowing icon badges
- Agent squad showcase with glassmorphic hover effects
- Dedicated About section with mission, technology highlights & platform metrics
- Subscription tiers with glowing Pro card
- Auth view with matching frosted glass theme
- Strict auth guard for learning workspace
"""

from __future__ import annotations

import asyncio
import logging
import os
import streamlit as st

logger = logging.getLogger(__name__)


# ─── Helper ──────────────────────────────────────────────────────
def run_async(coro):
    """Run an async coroutine inside Streamlit's sync execution loop."""
    try:
        loop = asyncio.get_event_loop()
    except RuntimeError:
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
    return loop.run_until_complete(coro)





# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  CSS — Glassy n8n-Inspired Theme
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOME_CSS = """
<style>
    /* ── Animations ─────────────────────────────────── */
    @keyframes pulseGlow {
        0%, 100% { opacity: 0.6; }
        50% { opacity: 1; }
    }

    @keyframes floatUp {
        0%, 100% { transform: translateY(0px); }
        50% { transform: translateY(-6px); }
    }

    @keyframes gradientShift {
        0% { background-position: 0% 50%; }
        50% { background-position: 100% 50%; }
        100% { background-position: 0% 50%; }
    }

    @keyframes borderGlow {
        0%, 100% { border-color: rgba(139, 92, 246, 0.3); }
        50% { border-color: rgba(139, 92, 246, 0.6); }
    }

    /* ── Global ─────────────────────────────────────── */
    .stApp {
        background-color: #0E0918 !important;
        color: #FAFAFA !important;
    }

    .block-container {
        padding-top: 1.5rem !important;
    }

    /* ── Completely Eliminate Default Streamlit Header & Deploy Bar ── */
    header[data-testid="stHeader"] {
        display: none !important;
        visibility: hidden !important;
        height: 0px !important;
        min-height: 0px !important;
        padding: 0 !important;
        margin: 0 !important;
        opacity: 0 !important;
        pointer-events: none !important;
    }

    #MainMenu, .stDeployButton, [data-testid="stToolbarActions"], [data-testid="stDecoration"], [data-testid="stStatusWidget"], footer, #edutech-sidebar-master-toggle, [data-testid="stHeaderActionElements"], a[aria-label="Link to heading"] {
        display: none !important;
        visibility: hidden !important;
        height: 0px !important;
        width: 0px !important;
        opacity: 0 !important;
        pointer-events: none !important;
    }

    section[data-testid="stSidebar"] {
        display: none !important;
    }

    /* ── Global Primary Button — Gradient Style ──── */
    .stApp button[kind="primary"] {
        background: linear-gradient(135deg, #EC4899 0%, #A855F7 50%, #3B82F6 100%) !important;
        border: none !important;
        border-radius: 24px !important;
        color: #FFFFFF !important;
        font-weight: 800 !important;
        box-shadow: 0 0 20px rgba(236, 72, 153, 0.35) !important;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1) !important;
    }

    .stApp button[kind="primary"]:hover {
        box-shadow: 0 0 30px rgba(236, 72, 153, 0.6), 0 0 15px rgba(6, 182, 212, 0.4) !important;
        transform: translateY(-2px) !important;
    }

    /* ── Glowing Background Orbs ───────────────────── */
    .glow-bg {
        position: fixed;
        top: 0; left: 0; right: 0; bottom: 0;
        pointer-events: none;
        z-index: 0;
        background:
            radial-gradient(ellipse 600px 400px at 20% 10%, rgba(139, 92, 246, 0.12) 0%, transparent 70%),
            radial-gradient(ellipse 500px 350px at 80% 30%, rgba(236, 72, 153, 0.08) 0%, transparent 70%),
            radial-gradient(ellipse 400px 300px at 50% 80%, rgba(59, 130, 246, 0.06) 0%, transparent 70%);
    }

    /* ── Glass Card Base ───────────────────────────── */
    .glass {
        background: rgba(255, 255, 255, 0.03);
        backdrop-filter: blur(24px);
        -webkit-backdrop-filter: blur(24px);
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 16px;
        transition: all 0.3s ease;
    }

    .glass:hover {
        background: rgba(255, 255, 255, 0.05);
        border-color: rgba(255, 255, 255, 0.15);
    }

    /* ── Glowing Glass Card ────────────────────────── */
    .glass-glow {
        background: rgba(255, 255, 255, 0.03);
        backdrop-filter: blur(24px);
        -webkit-backdrop-filter: blur(24px);
        border: 1px solid rgba(139, 92, 246, 0.2);
        border-radius: 16px;
        box-shadow: 0 0 30px rgba(139, 92, 246, 0.08), inset 0 1px 0 rgba(255, 255, 255, 0.05);
        transition: all 0.3s ease;
    }

    .glass-glow:hover {
        border-color: rgba(139, 92, 246, 0.4);
        box-shadow: 0 0 50px rgba(139, 92, 246, 0.15), inset 0 1px 0 rgba(255, 255, 255, 0.08);
        transform: translateY(-2px);
    }

    /* ── Navbar — Floating Glassmorphism Theme ───────── */
    div[data-testid="stHorizontalBlock"]:has(.et-logo) {
        background: rgba(15, 23, 42, 0.85) !important;
        backdrop-filter: blur(20px) !important;
        -webkit-backdrop-filter: blur(20px) !important;
        border: 1px solid rgba(168, 85, 247, 0.45) !important;
        border-radius: 50px !important;
        padding: 8px 24px !important;
        margin: 0 !important;
        box-shadow: 0 0 30px rgba(168, 85, 247, 0.25), 0 10px 30px rgba(0, 0, 0, 0.5), inset 0 0 20px rgba(168, 85, 247, 0.15) !important;
        width: 100% !important;
        box-sizing: border-box !important;
        align-items: center !important;
        justify-content: space-between !important;
        min-height: 52px !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo) * {
        align-self: center !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo) div[data-testid="column"],
    div[data-testid="stHorizontalBlock"]:has(.et-logo) div[data-testid="stColumn"] {
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        padding: 0 !important;
        margin: 0 !important;
        height: auto !important;
        min-height: 0 !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo) div[data-testid="column"]:first-child,
    div[data-testid="stHorizontalBlock"]:has(.et-logo) div[data-testid="stColumn"]:first-child {
        justify-content: flex-start !important;
        padding-left: 0 !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo) div[data-testid="column"]:first-child *,
    div[data-testid="stHorizontalBlock"]:has(.et-logo) div[data-testid="stColumn"]:first-child * {
        justify-content: flex-start !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo) div[data-testid="column"]:last-child,
    div[data-testid="stHorizontalBlock"]:has(.et-logo) div[data-testid="stColumn"]:last-child {
        justify-content: flex-end !important;
        padding-right: 0 !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo) div[data-testid="stVerticalBlock"],
    div[data-testid="stHorizontalBlock"]:has(.et-logo) div[data-testid="stVerticalBlockBorderWrapper"] {
        gap: 0 !important;
        padding: 0 !important;
        margin: 0 !important;
        justify-content: center !important;
        align-items: center !important;
        align-self: center !important;
        display: flex !important;
        flex-direction: row !important;
        min-height: 0 !important;
        height: auto !important;
    }

    /* Nested horizontal blocks inside the last column (button row) */
    div[data-testid="stHorizontalBlock"]:has(.et-logo) div[data-testid="column"]:last-child div[data-testid="stHorizontalBlock"],
    div[data-testid="stHorizontalBlock"]:has(.et-logo) div[data-testid="stColumn"]:last-child div[data-testid="stHorizontalBlock"] {
        align-items: center !important;
        justify-content: flex-end !important;
        gap: 3px !important;
        margin: 0 !important;
        padding: 0 !important;
        background: transparent !important;
        border: none !important;
        box-shadow: none !important;
        backdrop-filter: none !important;
        -webkit-backdrop-filter: none !important;
        border-radius: 0 !important;
        min-height: 0 !important;
        flex-wrap: nowrap !important;
    }

    /* Force nested sub-columns (button wrappers) to shrink to content */
    div[data-testid="stHorizontalBlock"]:has(.et-logo) div[data-testid="column"]:last-child div[data-testid="stHorizontalBlock"] > div[data-testid="column"],
    div[data-testid="stHorizontalBlock"]:has(.et-logo) div[data-testid="column"]:last-child div[data-testid="stHorizontalBlock"] > div[data-testid="stColumn"],
    div[data-testid="stHorizontalBlock"]:has(.et-logo) div[data-testid="stColumn"]:last-child div[data-testid="stHorizontalBlock"] > div[data-testid="column"],
    div[data-testid="stHorizontalBlock"]:has(.et-logo) div[data-testid="stColumn"]:last-child div[data-testid="stHorizontalBlock"] > div[data-testid="stColumn"] {
        flex: 0 0 auto !important;
        width: auto !important;
        min-width: 0 !important;
        max-width: none !important;
        padding: 0 !important;
        margin: 0 !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo) div.element-container,
    div[data-testid="stHorizontalBlock"]:has(.et-logo) div[data-testid="stElementContainer"] {
        margin: 0 !important;
        padding: 0 !important;
        display: flex !important;
        align-items: center !important;
        align-self: center !important;
        justify-content: center !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo) div.stMarkdown,
    div[data-testid="stHorizontalBlock"]:has(.et-logo) div[data-testid="stMarkdownContainer"] {
        display: flex !important;
        align-items: center !important;
        align-self: center !important;
        margin: 0 !important;
        padding: 0 !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo) div.stMarkdown p,
    div[data-testid="stHorizontalBlock"]:has(.et-logo) div[data-testid="stMarkdownContainer"] p {
        margin: 0 !important;
        padding: 0 !important;
        line-height: 1 !important;
        display: inline-flex !important;
        align-items: center !important;
    }

    .et-logo, .et-logo-simple {
        font-size: 1.38rem;
        font-weight: 900;
        color: #FAFAFA;
        letter-spacing: -0.5px;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        margin: 0;
        line-height: 1;
        align-self: center;
    }

    .et-logo .accent, .et-logo-simple .accent {
        background: linear-gradient(135deg, #EC4899 0%, #A855F7 50%, #3B82F6 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
    }

    .et-logo .badge-ai, .et-logo-simple .badge-ai {
        font-size: 0.65rem;
        font-weight: 800;
        background: rgba(168, 85, 247, 0.2);
        color: #C084FC;
        border: 1px solid rgba(168, 85, 247, 0.4);
        border-radius: 8px;
        padding: 2px 6px;
        margin-left: 2px;
        line-height: 1;
    }

    .et-nav-links {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 12px;
        margin: 0;
        align-self: center;
    }

    .et-nav-links a.nav-pill {
        color: rgba(255, 255, 255, 0.7);
        font-size: 0.95rem;
        font-weight: 600;
        text-decoration: none;
        padding: 6px 16px;
        border-radius: 20px;
        border: 1px solid transparent;
        transition: all 0.25s ease;
        white-space: nowrap;
        line-height: 1;
        display: inline-flex;
        align-items: center;
    }

    .et-nav-links a.nav-pill:hover {
        color: #FFFFFF;
        background: rgba(168, 85, 247, 0.18);
        border-color: rgba(168, 85, 247, 0.4);
        box-shadow: 0 0 15px rgba(168, 85, 247, 0.25);
    }

    /* Modern Compact UI/UX Navbar Buttons Override */
    div[data-testid="stHorizontalBlock"]:has(.et-logo) div[data-testid="stButton"] {
        margin: 0 !important;
        padding: 0 !important;
        display: inline-flex !important;
        align-items: center !important;
        justify-content: center !important;
        align-self: center !important;
        width: auto !important;
        min-width: 0 !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo) button {
        height: 36px !important;
        min-height: 36px !important;
        max-height: 36px !important;
        line-height: 1 !important;
        margin: 0 !important;
        border-radius: 18px !important;
        font-weight: 700 !important;
        font-size: 0.85rem !important;
        display: inline-flex !important;
        align-items: center !important;
        justify-content: center !important;
        padding: 0 1.2rem !important;
        transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1) !important;
        white-space: nowrap !important;
        width: auto !important;
        min-width: 0 !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo) button div[data-testid="stMarkdownContainer"],
    div[data-testid="stHorizontalBlock"]:has(.et-logo) button div[data-testid="stMarkdownContainer"] p,
    div[data-testid="stHorizontalBlock"]:has(.et-logo) button p,
    div[data-testid="stHorizontalBlock"]:has(.et-logo) button span {
        padding: 0 !important;
        margin: 0 !important;
        font-size: 0.85rem !important;
        font-weight: 700 !important;
        line-height: 1 !important;
        display: inline-flex !important;
        align-items: center !important;
        justify-content: center !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo) button[kind="secondary"] {
        background: transparent !important;
        backdrop-filter: none !important;
        -webkit-backdrop-filter: none !important;
        border: none !important;
        outline: none !important;
        box-shadow: none !important;
        color: rgba(255, 255, 255, 0.85) !important;
        padding: 0 0.8rem !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo) button[kind="secondary"]:hover {
        background: rgba(255, 255, 255, 0.08) !important;
        color: #FFFFFF !important;
        transform: translateY(-1px) !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo) button[kind="primary"] {
        background: linear-gradient(135deg, #EC4899 0%, #A855F7 50%, #3B82F6 100%) !important;
        border: none !important;
        border-radius: 18px !important;
        color: #FFFFFF !important;
        font-weight: 800 !important;
        padding: 0 1.2rem !important;
        box-shadow: 0 0 14px rgba(236, 72, 153, 0.35) !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo) button[kind="primary"]:hover {
        box-shadow: 0 0 22px rgba(236, 72, 153, 0.65), 0 0 12px rgba(6, 182, 212, 0.4) !important;
        transform: translateY(-1px) !important;
    }

    /* ── Hero ───────────────────────────────────────── */
    .et-hero {
        text-align: center;
        padding: 3.5rem 1rem 2rem 1rem;
        position: relative;
    }

    .et-hero-badge {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        background: rgba(168, 85, 247, 0.12);
        border: 1px solid rgba(168, 85, 247, 0.35);
        color: #E9D5FF;
        font-size: 0.82rem;
        font-weight: 700;
        padding: 6px 20px;
        border-radius: 24px;
        margin-bottom: 2rem;
        box-shadow: 0 0 20px rgba(168, 85, 247, 0.2);
        animation: pulseGlow 3s ease-in-out infinite;
    }

    .et-hero h1 {
        font-size: 3.6rem;
        font-weight: 900;
        color: #FAFAFA;
        line-height: 1.15;
        letter-spacing: -2px;
        margin-bottom: 1.2rem;
        max-width: 840px;
        margin-left: auto;
        margin-right: auto;
    }

    .et-hero .gradient-text {
        background: linear-gradient(135deg, #EC4899 0%, #A855F7 50%, #3B82F6 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
    }

    .et-hero p {
        font-size: 1.15rem;
        color: rgba(233, 213, 255, 0.75);
        max-width: 660px;
        margin: 0 auto 2.5rem auto;
        line-height: 1.7;
    }
        color: rgba(255, 255, 255, 0.5);
        max-width: 640px;
        margin: 0 auto 2.5rem auto;
        line-height: 1.7;
    }

    /* ── Pixel-Perfect n8n Workflow Canvas — Glassmorphism Theme ────── */
    @keyframes n8nMeshGlow {
        0% { background-position: 0% 50%; }
        50% { background-position: 100% 50%; }
        100% { background-position: 0% 50%; }
    }

    @keyframes n8nPulseGlow {
        0%, 100% { transform: scale(1); opacity: 0.85; box-shadow: 0 0 15px rgba(168, 85, 247, 0.35); }
        50% { transform: scale(1.005); opacity: 1; box-shadow: 0 0 30px rgba(6, 182, 212, 0.6); }
    }

    @keyframes wireShimmer {
        0% { background-position: 0% 50%; }
        100% { background-position: 200% 50%; }
    }

    .n8n-canvas {
        position: relative;
        width: 100%;
        padding: 3rem 1.5rem;
        background: radial-gradient(circle at 20% 30%, rgba(168, 85, 247, 0.18) 0%, transparent 40%),
                    radial-gradient(circle at 80% 70%, rgba(59, 130, 246, 0.18) 0%, transparent 40%),
                    #0B0813;
        backdrop-filter: blur(20px);
        -webkit-backdrop-filter: blur(20px);
        border: 1px solid rgba(168, 85, 247, 0.35);
        border-radius: 20px;
        overflow: hidden;
        box-shadow: 0 20px 60px -15px rgba(124, 58, 237, 0.3), inset 0 0 30px rgba(168, 85, 247, 0.15);
        animation: n8nPulseGlow 4s infinite ease-in-out;
    }

    /* Restored Dot grid matrix background */
    .n8n-canvas::before {
        content: '';
        position: absolute;
        top: 0; left: 0; right: 0; bottom: 0;
        background-image: radial-gradient(circle, rgba(255,255,255,0.08) 1.2px, transparent 1.2px);
        background-size: 20px 20px;
        pointer-events: none;
    }

    .n8n-header {
        text-align: center;
        margin-bottom: 2.5rem;
        position: relative;
        z-index: 1;
    }

    .n8n-header span {
        background: rgba(168, 85, 247, 0.15);
        border: 1px solid rgba(168, 85, 247, 0.4);
        color: #E9D5FF;
        font-size: 0.75rem;
        font-weight: 800;
        padding: 6px 18px;
        border-radius: 20px;
        text-transform: uppercase;
        letter-spacing: 1.5px;
        box-shadow: 0 0 16px rgba(168, 85, 247, 0.3);
    }

    /* Main Diagram Container */
    .n8n-diagram {
        display: flex;
        align-items: center;
        justify-content: center;
        flex-wrap: wrap;
        gap: 12px;
        position: relative;
        z-index: 1;
        width: 100%;
        max-width: 100%;
        overflow: hidden;
        padding: 1rem 0 3rem 0;
    }

    /* 1. Trigger Arch Node */
    .n8n-trigger-node {
        position: relative;
        display: flex;
        align-items: center;
        background: rgba(30, 41, 59, 0.7);
        backdrop-filter: blur(12px);
        border: 1.5px solid rgba(6, 182, 212, 0.5);
        border-radius: 40px 14px 14px 40px;
        padding: 0.8rem 1.1rem 0.8rem 0.6rem;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.4), 0 0 15px rgba(6, 182, 212, 0.25);
    }

    .n8n-trigger-icon {
        width: 44px;
        height: 44px;
        border-radius: 50%;
        background: rgba(6, 182, 212, 0.2);
        border: 1px solid rgba(6, 182, 212, 0.5);
        color: #22D3EE;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.2rem;
        margin-right: 10px;
        box-shadow: 0 0 12px rgba(6, 182, 212, 0.3);
    }

    .n8n-trigger-label {
        font-size: 0.76rem;
        font-weight: 700;
        color: #FAFAFA;
        max-width: 130px;
        line-height: 1.3;
    }

    .n8n-lightning {
        position: absolute;
        left: -8px;
        top: 50%;
        transform: translateY(-50%);
        color: #EF4444;
        font-size: 0.9rem;
    }

    /* Port Dot */
    .n8n-port {
        width: 10px;
        height: 10px;
        border-radius: 50%;
        background: #A78BFA;
        border: 2px solid #0F172A;
        position: absolute;
        box-shadow: 0 0 8px #A78BFA;
    }

    .n8n-port-right { right: -6px; top: 50%; transform: translateY(-50%); }
    .n8n-port-left  { left: -6px; top: 50%; transform: translateY(-50%); }
    .n8n-port-bottom { bottom: -6px; left: 50%; transform: translateX(-50%); }

    /* Wire Line */
    .n8n-wire {
        width: 32px;
        height: 3px;
        background: linear-gradient(90deg, #EC4899, #A855F7, #3B82F6, #06B6D4);
        background-size: 200% 200%;
        animation: wireShimmer 2s infinite linear;
        flex-shrink: 0;
        position: relative;
        box-shadow: 0 0 8px rgba(168, 85, 247, 0.5);
    }

    .n8n-wire::after {
        content: '';
        position: absolute;
        right: -4px;
        top: -3px;
        width: 0; height: 0;
        border-top: 4px solid transparent;
        border-bottom: 4px solid transparent;
        border-left: 6px solid #A855F7;
    }

    /* 2. Main Agent Card Node */
    .n8n-agent-card {
        position: relative;
        background: rgba(30, 41, 59, 0.75);
        backdrop-filter: blur(12px);
        border: 1.5px solid rgba(168, 85, 247, 0.5);
        border-radius: 14px;
        padding: 1.1rem 1.4rem;
        box-shadow: 0 0 30px rgba(168, 85, 247, 0.25);
        min-width: 210px;
    }

    .n8n-agent-header {
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .n8n-agent-icon {
        width: 36px;
        height: 36px;
        border-radius: 10px;
        background: rgba(168, 85, 247, 0.25);
        border: 1px solid rgba(168, 85, 247, 0.4);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.2rem;
        box-shadow: 0 0 12px rgba(168, 85, 247, 0.3);
    }

    .n8n-agent-title {
        font-size: 0.9rem;
        font-weight: 800;
        color: #FAFAFA;
    }

    .n8n-agent-sub {
        font-size: 0.72rem;
        color: rgba(255, 255, 255, 0.5);
    }

    /* Bottom Sub-Ports Labels */
    .n8n-sub-ports {
        display: flex;
        justify-content: space-around;
        margin-top: 0.9rem;
        padding-top: 0.5rem;
        border-top: 1px dashed rgba(255, 255, 255, 0.15);
    }

    .n8n-sub-port-tag {
        font-size: 0.58rem;
        color: rgba(255, 255, 255, 0.5);
        position: relative;
    }

    /* Sub-Nodes (Dashed Below) */
    .n8n-sub-nodes-group {
        position: absolute;
        top: 100%;
        left: 50%;
        transform: translateX(-50%);
        display: flex;
        gap: 16px;
        padding-top: 24px;
    }

    .n8n-sub-node {
        display: flex;
        flex-direction: column;
        align-items: center;
        position: relative;
    }

    .n8n-sub-wire {
        position: absolute;
        top: -24px;
        width: 2px;
        height: 24px;
        border-left: 2px dashed rgba(168, 85, 247, 0.4);
    }

    .n8n-sub-circle {
        width: 52px;
        height: 52px;
        border-radius: 50%;
        background: rgba(30, 41, 59, 0.85);
        backdrop-filter: blur(10px);
        border: 1.5px solid rgba(168, 85, 247, 0.4);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.25rem;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.4), 0 0 12px rgba(168, 85, 247, 0.25);
    }

    .n8n-sub-title {
        font-size: 0.65rem;
        font-weight: 700;
        color: rgba(255, 255, 255, 0.85);
        margin-top: 6px;
        text-align: center;
        white-space: nowrap;
    }

    /* 3. Decision Node */
    .n8n-decision-card {
        position: relative;
        background: rgba(30, 41, 59, 0.75);
        backdrop-filter: blur(12px);
        border: 1.5px solid rgba(16, 185, 129, 0.5);
        border-radius: 14px;
        padding: 1.1rem;
        display: flex;
        align-items: center;
        gap: 10px;
        min-width: 130px;
        box-shadow: 0 0 25px rgba(16, 185, 129, 0.2);
    }

    .n8n-decision-icon {
        width: 36px;
        height: 36px;
        border-radius: 10px;
        background: rgba(16, 185, 129, 0.2);
        border: 1px solid rgba(16, 185, 129, 0.4);
        color: #34D399;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.2rem;
        box-shadow: 0 0 12px rgba(16, 185, 129, 0.3);
    }

    .n8n-branch-arms {
        display: flex;
        flex-direction: column;
        gap: 32px;
        position: relative;
    }

    .n8n-arm-label {
        font-size: 0.62rem;
        font-weight: 700;
        color: rgba(255, 255, 255, 0.45);
        background: #0B0813;
        padding: 1px 6px;
        border-radius: 4px;
        border: 1px solid rgba(255, 255, 255, 0.1);
        margin-left: -8px;
    }

    /* ── Mobile Responsive Adaptations for Workflow Canvas ────── */
    @media (max-width: 768px) {
        .n8n-canvas {
            padding: 1.8rem 0.8rem;
            border-radius: 16px;
        }

        .n8n-header {
            margin-bottom: 1.5rem;
        }

        .n8n-header span {
            font-size: 0.68rem;
            padding: 5px 12px;
            letter-spacing: 0.8px;
        }

        .n8n-diagram {
            flex-direction: column;
            align-items: center;
            gap: 20px;
            padding: 0.5rem 0 2rem 0;
            width: 100%;
        }

        .n8n-wire {
            width: 3px;
            height: 24px;
            margin: 4px auto;
        }

        .n8n-wire::after {
            right: -2px;
            top: auto;
            bottom: -4px;
            border-left: 4px solid transparent;
            border-right: 4px solid transparent;
            border-top: 6px solid #A855F7;
        }

        .n8n-agent-card {
            width: 100%;
            max-width: 280px;
            min-width: unset;
            margin-bottom: 75px;
        }

        .n8n-trigger-node {
            width: 100%;
            max-width: 280px;
        }

        .n8n-decision-card {
            width: 100%;
            max-width: 280px;
        }

        .n8n-branch-arms {
            flex-direction: column;
            align-items: center;
            width: 100%;
            gap: 20px;
        }

        .n8n-sub-nodes-group {
            gap: 8px;
        }

        .n8n-sub-circle {
            width: 44px;
            height: 44px;
            font-size: 1.05rem;
        }

        .n8n-sub-title {
            font-size: 0.6rem;
        }
    }

    /* ── Section Titles — Team of AI Agents Persona ──── */
    .section-badge {
        display: table;
        margin: 0 auto 0.8rem auto;
        background: rgba(168, 85, 247, 0.12);
        border: 1px solid rgba(168, 85, 247, 0.35);
        color: #E9D5FF;
        font-size: 0.78rem;
        font-weight: 700;
        padding: 5px 18px;
        border-radius: 24px;
        box-shadow: 0 0 20px rgba(168, 85, 247, 0.2);
        text-transform: uppercase;
        letter-spacing: 1px;
    }

    .section-title {
        font-size: 2.8rem;
        font-weight: 900;
        color: #FAFAFA;
        text-align: center;
        margin-bottom: 0.6rem;
        letter-spacing: -1.5px;
        line-height: 1.2;
    }

    .gradient-text {
        background: linear-gradient(135deg, #EC4899 0%, #A855F7 50%, #3B82F6 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        display: inline;
    }

    .section-sub {
        font-size: 1.05rem;
        color: rgba(233, 213, 255, 0.75);
        text-align: center;
        max-width: 620px;
        margin: 0 auto 2.8rem auto;
        line-height: 1.6;
    }

    /* Top Accent Neon Glow Strip for All Cards */
    .feat-card, .agent-glass, .about-card, .price-glass {
        position: relative;
        overflow: hidden;
        border-radius: 20px !important;
    }

    .feat-card::before, .agent-glass::before, .about-card::before, .price-glass::before {
        content: '';
        position: absolute;
        top: 0; left: 15%; right: 15%; height: 2px;
        background: linear-gradient(90deg, transparent 0%, #EC4899 30%, #A855F7 50%, #06B6D4 70%, transparent 100%);
        border-radius: 2px;
        opacity: 0.7;
        transition: opacity 0.3s ease, box-shadow 0.3s ease;
    }

    .feat-card:hover::before, .agent-glass:hover::before, .about-card:hover::before, .price-glass:hover::before {
        opacity: 1;
        box-shadow: 0 0 14px #EC4899, 0 0 20px #A855F7;
    }

    /* Card Headings — Exact Logo Gradient Touch */
    .feat-card h4, .agent-glass h4, .about-card h3, .price-name {
        background: linear-gradient(135deg, #EC4899 0%, #A855F7 50%, #3B82F6 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        font-weight: 800;
    }

    /* ── Feature Cards — Glassmorphism Gradient Theme ───────── */
    .feat-card {
        background: linear-gradient(135deg, rgba(30, 41, 59, 0.85) 0%, rgba(124, 58, 237, 0.16) 50%, rgba(15, 23, 42, 0.9) 100%);
        backdrop-filter: blur(16px);
        -webkit-backdrop-filter: blur(16px);
        border: 1px solid rgba(168, 85, 247, 0.4);
        padding: 2rem 1.6rem;
        text-align: center;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        min-height: 210px;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4), inset 0 0 20px rgba(168, 85, 247, 0.1);
    }

    .feat-card:hover {
        background: linear-gradient(135deg, rgba(124, 58, 237, 0.28) 0%, rgba(59, 130, 246, 0.2) 50%, rgba(15, 23, 42, 0.95) 100%);
        border-color: rgba(168, 85, 247, 0.75);
        box-shadow: 0 0 40px rgba(168, 85, 247, 0.35), 0 12px 35px rgba(0, 0, 0, 0.5);
        transform: translateY(-5px);
    }

    .feat-icon {
        width: 52px;
        height: 52px;
        border-radius: 14px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-size: 1.4rem;
        margin-bottom: 1rem;
        box-shadow: 0 0 20px rgba(168, 85, 247, 0.25);
    }

    .feat-card h4 {
        font-size: 1.05rem;
        font-weight: 700;
        color: #FAFAFA;
        margin-bottom: 0.4rem;
    }

    .feat-card p {
        font-size: 0.85rem;
        color: rgba(255, 255, 255, 0.55);
        line-height: 1.5;
        margin: 0;
    }

    /* Icon color variants */
    .icon-violet  { background: rgba(168, 85, 247, 0.2); color: #C084FC; border: 1px solid rgba(168, 85, 247, 0.4); }
    .icon-blue    { background: rgba(59, 130, 246, 0.2); color: #60A5FA; border: 1px solid rgba(59, 130, 246, 0.4); }
    .icon-cyan    { background: rgba(6, 182, 212, 0.2); color: #22D3EE; border: 1px solid rgba(6, 182, 212, 0.4); }
    .icon-green   { background: rgba(16, 185, 129, 0.2); color: #34D399; border: 1px solid rgba(16, 185, 129, 0.4); }
    .icon-amber   { background: rgba(251, 191, 36, 0.2); color: #FBBF24; border: 1px solid rgba(251, 191, 36, 0.4); }
    .icon-pink    { background: rgba(236, 72, 153, 0.2); color: #F472B6; border: 1px solid rgba(236, 72, 153, 0.4); }

    /* ── Agent Cards — Glassmorphism Gradient Theme (Matching Why EduTech AI?) ─── */
    .agent-glass {
        background: linear-gradient(135deg, rgba(30, 41, 59, 0.85) 0%, rgba(124, 58, 237, 0.16) 50%, rgba(15, 23, 42, 0.9) 100%);
        backdrop-filter: blur(16px);
        -webkit-backdrop-filter: blur(16px);
        border: 1px solid rgba(168, 85, 247, 0.4);
        border-radius: 16px;
        padding: 1.8rem 1.4rem;
        text-align: center;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        min-height: 200px;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4), inset 0 0 20px rgba(168, 85, 247, 0.1);
    }

    .agent-glass:hover {
        background: linear-gradient(135deg, rgba(124, 58, 237, 0.28) 0%, rgba(59, 130, 246, 0.2) 50%, rgba(15, 23, 42, 0.95) 100%);
        border-color: rgba(168, 85, 247, 0.75);
        box-shadow: 0 0 40px rgba(168, 85, 247, 0.35), 0 12px 35px rgba(0, 0, 0, 0.5);
        transform: translateY(-5px);
    }

    .agent-glass h4 {
        font-size: 1.05rem;
        font-weight: 700;
        color: #FAFAFA;
        margin-bottom: 0.4rem;
    }

    .agent-glass p {
        font-size: 0.85rem;
        color: rgba(255, 255, 255, 0.55);
        line-height: 1.5;
        margin: 0;
    }

    .agent-icon {
        width: 52px;
        height: 52px;
        border-radius: 14px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-size: 1.4rem;
        margin-bottom: 1rem;
        box-shadow: 0 0 20px rgba(168, 85, 247, 0.25);
    }

    /* ── About Cards & Metric Pills — Glassmorphism Gradient Theme ─── */
    .about-card {
        background: linear-gradient(135deg, rgba(30, 41, 59, 0.85) 0%, rgba(168, 85, 247, 0.18) 50%, rgba(15, 23, 42, 0.9) 100%);
        backdrop-filter: blur(20px);
        -webkit-backdrop-filter: blur(20px);
        border: 1px solid rgba(168, 85, 247, 0.4);
        border-radius: 18px;
        padding: 2rem 1.8rem;
        height: 100%;
        transition: all 0.3s ease;
        box-shadow: 0 15px 35px rgba(0, 0, 0, 0.4), inset 0 0 25px rgba(124, 58, 237, 0.12);
    }

    .about-card:hover {
        background: linear-gradient(135deg, rgba(124, 58, 237, 0.25) 0%, rgba(236, 72, 153, 0.18) 50%, rgba(15, 23, 42, 0.95) 100%);
        border-color: rgba(168, 85, 247, 0.75);
        box-shadow: 0 0 40px rgba(124, 58, 237, 0.35);
        transform: translateY(-4px);
    }

    .about-card h3 {
        font-size: 1.25rem;
        font-weight: 800;
        color: #FAFAFA;
        margin-bottom: 0.8rem;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .about-card p {
        font-size: 0.9rem;
        color: rgba(255, 255, 255, 0.55);
        line-height: 1.65;
        margin: 0;
    }

    .stat-pill {
        background: linear-gradient(135deg, rgba(30, 41, 59, 0.85) 0%, rgba(124, 58, 237, 0.15) 50%, rgba(15, 23, 42, 0.9) 100%);
        backdrop-filter: blur(16px);
        -webkit-backdrop-filter: blur(16px);
        border: 1px solid rgba(168, 85, 247, 0.4);
        border-radius: 16px;
        padding: 1.5rem 1rem;
        text-align: center;
        transition: all 0.3s ease;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.4);
    }

    .stat-pill:hover {
        background: linear-gradient(135deg, rgba(124, 58, 237, 0.25) 0%, rgba(6, 182, 212, 0.2) 100%);
        border-color: rgba(168, 85, 247, 0.75);
        box-shadow: 0 0 35px rgba(168, 85, 247, 0.35);
        transform: translateY(-3px);
    }

    .stat-number {
        font-size: 2.2rem;
        font-weight: 900;
        background: linear-gradient(135deg, #EC4899 0%, #A855F7 50%, #06B6D4 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        line-height: 1;
        margin-bottom: 0.3rem;
    }

    .stat-label {
        font-size: 0.8rem;
        font-weight: 600;
        color: rgba(255, 255, 255, 0.55);
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    /* ── Pricing Cards — Glassmorphism Gradient Theme ───────── */
    .price-glass {
        background: linear-gradient(135deg, rgba(30, 41, 59, 0.85) 0%, rgba(124, 58, 237, 0.12) 50%, rgba(15, 23, 42, 0.9) 100%);
        backdrop-filter: blur(20px);
        -webkit-backdrop-filter: blur(20px);
        border: 1px solid rgba(168, 85, 247, 0.35);
        border-radius: 20px !important;
        padding: 2.4rem 1.5rem 2rem 1.5rem;
        position: relative;
        overflow: visible !important;
        height: 100%;
        display: flex;
        flex-direction: column;
        transition: all 0.3s ease;
        box-shadow: 0 15px 35px rgba(0, 0, 0, 0.4);
    }

    .price-glass:hover {
        background: linear-gradient(135deg, rgba(124, 58, 237, 0.2) 0%, rgba(59, 130, 246, 0.15) 50%, rgba(15, 23, 42, 0.95) 100%);
        border-color: rgba(168, 85, 247, 0.65);
        box-shadow: 0 0 35px rgba(168, 85, 247, 0.25);
        transform: translateY(-4px);
    }

    .price-glass-pro {
        background: linear-gradient(135deg, rgba(124, 58, 237, 0.25) 0%, rgba(236, 72, 153, 0.18) 50%, rgba(15, 23, 42, 0.92) 100%);
        border: 1.5px solid rgba(168, 85, 247, 0.75);
        box-shadow: 0 0 45px rgba(168, 85, 247, 0.35);
        animation: n8nPulseGlow 4s ease-in-out infinite;
    }

    .price-glass-pro:hover {
        background: linear-gradient(135deg, rgba(124, 58, 237, 0.35) 0%, rgba(236, 72, 153, 0.28) 50%, rgba(15, 23, 42, 0.95) 100%);
        border-color: rgba(168, 85, 247, 0.95);
        box-shadow: 0 0 55px rgba(168, 85, 247, 0.45);
        transform: translateY(-4px);
    }

    .price-badge {
        position: absolute;
        top: -14px;
        left: 50%;
        transform: translateX(-50%);
        background: linear-gradient(135deg, #EC4899 0%, #A855F7 50%, #3B82F6 100%);
        color: #FAFAFA;
        font-size: 0.7rem;
        font-weight: 800;
        padding: 5px 16px;
        border-radius: 20px;
        letter-spacing: 1px;
        text-transform: uppercase;
        box-shadow: 0 0 20px rgba(236, 72, 153, 0.5);
        white-space: nowrap;
        z-index: 10;
    }

    .price-name {
        font-size: 1.4rem;
        font-weight: 800;
        color: #FAFAFA;
        margin-top: 0.3rem;
    }

    .price-amount {
        font-size: 2.8rem;
        font-weight: 900;
        color: #FAFAFA;
        line-height: 1;
        margin: 0.3rem 0 0.6rem 0;
    }

    .price-amount sub {
        font-size: 1rem;
        font-weight: 400;
        color: rgba(255, 255, 255, 0.35);
    }

    .price-desc {
        font-size: 0.85rem;
        color: rgba(255, 255, 255, 0.4);
        margin-bottom: 1.5rem;
        line-height: 1.5;
        min-height: 42px;
    }

    .price-feat {
        display: flex;
        align-items: center;
        gap: 10px;
        font-size: 0.85rem;
        color: rgba(255, 255, 255, 0.6);
        margin-bottom: 0.5rem;
    }

    .price-feat .chk {
        color: #10B981;
        font-weight: 700;
    }

    /* ── CTA Banner ────────────────────────────────── */
    .cta-banner {
        text-align: center;
        padding: 4rem 1rem;
        background:
            radial-gradient(ellipse 600px 300px at 50% 50%, rgba(139, 92, 246, 0.1) 0%, transparent 70%);
        border-top: 1px solid rgba(255, 255, 255, 0.04);
        border-bottom: 1px solid rgba(255, 255, 255, 0.04);
        margin: 2rem 0;
    }

    .cta-banner h2 {
        font-size: 2.2rem;
        font-weight: 900;
        background: linear-gradient(135deg, #EC4899 0%, #A855F7 50%, #3B82F6 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        margin-bottom: 0.6rem;
    }

    .cta-banner p {
        font-size: 1rem;
        color: rgba(255, 255, 255, 0.4);
        max-width: 520px;
        margin: 0 auto 2rem auto;
    }

    /* ── Footer ────────────────────────────────────── */
    .et-footer {
        padding: 2rem 0;
        border-top: 1px solid rgba(255, 255, 255, 0.05);
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .et-footer-left {
        color: rgba(255, 255, 255, 0.3);
        font-size: 0.82rem;
    }

    .et-footer-left span {
        font-weight: 700;
        color: rgba(255, 255, 255, 0.5);
    }

    .et-footer-links {
        display: flex;
        gap: 24px;
    }

    .et-footer-links a {
        color: rgba(255, 255, 255, 0.3);
        font-size: 0.82rem;
        text-decoration: none;
        transition: color 0.2s;
    }

    .et-footer-links a:hover { color: #FAFAFA; }

    /* ── Auth Page Intro Header & Instructions ── */
    .auth-header-container {
        text-align: center !important;
        margin: 0 auto 1rem auto !important;
        max-width: 800px !important;
    }

    .auth-badge {
        display: inline-flex !important;
        background: rgba(168, 85, 247, 0.1) !important;
        border: 1px solid rgba(168, 85, 247, 0.3) !important;
        color: #C084FC !important;
        font-size: 0.68rem !important;
        font-weight: 800 !important;
        letter-spacing: 1.5px !important;
        padding: 5px 12px !important;
        border-radius: 20px !important;
        margin-bottom: 0.8rem !important;
    }

    .auth-title {
        font-size: 2.1rem !important;
        font-weight: 900 !important;
        color: #FAFAFA !important;
        margin-top: 0 !important;
        margin-bottom: 0.6rem !important;
        line-height: 1.25 !important;
    }

    .auth-subtitle {
        font-size: 0.98rem !important;
        color: rgba(233, 213, 255, 0.75) !important;
        margin-bottom: 1.2rem !important;
        line-height: 1.5 !important;
    }

    .auth-instructions-pill {
        background: linear-gradient(135deg, rgba(30, 41, 59, 0.7) 0%, rgba(124, 58, 237, 0.15) 50%, rgba(15, 23, 42, 0.8) 100%) !important;
        backdrop-filter: blur(20px) !important;
        -webkit-backdrop-filter: blur(20px) !important;
        border: 1px solid rgba(168, 85, 247, 0.4) !important;
        border-radius: 16px !important;
        padding: 14px 20px !important;
        display: inline-flex !important;
        align-items: center !important;
        gap: 16px !important;
        text-align: left !important;
        max-width: 720px !important;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4), inset 0 0 20px rgba(168, 85, 247, 0.15) !important;
        transition: all 0.3s ease !important;
        margin-top: 0.5rem !important;
    }

    .auth-instructions-pill:hover {
        background: linear-gradient(135deg, rgba(124, 58, 237, 0.25) 0%, rgba(59, 130, 246, 0.15) 50%, rgba(15, 23, 42, 0.9) 100%) !important;
        border-color: rgba(168, 85, 247, 0.7) !important;
        box-shadow: 0 0 30px rgba(168, 85, 247, 0.25), 0 12px 35px rgba(0, 0, 0, 0.5) !important;
        transform: translateY(-2px) !important;
    }

    .auth-instructions-pill .instructions-icon {
        background: rgba(168, 85, 247, 0.2) !important;
        border: 1px solid rgba(168, 85, 247, 0.4) !important;
        width: 48px !important;
        height: 48px !important;
        min-width: 48px !important;
        border-radius: 12px !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        font-size: 1.5rem !important;
        box-shadow: 0 0 20px rgba(168, 85, 247, 0.3) !important;
    }

    .auth-instructions-pill .instructions-text {
        display: flex !important;
        flex-direction: column !important;
        gap: 6px !important;
    }

    .auth-instructions-pill h4 {
        margin: 0 !important;
        font-size: 0.95rem !important;
        font-weight: 800 !important;
        letter-spacing: 0.5px !important;
        text-transform: uppercase !important;
    }

    .auth-instructions-pill h4 .gradient-text {
        background: linear-gradient(135deg, #EC4899 0%, #A855F7 50%, #3B82F6 100%) !important;
        -webkit-background-clip: text !important;
        -webkit-text-fill-color: transparent !important;
        display: inline !important;
    }

    .auth-instructions-pill p {
        font-size: 0.88rem !important;
        color: rgba(255, 255, 255, 0.75) !important;
        line-height: 1.55 !important;
        margin: 0 !important;
    }

    .auth-instructions-pill p b {
        color: #E9D5FF !important;
        font-weight: 700 !important;
    }

    /* ── Native Interactive Flowchart Branch Buttons (Zero Page Reload) ── */
    div.st-key-flowchart_signin_btn,
    div.st-key-flowchart_signup_btn,
    div[data-testid="stColumn"]:has(#signin-branch-marker) div[data-testid="stButton"],
    div[data-testid="stColumn"]:has(#signup-branch-marker) div[data-testid="stButton"] {
        width: 100% !important;
        margin: 0 !important;
        padding: 0 !important;
    }

    div.st-key-flowchart_signin_btn button,
    div.st-key-flowchart_signup_btn button,
    div[data-testid="stColumn"]:has(#signin-branch-marker) button,
    div[data-testid="stColumn"]:has(#signup-branch-marker) button {
        display: flex !important;
        flex-direction: column !important;
        align-items: flex-start !important;
        justify-content: center !important;
        background: linear-gradient(135deg, rgba(20, 13, 33, 0.95) 0%, rgba(30, 20, 50, 0.85) 100%) !important;
        backdrop-filter: blur(16px) !important;
        -webkit-backdrop-filter: blur(16px) !important;
        border-radius: 16px !important;
        padding: 12px 18px !important;
        min-height: 74px !important;
        width: 100% !important;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.4), inset 0 0 20px rgba(168, 85, 247, 0.08) !important;
        transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1) !important;
        position: relative !important;
        overflow: hidden !important;
        box-sizing: border-box !important;
        cursor: pointer !important;
        text-align: left !important;
    }

    /* Top Neon Line for Buttons */
    div.st-key-flowchart_signin_btn button::before,
    div.st-key-flowchart_signup_btn button::before,
    div[data-testid="stColumn"]:has(#signin-branch-marker) button::before,
    div[data-testid="stColumn"]:has(#signup-branch-marker) button::before {
        content: '' !important;
        position: absolute !important;
        top: 0 !important; left: 15% !important; right: 15% !important; height: 2px !important;
        background: linear-gradient(90deg, transparent 0%, #EC4899 30%, #A855F7 50%, #06B6D4 70%, transparent 100%) !important;
        border-radius: 2px !important;
        opacity: 0.65 !important;
        transition: opacity 0.3s ease, box-shadow 0.3s ease !important;
    }

    div.st-key-flowchart_signin_btn button:hover::before,
    div.st-key-flowchart_signup_btn button:hover::before,
    div[data-testid="stColumn"]:has(#signin-branch-marker) button:hover::before,
    div[data-testid="stColumn"]:has(#signup-branch-marker) button:hover::before {
        opacity: 1 !important;
        box-shadow: 0 0 12px #EC4899, 0 0 16px #A855F7 !important;
    }

    /* Borders and Hover for Sign In */
    div.st-key-flowchart_signin_btn button,
    div[data-testid="stColumn"]:has(#signin-branch-marker) button {
        border: 1.5px solid rgba(34, 197, 94, 0.45) !important;
    }
    div.st-key-flowchart_signin_btn button:hover,
    div[data-testid="stColumn"]:has(#signin-branch-marker) button:hover {
        border-color: rgba(34, 197, 94, 0.95) !important;
        transform: translateY(-2px) !important;
        box-shadow: 0 0 30px rgba(34, 197, 94, 0.45), 0 10px 30px rgba(0, 0, 0, 0.5) !important;
    }

    /* Borders and Hover for Sign Up */
    div.st-key-flowchart_signup_btn button,
    div[data-testid="stColumn"]:has(#signup-branch-marker) button {
        border: 1.5px solid rgba(168, 85, 247, 0.45) !important;
    }
    div.st-key-flowchart_signup_btn button:hover,
    div[data-testid="stColumn"]:has(#signup-branch-marker) button:hover {
        border-color: rgba(168, 85, 247, 0.95) !important;
        transform: translateY(-2px) !important;
        box-shadow: 0 0 30px rgba(168, 85, 247, 0.45), 0 10px 30px rgba(0, 0, 0, 0.5) !important;
    }

    /* Paragraph Container Inside Button */
    div.st-key-flowchart_signin_btn button div[data-testid="stMarkdownContainer"],
    div.st-key-flowchart_signup_btn button div[data-testid="stMarkdownContainer"],
    div[data-testid="stColumn"]:has(#signin-branch-marker) button div[data-testid="stMarkdownContainer"],
    div[data-testid="stColumn"]:has(#signup-branch-marker) button div[data-testid="stMarkdownContainer"] {
        width: 100% !important;
        text-align: left !important;
    }

    div.st-key-flowchart_signin_btn button div[data-testid="stMarkdownContainer"] p,
    div.st-key-flowchart_signup_btn button div[data-testid="stMarkdownContainer"] p,
    div[data-testid="stColumn"]:has(#signin-branch-marker) button div[data-testid="stMarkdownContainer"] p,
    div[data-testid="stColumn"]:has(#signup-branch-marker) button div[data-testid="stMarkdownContainer"] p {
        display: flex !important;
        flex-direction: column !important;
        align-items: flex-start !important;
        text-align: left !important;
        gap: 3px !important;
        margin: 0 !important;
        padding: 0 !important;
        white-space: pre-line !important;
        font-size: 0.74rem !important;
        color: rgba(233, 213, 255, 0.72) !important;
        line-height: 1.35 !important;
    }

    /* First Line: Step Tag (Bold) */
    div.st-key-flowchart_signin_btn button div[data-testid="stMarkdownContainer"] p::first-line,
    div[data-testid="stColumn"]:has(#signin-branch-marker) button div[data-testid="stMarkdownContainer"] p::first-line {
        font-size: 0.70rem !important;
        font-weight: 900 !important;
        color: #4ADE80 !important;
        letter-spacing: 1.2px !important;
        text-transform: uppercase !important;
        line-height: 1.25 !important;
    }

    div.st-key-flowchart_signup_btn button div[data-testid="stMarkdownContainer"] p::first-line,
    div[data-testid="stColumn"]:has(#signup-branch-marker) button div[data-testid="stMarkdownContainer"] p::first-line {
        font-size: 0.70rem !important;
        font-weight: 900 !important;
        color: #C084FC !important;
        letter-spacing: 1.2px !important;
        text-transform: uppercase !important;
        line-height: 1.25 !important;
    }

    /* ── Auth Page — Glowing Split-Screen Layout ──────── */

    /* Floating Navbar Pill on Auth View — Luminous Glow */
    div[data-testid="stHorizontalBlock"]:has(.et-logo-simple) {
        background: rgba(15, 23, 42, 0.85) !important;
        backdrop-filter: blur(20px) !important;
        -webkit-backdrop-filter: blur(20px) !important;
        border: 1px solid rgba(168, 85, 247, 0.45) !important;
        border-radius: 50px !important;
        padding: 8px 24px !important;
        margin: 0 !important;
        box-shadow: 0 0 30px rgba(168, 85, 247, 0.25), 0 10px 30px rgba(0, 0, 0, 0.5), inset 0 0 20px rgba(168, 85, 247, 0.15) !important;
        width: 100% !important;
        box-sizing: border-box !important;
        align-items: center !important;
        justify-content: space-between !important;
        min-height: 52px !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo-simple) * {
        align-self: center !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo-simple) div[data-testid="column"],
    div[data-testid="stHorizontalBlock"]:has(.et-logo-simple) div[data-testid="stColumn"] {
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        padding: 0 !important;
        margin: 0 !important;
        height: auto !important;
        min-height: 0 !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo-simple) div[data-testid="column"]:first-child,
    div[data-testid="stHorizontalBlock"]:has(.et-logo-simple) div[data-testid="stColumn"]:first-child {
        justify-content: flex-start !important;
        padding-left: 0 !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo-simple) div[data-testid="column"]:first-child *,
    div[data-testid="stHorizontalBlock"]:has(.et-logo-simple) div[data-testid="stColumn"]:first-child * {
        justify-content: flex-start !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo-simple) div[data-testid="column"]:last-child,
    div[data-testid="stHorizontalBlock"]:has(.et-logo-simple) div[data-testid="stColumn"]:last-child {
        justify-content: flex-end !important;
        padding-right: 0 !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo-simple) div[data-testid="stVerticalBlock"],
    div[data-testid="stHorizontalBlock"]:has(.et-logo-simple) div[data-testid="stVerticalBlockBorderWrapper"] {
        gap: 0 !important;
        padding: 0 !important;
        margin: 0 !important;
        justify-content: center !important;
        align-items: center !important;
        align-self: center !important;
        display: flex !important;
        flex-direction: row !important;
        min-height: 0 !important;
        height: auto !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo-simple) div.element-container,
    div[data-testid="stHorizontalBlock"]:has(.et-logo-simple) div[data-testid="stElementContainer"] {
        margin: 0 !important;
        padding: 0 !important;
        display: flex !important;
        align-items: center !important;
        align-self: center !important;
        justify-content: center !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo-simple) div[data-testid="column"]:last-child div.element-container,
    div[data-testid="stHorizontalBlock"]:has(.et-logo-simple) div[data-testid="column"]:last-child div[data-testid="stElementContainer"],
    div[data-testid="stHorizontalBlock"]:has(.et-logo-simple) div[data-testid="stColumn"]:last-child div.element-container,
    div[data-testid="stHorizontalBlock"]:has(.et-logo-simple) div[data-testid="stColumn"]:last-child div[data-testid="stElementContainer"] {
        justify-content: flex-end !important;
        width: 100% !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo-simple) div.stMarkdown,
    div[data-testid="stHorizontalBlock"]:has(.et-logo-simple) div[data-testid="stMarkdownContainer"] {
        display: flex !important;
        align-items: center !important;
        align-self: center !important;
        margin: 0 !important;
        padding: 0 !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo-simple) div.stMarkdown p,
    div[data-testid="stHorizontalBlock"]:has(.et-logo-simple) div[data-testid="stMarkdownContainer"] p {
        margin: 0 !important;
        padding: 0 !important;
        line-height: 1 !important;
        display: inline-flex !important;
        align-items: center !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo-simple) div[data-testid="stButton"] {
        margin: 0 !important;
        padding: 0 !important;
        display: inline-flex !important;
        align-items: center !important;
        justify-content: flex-end !important;
        align-self: center !important;
        width: auto !important;
        min-width: 0 !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo-simple) div[data-testid="column"]:last-child div[data-testid="stButton"],
    div[data-testid="stHorizontalBlock"]:has(.et-logo-simple) div[data-testid="stColumn"]:last-child div[data-testid="stButton"] {
        width: 100% !important;
        justify-content: flex-end !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo-simple) button {
        height: 36px !important;
        min-height: 36px !important;
        max-height: 36px !important;
        line-height: 1 !important;
        margin: 0 !important;
        border-radius: 18px !important;
        font-weight: 700 !important;
        font-size: 0.85rem !important;
        display: inline-flex !important;
        align-items: center !important;
        justify-content: center !important;
        padding: 0 1.2rem !important;
        background: rgba(255, 255, 255, 0.06) !important;
        color: #FAFAFA !important;
        border: 1px solid rgba(168, 85, 247, 0.45) !important;
        box-shadow: 0 0 15px rgba(168, 85, 247, 0.2) !important;
        transition: all 0.25s ease !important;
        white-space: nowrap !important;
        width: auto !important;
        min-width: 0 !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-logo-simple) button:hover {
        background: rgba(168, 85, 247, 0.25) !important;
        border-color: rgba(168, 85, 247, 0.85) !important;
        color: #FFFFFF !important;
        box-shadow: 0 0 25px rgba(168, 85, 247, 0.4) !important;
        transform: translateY(-1px) !important;
    }

    /* ── Constellation / Network Node Overlay Background ── */
    .glow-bg-constellation {
        position: fixed;
        top: 0; left: 0; right: 0; bottom: 0;
        pointer-events: none;
        z-index: 0;
        background:
            radial-gradient(ellipse 650px 450px at 15% 20%, rgba(168, 85, 247, 0.16) 0%, transparent 70%),
            radial-gradient(ellipse 550px 380px at 85% 30%, rgba(236, 72, 153, 0.12) 0%, transparent 70%),
            radial-gradient(ellipse 450px 320px at 50% 85%, rgba(59, 130, 246, 0.1) 0%, transparent 70%);
        background-image:
            radial-gradient(circle at 12% 28%, rgba(168, 85, 247, 0.25) 0px, rgba(168, 85, 247, 0.25) 2px, transparent 3px),
            radial-gradient(circle at 28% 68%, rgba(59, 130, 246, 0.25) 0px, rgba(59, 130, 246, 0.25) 2px, transparent 3px),
            radial-gradient(circle at 68% 18%, rgba(236, 72, 153, 0.25) 0px, rgba(236, 72, 153, 0.25) 2px, transparent 3px),
            radial-gradient(circle at 88% 78%, rgba(168, 85, 247, 0.25) 0px, rgba(168, 85, 247, 0.25) 2px, transparent 3px),
            radial-gradient(circle at 48% 12%, rgba(6, 182, 212, 0.25) 0px, rgba(6, 182, 212, 0.25) 2px, transparent 3px);
    }

    /* Auth Left Column — AI Workflow Flow Canvas (Luminous Glow) */
    div[data-testid="stColumn"]:has(#auth-canvas-marker),
    .auth-flow-canvas {
        background: radial-gradient(circle at 20% 30%, rgba(168, 85, 247, 0.18) 0%, transparent 40%),
                    radial-gradient(circle at 80% 70%, rgba(59, 130, 246, 0.18) 0%, transparent 40%),
                    #0B0813 !important;
        backdrop-filter: blur(25px) !important;
        -webkit-backdrop-filter: blur(25px) !important;
        border: 1px solid rgba(168, 85, 247, 0.35) !important;
        border-radius: 24px !important;
        padding: 1.8rem 1.8rem 2rem 1.8rem !important;
        box-shadow: 0 20px 60px -15px rgba(124, 58, 237, 0.3), inset 0 0 30px rgba(168, 85, 247, 0.15) !important;
        height: 100% !important;
        box-sizing: border-box !important;
        position: relative !important;
        overflow: hidden !important;
        animation: n8nPulseGlow 4s infinite ease-in-out !important;
    }

    /* Auth Right Column — Glassmorphic Auth Form Card (Luminous Glow) */
    div[data-testid="stColumn"]:has(#auth-form-card-marker),
    .auth-form-card {
        background: rgba(15, 23, 42, 0.88) !important;
        backdrop-filter: blur(25px) !important;
        -webkit-backdrop-filter: blur(25px) !important;
        border: 1px solid rgba(168, 85, 247, 0.45) !important;
        border-radius: 24px !important;
        padding: 1.8rem 2.2rem 2rem 2.2rem !important;
        box-shadow: 0 20px 60px -15px rgba(168, 85, 247, 0.35), inset 0 0 30px rgba(168, 85, 247, 0.15) !important;
        position: relative !important;
        box-sizing: border-box !important;
        height: 100% !important;
    }

    /* Top-Left Glassmorphic Circular Back Arrow Button on Form Card */
    div[data-testid="stColumn"]:has(#auth-form-card-marker) button[key="close_auth_form"],
    button[key="close_auth_form"],
    button[key="close_auth_form"].st-emotion-cache-165rbpf {
        display: inline-flex !important;
        align-items: center !important;
        justify-content: center !important;
        width: 34px !important;
        height: 34px !important;
        min-width: 34px !important;
        min-height: 34px !important;
        max-width: 34px !important;
        max-height: 34px !important;
        border-radius: 50% !important;
        padding: 0 !important;
        margin: 0 0 0.8rem 0 !important;
        background: rgba(255, 255, 255, 0.08) !important;
        background-color: rgba(255, 255, 255, 0.08) !important;
        border: 1px solid rgba(255, 255, 255, 0.2) !important;
        color: rgba(255, 255, 255, 0.85) !important;
        font-size: 1.1rem !important;
        font-weight: 700 !important;
        line-height: 1 !important;
        cursor: pointer !important;
        transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1) !important;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3) !important;
        outline: none !important;
    }

    div[data-testid="stColumn"]:has(#auth-form-card-marker) button[key="close_auth_form"]:hover,
    button[key="close_auth_form"]:hover,
    button[key="close_auth_form"].st-emotion-cache-165rbpf:hover {
        color: #FFFFFF !important;
        background: rgba(168, 85, 247, 0.25) !important;
        background-color: rgba(168, 85, 247, 0.25) !important;
        border-color: rgba(168, 85, 247, 0.6) !important;
        box-shadow: 0 0 15px rgba(168, 85, 247, 0.4) !important;
        transform: scale(1.1) translateX(-2px) !important;
    }

    div[data-testid="stColumn"]:has(#auth-canvas-marker)::before,
    .auth-flow-canvas::before {
        content: '' !important;
        position: absolute !important;
        top: 0 !important; left: 0 !important; right: 0 !important; bottom: 0 !important;
        background-image: radial-gradient(circle, rgba(255,255,255,0.08) 1.2px, transparent 1.2px) !important;
        background-size: 20px 20px !important;
        pointer-events: none !important;
        width: 100% !important;
        height: 100% !important;
        opacity: 1 !important;
        box-shadow: none !important;
        border-radius: 0 !important;
    }

    /* ── Modern Auth Flowchart Cards & Glowing Icons ── */
    .auth-flow-card {
        display: flex !important;
        align-items: center !important;
        gap: 14px !important;
        background: linear-gradient(135deg, rgba(20, 13, 33, 0.95) 0%, rgba(30, 20, 50, 0.85) 100%) !important;
        backdrop-filter: blur(16px) !important;
        -webkit-backdrop-filter: blur(16px) !important;
        border: 1.5px solid rgba(168, 85, 247, 0.35) !important;
        border-radius: 16px !important;
        padding: 10px 16px !important;
        width: 100% !important;
        max-width: 320px !important;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.4), inset 0 0 20px rgba(168, 85, 247, 0.08) !important;
        transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1) !important;
        position: relative !important;
        overflow: hidden !important;
        box-sizing: border-box !important;
    }

    .auth-flow-card::before {
        content: '' !important;
        position: absolute !important;
        top: 0 !important; left: 15% !important; right: 15% !important; height: 2px !important;
        background: linear-gradient(90deg, transparent 0%, #EC4899 30%, #A855F7 50%, #06B6D4 70%, transparent 100%) !important;
        border-radius: 2px !important;
        opacity: 0.65 !important;
        transition: opacity 0.3s ease, box-shadow 0.3s ease !important;
    }

    .auth-flow-card:hover {
        border-color: rgba(168, 85, 247, 0.75) !important;
        box-shadow: 0 0 30px rgba(168, 85, 247, 0.35), 0 10px 30px rgba(0, 0, 0, 0.5) !important;
        transform: translateY(-2px) !important;
    }

    .auth-flow-card:hover::before {
        opacity: 1 !important;
        box-shadow: 0 0 12px #EC4899, 0 0 16px #A855F7 !important;
    }

    /* Glow Icon Container */
    .flow-icon-container {
        width: 44px !important;
        height: 44px !important;
        min-width: 44px !important;
        border-radius: 12px !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        font-size: 1.35rem !important;
        flex-shrink: 0 !important;
        transition: all 0.3s ease !important;
    }

    .auth-flow-card:hover .flow-icon-container {
        transform: scale(1.08) !important;
    }

    /* Distinct Icon Glow Themes */
    .icon-glow-blue {
        background: rgba(59, 130, 246, 0.18) !important;
        border: 1.5px solid rgba(59, 130, 246, 0.5) !important;
        box-shadow: 0 0 18px rgba(59, 130, 246, 0.45), inset 0 0 10px rgba(59, 130, 246, 0.25) !important;
    }

    .icon-glow-purple {
        background: rgba(168, 85, 247, 0.18) !important;
        border: 1.5px solid rgba(168, 85, 247, 0.5) !important;
        box-shadow: 0 0 18px rgba(168, 85, 247, 0.45), inset 0 0 10px rgba(168, 85, 247, 0.25) !important;
    }

    .icon-glow-pink {
        background: rgba(236, 72, 153, 0.18) !important;
        border: 1.5px solid rgba(236, 72, 153, 0.5) !important;
        box-shadow: 0 0 18px rgba(236, 72, 153, 0.45), inset 0 0 10px rgba(236, 72, 153, 0.25) !important;
    }

    .icon-glow-green {
        background: rgba(34, 197, 94, 0.18) !important;
        border: 1.5px solid rgba(34, 197, 94, 0.5) !important;
        box-shadow: 0 0 18px rgba(34, 197, 94, 0.45), inset 0 0 10px rgba(34, 197, 94, 0.25) !important;
    }

    .icon-glow-neural {
        background: linear-gradient(135deg, rgba(6, 182, 212, 0.25) 0%, rgba(168, 85, 247, 0.25) 100%) !important;
        border: 1.5px solid rgba(6, 182, 212, 0.65) !important;
        box-shadow: 0 0 24px rgba(6, 182, 212, 0.65), 0 0 16px rgba(168, 85, 247, 0.45), inset 0 0 12px rgba(6, 182, 212, 0.3) !important;
        animation: neuralPulse 3s infinite ease-in-out !important;
    }

    @keyframes neuralPulse {
        0%, 100% {
            box-shadow: 0 0 20px rgba(6, 182, 212, 0.5), 0 0 14px rgba(168, 85, 247, 0.35), inset 0 0 10px rgba(6, 182, 212, 0.2);
            border-color: rgba(6, 182, 212, 0.55);
        }
        50% {
            box-shadow: 0 0 32px rgba(6, 182, 212, 0.85), 0 0 22px rgba(168, 85, 247, 0.65), inset 0 0 16px rgba(6, 182, 212, 0.4);
            border-color: rgba(6, 182, 212, 0.95);
            transform: scale(1.05);
        }
    }

    /* Content & Typography */
    .flow-content {
        display: flex !important;
        flex-direction: column !important;
        align-items: flex-start !important;
        text-align: left !important;
        overflow: hidden !important;
    }

    .flow-step-tag {
        font-size: 0.68rem !important;
        font-weight: 900 !important;
        letter-spacing: 1.2px !important;
        text-transform: uppercase !important;
        margin-bottom: 3px !important;
    }

    .tag-blue { color: #60A5FA !important; }
    .tag-purple { color: #C084FC !important; }
    .tag-pink { color: #F472B6 !important; }
    .tag-green { color: #4ADE80 !important; }
    .tag-cyan { color: #22D3EE !important; }

    .flow-node-title {
        font-size: 0.94rem !important;
        font-weight: 900 !important;
        background: linear-gradient(135deg, #EC4899 0%, #A855F7 50%, #3B82F6 100%) !important;
        -webkit-background-clip: text !important;
        -webkit-text-fill-color: transparent !important;
        line-height: 1.25 !important;
        margin-bottom: 2px !important;
        display: inline-block !important;
    }

    .flow-node-sub {
        font-size: 0.74rem !important;
        font-weight: 500 !important;
        color: rgba(233, 213, 255, 0.72) !important;
        line-height: 1.35 !important;
    }

    /* Card Color Variants */
    .flow-card-blue { border-color: rgba(59, 130, 246, 0.4) !important; }
    .flow-card-blue:hover { border-color: rgba(59, 130, 246, 0.8) !important; box-shadow: 0 0 30px rgba(59, 130, 246, 0.35), 0 10px 30px rgba(0, 0, 0, 0.5) !important; }

    .flow-card-purple { border-color: rgba(168, 85, 247, 0.45) !important; }
    .flow-card-purple:hover { border-color: rgba(168, 85, 247, 0.85) !important; box-shadow: 0 0 30px rgba(168, 85, 247, 0.4), 0 10px 30px rgba(0, 0, 0, 0.5) !important; }

    .flow-card-pink { border-color: rgba(236, 72, 153, 0.4) !important; }
    .flow-card-pink:hover { border-color: rgba(236, 72, 153, 0.8) !important; box-shadow: 0 0 30px rgba(236, 72, 153, 0.35), 0 10px 30px rgba(0, 0, 0, 0.5) !important; }

    .flow-card-green { border-color: rgba(34, 197, 94, 0.45) !important; }
    .flow-card-green:hover { border-color: rgba(34, 197, 94, 0.85) !important; box-shadow: 0 0 30px rgba(34, 197, 94, 0.4), 0 10px 30px rgba(0, 0, 0, 0.5) !important; }

    /* Branch Cards Layout */
    .flow-branch-cards {
        display: grid !important;
        grid-template-columns: 1fr 1fr !important;
        gap: 12px !important;
        width: 100% !important;
        margin: 4px 0 !important;
    }

    .flow-branch-link {
        text-decoration: none !important;
        color: inherit !important;
        display: block !important;
        width: 100% !important;
    }

    .flow-branch-cards .auth-flow-card {
        max-width: 100% !important;
        cursor: pointer !important;
        min-height: 72px !important;
    }

    /* Active Highlight States */
    .auth-flow-card.active-branch-signin {
        background: linear-gradient(135deg, rgba(34, 197, 94, 0.25) 0%, rgba(16, 185, 129, 0.15) 100%) !important;
        border: 2px solid rgba(34, 197, 94, 0.95) !important;
        box-shadow: 0 0 35px rgba(34, 197, 94, 0.55), 0 8px 25px rgba(0, 0, 0, 0.5) !important;
    }

    .auth-flow-card.active-branch-signup {
        background: linear-gradient(135deg, rgba(168, 85, 247, 0.25) 0%, rgba(147, 51, 234, 0.15) 100%) !important;
        border: 2px solid rgba(168, 85, 247, 0.95) !important;
        box-shadow: 0 0 35px rgba(168, 85, 247, 0.55), 0 8px 25px rgba(0, 0, 0, 0.5) !important;
    }

    .flow-card-gradient {
        background: linear-gradient(135deg, rgba(30, 41, 59, 0.9) 0%, rgba(124, 58, 237, 0.25) 50%, rgba(15, 23, 42, 0.95) 100%) !important;
        border: 1.5px solid rgba(6, 182, 212, 0.55) !important;
        box-shadow: 0 0 30px rgba(6, 182, 212, 0.25), 0 10px 30px rgba(0, 0, 0, 0.5), inset 0 0 20px rgba(168, 85, 247, 0.2) !important;
    }

    .flow-card-gradient:hover {
        border-color: rgba(6, 182, 212, 0.9) !important;
        box-shadow: 0 0 40px rgba(6, 182, 212, 0.45), 0 0 20px rgba(168, 85, 247, 0.35) !important;
    }

    /* Wire Connectors & Glowing Vector Arrow Pointer System */
    .flow-connector-wrapper {
        display: flex !important;
        flex-direction: column !important;
        align-items: center !important;
        justify-content: center !important;
        margin: 6px 0 !important;
        position: relative !important;
    }

    .flow-connector-line {
        width: 2px !important;
        height: 18px !important;
        background: linear-gradient(180deg, #A855F7 0%, #EC4899 100%) !important;
        box-shadow: 0 0 10px rgba(168, 85, 247, 0.8) !important;
    }

    .flow-connector-arrow {
        font-size: 0.65rem !important;
        color: #EC4899 !important;
        line-height: 1 !important;
        margin-top: -3px !important;
        text-shadow: 0 0 8px #EC4899 !important;
    }

    .flow-connector-arrow.color-cyan {
        color: #38BDF8 !important;
        text-shadow: 0 0 8px #38BDF8 !important;
    }

    /* Center Step Wrappers */
    .flow-step-center {
        display: flex !important;
        justify-content: center !important;
        width: 100% !important;
    }

    /* Branch Arrow Rows */
    .flow-branch-arrows {
        display: grid !important;
        grid-template-columns: 1fr 1fr !important;
        gap: 12px !important;
        width: 100% !important;
        margin: 4px 0 !important;
    }

    .branch-arrow-col {
        display: flex !important;
        flex-direction: column !important;
        align-items: center !important;
    }

    .branch-label {
        font-size: 0.7rem !important;
        font-weight: 800 !important;
        padding: 3px 10px !important;
        border-radius: 12px !important;
        margin-bottom: 2px !important;
        letter-spacing: 0.5px !important;
        white-space: nowrap !important;
    }

    .label-yes {
        background: rgba(34, 197, 94, 0.18) !important;
        color: #4ADE80 !important;
        border: 1px solid rgba(34, 197, 94, 0.45) !important;
        box-shadow: 0 0 12px rgba(34, 197, 94, 0.25) !important;
    }

    .label-no {
        background: rgba(236, 72, 153, 0.18) !important;
        color: #F472B6 !important;
        border: 1px solid rgba(236, 72, 153, 0.45) !important;
        box-shadow: 0 0 12px rgba(236, 72, 153, 0.25) !important;
    }

    /* SVG Vector Merge Connector Container */
    .flow-merge-svg-container {
        display: flex !important;
        flex-direction: column !important;
        align-items: center !important;
        width: 100% !important;
        margin: 2px 0 !important;
    }

    .flow-merge-svg-container svg path {
        filter: drop-shadow(0px 0px 4px rgba(168, 85, 247, 0.8)) !important;
    }

    /* Animated Neural Network Dots Icon */
    .neural-anim-container {
        position: relative !important;
        width: 22px !important;
        height: 22px !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
    }

    .neural-dot {
        position: absolute !important;
        width: 6px !important;
        height: 6px !important;
        border-radius: 50% !important;
        animation: neuralPulse 1.6s infinite ease-in-out alternate !important;
    }

    .neural-dot.n1 { top: 2px; left: 2px; background: #38BDF8; box-shadow: 0 0 8px #38BDF8; animation-delay: 0s !important; }
    .neural-dot.n2 { top: 2px; right: 2px; background: #C084FC; box-shadow: 0 0 8px #C084FC; animation-delay: 0.4s !important; }
    .neural-dot.n3 { bottom: 2px; left: 8px; background: #EC4899; box-shadow: 0 0 8px #EC4899; animation-delay: 0.8s !important; }

    @keyframes neuralPulse {
        0% { transform: scale(0.7); opacity: 0.4; }
        100% { transform: scale(1.4); opacity: 1; filter: brightness(1.3); }
    }

    /* Node Port Connector Dots */
    .node-port {
        width: 10px !important;
        height: 10px !important;
        border-radius: 50% !important;
        background: #C084FC !important;
        border: 2px solid #0E0918 !important;
        position: absolute !important;
        box-shadow: 0 0 12px #C084FC !important;
    }

    .node-port-left { left: -5px; top: 50%; transform: translateY(-50%); }
    .node-port-right { right: -5px; top: 50%; transform: translateY(-50%); }

    /* Wire Connectors with Pulse Glow */
    .flow-vertical-line {
        width: 2px !important;
        height: 22px !important;
        background: linear-gradient(180deg, #A855F7 0%, #EC4899 100%) !important;
        margin: 0 auto !important;
        box-shadow: 0 0 10px rgba(168, 85, 247, 0.8) !important;
    }

    .flow-branch-badge {
        display: inline-flex !important;
        align-items: center !important;
        justify-content: center !important;
        font-size: 0.74rem !important;
        font-weight: 800 !important;
        padding: 3px 12px !important;
        border-radius: 14px !important;
        margin: 6px 0 !important;
        box-shadow: 0 0 15px rgba(0, 0, 0, 0.2) !important;
    }

    .badge-yes {
        background: rgba(34, 197, 94, 0.2) !important;
        color: #4ADE80 !important;
        border: 1px solid rgba(34, 197, 94, 0.45) !important;
        box-shadow: 0 0 15px rgba(34, 197, 94, 0.25) !important;
    }

    .badge-no {
        background: rgba(236, 72, 153, 0.2) !important;
        color: #F472B6 !important;
        border: 1px solid rgba(236, 72, 153, 0.45) !important;
        box-shadow: 0 0 15px rgba(236, 72, 153, 0.25) !important;
    }

    /* Right Auth Glass Card Container — Luminous Glow */
    .auth-form-card {
        background: rgba(15, 23, 42, 0.65) !important;
        backdrop-filter: blur(30px) !important;
        -webkit-backdrop-filter: blur(30px) !important;
        border: 1px solid rgba(168, 85, 247, 0.45) !important;
        border-radius: 24px !important;
        padding: 2.2rem 2.2rem 2.2rem 2.2rem !important;
        box-shadow:
            0 0 35px rgba(168, 85, 247, 0.2),
            0 25px 60px rgba(0, 0, 0, 0.5),
            inset 0 0 20px rgba(168, 85, 247, 0.1) !important;
        animation: authCardFadeIn 0.5s ease-out !important;
        height: 100% !important;
        box-sizing: border-box !important;
        position: relative !important;
        overflow: hidden !important;
        transition: all 0.3s ease !important;
    }

    .auth-form-card::before {
        content: '' !important;
        position: absolute !important;
        top: 0 !important; left: 15% !important; right: 15% !important; height: 2px !important;
        background: linear-gradient(90deg, transparent 0%, #EC4899 30%, #A855F7 50%, #06B6D4 70%, transparent 100%) !important;
        border-radius: 2px !important;
        opacity: 0.7 !important;
        transition: opacity 0.3s ease, box-shadow 0.3s ease !important;
        z-index: 9999 !important;
    }

    .auth-form-card:hover {
        border-color: rgba(168, 85, 247, 0.65) !important;
        box-shadow:
            0 0 45px rgba(168, 85, 247, 0.35),
            0 25px 60px rgba(0, 0, 0, 0.5),
            inset 0 0 20px rgba(168, 85, 247, 0.1) !important;
        transform: translateY(-2px) !important;
    }

    .auth-form-card:hover::before {
        opacity: 1 !important;
        box-shadow: 0 0 14px #EC4899, 0 0 20px #A855F7 !important;
    }

    @keyframes authCardFadeIn {
        from { opacity: 0; transform: translateY(15px); }
        to { opacity: 1; transform: translateY(0); }
    }

    /* Auth Header Layout inside Card */
    .auth-card-header {
        display: flex !important;
        justify-content: space-between !important;
        align-items: center !important;
        margin-bottom: 1.5rem !important;
        width: 100% !important;
    }

    .auth-card-header div.element-container,
    .auth-card-header div[data-testid="stElementContainer"] {
        margin: 0 !important;
        padding: 0 !important;
        width: auto !important;
    }

    .auth-card-header h3 {
        margin: 0 !important;
        color: #FAFAFA !important;
        font-weight: 800 !important;
        font-size: 1.35rem !important;
        line-height: 1.2 !important;
    }

    /* Close Button Styling */
    .auth-close-btn-wrapper {
        display: flex !important;
        justify-content: flex-end !important;
        align-items: center !important;
    }

    .auth-close-btn-wrapper button {
        background: rgba(239, 68, 68, 0.1) !important;
        border: 1px solid rgba(239, 68, 68, 0.35) !important;
        color: #F87171 !important;
        border-radius: 14px !important;
        padding: 4px 12px !important;
        height: 28px !important;
        min-height: 28px !important;
        font-size: 0.75rem !important;
        font-weight: 700 !important;
        transition: all 0.2s ease !important;
        width: auto !important;
        line-height: 1 !important;
    }

    .auth-close-btn-wrapper button:hover {
        background: rgba(239, 68, 68, 0.25) !important;
        border-color: rgba(239, 68, 68, 0.7) !important;
        color: #FFFFFF !important;
        box-shadow: 0 0 15px rgba(239, 68, 68, 0.3) !important;
        transform: translateY(-1px) !important;
    }

    /* Auth Form Labels */
    .auth-form-card label, .auth-form-card .stTextInput label {
        color: rgba(255, 255, 255, 0.7) !important;
        font-size: 0.78rem !important;
        font-weight: 700 !important;
        letter-spacing: 0.5px !important;
        text-transform: uppercase !important;
        margin-bottom: 4px !important;
    }

    /* Auth Form Inputs — Glowing Rings */
    .auth-form-card div[data-baseweb="input"] > div,
    .auth-form-card div[data-baseweb="select"] > div {
        background: rgba(255, 255, 255, 0.04) !important;
        border: 1px solid rgba(168, 85, 247, 0.2) !important;
        border-radius: 12px !important;
        transition: border-color 0.25s ease, box-shadow 0.25s ease !important;
        color: #FAFAFA !important;
    }

    .auth-form-card div[data-baseweb="input"] > div:focus-within,
    .auth-form-card div[data-baseweb="select"] > div:focus-within {
        border-color: rgba(168, 85, 247, 0.65) !important;
        box-shadow: 0 0 0 3px rgba(168, 85, 247, 0.15), 0 0 25px rgba(168, 85, 247, 0.15) !important;
    }

    .auth-form-card input {
        color: #FAFAFA !important;
        font-size: 0.95rem !important;
    }

    .auth-form-card input::placeholder {
        color: rgba(255, 255, 255, 0.25) !important;
    }

    /* Auth Submit Button — Gradient */
    .auth-form-card button[kind="primary"],
    .auth-form-card button[type="submit"],
    .auth-form-card div[data-testid="stFormSubmitButton"] button {
        background: linear-gradient(135deg, #EC4899 0%, #A855F7 50%, #3B82F6 100%) !important;
        border: none !important;
        border-radius: 14px !important;
        color: #FFFFFF !important;
        font-weight: 800 !important;
        font-size: 0.95rem !important;
        padding: 12px 24px !important;
        box-shadow: 0 0 25px rgba(236, 72, 153, 0.35) !important;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1) !important;
        height: 48px !important;
        min-height: 48px !important;
        width: 100% !important;
        margin-top: 0.5rem !important;
    }

    .auth-form-card button[kind="primary"]:hover,
    .auth-form-card button[type="submit"]:hover,
    .auth-form-card div[data-testid="stFormSubmitButton"] button:hover {
        box-shadow: 0 0 35px rgba(236, 72, 153, 0.65), 0 0 20px rgba(6, 182, 212, 0.45) !important;
        transform: translateY(-2px) !important;
    }

    /* Auth Selectbox Override */
    .auth-form-card div[data-baseweb="select"] span {
        color: #FAFAFA !important;
    }

    /* Auth dividers */
    .auth-glass hr {
        border-color: rgba(139, 92, 246, 0.12) !important;
        margin: 1.5rem 0 !important;
    }

    /* ── Glowing Input Rings (global fallback) ──────── */
    div[data-baseweb="input"] > div {
        background: rgba(255, 255, 255, 0.03) !important;
        border: 1px solid rgba(255, 255, 255, 0.1) !important;
        border-radius: 10px !important;
        transition: border-color 0.2s, box-shadow 0.2s;
    }

    div[data-baseweb="input"] > div:focus-within {
        border-color: rgba(139, 92, 246, 0.5) !important;
        box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.15), 0 0 20px rgba(139, 92, 246, 0.1) !important;
    }
</style>
"""


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  MAIN RENDER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
def render_home_page():
    """Renders the glassy AI-driven landing page."""
    st.markdown(HOME_CSS, unsafe_allow_html=True)

    # Background glow orbs
    st.markdown('<div class="glow-bg"></div>', unsafe_allow_html=True)

    # Init state
    if "view" not in st.session_state:
        st.session_state["view"] = "home"
    if "user_profile" not in st.session_state:
        st.session_state["user_profile"] = None

    user_profile = st.session_state.get("user_profile")

    if st.session_state.get("view") == "auth":
        _render_auth_view()
        return

    # ── NAVBAR ────────────────────────────────────────────────────
    nav_col1, nav_col2, nav_col3 = st.columns([2.5, 4.2, 3.3])

    with nav_col1:
        st.markdown('<div class="et-logo">⚡ <span class="accent">EduTech</span> <span class="badge-ai">AI</span></div>', unsafe_allow_html=True)

    with nav_col2:
        st.markdown(
            '<div class="et-nav-links"><a href="#about" class="nav-pill">About</a><a href="#features" class="nav-pill">Features</a><a href="#agents" class="nav-pill">Agents</a><a href="#pricing" class="nav-pill">Pricing</a></div>',
            unsafe_allow_html=True,
        )

    with nav_col3:
        if user_profile:
            u_tier = (user_profile.subscription.tier if user_profile.subscription else "normal").upper()
            st.markdown(f'<div style="color:rgba(255,255,255,0.7);font-size:0.85rem;padding-top:6px;">👋 <b style="color:#FAFAFA;">{user_profile.first_name}</b> · <span style="color:#C084FC;font-weight:800;">{u_tier}</span></div>', unsafe_allow_html=True)
        else:
            nb1, nb2 = st.columns(2)
            with nb1:
                if st.button("Sign In", key="nav_si"):
                    st.session_state["auth_tab"] = "login"
                    st.session_state["view"] = "auth"
                    st.rerun()
            with nb2:
                if st.button("Get Started", key="nav_gs", type="primary"):
                    st.session_state["auth_tab"] = "signup"
                    st.session_state["view"] = "auth"
                    st.rerun()

    # ── HERO ──────────────────────────────────────────────────────
    st.markdown(
        """
        <div class="et-hero">
            <h1>Master Any Subject with a<br/><span class="gradient-text">Team of AI Agents</span></h1>
            <p>Our orchestrator divides complex topics into milestones, while specialized agents guide you through Socratic dialogue, curated videos, research papers, and interactive assessments.</p>
        </div>
        """,
        unsafe_allow_html=True,
    )

    cl, cc, cr = st.columns([2.5, 1.5, 2.5])
    with cc:
        if st.button("Start Learning for Free →", key="hero_btn", type="primary", use_container_width=True):
            if not user_profile:
                st.session_state["auth_tab"] = "login"
                st.session_state["view"] = "auth"
                st.toast("🔒 Sign in or create an account to start.", icon="🔒")
                st.rerun()
            else:
                st.session_state["view"] = "learning"
                st.rerun()

    st.markdown("<div style='height: 2rem;'></div>", unsafe_allow_html=True)

    # ── Pixel-Perfect n8n-Style Workflow Visualization ──────────────
    st.markdown(
"""<div class="n8n-canvas">
<div class="n8n-header">
<span>⚡ EduTech AI — Autonomous Multi-Agent Flow</span>
</div>
<div class="n8n-diagram">
<!-- 1. Trigger Node (Left Arch) -->
<div class="n8n-trigger-node">
<span class="n8n-lightning">⚡</span>
<div class="n8n-trigger-icon">📝</div>
<div class="n8n-trigger-label">On 'Topic Selection' submission</div>
<div class="n8n-port n8n-port-right"></div>
</div>
<div class="n8n-wire"></div>
<!-- 2. Main Agent Card Node -->
<div class="n8n-agent-card">
<div class="n8n-port n8n-port-left"></div>
<div class="n8n-agent-header">
<div class="n8n-agent-icon">🤖</div>
<div>
<div class="n8n-agent-title">AI Orchestrator</div>
<div class="n8n-agent-sub">Multi-Agent Supervisor</div>
</div>
</div>
<div class="n8n-sub-ports">
<span class="n8n-sub-port-tag">Model*</span>
<span class="n8n-sub-port-tag">Memory</span>
<span class="n8n-sub-port-tag">Tools</span>
</div>
<div class="n8n-port n8n-port-right"></div>
<!-- Sub-Nodes connected below -->
<div class="n8n-sub-nodes-group">
<div class="n8n-sub-node">
<div class="n8n-sub-wire"></div>
<div class="n8n-sub-circle">✨</div>
<div class="n8n-sub-title">Google Gemini</div>
</div>
<div class="n8n-sub-node">
<div class="n8n-sub-wire"></div>
<div class="n8n-sub-circle">🐘</div>
<div class="n8n-sub-title">PostgreSQL DB</div>
</div>
<div class="n8n-sub-node">
<div class="n8n-sub-wire"></div>
<div class="n8n-sub-circle">📚</div>
<div class="n8n-sub-title">Academic APIs</div>
</div>
<div class="n8n-sub-node">
<div class="n8n-sub-wire"></div>
<div class="n8n-sub-circle">🎬</div>
<div class="n8n-sub-title">YouTube API</div>
</div>
</div>
</div>
<div class="n8n-wire"></div>
<!-- 3. Decision Node -->
<div class="n8n-decision-card">
<div class="n8n-port n8n-port-left"></div>
<div class="n8n-decision-icon">🔀</div>
<div>
<div class="n8n-agent-title">Task Router</div>
<div class="n8n-agent-sub">Check Step Type</div>
</div>
<div class="n8n-port n8n-port-right"></div>
</div>
<!-- Branching Arms -->
<div class="n8n-branch-arms">
<!-- True Arm (Concept Explanation) -->
<div style="display:flex; align-items:center; gap:8px;">
<span class="n8n-arm-label">true</span>
<div class="n8n-wire"></div>
<div class="n8n-trigger-node" style="border-radius:14px; border-color:rgba(139,92,246,0.3);">
<div class="n8n-trigger-icon" style="background:rgba(139,92,246,0.15); color:#C4B5FD; border-color:rgba(139,92,246,0.3);">💬</div>
<div>
<div class="n8n-agent-title" style="font-size:0.8rem;">Socratic Tutor</div>
<div class="n8n-agent-sub">Guided Dialogue &amp; Clips</div>
</div>
</div>
</div>
<!-- False Arm (Assessment & XP) -->
<div style="display:flex; align-items:center; gap:8px;">
<span class="n8n-arm-label">false</span>
<div class="n8n-wire"></div>
<div class="n8n-trigger-node" style="border-radius:14px; border-color:rgba(236,72,153,0.3);">
<div class="n8n-trigger-icon" style="background:rgba(236,72,153,0.15); color:#F9A8D4; border-color:rgba(236,72,153,0.3);">🏆</div>
<div>
<div class="n8n-agent-title" style="font-size:0.8rem;">Quiz &amp; XP Engine</div>
<div class="n8n-agent-sub">Assessment &amp; Rewards</div>
</div>
</div>
</div>
</div>
</div>
</div>""",
        unsafe_allow_html=True,
    )

    st.markdown("<br/><br/><br/>", unsafe_allow_html=True)

    # ── FEATURES ──────────────────────────────────────────────────
    st.markdown('<a name="features"></a>', unsafe_allow_html=True)
    st.markdown('<div class="section-title"><span class="gradient-text">Why EduTech AI?</span></div>', unsafe_allow_html=True)
    st.markdown('<div class="section-sub">Everything you need for an AI-powered learning experience, built from the ground up.</div>', unsafe_allow_html=True)

    f1, f2, f3 = st.columns(3)
    with f1:
        st.markdown(
            '<div class="feat-card"><div class="feat-icon icon-violet">🧩</div><h4>Adaptive Milestones</h4><p>AI decomposes any topic into 4-7 structured steps with automatic prerequisite detection.</p></div>',
            unsafe_allow_html=True,
        )
    with f2:
        st.markdown(
            '<div class="feat-card"><div class="feat-icon icon-blue">💬</div><h4>Socratic Dialogue</h4><p>Never dry lectures. Guided questions and everyday analogies adapted to your education level.</p></div>',
            unsafe_allow_html=True,
        )
    with f3:
        st.markdown(
            '<div class="feat-card"><div class="feat-icon icon-cyan">🎬</div><h4>Video Deep-Linking</h4><p>Curated YouTube clips that jump to the exact timestamp where your concept is explained.</p></div>',
            unsafe_allow_html=True,
        )

    st.markdown("<br/>", unsafe_allow_html=True)

    f4, f5, f6 = st.columns(3)
    with f4:
        st.markdown(
            '<div class="feat-card"><div class="feat-icon icon-green">📚</div><h4>Research Curation</h4><p>Open-access papers from arXiv, Semantic Scholar & OpenAlex with AI-generated takeaways.</p></div>',
            unsafe_allow_html=True,
        )
    with f5:
        st.markdown(
            '<div class="feat-card"><div class="feat-icon icon-amber">📝</div><h4>Dynamic Quizzes</h4><p>Contextual MCQs after each milestone with instant grading and detailed explanations.</p></div>',
            unsafe_allow_html=True,
        )
    with f6:
        st.markdown(
            '<div class="feat-card"><div class="feat-icon icon-pink">🏆</div><h4>XP & Gamification</h4><p>Streaks, XP rewards, and a 10-level progression system to keep you motivated.</p></div>',
            unsafe_allow_html=True,
        )

    st.markdown("<br/><br/>", unsafe_allow_html=True)

    # ── AGENT SQUAD ───────────────────────────────────────────────
    st.markdown('<a name="agents"></a>', unsafe_allow_html=True)
    st.markdown('<div class="section-title"><span class="gradient-text">The Agent Squad</span></div>', unsafe_allow_html=True)
    st.markdown('<div class="section-sub">Six specialized AI agents working in parallel via shared memory to deliver your personalized curriculum.</div>', unsafe_allow_html=True)

    a1, a2, a3 = st.columns(3)
    with a1:
        st.markdown('<div class="agent-glass"><div class="agent-icon icon-violet">🎯</div><h4>Orchestrator</h4><p>Supervisor agent. Decomposes topics into structured milestone steps.</p></div>', unsafe_allow_html=True)
    with a2:
        st.markdown('<div class="agent-glass"><div class="agent-icon icon-blue">💬</div><h4>Socratic Tutor</h4><p>Guided questioning, real-world analogies, and conceptual scaffolding.</p></div>', unsafe_allow_html=True)
    with a3:
        st.markdown('<div class="agent-glass"><div class="agent-icon icon-cyan">🎬</div><h4>YouTube Curator</h4><p>Finds videos and pinpoints exact timestamp clips for each milestone.</p></div>', unsafe_allow_html=True)

    st.markdown("<br/>", unsafe_allow_html=True)

    a4, a5, a6 = st.columns(3)
    with a4:
        st.markdown('<div class="agent-glass"><div class="agent-icon icon-green">📚</div><h4>Academic Researcher</h4><p>Curates open-access papers with AI-generated key takeaways.</p></div>', unsafe_allow_html=True)
    with a5:
        st.markdown('<div class="agent-glass"><div class="agent-icon icon-amber">📝</div><h4>Dynamic Quiz</h4><p>Generates contextual MCQs with instant grading and XP rewards.</p></div>', unsafe_allow_html=True)
    with a6:
        st.markdown('<div class="agent-glass"><div class="agent-icon icon-pink">📊</div><h4>Gamification Engine</h4><p>Streak tracking, level progression (1-10), and session persistence.</p></div>', unsafe_allow_html=True)

    st.markdown("<br/><br/>", unsafe_allow_html=True)

    # ── ABOUT SECTION ─────────────────────────────────────────────
    st.markdown('<a name="about"></a>', unsafe_allow_html=True)
    st.markdown('<div class="section-title"><span class="gradient-text">About EduTech AI</span></div>', unsafe_allow_html=True)
    st.markdown('<div class="section-sub">Transforming education through multi-agent intelligence, academic rigor, and gamified cognitive science.</div>', unsafe_allow_html=True)

    # Metric Stats Row
    s1, s2, s3, s4 = st.columns(4)
    with s1:
        st.markdown('<div class="stat-pill"><div class="stat-number">6</div><div class="stat-label">AI Agents</div></div>', unsafe_allow_html=True)
    with s2:
        st.markdown('<div class="stat-pill"><div class="stat-number">5</div><div class="stat-label">Education Levels</div></div>', unsafe_allow_html=True)
    with s3:
        st.markdown('<div class="stat-pill"><div class="stat-number">100%</div><div class="stat-label">Academic Integration</div></div>', unsafe_allow_html=True)
    with s4:
        st.markdown('<div class="stat-pill"><div class="stat-number">10</div><div class="stat-label">Progression Levels</div></div>', unsafe_allow_html=True)

    st.markdown("<br/>", unsafe_allow_html=True)

    # Mission & Technology Cards
    ab1, ab2 = st.columns(2)
    with ab1:
        st.markdown(
            """
            <div class="about-card">
                <h3>🚀 Our Mission</h3>
                <p>
                    Traditional online learning often relies on passive video watching and static, one-size-fits-all quizzes.
                    EduTech AI was built to pioneer a new paradigm: <b>Interactive Multi-Agent Learning</b>.
                    <br/><br/>
                    We combine autonomous LLM supervisor orchestrators with specialized worker agents that act as your personal 24/7 tutor—breaking down complex subjects into bite-sized milestones and testing your understanding with Socratic questioning.
                </p>
            </div>
            """, unsafe_allow_html=True)

    with ab2:
        st.markdown(
            """
            <div class="about-card">
                <h3>🧠 Engineered for Deep Mastery</h3>
                <p>
                    Built on top of a state-persisted supervisor-worker architecture, EduTech AI connects directly to leading academic databases (arXiv, OpenAlex, Semantic Scholar) and curated video timestamps.
                    <br/><br/>
                    Whether you are a high school student grasping basic physics or a researcher analyzing machine learning papers, our system adapts to your cognitive level in real time.
                </p>
            </div>
            """, unsafe_allow_html=True)

    st.markdown("<br/><br/>", unsafe_allow_html=True)

    # ── PRICING ───────────────────────────────────────────────────
    st.markdown('<a name="pricing"></a>', unsafe_allow_html=True)
    st.markdown('<div class="section-title"><span class="gradient-text">Choose Your Path</span></div>', unsafe_allow_html=True)
    st.markdown('<div class="section-sub">Flexible plans designed for every type of learner.</div>', unsafe_allow_html=True)

    p1, p2, p3 = st.columns(3)

    with p1:
        st.markdown(
            """
            <div class="price-glass">
                <div class="price-name">Free</div>
                <div class="price-amount">$0<sub>/mo</sub></div>
                <div class="price-desc">Essential AI tutoring for curious learners starting out.</div>
                <hr style="border:1px solid rgba(255,255,255,0.05);"/>
                <div class="price-feat"><span class="chk">✓</span> 5 AI Sessions / mo</div>
                <div class="price-feat"><span class="chk">✓</span> Standard Socratic Tutor</div>
                <div class="price-feat"><span class="chk">✓</span> 3 Education Levels</div>
                <div class="price-feat"><span class="chk">✓</span> Milestone Journeys</div>
                <div class="price-feat"><span class="chk">✓</span> Basic Quizzes & XP</div>
            </div>
            """, unsafe_allow_html=True)
        st.markdown("<div style='height:12px'></div>", unsafe_allow_html=True)
        if st.button("Start Free", key="t_n", type="primary", use_container_width=True):
            _handle_tier_select("normal")

    with p2:
        st.markdown(
            """
            <div class="price-glass price-glass-pro">
                <div class="price-badge">MOST POPULAR ⭐</div>
                <div class="price-name">Pro</div>
                <div class="price-amount">$19<sub>/mo</sub></div>
                <div class="price-desc">Full agent squad, deep research, visual modes & 1.5x XP.</div>
                <hr style="border:1px solid rgba(139,92,246,0.15);"/>
                <div class="price-feat"><span class="chk">✓</span> <b>Unlimited</b> AI Sessions</div>
                <div class="price-feat"><span class="chk">✓</span> All 5 Education Levels</div>
                <div class="price-feat"><span class="chk">✓</span> Visual & Deep-Dive Modes</div>
                <div class="price-feat"><span class="chk">✓</span> <b>YouTube Deep-Linking</b></div>
                <div class="price-feat"><span class="chk">✓</span> Academic Paper Curation</div>
                <div class="price-feat"><span class="chk">✓</span> <b>1.5x XP Multiplier</b></div>
            </div>
            """, unsafe_allow_html=True)
        st.markdown("<div style='height:12px'></div>", unsafe_allow_html=True)
        if st.button("Upgrade to Pro", key="t_p", type="primary", use_container_width=True):
            _handle_tier_select("pro")

    with p3:
        st.markdown(
            """
            <div class="price-glass">
                <div class="price-name">Ultra</div>
                <div class="price-amount">$49<sub>/mo</sub></div>
                <div class="price-desc">Priority execution, custom personas, 2x XP & 24/7 support.</div>
                <hr style="border:1px solid rgba(255,255,255,0.05);"/>
                <div class="price-feat"><span class="chk">✓</span> Everything in Pro +</div>
                <div class="price-feat"><span class="chk">✓</span> Priority Multi-Agent Exec</div>
                <div class="price-feat"><span class="chk">✓</span> Unlimited Paper Downloads</div>
                <div class="price-feat"><span class="chk">✓</span> Custom Socratic Persona</div>
                <div class="price-feat"><span class="chk">✓</span> <b>2x XP Boost</b></div>
                <div class="price-feat"><span class="chk">✓</span> 24/7 AI Support</div>
            </div>
            """, unsafe_allow_html=True)
        st.markdown("<div style='height:12px'></div>", unsafe_allow_html=True)
        if st.button("Select Ultra", key="t_u", type="primary", use_container_width=True):
            _handle_tier_select("ultra")

    st.markdown("<br/>", unsafe_allow_html=True)

    # ── CTA BANNER ────────────────────────────────────────────────
    st.markdown(
        """
        <div class="cta-banner">
            <h2 style="font-size:2.4rem; font-weight:900; margin-bottom:0.6rem;"><span class="gradient-text">Ready to Accelerate Your Learning?</span></h2>
            <p>Join thousands of students and professionals mastering complex topics faster with EduTech AI.</p>
        </div>
        """, unsafe_allow_html=True)

    bl, bc, br = st.columns([2.5, 1.5, 2.5])
    with bc:
        if st.button("Get Started Free →", key="cta_btn", type="primary", use_container_width=True):
            if not user_profile:
                st.session_state["auth_tab"] = "signup"
                st.session_state["view"] = "auth"
                st.rerun()
            else:
                st.session_state["view"] = "learning"
                st.rerun()

    st.markdown("<br/>", unsafe_allow_html=True)

    # ── FOOTER ────────────────────────────────────────────────────
    st.markdown(
        """
        <div class="et-footer">
            <div class="et-footer-left"><span>EduTech AI</span><br/>© 2024 EduTech AI. Empowering cognitive research through education.</div>
            <div class="et-footer-links">
                <a href="#">Terms of Service</a>
                <a href="#">Privacy Policy</a>
                <a href="#">Contact Support</a>
                <a href="#">Documentation</a>
            </div>
        </div>
        """, unsafe_allow_html=True)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  AUTH VIEW — Glassy Sign In / Sign Up
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
def _render_auth_view():
    """Renders split-screen AI flow diagram auth view matching the homepage theme."""
    # Sync view to auth query param for refreshes
    st.query_params["view"] = "auth"

    # Sync query parameter auth_mode with session state
    qp_auth_mode = st.query_params.get("auth_mode")
    if qp_auth_mode in ["signin", "signup"]:
        st.session_state["auth_form_mode"] = qp_auth_mode

    # Initialize the auth form mode if not present in session state
    if "auth_form_mode" not in st.session_state or st.session_state.get("auth_form_mode") is None:
        if qp_auth_mode in ["signin", "signup"]:
            st.session_state["auth_form_mode"] = qp_auth_mode
        else:
            init_tab = st.session_state.pop("auth_tab", None)
            if init_tab == "login":
                st.session_state["auth_form_mode"] = "signin"
            elif init_tab == "signup":
                st.session_state["auth_form_mode"] = "signup"
            else:
                st.session_state["auth_form_mode"] = None

    mode = st.session_state.get("auth_form_mode")

    # ── Floating Glassmorphic Navbar Pill (rendered first) ──────────────────────
    nav_c1, nav_c2 = st.columns([3, 1])
    with nav_c1:
        st.markdown('<div class="et-logo-simple">⚡ <span class="accent">EduTech</span> <span class="badge-ai">AI</span></div>', unsafe_allow_html=True)
    with nav_c2:
        if st.button("← Back to Home", key="auth_back"):
            st.session_state["view"] = "home"
            # Clear state when leaving
            st.session_state["auth_form_mode"] = None
            st.session_state["auth_tab"] = None
            st.query_params.clear()
            st.rerun()

    # Dynamic active state CSS overrides (Glassmorphic background fill for selected state)
    if mode == "signin":
        st.markdown("""<style>
        html body div.stApp div[data-testid="stColumn"]:has(#signin-branch-marker):not(:has(#signup-branch-marker)) button,
        div[data-testid="stColumn"]:has(#signin-branch-marker):not(:has(#signup-branch-marker)) button {
            background: linear-gradient(135deg, rgba(34, 197, 94, 0.38) 0%, rgba(16, 185, 129, 0.25) 100%) !important;
            background-color: rgba(34, 197, 94, 0.32) !important;
            border: 2px solid rgba(34, 197, 94, 0.95) !important;
            box-shadow: 0 0 35px rgba(34, 197, 94, 0.65), 0 8px 25px rgba(0, 0, 0, 0.5) !important;
            backdrop-filter: blur(16px) !important;
            -webkit-backdrop-filter: blur(16px) !important;
        }
        </style>""", unsafe_allow_html=True)
    elif mode == "signup":
        st.markdown("""<style>
        html body div.stApp div[data-testid="stColumn"]:has(#signup-branch-marker):not(:has(#signin-branch-marker)) button,
        div[data-testid="stColumn"]:has(#signup-branch-marker):not(:has(#signin-branch-marker)) button {
            background: linear-gradient(135deg, rgba(168, 85, 247, 0.38) 0%, rgba(147, 51, 234, 0.25) 100%) !important;
            background-color: rgba(168, 85, 247, 0.32) !important;
            border: 2px solid rgba(168, 85, 247, 0.95) !important;
            box-shadow: 0 0 35px rgba(168, 85, 247, 0.65), 0 8px 25px rgba(0, 0, 0, 0.5) !important;
            backdrop-filter: blur(16px) !important;
            -webkit-backdrop-filter: blur(16px) !important;
        }
        </style>""", unsafe_allow_html=True)

    # Background glow with constellation node overlay
    st.markdown('<div class="glow-bg-constellation"></div>', unsafe_allow_html=True)

    st.markdown(
        """
        <div class="auth-header-container">
            <h1 class="auth-title">Access the <span class="gradient-text">AI Learning Workspace</span></h1>
            <p class="auth-subtitle">EduTech AI is an autonomous, multi-agent academic ecosystem. Log in or create a new student account to instantiate your personal supervisor-worker agent swarm.</p>
            <div class="auth-instructions-pill">
                <div class="instructions-icon">💡</div>
                <div class="instructions-text">
                    <h4><span class="gradient-text">Access Instructions</span></h4>
                    <p>Trace the <b>Providing Access Flowchart</b> below. If you already have an account, complete the <b>Sign In</b> form on the right. Otherwise, proceed to the <b>Create Account</b> tab. Upon verification, the system dispatches the AI Agent Squad to instantly grant workspace access.</p>
                </div>
            </div>
        </div>
        """, unsafe_allow_html=True)

    # ── Dynamic Grid Showcase Layout ─────────────────────────────
    if mode is None:
        col_left, col_showcase, col_right = st.columns([0.5, 2.0, 0.5])
    else:
        col_showcase, col_auth = st.columns([1.1, 1.0], gap="large")

    with col_showcase:
        st.markdown(
            """<div id="auth-canvas-marker"></div>
<div class="n8n-header" style="margin-bottom:1.2rem; text-align:center;">
<span>⚡ EduTech AI — Providing Access Flowchart</span>
</div>

<!-- Step 1: Student Intake / Arrival -->
<div class="flow-step-center">
<div class="auth-flow-card flow-card-blue">
  <div class="flow-icon-container icon-glow-blue">
    <span class="flow-icon">👤</span>
  </div>
  <div class="flow-content">
    <div class="flow-step-tag tag-blue"><b>STEP 01 • INTAKE</b></div>
    <div class="flow-node-title"><span class="gradient-text">Student Arrival</span></div>
    <div class="flow-node-sub">Initiates secure session request</div>
  </div>
</div>
</div>

<!-- Arrow 1 -->
<div class="flow-connector-wrapper">
<div class="flow-connector-line"></div>
<div class="flow-connector-arrow">▼</div>
</div>

<!-- Step 2: AI Identity Guard -->
<div class="flow-step-center">
<div class="auth-flow-card flow-card-purple">
  <div class="flow-icon-container icon-glow-purple">
    <span class="flow-icon">🛡️</span>
  </div>
  <div class="flow-content">
    <div class="flow-step-tag tag-purple"><b>STEP 02 • AI EVALUATION</b></div>
    <div class="flow-node-title"><span class="gradient-text">AI Identity Guard</span></div>
    <div class="flow-node-sub">Inspects credentials & privileges</div>
  </div>
</div>
</div>

<!-- Arrow 2 -->
<div class="flow-connector-wrapper">
<div class="flow-connector-line"></div>
<div class="flow-connector-arrow">▼</div>
</div>

<!-- Step 3: Account Verification Gateway -->
<div class="flow-step-center">
<div class="auth-flow-card flow-card-pink">
  <div class="flow-icon-container icon-glow-pink">
    <span class="flow-icon">❓</span>
  </div>
  <div class="flow-content">
    <div class="flow-step-tag tag-pink"><b>STEP 03 • ROUTING GATEWAY</b></div>
    <div class="flow-node-title"><span class="gradient-text">Account Verification</span></div>
    <div class="flow-node-sub">Determines authentication pathway</div>
  </div>
</div>
</div>

<!-- 2 Arrows branching to Sign In and Create Account -->
<div class="flow-branch-arrows">
<div class="branch-arrow-col">
  <span class="branch-label label-yes">YES • EXISTING USER (✓)</span>
  <div class="flow-connector-line"></div>
  <div class="flow-connector-arrow color-green">▼</div>
</div>
<div class="branch-arrow-col">
  <span class="branch-label label-no">NO • NEW STUDENT (✨)</span>
  <div class="flow-connector-line"></div>
  <div class="flow-connector-arrow color-pink">▼</div>
</div>
</div>""", unsafe_allow_html=True)

        # Step 4: Native Streamlit Flowchart Action Cards (Zero Page Reload)
        flow_col1, flow_col2 = st.columns(2)
        with flow_col1:
            st.markdown('<div id="signin-branch-marker"></div>', unsafe_allow_html=True)
            if st.button("🔐  STEP 04A • LOGIN\nSign In\nExisting Account Access", key="flowchart_signin_btn", use_container_width=True):
                st.session_state["auth_form_mode"] = "signin"
                st.rerun()
        with flow_col2:
            st.markdown('<div id="signup-branch-marker"></div>', unsafe_allow_html=True)
            if st.button("✨  STEP 04B • REGISTER\nCreate Account\nInstant Free Setup", key="flowchart_signup_btn", use_container_width=True):
                st.session_state["auth_form_mode"] = "signup"
                st.rerun()

        st.markdown(
            """<!-- Merge Arrow connecting to Dispatch AI Agent Squad block -->
<div class="flow-merge-svg-container">
<svg width="100%" height="22" viewBox="0 0 100 22" preserveAspectRatio="none" style="display:block;">
  <path d="M 25 0 L 25 11" stroke="#34D399" stroke-width="2" fill="none" vector-effect="non-scaling-stroke" />
  <path d="M 75 0 L 75 11" stroke="#F472B6" stroke-width="2" fill="none" vector-effect="non-scaling-stroke" />
  <path d="M 25 11 L 75 11" stroke="#A855F7" stroke-width="2" fill="none" vector-effect="non-scaling-stroke" />
  <path d="M 50 11 L 50 22" stroke="#38BDF8" stroke-width="2" fill="none" vector-effect="non-scaling-stroke" />
</svg>
<div class="flow-connector-wrapper" style="margin-top:-6px;">
<div class="flow-connector-arrow color-cyan">▼</div>
</div>
</div>

<!-- Step 5: Dispatch AI Agent Squad block with Glowing Neural Icon -->
<div class="flow-step-center">
<div class="auth-flow-card flow-card-gradient">
  <div class="flow-icon-container icon-glow-neural">
    <span class="flow-icon">🧠</span>
  </div>
  <div class="flow-content">
    <div class="flow-step-tag tag-cyan"><b>STEP 05 • DISPATCH & UNLOCK</b></div>
    <div class="flow-node-title"><span class="gradient-text">Spawn AI Agent Squad</span></div>
    <div class="flow-node-sub">Instant Autonomous Workspace Access</div>
  </div>
</div>
</div>""",
            unsafe_allow_html=True,
        )

    if mode is not None:
        with col_auth:
            st.markdown('<div id="auth-form-card-marker"></div>', unsafe_allow_html=True)

            if st.button("←", key="close_auth_form"):
                st.session_state["auth_form_mode"] = None
                st.session_state.pop("auth_tab", None)
                if "auth_mode" in st.query_params:
                    del st.query_params["auth_mode"]
                st.rerun()

            if mode == "signin":
                st.markdown("### 🔐 Sign In")
            else:
                st.markdown("### ✨ Create Account")

            if mode == "signin":
                with st.form("signin_form"):
                    email_in = st.text_input("Email Address", placeholder="student@example.com")
                    pass_in = st.text_input("Password", type="password")
                    sub = st.form_submit_button("Sign In", type="primary", use_container_width=True)

                if sub:
                    if not email_in or not pass_in:
                        st.error("Please provide both email and password.")
                    else:
                        with st.spinner("Authenticating..."):
                            try:
                                from services.auth_service import AuthService
                                from services.database import get_db_session

                                async def _login():
                                    async with get_db_session() as db:
                                        u = await AuthService.authenticate_user(db, email_in.strip(), pass_in)
                                        return AuthService.get_user_current_profile(u)

                                p = run_async(_login())
                                st.session_state["user_profile"] = p
                                st.session_state["view"] = "learning"
                                st.toast(f"Welcome back, {p.first_name}!", icon="✅")
                                st.rerun()
                            except Exception as e:
                                st.error(f"Sign in failed: {e}")
            else:
                with st.form("signup_form"):
                    col_fn, col_ln = st.columns(2)
                    with col_fn:
                        fn = st.text_input("First Name *", placeholder="Jane")
                    with col_ln:
                        ln = st.text_input("Last Name *", placeholder="Doe")

                    se = st.text_input("Email Address *", placeholder="jane.doe@example.com")
                    sp = st.text_input("Password * (min 6 characters)", type="password")

                    col_mob, col_ctry = st.columns(2)
                    with col_mob:
                        mob = st.text_input("Mobile Number", placeholder="+1 555-0199")
                    with col_ctry:
                        ctry = st.text_input("Country", placeholder="United States")

                    sub2 = st.form_submit_button("Create Account & Start Learning", type="primary", use_container_width=True)

                if sub2:
                    if not fn.strip() or not ln.strip() or not se.strip() or not sp:
                        st.error("Please fill in all required fields (First Name, Last Name, Email, and Password).")
                    elif len(sp) < 6:
                        st.error("Password must be at least 6 characters long.")
                    else:
                        with st.spinner("Creating account..."):
                            try:
                                from models.user_schemas import UserCreateRequest
                                from services.auth_service import AuthService
                                from services.database import get_db_session
                                from services.user_service import UserService

                                async def _signup():
                                    async with get_db_session() as db:
                                        req = UserCreateRequest(
                                            first_name=fn.strip(),
                                            last_name=ln.strip(),
                                            email=se.strip(),
                                            password=sp,
                                            mobile=mob.strip() if mob and mob.strip() else None,
                                            country=ctry.strip() if ctry and ctry.strip() else None,
                                        )
                                        cu = await UserService.create_user(db, req)
                                        return AuthService.get_user_current_profile(cu)

                                p = run_async(_signup())
                                st.session_state["user_profile"] = p
                                st.session_state["view"] = "learning"
                                st.toast(f"Welcome, {p.first_name}! Account created successfully.", icon="🎉")
                                st.rerun()
                            except Exception as e:
                                st.error(f"Registration failed: {e}")

    # ── Trust Badges Footer ───────────────────────────────────
    st.markdown(
        """
        <div style="text-align:center; margin-top:2.5rem; padding-bottom:1rem;">
            <div style="display:inline-flex; align-items:center; gap:24px; color:rgba(255,255,255,0.3); font-size:0.8rem; font-weight:600;">
                <span>&#x1F512; 256-bit SSL Security</span>
                <span>&bull;</span>
                <span>&#x1F6E1; SOC 2 Compliant Infrastructure</span>
                <span>&bull;</span>
                <span>&#x26A1; Instant Account Activation</span>
            </div>
        </div>
        """,
        unsafe_allow_html=True,
    )


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  HELPERS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
def _make_demo_profile(email: str):
    from models.auth_schemas import UserCurrentProfileResponse
    from models.subscription_schemas import SubscriptionResponse
    from datetime import datetime, timezone

    t = "pro" if "pro" in email else "normal"
    return UserCurrentProfileResponse(
        id="demo-user-123", first_name="Demo", last_name="Learner", email=email,
        created_at=datetime.now(timezone.utc), roles=["student"],
        subscription=SubscriptionResponse(id=1, user_id="demo-user-123", tier=t, status="active",
                                          current_period_start=datetime.now(timezone.utc)),
        privilege_codes=["ET_VIEW_LESSON", "ET_TAKE_QUIZ", "ET_VIEW_SUBSCRIPTION"],
    )


def _quick_demo_login(email: str, pw: str):
    try:
        from services.auth_service import AuthService
        from services.database import get_db_session

        async def _do():
            async with get_db_session() as db:
                u = await AuthService.authenticate_user(db, email, pw)
                return AuthService.get_user_current_profile(u)

        p = run_async(_do())
        st.session_state["user_profile"] = p
        st.session_state["view"] = "learning"
        st.toast(f"Logged in as {p.first_name}", icon="⚡")
        st.rerun()
    except Exception:
        st.session_state["user_profile"] = _make_demo_profile(email)
        st.session_state["view"] = "learning"
        st.toast(f"Demo ({'PRO' if 'pro' in email else 'NORMAL'} Tier)", icon="⚡")
        st.rerun()


def _handle_tier_select(tier: str):
    up = st.session_state.get("user_profile")
    st.session_state["selected_tier"] = tier

    if not up:
        st.session_state["auth_tab"] = "signup"
        st.session_state["view"] = "auth"
        st.toast(f"🔒 Sign in to select {tier.upper()} Tier.", icon="🔒")
        st.rerun()
    else:
        try:
            from models.subscription_schemas import SubscriptionUpdateRequest
            from services.database import get_db_session
            from services.subscription_service import SubscriptionService
            from services.auth_service import AuthService
            from services.user_service import UserService

            async def _up():
                async with get_db_session() as db:
                    await SubscriptionService.update_user_subscription_tier(db, user_id=up.id,
                                                                           request=SubscriptionUpdateRequest(tier=tier))
                    u = await UserService.get_user_by_id(db, up.id)
                    return AuthService.get_user_current_profile(u)

            p = run_async(_up())
            st.session_state["user_profile"] = p
            st.toast(f"Subscription → {tier.upper()}!", icon="⭐")
            st.rerun()
        except Exception:
            st.toast(f"Tier: {tier.upper()}", icon="⚡")
            st.session_state["view"] = "learning"
            st.rerun()
