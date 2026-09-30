"""
EduTechAI — Authentication & Authorization REST Router

Endpoints for user login, logout, and retrieving current user profile with privilege codes.
"""

from __future__ import annotations

from fastapi import APIRouter, Depends, Response, Request, Cookie
import hashlib
from datetime import datetime, timezone
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.dependencies import get_current_user
from app.exceptions import UnauthorizedException
from config import get_settings
from models.auth_schemas import LoginRequest, UserCurrentProfileResponse
from models.db_models import User, RefreshToken
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

    access_token = AuthService.create_access_token({
        "sub": user.id,
        "email": user.email,
    })
    
    refresh_token = await AuthService.create_refresh_token(db, user.id)

    access_max_age = settings.jwt_access_expire_minutes * 60
    refresh_max_age = settings.jwt_refresh_expire_days * 86400

    response.set_cookie(
        key="access_token",
        value=access_token,
        httponly=True,
        samesite="lax",
        max_age=access_max_age,
        path="/",
    )
    
    response.set_cookie(
        key="refresh_token",
        value=refresh_token,
        httponly=True,
        samesite="lax",
        max_age=refresh_max_age,
        path="/",
    )

    return {"message": "Logged in successfully", "access_token": access_token, "refresh_token": refresh_token}


@router.post("/auth/refresh")
async def refresh(
    request: Request,
    response: Response,
    db: AsyncSession = Depends(get_db),
    refresh_token: str | None = Cookie(default=None, alias="refresh_token"),
):
    if not refresh_token:
        # Fallback to body
        body = await request.json() if request.headers.get("content-type") == "application/json" else {}
        refresh_token = body.get("refresh_token") if body else None
        
    if not refresh_token:
        raise UnauthorizedException(
            error_code="TOKEN_MISSING",
            errors="Refresh token is missing."
        )
        
    new_access_token, new_refresh_token = await AuthService.rotate_refresh_token(db, refresh_token)
    
    settings = get_settings()
    access_max_age = settings.jwt_access_expire_minutes * 60
    refresh_max_age = settings.jwt_refresh_expire_days * 86400

    response.set_cookie(
        key="access_token",
        value=new_access_token,
        httponly=True,
        samesite="lax",
        max_age=access_max_age,
        path="/",
    )
    response.set_cookie(
        key="refresh_token",
        value=new_refresh_token,
        httponly=True,
        samesite="lax",
        max_age=refresh_max_age,
        path="/",
    )
    
    return {"message": "Token refreshed successfully", "access_token": new_access_token, "refresh_token": new_refresh_token}


@router.post("/auth/logout")
async def logout(
    response: Response,
    db: AsyncSession = Depends(get_db),
    refresh_token: str | None = Cookie(default=None, alias="refresh_token"),
):
    """
    Log out current user by revoking the refresh token and clearing cookies.
    """
    if refresh_token:
        token_hash = hashlib.sha256(refresh_token.encode()).hexdigest()
        stmt = select(RefreshToken).where(RefreshToken.token_hash == token_hash)
        res = await db.execute(stmt)
        token_record = res.scalar_one_or_none()
        if token_record and token_record.revoked_at is None:
            token_record.revoked_at = datetime.now(timezone.utc)
            await db.commit()

    response.delete_cookie(key="access_token", path="/")
    response.delete_cookie(key="refresh_token", path="/")
    return {"message": "Logged out successfully"}


@router.post("/auth/logout-all")
async def logout_all(
    response: Response,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Sign out of all devices by revoking all refresh tokens and invalidating access tokens.
    """
    now = datetime.now(timezone.utc)
    
    # 1. Revoke all active refresh tokens for the user
    stmt = select(RefreshToken).where(
        RefreshToken.user_id == current_user.id,
        RefreshToken.revoked_at.is_(None)
    )
    res = await db.execute(stmt)
    for rt in res.scalars().all():
        rt.revoked_at = now
        
    # 2. Invalidate all currently issued access tokens instantly
    current_user.tokens_invalidated_before = now
    await db.commit()
    
    response.delete_cookie(key="access_token", path="/")
    response.delete_cookie(key="refresh_token", path="/")
    return {"message": "Logged out of all devices successfully"}


@router.get("/auth/me", response_model=UserCurrentProfileResponse)
async def get_current_user_profile(
    current_user: User = Depends(get_current_user),
):
    """
    Retrieve profile details, assigned roles, subscription status, and
    flat list of active privilege codes for the currently authenticated user.
    """
    return AuthService.get_user_current_profile(current_user)
