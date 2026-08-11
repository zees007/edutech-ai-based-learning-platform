"""
EduTechAI — User Service Layer

Encapsulates database access and business logic for user management operations.
"""

from __future__ import annotations

import logging
from datetime import datetime, timezone
import math

import bcrypt
from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.exceptions import BadRequestException, ConflictException, NotFoundException
from models.db_models import User
from models.user_schemas import ChangePasswordRequest, SearchDTO, UserCreateRequest, UserEditRequest

logger = logging.getLogger(__name__)


class UserService:
    """Service layer for user operations."""

    @staticmethod
    def hash_password(password: str) -> str:
        """Hash a plaintext password using bcrypt."""
        pw_bytes = password.encode("utf-8")[:72]
        salt = bcrypt.gensalt()
        return bcrypt.hashpw(pw_bytes, salt).decode("utf-8")

    @staticmethod
    def verify_password(plain_password: str, hashed_password: str) -> bool:
        """Verify a plaintext password against a bcrypt hash."""
        pw_bytes = plain_password.encode("utf-8")[:72]
        hash_bytes = hashed_password.encode("utf-8")
        return bcrypt.checkpw(pw_bytes, hash_bytes)

    @staticmethod
    async def create_user(db: AsyncSession, dto: UserCreateRequest) -> User:
        """
        Create a new user. Raises ConflictException if email already exists.
        """
        # Check duplicate email
        stmt = select(User).where(User.email == dto.email)
        res = await db.execute(stmt)
        if res.scalar_one_or_none() is not None:
            raise ConflictException(
                error_code="EMAIL_ALREADY_EXISTS",
                errors=f"A user with email '{dto.email}' already exists.",
            )

        hashed_password = UserService.hash_password(dto.password)

        user = User(
            first_name=dto.first_name,
            last_name=dto.last_name,
            email=dto.email,
            password_hash=hashed_password,
            mobile=dto.mobile,
            country=dto.country,
        )
        db.add(user)
        await db.commit()
        await db.refresh(user)
        logger.info(f"User created: {user.id} ({user.email})")
        return user

    @staticmethod
    async def get_user_by_id(db: AsyncSession, user_id: str) -> User:
        """
        Retrieve user by ID. Raises NotFoundException if not found.
        """
        stmt = select(User).where(User.id == user_id)
        res = await db.execute(stmt)
        user = res.scalar_one_or_none()
        if user is None:
            raise NotFoundException(
                error_code="USER_NOT_FOUND",
                errors=f"User with ID '{user_id}' was not found.",
            )
        return user

    @staticmethod
    async def edit_user(db: AsyncSession, user_id: str, dto: UserEditRequest) -> User:
        """
        Update user attributes. Raises NotFoundException if user not found,
        or ConflictException if email is updated to an existing email.
        """
        user = await UserService.get_user_by_id(db, user_id)

        if dto.email is not None and dto.email != user.email:
            stmt = select(User).where(User.email == dto.email, User.id != user_id)
            res = await db.execute(stmt)
            if res.scalar_one_or_none() is not None:
                raise ConflictException(
                    error_code="EMAIL_ALREADY_EXISTS",
                    errors=f"A user with email '{dto.email}' already exists.",
                )
            user.email = dto.email

        if dto.first_name is not None:
            user.first_name = dto.first_name
        if dto.last_name is not None:
            user.last_name = dto.last_name
        if dto.mobile is not None:
            user.mobile = dto.mobile
        if dto.country is not None:
            user.country = dto.country

        await db.commit()
        await db.refresh(user)
        logger.info(f"User updated: {user.id}")
        return user

    @staticmethod
    async def change_password(db: AsyncSession, user_id: str, dto: ChangePasswordRequest) -> User:
        """
        Change user's password. Validates old_password before setting new_password.
        Raises NotFoundException if user not found, or BadRequestException if old_password invalid.
        """
        user = await UserService.get_user_by_id(db, user_id)

        if not UserService.verify_password(dto.old_password, user.password_hash):
            raise BadRequestException(
                error_code="INVALID_OLD_PASSWORD",
                errors="Old password is incorrect.",
            )

        user.password_hash = UserService.hash_password(dto.new_password)
        await db.commit()
        await db.refresh(user)
        logger.info(f"Password changed for user: {user.id}")
        return user

    @staticmethod
    async def retire_user(db: AsyncSession, user_id: str) -> User:
        """
        Soft-retire a user by setting retired=True and recording retired_at.
        Raises NotFoundException if user not found.
        """
        user = await UserService.get_user_by_id(db, user_id)
        if user.retired:
            raise BadRequestException(
                error_code="USER_ALREADY_RETIRED",
                errors=f"User with ID '{user_id}' is already retired.",
            )

        user.retired = True
        user.retired_at = datetime.now(timezone.utc).replace(tzinfo=None)
        user.retired_by = None  # Auth system not implemented yet

        await db.commit()
        await db.refresh(user)
        logger.info(f"User retired: {user.id}")
        return user

    @staticmethod
    async def search_users(db: AsyncSession, dto: SearchDTO) -> tuple[list[User], int]:
        """
        Search active users (retired=False) with 0-indexed pagination, sorting, and lookupText filtering.
        Returns tuple of (users_list, total_count).
        """
        # Always exclude retired users — only active users returned
        query = select(User).where(User.retired == False)

        # Lookup text search across first_name, last_name, email, mobile
        lookup = dto.lookupText
        if lookup and lookup.strip():
            term = f"%{lookup.strip()}%"
            query = query.where(
                or_(
                    User.first_name.ilike(term),
                    User.last_name.ilike(term),
                    User.email.ilike(term),
                    User.mobile.ilike(term),
                )
            )

        # Count total matching active records before pagination
        count_query = select(func.count()).select_from(query.subquery())
        total_res = await db.execute(count_query)
        total = total_res.scalar_one() or 0

        # Sort field resolution supporting both camelCase ("createdAt") and snake_case ("created_at")
        raw_sort = (dto.sortBy or "created_at").lower().replace("_", "")
        sort_map = {
            "createdat": User.created_at,
            "firstname": User.first_name,
            "lastname": User.last_name,
            "email": User.email,
            "mobile": User.mobile,
            "country": User.country,
            "id": User.id,
        }
        sort_column = sort_map.get(raw_sort, User.created_at)

        if dto.isDesc:
            query = query.order_by(sort_column.desc())
        else:
            query = query.order_by(sort_column.asc())

        # 0-indexed pagination offset
        offset = dto.page * dto.size
        query = query.offset(offset).limit(dto.size)

        res = await db.execute(query)
        users = list(res.scalars().all())

        return users, total
