"""
EduTechAI — Role Management REST Router

API endpoints for managing roles:
- POST   /api/v1/roles/create   — Create a role
- PUT    /api/v1/roles/{id}/edit — Edit role & privileges
- DELETE /api/v1/roles/{id}/retire — Soft-retire role
- GET    /api/v1/roles/{id}     — Get role by ID
- GET    /api/v1/roles/search   — Search & list roles (paginated)
"""

from __future__ import annotations

import math
from typing import Annotated

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from models.role_schemas import (
    PaginatedRoleResponse,
    RoleCreateRequest,
    RoleEditRequest,
    RoleResponse,
)
from models.user_schemas import SearchDTO
from services.database import get_db
from services.role_service import RoleService

router = APIRouter()


@router.post("/roles/create", response_model=RoleResponse, status_code=201)
async def create_role(
    request: RoleCreateRequest,
    db: AsyncSession = Depends(get_db),
):
    """Create a new role with associated privilege IDs."""
    role = await RoleService.create_role(db, request)
    return RoleResponse.model_validate(role)


@router.get("/roles/search", response_model=PaginatedRoleResponse)
async def search_roles(
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
    Search active roles (retired=False) with 0-indexed pagination, sorting, and lookupText.
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
    roles, total = await RoleService.search_roles(db, search_dto)
    total_pages = math.ceil(total / size) if total > 0 else 0

    return PaginatedRoleResponse(
        items=[RoleResponse.model_validate(r) for r in roles],
        total=total,
        page=page,
        size=size,
        total_pages=total_pages,
    )


@router.get("/roles/{role_id}", response_model=RoleResponse)
async def get_role_by_id(
    role_id: str,
    db: AsyncSession = Depends(get_db),
):
    """Retrieve role details by UUID."""
    role = await RoleService.get_role_by_id(db, role_id)
    return RoleResponse.model_validate(role)


@router.put("/roles/{role_id}/edit", response_model=RoleResponse)
async def edit_role(
    role_id: str,
    request: RoleEditRequest,
    db: AsyncSession = Depends(get_db),
):
    """Edit role details and privilege assignments."""
    role = await RoleService.edit_role(db, role_id, request)
    return RoleResponse.model_validate(role)


@router.delete("/roles/{role_id}/retire")
async def retire_role(
    role_id: str,
    db: AsyncSession = Depends(get_db),
):
    """Soft-retire a role using DELETE method."""
    await RoleService.retire_role(db, role_id)
    return {"message": "Role retired successfully"}
