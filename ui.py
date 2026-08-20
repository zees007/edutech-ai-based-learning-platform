"""
EduTechAI — Interactive Learning Workspace (Streamlit Frontend)

An adaptive, interactive educational workspace powered by autonomous AI agents.
Features:
- Real-time Socratic Tutoring with age-appropriate explanations & analogies
- Dynamic YouTube video search with precise timestamp deep-linking
- Open-access academic paper curation (OpenAlex, Semantic Scholar, arXiv)
- Interactive comprehension quizzes with instant grading & XP rewards
- Gamified leveling system & progress tracking
- Configurable Learning Modes (Visual, Deep Dive, Bite-Sized)
"""

from __future__ import annotations

import asyncio
import html
import logging
import os
import time

import streamlit as st
import streamlit.components.v1 as components

from config import sync_streamlit_secrets

# Safely sync Streamlit Cloud secrets to os.environ for Pydantic Settings & Services
sync_streamlit_secrets()

# ─── Page Configuration ──────────────────────────────────────────
st.set_page_config(
    page_title="EduTechAI — Learning Workspace",
    page_icon="🎓",
    layout="wide",
    initial_sidebar_state="expanded",
)

# Suppress background logs in Streamlit
logging.getLogger("httpx").setLevel(logging.WARNING)

# Import backend modules
from agents.academic_researcher import AcademicResearcherAgent
from agents.orchestrator import OrchestratorAgent
from agents.quiz_agent import QuizAgent
from agents.socratic_tutor import SocraticTutorAgent
from agents.youtube_curator import YouTubeCuratorAgent
from config import get_settings
from models.schemas import LearningMode, StepStatus
from models.shared_memory import SharedMemory
from services.gamification import calculate_level, calculate_quiz_xp, calculate_step_xp

# ─── Custom CSS Styling — Glassy AI Theme (Matching Landing Page) ──────────
CUSTOM_CSS = """
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

    @keyframes n8nPulseGlow {
        0%, 100% { transform: scale(1); opacity: 0.85; box-shadow: 0 0 15px rgba(168, 85, 247, 0.35); }
        50% { transform: scale(1.005); opacity: 1; box-shadow: 0 0 30px rgba(6, 182, 212, 0.6); }
    }

    @keyframes meshGlow {
        0% { background-position: 0% 50%; }
        50% { background-position: 100% 50%; }
        100% { background-position: 0% 50%; }
    }

    /* ── Global Page & Atmosphere ────────────────────── */
    .stApp {
        background-color: #0E0918 !important;
        color: #FAFAFA !important;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif !important;
    }

    .block-container {
        padding-top: 1.5rem !important;
        padding-bottom: 3rem !important;
    }

    /* Eliminate spacing from 0-height custom components, wrappers, and background elements */
    div[data-testid="stCustomComponentV1"],
    div.element-container:has(iframe[height="0"]),
    div.stCustomComponentV1:has(iframe[height="0"]),
    iframe[height="0"] {
        display: none !important;
        margin: 0 !important;
        padding: 0 !important;
        height: 0px !important;
        min-height: 0px !important;
        border: none !important;
    }

    /* ── Glowing Background Orbs ───────────────────── */
    .glow-bg {
        position: fixed;
        top: 0; left: 0; right: 0; bottom: 0;
        pointer-events: none;
        z-index: 0;
        background:
            radial-gradient(ellipse 650px 450px at 15% 10%, rgba(139, 92, 246, 0.14) 0%, transparent 70%),
            radial-gradient(ellipse 550px 380px at 85% 30%, rgba(236, 72, 153, 0.09) 0%, transparent 70%),
            radial-gradient(ellipse 450px 320px at 50% 80%, rgba(59, 130, 246, 0.08) 0%, transparent 70%);
    }

    /* ── Signature Gradient Text & Headings ──────────── */
    .main-title {
        font-size: 2.2rem;
        font-weight: 900;
        background: linear-gradient(135deg, #EC4899 0%, #A855F7 50%, #3B82F6 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        letter-spacing: -0.5px;
        line-height: 1.2;
        margin-bottom: 0.3rem;
    }
    
    .sub-title {
        color: rgba(233, 213, 255, 0.75);
        font-size: 1.0rem;
        margin-bottom: 1.5rem;
        line-height: 1.5;
    }

    .gradient-text {
        background: linear-gradient(135deg, #EC4899 0%, #A855F7 50%, #3B82F6 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        display: inline;
    }

    .section-badge {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        background: rgba(168, 85, 247, 0.12);
        border: 1px solid rgba(168, 85, 247, 0.35);
        color: #E9D5FF;
        font-size: 0.75rem;
        font-weight: 800;
        padding: 5px 16px;
        border-radius: 24px;
        box-shadow: 0 0 20px rgba(168, 85, 247, 0.2);
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-bottom: 1rem;
    }

    /* ── Streamlit Header: Completely Hidden from View ── */
    html body div.stApp header[data-testid="stHeader"],
    html body div.stApp [data-testid="stHeader"] {
        background: transparent !important;
        height: 0px !important;
        min-height: 0px !important;
        max-height: 0px !important;
        padding: 0 !important;
        margin: 0 !important;
        border: none !important;
        box-shadow: none !important;
        pointer-events: none !important;
        opacity: 0 !important;
        visibility: hidden !important;
        overflow: hidden !important;
        display: none !important;
    }

    /* Cleanly target deploy buttons, decoration line, main menu, and header anchor link icons */
    html body div.stApp .stDeployButton,
    html body div.stApp [data-testid="stAppDeployButton"],
    html body div.stApp button[data-testid="stAppDeployButton"],
    html body div.stApp #MainMenu, 
    html body div.stApp [data-testid="stDecoration"], 
    html body div.stApp [data-testid="stHeaderActionElements"],
    html body div.stApp a[aria-label="Link to heading"],
    html body div.stApp footer {
        display: none !important;
        visibility: hidden !important;
        height: 0px !important;
        width: 0px !important;
        opacity: 0 !important;
        pointer-events: none !important;
    }

    /* ── Sidebar Layout & Default Controls Clean Up ── */
    html body div.stApp section[data-testid="stSidebar"] {
        display: flex !important;
        visibility: visible !important;
        opacity: 1 !important;
    }

    /* Hide ALL native default collapse and expand controls & sidebar headers visually while keeping them click-active in viewport */
    html body div.stApp [data-testid="stSidebarHeader"],
    html body div.stApp [data-testid="stLogoSpacer"],
    html body div.stApp [data-testid="stSidebarCollapseButton"],
    html body div.stApp [data-testid="stSidebarCollapsedControl"],
    html body div.stApp [data-testid="collapsedControl"],
    html body div.stApp header[data-testid="stHeader"] [data-testid="stSidebarCollapsedControl"],
    html body div.stApp header[data-testid="stHeader"] [data-testid="collapsedControl"],
    html body div.stApp header[data-testid="stHeader"] button,
    html body div.stApp [data-testid="stHeader"] button,
    html body div.stApp button[kind="header"] {
        opacity: 0 !important;
        position: fixed !important;
        top: 10px !important;
        left: 10px !important;
        width: 32px !important;
        height: 32px !important;
        max-width: 32px !important;
        max-height: 32px !important;
        padding: 0 !important;
        margin: 0 !important;
        border: none !important;
        overflow: hidden !important;
        pointer-events: auto !important;
        visibility: visible !important;
        z-index: 1 !important;
    }

    /* ── Logo — Exact Home Page Branding ─────────────── */
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

    .et-nav-topic {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        background: rgba(168, 85, 247, 0.12);
        border: 1px solid rgba(168, 85, 247, 0.35);
        border-radius: 20px;
        padding: 4px 14px;
        color: #E9D5FF;
        font-size: 0.82rem;
        font-weight: 700;
        max-width: 380px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    /* ── Hero Center Typography (Matches Auth Title Size Exactly) ────── */
    .et-hero {
        text-align: center;
        padding: 0 !important;
        margin: 0 auto 0.4rem auto !important;
        position: relative;
    }

    .et-hero h1,
    div[data-testid="stMarkdownContainer"] .et-hero h1,
    .et-hero > h1 {
        font-size: 2.1rem !important;
        font-weight: 900 !important;
        color: #FAFAFA !important;
        line-height: 1.25 !important;
        letter-spacing: -0.5px !important;
        margin-top: 0 !important;
        margin-bottom: 0.5rem !important;
        padding: 0 !important;
        max-width: 900px !important;
        margin-left: auto !important;
        margin-right: auto !important;
        white-space: normal !important;
    }

    .et-hero .gradient-text {
        background: linear-gradient(135deg, #EC4899 0%, #A855F7 50%, #3B82F6 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
    }

    .et-hero p {
        font-size: 0.98rem !important;
        color: rgba(233, 213, 255, 0.75) !important;
        max-width: 660px;
        margin: 0 auto 1.2rem auto;
        line-height: 1.5 !important;
    }

    /* ── App Theme Glass Container Card for Start Journey (Exact Match of Sign In Form in home_ui.py) ── */
    div[data-testid="stColumn"]:has(#journey-console-card-marker),
    div[data-testid="column"]:has(#journey-console-card-marker) {
        background: linear-gradient(135deg, rgba(15, 23, 42, 0.94) 0%, rgba(26, 17, 46, 0.9) 100%) !important;
        backdrop-filter: blur(30px) !important;
        -webkit-backdrop-filter: blur(30px) !important;
        border: 1.5px solid rgba(168, 85, 247, 0.45) !important;
        border-radius: 24px !important;
        padding: 1.8rem 2.2rem 1.4rem 2.2rem !important;
        margin-top: 0.8rem !important;
        margin-bottom: 1.4rem !important;
        box-shadow: 0 25px 65px -15px rgba(168, 85, 247, 0.35), inset 0 0 35px rgba(168, 85, 247, 0.12) !important;
        position: relative !important;
        box-sizing: border-box !important;
        overflow: hidden !important;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1) !important;
    }

    div[data-testid="stColumn"]:has(#journey-console-card-marker)::before,
    div[data-testid="column"]:has(#journey-console-card-marker)::before {
        content: '' !important;
        position: absolute !important;
        top: 0 !important;
        left: 10% !important;
        right: 10% !important;
        height: 3px !important;
        background: linear-gradient(90deg, transparent 0%, #EC4899 25%, #A855F7 50%, #3B82F6 75%, transparent 100%) !important;
        border-radius: 3px !important;
        box-shadow: 0 0 15px #EC4899, 0 0 20px #A855F7 !important;
        opacity: 1 !important;
        z-index: 10 !important;
        transition: opacity 0.3s ease, box-shadow 0.3s ease !important;
    }

    div[data-testid="stColumn"]:has(#journey-console-card-marker):hover,
    div[data-testid="column"]:has(#journey-console-card-marker):hover {
        border-color: rgba(168, 85, 247, 0.85) !important;
        box-shadow: 0 30px 75px -10px rgba(168, 85, 247, 0.55), inset 0 0 45px rgba(168, 85, 247, 0.2) !important;
        transform: translateY(-2px) !important;
    }

    div[data-testid="stColumn"]:has(#journey-console-card-marker):hover::before,
    div[data-testid="column"]:has(#journey-console-card-marker):hover::before {
        opacity: 1 !important;
        box-shadow: 0 0 22px #EC4899, 0 0 30px #A855F7 !important;
    }

    div[data-testid="stColumn"]:has(#journey-console-card-marker) div[data-testid="stForm"],
    div[data-testid="column"]:has(#journey-console-card-marker) div[data-testid="stForm"] {
        border: none !important;
        padding: 0 !important;
        background: transparent !important;
        box-shadow: none !important;
    }

    /* Labels inside journey glass card */
    div[data-testid="stColumn"]:has(#journey-console-card-marker) label,
    div[data-testid="stColumn"]:has(#journey-console-card-marker) label p,
    div[data-testid="column"]:has(#journey-console-card-marker) label,
    div[data-testid="column"]:has(#journey-console-card-marker) label p {
        color: rgba(233, 213, 255, 0.92) !important;
        font-size: 0.86rem !important;
        font-weight: 700 !important;
        letter-spacing: 0.3px !important;
        margin-bottom: 4px !important;
    }

    /* Inputs & Selectboxes inside journey glass card (Matching Sign In BaseWeb Theme) */
    div[data-testid="stColumn"]:has(#journey-console-card-marker) div[data-baseweb="input"],
    div[data-testid="stColumn"]:has(#journey-console-card-marker) div[data-baseweb="base-input"],
    div[data-testid="stColumn"]:has(#journey-console-card-marker) div[data-baseweb="select"] > div,
    div[data-testid="stColumn"]:has(#journey-console-card-marker) div[data-testid="stSelectbox"] > div > div,
    div[data-testid="column"]:has(#journey-console-card-marker) div[data-baseweb="input"],
    div[data-testid="column"]:has(#journey-console-card-marker) div[data-baseweb="base-input"],
    div[data-testid="column"]:has(#journey-console-card-marker) div[data-baseweb="select"] > div,
    div[data-testid="column"]:has(#journey-console-card-marker) div[data-testid="stSelectbox"] > div > div {
        background: rgba(15, 23, 42, 0.75) !important;
        border: 1.5px solid rgba(168, 85, 247, 0.35) !important;
        border-radius: 14px !important;
        transition: all 0.25s ease !important;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.25), inset 0 0 10px rgba(0, 0, 0, 0.3) !important;
    }

    div[data-testid="stColumn"]:has(#journey-console-card-marker) div[data-baseweb="input"]:hover,
    div[data-testid="stColumn"]:has(#journey-console-card-marker) div[data-baseweb="select"] > div:hover,
    div[data-testid="stColumn"]:has(#journey-console-card-marker) div[data-testid="stSelectbox"] > div > div:hover,
    div[data-testid="column"]:has(#journey-console-card-marker) div[data-baseweb="input"]:hover,
    div[data-testid="column"]:has(#journey-console-card-marker) div[data-baseweb="select"] > div:hover,
    div[data-testid="column"]:has(#journey-console-card-marker) div[data-testid="stSelectbox"] > div > div:hover {
        border-color: rgba(168, 85, 247, 0.65) !important;
        box-shadow: 0 0 16px rgba(168, 85, 247, 0.28) !important;
    }

    div[data-testid="stColumn"]:has(#journey-console-card-marker) div[data-baseweb="input"]:focus-within,
    div[data-testid="stColumn"]:has(#journey-console-card-marker) div[data-baseweb="select"] > div:focus-within,
    div[data-testid="stColumn"]:has(#journey-console-card-marker) div[data-testid="stSelectbox"] > div > div:focus-within,
    div[data-testid="column"]:has(#journey-console-card-marker) div[data-baseweb="input"]:focus-within,
    div[data-testid="column"]:has(#journey-console-card-marker) div[data-baseweb="select"] > div:focus-within,
    div[data-testid="column"]:has(#journey-console-card-marker) div[data-testid="stSelectbox"] > div > div:focus-within {
        border-color: rgba(168, 85, 247, 0.95) !important;
        box-shadow: 0 0 25px rgba(168, 85, 247, 0.45), inset 0 0 12px rgba(168, 85, 247, 0.15) !important;
        background: rgba(15, 23, 42, 0.92) !important;
    }

    div[data-testid="stColumn"]:has(#journey-console-card-marker) input,
    div[data-testid="column"]:has(#journey-console-card-marker) input {
        color: #FAFAFA !important;
        font-size: 0.94rem !important;
        font-weight: 500 !important;
        padding: 10px 14px !important;
    }

    div[data-testid="stColumn"]:has(#journey-console-card-marker) input::placeholder,
    div[data-testid="column"]:has(#journey-console-card-marker) input::placeholder {
        color: rgba(233, 213, 255, 0.38) !important;
    }

    /* ✨ Start Journey Theme Button Gradient (Matching Sign In Launch Button) */
    div[data-testid="stColumn"]:has(#journey-console-card-marker) div[data-testid="stFormSubmitButton"] button,
    div[data-testid="stColumn"]:has(#journey-console-card-marker) div[data-testid="stFormSubmitButton"] button[kind="primary"],
    div[data-testid="column"]:has(#journey-console-card-marker) div[data-testid="stFormSubmitButton"] button,
    div[data-testid="column"]:has(#journey-console-card-marker) div[data-testid="stFormSubmitButton"] button[kind="primary"] {
        background: linear-gradient(135deg, #EC4899 0%, #A855F7 50%, #3B82F6 100%) !important;
        background-color: transparent !important;
        border: none !important;
        border-radius: 14px !important;
        color: #FFFFFF !important;
        font-weight: 800 !important;
        font-size: 0.96rem !important;
        letter-spacing: 0.3px !important;
        padding: 11px 20px !important;
        min-height: 46px !important;
        box-shadow: 0 8px 25px rgba(168, 85, 247, 0.4), 0 0 20px rgba(236, 72, 153, 0.25) !important;
        transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1) !important;
        cursor: pointer !important;
    }

    div[data-testid="stColumn"]:has(#journey-console-card-marker) div[data-testid="stFormSubmitButton"] button:hover,
    div[data-testid="stColumn"]:has(#journey-console-card-marker) div[data-testid="stFormSubmitButton"] button[kind="primary"]:hover,
    div[data-testid="column"]:has(#journey-console-card-marker) div[data-testid="stFormSubmitButton"] button:hover,
    div[data-testid="column"]:has(#journey-console-card-marker) div[data-testid="stFormSubmitButton"] button[kind="primary"]:hover {
        transform: translateY(-2px) scale(1.01) !important;
        box-shadow: 0 12px 35px rgba(168, 85, 247, 0.6), 0 0 30px rgba(59, 130, 246, 0.45) !important;
    }

    /* Popover Trigger for Topic Suggestions */
    div[data-testid="stColumn"]:has(#journey-console-card-marker) div[data-testid="stPopover"],
    div[data-testid="column"]:has(#journey-console-card-marker) div[data-testid="stPopover"] {
        margin-top: 4px !important;
    }

    div[data-testid="stColumn"]:has(#journey-console-card-marker) div[data-testid="stPopover"] button,
    div[data-testid="column"]:has(#journey-console-card-marker) div[data-testid="stPopover"] button {
        background: rgba(168, 85, 247, 0.1) !important;
        border: 1px solid rgba(168, 85, 247, 0.3) !important;
        border-radius: 10px !important;
        color: #E9D5FF !important;
        font-size: 0.84rem !important;
        font-weight: 600 !important;
        padding: 5px 12px !important;
        transition: all 0.2s ease !important;
    }

    div[data-testid="stColumn"]:has(#journey-console-card-marker) div[data-testid="stPopover"] button:hover,
    div[data-testid="column"]:has(#journey-console-card-marker) div[data-testid="stPopover"] button:hover {
        background: rgba(168, 85, 247, 0.22) !important;
        border-color: #C084FC !important;
        color: #FFFFFF !important;
        box-shadow: 0 0 12px rgba(168, 85, 247, 0.3) !important;
    }

    .journey-tip-footer {
        display: flex;
        align-items: center;
        gap: 6px;
        font-size: 0.76rem;
        color: rgba(233, 213, 255, 0.6);
        margin-top: 8px;
        padding-top: 4px;
    }

    /* ── Navbar — Floating Glassmorphism Theme (Learning Workspace) ───────── */
    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) {
        background: rgba(15, 23, 42, 0.85) !important;
        backdrop-filter: blur(20px) !important;
        -webkit-backdrop-filter: blur(20px) !important;
        border: 1px solid rgba(168, 85, 247, 0.45) !important;
        border-radius: 50px !important;
        padding: 8px 24px !important;
        margin: 0rem 0 1.5rem 0 !important;
        box-shadow: 0 0 30px rgba(168, 85, 247, 0.25), 0 10px 30px rgba(0, 0, 0, 0.5), inset 0 0 20px rgba(168, 85, 247, 0.15) !important;
        width: 100% !important;
        box-sizing: border-box !important;
        align-items: center !important;
        justify-content: space-between !important;
        min-height: 52px !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) * {
        align-self: center !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) div[data-testid="column"],
    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) div[data-testid="stColumn"] {
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        padding: 0 !important;
        margin: 0 !important;
        height: auto !important;
        min-height: 0 !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) div[data-testid="column"]:first-child,
    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) div[data-testid="stColumn"]:first-child {
        justify-content: flex-start !important;
        padding-left: 0 !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) div[data-testid="column"]:first-child *,
    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) div[data-testid="stColumn"]:first-child * {
        justify-content: flex-start !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) div[data-testid="column"]:last-child,
    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) div[data-testid="stColumn"]:last-child {
        justify-content: flex-end !important;
        padding-right: 0 !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) div[data-testid="stVerticalBlock"],
    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) div[data-testid="stVerticalBlockBorderWrapper"] {
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

    /* Nested horizontal blocks inside the last column (icon button row) */
    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) div[data-testid="column"]:last-child div[data-testid="stHorizontalBlock"],
    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) div[data-testid="stColumn"]:last-child div[data-testid="stHorizontalBlock"] {
        align-items: center !important;
        justify-content: flex-end !important;
        gap: 10px !important;
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
    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) div[data-testid="column"]:last-child div[data-testid="stHorizontalBlock"] > div[data-testid="column"],
    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) div[data-testid="column"]:last-child div[data-testid="stHorizontalBlock"] > div[data-testid="stColumn"],
    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) div[data-testid="stColumn"]:last-child div[data-testid="stHorizontalBlock"] > div[data-testid="column"],
    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) div[data-testid="stColumn"]:last-child div[data-testid="stHorizontalBlock"] > div[data-testid="stColumn"] {
        flex: 0 0 auto !important;
        width: auto !important;
        min-width: 0 !important;
        max-width: none !important;
        padding: 0 !important;
        margin: 0 !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) div.element-container,
    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) div[data-testid="stElementContainer"] {
        margin: 0 !important;
        padding: 0 !important;
        display: flex !important;
        align-items: center !important;
        align-self: center !important;
        justify-content: center !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) div.stMarkdown,
    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) div[data-testid="stMarkdownContainer"] {
        display: flex !important;
        align-items: center !important;
        align-self: center !important;
        margin: 0 !important;
        padding: 0 !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) div.stMarkdown p,
    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) div[data-testid="stMarkdownContainer"] p {
        margin: 0 !important;
        padding: 0 !important;
        line-height: 1 !important;
        display: inline-flex !important;
        align-items: center !important;
    }

    /* Modern Circular Icon Buttons (Admin & Profile) & Mobile Responsive Top Navbar */
    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) {
        display: flex !important;
        flex-direction: row !important;
        flex-wrap: nowrap !important;
        justify-content: space-between !important;
        align-items: center !important;
        width: 100% !important;
        gap: 8px !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) > div[data-testid="column"],
    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) > div[data-testid="stColumn"] {
        width: auto !important;
        min-width: auto !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) > div[data-testid="column"]:first-child,
    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) > div[data-testid="stColumn"]:first-child {
        flex: 1 1 auto !important;
        display: flex !important;
        align-items: center !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) > div[data-testid="column"]:last-child,
    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) > div[data-testid="stColumn"]:last-child {
        display: flex !important;
        justify-content: flex-end !important;
        align-items: center !important;
        flex: 0 0 auto !important;
    }

    /* Nested button columns for Settings & Profile icons */
    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) div[data-testid="stColumn"] div[data-testid="stHorizontalBlock"] {
        display: flex !important;
        flex-direction: row !important;
        flex-wrap: nowrap !important;
        align-items: center !important;
        justify-content: flex-end !important;
        gap: 8px !important;
        width: auto !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) div[data-testid="stColumn"] div[data-testid="stHorizontalBlock"] > div {
        width: 38px !important;
        min-width: 38px !important;
        max-width: 38px !important;
        flex: 0 0 38px !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) div[data-testid="stButton"],
    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) div[data-testid="stPopover"] {
        margin: 0 !important;
        padding: 0 !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        align-self: center !important;
        width: 38px !important;
        height: 38px !important;
        min-width: 38px !important;
        max-width: 38px !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) button {
        height: 38px !important;
        width: 38px !important;
        min-height: 38px !important;
        max-height: 38px !important;
        min-width: 38px !important;
        max-width: 38px !important;
        padding: 0 !important;
        border-radius: 50% !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        text-align: center !important;
        box-sizing: border-box !important;
        background: rgba(30, 41, 59, 0.75) !important;
        border: 1px solid rgba(168, 85, 247, 0.4) !important;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.25) !important;
        backdrop-filter: blur(12px) !important;
        -webkit-backdrop-filter: blur(12px) !important;
        transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1) !important;
        margin: 0 auto !important;
        cursor: pointer !important;
        color: #E9D5FF !important;
        overflow: hidden !important;
        gap: 0 !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) button > div {
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        height: 100% !important;
        width: 100% !important;
        margin: 0 auto !important;
        padding: 0 !important;
        gap: 0 !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) button [data-testid="stIconMaterial"],
    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) button svg {
        font-size: 20px !important;
        width: 20px !important;
        height: 20px !important;
        color: #E9D5FF !important;
        fill: currentColor !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        margin: 0 auto !important;
        transition: all 0.2s ease !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) button div[data-testid="stMarkdownContainer"],
    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) button div[data-testid="stMarkdownContainer"] p,
    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) button p,
    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) button span {
        padding: 0 !important;
        margin: 0 !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        text-align: center !important;
        line-height: 1 !important;
        width: 100% !important;
        height: 100% !important;
        transform: none !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) button:hover {
        background: rgba(168, 85, 247, 0.3) !important;
        border-color: rgba(168, 85, 247, 0.85) !important;
        box-shadow: 0 0 16px rgba(168, 85, 247, 0.5) !important;
        transform: translateY(-2px) !important;
        color: #FFFFFF !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) button:hover [data-testid="stIconMaterial"],
    div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) button:hover svg {
        color: #FFFFFF !important;
        filter: drop-shadow(0 0 8px rgba(168, 85, 247, 0.9)) !important;
    }

    /* Hide Chevron / Expand Arrow inside stPopover toggle button without hiding profile icon */
    div[data-testid="stPopover"] button [data-testid="stIconMaterial"]:last-of-type:not(:first-of-type),
    div[data-testid="stPopover"] button [data-testid="stIconChevron"],
    div[data-testid="stPopover"] button svg[data-testid="stIconChevron"],
    div[data-testid="stPopover"] button > div > *:nth-child(n+2),
    div[data-testid="stPopover"] button span + span {
        display: none !important;
        visibility: hidden !important;
        width: 0 !important;
        height: 0 !important;
        margin: 0 !important;
        padding: 0 !important;
        opacity: 0 !important;
        pointer-events: none !important;
        position: absolute !important;
    }

    /* Mobile Responsive Optimizations */
    @media (max-width: 768px) {
        .et-learning-nav .et-logo {
            font-size: 1.15rem !important;
        }
        .et-learning-nav .badge-ai {
            font-size: 0.65rem !important;
            padding: 1px 6px !important;
        }
        div[data-testid="stHorizontalBlock"]:has(.et-learning-nav) {
            gap: 6px !important;
        }
    }

    /* ── Luminous Neon Glassmorphism Spinner / Loader ── */
    div[data-testid="stSpinner"],
    .stSpinner {
        display: flex !important;
        flex-direction: row !important;
        align-items: center !important;
        justify-content: center !important;
        gap: 12px !important;
        background: linear-gradient(135deg, rgba(20, 13, 33, 0.96) 0%, rgba(30, 20, 50, 0.92) 100%) !important;
        backdrop-filter: blur(25px) !important;
        -webkit-backdrop-filter: blur(25px) !important;
        border: 1.5px solid rgba(168, 85, 247, 0.55) !important;
        border-radius: 20px !important;
        padding: 12px 20px !important;
        margin: 1.2rem auto !important;
        box-shadow: 0 0 35px rgba(168, 85, 247, 0.35), 0 10px 30px rgba(0, 0, 0, 0.6), inset 0 0 20px rgba(168, 85, 247, 0.15) !important;
        width: fit-content !important;
        max-width: 100% !important;
        box-sizing: border-box !important;
        animation: spinnerGlowPulse 2.5s infinite ease-in-out !important;
        position: relative !important;
        overflow: visible !important;
    }

    /* Top Accent Line for Spinner */
    div[data-testid="stSpinner"]::before,
    .stSpinner::before {
        content: '' !important;
        position: absolute !important;
        top: 0 !important; left: 10% !important; right: 10% !important; height: 2px !important;
        background: linear-gradient(90deg, transparent 0%, #EC4899 30%, #A855F7 50%, #06B6D4 70%, transparent 100%) !important;
        border-radius: 2px !important;
        box-shadow: 0 0 10px #EC4899, 0 0 14px #A855F7 !important;
    }

    /* Pulse Glow Animation for Loader */
    @keyframes spinnerGlowPulse {
        0%, 100% {
            border-color: rgba(168, 85, 247, 0.45);
            box-shadow: 0 0 30px rgba(168, 85, 247, 0.3), 0 10px 30px rgba(0, 0, 0, 0.6), inset 0 0 15px rgba(168, 85, 247, 0.1);
        }
        50% {
            border-color: rgba(6, 182, 212, 0.8);
            box-shadow: 0 0 45px rgba(6, 182, 212, 0.45), 0 0 30px rgba(168, 85, 247, 0.35), 0 10px 30px rgba(0, 0, 0, 0.7), inset 0 0 25px rgba(6, 182, 212, 0.2);
            transform: scale(1.02);
        }
    }

    /* Spinner Icon Glow & Colors */
    div[data-testid="stSpinner"] > i,
    div[data-testid="stSpinner"] svg,
    .stSpinner svg {
        border-top-color: #EC4899 !important;
        border-right-color: #A855F7 !important;
        border-bottom-color: #06B6D4 !important;
        border-left-color: transparent !important;
        filter: drop-shadow(0 0 10px rgba(168, 85, 247, 0.9)) !important;
        width: 22px !important;
        height: 22px !important;
        flex-shrink: 0 !important;
    }

    /* Spinner Text */
    div[data-testid="stSpinner"] div[data-testid="stMarkdownContainer"],
    .stSpinner div[data-testid="stMarkdownContainer"] {
        margin: 0 !important;
        padding: 0 !important;
        max-width: 100% !important;
    }

    div[data-testid="stSpinner"] p,
    .stSpinner p {
        font-size: 0.90rem !important;
        font-weight: 800 !important;
        letter-spacing: 0.3px !important;
        background: linear-gradient(135deg, #F472B6 0%, #C084FC 50%, #38BDF8 100%) !important;
        -webkit-background-clip: text !important;
        -webkit-text-fill-color: transparent !important;
        margin: 0 !important;
        padding: 0 !important;
        line-height: 1.4 !important;
        text-shadow: 0 0 15px rgba(168, 85, 247, 0.3) !important;
        white-space: normal !important;
        word-break: break-word !important;
        text-align: left !important;
    }

    /* Popover Content Styling */
    div[data-testid="stPopoverBody"] {
        background: rgba(15, 23, 42, 0.95) !important;
        backdrop-filter: blur(24px) !important;
        -webkit-backdrop-filter: blur(24px) !important;
        border: 1px solid rgba(168, 85, 247, 0.5) !important;
        border-radius: 16px !important;
        padding: 16px !important;
        box-shadow: 0 20px 50px rgba(0, 0, 0, 0.7), 0 0 25px rgba(168, 85, 247, 0.25) !important;
        color: #FAFAFA !important;
        min-width: 260px !important;
        z-index: 99999 !important;
    }

    div[data-testid="stPopoverBody"] hr {
        border-color: rgba(168, 85, 247, 0.25) !important;
        margin: 10px 0 !important;
    }

    div[data-testid="stPopoverBody"] button {
        width: 100% !important;
        max-width: none !important;
        height: auto !important;
        max-height: none !important;
        min-height: 38px !important;
        padding: 8px 16px !important;
        border-radius: 10px !important;
        font-size: 0.88rem !important;
        font-weight: 700 !important;
        background: rgba(239, 68, 68, 0.15) !important;
        border: 1px solid rgba(239, 68, 68, 0.4) !important;
        color: #FCA5A5 !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        gap: 6px !important;
        transition: all 0.2s ease !important;
    }

    div[data-testid="stPopoverBody"] button:hover {
        background: rgba(239, 68, 68, 0.3) !important;
        border-color: rgba(239, 68, 68, 0.8) !important;
        box-shadow: 0 0 16px rgba(239, 68, 68, 0.4) !important;
        color: #FFFFFF !important;
        transform: translateY(-1px) !important;
    }

    /* ── Glassmorphism Cards & Containers ────────────── */
    .glass-card, .feat-card, .agent-glass, div[data-testid="stColumn"]:has(.aj-card-marker), div[data-testid="column"]:has(.aj-card-marker) {
        position: relative !important;
        background: linear-gradient(135deg, rgba(30, 41, 59, 0.85) 0%, rgba(124, 58, 237, 0.16) 50%, rgba(15, 23, 42, 0.9) 100%) !important;
        backdrop-filter: blur(20px) !important;
        -webkit-backdrop-filter: blur(20px) !important;
        border: 1px solid rgba(168, 85, 247, 0.4) !important;
        border-radius: 18px !important;
        padding: 1.4rem !important;
        margin-bottom: 1rem !important;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4), 0 0 25px rgba(168, 85, 247, 0.2), inset 0 0 20px rgba(168, 85, 247, 0.1) !important;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1) !important;
        overflow: hidden !important;
    }

    .glass-card::before, .feat-card::before, .agent-glass::before, .top-progress-card::before, div[data-testid="stColumn"]:has(.aj-card-marker)::before, div[data-testid="column"]:has(.aj-card-marker)::before {
        content: '' !important;
        position: absolute !important;
        top: 0 !important; left: 15% !important; right: 15% !important; height: 2px !important;
        background: linear-gradient(90deg, transparent 0%, #EC4899 30%, #A855F7 50%, #06B6D4 70%, transparent 100%) !important;
        border-radius: 2px !important;
        opacity: 0.75 !important;
        transition: opacity 0.3s ease, box-shadow 0.3s ease !important;
        z-index: 5 !important;
    }

    .glass-card:hover, .feat-card:hover, .agent-glass:hover, div[data-testid="stColumn"]:has(.aj-card-marker):hover, div[data-testid="column"]:has(.aj-card-marker):hover {
        background: linear-gradient(135deg, rgba(124, 58, 237, 0.28) 0%, rgba(59, 130, 246, 0.2) 50%, rgba(15, 23, 42, 0.95) 100%) !important;
        border-color: rgba(168, 85, 247, 0.75) !important;
        box-shadow: 0 0 40px rgba(168, 85, 247, 0.35), 0 12px 35px rgba(0, 0, 0, 0.5), inset 0 0 25px rgba(168, 85, 247, 0.15) !important;
        transform: translateY(-3px) !important;
    }

    .glass-card:hover::before, .feat-card:hover::before, .agent-glass:hover::before, div[data-testid="stColumn"]:has(.aj-card-marker):hover::before, div[data-testid="column"]:has(.aj-card-marker):hover::before {
        opacity: 1 !important;
        box-shadow: 0 0 14px #EC4899, 0 0 20px #A855F7 !important;
    }

    .feat-card h4, .agent-glass h4, .glass-card h3 {
        background: linear-gradient(135deg, #EC4899 0%, #A855F7 50%, #3B82F6 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        font-weight: 800;
        margin-bottom: 0.5rem;
    }

    /* ── Icon Boxes ─────────────────────────────────── */
    .feat-icon {
        width: 50px;
        height: 50px;
        border-radius: 14px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-size: 1.4rem;
        margin-bottom: 0.8rem;
        box-shadow: 0 0 20px rgba(168, 85, 247, 0.25);
    }

    .icon-violet { background: rgba(168, 85, 247, 0.2); color: #C084FC; border: 1px solid rgba(168, 85, 247, 0.4); }
    .icon-blue   { background: rgba(59, 130, 246, 0.2); color: #60A5FA; border: 1px solid rgba(59, 130, 246, 0.4); }
    .icon-cyan   { background: rgba(6, 182, 212, 0.2); color: #22D3EE; border: 1px solid rgba(6, 182, 212, 0.4); }
    .icon-green  { background: rgba(16, 185, 129, 0.2); color: #34D399; border: 1px solid rgba(16, 185, 129, 0.4); }
    .icon-pink   { background: rgba(236, 72, 153, 0.2); color: #F472B6; border: 1px solid rgba(236, 72, 153, 0.4); }
    .icon-amber  { background: rgba(251, 191, 36, 0.2); color: #FBBF24; border: 1px solid rgba(251, 191, 36, 0.4); }

    /* ── Top Progress Banner ─────────────────────────── */
    .top-progress-card {
        position: relative;
        background: linear-gradient(135deg, rgba(30, 41, 59, 0.9) 0%, rgba(124, 58, 237, 0.2) 50%, rgba(15, 23, 42, 0.95) 100%);
        border: 1px solid rgba(168, 85, 247, 0.45);
        border-radius: 20px;
        padding: 1.3rem 1.6rem;
        margin-bottom: 1.3rem;
        box-shadow: 0 15px 40px -10px rgba(124, 58, 237, 0.3), 0 4px 15px rgba(0, 0, 0, 0.4), inset 0 0 25px rgba(168, 85, 247, 0.12);
        backdrop-filter: blur(20px);
        -webkit-backdrop-filter: blur(20px);
        overflow: hidden;
    }
    
    .top-progress-stat {
        font-size: 1.5rem;
        font-weight: 900;
        background: linear-gradient(135deg, #EC4899 0%, #A855F7 50%, #3B82F6 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        line-height: 1.2;
    }
    
    .top-progress-label {
        color: rgba(233, 213, 255, 0.7);
        font-size: 0.76rem;
        text-transform: uppercase;
        letter-spacing: 0.8px;
        font-weight: 800;
        margin-bottom: 4px;
    }

    /* ── Sidebar Glassmorphic Theme & Layout Architecture ── */
    html body div.stApp section[data-testid="stSidebar"]:not([aria-expanded="false"]) {
        display: flex !important;
        visibility: visible !important;
        opacity: 1 !important;
        overflow: visible !important;
        background-color: #0B0715 !important;
        background-image: radial-gradient(ellipse 300px 300px at 50% 10%, rgba(139, 92, 246, 0.15) 0%, transparent 80%) !important;
        border-right: 1px solid rgba(168, 85, 247, 0.25) !important;
        box-shadow: 10px 0 30px rgba(0, 0, 0, 0.5) !important;
    }

    html body div.stApp section[data-testid="stSidebar"][aria-expanded="false"] {
        display: none !important;
        visibility: hidden !important;
        width: 0px !important;
        min-width: 0px !important;
        max-width: 0px !important;
        margin-left: -9999px !important;
        border: none !important;
        box-shadow: none !important;
    }

    section[data-testid="stSidebar"] div.block-container,
    section[data-testid="stSidebar"] [data-testid="stSidebarContent"],
    section[data-testid="stSidebar"] [data-testid="stSidebarUserContent"],
    section[data-testid="stSidebar"] div[data-testid="stVerticalBlock"] {
        padding-top: 0.15rem !important;
        margin-top: 0 !important;
    }

    /* ── Fixed Viewport Sidebar Layout & Bottom Sticky Footer ── */
    html body div.stApp section[data-testid="stSidebar"] [data-testid="stSidebarContent"] {
        padding-top: 1rem !important;
        padding-left: 0.9rem !important;
        padding-right: 0.9rem !important;
        padding-bottom: 0.8rem !important;
        display: flex !important;
        flex-direction: column !important;
        height: 100vh !important;
        max-height: 100vh !important;
        overflow: hidden !important;
        box-sizing: border-box !important;
    }

    html body div.stApp section[data-testid="stSidebar"] [data-testid="stSidebarUserContent"] {
        display: flex !important;
        flex-direction: column !important;
        flex: 1 1 0% !important;
        min-height: 0 !important;
        height: 100% !important;
        overflow: hidden !important;
    }

    html body div.stApp section[data-testid="stSidebar"] [data-testid="stSidebarUserContent"] > div[data-testid="stVerticalBlock"] {
        display: flex !important;
        flex-direction: column !important;
        flex: 1 1 0% !important;
        min-height: 0 !important;
        height: 100% !important;
        gap: 0px !important;
    }

    /* Target middle scrollable container inside sidebar block */
    html body div.stApp section[data-testid="stSidebar"] [data-testid="stSidebarUserContent"] > div[data-testid="stVerticalBlock"] > div:nth-child(2) {
        flex: 1 1 auto !important;
        min-height: 0 !important;
        overflow-y: auto !important;
        overflow-x: hidden !important;
        padding-right: 4px !important;
    }

    /* Scrollbar styling for sidebar scroll area */
    html body div.stApp section[data-testid="stSidebar"] [data-testid="stSidebarUserContent"] > div[data-testid="stVerticalBlock"] > div:nth-child(2)::-webkit-scrollbar {
        width: 4px;
    }
    html body div.stApp section[data-testid="stSidebar"] [data-testid="stSidebarUserContent"] > div[data-testid="stVerticalBlock"] > div:nth-child(2)::-webkit-scrollbar-thumb {
        background: rgba(168, 85, 247, 0.3);
        border-radius: 4px;
    }

    /* Ensure footer containers sit fixed at the very bottom */
    section[data-testid="stSidebar"] div[data-testid="stSidebarUserContent"] > div[data-testid="stVerticalBlock"] > div:has(.sidebar-user-footer-divider),
    section[data-testid="stSidebar"] div[data-testid="stSidebarUserContent"] > div[data-testid="stVerticalBlock"] > div:has(div.sidebar-footer-wrapper) {
        margin-top: auto !important;
        flex-shrink: 0 !important;
    }

    .sidebar-footer-wrapper {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-top: 4px;
        width: 100%;
    }

    .sidebar-user-footer-divider {
        border-top: 1px solid rgba(168, 85, 247, 0.25);
        margin: 14px 0 10px 0;
        box-shadow: 0 -1px 8px rgba(168, 85, 247, 0.2);
    }

    /* Redesigned User Profile Card with App Theme */
    .user-profile-bottom-card {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 8px 12px;
        border-radius: 14px;
        background: linear-gradient(135deg, rgba(30, 20, 50, 0.6) 0%, rgba(124, 58, 237, 0.15) 100%);
        border: 1px solid rgba(168, 85, 247, 0.35);
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3), inset 0 0 12px rgba(168, 85, 247, 0.1);
        backdrop-filter: blur(12px);
        cursor: default;
        transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
        width: 100%;
        box-sizing: border-box;
    }

    .user-profile-bottom-card:hover {
        background: linear-gradient(135deg, rgba(45, 25, 75, 0.75) 0%, rgba(168, 85, 247, 0.28) 100%);
        border-color: #C084FC;
        box-shadow: 0 6px 20px rgba(168, 85, 247, 0.35), inset 0 0 16px rgba(168, 85, 247, 0.2);
        transform: translateY(-1px);
    }

    .user-avatar-pill {
        width: 36px;
        height: 36px;
        border-radius: 50%;
        background: linear-gradient(135deg, #EC4899 0%, #A855F7 50%, #3B82F6 100%);
        border: 1.5px solid rgba(255, 255, 255, 0.3);
        box-shadow: 0 0 12px rgba(168, 85, 247, 0.5);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.1rem;
        flex-shrink: 0;
        color: #FFFFFF;
    }

    .user-info-text {
        overflow: hidden;
        display: flex;
        flex-direction: column;
        justify-content: center;
        flex: 1 1 auto;
        min-width: 0;
    }

    .user-name-title {
        font-size: 0.85rem;
        font-weight: 800;
        color: #FAFAFA;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        line-height: 1.2;
        letter-spacing: 0.2px;
    }

    .user-tier-subtitle {
        font-size: 0.64rem;
        font-weight: 800;
        color: #C084FC;
        letter-spacing: 0.6px;
        line-height: 1.1;
        text-transform: uppercase;
        margin-top: 1px;
    }

    /* Redesigned Circular Settings Icon Button */
    div[class*="st-key-sb_settings_popover_btn"] div[data-testid="stPopover"] button {
        width: 38px !important;
        height: 38px !important;
        min-width: 38px !important;
        max-width: 38px !important;
        min-height: 38px !important;
        max-height: 38px !important;
        border-radius: 50% !important;
        padding: 0 !important;
        margin: 0 !important;
        background: linear-gradient(135deg, rgba(168, 85, 247, 0.25) 0%, rgba(59, 130, 246, 0.2) 100%) !important;
        border: 1.5px solid rgba(168, 85, 247, 0.45) !important;
        color: #E9D5FF !important;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3), 0 0 10px rgba(168, 85, 247, 0.2) !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1) !important;
    }

    div[class*="st-key-sb_settings_popover_btn"] div[data-testid="stPopover"] button:hover {
        background: linear-gradient(135deg, rgba(236, 72, 153, 0.4) 0%, rgba(168, 85, 247, 0.55) 100%) !important;
        border-color: #C084FC !important;
        color: #FFFFFF !important;
        box-shadow: 0 0 18px rgba(168, 85, 247, 0.6) !important;
        transform: rotate(45deg) scale(1.06) !important;
    }

    /* Bold Sidebar Widget Labels */
    section[data-testid="stSidebar"] label[data-testid="stWidgetLabel"] p,
    section[data-testid="stSidebar"] label[data-testid="stWidgetLabel"] div,
    section[data-testid="stSidebar"] label {
        font-weight: 800 !important;
        font-size: 0.95rem !important;
        color: #F3E8FF !important;
        letter-spacing: 0.2px !important;
    }

    /* ── Sidebar Top Header & Collapse Button ── */
    .sidebar-brand-header {
        display: flex !important;
        align-items: center !important;
        justify-content: space-between !important;
        padding: 4px 4px 10px 0 !important;
        margin-top: 0 !important;
        margin-bottom: 8px !important;
        border-top: none !important;
        border-bottom: 1px solid rgba(168, 85, 247, 0.2) !important;
        width: 100% !important;
    }

    .sidebar-brand-top {
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .sidebar-top-collapse-btn {
        background: rgba(255, 255, 255, 0.04);
        border: 1px solid rgba(168, 85, 247, 0.35);
        border-radius: 8px;
        width: 32px;
        height: 32px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        padding: 0;
        color: #E9D5FF;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
    }

    .sidebar-top-collapse-btn:hover {
        background: rgba(168, 85, 247, 0.25);
        border-color: #C084FC;
        box-shadow: 0 0 12px rgba(168, 85, 247, 0.5);
        transform: scale(1.06);
    }

    .neural-icon-wrapper-small {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 28px;
        height: 28px;
        border-radius: 8px;
        background: linear-gradient(135deg, rgba(168, 85, 247, 0.2) 0%, rgba(59, 130, 246, 0.2) 100%);
        border: 1px solid rgba(168, 85, 247, 0.45);
        box-shadow: 0 0 12px rgba(168, 85, 247, 0.3);
        flex-shrink: 0;
    }

    .neural-network-svg {
        overflow: visible;
    }

    .neural-node {
        animation: neuralPulse 2s infinite ease-in-out;
        transform-origin: center;
    }
    .node-1 { animation-delay: 0s; }
    .node-2 { animation-delay: 0.5s; }
    .node-3 { animation-delay: 1.0s; }
    .node-4 { animation-delay: 1.5s; }

    @keyframes neuralPulse {
        0%, 100% {
            transform: scale(1);
            filter: drop-shadow(0 0 2px rgba(168, 85, 247, 0.6));
        }
        50% {
            transform: scale(1.3);
            filter: drop-shadow(0 0 6px rgba(6, 182, 212, 0.9));
        }
    }

    .neural-pulse-line {
        animation: dashMove 3s linear infinite;
    }

    @keyframes dashMove {
        from { stroke-dashoffset: 20; }
        to { stroke-dashoffset: 0; }
    }

    /* ── ChatGPT-Grade "New Learning Journey" Button with White Edit Icon ── */
    div[class*="st-key-sb_new_journey_btn"] button {
        background: linear-gradient(135deg, rgba(236, 72, 153, 0.3) 0%, rgba(168, 85, 247, 0.42) 50%, rgba(59, 130, 246, 0.3) 100%) !important;
        border: 1.5px solid rgba(168, 85, 247, 0.6) !important;
        border-radius: 12px !important;
        color: #FFFFFF !important;
        font-weight: 800 !important;
        font-size: 0.88rem !important;
        letter-spacing: 0.2px !important;
        box-shadow: 0 0 18px rgba(168, 85, 247, 0.35) !important;
        transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1) !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        gap: 8px !important;
        padding: 9px 14px !important;
        margin-top: 30px !important;
        margin-bottom: 14px !important;
        min-height: 44px !important;
    }

    div[class*="st-key-sb_new_journey_btn"] button:hover {
        background: linear-gradient(135deg, rgba(236, 72, 153, 0.5) 0%, rgba(168, 85, 247, 0.62) 50%, rgba(59, 130, 246, 0.5) 100%) !important;
        border-color: #C084FC !important;
        box-shadow: 0 0 26px rgba(168, 85, 247, 0.65), 0 0 10px rgba(6, 182, 212, 0.4) !important;
        transform: translateY(-1px) !important;
        color: #FFFFFF !important;
    }

    div[class*="st-key-sb_new_journey_btn"] button span[data-testid="stIconMaterial"],
    div[class*="st-key-sb_new_journey_btn"] button svg {
        color: #FFFFFF !important;
        fill: #FFFFFF !important;
        font-size: 1.22rem !important;
        filter: drop-shadow(0 0 5px rgba(255, 255, 255, 0.8)) !important;
    }

    /* ── Learning History Header with Icon ── */
    .sidebar-section-title {
        font-size: 0.84rem;
        font-weight: 800;
        color: #FAFAFA;
        display: flex;
        align-items: center;
        gap: 8px;
        margin-top: 10px;
        margin-bottom: 12px;
        letter-spacing: 0.2px;
    }

    .sidebar-section-title svg {
        color: #C084FC;
        stroke: #C084FC;
        flex-shrink: 0;
    }

    /* ── Modern Glassmorphic Search Bar in Sidebar ── */
    div[class*="st-key-sb_hist_search_input"] {
        margin-top: 10px !important;
        margin-bottom: 12px !important;
    }

    div[class*="st-key-sb_hist_search_input"] input {
        background: rgba(255, 255, 255, 0.04) !important;
        border: 1px solid rgba(168, 85, 247, 0.22) !important;
        border-radius: 10px !important;
        color: #F3E8FF !important;
        font-size: 0.82rem !important;
        padding: 7px 12px !important;
        height: 36px !important;
        transition: all 0.2s ease !important;
    }
    div[class*="st-key-sb_hist_search_input"] input:focus {
        background: rgba(255, 255, 255, 0.07) !important;
        border-color: #A855F7 !important;
        box-shadow: 0 0 12px rgba(168, 85, 247, 0.35) !important;
    }

    /* ── Redesigned Modern Filter Pills: All, Active, Completed ── */
    div[data-testid="stSidebar"] div[data-testid="stHorizontalBlock"]:has(div[class*="st-key-sb_flt_"]) {
        margin-top: 6px !important;
        margin-bottom: 12px !important;
    }

    html body div.stApp section[data-testid="stSidebar"] div[class*="st-key-sb_flt_"] button,
    div[class*="st-key-sb_flt_"] button {
        height: 32px !important;
        min-height: 32px !important;
        max-height: 32px !important;
        font-size: 0.76rem !important;
        font-weight: 600 !important;
        border-radius: 20px !important;
        padding: 0 6px !important;
        margin: 0 !important;
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1) !important;
        letter-spacing: 0.1px !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        text-align: center !important;
        box-shadow: none !important;
        white-space: nowrap !important;
        width: 100% !important;
    }

    /* Inactive Filter Pill */
    html body div.stApp section[data-testid="stSidebar"] div[class*="st-key-sb_flt_inactive"] button,
    div[class*="st-key-sb_flt_inactive"] button {
        background: rgba(255, 255, 255, 0.03) !important;
        border: 1px solid rgba(168, 85, 247, 0.18) !important;
        color: rgba(233, 213, 255, 0.65) !important;
        text-align: center !important;
        justify-content: center !important;
    }
    html body div.stApp section[data-testid="stSidebar"] div[class*="st-key-sb_flt_inactive"] button:hover,
    div[class*="st-key-sb_flt_inactive"] button:hover {
        background: rgba(168, 85, 247, 0.14) !important;
        border-color: rgba(168, 85, 247, 0.45) !important;
        color: #F3E8FF !important;
        transform: translateY(-1px) !important;
        box-shadow: 0 2px 8px rgba(168, 85, 247, 0.2) !important;
    }

    /* Active Filter Pill */
    html body div.stApp section[data-testid="stSidebar"] div[class*="st-key-sb_flt_active"] button,
    div[class*="st-key-sb_flt_active"] button {
        background: linear-gradient(135deg, rgba(168, 85, 247, 0.45) 0%, rgba(59, 130, 246, 0.35) 100%) !important;
        border: 1.5px solid #C084FC !important;
        color: #FFFFFF !important;
        font-weight: 700 !important;
        box-shadow: 0 0 14px rgba(168, 85, 247, 0.45), inset 0 1px 1px rgba(255, 255, 255, 0.25) !important;
        text-align: center !important;
        justify-content: center !important;
        margin-bottom: 10px !important;
    }
    html body div.stApp section[data-testid="stSidebar"] div[class*="st-key-sb_flt_active"] button:hover,
    div[class*="st-key-sb_flt_active"] button:hover {
        background: linear-gradient(135deg, rgba(168, 85, 247, 0.55) 0%, rgba(59, 130, 246, 0.45) 100%) !important;
        border-color: #E9D5FF !important;
        box-shadow: 0 0 20px rgba(168, 85, 247, 0.65), inset 0 1px 1px rgba(255, 255, 255, 0.35) !important;
    }

    /* ── Learning History Header: Single Unified Inline Flex Title & Chevron Arrow ── */
    .sidebar-section-title.clickable-hist-header {
        display: inline-flex !important;
        align-items: center !important;
        justify-content: flex-start !important;
        gap: 6px !important;
        margin: 10px 0 12px 0 !important;
        cursor: pointer !important;
        user-select: none !important;
        -webkit-user-select: none !important;
        padding: 3px 6px 3px 2px !important;
        border-radius: 6px !important;
        transition: background 0.15s ease !important;
        width: fit-content !important;
    }

    .sidebar-section-title.clickable-hist-header:hover {
        background: rgba(168, 85, 247, 0.14) !important;
    }

    .sidebar-section-title.clickable-hist-header .hist-chevron-arrow {
        margin-left: 2px !important;
        display: inline-flex !important;
        align-items: center !important;
        justify-content: center !important;
        transition: stroke 0.15s ease, transform 0.15s ease !important;
        stroke: #C084FC !important;
        vertical-align: middle !important;
    }

    .sidebar-section-title.clickable-hist-header:hover .hist-chevron-arrow {
        stroke: #FFFFFF !important;
    }

    div[class*="st-key-sb_hist_hidden_toggle_btn"] {
        display: none !important;
        position: absolute !important;
        opacity: 0 !important;
        pointer-events: none !important;
        height: 0 !important;
        width: 0 !important;
        margin: 0 !important;
        padding: 0 !important;
        overflow: hidden !important;
    }

    /* ── Learning History Dedicated Container Gap Removal ── */
    section[data-testid="stSidebar"] div[data-testid="stVerticalBlock"]:has(.sb-hist-container-marker),
    section[data-testid="stSidebar"] div[data-testid="stVerticalBlockBorderWrapper"]:has(.sb-hist-container-marker) {
        gap: 0px !important;
        row-gap: 0px !important;
    }

    section[data-testid="stSidebar"] div[data-testid="stVerticalBlock"]:has(> div[data-testid="stHorizontalBlock"]:has(div[class*="st-key-sb_card_"])) {
        gap: 0px !important;
        row-gap: 10px !important;
    }

    /* Fallback direct sibling selector for cards */
    section[data-testid="stSidebar"] div[data-testid="stHorizontalBlock"]:has(div[class*="st-key-sb_card_"]) {
        margin: 0px 0 !important;
        padding: 0px 4px 0px 6px !important;
        gap: 0px !important;
        border-radius: 8px !important;
        border: none !important;
        box-shadow: none !important;
        background: transparent !important;
        transition: background 0.12s cubic-bezier(0.4, 0, 0.2, 1) !important;
        display: flex !important;
        align-items: center !important;
        justify-content: space-between !important;
        width: 100% !important;
        box-sizing: border-box !important;
    }

    /* Entire row uniform highlight on hover */
    section[data-testid="stSidebar"] div[data-testid="stHorizontalBlock"]:has(div[class*="st-key-sb_card_"]):hover {
        background: rgba(255, 255, 255, 0.08) !important;
    }

    /* Active session row highlight */
    section[data-testid="stSidebar"] div[data-testid="stHorizontalBlock"]:has(div[class*="st-key-sb_card_"] button[kind="primary"]) {
        background: rgba(168, 85, 247, 0.16) !important;
    }

    /* First Column: 0 Margin & 0 Padding so Text Starts from Very Left */
    html body div.stApp section[data-testid="stSidebar"] div[data-testid="stHorizontalBlock"]:has(div[class*="st-key-sb_card_"]) > div[data-testid="stColumn"]:first-child,
    section[data-testid="stSidebar"] div[data-testid="stHorizontalBlock"]:has(div[class*="st-key-sb_card_"]) > div[data-testid="stColumn"]:first-child {
        margin: 0 !important;
        padding: 0 !important;
        flex: 1 1 auto !important;
        min-width: 0 !important;
        width: calc(100% - 30px) !important;
        overflow: hidden !important;
        display: flex !important;
        align-items: center !important;
        gap: 0px !important;
    }

    html body div.stApp section[data-testid="stSidebar"] div[class*="st-key-sb_card_"],
    section[data-testid="stSidebar"] div[class*="st-key-sb_card_"] {
        flex: 1 1 auto !important;
        width: 100% !important;
        min-width: 0 !important;
        margin: 0 !important;
        padding: 0 !important;
        overflow: hidden !important;
        display: block !important;
        text-align: left !important;
    
    }

    html body div.stApp section[data-testid="stSidebar"] div[class*="st-key-sb_card_"] button,
    section[data-testid="stSidebar"] div[class*="st-key-sb_card_"] button {
        text-align: left !important;
        -webkit-box-pack: start !important;
        justify-content: flex-start !important;
        -webkit-box-align: center !important;
        align-items: center !important;
        background: transparent !important;
        border: none !important;
        box-shadow: none !important;
        border-radius: 6px !important;
        padding: 6px 0px 6px 2px !important;
        margin: 0 !important;
        font-size: 0.82rem !important;
        font-weight: 500 !important;
        color: #E2E8F0 !important;
        line-height: 1.3 !important;
        min-height: 34px !important;
        height: 34px !important;
        white-space: nowrap !important;
        overflow: hidden !important;
        text-overflow: ellipsis !important;
        transition: color 0.12s ease !important;
        width: 100% !important;
        display: flex !important;
    }

    html body div.stApp section[data-testid="stSidebar"] div[class*="st-key-sb_card_"] button > div,
    html body div.stApp section[data-testid="stSidebar"] div[class*="st-key-sb_card_"] button > div:first-child,
    html body div.stApp section[data-testid="stSidebar"] div[class*="st-key-sb_card_"] button div[data-testid="stMarkdownContainer"],
    html body div.stApp section[data-testid="stSidebar"] div[class*="st-key-sb_card_"] button div p,
    html body div.stApp section[data-testid="stSidebar"] div[class*="st-key-sb_card_"] button p,
    html body div.stApp section[data-testid="stSidebar"] div[class*="st-key-sb_card_"] button span {
        text-align: left !important;
        -webkit-box-pack: start !important;
        justify-content: flex-start !important;
        align-items: flex-start !important;
        align-self: flex-start !important;
        white-space: nowrap !important;
        overflow: hidden !important;
        text-overflow: ellipsis !important;
        margin: 0 !important;
        padding: 0 !important;
        width: 100% !important;
        max-width: 100% !important;
        display: block !important;
    }

    html body div.stApp section[data-testid="stSidebar"] div[class*="st-key-sb_card_"] button:hover,
    section[data-testid="stSidebar"] div[class*="st-key-sb_card_"] button:hover {
        background: transparent !important;
        color: #FFFFFF !important;
        border: none !important;
        box-shadow: none !important;
        transform: none !important;
    }

    html body div.stApp section[data-testid="stSidebar"] div[class*="st-key-sb_card_"] button[kind="primary"],
    section[data-testid="stSidebar"] div[class*="st-key-sb_card_"] button[kind="primary"] {
        color: #FFFFFF !important;
        font-weight: 600 !important;
        background: transparent !important;
        border: none !important;
        box-shadow: none !important;
    }

    /* Second Column: Pinned to Most Right with Aligned 3-Dots Button */
    section[data-testid="stSidebar"] div[data-testid="stHorizontalBlock"]:has(div[class*="st-key-sb_card_"]) > div[data-testid="stColumn"]:last-child {
        margin: 0 0 0 auto !important;
        padding: 0 !important;
        flex: 0 0 28px !important;
        width: 28px !important;
        min-width: 28px !important;
        max-width: 28px !important;
        display: flex !important;
        align-items: center !important;
        justify-content: flex-end !important;
    }

    section[data-testid="stSidebar"] div[data-testid="stHorizontalBlock"]:has(div[class*="st-key-sb_card_"]) div[data-testid="stPopover"] {
        margin: 0 !important;
        padding: 0 !important;
        width: 28px !important;
        display: flex !important;
        justify-content: flex-end !important;
        align-items: center !important;
    }

    section[data-testid="stSidebar"] div[data-testid="stHorizontalBlock"]:has(div[class*="st-key-sb_card_"]) div[data-testid="stPopover"] button {
        opacity: 0 !important;
        visibility: hidden !important;
        border-radius: 6px !important;
        min-height: 26px !important;
        height: 26px !important;
        width: 26px !important;
        min-width: 26px !important;
        max-width: 26px !important;
        padding: 0 !important;
        margin: 0 !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        background: transparent !important;
        border: none !important;
        box-shadow: none !important;
        color: rgba(233, 213, 255, 0.7) !important;
        transition: opacity 0.12s ease, visibility 0.12s ease, background 0.12s ease, color 0.12s ease !important;
    }

    section[data-testid="stSidebar"] div[data-testid="stHorizontalBlock"]:has(div[class*="st-key-sb_card_"]):hover div[data-testid="stPopover"] button,
    section[data-testid="stSidebar"] div[data-testid="stHorizontalBlock"]:has(div[class*="st-key-sb_card_"]) div[data-testid="stPopover"]:focus-within button,
    section[data-testid="stSidebar"] div[data-testid="stHorizontalBlock"]:has(div[class*="st-key-sb_card_"]) div[data-testid="stPopover"] button[aria-expanded="true"] {
        opacity: 1 !important;
        visibility: visible !important;
    }

    section[data-testid="stSidebar"] div[data-testid="stHorizontalBlock"]:has(div[class*="st-key-sb_card_"]) div[data-testid="stPopover"] button:hover {
        background: rgba(255, 255, 255, 0.15) !important;
        color: #FFFFFF !important;
    }

    /* ── Streamlit Segmented Control Glassy Theme ── */
    div[data-testid="stSegmentedControl"] {
        background: rgba(15, 10, 26, 0.8) !important;
        border: 1px solid rgba(168, 85, 247, 0.3) !important;
        border-radius: 12px !important;
        padding: 2px !important;
        width: 100% !important;
    }

    div[data-testid="stSegmentedControl"] button {
        border-radius: 8px !important;
        font-weight: 700 !important;
        font-size: 0.76rem !important;
        padding: 4px 8px !important;
        transition: all 0.2s ease !important;
    }

    /* ── Progressive 20-Item "Load More" Button ── */
    div[class*="st-key-sb_load_more_btn"] button {
        background: rgba(168, 85, 247, 0.1) !important;
        border: 1px dashed rgba(168, 85, 247, 0.4) !important;
        border-radius: 10px !important;
        color: #E9D5FF !important;
        font-size: 0.78rem !important;
        font-weight: 700 !important;
        padding: 6px 12px !important;
        margin-top: 6px !important;
        transition: all 0.2s ease !important;
    }

    div[class*="st-key-sb_load_more_btn"] button:hover {
        background: rgba(168, 85, 247, 0.25) !important;
        border-color: #C084FC !important;
        color: #FFFFFF !important;
        box-shadow: 0 0 14px rgba(168, 85, 247, 0.35) !important;
    }

    /* ── Sidebar Bottom Footer: User Profile & Settings ── */
    section[data-testid="stSidebar"] div[data-testid="stSidebarUserContent"] > div[data-testid="stVerticalBlock"] > div:has(.sidebar-user-footer-divider),
    section[data-testid="stSidebar"] div[data-testid="stSidebarUserContent"] > div[data-testid="stVerticalBlock"] > div:has(> div[data-testid="stHorizontalBlock"]:has(div.user-profile-bottom-card)) {
        margin-top: auto !important;
    }

    .sidebar-user-footer-divider {
        border-top: 1px solid rgba(168, 85, 247, 0.22);
        margin: 14px 0 10px 0;
    }

    .user-profile-bottom-card {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 5px 8px;
        border-radius: 10px;
        background: rgba(255, 255, 255, 0.03);
        border: 1px solid rgba(168, 85, 247, 0.25);
        cursor: default;
        transition: all 0.2s ease;
    }

    .user-profile-bottom-card:hover {
        background: rgba(168, 85, 247, 0.12);
        border-color: rgba(168, 85, 247, 0.45);
    }

    .user-avatar-pill {
        width: 32px;
        height: 32px;
        border-radius: 50%;
        background: linear-gradient(135deg, rgba(168, 85, 247, 0.35) 0%, rgba(59, 130, 246, 0.35) 100%);
        border: 1px solid rgba(168, 85, 247, 0.5);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.05rem;
        flex-shrink: 0;
    }

    .user-info-text {
        overflow: hidden;
        display: flex;
        flex-direction: column;
        justify-content: center;
    }

    .user-name-title {
        font-size: 0.82rem;
        font-weight: 800;
        color: #FAFAFA;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        line-height: 1.2;
    }

    .user-tier-subtitle {
        font-size: 0.65rem;
        font-weight: 800;
        color: #C084FC;
        letter-spacing: 0.5px;
        line-height: 1.1;
    }

    div[class*="st-key-sb_pop_logout_btn"] button {
        background: linear-gradient(135deg, #EC4899 0%, #A855F7 50%, #3B82F6 100%) !important;
        border: none !important;
        border-radius: 10px !important;
        color: #FFFFFF !important;
        font-weight: 800 !important;
        font-size: 0.88rem !important;
        padding: 8px 12px !important;
        box-shadow: 0 0 16px rgba(236, 72, 153, 0.4) !important;
        transition: all 0.2s ease !important;
    }

    div[class*="st-key-sb_pop_logout_btn"] button:hover {
        box-shadow: 0 0 24px rgba(236, 72, 153, 0.7) !important;
        transform: translateY(-1px) !important;
    }

    .user-profile-sidebar-card {
        background: linear-gradient(135deg, rgba(30, 41, 59, 0.85) 0%, rgba(124, 58, 237, 0.2) 100%);
        border: 1px solid rgba(168, 85, 247, 0.4);
        border-radius: 14px;
        padding: 12px 14px;
        margin-bottom: 12px;
        box-shadow: 0 8px 20px rgba(0, 0, 0, 0.3), inset 0 0 15px rgba(168, 85, 247, 0.1);
        backdrop-filter: blur(16px);
    }

    .tier-pill {
        background: linear-gradient(135deg, rgba(168, 85, 247, 0.25) 0%, rgba(236, 72, 153, 0.25) 100%);
        color: #F3E8FF;
        border: 1px solid rgba(168, 85, 247, 0.5);
        font-size: 0.72rem;
        font-weight: 800;
        padding: 3px 10px;
        border-radius: 20px;
        text-transform: uppercase;
        letter-spacing: 0.6px;
        box-shadow: 0 0 10px rgba(168, 85, 247, 0.25);
    }

    /* ── Collapsed Mini Icon Rail ── */
    #edutech-collapsed-mini-rail {
        position: fixed;
        top: 0;
        left: 0;
        bottom: 0;
        width: 54px;
        background: #0B0715;
        border-right: 1px solid rgba(168, 85, 247, 0.25);
        box-shadow: 4px 0 20px rgba(0, 0, 0, 0.4);
        z-index: 999999;
        display: none;
        flex-direction: column;
        align-items: center;
        padding: 14px 0;
        gap: 12px;
        user-select: none;
        -webkit-user-select: none;
    }

    .mr-item {
        width: 38px;
        height: 38px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        background: rgba(255, 255, 255, 0.04);
        border: 1px solid rgba(168, 85, 247, 0.3);
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        color: #E9D5FF;
    }

    .mr-item:hover {
        background: rgba(168, 85, 247, 0.3);
        border-color: #C084FC;
        box-shadow: 0 0 14px rgba(168, 85, 247, 0.6);
        transform: scale(1.08);
    }

    .mr-item.mr-new-journey {
        background: linear-gradient(135deg, rgba(236, 72, 153, 0.4) 0%, rgba(168, 85, 247, 0.5) 100%);
        border-color: rgba(168, 85, 247, 0.7);
        box-shadow: 0 0 12px rgba(168, 85, 247, 0.4);
    }

    /* ── Pill Capsules System ────────────────────────── */
    .pill-capsule {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 6px 16px;
        border-radius: 9999px;
        font-size: 0.84rem;
        font-weight: 600;
        letter-spacing: 0.4px;
        backdrop-filter: blur(16px);
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
        transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
        white-space: nowrap;
        user-select: none;
    }
    
    .pill-capsule:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(0, 0, 0, 0.45);
    }

    .pill-icon-box {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 22px;
        height: 22px;
        border-radius: 50%;
        font-size: 0.85rem;
        background: rgba(255, 255, 255, 0.15);
    }
    
    .pill-mode {
        background: linear-gradient(135deg, rgba(168, 85, 247, 0.25) 0%, rgba(124, 58, 237, 0.3) 100%);
        border: 1px solid rgba(192, 132, 252, 0.6);
        color: #F3E8FF;
        box-shadow: 0 0 15px rgba(168, 85, 247, 0.25);
    }
    .pill-mode .pill-label {
        color: #D8B4FE;
        font-weight: 700;
        text-transform: uppercase;
        font-size: 0.72rem;
        letter-spacing: 0.6px;
    }
    .pill-mode .pill-value {
        color: #FFFFFF;
        font-weight: 800;
    }
    
    .pill-audience {
        background: linear-gradient(135deg, rgba(59, 130, 246, 0.25) 0%, rgba(37, 99, 235, 0.3) 100%);
        border: 1px solid rgba(96, 165, 250, 0.6);
        color: #EFF6FF;
        box-shadow: 0 0 15px rgba(59, 130, 246, 0.25);
    }
    .pill-audience .pill-label {
        color: #93C5FD;
        font-weight: 700;
        text-transform: uppercase;
        font-size: 0.72rem;
        letter-spacing: 0.6px;
    }
    .pill-audience .pill-value {
        color: #FFFFFF;
        font-weight: 800;
    }

    .pill-status-complete {
        background: linear-gradient(135deg, rgba(16, 185, 129, 0.25) 0%, rgba(5, 150, 105, 0.3) 100%);
        border: 1px solid rgba(52, 211, 153, 0.6);
        color: #ECFDF5;
        box-shadow: 0 0 15px rgba(16, 185, 129, 0.25);
    }
    .pill-status-complete .pill-label {
        color: #6EE7B7;
        font-weight: 700;
        text-transform: uppercase;
        font-size: 0.72rem;
        letter-spacing: 0.6px;
    }
    .pill-status-complete .pill-value { color: #FFFFFF; font-weight: 800; }

    .pill-status-inprogress {
        background: linear-gradient(135deg, rgba(14, 165, 233, 0.25) 0%, rgba(2, 132, 199, 0.3) 100%);
        border: 1px solid rgba(56, 189, 248, 0.6);
        color: #F0F9FF;
        box-shadow: 0 0 15px rgba(14, 165, 233, 0.25);
    }
    .pill-status-inprogress .pill-label {
        color: #7DD3FC;
        font-weight: 700;
        text-transform: uppercase;
        font-size: 0.72rem;
        letter-spacing: 0.6px;
    }
    .pill-status-inprogress .pill-value { color: #FFFFFF; font-weight: 800; }

    .pill-status-pending {
        background: linear-gradient(135deg, rgba(100, 116, 139, 0.22) 0%, rgba(71, 85, 105, 0.26) 100%);
        border: 1px solid rgba(148, 163, 184, 0.45);
        color: #F1F5F9;
    }
    .pill-status-pending .pill-label {
        color: #CBD5E1;
        font-weight: 700;
        text-transform: uppercase;
        font-size: 0.72rem;
        letter-spacing: 0.6px;
    }
    .pill-status-pending .pill-value { color: #E2E8F0; font-weight: 800; }

    .prereq-badge {
        background: rgba(251, 191, 36, 0.15);
        color: #FBBF24;
        border: 1px solid rgba(251, 191, 36, 0.45);
        font-size: 0.72rem;
        font-weight: 800;
        padding: 3px 10px;
        border-radius: 20px;
        text-transform: uppercase;
        letter-spacing: 0.6px;
        display: inline-flex;
        align-items: center;
        height: 24px;
        box-sizing: border-box;
        vertical-align: middle;
    }

    .milestone-badge {
        background: rgba(99, 102, 241, 0.18);
        color: #818CF8;
        border: 1px solid rgba(99, 102, 241, 0.45);
        font-size: 0.72rem;
        font-weight: 800;
        padding: 3px 10px;
        border-radius: 20px;
        text-transform: uppercase;
        letter-spacing: 0.6px;
        display: inline-flex;
        align-items: center;
        height: 24px;
        box-sizing: border-box;
        vertical-align: middle;
    }

    .compact-status-pill {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 5px;
        font-size: 0.72rem;
        font-weight: 800;
        padding: 3px 10px;
        border-radius: 20px;
        text-transform: uppercase;
        letter-spacing: 0.6px;
        white-space: nowrap;
        height: 24px;
        min-height: 24px;
        box-sizing: border-box;
        vertical-align: middle;
    }
    .compact-status-inprogress {
        background: rgba(14, 165, 233, 0.2);
        color: #38BDF8;
        border: 1px solid rgba(56, 189, 248, 0.5);
    }
    .compact-status-complete {
        background: rgba(16, 185, 129, 0.2);
        color: #34D399;
        border: 1px solid rgba(52, 211, 153, 0.5);
    }
    .compact-status-pending {
        background: rgba(100, 116, 139, 0.2);
        color: #94A3B8;
        border: 1px solid rgba(148, 163, 184, 0.45);
    }

    /* ── Streamlit Button Overrides (Theme Matched) ───── */
    .stApp button[kind="primary"], div[data-testid="stButton"] button[kind="primary"] {
        background: linear-gradient(135deg, #EC4899 0%, #A855F7 50%, #3B82F6 100%) !important;
        border: none !important;
        border-radius: 24px !important;
        color: #FFFFFF !important;
        font-weight: 800 !important;
        box-shadow: 0 0 20px rgba(236, 72, 153, 0.35) !important;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1) !important;
    }

    .stApp button[kind="primary"]:hover, div[data-testid="stButton"] button[kind="primary"]:hover {
        box-shadow: 0 0 30px rgba(236, 72, 153, 0.6), 0 0 15px rgba(6, 182, 212, 0.4) !important;
        transform: translateY(-2px) !important;
    }

    .stApp button[kind="secondary"], div[data-testid="stButton"] button[kind="secondary"] {
        background: rgba(30, 41, 59, 0.6) !important;
        border: 1px solid rgba(168, 85, 247, 0.35) !important;
        border-radius: 20px !important;
        color: #FAFAFA !important;
        font-weight: 700 !important;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2) !important;
        transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1) !important;
    }

    .stApp button[kind="secondary"]:hover, div[data-testid="stButton"] button[kind="secondary"]:hover {
        background: rgba(168, 85, 247, 0.25) !important;
        border-color: rgba(168, 85, 247, 0.7) !important;
        box-shadow: 0 0 20px rgba(168, 85, 247, 0.35) !important;
        transform: translateY(-2px) !important;
    }

    /* ── Precise In-Line Alignment for Milestone Meta Row & Regenerate Pill ── */
    div[data-testid="stColumn"]:has(.milestone-badge-row),
    div[data-testid="column"]:has(.milestone-badge-row),
    div[data-testid="stColumn"]:has(div[class*="st-key-regen_btn_"]),
    div[data-testid="column"]:has(div[class*="st-key-regen_btn_"]) {
        display: flex !important;
        flex-direction: column !important;
        justify-content: center !important;
        min-height: 28px !important;
        margin-top: 0 !important;
        margin-bottom: 0 !important;
    }

    div[data-testid="stColumn"]:has(.milestone-badge-row) div[data-testid="stElementContainer"],
    div[data-testid="column"]:has(.milestone-badge-row) div[data-testid="stElementContainer"] {
        margin: 0 !important;
        padding: 0 !important;
        display: flex !important;
        align-items: center !important;
        height: 26px !important;
    }

    div[data-testid="stColumn"]:has(.milestone-badge-row) div[data-testid="stMarkdownContainer"] p,
    div[data-testid="column"]:has(.milestone-badge-row) div[data-testid="stMarkdownContainer"] p {
        margin: 0 !important;
        padding: 0 !important;
        display: flex !important;
        align-items: center !important;
        gap: 8px !important;
        height: 26px !important;
    }

    div[data-testid="stColumn"]:has(div[class*="st-key-regen_btn_"]),
    div[data-testid="column"]:has(div[class*="st-key-regen_btn_"]) {
        align-items: flex-end !important;
        justify-content: center !important;
        text-align: right !important;
    }

    div[data-testid="stColumn"]:has(div[class*="st-key-regen_btn_"]) div[data-testid="stVerticalBlock"],
    div[data-testid="column"]:has(div[class*="st-key-regen_btn_"]) div[data-testid="stVerticalBlock"],
    div[data-testid="stColumn"]:has(div[class*="st-key-regen_btn_"]) div[data-testid="stElementContainer"],
    div[data-testid="column"]:has(div[class*="st-key-regen_btn_"]) div[data-testid="stElementContainer"],
    div[class*="st-key-regen_btn_"] {
        display: flex !important;
        justify-content: flex-end !important;
        align-items: center !important;
        width: 100% !important;
        margin: 0 !important;
        padding: 0 !important;
        height: 26px !important;
    }

    div[class*="st-key-regen_btn_"] button {
        margin-left: auto !important;
        margin-right: 0 !important;
        background: linear-gradient(135deg, #EC4899 0%, #A855F7 50%, #3B82F6 100%) !important;
        border: none !important;
        border-radius: 20px !important;
        color: #FFFFFF !important;
        font-size: 0.72rem !important;
        font-weight: 800 !important;
        letter-spacing: 0.6px !important;
        text-transform: uppercase !important;
        padding: 4px 14px !important;
        height: 26px !important;
        min-height: 26px !important;
        line-height: 1.1 !important;
        box-shadow: 0 0 12px rgba(236, 72, 153, 0.35) !important;
        transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1) !important;
        display: inline-flex !important;
        align-items: center !important;
        justify-content: center !important;
        gap: 5px !important;
        cursor: pointer !important;
        white-space: nowrap !important;
        vertical-align: middle !important;
        overflow: visible !important;
    }

    div[class*="st-key-regen_btn_"] button div[data-testid="stMarkdownContainer"],
    div[class*="st-key-regen_btn_"] button div[data-testid="stMarkdownContainer"] p {
        font-size: 0.72rem !important;
        font-weight: 800 !important;
        line-height: 1.1 !important;
        margin: 0 !important;
        padding: 0 !important;
        text-transform: uppercase !important;
        letter-spacing: 0.6px !important;
        white-space: nowrap !important;
        overflow: visible !important;
        color: #FFFFFF !important;
    }

    div[class*="st-key-regen_btn_"] button:hover {
        background: linear-gradient(135deg, #F43F5E 0%, #9333EA 50%, #2563EB 100%) !important;
        box-shadow: 0 0 18px rgba(236, 72, 153, 0.6) !important;
        transform: translateY(-1px) !important;
    }

    div[class*="st-key-regen_btn_"] [data-testid="stIconMaterial"] {
        color: #FFFFFF !important;
        font-size: 1.15rem !important;
        filter: drop-shadow(0 0 6px rgba(255, 255, 255, 0.9)) !important;
        transition: transform 0.5s cubic-bezier(0.34, 1.56, 0.64, 1), filter 0.3s ease !important;
    }

    div[class*="st-key-regen_btn_"] button:hover [data-testid="stIconMaterial"] {
        transform: rotate(180deg) scale(1.2) !important;
        filter: drop-shadow(0 0 10px rgba(6, 182, 212, 1)) !important;
    }

    /* ── Socratic Tutor Clean Input Row (No Outer Border) ── */
    div[data-testid="stForm"]:has(div[class*="st-key-chat_in_"]),
    form[data-testid="stForm"]:has(div[class*="st-key-chat_in_"]) {
        background: transparent !important;
        border: none !important;
        box-shadow: none !important;
        padding: 0 !important;
        margin-top: 10px !important;
        margin-bottom: 8px !important;
        backdrop-filter: none !important;
        -webkit-backdrop-filter: none !important;
        width: 100% !important;
    }

    div[data-testid="stForm"]:has(div[class*="st-key-chat_in_"]) div[data-testid="stHorizontalBlock"] {
        align-items: center !important;
        gap: 10px !important;
        width: 100% !important;
    }

    /* Style the primary Ask Tutor, Submit Quiz & Sign Out buttons inside forms/popovers */
    div[data-testid="stForm"]:has(div[class*="st-key-chat_in_"]) div[data-testid="stFormSubmitButton"],
    div[data-testid="stForm"]:has(div[class*="st-key-chat_in_"]) div[data-testid="stFormSubmitButton"] div,
    div[data-testid="stForm"]:has(div[class*="st-key-chat_in_"]) div[data-testid="stFormSubmitButton"] button {
        width: 100% !important;
    }

    div[data-testid="stForm"]:has(div[class*="st-key-chat_in_"]) div[data-testid="stFormSubmitButton"] button,
    div[data-testid="stForm"]:has(div[class*="st-key-q_"]) div[data-testid="stFormSubmitButton"] button,
    div[data-testid="stForm"] div[data-testid="stFormSubmitButton"] button[kind="primary"],
    div[class*="st-key-nav_logout_btn"] button {
        width: 100% !important;
        max-width: 100% !important;
        min-width: 0 !important;
        min-height: 44px !important;
        height: auto !important;
        border-radius: 12px !important;
        background: linear-gradient(135deg, #EC4899 0%, #A855F7 50%, #3B82F6 100%) !important;
        border: none !important;
        color: #FFFFFF !important;
        font-weight: 800 !important;
        font-size: 0.92rem !important;
        letter-spacing: 0.2px !important;
        padding: 8px 12px !important;
        margin: 0 !important;
        box-shadow: 0 0 18px rgba(236, 72, 153, 0.4) !important;
        transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1) !important;
        display: inline-flex !important;
        align-items: center !important;
        justify-content: center !important;
        text-align: center !important;
        gap: 6px !important;
        cursor: pointer !important;
        white-space: normal !important;
        word-break: normal !important;
        overflow-wrap: break-word !important;
        line-height: 1.25 !important;
    }

    div[data-testid="stForm"]:has(div[class*="st-key-chat_in_"]) div[data-testid="stFormSubmitButton"] button *,
    div[data-testid="stForm"]:has(div[class*="st-key-chat_in_"]) div[data-testid="stFormSubmitButton"] button p,
    div[data-testid="stForm"]:has(div[class*="st-key-chat_in_"]) div[data-testid="stFormSubmitButton"] button span,
    div[data-testid="stForm"]:has(div[class*="st-key-chat_in_"]) div[data-testid="stFormSubmitButton"] button div {
        white-space: normal !important;
        word-break: normal !important;
        overflow-wrap: break-word !important;
        text-align: center !important;
        line-height: 1.25 !important;
        display: inline !important;
    }

    div[data-testid="stForm"]:has(div[class*="st-key-chat_in_"]) div[data-testid="stFormSubmitButton"] button:hover,
    div[data-testid="stForm"]:has(div[class*="st-key-q_"]) div[data-testid="stFormSubmitButton"] button:hover,
    div[data-testid="stForm"] div[data-testid="stFormSubmitButton"] button[kind="primary"]:hover,
    div[class*="st-key-nav_logout_btn"] button:hover {
        background: linear-gradient(135deg, #F43F5E 0%, #9333EA 50%, #2563EB 100%) !important;
        box-shadow: 0 0 28px rgba(236, 72, 153, 0.65), 0 0 15px rgba(6, 182, 212, 0.4) !important;
        transform: translateY(-2px) !important;
    }

    /* Mobile & Tablet Responsive Layout for Tutor Chat & Suggested Questions */
    @media (max-width: 768px) {
        div[data-testid="stForm"]:has(div[class*="st-key-chat_in_"]) div[data-testid="stHorizontalBlock"] {
            flex-direction: column !important;
            align-items: stretch !important;
            gap: 10px !important;
        }

        div[data-testid="stForm"]:has(div[class*="st-key-chat_in_"]) div[data-testid="stHorizontalBlock"] > div[data-testid="stColumn"],
        div[data-testid="stForm"]:has(div[class*="st-key-chat_in_"]) div[data-testid="stHorizontalBlock"] > div[data-testid="column"] {
            width: 100% !important;
            flex: 1 1 100% !important;
            min-width: 100% !important;
        }

        div[data-testid="stForm"]:has(div[class*="st-key-chat_in_"]) div[data-testid="stFormSubmitButton"] button {
            width: 100% !important;
            min-height: 44px !important;
            height: auto !important;
            font-size: 0.9rem !important;
            padding: 8px 12px !important;
        }

        div[data-testid="stHorizontalBlock"]:has(button[key*="sug_q_"]) {
            flex-direction: column !important;
            gap: 8px !important;
        }

        div[data-testid="stHorizontalBlock"]:has(button[key*="sug_q_"]) > div[data-testid="stColumn"],
        div[data-testid="stHorizontalBlock"]:has(button[key*="sug_q_"]) > div[data-testid="column"] {
            width: 100% !important;
            flex: 1 1 100% !important;
        }
    }

    /* ── Streamlit Expanders (Frosted Glass Theme) ────── */
    div[data-testid="stExpander"] {
        background: linear-gradient(135deg, rgba(30, 41, 59, 0.7) 0%, rgba(15, 23, 42, 0.8) 100%) !important;
        backdrop-filter: blur(20px) !important;
        -webkit-backdrop-filter: blur(20px) !important;
        border: 1px solid rgba(168, 85, 247, 0.4) !important;
        border-radius: 18px !important;
        margin-bottom: 1.2rem !important;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.35), inset 0 0 20px rgba(168, 85, 247, 0.08) !important;
        overflow: hidden !important;
    }

    div[data-testid="stExpander"] summary {
        background: rgba(20, 13, 33, 0.8) !important;
        border-bottom: 1px solid rgba(168, 85, 247, 0.25) !important;
        padding: 0.9rem 1.2rem !important;
        font-weight: 800 !important;
        color: #FAFAFA !important;
        transition: background 0.2s ease !important;
    }

    div[data-testid="stExpander"] summary:hover {
        background: rgba(168, 85, 247, 0.15) !important;
    }

    div[data-testid="stExpander"] div[data-testid="stExpanderDetails"] {
        padding: 1.2rem !important;
    }

    /* ── Streamlit Dialog / Modal Glowing Sparkling Theme ── */
    div[data-testid="stModalContainer"],
    div[data-testid="stDialog"] {
        z-index: 9999999 !important;
    }

    div[data-testid="stModal"],
    div[role="dialog"] {
        z-index: 9999999 !important;
        background: linear-gradient(135deg, rgba(20, 12, 35, 0.98) 0%, rgba(35, 18, 55, 0.98) 100%) !important;
        border: 2px solid rgba(245, 158, 11, 0.6) !important;
        border-radius: 24px !important;
        box-shadow: 0 0 50px rgba(245, 158, 11, 0.4), 0 0 90px rgba(236, 72, 153, 0.35), 0 20px 60px rgba(0, 0, 0, 0.8) !important;
        backdrop-filter: blur(25px) !important;
        -webkit-backdrop-filter: blur(25px) !important;
    }

    div[role="dialog"] header {
        background: transparent !important;
    }

    div.sparkling-modal-card {
        text-align: center !important;
        padding: 10px 4px !important;
    }

    div.glowing-trophy-box {
        width: 84px !important;
        height: 84px !important;
        margin: 0 auto 16px auto !important;
        background: linear-gradient(135deg, #F59E0B 0%, #EC4899 50%, #A855F7 100%) !important;
        border-radius: 50% !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        box-shadow: 0 0 35px rgba(245, 158, 11, 0.7), 0 0 20px rgba(236, 72, 153, 0.5) !important;
        animation: trophySparkle 2s infinite ease-in-out !important;
    }

    @keyframes trophySparkle {
        0%, 100% { transform: scale(1) rotate(0deg); box-shadow: 0 0 30px rgba(245, 158, 11, 0.7); }
        50% { transform: scale(1.1) rotate(4deg); box-shadow: 0 0 55px rgba(236, 72, 153, 0.9), 0 0 30px rgba(59, 130, 246, 0.6); }
    }

    span.trophy-emoji {
        font-size: 3rem !important;
        filter: drop-shadow(0 4px 10px rgba(0,0,0,0.5)) !important;
    }

    h2.sparkle-title {
        font-size: 2rem !important;
        font-weight: 900 !important;
        background: linear-gradient(135deg, #FBBF24 0%, #F43F5E 50%, #C084FC 100%) !important;
        -webkit-background-clip: text !important;
        -webkit-text-fill-color: transparent !important;
        margin-bottom: 8px !important;
        letter-spacing: -0.5px !important;
    }

    p.sparkle-subtitle {
        color: #E2E8F0 !important;
        font-size: 1rem !important;
        margin-bottom: 20px !important;
    }

    div.score-hero-badge {
        background: linear-gradient(135deg, rgba(245, 158, 11, 0.15) 0%, rgba(236, 72, 153, 0.15) 100%) !important;
        border: 1.5px solid rgba(245, 158, 11, 0.5) !important;
        border-radius: 18px !important;
        padding: 14px 20px !important;
        margin: 16px auto 20px auto !important;
        display: inline-block !important;
        box-shadow: inset 0 0 15px rgba(245, 158, 11, 0.15), 0 4px 20px rgba(0, 0, 0, 0.3) !important;
    }

    div.score-number {
        font-size: 2.2rem !important;
        font-weight: 900 !important;
        color: #FBBF24 !important;
        text-shadow: 0 0 15px rgba(245, 158, 11, 0.6) !important;
        line-height: 1 !important;
    }

    div.score-label {
        font-size: 0.78rem !important;
        color: #CBD5E1 !important;
        text-transform: uppercase !important;
        letter-spacing: 0.8px !important;
        margin-top: 4px !important;
        font-weight: 700 !important;
    }

    div.modal-stats-grid {
        display: grid !important;
        grid-template-columns: repeat(3, 1fr) !important;
        gap: 10px !important;
        margin-top: 10px !important;
    }

    div.modal-stat-card {
        background: rgba(15, 10, 28, 0.8) !important;
        border: 1px solid rgba(168, 85, 247, 0.35) !important;
        border-radius: 14px !important;
        padding: 10px 8px !important;
        text-align: center !important;
    }

    div.modal-stat-card span.m-icon {
        font-size: 1.3rem !important;
    }

    div.modal-stat-card div.m-val {
        font-size: 1rem !important;
        font-weight: 800 !important;
        color: #FAFAFA !important;
    }

    div.modal-stat-card div.m-lbl {
        font-size: 0.7rem !important;
        color: #94A3B8 !important;
        text-transform: uppercase !important;
    }

    /* ── Popovers & Profile Dropdown Modern Glass Theme ── */
    div[data-testid="stPopoverBody"],
    div[data-baseweb="popover"],
    div[data-baseweb="popover"] > div {
        background: linear-gradient(135deg, rgba(20, 13, 33, 0.96) 0%, rgba(30, 20, 50, 0.94) 100%) !important;
        border: 1.5px solid rgba(168, 85, 247, 0.45) !important;
        border-radius: 18px !important;
        box-shadow: 0 12px 35px rgba(0, 0, 0, 0.65), 0 0 25px rgba(168, 85, 247, 0.25) !important;
        backdrop-filter: blur(20px) !important;
        -webkit-backdrop-filter: blur(20px) !important;
        padding: 8px 12px !important;
        color: #FAFAFA !important;
    }

    div[data-testid="stPopover"] > button,
    div[class*="st-key-nav_admin_btn"] button {
        background: rgba(20, 13, 33, 0.85) !important;
        border: 1px solid rgba(168, 85, 247, 0.4) !important;
        border-radius: 12px !important;
        color: #FAFAFA !important;
        box-shadow: inset 0 2px 6px rgba(0, 0, 0, 0.4) !important;
        transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1) !important;
    }

    div[data-testid="stPopover"] > button:hover,
    div[class*="st-key-nav_admin_btn"] button:hover {
        border-color: rgba(192, 132, 252, 0.9) !important;
        box-shadow: 0 0 18px rgba(168, 85, 247, 0.45) !important;
        background: rgba(30, 20, 50, 0.9) !important;
        transform: translateY(-1px) !important;
    }

    /* ── Inputs & Selectboxes Theming ────────────────── */
    div[data-testid="stTextInput"] input,
    div[data-testid="stSelectbox"] div[data-baseweb="select"] {
        background: rgba(20, 13, 33, 0.85) !important;
        border: 1px solid rgba(168, 85, 247, 0.4) !important;
        border-radius: 12px !important;
        color: #FAFAFA !important;
        box-shadow: inset 0 2px 6px rgba(0, 0, 0, 0.4) !important;
        transition: all 0.25s ease !important;
    }

    div[data-testid="stTextInput"] input:focus,
    div[data-testid="stSelectbox"] div[data-baseweb="select"]:focus-within {
        border-color: rgba(168, 85, 247, 0.85) !important;
        box-shadow: 0 0 20px rgba(168, 85, 247, 0.45) !important;
    }

    /* ── Chat Messages Theming ───────────────────────── */
    div[data-testid="stChatMessage"] {
        background: linear-gradient(135deg, rgba(30, 41, 59, 0.75) 0%, rgba(15, 23, 42, 0.85) 100%) !important;
        border: 1px solid rgba(168, 85, 247, 0.35) !important;
        border-radius: 16px !important;
        padding: 1rem 1.2rem !important;
        margin-bottom: 0.8rem !important;
        box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3) !important;
        backdrop-filter: blur(16px) !important;
    }

    /* ── Research Paper Cards ────────────────────────── */
    .paper-card {
        border: 1px solid rgba(168, 85, 247, 0.35);
        border-radius: 14px;
        padding: 12px 16px;
        margin-bottom: 10px;
        background: linear-gradient(135deg, rgba(30, 41, 59, 0.6) 0%, rgba(15, 23, 42, 0.75) 100%);
        backdrop-filter: blur(12px);
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.25);
        transition: all 0.25s ease;
    }

    .paper-card:hover {
        border-color: rgba(168, 85, 247, 0.7);
        box-shadow: 0 0 25px rgba(168, 85, 247, 0.3);
        transform: translateY(-2px);
    }

    /* ── Progress Bar Theming (Single Sleek Gradient Bar) ────────── */
    div[data-testid="stProgress"] {
        height: 8px !important;
        min-height: 8px !important;
        margin: 8px 0 0 0 !important;
        padding: 0 !important;
    }

    div[data-testid="stProgress"] > div {
        height: 8px !important;
        background: rgba(30, 41, 59, 0.7) !important;
        border-radius: 8px !important;
        border: 1px solid rgba(168, 85, 247, 0.3) !important;
        overflow: hidden !important;
        box-shadow: inset 0 1px 3px rgba(0, 0, 0, 0.5) !important;
    }

    div[data-testid="stProgress"] [role="progressbar"],
    div[data-testid="stProgress"] [role="progressbar"] > div,
    div[data-testid="stProgress"] > div > div {
        background: linear-gradient(90deg, #EC4899 0%, #A855F7 50%, #3B82F6 100%) !important;
        box-shadow: 0 0 12px rgba(168, 85, 247, 0.6) !important;
        border-radius: 8px !important;
        height: 100% !important;
        border: none !important;
    }

    /* Custom In-Card Glass Progress Bars */
    .custom-progress-track {
        width: 100%;
        height: 7px;
        background: rgba(30, 41, 59, 0.8);
        border: 1px solid rgba(168, 85, 247, 0.3);
        border-radius: 10px;
        overflow: hidden;
        box-shadow: inset 0 1px 3px rgba(0, 0, 0, 0.6);
        margin-top: 4px;
    }

    .custom-progress-fill {
        height: 100%;
        background: linear-gradient(90deg, #EC4899 0%, #A855F7 50%, #3B82F6 100%);
        border-radius: 10px;
        box-shadow: 0 0 12px rgba(168, 85, 247, 0.7);
        transition: width 0.4s cubic-bezier(0.4, 0, 0.2, 1);
    }

    /* Fullscreen Faded Glassmorphic Overlay for AI Compute Cluster */
    .glass-loader-overlay-backdrop {
        position: fixed !important;
        top: 0 !important;
        left: 0 !important;
        width: 100vw !important;
        height: 100vh !important;
        background: rgba(10, 15, 29, 0.84) !important;
        backdrop-filter: blur(18px) !important;
        -webkit-backdrop-filter: blur(18px) !important;
        z-index: 999999 !important;
        display: flex !important;
        align-items: flex-start !important;
        justify-content: center !important;
        padding: 8vh 24px 40px 24px !important;
        box-sizing: border-box !important;
        overflow-y: auto !important;
        animation: fadeInOverlay 0.25s ease-out !important;
    }

    @keyframes fadeInOverlay {
        from { opacity: 0; backdrop-filter: blur(0px); }
        to { opacity: 1; backdrop-filter: blur(18px); }
    }

    /* Glassmorphism Dynamic AI Loader Box */
    .glass-loader-box {
        position: relative !important;
        background: linear-gradient(135deg, rgba(15, 23, 42, 0.96) 0%, rgba(26, 17, 46, 0.94) 100%) !important;
        backdrop-filter: blur(30px) !important;
        -webkit-backdrop-filter: blur(30px) !important;
        border: 1.5px solid rgba(168, 85, 247, 0.5) !important;
        border-radius: 24px !important;
        padding: 2rem 2.2rem !important;
        margin: 10px auto 30px auto !important;
        max-width: 860px !important;
        width: 100% !important;
        overflow: hidden !important;
        box-shadow: 0 30px 80px -10px rgba(0, 0, 0, 0.8), 0 0 45px rgba(168, 85, 247, 0.3), inset 0 0 35px rgba(168, 85, 247, 0.12) !important;
        animation: n8nPulseGlow 3s infinite ease-in-out !important;
    }

    .glass-loader-mesh {
        position: absolute;
        top: -50%;
        left: -50%;
        width: 200%;
        height: 200%;
        background: radial-gradient(circle at 20% 30%, rgba(168, 85, 247, 0.18) 0%, transparent 40%),
                    radial-gradient(circle at 80% 70%, rgba(59, 130, 246, 0.18) 0%, transparent 40%),
                    radial-gradient(circle at 50% 50%, rgba(6, 182, 212, 0.15) 0%, transparent 50%);
        background-size: 200% 200%;
        animation: meshGlow 8s infinite alternate ease-in-out;
        pointer-events: none;
        z-index: 0;
    }

    .glass-loader-content {
        position: relative;
        z-index: 1;
    }

    .loader-header {
        display: flex;
        align-items: center;
        justify-content: center;
        position: relative;
        margin-bottom: 1.2rem;
        padding-bottom: 0.8rem;
        border-bottom: 1px solid rgba(255, 255, 255, 0.08);
        width: 100%;
        text-align: center;
    }

    .loader-header-inner {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        text-align: center;
        width: 100%;
    }

    .loader-cluster-tag {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-size: 0.76rem;
        font-weight: 800;
        color: #A78BFA;
        text-transform: uppercase;
        letter-spacing: 1.5px;
        margin-bottom: 6px;
        text-align: center;
    }

    .loader-title {
        font-size: 1.28rem;
        font-weight: 800;
        background: linear-gradient(135deg, #EC4899 0%, #A855F7 50%, #06B6D4 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        letter-spacing: 0.5px;
        text-align: center;
    }

    .loader-subtitle {
        color: #94A3B8;
        font-size: 0.88rem;
        margin-top: 2px;
        text-align: center;
    }

    .loader-metrics-badge {
        position: absolute;
        top: 0;
        right: 0;
        background: rgba(30, 41, 59, 0.8);
        border: 1px solid rgba(168, 85, 247, 0.4);
        border-radius: 30px;
        padding: 5px 12px;
        font-size: 0.76rem;
        font-weight: 700;
        color: #A78BFA;
        display: flex;
        align-items: center;
        gap: 6px;
    }

    @media (max-width: 640px) {
        .loader-metrics-badge {
            position: static;
            margin-top: 8px;
        }
    }

    @keyframes pulseTravel1 {
        0% { cx: 80px; cy: 35px; opacity: 0; }
        50% { opacity: 1; }
        100% { cx: 280px; cy: 25px; opacity: 0; }
    }
    @keyframes pulseTravel2 {
        0% { cx: 280px; cy: 25px; opacity: 0; }
        50% { opacity: 1; }
        100% { cx: 520px; cy: 75px; opacity: 0; }
    }
    @keyframes pulseTravel3 {
        0% { cx: 520px; cy: 75px; opacity: 0; }
        50% { opacity: 1; }
        100% { cx: 720px; cy: 75px; opacity: 0; }
    }

    .synapse-pulse { animation: pulseTravel1 1.8s infinite linear; }
    .synapse-pulse-2 { animation: pulseTravel2 2.2s infinite linear; }
    .synapse-pulse-3 { animation: pulseTravel3 1.6s infinite linear; }

    .neural-network-canvas {
        background: rgba(15, 23, 42, 0.6);
        border: 1px solid rgba(168, 85, 247, 0.25);
        border-radius: 14px;
        padding: 12px;
        margin: 1rem 0;
        backdrop-filter: blur(12px);
        overflow: hidden;
    }

    .cluster-spinner {
        display: inline-block;
        width: 14px;
        height: 14px;
        border: 2.5px solid rgba(168, 85, 247, 0.25);
        border-top-color: #EC4899;
        border-right-color: #A855F7;
        border-bottom-color: #06B6D4;
        border-radius: 50%;
        animation: spinCluster 0.85s cubic-bezier(0.4, 0, 0.2, 1) infinite;
        vertical-align: middle;
        margin-right: 8px;
        box-shadow: 0 0 12px rgba(168, 85, 247, 0.8), inset 0 0 4px rgba(236, 72, 153, 0.4);
    }

    .agent-mini-spinner {
        display: inline-block;
        width: 11px;
        height: 11px;
        border: 2px solid rgba(192, 132, 252, 0.3);
        border-top-color: #F472B6;
        border-right-color: #C084FC;
        border-bottom-color: #38BDF8;
        border-radius: 50%;
        animation: spinCluster 0.75s linear infinite;
        vertical-align: middle;
        margin-right: 5px;
        box-shadow: 0 0 8px rgba(192, 132, 252, 0.8);
    }

    @keyframes spinCluster {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }

    .agent-workflow-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(210px, 1fr));
        gap: 0.85rem;
        margin-top: 1rem;
    }

    .agent-card-item {
        background: rgba(30, 41, 59, 0.55);
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 12px;
        padding: 0.85rem;
        backdrop-filter: blur(10px);
        transition: all 0.3s ease;
    }

    .agent-card-item.active {
        border-color: rgba(168, 85, 247, 0.85);
        background: linear-gradient(135deg, rgba(124, 58, 237, 0.25) 0%, rgba(236, 72, 153, 0.15) 100%);
        box-shadow: 0 0 25px rgba(168, 85, 247, 0.35), inset 0 0 15px rgba(168, 85, 247, 0.15);
        transform: translateY(-2px);
    }

    .agent-card-item.completed {
        border-color: rgba(16, 185, 129, 0.6);
        background: rgba(16, 185, 129, 0.08);
    }

    .agent-card-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 0.3rem;
    }

    .agent-name {
        font-weight: 700;
        font-size: 0.85rem;
        color: #F4F4F5;
    }

    .agent-status-tag {
        font-size: 0.65rem;
        font-weight: 800;
        padding: 2px 7px;
        border-radius: 5px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    .tag-completed { background: rgba(16, 185, 129, 0.2); color: #34D399; }
    .tag-active {
        background: linear-gradient(135deg, rgba(168, 85, 247, 0.3) 0%, rgba(236, 72, 153, 0.25) 100%);
        color: #F472B6;
        border: 1px solid rgba(192, 132, 252, 0.4);
        box-shadow: 0 0 10px rgba(168, 85, 247, 0.4);
        display: inline-flex;
        align-items: center;
    }
    .tag-waiting { background: rgba(255, 255, 255, 0.05); color: #71717A; }

    .agent-desc {
        font-size: 0.75rem;
        color: #94A3B8;
        line-height: 1.3;
    }

    /* ── Active Journey Resume Cards (Uniform Glass Grid) ── */
    div[data-testid="stHorizontalBlock"]:has(.aj-card-marker) {
        align-items: stretch !important;
        gap: 1.2rem !important;
        margin-bottom: 1.5rem !important;
    }

    div[data-testid="stHorizontalBlock"]:has(.aj-card-marker) > div[data-testid="stColumn"],
    div[data-testid="stHorizontalBlock"]:has(.aj-card-marker) > div[data-testid="column"] {
        display: flex !important;
        flex-direction: column !important;
        flex: 1 1 0 !important;
        height: 100% !important;
    }

    div[data-testid="stColumn"]:has(.aj-card-marker),
    div[data-testid="column"]:has(.aj-card-marker) {
        padding: 1.3rem 1.2rem 1.1rem 1.2rem !important;
        box-sizing: border-box !important;
        display: flex !important;
        flex-direction: column !important;
        justify-content: space-between !important;
    }

    div[data-testid="stColumn"]:has(.aj-card-marker) > div[data-testid="stVerticalBlock"],
    div[data-testid="column"]:has(.aj-card-marker) > div[data-testid="stVerticalBlock"],
    div[data-testid="stColumn"]:has(.aj-card-marker) > div[data-testid="stVerticalBlockBorderWrapper"],
    div[data-testid="column"]:has(.aj-card-marker) > div[data-testid="stVerticalBlockBorderWrapper"] {
        display: flex !important;
        flex-direction: column !important;
        justify-content: space-between !important;
        height: 100% !important;
        flex: 1 1 auto !important;
        gap: 0 !important;
        padding: 0 !important;
        margin: 0 !important;
    }

    .aj-topic-title {
        font-size: 0.95rem !important;
        font-weight: 800 !important;
        color: #FAFAFA !important;
        margin: 6px 0 10px 0 !important;
        line-height: 1.35 !important;
        height: 2.7em !important;
        max-height: 2.7em !important;
        display: -webkit-box !important;
        -webkit-line-clamp: 2 !important;
        -webkit-box-orient: vertical !important;
        overflow: hidden !important;
        text-overflow: ellipsis !important;
        word-break: break-word !important;
    }

    div[data-testid="stColumn"]:has(.aj-card-marker) div[data-testid="stElementContainer"]:has(div[data-testid="stButton"]),
    div[data-testid="column"]:has(.aj-card-marker) div[data-testid="stElementContainer"]:has(div[data-testid="stButton"]),
    div[data-testid="stColumn"]:has(.aj-card-marker) div[data-testid="stButton"],
    div[data-testid="column"]:has(.aj-card-marker) div[data-testid="stButton"] {
        margin-top: auto !important;
        margin-bottom: 0 !important;
        width: 100% !important;
        padding-top: 14px !important;
    }

    div[data-testid="stColumn"]:has(.aj-card-marker) div[data-testid="stButton"] button,
    div[data-testid="column"]:has(.aj-card-marker) div[data-testid="stButton"] button {
        width: 100% !important;
        border-radius: 12px !important;
        font-size: 0.85rem !important;
        font-weight: 800 !important;
        padding: 8px 16px !important;
        min-height: 38px !important;
        height: 38px !important;
        background: linear-gradient(135deg, #EC4899 0%, #A855F7 50%, #3B82F6 100%) !important;
        border: none !important;
        color: #FFFFFF !important;
        box-shadow: 0 0 20px rgba(236, 72, 153, 0.4), 0 0 14px rgba(168, 85, 247, 0.35) !important;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1) !important;
    }

    div[data-testid="stColumn"]:has(.aj-card-marker) div[data-testid="stButton"] button:hover,
    div[data-testid="column"]:has(.aj-card-marker) div[data-testid="stButton"] button:hover {
        box-shadow: 0 0 32px rgba(236, 72, 153, 0.75), 0 0 20px rgba(6, 182, 212, 0.6) !important;
        transform: translateY(-2px) !important;
    }
</style>
"""


def format_display_text(val: Any) -> str:
    """Format enum or string values by replacing underscores with spaces and applying title case."""
    if val is None:
        return ""
    str_val = val.value if hasattr(val, "value") else str(val)
    return str_val.replace("_", " ").title()


def get_mode_icon(mode_val: Any) -> str:
    """Return appropriate icon for learning mode."""
    str_val = (mode_val.value if hasattr(mode_val, "value") else str(mode_val)).lower()
    if "visual" in str_val:
        return "🎨"
    elif "deep" in str_val:
        return "🔬"
    elif "bite" in str_val:
        return "⚡"
    return "🎯"


def get_audience_icon(aud_val: Any) -> str:
    """Return appropriate icon for student level / audience."""
    str_val = (aud_val.value if hasattr(aud_val, "value") else str(aud_val)).lower()
    if "middle" in str_val:
        return "🏫"
    elif "high" in str_val:
        return "🎒"
    elif "undergrad" in str_val:
        return "🏛️"
    elif "grad" in str_val:
        return "🎓"
    return "💡"


def get_item_attr(item: Any, key: str, default: Any = None) -> Any:
    """Safely extract an attribute or dictionary key value from an item."""
    if isinstance(item, dict):
        return item.get(key, default)
    return getattr(item, key, default)


def safe_set_attr(item: Any, key: str, value: Any) -> None:
    """Safely set an attribute or dictionary key value on an item."""
    if isinstance(item, dict):
        item[key] = value
    else:
        try:
            setattr(item, key, value)
        except Exception:
            pass


def format_quiz_options(raw_opts: Any) -> list[str]:
    """Format raw quiz options into clean labeled option strings."""
    if isinstance(raw_opts, dict):
        return [f"{k}: {v}" for k, v in raw_opts.items()]
    elif isinstance(raw_opts, list):
        formatted = []
        letters = ["A", "B", "C", "D", "E", "F"]
        for idx, opt in enumerate(raw_opts):
            opt_str = str(opt).strip()
            if len(opt_str) > 2 and opt_str[0].upper() in letters and opt_str[1] in [":", ")", "."]:
                formatted.append(f"{opt_str[0].upper()}: {opt_str[2:].strip()}")
            else:
                label = letters[idx] if idx < len(letters) else str(idx + 1)
                formatted.append(f"{label}: {opt_str}")
        return formatted
    return ["A: Option A", "B: Option B"]


def is_answer_correct(selected_full: str, selected_key: str, correct_raw: str) -> bool:
    """Check if student's answer matches the correct answer in any format."""
    correct_str = str(correct_raw).strip()
    correct_key = correct_str.split(":")[0].split(")")[0].split(".")[0].strip().upper()
    
    if selected_full.strip().lower() == correct_str.lower():
        return True
    if selected_key.upper() == correct_key:
        return True
    if len(correct_str) > 2 and correct_str.lower() in selected_full.lower():
        return True
    return False


def render_glassy_agent_loader_html(
    title: str,
    subtitle: str,
    orchestrator_status: str = "waiting",
    socratic_status: str = "waiting",
    youtube_status: str = "waiting",
    academic_status: str = "waiting",
    quiz_status: str = "waiting",
    progress_percent: int = 30,
) -> str:
    """
    Renders a vivid Glassmorphism AI Compute loader with glowing mesh gradients,
    neural network node visualizers, glowing spinner, and step-by-step agent workflow cards.
    """
    def _status_tag(status: str) -> str:
        if status == "completed":
            return '<span class="agent-status-tag tag-completed">✓ COMPLETED</span>'
        elif status == "active":
            return '<span class="agent-status-tag tag-active"><span class="agent-mini-spinner"></span>EXECUTING...</span>'
        else:
            return '<span class="agent-status-tag tag-waiting">⌛ QUEUED</span>'

    def _card_class(status: str) -> str:
        if status == "completed":
            return "agent-card-item completed"
        elif status == "active":
            return "agent-card-item active"
        else:
            return "agent-card-item"

    return f"""<div class="glass-loader-overlay-backdrop">
<div class="glass-loader-box">
<div class="glass-loader-mesh"></div>
<div class="glass-loader-content">
<div class="loader-header">
<div class="loader-header-inner">
<div class="loader-cluster-tag">
<span class="cluster-spinner"></span>
<span>EDU-TECH AI COMPUTE CLUSTER &nbsp;•&nbsp; NEURAL INFERENCE</span>
</div>
<div class="loader-title">{title}</div>
<div class="loader-subtitle">{subtitle}</div>
</div>
<div class="loader-metrics-badge">
<span style="display:inline-block; width:8px; height:8px; border-radius:50%; background:#10B981; box-shadow:0 0 8px #10B981;"></span>
<span>LIVE INFERENCE</span>
</div>
</div>
<div class="neural-network-canvas">
<svg width="100%" height="150" viewBox="0 0 800 150" fill="none" xmlns="http://www.w3.org/2000/svg">
<!-- Synapse Connection Lines -->
<line x1="80" y1="35" x2="280" y2="25" stroke="rgba(236,72,153,0.35)" stroke-width="2" />
<line x1="80" y1="35" x2="280" y2="75" stroke="rgba(236,72,153,0.35)" stroke-width="2" />
<line x1="80" y1="35" x2="280" y2="125" stroke="rgba(236,72,153,0.35)" stroke-width="2" />
<line x1="80" y1="115" x2="280" y2="25" stroke="rgba(236,72,153,0.35)" stroke-width="2" />
<line x1="80" y1="115" x2="280" y2="75" stroke="rgba(236,72,153,0.35)" stroke-width="2" />
<line x1="80" y1="115" x2="280" y2="125" stroke="rgba(236,72,153,0.35)" stroke-width="2" />

<line x1="280" y1="25" x2="520" y2="25" stroke="rgba(168,85,247,0.4)" stroke-width="2" />
<line x1="280" y1="25" x2="520" y2="75" stroke="rgba(168,85,247,0.4)" stroke-width="2" />
<line x1="280" y1="75" x2="520" y2="75" stroke="rgba(168,85,247,0.4)" stroke-width="2" />
<line x1="280" y1="75" x2="520" y2="125" stroke="rgba(168,85,247,0.4)" stroke-width="2" />
<line x1="280" y1="125" x2="520" y2="75" stroke="rgba(168,85,247,0.4)" stroke-width="2" />
<line x1="280" y1="125" x2="520" y2="125" stroke="rgba(168,85,247,0.4)" stroke-width="2" />

<line x1="520" y1="25" x2="720" y2="75" stroke="rgba(59,130,246,0.4)" stroke-width="2" />
<line x1="520" y1="75" x2="720" y2="75" stroke="rgba(6,182,212,0.4)" stroke-width="2" />
<line x1="520" y1="125" x2="720" y2="75" stroke="rgba(16,185,129,0.4)" stroke-width="2" />

<!-- Animated Traveling Synapse Pulse Bullets -->
<circle cx="180" cy="30" r="4" fill="#EC4899" class="synapse-pulse" />
<circle cx="400" cy="50" r="4" fill="#A855F7" class="synapse-pulse-2" />
<circle cx="620" cy="75" r="4" fill="#3B82F6" class="synapse-pulse-3" />

<!-- Solid Neural Node Points -->
<circle cx="80" cy="35" r="16" fill="#0F172A" stroke="#EC4899" stroke-width="3" />
<text x="80" y="39" font-size="11" text-anchor="middle" fill="#FAFAFA">🎯</text>
<text x="80" y="64" font-size="10" font-weight="700" text-anchor="middle" fill="#EC4899">Topic</text>

<circle cx="80" cy="115" r="16" fill="#0F172A" stroke="#F43F5E" stroke-width="3" />
<text x="80" y="119" font-size="11" text-anchor="middle" fill="#FAFAFA">👤</text>
<text x="80" y="144" font-size="10" font-weight="700" text-anchor="middle" fill="#F43F5E">Context</text>

<circle cx="280" cy="25" r="17" fill="#0F172A" stroke="#A855F7" stroke-width="3" />
<text x="280" y="30" font-size="12" text-anchor="middle" fill="#FAFAFA">🧠</text>
<text x="280" y="54" font-size="10" font-weight="700" text-anchor="middle" fill="#C084FC">Orchestrator</text>

<circle cx="280" cy="75" r="15" fill="#0F172A" stroke="#8B5CF6" stroke-width="3" />
<text x="280" y="79" font-size="11" text-anchor="middle" fill="#FAFAFA">⚡</text>
<text x="280" y="101" font-size="10" font-weight="700" text-anchor="middle" fill="#A78BFA">Roadmap</text>

<circle cx="280" cy="125" r="15" fill="#0F172A" stroke="#7C3AED" stroke-width="3" />
<text x="280" y="129" font-size="11" text-anchor="middle" fill="#FAFAFA">📊</text>
<text x="280" y="149" font-size="10" font-weight="700" text-anchor="middle" fill="#DDD6FE">Vector RAG</text>

<circle cx="520" cy="25" r="16" fill="#0F172A" stroke="#3B82F6" stroke-width="3" />
<text x="520" y="29" font-size="11" text-anchor="middle" fill="#FAFAFA">💬</text>
<text x="520" y="53" font-size="10" font-weight="700" text-anchor="middle" fill="#93C5FD">Socratic</text>

<circle cx="520" cy="75" r="16" fill="#0F172A" stroke="#06B6D4" stroke-width="3" />
<text x="520" y="79" font-size="11" text-anchor="middle" fill="#FAFAFA">📺</text>
<text x="520" y="103" font-size="10" font-weight="700" text-anchor="middle" fill="#67E8F9">YouTube</text>

<circle cx="520" cy="125" r="16" fill="#0F172A" stroke="#10B981" stroke-width="3" />
<text x="520" y="129" font-size="11" text-anchor="middle" fill="#FAFAFA">📚</text>
<text x="520" y="151" font-size="10" font-weight="700" text-anchor="middle" fill="#6EE7B7">Academic</text>

<circle cx="720" cy="75" r="22" fill="#0F172A" stroke="#EC4899" stroke-width="4" />
<text x="720" y="80" font-size="15" text-anchor="middle" fill="#FAFAFA">🎓</text>
<text x="720" y="112" font-size="11" font-weight="800" text-anchor="middle" fill="#F472B6">Workspace</text>
</svg>
</div>
<div style="background: rgba(255, 255, 255, 0.06); border-radius: 10px; height: 8px; overflow: hidden; margin-bottom: 1.2rem; position: relative;">
<div style="width: {progress_percent}%; height: 100%; background: linear-gradient(90deg, #EC4899 0%, #A855F7 50%, #06B6D4 100%); border-radius: 10px; transition: width 0.5s ease-in-out;"></div>
</div>
<div class="agent-workflow-grid">
<div class="{_card_class(orchestrator_status)}">
<div class="agent-card-header">
<span class="agent-name">🧠 Orchestrator Agent</span>
{_status_tag(orchestrator_status)}
</div>
<div class="agent-desc">Decomposing topic into structured, age-appropriate milestone roadmap.</div>
</div>
<div class="{_card_class(socratic_status)}">
<div class="agent-card-header">
<span class="agent-name">💬 Socratic Tutor</span>
{_status_tag(socratic_status)}
</div>
<div class="agent-desc">Crafting deep intuitive explanations & interactive guiding questions.</div>
</div>
<div class="{_card_class(youtube_status)}">
<div class="agent-card-header">
<span class="agent-name">📺 YouTube Curator</span>
{_status_tag(youtube_status)}
</div>
<div class="agent-desc">Filtering high-yield educational videos with precise timestamp deep-linking.</div>
</div>
<div class="{_card_class(academic_status)}">
<div class="agent-card-header">
<span class="agent-name">📚 Academic Researcher</span>
{_status_tag(academic_status)}
</div>
<div class="agent-desc">Indexing peer-reviewed open access papers from OpenAlex & Semantic Scholar.</div>
</div>
<div class="{_card_class(quiz_status)}">
<div class="agent-card-header">
<span class="agent-name">📝 Quiz Agent</span>
{_status_tag(quiz_status)}
</div>
<div class="agent-desc">Structuring adaptive comprehension questions & XP reward multipliers.</div>
</div>
</div>
</div>
</div>
</div>"""


# ─── Helper Functions & Multi-Agent Execution ─────────────────────
def run_async(coro):
    """Run an async coroutine inside Streamlit's sync execution model."""
    try:
        loop = asyncio.get_event_loop()
    except RuntimeError:
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
    return loop.run_until_complete(coro)


async def generate_all_agent_content_for_step(step, memory: SharedMemory) -> None:
    """
    Run Socratic Tutor, YouTube Curator, Academic Researcher, and Quiz Agent
    for a milestone step, bringing all agent results together.
    """
    if getattr(step, "index", None) is not None:
        st.session_state[f"step_agents_ran_{step.index}"] = True
    setattr(step, "_agent_generated", True)

    # 1. Generate Socratic Explanation first so Quiz Agent has full context
    if getattr(step, "tutor_explanation", None) is None:
        tutor = SocraticTutorAgent()
        try:
            exp_res = await tutor.explain_step_with_questions(step, memory.topic, memory.learning_mode, memory.student_level)
            if isinstance(exp_res, tuple) and len(exp_res) == 2:
                setattr(step, "tutor_explanation", exp_res[0])
                try:
                    setattr(step, "socratic_questions", exp_res[1])
                except Exception:
                    pass
                st.session_state[f"socratic_qs_{step.index}"] = exp_res[1]
            else:
                setattr(step, "tutor_explanation", str(exp_res))
        except Exception as e:
            logging.error(f"Socratic Tutor failed for step {step.index}: {e}")

    # 2. Run YouTube Curator, Academic Researcher, and Quiz Agent concurrently
    tasks = []
    task_keys = []

    if not getattr(step, "videos", None):
        curator = YouTubeCuratorAgent()
        tasks.append(curator.curate_videos(step, memory.topic, memory.student_level))
        task_keys.append("videos")

    if not getattr(step, "papers", None):
        researcher = AcademicResearcherAgent()
        tasks.append(researcher.curate_papers(step, memory.topic))
        task_keys.append("papers")

    if not getattr(step, "quiz", None):
        quiz_agent = QuizAgent()
        tasks.append(quiz_agent.generate_quiz(step, memory.topic, memory.student_level))
        task_keys.append("quiz")

    if tasks:
        results = await asyncio.gather(*tasks, return_exceptions=True)

        for key, result in zip(task_keys, results):
            if isinstance(result, Exception):
                logging.error(f"Error executing agent '{key}' for step {step.index}: {result}")
                if key == "quiz":
                    setattr(step, "quiz", QuizAgent()._generate_fallback_quiz(getattr(step, "title", "Step")))
                continue
            if key == "videos":
                setattr(step, "videos", result if isinstance(result, list) else [])
            elif key == "papers":
                setattr(step, "papers", result if isinstance(result, list) else [])
            elif key == "quiz":
                final_quiz = result if isinstance(result, list) and result else QuizAgent()._generate_fallback_quiz(getattr(step, "title", "Step"))
                setattr(step, "quiz", final_quiz)

    if not getattr(step, "quiz", None):
        setattr(step, "quiz", QuizAgent()._generate_fallback_quiz(getattr(step, "title", "Step")))

    try:
        from services.session_manager import SessionManager
        await SessionManager().update_session(memory)
    except Exception as e:
        logging.warning(f"Could not persist multi-agent step results to DB: {e}")


# ─── One-Time DB Initialization (at Streamlit app startup) ───────
@st.cache_resource(show_spinner=False)
def _init_db_once():
    """Warm up DB schema, migrations, and seeds at app start — not on first admin switch."""
    from services.database import init_db
    from config import get_settings
    run_async(init_db(get_settings()))


_init_db_once()  # Triggered once on first Streamlit page load


def get_or_create_memory() -> SharedMemory | None:
    """Retrieve active session from session state."""
    return st.session_state.get("memory")


def calculate_overall_topic_score(memory) -> float:
    """Calculates average quiz accuracy score across all milestones in memory."""
    if not memory or not memory.steps:
        return 1.0
    scores = []
    for step in memory.steps:
        s = getattr(step, "quiz_score", None)
        if s is not None:
            scores.append(s)
    if scores:
        return sum(scores) / len(scores)
    return 1.0


@st.dialog("🎉 Milestone Mastery Accomplished!", width="medium")
def show_congratulations_dialog(memory):
    """
    Renders a sparkling, glowing victory modal dialog with canvas confetti,
    overall quiz score badge, XP & streak stats, and CTAs.
    """
    total_steps = len(memory.steps) if memory and memory.steps else 0
    xp_val = getattr(memory, "xp_earned", 0)
    streak_val = getattr(memory, "streak_count", 1)
    topic_str = getattr(memory, "topic", "this topic")
    avg_score = calculate_overall_topic_score(memory)

    # Lightweight JS Confetti particle burst inside glowing modal
    st.components.v1.html(
        """
        <script src="https://cdn.jsdelivr.net/npm/canvas-confetti@1.9.2/dist/confetti.browser.min.js"></script>
        <script>
          setTimeout(() => {
            confetti({
              particleCount: 160,
              spread: 95,
              origin: { y: 0.4 },
              colors: ['#EC4899', '#A855F7', '#3B82F6', '#F59E0B', '#10B981']
            });
          }, 120);
        </script>
        """,
        height=0,
    )

    modal_html = f"""<div class="sparkling-modal-card">
<div class="glowing-trophy-box">
<span class="trophy-emoji">🏆</span>
</div>
<h2 class="sparkle-title">Course Mastery Accomplished!</h2>
<p class="sparkle-subtitle">Outstanding work! You have completed all <b>{total_steps}</b> milestone steps for <b>{topic_str}</b>.</p>
<div class="score-hero-badge">
<div class="score-number">{avg_score:.0%}</div>
<div class="score-label">Overall Quiz Score</div>
</div>
<div class="modal-stats-grid">
<div class="modal-stat-card">
<span class="m-icon">⚡</span>
<div class="m-val">+{xp_val} XP</div>
<div class="m-lbl">Points Earned</div>
</div>
<div class="modal-stat-card">
<span class="m-icon">🔥</span>
<div class="m-val">{streak_val} Days</div>
<div class="m-lbl">Streak Kept</div>
</div>
<div class="modal-stat-card">
<span class="m-icon">🎓</span>
<div class="m-val">{total_steps}/{total_steps}</div>
<div class="m-lbl">Milestones</div>
</div>
</div>
</div>"""

    st.markdown(modal_html, unsafe_allow_html=True)

    st.markdown("<br>", unsafe_allow_html=True)
    c1, c2 = st.columns([1, 1])
    with c1:
        if st.button("🚀 Explore New Topic", key="dlg_btn_new_topic", type="primary", use_container_width=True):
            if memory and getattr(memory, "session_id", None):
                st.session_state[f"show_victory_modal_{memory.session_id}"] = False
            st.session_state["memory"] = None
            st.session_state["view"] = "home"
            if "last_topic" in st.session_state:
                del st.session_state["last_topic"]
            st.query_params.clear()
            st.rerun()
    with c2:
        if st.button("✨ Close & Review Roadmap", key="dlg_btn_close", use_container_width=True):
            if memory and getattr(memory, "session_id", None):
                st.session_state[f"show_victory_modal_{memory.session_id}"] = False
                st.session_state[f"victory_modal_dismissed_{memory.session_id}"] = True
            st.rerun()


def render_learning_workspace():
    """Renders the student learning workspace with the glassy AI theme."""
    st.markdown(CUSTOM_CSS, unsafe_allow_html=True)

    # Background ambient glow orbs
    st.markdown('<div class="glow-bg"></div>', unsafe_allow_html=True)

    user_profile = st.session_state.get("user_profile")
    if not user_profile:
        st.session_state["auth_tab"] = "login"
        st.session_state["view"] = "auth"
        st.toast("🔒 Authentication Required: Please sign in or create an account to access the AI learning workspace.", icon="🔒")
        st.rerun()


    memory = get_or_create_memory()

    # Master Sidebar Toggle, Collapse Sync & Collapsed Mini-Rail Controller
    components.html(
        """
        <script>
        (function() {
            try {
                const doc = window.parent.document;
                const win = window.parent;

                function dispatchFullClick(el) {
                    if (!el) return;
                    try {
                        const btn = (el.tagName === 'BUTTON') ? el : (el.querySelector('button') || el);
                        const rect = btn.getBoundingClientRect();
                        const cx = rect.width > 0 ? (rect.left + rect.width / 2) : 16;
                        const cy = rect.height > 0 ? (rect.top + rect.height / 2) : 16;
                        const opts = { bubbles: true, cancelable: true, view: win, clientX: cx, clientY: cy, composed: true };
                        
                        btn.dispatchEvent(new PointerEvent('pointerdown', opts));
                        btn.dispatchEvent(new MouseEvent('mousedown', opts));
                        btn.dispatchEvent(new PointerEvent('pointerup', opts));
                        btn.dispatchEvent(new MouseEvent('mouseup', opts));
                        btn.dispatchEvent(new MouseEvent('click', opts));
                        if (typeof btn.click === 'function') {
                            btn.click();
                        }
                    } catch(err) {
                        try { if (typeof el.click === 'function') el.click(); } catch(e) {}
                    }
                }

                function findExpandButton() {
                    const selectors = [
                        '[data-testid="stSidebarCollapsedControl"] button',
                        '[data-testid="collapsedControl"] button',
                        'header[data-testid="stHeader"] [data-testid="stSidebarCollapsedControl"] button',
                        'header[data-testid="stHeader"] [data-testid="collapsedControl"] button',
                        '[data-testid="stSidebarCollapsedControl"]',
                        '[data-testid="collapsedControl"]',
                        'button[data-testid="stSidebarCollapseButton"]',
                        '[data-testid="stSidebarCollapseButton"] button',
                        'section[data-testid="stSidebar"] [data-testid="stSidebarCollapseButton"] button',
                        'header[data-testid="stHeader"] button',
                        'button[aria-label*="Expand" i]',
                        'button[aria-label*="Open sidebar" i]',
                        'button[title*="Expand" i]',
                        'button[title*="Open sidebar" i]'
                    ];
                    for (let s of selectors) {
                        let el = doc.querySelector(s);
                        if (el) return (el.tagName === 'BUTTON' ? el : (el.querySelector('button') || el));
                    }

                    const allBtns = doc.querySelectorAll('header[data-testid="stHeader"] button, [data-testid="stHeader"] button, button');
                    for (let b of allBtns) {
                        const aria = (b.getAttribute('aria-label') || '').toLowerCase();
                        const title = (b.getAttribute('title') || '').toLowerCase();
                        if (aria.includes('expand') || aria.includes('open sidebar') || title.includes('expand') || title.includes('open sidebar')) {
                            return b;
                        }
                    }
                    return null;
                }

                function findCollapseButton() {
                    const selectors = [
                        'section[data-testid="stSidebar"] [data-testid="stSidebarCollapseButton"] button',
                        '[data-testid="stSidebarCollapseButton"] button',
                        'section[data-testid="stSidebar"] [data-testid="stSidebarHeader"] button',
                        '[data-testid="stSidebarHeader"] button',
                        'section[data-testid="stSidebar"] button[aria-label*="Close" i]',
                        'section[data-testid="stSidebar"] button[aria-label*="Collapse" i]',
                        'button[aria-label*="Close sidebar" i]',
                        'button[aria-label*="Collapse sidebar" i]'
                    ];
                    for (let s of selectors) {
                        let el = doc.querySelector(s);
                        if (el) return (el.tagName === 'BUTTON' ? el : (el.querySelector('button') || el));
                    }

                    const allSbBtns = doc.querySelectorAll('section[data-testid="stSidebar"] button, [data-testid="stSidebarHeader"] button');
                    for (let b of allSbBtns) {
                        const aria = (b.getAttribute('aria-label') || '').toLowerCase();
                        const title = (b.getAttribute('title') || '').toLowerCase();
                        if (aria.includes('close') || aria.includes('collapse') || title.includes('close') || title.includes('collapse')) {
                            return b;
                        }
                    }
                    return doc.querySelector('[data-testid="stSidebarCollapseButton"] button');
                }

                // Global Delegated click handler for top collapse button and history collapse toggle
                doc.addEventListener('click', function(e) {
                    const collapseTarget = e.target && e.target.closest ? e.target.closest('#edutech-sb-collapse-btn, .sidebar-top-collapse-btn') : null;
                    if (collapseTarget) {
                        e.preventDefault();
                        e.stopPropagation();
                        const closeBtn = findCollapseButton();
                        if (closeBtn) {
                            dispatchFullClick(closeBtn);
                        }
                    }

                    const histTarget = e.target && e.target.closest ? e.target.closest('#edutech-hist-collapse-header') : null;
                    if (histTarget) {
                        e.preventDefault();
                        e.stopPropagation();
                        const hiddenBtn = doc.querySelector('div[class*="st-key-sb_hist_hidden_toggle_btn"] button');
                        if (hiddenBtn) {
                            dispatchFullClick(hiddenBtn);
                        }
                    }
                }, true);

                function isSidebarOpen() {
                    const sb = doc.querySelector('section[data-testid="stSidebar"]');
                    if (!sb) return false;
                    const ariaExpanded = sb.getAttribute('aria-expanded');
                    if (ariaExpanded === 'false') return false;
                    if (ariaExpanded === 'true') return true;
                    const comp = win.getComputedStyle(sb);
                    if (comp.display === 'none' || comp.visibility === 'hidden' || comp.opacity === '0') return false;
                    const rect = sb.getBoundingClientRect();
                    return rect.width > 50 && rect.right > 50;
                }

                // Remove legacy master toggle if present
                const oldToggle = doc.getElementById('edutech-sidebar-master-toggle');
                if (oldToggle && oldToggle.parentNode) {
                    oldToggle.parentNode.removeChild(oldToggle);
                }

                // Inject Collapsed Mini Icon Rail
                let miniRail = doc.getElementById('edutech-collapsed-mini-rail');
                if (!miniRail) {
                    miniRail = doc.createElement('div');
                    miniRail.id = 'edutech-collapsed-mini-rail';
                    miniRail.innerHTML = `
                        <div class="mr-item mr-logo-expand" id="mr-btn-expand" title="Expand Sidebar (Click to Open)">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#C084FC" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                <polyline points="9 18 15 12 9 6"></polyline>
                            </svg>
                        </div>
                        <div class="mr-item mr-new-journey" id="mr-btn-new-journey" title="New Learning Journey">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M12 20h9"></path>
                                <path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path>
                            </svg>
                        </div>
                        <div class="mr-item mr-history" id="mr-btn-history" title="Learning History">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#C084FC" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                                <circle cx="12" cy="12" r="10"></circle>
                                <polyline points="12 6 12 12 16 14"></polyline>
                            </svg>
                        </div>
                        <div style="flex-grow: 1;"></div>
                        <div class="mr-item mr-profile" id="mr-btn-profile" title="Profile & Settings">
                            <div style="width: 28px; height: 28px; border-radius: 50%; background: linear-gradient(135deg, rgba(168, 85, 247, 0.5) 0%, rgba(59, 130, 246, 0.5) 100%); display: flex; align-items: center; justify-content: center; font-size: 0.9rem; border: 1.5px solid #A855F7;">&#128100;</div>
                        </div>
                    `;
                    doc.body.appendChild(miniRail);

                    const expandItem = miniRail.querySelector('#mr-btn-expand');
                    if (expandItem) {
                        expandItem.onclick = function(e) {
                            e.preventDefault();
                            e.stopPropagation();
                            const expBtn = findExpandButton();
                            if (expBtn) dispatchFullClick(expBtn);
                            setTimeout(updateRailVisibility, 100);
                        };
                    }
                    const newItem = miniRail.querySelector('#mr-btn-new-journey');
                    if (newItem) {
                        newItem.onclick = function(e) {
                            e.preventDefault();
                            e.stopPropagation();
                            const expBtn = findExpandButton();
                            if (expBtn) dispatchFullClick(expBtn);
                            setTimeout(() => {
                                const njBtn = doc.querySelector('div[class*="st-key-sb_new_journey_btn"] button');
                                if (njBtn) dispatchFullClick(njBtn);
                            }, 250);
                        };
                    }
                    const histItem = miniRail.querySelector('#mr-btn-history');
                    if (histItem) {
                        histItem.onclick = function(e) {
                            e.preventDefault();
                            e.stopPropagation();
                            const expBtn = findExpandButton();
                            if (expBtn) dispatchFullClick(expBtn);
                            setTimeout(updateRailVisibility, 100);
                        };
                    }
                    const profItem = miniRail.querySelector('#mr-btn-profile');
                    if (profItem) {
                        profItem.onclick = function(e) {
                            e.preventDefault();
                            e.stopPropagation();
                            const expBtn = findExpandButton();
                            if (expBtn) dispatchFullClick(expBtn);
                            setTimeout(() => {
                                const popBtn = doc.querySelector('section[data-testid="stSidebar"] div[data-testid="stPopover"] button');
                                if (popBtn) dispatchFullClick(popBtn);
                            }, 250);
                        };
                    }
                }

                function updateRailVisibility() {
                    const mr = doc.getElementById('edutech-collapsed-mini-rail');
                    if (!mr) return;
                    mr.style.display = isSidebarOpen() ? 'none' : 'flex';
                }

                updateRailVisibility();

                if (!win._edutechRailTracking) {
                    win._edutechRailTracking = true;
                    function track() {
                        updateRailVisibility();
                        requestAnimationFrame(track);
                    }
                    requestAnimationFrame(track);
                }
            } catch (err) {
                console.error("Sidebar rail controller error:", err);
            }
        })();
        </script>
        """,
        height=0,
        width=0,
    )

    # ─── Sidebar Controls & History (Left Panel — ChatGPT Theme) ────
    with st.sidebar:
        # 1. Top Brand Logo & Collapse Arrow Button (Unified Flex Header at the very top)
        st.markdown(
            """
            <div class="sidebar-brand-header">
                <div class="sidebar-brand-top">
                    <div class="et-logo-simple">
                        ⚡ <span class="accent">EduTech</span> <span class="badge-ai">AI</span>
                    </div>
                </div>
                <button id="edutech-sb-collapse-btn" class="sidebar-top-collapse-btn" title="Collapse sidebar" type="button">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#E9D5FF" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" style="pointer-events: none;">
                        <polyline points="15 18 9 12 15 6"></polyline>
                    </svg>
                </button>
            </div>
            """,
            unsafe_allow_html=True,
        )

        # 2. ChatGPT-Grade "New Learning Journey" Button with White Edit Icon
        if st.button(
            "New Learning Journey",
            key="sb_new_journey_btn",
            icon=":material/edit_square:",
            type="primary",
            use_container_width=True,
        ):
            st.session_state["memory"] = None
            st.session_state["active_step_index"] = 0
            st.session_state["last_topic"] = None
            st.session_state["submitted_quizzes"] = {}
            if "main_topic_query" in st.session_state:
                del st.session_state["main_topic_query"]
            for k in list(st.session_state.keys()):
                if any(k.startswith(pfx) for pfx in ["step_agents_ran_", "quiz_submitted_", "saved_user_answers_", "saved_user_full_answers_", "xp_awarded_"]):
                    del st.session_state[k]
            st.toast("Ready for a new learning journey! 🚀", icon="✨")
            st.rerun()

        st.markdown("<div style='height: 6px;'></div>", unsafe_allow_html=True)

        # 3. Learning History Header (100% Inline Single HTML Flexbox Container)
        if "history_section_expanded" not in st.session_state:
            st.session_state["history_section_expanded"] = True

        hist_expanded = st.session_state["history_section_expanded"]
        chevron_pts = "6 9 12 15 18 9" if hist_expanded else "9 18 15 12 9 6"

        st.markdown(
            f"""
            <div id="edutech-hist-collapse-header" class="sidebar-section-title clickable-hist-header" title="Toggle Learning History">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#C084FC" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="10"></circle>
                    <polyline points="12 6 12 12 16 14"></polyline>
                </svg>
                <span>Learning History</span>
                <svg class="hist-chevron-arrow" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#C084FC" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                    <polyline points="{chevron_pts}"></polyline>
                </svg>
            </div>
            """,
            unsafe_allow_html=True,
        )

        # Hidden trigger button for Streamlit reactive state rerun
        if st.button("hidden_hist_toggle", key="sb_hist_hidden_toggle_btn"):
            st.session_state["history_section_expanded"] = not hist_expanded
            st.rerun()

        if hist_expanded:
            # 4. Search Bar
            hist_search_val = st.text_input(
                "Search your learning sessions",
                value=st.session_state.get("session_hist_search_val", ""),
                placeholder="🔍 Search history...",
                key="sb_hist_search_input",
                label_visibility="collapsed",
            )
            if hist_search_val != st.session_state.get("session_hist_search_val", ""):
                st.session_state["session_hist_search_val"] = hist_search_val
                st.session_state["session_hist_limit"] = 20

            # 5. Redesigned Modern Filter Pills: All, Active, Completed
            current_flt = st.session_state.get("session_hist_seg_filter", "All")
            flt_col1, flt_col2, flt_col3 = st.columns(3, gap="small")
            with flt_col1:
                is_all = (current_flt == "All")
                all_key = f"sb_flt_{'active_all' if is_all else 'inactive_all'}"
                if st.button("● All", key=all_key, use_container_width=True):
                    if current_flt != "All":
                        st.session_state["session_hist_seg_filter"] = "All"
                        st.session_state["session_hist_limit"] = 20
                        st.rerun()
            with flt_col2:
                is_act = (current_flt == "Active")
                act_key = f"sb_flt_{'active_act' if is_act else 'inactive_act'}"
                if st.button("⚡ Active", key=act_key, use_container_width=True):
                    if current_flt != "Active":
                        st.session_state["session_hist_seg_filter"] = "Active"
                        st.session_state["session_hist_limit"] = 20
                        st.rerun()
            with flt_col3:
                is_comp = (current_flt == "Completed")
                comp_key = f"sb_flt_{'active_comp' if is_comp else 'inactive_comp'}"
                if st.button("✓ Completed", key=comp_key, use_container_width=True):
                    if current_flt != "Completed":
                        st.session_state["session_hist_seg_filter"] = "Completed"
                        st.session_state["session_hist_limit"] = 20
                        st.rerun()

            filter_map = {
                "All": "all",
                "Active": "in_progress",
                "Completed": "completed",
            }
            current_filter = filter_map.get(current_flt, "all")

            hist_limit = st.session_state.get("session_hist_limit", 20)

            # Query User Sessions from Database
            user_sessions = []
            total_sessions = 0
            try:
                from models.user_schemas import SearchDTO
                from services.session_manager import SessionManager

                s_dto = SearchDTO(
                    page=0,
                    size=hist_limit,
                    sortBy="updated_at",
                    isDesc=True,
                    lookupText=hist_search_val.strip() if hist_search_val and hist_search_val.strip() else None,
                )
                user_sessions, total_sessions = run_async(
                    SessionManager().search_user_sessions(
                        user_id=user_profile.id,
                        dto=s_dto,
                        status_filter=current_filter,
                    )
                )
            except Exception as ex_sh:
                logging.warning(f"Failed to query user session history: {ex_sh}")

            st.markdown(
                f"<div style='font-size: 0.72rem; color: rgba(233,213,255,0.65); margin: 3px 0 15px 0;'><b>{len(user_sessions)}</b> of <b>{total_sessions}</b> session(s)</div>",
                unsafe_allow_html=True,
            )

            active_mem = st.session_state.get("memory")
            active_session_id = active_mem.session_id if active_mem else None

            if not user_sessions:
                st.markdown(
                    "<div style='background: rgba(168,85,247,0.06); border: 1px dashed rgba(168,85,247,0.25); border-radius: 10px; padding: 12px; text-align: center; font-size: 0.76rem; color: rgba(255,255,255,0.6);'>No sessions match. Start a new topic!</div>",
                    unsafe_allow_html=True,
                )
            else:
                with st.container():
                    st.markdown("<div class='sb-hist-container-marker' style='display:none;'></div>", unsafe_allow_html=True)
                    for s_info in user_sessions:
                        s_id = s_info["session_id"]
                        s_topic = s_info["topic"]
                        s_complete = s_info["is_complete"]
                        s_tot_steps = s_info.get("total_steps", 0)
                        s_cur_step = s_info.get("current_step_index", 0)
                        s_xp = s_info.get("xp_earned", 0)
                        is_active_session = (active_session_id == s_id)

                        status_tag = "Completed" if s_complete else f"Step {min(s_cur_step + 1, s_tot_steps)}/{s_tot_steps}"
                        btn_display = s_topic

                        card_cols = st.columns([9.0, 1.0], gap="small", vertical_alignment="center")
                        with card_cols[0]:
                            if st.button(
                                btn_display,
                                key=f"sb_card_{s_id}",
                                type="primary" if is_active_session else "secondary",
                                use_container_width=True,
                            ):
                                with st.spinner("Opening session..."):
                                    loaded = run_async(SessionManager().get_session(s_id))
                                    if loaded:
                                        for k in list(st.session_state.keys()):
                                            if any(k.startswith(pfx) for pfx in ["step_agents_ran_", "quiz_submitted_", "saved_user_answers_", "saved_user_full_answers_", "xp_awarded_"]):
                                                del st.session_state[k]

                                        for idx_st, st_ob in enumerate(loaded.steps):
                                            has_step_content = bool(
                                                getattr(st_ob, "tutor_explanation", None)
                                                or getattr(st_ob, "quiz", None)
                                                or getattr(st_ob, "videos", None)
                                                or getattr(st_ob, "papers", None)
                                                or getattr(st_ob, "status", None) == StepStatus.COMPLETE
                                            )
                                            if has_step_content:
                                                setattr(st_ob, "_agent_generated", True)
                                                st.session_state[f"step_agents_ran_{idx_st}"] = True

                                        st.session_state["memory"] = loaded
                                        target_idx = 0
                                        for idx_s, step_obj in enumerate(loaded.steps):
                                            if step_obj.status != StepStatus.COMPLETE:
                                                target_idx = idx_s
                                                break
                                        st.session_state["active_step_index"] = target_idx
                                        st.session_state["last_topic"] = loaded.topic
                                        st.rerun()

                        with card_cols[1]:
                            with st.popover("", icon=":material/more_horiz:", use_container_width=True):
                                st.markdown(f"<div style='font-size:0.82rem; font-weight:700; color:#FAFAFA; margin-bottom:4px;'>{s_topic[:26]}...</div>", unsafe_allow_html=True)
                                st.markdown(f"<div style='font-size:0.75rem; color:#A855F7; margin-bottom:8px;'>Status: <b>{status_tag}</b> • <b>+{s_xp} XP</b></div>", unsafe_allow_html=True)
                                if st.button("🗑️ Delete Session", key=f"sb_del_pop_{s_id}", type="primary", use_container_width=True):
                                    run_async(SessionManager().delete_session(s_id, user_id=user_profile.id))
                                    if active_session_id == s_id:
                                        st.session_state["memory"] = None
                                        st.session_state["active_step_index"] = 0
                                    st.toast("Session deleted.", icon="🗑️")
                                    st.rerun()

                # Progressive Loading "Load More" Button
                if total_sessions > len(user_sessions):
                    if st.button(f"↓ Load More ({len(user_sessions)} of {total_sessions})", key="sb_load_more_btn", use_container_width=True):
                        st.session_state["session_hist_limit"] = hist_limit + 20
                        st.rerun()

        # ─── Sidebar Bottom Footer: User Profile & Settings ───────────────────
        st.markdown("<div class='sidebar-user-footer-divider'></div>", unsafe_allow_html=True)

        prof_cols = st.columns([7.8, 2.2], gap="small", vertical_alignment="center")
        with prof_cols[0]:
            user_display_name = f"{user_profile.first_name or ''} {user_profile.last_name or ''}".strip() or "Student"
            u_tier = (user_profile.subscription.tier if user_profile.subscription else "normal").upper()
            truncated_name = (user_display_name[:18] + "...") if len(user_display_name) > 18 else user_display_name

            st.markdown(
                f"""
                <div class="user-profile-bottom-card" title="{html.escape(user_display_name)} ({u_tier})">
                    <div class="user-avatar-pill">&#128100;</div>
                    <div class="user-info-text">
                        <div class="user-name-title">{html.escape(truncated_name)}</div>
                        <div class="user-tier-subtitle">{u_tier} TIER</div>
                    </div>
                </div>
                """,
                unsafe_allow_html=True,
            )

        with prof_cols[1]:
            st.markdown("<div class='st-key-sb_settings_popover_btn'>", unsafe_allow_html=True)
            with st.popover("", icon=":material/settings:", use_container_width=True):
                st.markdown(
                    f"""
                    <div style="text-align: center; padding: 6px 0 10px 0;">
                        <div style="font-size: 2.2rem; margin-bottom: 4px;">&#128100;</div>
                        <div style="font-weight: 800; font-size: 1.05rem; color: #FAFAFA;">{html.escape(user_display_name)}</div>
                        <div style="font-size: 0.8rem; color: rgba(233, 213, 255, 0.7); margin-bottom: 8px;">{html.escape(user_profile.email if hasattr(user_profile, 'email') and user_profile.email else 'Student')}</div>
                        <div style="display: inline-block; background: rgba(168, 85, 247, 0.25); border: 1px solid rgba(168, 85, 247, 0.5); border-radius: 20px; padding: 2px 12px; font-size: 0.75rem; font-weight: 800; color: #C084FC; text-transform: uppercase;">
                            {u_tier} Tier
                        </div>
                    </div>
                    """,
                    unsafe_allow_html=True,
                )

                if u_tier != "ULTRA":
                    upgrade_target = "ultra" if u_tier == "PRO" else "pro"
                    if st.button(f"⚡ Upgrade to {upgrade_target.upper()}", key="sb_pop_upgrade_btn", type="primary", use_container_width=True):
                        st.session_state["show_billing_portal_modal"] = False
                        st.session_state["target_upgrade_tier"] = upgrade_target
                        st.session_state["show_upgrade_modal"] = True
                        st.rerun()

                if st.button("💳 Billing & Plan", key="sb_pop_billing_btn", use_container_width=True):
                    st.session_state["show_upgrade_modal"] = False
                    st.session_state["show_billing_portal_modal"] = True
                    st.rerun()

                if st.button("⚙️ Admin Console", key="sb_pop_admin_btn", use_container_width=True):
                    st.session_state["show_upgrade_modal"] = False
                    st.session_state["show_billing_portal_modal"] = False
                    st.session_state["view"] = "admin"
                    st.rerun()

                st.markdown("<hr style='border-color:rgba(168,85,247,0.25); margin:8px 0;'>", unsafe_allow_html=True)

                if st.button("⏻ Sign Out", key="sb_pop_logout_btn", type="primary", use_container_width=True):
                    st.session_state["user_profile"] = None
                    st.session_state["memory"] = None
                    st.session_state["active_step_index"] = 0
                    st.session_state["last_topic"] = None
                    st.session_state["show_upgrade_modal"] = False
                    st.session_state["show_billing_portal_modal"] = False
                    if "target_upgrade_tier" in st.session_state:
                        del st.session_state["target_upgrade_tier"]
                    if "quick_launch_topic" in st.session_state:
                        del st.session_state["quick_launch_topic"]
                    for k in list(st.session_state.keys()):
                        if any(
                            k.startswith(pfx)
                            for pfx in [
                                "step_agents_ran_",
                                "quiz_submitted_",
                                "saved_user_answers_",
                                "saved_user_full_answers_",
                                "xp_awarded_",
                                "show_victory_modal_",
                                "victory_modal_dismissed_",
                                "session_hist_",
                            ]
                        ):
                            del st.session_state[k]
                    st.session_state["view"] = "home"
                    st.query_params.clear()
                    st.toast("Logged out successfully.", icon="ℹ️")
                    st.rerun()
            st.markdown("</div>", unsafe_allow_html=True)

    memory = get_or_create_memory()

    # ─── Main Content Workspace ──────────────────────────────────────
    if not memory or not memory.steps:
        # Centered Hero Section (Matching Home Page Typography & Gradient Text)
        st.markdown(
            """
            <div class="et-hero">
                <h1>EduTechAI <span class="gradient-text">Learning Workspace</span></h1>
                <p>An adaptive, intelligent learning studio where specialized AI agents orchestrate personalized roadmaps, intuitive analogies, video deep-dives, and instant mastery checks.</p>
            </div>
            """,
            unsafe_allow_html=True,
        )

        # Quick In-Progress Session Resume Card (if user has active topics in DB)
        try:
            from models.user_schemas import SearchDTO
            from services.session_manager import SessionManager
            ip_dto = SearchDTO(page=0, size=3, sortBy="updated_at", isDesc=True)
            ip_sessions, _ = run_async(SessionManager().search_user_sessions(user_profile.id, ip_dto, status_filter="in_progress"))
            if ip_sessions:
                st.markdown("### ⚡ **Continue Your Recent Active Journeys**")
                ip_cols = st.columns(min(len(ip_sessions), 3))
                for idx_ip, sess_ip in enumerate(ip_sessions[:3]):
                    with ip_cols[idx_ip]:
                        s_id = sess_ip["session_id"]
                        s_top = sess_ip["topic"]
                        s_cur = sess_ip.get("current_step_index", 0)
                        s_tot = sess_ip.get("total_steps", 0)
                        s_xp = sess_ip.get("xp_earned", 0)
                        s_pct = (s_cur / s_tot * 100) if s_tot else 0

                        esc_top = html.escape(s_top)
                        st.markdown(
                            f"""
                            <div class="aj-card-marker"></div>
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                                <span style="background: rgba(168, 85, 247, 0.25); color: #C084FC; border: 1px solid rgba(168, 85, 247, 0.5); font-size: 0.72rem; font-weight: 800; padding: 2px 8px; border-radius: 9999px;">Step {min(s_cur+1, s_tot)}/{s_tot}</span>
                                <span style="font-size: 0.75rem; color: #38BDF8; font-weight: 700;">+{s_xp} XP</span>
                            </div>
                            <div class="aj-topic-title" title="{esc_top}">{esc_top}</div>
                            <div class="custom-progress-track" style="height: 6px; margin-bottom: 12px;">
                                <div class="custom-progress-fill" style="width: {s_pct:.0f}%;"></div>
                            </div>
                            """,
                            unsafe_allow_html=True,
                        )
                        if st.button("Resume →", key=f"main_res_{s_id}", type="primary", use_container_width=True):
                            with st.spinner("Resuming learning session..."):
                                loaded = run_async(SessionManager().get_session(s_id))
                                if loaded:
                                    for k in list(st.session_state.keys()):
                                        if any(k.startswith(pfx) for pfx in ["step_agents_ran_", "quiz_submitted_", "saved_user_answers_", "saved_user_full_answers_", "xp_awarded_"]):
                                            del st.session_state[k]

                                    for idx_st, st_ob in enumerate(loaded.steps):
                                        has_step_content = bool(
                                            getattr(st_ob, "tutor_explanation", None)
                                            or getattr(st_ob, "quiz", None)
                                            or getattr(st_ob, "videos", None)
                                            or getattr(st_ob, "papers", None)
                                            or getattr(st_ob, "status", None) == StepStatus.COMPLETE
                                        )
                                        if has_step_content:
                                            setattr(st_ob, "_agent_generated", True)
                                            st.session_state[f"step_agents_ran_{idx_st}"] = True

                                    st.session_state["memory"] = loaded
                                    target_idx = 0
                                    for i_st, st_ob in enumerate(loaded.steps):
                                        if st_ob.status != StepStatus.COMPLETE:
                                            target_idx = i_st
                                            break
                                    st.session_state["active_step_index"] = target_idx
                                    st.session_state["last_topic"] = loaded.topic
                                    st.rerun()
                st.markdown("<br>", unsafe_allow_html=True)
        except Exception as ex_ip:
            logging.debug(f"Notice: Could not load quick resume cards: {ex_ip}")
        

        # ─── Main Page: Centered Heading ("What do you want to learn today?") ───
        st.markdown(
            """
            <div class="et-hero" style="margin-top: 2rem; margin-bottom: 1.2rem;">
                <h1>What do you want to <span class="gradient-text">learn today?</span></h1>
                <p>Decompose any concept into adaptive milestones, interactive Socratic lessons, and academic research.</p>
            </div>
            """,
            unsafe_allow_html=True,
        )


        if "quick_launch_topic" in st.session_state:
            st.session_state["main_topic_input_composer"] = st.session_state.pop("quick_launch_topic")
        elif "main_topic_query" in st.session_state:
            st.session_state["main_topic_input_composer"] = st.session_state.pop("main_topic_query")

        # Centered ChatGPT-Style Layout with Balanced Left/Right Margins
        pad_l, card_col, pad_r = st.columns([0.8, 8.4, 0.8])
        with card_col:
            st.markdown('<div id="journey-console-card-marker" class="et-journey-card-container-marker"></div>', unsafe_allow_html=True)

            # 1. Dropdowns: Mode (Left) and Education Level (Right) placed ABOVE the chat prompt
            drop_col1, drop_col2 = st.columns(2)
            with drop_col1:
                mode_choice = st.selectbox(
                    "**🎨 Learning Mode**",
                    options=["Visual 🎬", "Deep Dive 🔬", "Bite-Sized ⚡"],
                    index=0,
                    key="main_mode_select",
                    help="Visual: video & diagrams | Deep Dive: papers & proofs | Bite-Sized: quick summaries",
                )
                mode_map = {
                    "Visual 🎬": LearningMode.VISUAL,
                    "Deep Dive 🔬": LearningMode.DEEP_DIVE,
                    "Bite-Sized ⚡": LearningMode.BITE_SIZED,
                }
                selected_mode = mode_map[mode_choice]

            with drop_col2:
                level_choice = st.selectbox(
                    "**🎓 Education Level**",
                    options=["Middle School 🏫", "High School 🎒", "Undergraduate 🏛️", "Graduate 🎓", "General Curious 💡"],
                    index=0,
                    key="main_level_select",
                )
                level_map = {
                    "Middle School 🏫": "middle_school",
                    "High School 🎒": "high_school",
                    "Undergraduate 🏛️": "undergraduate",
                    "Graduate 🎓": "graduate",
                    "General Curious 💡": "general",
                }
                selected_level = level_map[level_choice]

            # 2. Gemini Style Search Prompt Form with Input + ✨ Start Journey Button
            with st.form(key="main_journey_launch_form", clear_on_submit=False, border=False):
                st.markdown('<div class="et-gemini-prompt-form-marker"></div>', unsafe_allow_html=True)

                c_input, c_btn = st.columns([4.8, 1.4], vertical_alignment="center")
                with c_input:
                    main_topic_input = st.text_input(
                        "What do you want to learn?",
                        placeholder="Ask EduTechAI anything... (e.g., I want to learn Python programming from zero)",
                        key="main_topic_input_composer",
                        label_visibility="collapsed",
                    )
                with c_btn:
                    main_start_clicked = st.form_submit_button("✨ Start Journey", type="primary", use_container_width=True)

            # 3. Space-Efficient Suggested Topics Popover Drawer (Instant Client-Side Fill, Zero Page Reload)
            with st.popover("💡 Browse Suggested Topics", use_container_width=False):
                st.markdown("<div style='font-size:0.88rem; font-weight:700; color:#E9D5FF; margin-bottom:4px;'>🌟 Curated Learning Prompts</div>", unsafe_allow_html=True)
                
                topics_html = """
                <style>
                    body {
                        margin: 0;
                        padding: 0;
                        background: transparent;
                        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
                        overflow: hidden;
                    }
                    .topic-list {
                        display: flex;
                        flex-direction: column;
                        gap: 8px;
                        padding: 4px 6px 4px 2px;
                        max-height: 240px;
                        overflow-y: auto;
                        overflow-x: hidden;
                        scrollbar-width: thin;
                        scrollbar-color: rgba(168, 85, 247, 0.45) transparent;
                        box-sizing: border-box;
                    }
                    .topic-list::-webkit-scrollbar {
                        width: 6px;
                    }
                    .topic-list::-webkit-scrollbar-track {
                        background: rgba(15, 23, 42, 0.4);
                        border-radius: 4px;
                    }
                    .topic-list::-webkit-scrollbar-thumb {
                        background: rgba(168, 85, 247, 0.45);
                        border-radius: 4px;
                    }
                    .topic-list::-webkit-scrollbar-thumb:hover {
                        background: rgba(168, 85, 247, 0.75);
                    }
                    .topic-item {
                        display: flex;
                        align-items: center;
                        background: rgba(168, 85, 247, 0.1);
                        border: 1px solid rgba(168, 85, 247, 0.28);
                        border-radius: 10px;
                        color: #FAFAFA;
                        font-size: 0.88rem;
                        font-weight: 500;
                        padding: 10px 14px;
                        cursor: pointer;
                        text-align: left;
                        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
                        outline: none;
                        width: 100%;
                        box-sizing: border-box;
                    }
                    .topic-item:hover {
                        background: rgba(168, 85, 247, 0.26);
                        border-color: #C084FC;
                        border-left: 3px solid #C084FC;
                        padding-left: 18px;
                        color: #FFFFFF;
                        box-shadow: 0 4px 15px rgba(168, 85, 247, 0.35);
                        transform: translateX(2px);
                    }
                </style>
                <div class="topic-list">
                    <button class="topic-item" onclick="selectTopic('I want to learn Python programming from zero step by step')">
                        🐍 I want to learn Python programming from zero
                    </button>
                    <button class="topic-item" onclick="selectTopic('How do Deep Neural Networks and Machine Learning models learn?')">
                        🧠 Explain Deep Neural Networks and Machine Learning
                    </button>
                    <button class="topic-item" onclick="selectTopic('Intuitive guide to Calculus, Derivatives, and Differential Equations')">
                        📐 Intuitive guide to Calculus & Differential Equations
                    </button>
                    <button class="topic-item" onclick="selectTopic('How does CRISPR-Cas9 Gene Editing and DNA repair work?')">
                        🧬 How CRISPR-Cas9 Gene Editing works
                    </button>
                    <button class="topic-item" onclick="selectTopic('How do chemical bonds, covalent and ionic molecular orbitals work?')">
                        ⚗️ Chemical Bonding: Covalent vs Ionic Orbitals
                    </button>
                </div>
                <script>
                function selectTopic(text) {
                    try {
                        const pdoc = window.parent.document;
                        const input = pdoc.querySelector('input[placeholder*="Ask EduTechAI"]') 
                                   || pdoc.querySelector('div[data-testid="stColumn"]:has(#journey-console-card-marker) input')
                                   || pdoc.querySelector('input[aria-label="What do you want to learn?"]');
                        if (input) {
                            const nativeSetter = Object.getOwnPropertyDescriptor(window.parent.HTMLInputElement.prototype, 'value').set;
                            if (nativeSetter) {
                                nativeSetter.call(input, text);
                            } else {
                                input.value = text;
                            }
                            input.dispatchEvent(new Event('input', { bubbles: true }));
                            input.dispatchEvent(new Event('change', { bubbles: true }));
                            input.focus();
                        }
                        // Close popover
                        pdoc.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', keyCode: 27, which: 27, bubbles: true }));
                        const popBtn = pdoc.querySelector('div[data-testid="stColumn"]:has(#journey-console-card-marker) div[data-testid="stPopover"] button');
                        if (popBtn) {
                            popBtn.click();
                        }
                    } catch (e) {
                        console.error("Topic select error:", e);
                    }
                }
                </script>
                """
                components.html(topics_html, height=250, scrolling=False)

        if main_start_clicked and main_topic_input.strip():
            st.session_state["last_topic"] = main_topic_input.strip()
            if "main_topic_query" in st.session_state:
                del st.session_state["main_topic_query"]

            loader_placeholder = st.empty()

            # Step 1: Orchestrator Agent decomposing topic into milestone steps
            loader_placeholder.markdown(
                render_glassy_agent_loader_html(
                    title=f"Decomposing '{main_topic_input.strip()}'",
                    subtitle="🧠 Orchestrator Agent is analyzing domain knowledge & mapping milestone roadmap...",
                    orchestrator_status="active",
                    socratic_status="waiting",
                    youtube_status="waiting",
                    academic_status="waiting",
                    quiz_status="waiting",
                    progress_percent=25,
                ),
                unsafe_allow_html=True,
            )

            # Initialize SharedMemory with user_id
            new_memory = SharedMemory(
                user_id=user_profile.id,
                topic=main_topic_input.strip(),
                learning_mode=selected_mode,
                student_level=selected_level,
            )

            # Run Orchestrator Agent
            orchestrator = OrchestratorAgent()
            run_async(orchestrator.execute(new_memory))

            if new_memory.steps:
                new_memory.steps[0].status = StepStatus.IN_PROGRESS
                # Step 2: Multi-Agent System collaborating on Step 1 content
                loader_placeholder.markdown(
                    render_glassy_agent_loader_html(
                        title=f"Synthesizing Step 1: {new_memory.steps[0].title}",
                        subtitle="🤖 Multi-Agents (Socratic, YouTube, Academic, Quiz) generating step 1 content concurrently...",
                        orchestrator_status="completed",
                        socratic_status="active",
                        youtube_status="active",
                        academic_status="active",
                        quiz_status="active",
                        progress_percent=70,
                    ),
                    unsafe_allow_html=True,
                )
                run_async(generate_all_agent_content_for_step(new_memory.steps[0], new_memory))

            loader_placeholder.markdown(
                render_glassy_agent_loader_html(
                    title="Finalizing Learning Workspace",
                    subtitle="✨ Persisting session memory & loading interactive workspace...",
                    orchestrator_status="completed",
                    socratic_status="completed",
                    youtube_status="completed",
                    academic_status="completed",
                    quiz_status="completed",
                    progress_percent=100,
                ),
                unsafe_allow_html=True,
            )
            time.sleep(0.5)
            loader_placeholder.empty()

            # Persist session to PostgreSQL database linked to current user
            try:
                from services.session_manager import SessionManager
                run_async(SessionManager().create_session(new_memory, user_id=user_profile.id))
            except Exception as e:
                logging.warning(f"Could not persist session to database: {e}")

            st.session_state["memory"] = new_memory
            st.session_state["active_step_index"] = 0
            st.session_state["submitted_quizzes"] = {}
            st.rerun()
        elif main_start_clicked and not main_topic_input.strip():
            st.toast("Please enter a topic to start your learning journey! 💡", icon="⚠️")

    else:
        # Active Session Workspace Body (Header already rendered above)
        
        # ─── Top Progress & Gamification Header Dashboard ──────────────
        total_xp = memory.xp_earned if memory else 0
        level_data = calculate_level(total_xp)
        completed_steps = sum(1 for s in memory.steps if s.status == StepStatus.COMPLETE)
        total_steps = len(memory.steps)

        formatted_mode = format_display_text(memory.learning_mode)
        formatted_audience = format_display_text(memory.student_level)
        mode_icon = get_mode_icon(memory.learning_mode)
        audience_icon = get_audience_icon(memory.student_level)

        st.markdown(
            f"""
            <div class="top-progress-card">
                <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px;">
                    <div style="display: flex; align-items: center; gap: 12px;">
                        <div style="background: linear-gradient(135deg, #EC4899 0%, #A855F7 100%); padding: 9px 13px; border-radius: 14px; font-size: 1.2rem; box-shadow: 0 4px 15px rgba(236, 72, 153, 0.4);">🏆</div>
                        <div>
                            <div style="font-weight: 900; font-size: 1.2rem; color: #FAFAFA; letter-spacing: 0.3px;">Your Mastery Dashboard</div>
                            <div style="font-size: 0.8rem; color: rgba(233, 213, 255, 0.75);">Real-time learning milestone progress & XP rewards</div>
                        </div>
                    </div>
                    <div style="display: flex; align-items: center; gap: 12px; flex-wrap: wrap;">
                        <div class="pill-capsule pill-mode">
                            <span class="pill-label">Mode</span>
                            <span class="pill-icon-box">{mode_icon}</span>
                            <span class="pill-value">{formatted_mode}</span>
                        </div>
                        <div class="pill-capsule pill-audience">
                            <span class="pill-label">Audience</span>
                            <span class="pill-icon-box">{audience_icon}</span>
                            <span class="pill-value">{formatted_audience}</span>
                        </div>
                    </div>
                </div>
            </div>
            """,
            unsafe_allow_html=True,
        )

        prog_col1, prog_col2, prog_col3, prog_col4 = st.columns([1.2, 1.2, 1.8, 1.8])
        with prog_col1:
            st.markdown(
                f"""
                <div class="glass-card" style="margin-bottom:0; text-align:center; padding: 0.85rem 0.6rem;">
                    <div class="top-progress-label">Current Level</div>
                    <div class="top-progress-stat">Lvl {level_data['level']}</div>
                    <div style="font-size:0.78rem; color:#C084FC; font-weight:800; margin-top:2px;">{level_data['title']}</div>
                </div>
                """,
                unsafe_allow_html=True,
            )

        with prog_col2:
            st.markdown(
                f"""
                <div class="glass-card" style="margin-bottom:0; text-align:center; padding: 0.85rem 0.6rem;">
                    <div class="top-progress-label">Total XP Earned</div>
                    <div class="top-progress-stat">⭐ {total_xp}</div>
                    <div style="font-size:0.78rem; color:#38BDF8; font-weight:800; margin-top:2px;">Streak: {memory.streak_count} 🔥</div>
                </div>
                """,
                unsafe_allow_html=True,
            )

        with prog_col3:
            lvl_pct = min(1.0, max(0.0, float(level_data.get("progress", 0.0))))
            st.markdown(
                f"""
                <div class="glass-card" style="margin-bottom:0; padding: 0.85rem 0.9rem; display:flex; flex-direction:column; justify-content:space-between; height:100%;">
                    <div>
                        <div class="top-progress-label">Level Progress (Lvl {level_data['level']} → {level_data['level']+1})</div>
                        <div style="font-size:0.85rem; color:#F1F5F9; font-weight:700; margin-bottom:6px;">{total_xp} / {level_data['xp_for_next_level']} XP <span style="font-size:0.75rem; color:#94A3B8;">({level_data['xp_in_level']}/{level_data['xp_needed_for_next']} in Lvl)</span></div>
                    </div>
                    <div class="custom-progress-track">
                        <div class="custom-progress-fill" style="width: {lvl_pct*100:.1f}%;"></div>
                    </div>
                </div>
                """,
                unsafe_allow_html=True,
            )

        with prog_col4:
            topic_pct = (completed_steps / total_steps) if total_steps else 0.0
            st.markdown(
                f"""
                <div class="glass-card" style="margin-bottom:0; padding: 0.85rem 0.9rem; display:flex; flex-direction:column; justify-content:space-between; height:100%;">
                    <div>
                        <div class="top-progress-label">Topic Completion</div>
                        <div style="font-size:0.85rem; color:#F1F5F9; font-weight:700; margin-bottom:6px;">{completed_steps} of {total_steps} Steps ({topic_pct:.0%})</div>
                    </div>
                    <div class="custom-progress-track">
                        <div class="custom-progress-fill" style="width: {topic_pct*100:.1f}%;"></div>
                    </div>
                </div>
                """,
                unsafe_allow_html=True,
            )

        st.markdown("<br>", unsafe_allow_html=True)

        # Check active index
        active_idx = st.session_state.get("active_step_index", 0)
        if active_idx >= len(memory.steps):
            active_idx = 0
        num_steps = len(memory.steps)

        # ─── Linear Milestone Learning Roadmap Stepper ───────────────
        st.markdown(
            f"""
            <div style="display: flex; align-items: center; gap: 10px; flex-wrap: wrap; margin-bottom: 12px;">
                <span style="font-size: 1.3rem; font-weight: 800; color: #FAFAFA; letter-spacing: 0.2px;">🗺️ Milestone Learning Roadmap</span>
                <span style="background: linear-gradient(135deg, rgba(236, 72, 153, 0.15) 0%, rgba(168, 85, 247, 0.2) 100%); border: 1px solid rgba(168, 85, 247, 0.4); padding: 4px 14px; border-radius: 9999px; font-size: 0.9rem; font-weight: 700; color: #F1F5F9; box-shadow: 0 2px 10px rgba(168, 85, 247, 0.15);">
                    🎯 <span style="color: #A78BFA;">Inquiry:</span> {memory.topic}
                </span>
            </div>
            """,
            unsafe_allow_html=True,
        )
        step_cols = st.columns(num_steps)

        for i, s in enumerate(memory.steps):
            with step_cols[i]:
                is_active = (i == active_idx)
                is_complete = (s.status == StepStatus.COMPLETE)
                is_in_progress = (s.status == StepStatus.IN_PROGRESS or is_active)

                if is_complete:
                    status_icon = "✅"
                elif is_active:
                    status_icon = "🔵"
                elif is_in_progress:
                    status_icon = "⚡"
                else:
                    status_icon = "🔒"

                can_click = (i == 0 or is_complete or is_active or is_in_progress or (i > 0 and memory.steps[i-1].status == StepStatus.COMPLETE))
                
                short_title = (s.title[:18] + "...") if len(s.title) > 18 else s.title
                btn_label = f"{status_icon} Step {i+1}\n{short_title}"

                if st.button(
                    btn_label,
                    key=f"linear_step_btn_{i}",
                    type="primary" if is_active else "secondary",
                    disabled=not can_click,
                    use_container_width=True,
                    help=f"Step {i+1}: {s.title} ({s.status.value.replace('_', ' ').title()})"
                ):
                    st.session_state["active_step_index"] = i
                    st.rerun()

        # Overall Linear Progress Bar (Single Unified Progress Bar)
        roadmap_pct = (completed_steps / total_steps) if total_steps else 0.0
        st.markdown(
            f"""
            <div style="margin-top: 10px;">
                <div class="custom-progress-track" style="height: 9px;">
                    <div class="custom-progress-fill" style="width: {roadmap_pct*100:.1f}%;"></div>
                </div>
            </div>
            """,
            unsafe_allow_html=True,
        )

        current_step = memory.steps[active_idx]
        if current_step.status == StepStatus.PENDING:
            current_step.status = StepStatus.IN_PROGRESS

        # Auto-trigger Multi-Agent Execution once per step (skipped if content already exists from history)
        agents_ran_key = f"step_agents_ran_{active_idx}"
        has_existing_content = bool(
            getattr(current_step, "tutor_explanation", None) 
            or getattr(current_step, "quiz", None) 
            or getattr(current_step, "videos", None) 
            or getattr(current_step, "papers", None)
            or getattr(current_step, "status", None) == StepStatus.COMPLETE
        )
        is_already_generated = (
            getattr(current_step, "_agent_generated", False) 
            or st.session_state.get(agents_ran_key, False)
            or has_existing_content
        )

        if not is_already_generated:
            st.session_state[agents_ran_key] = True
            setattr(current_step, "_agent_generated", True)
            loader_placeholder = st.empty()
            loader_placeholder.markdown(
                render_glassy_agent_loader_html(
                    title=f"Collaborating on Step {active_idx+1}: {current_step.title}",
                    subtitle="🧩 Multi-Agent System (Socratic, YouTube, Academic, Quiz) generating step content...",
                    orchestrator_status="completed",
                    socratic_status="active",
                    youtube_status="active",
                    academic_status="active",
                    quiz_status="active",
                    progress_percent=75,
                ),
                unsafe_allow_html=True,
            )
            run_async(generate_all_agent_content_for_step(current_step, memory))
            loader_placeholder.empty()
            st.rerun()

        st.markdown("<br>", unsafe_allow_html=True)

        # Display Step Details Header
        formatted_status = format_display_text(current_step.status)
        if current_step.status == StepStatus.COMPLETE:
            status_class = "complete"
            status_icon = "✅"
        elif current_step.status == StepStatus.IN_PROGRESS:
            status_class = "inprogress"
            status_icon = "⚡"
        else:
            status_class = "pending"
            status_icon = "🔒"

        prereq_val = getattr(current_step, "prerequisite", None)
        prereq_badge_html = ""
        if prereq_val:
            prereq_badge_html = f'<span class="prereq-badge">Prereq: {prereq_val}</span>'
        elif getattr(current_step, "is_prerequisite", False):
            prereq_badge_html = '<span class="prereq-badge">Prerequisite Step</span>'

        # Row 1: Milestone & Prerequisite badges on left, Regenerate pill on top right
        col_meta_left, col_meta_right = st.columns([7.2, 2.8], vertical_alignment="center")
        with col_meta_left:
            st.markdown(
                f"""
                <div class="milestone-badge-row" style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap; height: 26px;">
                    <span class="milestone-badge">Milestone {active_idx+1} of {num_steps}</span>
                    {prereq_badge_html}
                </div>
                """,
                unsafe_allow_html=True,
            )
        with col_meta_right:
            if st.button(
                "↻ Regenerate",
                key=f"regen_btn_{active_idx}",
                type="primary",
                help=f"Regenerate Step {active_idx + 1} content",
            ):
                setattr(current_step, "tutor_explanation", None)
                setattr(current_step, "videos", [])
                setattr(current_step, "papers", [])
                setattr(current_step, "quiz", [])
                st.session_state[f"step_agents_ran_{active_idx}"] = False
                setattr(current_step, "_agent_generated", False)
                st.rerun()

        # Row 2 & 3: Step Title with Status Pill right after it, followed by description
        st.markdown(
            f"""
            <div style="display: flex; align-items: center; gap: 10px; flex-wrap: wrap; margin: 4px 0 4px 0;">
                <h2 style="font-size: 1.45rem; font-weight: 800; color: #F8FAFC; margin: 0; line-height: 1.25;">{current_step.title}</h2>
                <span class="compact-status-pill compact-status-{status_class}">
                    {status_icon} {formatted_status}
                </span>
            </div>
            <div style="font-size: 0.9rem; color: #94A3B8; font-style: italic; margin-top: 2px;">{current_step.description}</div>
            """,
            unsafe_allow_html=True,
        )

        st.markdown("---")

        # ─── 2-COLUMN UNIFIED WORKSPACE LAYOUT ───────────────────────────
        col_left, col_right = st.columns([1.1, 0.9])

        # ─── LEFT COLUMN: Socratic Tutor & Milestone Quiz ─────────────────
        with col_left:
            # 1. 🧩 Socratic Tutor Chat Interface
            with st.expander("🧩 **Socratic Tutor Chat**", expanded=True):
                tutor_exp = getattr(current_step, "tutor_explanation", None)
                
                # Render initial Socratic Explanation as Assistant Chat Message
                if tutor_exp:
                    with st.chat_message("assistant", avatar="🧩"):
                        st.markdown(tutor_exp)
                else:
                    st.info("Socratic Tutor Agent is preparing the explanation...")

                # Render subsequent Q&A discussion thread as Chat Messages
                chat_thread = st.session_state.get(f"tutor_chat_{active_idx}", [])
                for turn in chat_thread:
                    if turn["role"] == "user":
                        with st.chat_message("user", avatar="🧑‍🎓"):
                            st.markdown(turn["text"])
                    else:
                        with st.chat_message("assistant", avatar="🧩"):
                            st.markdown(turn["text"])

                st.markdown("<br>", unsafe_allow_html=True)

                # Suggested Socratic Questions Chips
                socratic_qs = (
                    get_item_attr(current_step, "socratic_questions", [])
                    or st.session_state.get(f"socratic_qs_{active_idx}", [])
                    or [
                        f"Can you explain this step with a real-world analogy?",
                        f"Why is this step crucial for understanding {memory.topic}?",
                    ]
                )

                st.markdown("<small>💡 **Suggested Questions for Socratic Tutor:**</small>", unsafe_allow_html=True)
                q_cols = st.columns(min(len(socratic_qs[:2]), 2))
                triggered_q = None

                for q_i, sug_q in enumerate(socratic_qs[:2]):
                    with q_cols[q_i]:
                        if st.button(f"💬 {sug_q}", key=f"sug_q_{active_idx}_{q_i}", use_container_width=True):
                            triggered_q = sug_q

                # Socratic Follow-Up Chat Input Row
                with st.form(key=f"tutor_chat_form_{active_idx}", clear_on_submit=True, border=False):
                    c_in, c_btn = st.columns([4.2, 1.2], vertical_alignment="center")
                    with c_in:
                        user_prompt = st.text_input(
                            "Ask Socratic Tutor...",
                            key=f"chat_in_{active_idx}",
                            placeholder="Ask Socratic Tutor a follow-up question or for an analogy...",
                            label_visibility="collapsed",
                        )
                    with c_btn:
                        send_chat = st.form_submit_button("Ask Tutor ✨", type="primary", use_container_width=True)

                question_to_send = triggered_q or (user_prompt.strip() if send_chat and user_prompt.strip() else None)

                if question_to_send:
                    with st.spinner("🧩 Socratic Tutor is answering..."):
                        tutor = SocraticTutorAgent()
                        chat_history = st.session_state.get(f"tutor_chat_{active_idx}", [])
                        ans = run_async(tutor.answer_followup(
                            question=question_to_send,
                            step_title=current_step.title,
                            step_description=current_step.description,
                            explanation=tutor_exp or "",
                            topic=memory.topic,
                            student_level=memory.student_level,
                            chat_history=chat_history,
                        ))
                        if f"tutor_chat_{active_idx}" not in st.session_state:
                            st.session_state[f"tutor_chat_{active_idx}"] = []
                        st.session_state[f"tutor_chat_{active_idx}"].append({"role": "user", "text": question_to_send})
                        st.session_state[f"tutor_chat_{active_idx}"].append({"role": "tutor", "text": ans})
                        st.rerun()

            st.markdown("<br>", unsafe_allow_html=True)

            # 2. 📝 Milestone Comprehension Quiz & Auto-Advance Logic
            with st.expander("📝 **Milestone Knowledge Check Quiz**", expanded=True):
                step_quiz = getattr(current_step, "quiz", []) or []
                if not step_quiz:
                    st.info("Quiz Agent is generating questions for this milestone...")
                    if st.button("📝 **Generate Milestone Quiz**", key=f"gen_quiz_btn_{active_idx}", use_container_width=True):
                        with st.spinner("📝 Quiz Agent is generating questions..."):
                            quiz_agent = QuizAgent()
                            q_list = run_async(quiz_agent.generate_quiz(current_step, memory.topic, memory.student_level))
                            setattr(current_step, "quiz", q_list)
                            st.rerun()
                else:
                    quiz_key = f"quiz_form_{active_idx}"
                    
                    saved_user_answers = st.session_state.get(f"saved_user_answers_{active_idx}") or getattr(current_step, "user_answers", {})
                    saved_user_full_answers = st.session_state.get(f"saved_user_full_answers_{active_idx}") or getattr(current_step, "user_full_answers", {})

                    with st.form(quiz_key):
                        user_answers = {}
                        user_full_answers = {}
                        for q_idx, q in enumerate(step_quiz):
                            q_text = get_item_attr(q, "question", f"Question {q_idx+1}")
                            q_type_str = str(get_item_attr(q, "question_type", "multiple_choice")).lower()
                            st.markdown(f"**Q{q_idx+1}: {q_text}**")
                            
                            raw_opts = get_item_attr(q, "options", [])

                            if "blank" in q_type_str or "fill" in q_type_str or (isinstance(raw_opts, list) and len(raw_opts) == 0):
                                default_val = saved_user_answers.get(q_idx, "")
                                user_val = st.text_input(
                                    f"Answer Q{q_idx+1}",
                                    value=default_val,
                                    key=f"q_{active_idx}_{q_idx}",
                                    placeholder="Type your answer for the blank here...",
                                    label_visibility="collapsed",
                                )
                                user_answers[q_idx] = user_val.strip()
                                user_full_answers[q_idx] = user_val.strip()
                            else:
                                opts = format_quiz_options(raw_opts)
                                saved_ans = saved_user_full_answers.get(q_idx, "")
                                default_idx = None
                                if saved_ans and saved_ans in opts:
                                    default_idx = opts.index(saved_ans)
                                elif saved_user_answers.get(q_idx):
                                    saved_k = str(saved_user_answers.get(q_idx)).strip().upper()
                                    for o_i, o_str in enumerate(opts):
                                        if o_str.split(":")[0].strip().upper() == saved_k:
                                            default_idx = o_i
                                            break

                                user_ans = st.radio(
                                    f"Select answer Q{q_idx+1}",
                                    opts,
                                    key=f"q_{active_idx}_{q_idx}",
                                    index=default_idx,
                                    label_visibility="collapsed",
                                )
                                if user_ans:
                                    user_answers[q_idx] = user_ans.split(":")[0].strip()
                                    user_full_answers[q_idx] = user_ans
                                else:
                                    user_answers[q_idx] = saved_user_answers.get(q_idx, "")
                                    user_full_answers[q_idx] = saved_user_full_answers.get(q_idx, "")

                            if q_idx < len(step_quiz) - 1:
                                st.markdown("---")
                        
                        submit_quiz = st.form_submit_button("🚀 Submit Quiz", type="primary", use_container_width=True)

                    if submit_quiz:
                        missing_q_indices = []
                        for q_idx in range(len(step_quiz)):
                            ans = user_answers.get(q_idx, "")
                            if not ans or not str(ans).strip():
                                missing_q_indices.append(q_idx + 1)
                        
                        if missing_q_indices:
                            missing_str = ", ".join([f"Q{i}" for i in missing_q_indices])
                            st.warning(f"⚠️ **Please answer all questions before submitting the quiz!** Unanswered: **{missing_str}**")
                        else:
                            st.session_state[f"quiz_submitted_{active_idx}"] = True
                            st.session_state[f"saved_user_answers_{active_idx}"] = user_answers
                            st.session_state[f"saved_user_full_answers_{active_idx}"] = user_full_answers
                            safe_set_attr(current_step, "user_answers", user_answers)
                            safe_set_attr(current_step, "user_full_answers", user_full_answers)
                    else:
                        for q_idx in range(len(step_quiz)):
                            if not user_answers.get(q_idx) and q_idx in saved_user_answers:
                                user_answers[q_idx] = saved_user_answers[q_idx]
                            if not user_full_answers.get(q_idx) and q_idx in saved_user_full_answers:
                                user_full_answers[q_idx] = saved_user_full_answers[q_idx]

                    is_quiz_submitted = (
                        f"quiz_submitted_{active_idx}" in st.session_state
                        or current_step.status == StepStatus.COMPLETE
                        or getattr(current_step, "quiz_score", None) is not None
                    )

                    if is_quiz_submitted:
                        st.session_state[f"quiz_submitted_{active_idx}"] = True
                        correct_count = 0
                        total_q = len(step_quiz)

                        for q_idx, q in enumerate(step_quiz):
                            selected_key = user_answers.get(q_idx, "")
                            selected_full = user_full_answers.get(q_idx, "")
                            correct_raw = get_item_attr(q, "correct_option", None) or get_item_attr(q, "correct_answer", "A")
                            if is_answer_correct(selected_full, selected_key, str(correct_raw)):
                                correct_count += 1

                        score = correct_count / total_q if total_q > 0 else 0
                        setattr(current_step, "quiz_score", score)
                        earned_xp = calculate_quiz_xp(correct_count, total_q)

                        if f"xp_awarded_{active_idx}" not in st.session_state:
                            st.session_state[f"xp_awarded_{active_idx}"] = True
                            memory.xp_earned += earned_xp + calculate_step_xp(memory.streak_count)
                            memory.mark_step_complete(active_idx)

                            # Persist completion of current step to DB
                            try:
                                from services.session_manager import SessionManager
                                sm = SessionManager()
                                run_async(sm.update_session(memory))
                                run_async(sm.save_step_progress(
                                    session_id=memory.session_id,
                                    step_index=active_idx,
                                    status="complete",
                                    quiz_score=score,
                                ))
                            except Exception as e:
                                logging.warning(f"Could not persist step progress: {e}")

                        st.markdown("#### 📊 Quiz Results & Answers")
                        st.markdown(f"**Score:** `{score:.0%}` ({correct_count}/{total_q} Correct) | **XP Earned:** `+{earned_xp} XP` ⭐")

                        for q_idx, q in enumerate(step_quiz):
                            selected_key = user_answers.get(q_idx, "")
                            selected_full = user_full_answers.get(q_idx, "")
                            correct_raw = get_item_attr(q, "correct_option", None) or get_item_attr(q, "correct_answer", "A")
                            explanation = get_item_attr(q, "explanation", "")

                            is_correct = is_answer_correct(selected_full, selected_key, str(correct_raw))
                            if is_correct:
                                st.success(f"**Q{q_idx+1}: Correct!** ✅ — {explanation}")
                            else:
                                st.error(f"**Q{q_idx+1}: Incorrect** ❌ — Your answer: ({selected_full or 'None'}). Correct Answer: ({correct_raw}). {explanation}")

                        st.markdown("<br>", unsafe_allow_html=True)
                        if active_idx + 1 < len(memory.steps):
                            next_idx = active_idx + 1
                            next_step_title = memory.steps[next_idx].title
                            if st.button(
                                f"➡️ **Move to Next Step: Step {next_idx + 1} ({next_step_title})**",
                                key=f"next_step_btn_{active_idx}",
                                type="primary",
                                use_container_width=True,
                            ):
                                st.session_state["active_step_index"] = next_idx
                                memory.steps[next_idx].status = StepStatus.IN_PROGRESS
                                st.session_state[f"step_agents_ran_{next_idx}"] = True
                                setattr(memory.steps[next_idx], "_agent_generated", True)

                                with st.spinner(f"🚀 Preparing Step {next_idx + 1}: {next_step_title}..."):
                                    run_async(generate_all_agent_content_for_step(memory.steps[next_idx], memory))

                                try:
                                    from services.session_manager import SessionManager
                                    run_async(SessionManager().save_step_progress(
                                        session_id=memory.session_id,
                                        step_index=next_idx,
                                        status="in_progress",
                                    ))
                                except Exception as ex:
                                    logging.warning(f"Could not update next step status in DB: {ex}")

                                st.rerun()
                        else:
                            if not memory.is_complete:
                                memory.mark_step_complete(active_idx)
                                try:
                                    from services.session_manager import SessionManager
                                    run_async(SessionManager().update_session(memory))
                                except Exception as e:
                                    logging.warning(f"Could not save final session state: {e}")
                            if not st.session_state.get(f"victory_modal_dismissed_{memory.session_id}", False):
                                st.session_state[f"show_victory_modal_{memory.session_id}"] = True
                                show_congratulations_dialog(memory)

        # ─── RIGHT COLUMN: YouTube Videos & Academic Research Papers ──────
        with col_right:
            # 3. 🎬 YouTube Curator Agent (Max 3 videos)
            with st.expander("🎬 **Recommended YouTube Video Clips & Timestamps**", expanded=True):
                step_vids = (getattr(current_step, "videos", []) or [])[:3]
                if step_vids:
                    for idx, vid in enumerate(step_vids):
                        v_title = get_item_attr(vid, "title", "Educational Video")
                        v_channel = get_item_attr(vid, "channel", "YouTube")
                        v_relevance = get_item_attr(vid, "relevance_score", 0.9)
                        v_video_id = get_item_attr(vid, "video_id", "")
                        v_ts = get_item_attr(vid, "timestamp_seconds", None) or get_item_attr(vid, "start_time", None) or 0
                        
                        v_embed = get_item_attr(vid, "embed_url", "")
                        if not v_embed and v_video_id:
                            v_embed = f"https://www.youtube.com/embed/{v_video_id}?start={int(v_ts)}"

                        v_url = get_item_attr(vid, "timestamp_url", "") or get_item_attr(vid, "url", "") or f"https://www.youtube.com/watch?v={v_video_id}&t={int(v_ts)}"
                        v_exp = get_item_attr(vid, "timestamp_explanation", "") or get_item_attr(vid, "relevance_snippet", "")
                        v_snippet = get_item_attr(vid, "relevant_snippet", "") or get_item_attr(vid, "relevance_snippet", "")

                        st.markdown(f"#### 🎬 {v_title}")
                        st.write(f"**Channel:** {v_channel} | **Relevance:** {v_relevance:.0%}")
                        
                        if v_embed:
                            st.components.v1.iframe(v_embed, height=260)
                        elif v_video_id:
                            st.video(f"https://www.youtube.com/watch?v={v_video_id}", start_time=int(v_ts))
                        
                        # Display Key Clip ONLY if timestamp > 0 or explanation text is non-empty
                        if (v_ts and int(v_ts) > 0) or (v_exp and str(v_exp).strip()):
                            timestamp_mins = int(v_ts) // 60 if v_ts else 0
                            timestamp_secs = int(v_ts) % 60 if v_ts else 0
                            clip_text = str(v_exp).strip() if (v_exp and str(v_exp).strip()) else "Topic explanation segment"
                            st.markdown(
                                f"📌 **Key Clip:** [{timestamp_mins:02d}:{timestamp_secs:02d}]({v_url}) "
                                f"— *\"{clip_text}\"*"
                            )
                        if v_snippet:
                            st.caption(f"**Transcript Snippet:** {v_snippet}")

                        if idx < len(step_vids) - 1:
                            st.markdown("---")
                else:
                    st.info("YouTube Curator Agent is curating video clips...")

            st.markdown("<br>", unsafe_allow_html=True)

            # 4. 📚 Academic Researcher Agent
            with st.expander("📚 **Academic Research Papers & Preprints**", expanded=True):
                step_papers = getattr(current_step, "papers", []) or []
                if step_papers:
                    for idx, paper in enumerate(step_papers):
                        p_title = get_item_attr(paper, "title", "Research Paper")
                        p_url = get_item_attr(paper, "url", "") or get_item_attr(paper, "pdf_url", "")
                        p_authors = get_item_attr(paper, "authors", []) or []
                        p_year = get_item_attr(paper, "year", None)
                        p_source = str(get_item_attr(paper, "source", "Academic")).title()
                        p_summary = get_item_attr(paper, "ai_summary", "") or get_item_attr(paper, "tldr", "") or get_item_attr(paper, "abstract", "")
                        if p_summary and len(p_summary) > 220:
                            p_summary = p_summary[:220] + "..."

                        authors_str = ', '.join(p_authors[:3]) if isinstance(p_authors, list) and p_authors else "Unknown Authors"

                        st.markdown(
                            f"""
                            <div class="paper-card">
                                <h4 style="margin-bottom:4px; color:#60A5FA;"><a href="{p_url}" target="_blank" style="color:#60A5FA; text-decoration:none;">📄 {p_title}</a></h4>
                                <p style="font-size:0.85rem; color:#94A3B8; margin-bottom:6px;"><b>Authors:</b> {authors_str} | <b>Year:</b> {p_year or 'N/A'} | <b>Source:</b> {p_source}</p>
                                <p style="font-size:0.9rem; color:#E2E8F0;"><b>AI Key Insight:</b> {p_summary}</p>
                            </div>
                            """,
                            unsafe_allow_html=True,
                        )
                else:
                    st.info("Academic Researcher Agent is querying OpenAlex & arXiv...")


def sync_session_with_url():
    """
    Synchronizes st.session_state with st.query_params to preserve state (current view,
    user login profile, active learning topic) across browser refreshes.
    """
    query_params = st.query_params

    # 1. Restore view from URL query params if missing in session state
    if "view" not in st.session_state:
        url_view = query_params.get("view")
        if url_view in ["home", "auth", "learning", "admin", "pricing"]:
            st.session_state["view"] = url_view
        else:
            st.session_state["view"] = "home"

    # 2. Restore active topic from query params if missing in session state
    if "last_topic" not in st.session_state and query_params.get("topic"):
        st.session_state["last_topic"] = query_params.get("topic")

    # 3. Restore user profile from query params if missing in session state
    if not st.session_state.get("user_profile"):
        uid = query_params.get("user_id")
        uemail = query_params.get("user_email")
        if uid or uemail:
            try:
                if uid and uid.startswith("demo-"):
                    from home_ui import _make_demo_profile
                    email_val = uemail or "student@edutech.ai"
                    st.session_state["user_profile"] = _make_demo_profile(email_val)
                elif uid:
                    from services.auth_service import AuthService
                    from services.database import get_db_session
                    from services.user_service import UserService

                    async def _restore():
                        async with get_db_session() as db:
                            u = await UserService.get_user_by_id(db, uid)
                            return AuthService.get_user_current_profile(u)

                    p = run_async(_restore())
                    if p:
                        st.session_state["user_profile"] = p
                elif uemail:
                    if uemail in ["student@edutech.ai", "pro@edutech.ai"]:
                        from home_ui import _make_demo_profile
                        st.session_state["user_profile"] = _make_demo_profile(uemail)
                    else:
                        from services.auth_service import AuthService
                        from services.database import get_db_session
                        from models.domain import User
                        from sqlalchemy import select

                        async def _restore_by_email():
                            async with get_db_session() as db:
                                stmt = select(User).where(User.email == uemail)
                                res = await db.execute(stmt)
                                u = res.scalar_one_or_none()
                                if u:
                                    return AuthService.get_user_current_profile(u)
                                return None

                        p = run_async(_restore_by_email())
                        if p:
                            st.session_state["user_profile"] = p
            except Exception as e:
                logging.warning(f"Session restoration from URL parameters failed: {e}")

    # 4. Write back active session state into URL query parameters
    cur_view = st.session_state.get("view", "home")
    st.query_params["view"] = cur_view

    user_profile = st.session_state.get("user_profile")
    if user_profile:
        st.query_params["user_id"] = user_profile.id
        if hasattr(user_profile, "email") and user_profile.email:
            st.query_params["user_email"] = user_profile.email
    else:
        if "user_id" in st.query_params:
            del st.query_params["user_id"]
        if "user_email" in st.query_params:
            del st.query_params["user_email"]

    last_topic = st.session_state.get("last_topic")
    if last_topic:
        st.query_params["topic"] = last_topic
    elif "topic" in st.query_params:
        del st.query_params["topic"]


# ─── Main View Switcher Execution ─────────────────────────────────
sync_session_with_url()

current_view = st.session_state.get("view", "home")

if current_view == "admin":
    from admin_ui import render_admin_panel
    render_admin_panel()
elif current_view in ["home", "auth", "pricing"]:
    from home_ui import render_home_page
    render_home_page()
else:
    render_learning_workspace()

# ─── Modal Dialog Controllers ──────────────────────────────────────
# Use pop() to consume the flag on the rerun that opens the dialog.
# The dialog stays open via Streamlit's internal fragment/dialog state.
# When dismissed (X or outside click), the full rerun finds no flag → dialog won't reopen.
if st.session_state.pop("show_upgrade_modal", False) and st.session_state.get("user_profile"):
    from services.subscription_ui import render_subscription_upgrade_dialog
    target_t = st.session_state.pop("target_upgrade_tier", "pro")
    render_subscription_upgrade_dialog(target_t)
elif st.session_state.pop("show_billing_portal_modal", False) and st.session_state.get("user_profile"):
    from services.subscription_ui import render_user_billing_portal_dialog
    render_user_billing_portal_dialog()



