"""
EduTechAI — FastAPI Authentication & Authorization Security Dependencies

Provides get_current_user dependency and declarative privilege/role guard factories.
"""

from __future__ import annotations

import logging

from fastapi import Cookie, Depends, Request
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.exceptions import ForbiddenException, UnauthorizedException
from models.db_models import User
from services.auth_service import AuthService
from services.database import get_db

logger = logging.getLogger(__name__)


def get_token_from_cookie_or_header(
    request: Request,
    access_token: str | None = Cookie(default=None, alias="access_token"),
) -> str:
    """
    Extract JWT token string from HTTP cookie or Authorization header fallback.

    First checks HTTP `access_token` cookie. If missing or empty, checks `Authorization: Bearer <token>`.
    Raises UnauthorizedException if neither token is present.
    """
    if access_token and access_token.strip():
        return access_token.strip()

    auth_header = request.headers.get("Authorization")
    if auth_header and auth_header.startswith("Bearer "):
        token_val = auth_header[7:].strip()
        if token_val:
            return token_val

    raise UnauthorizedException(
        error_code="UNAUTHORIZED",
        errors="Authentication required. Please log in.",
    )


async def get_current_user(
    db: AsyncSession = Depends(get_db),
    token: str = Depends(get_token_from_cookie_or_header),
) -> User:
    """
    FastAPI security dependency to retrieve the currently authenticated active User.

    Decodes JWT token, validates claims, and verifies active user status in database.
    """
    payload = AuthService.decode_access_token(token)
    user_id = payload.get("sub")

    if not user_id:
        raise UnauthorizedException(
            error_code="INVALID_TOKEN",
            errors="Token payload is invalid or missing subject.",
        )

    stmt = select(User).where(User.id == user_id)
    res = await db.execute(stmt)
    user = res.scalar_one_or_none()

    if user is None or user.retired:
        raise UnauthorizedException(
            error_code="USER_NOT_FOUND",
            errors="Authenticated user not found or account is retired.",
        )

    return user


def require_privilege(*privilege_codes: str):
    """
    FastAPI security dependency factory for fine-grained privilege check.
    Accepts one or more privilege codes. User must possess at least one matching privilege.

    Supports ET_ALL (SuperAdmin bypass), direct privilege code matching,
    and parent privilege group access matching (e.g. ET_FULL_ACCESS_USER grants ET_CREATE_USER).
    """

    async def privilege_checker(
        current_user: User = Depends(get_current_user),
    ) -> User:
        user_privs = {
            priv.code
            for role in current_user.roles if not role.retired
            for priv in role.privileges
            if priv.code
        }

        # 1. Global SuperAdmin privilege bypass
        if "ET_ALL" in user_privs:
            return current_user

        for code in privilege_codes:
            # 2. Direct privilege code match
            if code in user_privs:
                return current_user

            # 3. Module level FULL_ACCESS parent match (e.g., ET_FULL_ACCESS_USER -> ET_CREATE_USER)
            if "_" in code:
                parts = code.split("_")
                domain = parts[-1]  # e.g., USER, ROLE, SUBSCRIPTION, LEARNING, QUIZ
                parent_group_code = f"ET_FULL_ACCESS_{domain}"
                if parent_group_code in user_privs:
                    return current_user

        codes_str = ", ".join(f"'{c}'" for c in privilege_codes)
        raise ForbiddenException(
            error_code="PERMISSION_DENIED",
            errors=f"Access denied. Missing required privilege: {codes_str}.",
        )

    return privilege_checker


def require_role(role_name: str):
    """
    FastAPI security dependency factory for role-based authorization check.
    """

    async def role_checker(
        current_user: User = Depends(get_current_user),
    ) -> User:
        user_role_names = {
            role.name for role in current_user.roles if not role.retired
        }

        if role_name not in user_role_names:
            raise ForbiddenException(
                error_code="ROLE_REQUIRED",
                errors=f"Access denied. Required role: '{role_name}'.",
            )
        return current_user

    return role_checker
