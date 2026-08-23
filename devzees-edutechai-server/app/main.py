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

    # ─── Exception Handlers ──────────────────────────────────
    from datetime import datetime, timezone
    from fastapi import Request
    from fastapi.responses import JSONResponse
    from app.exceptions import APIError, AppException

    @app.exception_handler(AppException)
    async def app_exception_handler(request: Request, exc: AppException) -> JSONResponse:
        error_payload = APIError(
            http_status=exc.status_code,
            errors=exc.errors,
            timestamp=datetime.now(timezone.utc),
            path_uri=str(request.url.path),
            error_code=exc.error_code,
        )
        return JSONResponse(
            status_code=exc.status_code,
            content=error_payload.model_dump(mode="json"),
        )

    from fastapi.exceptions import RequestValidationError

    @app.exception_handler(RequestValidationError)
    async def validation_exception_handler(request: Request, exc: RequestValidationError) -> JSONResponse:
        errors = []
        for err in exc.errors():
            msg = err.get("msg", "Validation error.")
            if msg.startswith("Value error, "):
                msg = msg[len("Value error, "):]
            errors.append(msg)

        error_payload = APIError(
            http_status=422,
            errors=errors,
            timestamp=datetime.now(timezone.utc),
            path_uri=str(request.url.path),
            error_code="VALIDATION_ERROR",
        )
        return JSONResponse(
            status_code=422,
            content=error_payload.model_dump(mode="json"),
        )

    @app.exception_handler(Exception)
    async def unhandled_exception_handler(request: Request, exc: Exception) -> JSONResponse:
        logger.error(f"Unhandled exception on {request.url.path}: {exc}", exc_info=True)
        error_payload = APIError(
            http_status=500,
            errors=["An unexpected internal server error occurred."],
            timestamp=datetime.now(timezone.utc),
            path_uri=str(request.url.path),
            error_code="INTERNAL_SERVER_ERROR",
        )
        return JSONResponse(
            status_code=500,
            content=error_payload.model_dump(mode="json"),
        )

    # ─── Routers ─────────────────────────────────────────────
    from app.routers import auth, learning, quiz, roles, subscriptions, users, websocket, exports

    app.include_router(auth.router, prefix="/api/v1", tags=["Auth"])
    app.include_router(learning.router, prefix="/api", tags=["Learning"])
    app.include_router(exports.router, prefix="/api", tags=["Exports"])
    app.include_router(quiz.router, prefix="/api", tags=["Quiz"])
    app.include_router(users.router, prefix="/api/v1", tags=["Users"])
    app.include_router(roles.router, prefix="/api/v1", tags=["Roles"])
    app.include_router(subscriptions.router, prefix="/api/v1", tags=["Subscriptions"])
    app.include_router(websocket.router, tags=["WebSocket"])

    # ─── Health Check ────────────────────────────────────────
    from models.schemas import HealthResponse

    @app.get("/health", response_model=HealthResponse, tags=["System"])
    async def health_check():
        return HealthResponse()

    return app
