"""
EduTechAI — JWT Authentication & Authorization Service Layer

Provides helper methods for JWT token creation, token decoding/verification,
user credential authentication, and current profile assembly.
"""

from __future__ import annotations

import hashlib
import logging
import os
import uuid
from datetime import datetime, timedelta, timezone

import jwt
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.exceptions import UnauthorizedException
from config import get_settings
from models.auth_schemas import UserCurrentProfileResponse
from models.db_models import User, Role, RefreshToken
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
            expire = now + timedelta(minutes=settings.jwt_access_expire_minutes)

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
        from sqlalchemy.orm import selectinload
        stmt = (
            select(User)
            .options(
                selectinload(User.roles).selectinload(Role.privileges),
                selectinload(User.subscription)
            )
            .where(User.email == email)
        )
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

    @staticmethod
    async def create_refresh_token(db: AsyncSession, user_id: str, family_id: str | None = None) -> str:
        settings = get_settings()
        
        # Generate a cryptographically secure random token
        raw_token = os.urandom(32).hex()
        
        # Hash it for storage
        token_hash = hashlib.sha256(raw_token.encode()).hexdigest()
        
        # Determine expiry
        now = datetime.now(timezone.utc)
        expires_at = now + timedelta(days=settings.jwt_refresh_expire_days)
        
        if family_id is None:
            family_id = str(uuid.uuid4())
            
        new_token_record = RefreshToken(
            user_id=user_id,
            token_hash=token_hash,
            family_id=family_id,
            expires_at=expires_at,
        )
        db.add(new_token_record)
        await db.commit()
        
        return raw_token

    @staticmethod
    async def rotate_refresh_token(db: AsyncSession, raw_token: str) -> tuple[str, str]:
        """
        Validates the provided refresh token, rotates it (issues a new one), 
        and returns a tuple of (new_access_token, new_refresh_token).
        
        If reuse is detected, revokes all tokens in the family.
        """
        token_hash = hashlib.sha256(raw_token.encode()).hexdigest()
        
        stmt = select(RefreshToken).where(RefreshToken.token_hash == token_hash)
        res = await db.execute(stmt)
        token_record = res.scalar_one_or_none()
        
        if not token_record:
            raise UnauthorizedException(
                error_code="INVALID_REFRESH_TOKEN",
                errors="Refresh token is invalid or does not exist."
            )
            
        now = datetime.now(timezone.utc)
        
        # Token reuse detection!
        if token_record.revoked_at is not None:
            # This token was already used or revoked!
            # We must revoke the entire family immediately to protect the user.
            revoke_stmt = select(RefreshToken).where(
                RefreshToken.family_id == token_record.family_id,
                RefreshToken.revoked_at.is_(None)
            )
            active_family_res = await db.execute(revoke_stmt)
            for rt in active_family_res.scalars().all():
                rt.revoked_at = now
            await db.commit()
            
            raise UnauthorizedException(
                error_code="TOKEN_REUSE_DETECTED",
                errors="Compromised session detected. Please log in again."
            )
            
        if token_record.expires_at < now:
            raise UnauthorizedException(
                error_code="REFRESH_TOKEN_EXPIRED",
                errors="Refresh token has expired. Please log in again."
            )
            
        # Token is valid! 
        # 1. Fetch user to ensure they are active and create new access token
        stmt_user = select(User).where(User.id == token_record.user_id)
        res_user = await db.execute(stmt_user)
        user = res_user.scalar_one_or_none()
        
        if user is None or user.retired:
            raise UnauthorizedException(
                error_code="USER_NOT_FOUND",
                errors="User account not found or retired."
            )
            
        # 2. Mark current refresh token as used/revoked
        token_record.revoked_at = now
        
        # 3. Issue a new access token
        new_access_token = AuthService.create_access_token({
            "sub": user.id,
            "email": user.email,
        })
        
        # 4. Issue a new refresh token within the same family
        new_refresh_token = await AuthService.create_refresh_token(db, user.id, family_id=token_record.family_id)
        
        return new_access_token, new_refresh_token
