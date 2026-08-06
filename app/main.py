"""
EduTechAI — FastAPI Application Factory

The main FastAPI app with CORS, lifespan handlers, and router mounting.
"""

from __future__ import annotations

import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from config import get_settings
from services.database import close_db, init_db

logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Application lifespan handler.
    Runs on startup and shutdown.
    """
    # ─── Startup ─────────────────────────────────────────────
    settings = get_settings()
    logger.info("Starting EduTechAI...")

    # Initialize database (create tables if needed)
    await init_db(settings)
    logger.info("Database initialized.")

    # Ensure data directory exists
    settings.data_dir
    logger.info(f"Server running at http://{settings.host}:{settings.port}")

    yield  # App runs here

    # ─── Shutdown ────────────────────────────────────────────
    await close_db()
    logger.info("EduTechAI shutdown complete.")


def create_app() -> FastAPI:
    """Create and configure the FastAPI application."""
    settings = get_settings()

    app = FastAPI(
        title="EduTechAI",
        description=(
            "Adaptive AI-powered learning platform with multi-agent "
            "Socratic tutoring, YouTube clips, academic resources, and quizzes."
        ),
        version="0.1.0",
        lifespan=lifespan,
        debug=settings.debug,
    )

    # ─── CORS ────────────────────────────────────────────────
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],  # Permissive for local dev; tighten for production
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # ─── Routers ─────────────────────────────────────────────
    from app.routers import learning, quiz, websocket

    app.include_router(learning.router, prefix="/api", tags=["Learning"])
    app.include_router(quiz.router, prefix="/api", tags=["Quiz"])
    app.include_router(websocket.router, tags=["WebSocket"])

    # ─── Health Check ────────────────────────────────────────
    from models.schemas import HealthResponse

    @app.get("/health", response_model=HealthResponse, tags=["System"])
    async def health_check():
        return HealthResponse()

    return app
