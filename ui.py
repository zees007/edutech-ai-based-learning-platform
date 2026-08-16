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
import logging
import time

import streamlit as st
import streamlit.components.v1 as components

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

    /* Hide ALL native default collapse and expand controls & sidebar headers visually */
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
        display: none !important;
        opacity: 0 !important;
        visibility: hidden !important;
        position: fixed !important;
        top: -9999px !important;
        left: -9999px !important;
        width: 0px !important;
        height: 0px !important;
        max-width: 0px !important;
        max-height: 0px !important;
        padding: 0 !important;
        margin: 0 !important;
        border: none !important;
        overflow: hidden !important;
        pointer-events: none !important;
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

    /* ── Hero Center Typography (Exact Home Page Theme) ────── */
    .et-hero {
        text-align: center;
        padding: 0.2rem 1rem 0.6rem 1rem;
        position: relative;
    }

    .et-hero h1 {
        font-size: 3.6rem;
        font-weight: 900;
        color: #FAFAFA;
        line-height: 1.15;
        letter-spacing: -2px;
        margin-bottom: 0.8rem;
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
        margin: 0 auto 1.4rem auto;
        line-height: 1.7;
    }

    /* ── Sidebar Guide Callout Banner (Matching Sidebar Handle Theme) ── */
    .sidebar-guide-card {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 14px;
        background: linear-gradient(135deg, rgba(14, 9, 24, 0.95) 0%, rgba(30, 20, 50, 0.85) 100%);
        border: 1.5px solid rgba(168, 85, 247, 0.6);
        border-radius: 50px;
        padding: 0.8rem 1.8rem;
        margin: 0 auto 2.2rem auto;
        max-width: 800px;
        box-shadow: 0 0 30px rgba(168, 85, 247, 0.25), 0 8px 25px rgba(0, 0, 0, 0.5), inset 0 0 20px rgba(168, 85, 247, 0.15);
        backdrop-filter: blur(20px);
        -webkit-backdrop-filter: blur(20px);
        transition: all 0.3s ease;
    }

    .sidebar-guide-card:hover {
        border-color: #C084FC;
        box-shadow: 0 0 40px rgba(168, 85, 247, 0.4), 0 10px 30px rgba(0, 0, 0, 0.6);
        transform: translateY(-2px);
    }

    .guide-handle-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        background: rgba(168, 85, 247, 0.25);
        border: 1.5px solid #A855F7;
        border-radius: 20px;
        padding: 5px 12px;
        color: #E9D5FF;
        font-size: 0.78rem;
        font-weight: 800;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        box-shadow: 0 0 14px rgba(168, 85, 247, 0.4);
        flex-shrink: 0;
    }

    .guide-chevron-pulse {
        animation: chevronSlide 1.5s infinite ease-in-out;
    }

    @keyframes chevronSlide {
        0%, 100% { transform: translateX(0); }
        50% { transform: translateX(-4px); }
    }

    .guide-text-content {
        font-size: 0.98rem;
        font-weight: 600;
        color: #FAFAFA;
        line-height: 1.4;
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
    .glass-card, .feat-card, .agent-glass {
        position: relative;
        background: linear-gradient(135deg, rgba(30, 41, 59, 0.85) 0%, rgba(124, 58, 237, 0.16) 50%, rgba(15, 23, 42, 0.9) 100%);
        backdrop-filter: blur(20px);
        -webkit-backdrop-filter: blur(20px);
        border: 1px solid rgba(168, 85, 247, 0.4);
        border-radius: 18px;
        padding: 1.4rem;
        margin-bottom: 1rem;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4), inset 0 0 20px rgba(168, 85, 247, 0.1);
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        overflow: hidden;
    }

    .glass-card::before, .feat-card::before, .agent-glass::before, .top-progress-card::before {
        content: '';
        position: absolute;
        top: 0; left: 15%; right: 15%; height: 2px;
        background: linear-gradient(90deg, transparent 0%, #EC4899 30%, #A855F7 50%, #06B6D4 70%, transparent 100%);
        border-radius: 2px;
        opacity: 0.75;
        transition: opacity 0.3s ease, box-shadow 0.3s ease;
    }

    .glass-card:hover, .feat-card:hover, .agent-glass:hover {
        background: linear-gradient(135deg, rgba(124, 58, 237, 0.28) 0%, rgba(59, 130, 246, 0.2) 50%, rgba(15, 23, 42, 0.95) 100%);
        border-color: rgba(168, 85, 247, 0.75);
        box-shadow: 0 0 40px rgba(168, 85, 247, 0.35), 0 12px 35px rgba(0, 0, 0, 0.5);
        transform: translateY(-3px);
    }

    .glass-card:hover::before, .feat-card:hover::before, .agent-glass:hover::before {
        opacity: 1;
        box-shadow: 0 0 14px #EC4899, 0 0 20px #A855F7;
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

    /* ── Sidebar Glassmorphic Theme & Top Padding Adjustment ── */
    html body div.stApp section[data-testid="stSidebar"] {
        display: flex !important;
        visibility: visible !important;
        opacity: 1 !important;
        overflow: visible !important;
        background-color: #0B0715 !important;
        background-image: radial-gradient(ellipse 300px 300px at 50% 10%, rgba(139, 92, 246, 0.15) 0%, transparent 80%) !important;
        border-right: 1px solid rgba(168, 85, 247, 0.25) !important;
        box-shadow: 10px 0 30px rgba(0, 0, 0, 0.5) !important;
    }

    section[data-testid="stSidebar"] div.block-container,
    section[data-testid="stSidebar"] [data-testid="stSidebarContent"],
    section[data-testid="stSidebar"] [data-testid="stSidebarUserContent"],
    section[data-testid="stSidebar"] div[data-testid="stVerticalBlock"] {
        padding-top: 0.8rem !important;
        margin-top: 0 !important;
    }

    section[data-testid="stSidebar"] [data-testid="stSidebarContent"] {
        padding-top: 0.8rem !important;
        padding-left: 1.0rem !important;
        padding-right: 1.0rem !important;
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

    /* ── Animated AI Neural Network Icon in Sidebar Header ── */
    .sidebar-header-container {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 12px;
        padding-bottom: 8px;
        border-bottom: 1px solid rgba(168, 85, 247, 0.25);
    }

    .neural-icon-wrapper {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 32px;
        height: 32px;
        border-radius: 10px;
        background: linear-gradient(135deg, rgba(168, 85, 247, 0.2) 0%, rgba(59, 130, 246, 0.2) 100%);
        border: 1px solid rgba(168, 85, 247, 0.45);
        box-shadow: 0 0 15px rgba(168, 85, 247, 0.35);
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

    .sidebar-header-text {
        font-size: 1.02rem;
        font-weight: 900;
        color: #FAFAFA;
        line-height: 1.3;
        letter-spacing: -0.2px;
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
        border: 1px solid rgba(251, 191, 36, 0.4);
        font-size: 0.72rem;
        font-weight: 800;
        padding: 3px 10px;
        border-radius: 20px;
        text-transform: uppercase;
        letter-spacing: 0.6px;
        margin-left: 8px;
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

    /* ── Progress Bar Theming ────────────────────────── */
    div[data-testid="stProgress"] > div {
        background: rgba(30, 41, 59, 0.6) !important;
        border-radius: 10px !important;
        overflow: hidden !important;
        border: 1px solid rgba(168, 85, 247, 0.25) !important;
    }

    div[data-testid="stProgress"] > div > div > div > div {
        background: linear-gradient(90deg, #EC4899, #A855F7, #3B82F6) !important;
        box-shadow: 0 0 15px rgba(168, 85, 247, 0.5) !important;
    }

    /* Glassmorphism Dynamic AI Loader */
    .glass-loader-box {
        position: relative;
        background: rgba(15, 23, 42, 0.85);
        backdrop-filter: blur(20px);
        -webkit-backdrop-filter: blur(20px);
        border: 1px solid rgba(168, 85, 247, 0.35);
        border-radius: 20px;
        padding: 1.8rem;
        margin: 1.5rem 0;
        overflow: hidden;
        box-shadow: 0 20px 50px rgba(0, 0, 0, 0.5), inset 0 0 30px rgba(124, 58, 237, 0.15);
        animation: n8nPulseGlow 3s infinite ease-in-out;
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
        justify-content: space-between;
        margin-bottom: 1.2rem;
        padding-bottom: 0.8rem;
        border-bottom: 1px solid rgba(255, 255, 255, 0.08);
    }

    .loader-title {
        font-size: 1.25rem;
        font-weight: 800;
        background: linear-gradient(135deg, #EC4899 0%, #A855F7 50%, #06B6D4 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        letter-spacing: 0.5px;
    }

    .loader-metrics-badge {
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
        border-color: rgba(168, 85, 247, 0.7);
        background: rgba(124, 58, 237, 0.18);
        box-shadow: 0 0 20px rgba(168, 85, 247, 0.25);
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
    .tag-active { background: rgba(168, 85, 247, 0.25); color: #C084FC; }
    .tag-waiting { background: rgba(255, 255, 255, 0.05); color: #71717A; }

    .agent-desc {
        font-size: 0.75rem;
        color: #94A3B8;
        line-height: 1.3;
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
    neural network node visualizers, and step-by-step agent workflow cards.
    """
    def _status_tag(status: str) -> str:
        if status == "completed":
            return '<span class="agent-status-tag tag-completed">✓ COMPLETED</span>'
        elif status == "active":
            return '<span class="agent-status-tag tag-active">⚡ EXECUTING...</span>'
        else:
            return '<span class="agent-status-tag tag-waiting">⌛ QUEUED</span>'

    def _card_class(status: str) -> str:
        if status == "completed":
            return "agent-card-item completed"
        elif status == "active":
            return "agent-card-item active"
        else:
            return "agent-card-item"

    return f"""<div class="glass-loader-box">
<div class="glass-loader-mesh"></div>
<div class="glass-loader-content">
<div class="loader-header">
<div>
<div style="font-size: 0.75rem; font-weight: 800; color: #A78BFA; text-transform: uppercase; letter-spacing: 1.5px; margin-bottom: 4px;">⚡ EDU-TECH AI COMPUTE CLUSTER &nbsp;•&nbsp; NEURAL INFERENCE</div>
<div class="loader-title">{title}</div>
<div style="color: #94A3B8; font-size: 0.88rem; margin-top: 2px;">{subtitle}</div>
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
@st.cache_resource
def _init_db_once():
    """Warm up DB schema, migrations, and seeds at app start — not on first admin switch."""
    from services.database import init_db
    from config import get_settings
    run_async(init_db(get_settings()))


_init_db_once()  # Triggered once on first Streamlit page load


def get_or_create_memory() -> SharedMemory | None:
    """Retrieve active session from session state."""
    return st.session_state.get("memory")


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

    # ─── TOP NAVBAR: Floating Pill Navbar matching Homepage (rendered first) ──────────
    u_tier = (user_profile.subscription.tier if user_profile.subscription else "normal").upper()
    top_nav_l, top_nav_r = st.columns([8.8, 1.2], vertical_alignment="center")

    with top_nav_l:
        st.markdown(
            '<div class="et-learning-nav"><div class="et-logo">⚡ <span class="accent">EduTech</span> <span class="badge-ai">AI</span></div></div>',
            unsafe_allow_html=True,
        )

    with top_nav_r:
        r_a, r_p = st.columns(2, gap="small", vertical_alignment="center")
        with r_a:
            if st.button("", icon=":material/settings:", key="nav_admin_btn", help="Admin Console & Settings", use_container_width=False):
                st.session_state["view"] = "admin"
                st.rerun()
        with r_p:
            with st.popover("", icon=":material/person:", help=f"Profile: {user_profile.first_name} {user_profile.last_name}", use_container_width=False):
                st.markdown(
                    f"""
                    <div style="text-align: center; padding: 4px 0 8px 0;">
                        <div style="font-size: 2.2rem; margin-bottom: 4px;">👤</div>
                        <div style="font-weight: 800; font-size: 1.05rem; color: #FAFAFA;">{user_profile.first_name} {user_profile.last_name}</div>
                        <div style="font-size: 0.8rem; color: rgba(233, 213, 255, 0.7); margin-bottom: 8px;">{user_profile.email if hasattr(user_profile, 'email') and user_profile.email else 'Student'}</div>
                        <div style="display: inline-block; background: rgba(168, 85, 247, 0.25); border: 1px solid rgba(168, 85, 247, 0.5); border-radius: 20px; padding: 2px 12px; font-size: 0.75rem; font-weight: 800; color: #C084FC; text-transform: uppercase;">
                            ✨ {u_tier} Tier
                        </div>
                    </div>
                    """,
                    unsafe_allow_html=True,
                )
                st.markdown("<hr style='border-color:rgba(168,85,247,0.25); margin:8px 0;'>", unsafe_allow_html=True)
                if st.button("⏻ Sign Out", key="nav_logout_btn", use_container_width=True):
                    st.session_state["user_profile"] = None
                    st.session_state["view"] = "home"
                    st.query_params.clear()
                    st.toast("Logged out successfully.", icon="ℹ️")
                    st.rerun()

    memory = get_or_create_memory()

    # Master Sidebar Toggle & Auto-Expand Controller (Senior Frontend Architecture)
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
                        const opts = { bubbles: true, cancelable: true, view: win };
                        el.dispatchEvent(new MouseEvent('mousedown', opts));
                        el.dispatchEvent(new MouseEvent('mouseup', opts));
                        el.dispatchEvent(new MouseEvent('click', opts));
                        if (typeof el.click === 'function') el.click();
                    } catch(err) {
                        if (typeof el.click === 'function') el.click();
                    }
                }

                function findExpandButton() {
                    // 1. Direct standard Streamlit testids
                    let btn = doc.querySelector('[data-testid="stSidebarCollapsedControl"] button, [data-testid="collapsedControl"] button');
                    if (btn) return btn;

                    // 2. Search all buttons inside header
                    const headerBtns = doc.querySelectorAll('header[data-testid="stHeader"] button, [data-testid="stHeader"] button, button[kind="header"]');
                    for (let b of headerBtns) {
                        const str = ((b.getAttribute('aria-label') || '') + ' ' + (b.getAttribute('title') || '') + ' ' + b.className).toLowerCase();
                        if (!str.includes('deploy') && !str.includes('menu') && !b.closest('.stDeployButton') && !b.closest('[data-testid="stAppDeployButton"]')) {
                            return b;
                        }
                    }

                    // 3. Search document-wide for expand / sidebar buttons
                    const allBtns = doc.querySelectorAll('button');
                    for (let b of allBtns) {
                        const aria = (b.getAttribute('aria-label') || '').toLowerCase();
                        const title = (b.getAttribute('title') || '').toLowerCase();
                        if (aria.includes('expand') || aria.includes('open sidebar') || title.includes('expand') || title.includes('open sidebar')) {
                            return b;
                        }
                    }

                    // 4. Fallback to container itself
                    const container = doc.querySelector('[data-testid="stSidebarCollapsedControl"], [data-testid="collapsedControl"]');
                    if (container) return container;

                    return null;
                }

                function findCollapseButton() {
                    let btn = doc.querySelector('section[data-testid="stSidebar"] [data-testid="stSidebarCollapseButton"] button, section[data-testid="stSidebar"] button[aria-label*="Close" i], section[data-testid="stSidebar"] button[aria-label*="Collapse" i]');
                    if (btn) return btn;

                    const allSbBtns = doc.querySelectorAll('section[data-testid="stSidebar"] button');
                    for (let b of allSbBtns) {
                        const aria = (b.getAttribute('aria-label') || '').toLowerCase();
                        const title = (b.getAttribute('title') || '').toLowerCase();
                        if (aria.includes('close') || aria.includes('collapse') || title.includes('close') || title.includes('collapse')) {
                            return b;
                        }
                    }
                    return doc.querySelector('[data-testid="stSidebarCollapseButton"] button');
                }

                // Auto-expand sidebar if collapsed on initial workspace landing
                function ensureSidebarOpen() {
                    const sidebar = doc.querySelector('section[data-testid="stSidebar"]');
                    const isCollapsed = !sidebar || 
                                        sidebar.getAttribute('aria-expanded') === 'false' || 
                                        sidebar.getBoundingClientRect().width === 0 ||
                                        window.getComputedStyle(sidebar).display === 'none';
                    if (isCollapsed) {
                        const targetBtn = findExpandButton();
                        if (targetBtn) {
                            dispatchFullClick(targetBtn);
                        }
                    }
                }
                ensureSidebarOpen();
                setTimeout(ensureSidebarOpen, 150);
                setTimeout(ensureSidebarOpen, 400);

                // Inject Master Sidebar Toggle Button directly onto parent document body (immune to transforms & clipping)
                let toggle = doc.getElementById('edutech-sidebar-master-toggle');
                if (!toggle) {
                    toggle = doc.createElement('div');
                    toggle.id = 'edutech-sidebar-master-toggle';
                    toggle.innerHTML = `
                        <svg id="edutech-toggle-chevron" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#E9D5FF" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="transition: transform 0.25s cubic-bezier(0.4, 0, 0.2, 1); pointer-events: none;">
                            <polyline points="15 18 9 12 15 6"></polyline>
                        </svg>
                    `;
                    doc.body.appendChild(toggle);
                }

                // Get initial sidebar measurement if present, default to open width ~336px
                const initSb = doc.querySelector('section[data-testid="stSidebar"]');
                const initRight = (initSb && initSb.getBoundingClientRect().right > 100) ? initSb.getBoundingClientRect().right : 336;

                // Apply high-end modern glassmorphism styling
                Object.assign(toggle.style, {
                    position: 'fixed',
                    top: '50%',
                    left: `${initRight}px`,
                    transform: 'translateY(-50%)',
                    zIndex: '99999999',
                    width: '28px',
                    height: '56px',
                    background: 'rgba(14, 9, 24, 0.95)',
                    border: '2px solid #A855F7',
                    borderLeft: 'none',
                    borderRadius: '0 12px 12px 0',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    cursor: 'pointer',
                    boxShadow: '0 0 16px rgba(168, 85, 247, 0.45), 0 4px 12px rgba(0, 0, 0, 0.5)',
                    backdropFilter: 'blur(16px)',
                    webkitBackdropFilter: 'blur(16px)',
                    transition: 'left 0.15s cubic-bezier(0.4, 0, 0.2, 1), width 0.15s ease, background 0.15s ease, box-shadow 0.15s ease',
                    userSelect: 'none',
                    webkitUserSelect: 'none',
                    visibility: 'visible',
                    opacity: '1',
                    pointerEvents: 'auto',
                });

                toggle.onmouseenter = () => {
                    toggle.style.width = '34px';
                    toggle.style.background = 'rgba(168, 85, 247, 0.4)';
                    toggle.style.borderColor = '#C084FC';
                    toggle.style.boxShadow = '0 0 24px rgba(168, 85, 247, 0.8), 0 0 10px rgba(192, 132, 252, 0.5)';
                };
                toggle.onmouseleave = () => {
                    toggle.style.width = '28px';
                    toggle.style.background = 'rgba(14, 9, 24, 0.95)';
                    toggle.style.borderColor = '#A855F7';
                    toggle.style.boxShadow = '0 0 16px rgba(168, 85, 247, 0.45), 0 4px 12px rgba(0, 0, 0, 0.5)';
                };

                function isSidebarOpen() {
                    const sb = doc.querySelector('section[data-testid="stSidebar"]');
                    if (!sb) return true; // Default to open in learning workspace
                    const ariaClosed = sb.getAttribute('aria-expanded') === 'false';
                    if (ariaClosed) return false;
                    const comp = win.getComputedStyle(sb);
                    if (comp.display === 'none') return false;
                    const rect = sb.getBoundingClientRect();
                    return rect.right > 50 || rect.width > 50;
                }

                function updateTogglePosition() {
                    if (!toggle || !toggle.parentNode) return;
                    const sb = doc.querySelector('section[data-testid="stSidebar"]');
                    const svg = toggle.querySelector('#edutech-toggle-chevron');
                    
                    if (isSidebarOpen() && sb) {
                        const rect = sb.getBoundingClientRect();
                        const targetLeft = rect.right > 50 ? rect.right : 336;
                        toggle.style.left = `${Math.max(0, targetLeft)}px`;
                        if (svg) svg.style.transform = 'rotate(0deg)';
                        toggle.setAttribute('title', 'Collapse Sidebar');
                    } else {
                        toggle.style.left = '0px';
                        if (svg) svg.style.transform = 'rotate(180deg)';
                        toggle.setAttribute('title', 'Open Sidebar');
                    }
                }

                // Run immediately on creation
                updateTogglePosition();

                toggle.onclick = function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    if (isSidebarOpen()) {
                        const closeBtn = findCollapseButton();
                        if (closeBtn) dispatchFullClick(closeBtn);
                    } else {
                        const expandBtn = findExpandButton();
                        if (expandBtn) dispatchFullClick(expandBtn);
                    }
                    setTimeout(updateTogglePosition, 50);
                    setTimeout(updateTogglePosition, 150);
                    setTimeout(updateTogglePosition, 300);
                    setTimeout(updateTogglePosition, 500);
                };

                // Continually sync button position smoothly
                if (!win._edutechToggleTracking) {
                    win._edutechToggleTracking = true;
                    function track() {
                        updateTogglePosition();
                        requestAnimationFrame(track);
                    }
                    requestAnimationFrame(track);
                }
            } catch (err) {
                console.error("Master Sidebar Toggle error:", err);
            }
        })();
        </script>
        """,
        height=0,
        width=0,
    )

    # ─── Sidebar Controls & Gamification (Left Panel) ────────────────
    with st.sidebar:
        st.markdown(
            """
            <div class="sidebar-header-container">
                <div class="neural-icon-wrapper">
                    <svg class="neural-network-svg" width="22" height="22" viewBox="0 0 24 24" fill="none">
                        <line x1="4" y1="12" x2="12" y2="4" stroke="url(#neuralGrad1)" stroke-width="1.8" stroke-dasharray="2 2" class="neural-pulse-line" />
                        <line x1="4" y1="12" x2="12" y2="20" stroke="url(#neuralGrad1)" stroke-width="1.8" stroke-dasharray="2 2" class="neural-pulse-line" />
                        <line x1="12" y1="4" x2="20" y2="12" stroke="url(#neuralGrad2)" stroke-width="1.8" stroke-dasharray="2 2" class="neural-pulse-line" />
                        <line x1="12" y1="20" x2="20" y2="12" stroke="url(#neuralGrad2)" stroke-width="1.8" stroke-dasharray="2 2" class="neural-pulse-line" />
                        <line x1="12" y1="4" x2="12" y2="20" stroke="url(#neuralGrad3)" stroke-width="1.5" stroke-dasharray="2 2" class="neural-pulse-line" />
                        <line x1="4" y1="12" x2="20" y2="12" stroke="url(#neuralGrad3)" stroke-width="1.5" class="neural-pulse-line" />
                        <circle cx="4" cy="12" r="3" fill="#EC4899" class="neural-node node-1" />
                        <circle cx="12" cy="4" r="3.2" fill="#A855F7" class="neural-node node-2" />
                        <circle cx="12" cy="20" r="3.2" fill="#3B82F6" class="neural-node node-3" />
                        <circle cx="20" cy="12" r="3.5" fill="#06B6D4" class="neural-node node-4" />
                        <defs>
                            <linearGradient id="neuralGrad1" x1="0%" y1="0%" x2="100%" y2="100%">
                                <stop offset="0%" stop-color="#EC4899" />
                                <stop offset="100%" stop-color="#A855F7" />
                            </linearGradient>
                            <linearGradient id="neuralGrad2" x1="0%" y1="0%" x2="100%" y2="100%">
                                <stop offset="0%" stop-color="#A855F7" />
                                <stop offset="100%" stop-color="#06B6D4" />
                            </linearGradient>
                            <linearGradient id="neuralGrad3" x1="0%" y1="0%" x2="100%" y2="100%">
                                <stop offset="0%" stop-color="#EC4899" />
                                <stop offset="50%" stop-color="#A855F7" />
                                <stop offset="100%" stop-color="#3B82F6" />
                            </linearGradient>
                        </defs>
                    </svg>
                </div>
                <div class="sidebar-header-text">What do you want to learn today?</div>
            </div>
            """,
            unsafe_allow_html=True,
        )
        
        # Check if quick-launched from home page
        default_topic = st.session_state.pop("quick_launch_topic", None) or st.session_state.get("last_topic", "How does photosynthesis work?")

        # Topic Input
        topic_input = st.text_input(
            "What do you want to master?",
            value=default_topic,
            placeholder="e.g. Quantum Computing, Photosynthesis...",
            label_visibility="collapsed",
        )
        
        # Topic Suggestions
        st.markdown("<div style='font-size:0.78rem; color:rgba(233,213,255,0.75); font-weight:700; margin: 8px 0 4px 0;'>💡 Instant Topic Prompts:</div>", unsafe_allow_html=True)
        cols = st.columns(2)
        if cols[0].button("🌱 Photosynthesis", key="sug1", use_container_width=True):
            topic_input = "How does photosynthesis work?"
        if cols[1].button("⚛️ Quantum Physics", key="sug2", use_container_width=True):
            topic_input = "Explain quantum entanglement"
        if cols[0].button("🧠 Neural Networks", key="sug3", use_container_width=True):
            topic_input = "How do neural networks learn?"
        if cols[1].button("🌊 Ocean Tides", key="sug4", use_container_width=True):
            topic_input = "What causes ocean tides?"

        st.markdown("<hr style='border-color:rgba(168,85,247,0.25); margin:12px 0;'>", unsafe_allow_html=True)

        # Learning Mode Selection (Bold Label)
        mode_option = st.selectbox(
            "**🎨 Learning Mode**",
            options=["Visual 🎬", "Deep Dive 🔬", "Bite-Sized ⚡"],
            index=0,
            help="Visual: video & diagrams | Deep Dive: papers & proofs | Bite-Sized: quick summaries",
        )
        mode_map = {
            "Visual 🎬": LearningMode.VISUAL,
            "Deep Dive 🔬": LearningMode.DEEP_DIVE,
            "Bite-Sized ⚡": LearningMode.BITE_SIZED,
        }
        selected_mode = mode_map[mode_option]

        # Student Level Selection (Bold Label)
        level_option = st.selectbox(
            "**🎓 Education Level**",
            options=["Middle School 🏫", "High School 🎒", "Undergraduate 🏛️", "Graduate 🎓", "General Curious 💡"],
            index=0,
        )
        level_map = {
            "Middle School 🏫": "middle_school",
            "High School 🎒": "high_school",
            "Undergraduate 🏛️": "undergraduate",
            "Graduate 🎓": "graduate",
            "General Curious 💡": "general",
        }
        selected_level = level_map[level_option]

        st.markdown("<div style='height: 10px;'></div>", unsafe_allow_html=True)

        # Start Learning Journey Button
        start_clicked = st.button("🚀 Start Learning Journey", type="primary", use_container_width=True)

    # ─── Session Initialization Logic ────────────────────────────────
    if start_clicked and topic_input:
        st.session_state["last_topic"] = topic_input
        
        loader_placeholder = st.empty()

        # Step 1: Orchestrator Agent decomposing topic into milestone steps
        loader_placeholder.markdown(
            render_glassy_agent_loader_html(
                title=f"Decomposing '{topic_input}'",
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

        # Initialize SharedMemory
        new_memory = SharedMemory(
            topic=topic_input,
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

        # Persist session to PostgreSQL database in Supabase
        try:
            from services.session_manager import SessionManager
            run_async(SessionManager().create_session(new_memory))
        except Exception as e:
            logging.warning(f"Could not persist session to database: {e}")

        st.session_state["memory"] = new_memory
        st.session_state["active_step_index"] = 0
        st.session_state["submitted_quizzes"] = {}
        st.rerun()

    memory = get_or_create_memory()

    # ─── Main Content Workspace ──────────────────────────────────────
    if not memory or not memory.steps:
        # Centered Hero Section (Matching Home Page Typography & Gradient Text)
        st.markdown(
            """
            <div class="et-hero">
                <h1>EduTechAI<br/><span class="gradient-text">Learning Workspace</span></h1>
                <p>An adaptive, intelligent learning studio where specialized AI agents orchestrate personalized roadmaps, intuitive analogies, video deep-dives, and instant mastery checks.</p>
            </div>
            <div class="sidebar-guide-card">
                <div class="guide-handle-badge">
                    <svg class="guide-chevron-pulse" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#E9D5FF" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="15 18 9 12 15 6"></polyline>
                    </svg>
                    <span>Sidebar</span>
                </div>
                <div class="guide-text-content">
                    Enter any topic in the sidebar & click <span class="gradient-text" style="font-weight: 800;">'Start Learning Journey'</span> to launch your multi-agent studio!
                </div>
            </div>
            """,
            unsafe_allow_html=True,
        )
        
        # 4 Agent Squad Cards (Matching Landing Page Grid Aesthetic)
        col1, col2, col3, col4 = st.columns(4)
        with col1:
            st.markdown(
                """
                <div class="feat-card">
                    <div class="feat-icon icon-violet">🧩</div>
                    <h4>Socratic Tutor</h4>
                    <p style="font-size: 0.84rem; color: rgba(255, 255, 255, 0.65);">Interactive Socratic dialogue with intuitive analogies tailored to your level.</p>
                </div>
                """,
                unsafe_allow_html=True,
            )
        with col2:
            st.markdown(
                """
                <div class="feat-card">
                    <div class="feat-icon icon-cyan">🎬</div>
                    <h4>YouTube Curator</h4>
                    <p style="font-size: 0.84rem; color: rgba(255, 255, 255, 0.65);">Pinpoints exact timestamp clips and explanations from top educational videos.</p>
                </div>
                """,
                unsafe_allow_html=True,
            )
        with col3:
            st.markdown(
                """
                <div class="feat-card">
                    <div class="feat-icon icon-blue">📚</div>
                    <h4>Academic Researcher</h4>
                    <p style="font-size: 0.84rem; color: rgba(255, 255, 255, 0.65);">Retrieves open-access papers with AI summaries from arXiv & OpenAlex.</p>
                </div>
                """,
                unsafe_allow_html=True,
            )
        with col4:
            st.markdown(
                """
                <div class="feat-card">
                    <div class="feat-icon icon-pink">📝</div>
                    <h4>Milestone Quiz</h4>
                    <p style="font-size: 0.84rem; color: rgba(255, 255, 255, 0.65);">Adaptive knowledge checks with real-time feedback, gamification XP & auto-progression.</p>
                </div>
                """,
                unsafe_allow_html=True,
            )

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
            st.markdown(
                f"""
                <div class="glass-card" style="margin-bottom:0; padding: 0.75rem 0.8rem;">
                    <div class="top-progress-label">Level Progress (Lvl {level_data['level']} → {level_data['level']+1})</div>
                    <div style="font-size:0.85rem; color:#F1F5F9; font-weight:700; margin-bottom:4px;">{total_xp} / {level_data['xp_for_next_level']} XP <span style="font-size:0.75rem; color:#94A3B8;">({level_data['xp_in_level']}/{level_data['xp_needed_for_next']} in Lvl)</span></div>
                </div>
                """,
                unsafe_allow_html=True,
            )
            st.progress(level_data["progress"])

        with prog_col4:
            st.markdown(
                f"""
                <div class="glass-card" style="margin-bottom:0; padding: 0.75rem 0.8rem;">
                    <div class="top-progress-label">Topic Completion</div>
                    <div style="font-size:0.85rem; color:#F1F5F9; font-weight:700; margin-bottom:4px;">{completed_steps} of {total_steps} Steps ({completed_steps/total_steps if total_steps else 0:.0%})</div>
                </div>
                """,
                unsafe_allow_html=True,
            )
            st.progress(completed_steps / total_steps if total_steps else 0.0)

        st.markdown("<br>", unsafe_allow_html=True)

        # ─── Linear Milestone Learning Roadmap Stepper ───────────────
        st.markdown("### 🗺️ **Milestone Learning Roadmap**")
        
        # Check active index
        active_idx = st.session_state.get("active_step_index", 0)
        if active_idx >= len(memory.steps):
            active_idx = 0

        # Render Linear Stepper Nodes
        num_steps = len(memory.steps)
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

        # Overall Linear Progress Bar
        st.progress(completed_steps / total_steps if total_steps else 0.0)

        current_step = memory.steps[active_idx]
        if current_step.status == StepStatus.PENDING:
            current_step.status = StepStatus.IN_PROGRESS

        # Auto-trigger Multi-Agent Execution once per step
        agents_ran_key = f"step_agents_ran_{active_idx}"
        is_already_generated = getattr(current_step, "_agent_generated", False) or st.session_state.get(agents_ran_key, False)

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

        col_s1, col_s2 = st.columns([2.6, 1.4], vertical_alignment="center")
        with col_s1:
            st.markdown(
                f"""
                <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 4px;">
                    <span style="background: rgba(99, 102, 241, 0.2); color: #818CF8; border: 1px solid rgba(99, 102, 241, 0.4); font-size: 0.72rem; font-weight: 800; padding: 2px 10px; border-radius: 9999px; text-transform: uppercase; letter-spacing: 0.8px;">Milestone {active_idx+1} of {num_steps}</span>
                </div>
                <h2 style="font-size: 1.45rem; font-weight: 800; color: #F8FAFC; margin: 0 0 4px 0;">{current_step.title}</h2>
                <div style="font-size: 0.9rem; color: #94A3B8; font-style: italic;">{current_step.description}</div>
                """,
                unsafe_allow_html=True,
            )
            prereq_val = getattr(current_step, "prerequisite", None)
            if prereq_val:
                st.markdown(f'<span class="prereq-badge">Prereq: {prereq_val}</span>', unsafe_allow_html=True)
            elif getattr(current_step, "is_prerequisite", False):
                st.markdown('<span class="prereq-badge">Prerequisite Step</span>', unsafe_allow_html=True)

        with col_s2:
            # UP: Status Pill Capsule (Right-Aligned)
            st.markdown(
                f"""
                <div style="display: flex; justify-content: flex-end; align-items: center; margin-bottom: 6px; width: 100%;">
                    <div class="pill-capsule pill-status-{status_class}">
                        <span class="pill-label">Status</span>
                        <span class="pill-icon-box">{status_icon}</span>
                        <span class="pill-value">{formatted_status}</span>
                    </div>
                </div>
                """,
                unsafe_allow_html=True,
            )
            # BELOW: Redesigned Regenerate Step Capsule Button (Right-Aligned Directly Below Status)
            if st.button(
                f"🔄 Regenerate Step {active_idx + 1}",
                key=f"regen_btn_{active_idx}",
                help=f"Re-run Socratic, YouTube, Academic & Quiz agents for Step {active_idx + 1}",
            ):
                setattr(current_step, "tutor_explanation", None)
                setattr(current_step, "videos", [])
                setattr(current_step, "papers", [])
                setattr(current_step, "quiz", [])
                st.session_state[f"step_agents_ran_{active_idx}"] = False
                setattr(current_step, "_agent_generated", False)
                st.rerun()

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

                # Native Chat Input Form
                with st.form(key=f"tutor_chat_form_{active_idx}", clear_on_submit=True):
                    c1, c2 = st.columns([4, 1])
                    with c1:
                        user_prompt = st.text_input(
                            "Ask Socratic Tutor...",
                            key=f"chat_in_{active_idx}",
                            placeholder="Type a question or ask for another analogy...",
                            label_visibility="collapsed",
                        )
                    with c2:
                        send_chat = st.form_submit_button("Send 💬", use_container_width=True)

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
                        
                        submit_quiz = st.form_submit_button("🚀 Submit Quiz")

                    if submit_quiz:
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
                        submit_quiz
                        or f"quiz_submitted_{active_idx}" in st.session_state
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
                            st.balloons()
                            st.success("🎉 **Congratulations! You have completed all milestone steps for this topic!**")

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

                    # Automatically move to Next Step if available!
                    if active_idx + 1 < len(memory.steps):
                        next_idx = active_idx + 1
                        st.session_state["active_step_index"] = next_idx
                        memory.steps[next_idx].status = StepStatus.IN_PROGRESS

                        # Pre-generate next step's multi-agent content automatically
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

                        st.toast(f"🎉 Quiz Passed ({score:.0%})! Automatically advancing to Step {next_idx + 1}!", icon="🚀")
                        time.sleep(1)
                        st.rerun()
                    else:
                        if not memory.is_complete:
                            memory.mark_step_complete(active_idx)
                            try:
                                from services.session_manager import SessionManager
                                run_async(SessionManager().update_session(memory))
                            except Exception as e:
                                logging.warning(f"Could not save final session state: {e}")
                        st.balloons()
                        st.success("🎉 **Congratulations! You have completed all milestone steps for this topic!**")


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
