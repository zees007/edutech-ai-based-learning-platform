"""
EduTechAI — User Management REST Router

API endpoints for managing users:
- POST  /api/v1/users/create   — Create a user
- PUT   /api/v1/users/{id}/edit — Edit user
- PATCH /api/v1/users/{id}/retire — Soft-retire user
- GET   /api/v1/users/{id}     — Get user by ID
- GET   /api/v1/users/search   — Search & list users (paginated)
"""

from __future__ import annotations

import math
from typing import Annotated

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from models.user_schemas import (
    ChangePasswordRequest,
    PaginatedUserResponse,
    SearchDTO,
    UserCreateRequest,
    UserEditRequest,
    UserResponse,
)
from services.database import get_db
from services.user_service import UserService

router = APIRouter()


@router.post("/users/create", response_model=UserResponse, status_code=201)
async def create_user(
    request: UserCreateRequest,
    db: AsyncSession = Depends(get_db),
):
    """Create a new user profile."""
    user = await UserService.create_user(db, request)
    return UserResponse.model_validate(user)


@router.get("/users/search", response_model=PaginatedUserResponse)
async def search_users(
    page: Annotated[int, Query(ge=0, description="Page number (0-indexed)")] = 0,
    size: Annotated[int, Query(ge=1, le=100, description="Page size")] = 10,
    sortBy: Annotated[str | None, Query(alias="sortBy", description="Sort field name")] = None,
    sort_by: Annotated[str | None, Query(alias="sort_by")] = None,
    isDesc: Annotated[bool | None, Query(alias="isDesc", description="Sort descending")] = None,
    is_desc: Annotated[bool | None, Query(alias="is_desc")] = None,
    lookupText: Annotated[str | None, Query(alias="lookupText", description="Search term")] = None,
    lookup_text: Annotated[str | None, Query(alias="lookup_text")] = None,
    db: AsyncSession = Depends(get_db),
):
    """
    Search active users (retired=False) with 0-indexed pagination, sorting, and lookupText.
    If lookupText is null or blank, returns all active users.
    """
    final_sort_by = sort_by or sortBy or "created_at"
    final_is_desc = is_desc if is_desc is not None else (isDesc if isDesc is not None else True)
    final_lookup_text = lookup_text if lookup_text is not None else lookupText

    search_dto = SearchDTO(
        page=page,
        size=size,
        sortBy=final_sort_by,
        isDesc=final_is_desc,
        lookupText=final_lookup_text,
    )
    users, total = await UserService.search_users(db, search_dto)
    total_pages = math.ceil(total / size) if total > 0 else 0

    return PaginatedUserResponse(
        items=[UserResponse.model_validate(u) for u in users],
        total=total,
        page=page,
        size=size,
        total_pages=total_pages,
    )


@router.get("/users/{user_id}", response_model=UserResponse)
async def get_user_by_id(
    user_id: str,
    db: AsyncSession = Depends(get_db),
):
    """Retrieve user details by UUID."""
    user = await UserService.get_user_by_id(db, user_id)
    return UserResponse.model_validate(user)


@router.put("/users/{user_id}/edit", response_model=UserResponse)
async def edit_user(
    user_id: str,
    request: UserEditRequest,
    db: AsyncSession = Depends(get_db),
):
    """Edit user profile details (password excluded)."""
    user = await UserService.edit_user(db, user_id, request)
    return UserResponse.model_validate(user)


@router.patch("/users/{user_id}/change-password")
async def change_password(
    user_id: str,
    request: ChangePasswordRequest,
    db: AsyncSession = Depends(get_db),
):
    """Change user password after verifying old password and confirm password matching."""
    await UserService.change_password(db, user_id, request)
    return {"message": "Password has been changed successfully"}


@router.delete("/users/{user_id}/retire")
async def retire_user(
    user_id: str,
    db: AsyncSession = Depends(get_db),
):
    """Soft-retire a user account using DELETE method."""
    await UserService.retire_user(db, user_id)
    return {"message": "User retired successfully"}


from models.role_schemas import UserPrivilegesResponse
from models.user_schemas import UserRoleAssignRequest


@router.put("/users/{user_id}/roles", response_model=UserResponse)
async def assign_user_roles(
    user_id: str,
    request: UserRoleAssignRequest,
    db: AsyncSession = Depends(get_db),
):
    """Assign or update roles for a specific user."""
    user = await UserService.assign_roles_to_user(db, user_id, request.role_ids)
    return UserResponse.model_validate(user)


@router.get("/users/{user_id}/roles", response_model=UserPrivilegesResponse)
async def get_user_roles_and_privileges(
    user_id: str,
    db: AsyncSession = Depends(get_db),
):
    """Get assigned roles and computed fine-grained privileges for a user."""
    return await UserService.get_user_with_roles_and_privileges(db, user_id)

