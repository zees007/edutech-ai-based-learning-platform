"""
EduTechAI — Authentication & Authorization REST Router

Endpoints for user login, logout, and retrieving current user profile with privilege codes.
"""

from __future__ import annotations

from fastapi import APIRouter, Depends, Response
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies import get_current_user
from config import get_settings
from models.auth_schemas import LoginRequest, UserCurrentProfileResponse
from models.db_models import User
from services.auth_service import AuthService
from services.database import get_db

router = APIRouter()


@router.post("/auth/login")
async def login(
    request: LoginRequest,
    response: Response,
    db: AsyncSession = Depends(get_db),
):
    """
    Authenticate user with email and password.

    On successful authentication, creates a 60-minute JWT access token
    and sets an HTTP `access_token` cookie (`httponly=True`, `SameSite=Lax`).
    """
    settings = get_settings()
    user = await AuthService.authenticate_user(db, request.email, request.password)

    token = AuthService.create_access_token({
        "sub": user.id,
        "email": user.email,
    })

    # 60 minutes = 3600 seconds
    max_age_seconds = settings.jwt_expire_minutes * 60

    response.set_cookie(
        key="access_token",
        value=token,
        httponly=True,
        samesite="lax",
        max_age=max_age_seconds,
        path="/",
    )

    return {"message": "Logged in successfully"}


@router.post("/auth/logout")
async def logout(response: Response):
    """
    Log out current user by clearing the `access_token` HTTP cookie.
    """
    response.delete_cookie(key="access_token", path="/")
    return {"message": "Logged out successfully"}


@router.get("/auth/me", response_model=UserCurrentProfileResponse)
async def get_current_user_profile(
    current_user: User = Depends(get_current_user),
):
    """
    Retrieve profile details, assigned roles, subscription status, and
    flat list of active privilege codes for the currently authenticated user.
    """
    return AuthService.get_user_current_profile(current_user)
