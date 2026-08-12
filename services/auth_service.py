"""
EduTechAI — JWT Authentication & Authorization Service Layer

Provides helper methods for JWT token creation, token decoding/verification,
user credential authentication, and current profile assembly.
"""

from __future__ import annotations

import logging
from datetime import datetime, timedelta, timezone

import jwt
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.exceptions import UnauthorizedException
from config import get_settings
from models.auth_schemas import UserCurrentProfileResponse
from models.db_models import User
from models.subscription_schemas import SubscriptionResponse
from services.user_service import UserService

logger = logging.getLogger(__name__)


class AuthService:
    """Service layer for JWT creation, verification, and user authentication."""

    @staticmethod
    def create_access_token(
        data: dict,
        expires_delta: timedelta | None = None,
    ) -> str:
        """
        Create a signed JWT access token.

        By default, sets expiration to `jwt_expire_minutes` (60 minutes) from current UTC time.
        Uses HS256 algorithm and configured JWT_SECRET_KEY.
        """
        settings = get_settings()
        to_encode = data.copy()

        now = datetime.now(timezone.utc)
        if expires_delta:
            expire = now + expires_delta
        else:
            expire = now + timedelta(minutes=settings.jwt_expire_minutes)

        to_encode.update({
            "iat": now,
            "exp": expire,
        })

        encoded_jwt = jwt.encode(
            to_encode,
            settings.jwt_secret_key,
            algorithm=settings.jwt_algorithm,
        )
        return encoded_jwt

    @staticmethod
    def decode_access_token(token: str) -> dict:
        """
        Decode and verify a JWT access token.

        Raises UnauthorizedException if signature has expired or token format is invalid.
        """
        settings = get_settings()
        try:
            payload = jwt.decode(
                token,
                settings.jwt_secret_key,
                algorithms=[settings.jwt_algorithm],
            )
            return payload
        except jwt.ExpiredSignatureError:
            raise UnauthorizedException(
                error_code="TOKEN_EXPIRED",
                errors="Session expired. Please login again.",
            )
        except jwt.InvalidTokenError:
            raise UnauthorizedException(
                error_code="INVALID_TOKEN",
                errors="Invalid authentication token provided.",
            )

    @staticmethod
    async def authenticate_user(
        db: AsyncSession,
        email: str,
        password: str,
    ) -> User:
        """
        Validate user login credentials.

        Raises UnauthorizedException on invalid credentials or retired account status.
        """
        stmt = select(User).where(User.email == email)
        res = await db.execute(stmt)
        user = res.scalar_one_or_none()

        if user is None:
            raise UnauthorizedException(
                error_code="INVALID_CREDENTIALS",
                errors="Invalid email address or password.",
            )

        if user.retired:
            raise UnauthorizedException(
                error_code="USER_RETIRED",
                errors="Your account has been retired. Please contact support.",
            )

        if not UserService.verify_password(password, user.password_hash):
            raise UnauthorizedException(
                error_code="INVALID_CREDENTIALS",
                errors="Invalid email address or password.",
            )

        return user

    @staticmethod
    def get_user_current_profile(user: User) -> UserCurrentProfileResponse:
        """
        Build unified profile for currently authenticated user.

        Computes flat deduplicated list of active privilege codes across assigned active roles.
        """
        active_roles = [r for r in user.roles if not r.retired]
        role_names = [r.name for r in active_roles if r.name]

        unique_privilege_codes: set[str] = set()
        for role in active_roles:
            for priv in role.privileges:
                if priv.code:
                    unique_privilege_codes.add(priv.code)

        privilege_codes_list = sorted(list(unique_privilege_codes))

        subscription_response = (
            SubscriptionResponse.model_validate(user.subscription)
            if user.subscription
            else None
        )

        return UserCurrentProfileResponse(
            id=user.id,
            first_name=user.first_name,
            last_name=user.last_name,
            email=user.email,
            mobile=user.mobile,
            country=user.country,
            created_at=user.created_at,
            roles=role_names,
            subscription=subscription_response,
            privilege_codes=privilege_codes_list,
        )
