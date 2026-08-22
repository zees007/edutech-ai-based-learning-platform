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
from models.db_models import Privilege, Role, Subscription, User
from models.role_schemas import PrivilegeResponse, RoleResponse, UserPrivilegesResponse
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
        Dynamically fetches and assigns the active 'Free' tier role and initializes a 'free' subscription.
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

        # Query default 'Free' subscription tier role dynamically from DB
        role_stmt = select(Role).where(Role.name == "Free", Role.retired == False)
        role_res = await db.execute(role_stmt)
        free_role = role_res.scalar_one_or_none()

        roles_to_assign = [free_role] if free_role else []

        user = User(
            first_name=dto.first_name,
            last_name=dto.last_name,
            email=dto.email,
            password_hash=hashed_password,
            mobile=dto.mobile,
            country=dto.country,
            roles=roles_to_assign,
        )
        db.add(user)
        await db.flush()

        # Create active default subscription
        subscription = Subscription(
            user_id=user.id,
            tier="free",
            status="active",
        )
        db.add(subscription)

        await db.commit()
        await db.refresh(user)
        logger.info(f"User created with default 'Free' role & subscription: {user.id} ({user.email})")
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

    @staticmethod
    async def assign_roles_to_user(db: AsyncSession, user_id: str, role_ids: list[str]) -> User:
        """
        Assign a set of roles to a user. Validates role IDs exist and are not retired.
        Raises NotFoundException if user not found, or BadRequestException if invalid role ID.
        """
        user = await UserService.get_user_by_id(db, user_id)

        roles: list[Role] = []
        if role_ids:
            r_stmt = select(Role).where(Role.id.in_(role_ids), Role.retired == False)
            r_res = await db.execute(r_stmt)
            roles = list(r_res.scalars().all())

            found_ids = {r.id for r in roles}
            missing_ids = [rid for rid in set(role_ids) if rid not in found_ids]
            if missing_ids:
                raise BadRequestException(
                    error_code="INVALID_ROLE_ID",
                    errors=f"Role ID(s) {missing_ids} do not exist or are retired.",
                )

        user.roles = roles
        await db.commit()
        await db.refresh(user)
        logger.info(f"Updated roles for user {user.id}: {[r.name for r in roles]}")
        return user

    @staticmethod
    async def get_user_with_roles_and_privileges(db: AsyncSession, user_id: str) -> UserPrivilegesResponse:
        """
        Fetch a user's assigned roles and calculate all unique privileges granted.
        """
        user = await UserService.get_user_by_id(db, user_id)

        unique_privileges: dict[int, Privilege] = {}
        for role in user.roles:
            if not role.retired:
                for priv in role.privileges:
                    unique_privileges[priv.id] = priv

        privilege_list = [
            PrivilegeResponse.model_validate(p)
            for p in sorted(unique_privileges.values(), key=lambda p: (p.order_number or 0, p.id))
        ]
        privilege_codes = [p.code for p in privilege_list]
        role_responses = [RoleResponse.model_validate(r) for r in user.roles if not r.retired]

        return UserPrivilegesResponse(
            user_id=user.id,
            roles=role_responses,
            privileges=privilege_list,
            privilege_codes=privilege_codes,
        )

