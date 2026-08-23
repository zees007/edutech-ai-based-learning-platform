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

from app.dependencies import require_privilege
from app.privileges_config import (
    ET_CREATE_ROLE,
    ET_EDIT_ROLE,
    ET_RETIRE_ROLE,
    ET_SEARCH_ROLE,
    ET_VIEW_PRIVILEGE,
    ET_VIEW_ROLE,
)
from models.role_schemas import (
    PaginatedRoleResponse,
    PrivilegeResponse,
    PrivilegeTreeResponse,
    RoleCreateRequest,
    RoleEditRequest,
    RoleResponse,
)
from models.user_schemas import SearchDTO
from services.database import get_db
from services.role_service import RoleService

router = APIRouter()


@router.get(
    "/privileges/tree",
    response_model=list[PrivilegeTreeResponse],
    dependencies=[Depends(require_privilege(ET_VIEW_PRIVILEGE))],
)
async def get_privilege_tree(
    db: AsyncSession = Depends(get_db),
):
    """
    Get all privileges as a nested hierarchical tree structure.
    Top-level privileges (parent_id = null) are returned at root level,
    with nested children populated recursively for UI tree rendering.
    """
    return await RoleService.get_privilege_tree(db)


@router.get(
    "/privileges",
    response_model=list[PrivilegeResponse],
    dependencies=[Depends(require_privilege(ET_VIEW_PRIVILEGE))],
)
async def get_all_privileges(
    db: AsyncSession = Depends(get_db),
):
    """Get flat list of all privileges ordered by order_number and ID."""
    privileges = await RoleService.get_all_privileges(db)
    return [PrivilegeResponse.model_validate(p) for p in privileges]


@router.post(
    "/roles/create",
    response_model=RoleResponse,
    status_code=201,
    dependencies=[Depends(require_privilege(ET_CREATE_ROLE))],
)
async def create_role(
    request: RoleCreateRequest,
    db: AsyncSession = Depends(get_db),
):
    """Create a new role with associated privilege IDs."""
    role = await RoleService.create_role(db, request)
    return RoleResponse.model_validate(role)


@router.get(
    "/roles/search",
    response_model=PaginatedRoleResponse,
    dependencies=[Depends(require_privilege(ET_SEARCH_ROLE))],
)
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


@router.get(
    "/roles/{role_id}",
    response_model=RoleResponse,
    dependencies=[Depends(require_privilege(ET_VIEW_ROLE))],
)
async def get_role_by_id(
    role_id: str,
    db: AsyncSession = Depends(get_db),
):
    """Retrieve role details by UUID."""
    role = await RoleService.get_role_by_id(db, role_id)
    return RoleResponse.model_validate(role)


@router.put(
    "/roles/{role_id}/edit",
    response_model=RoleResponse,
    dependencies=[Depends(require_privilege(ET_EDIT_ROLE))],
)
async def edit_role(
    role_id: str,
    request: RoleEditRequest,
    db: AsyncSession = Depends(get_db),
):
    """Edit role details and privilege assignments."""
    role = await RoleService.edit_role(db, role_id, request)
    return RoleResponse.model_validate(role)


@router.delete(
    "/roles/{role_id}/retire",
    dependencies=[Depends(require_privilege(ET_RETIRE_ROLE))],
)
async def retire_role(
    role_id: str,
    db: AsyncSession = Depends(get_db),
):
    """Soft-retire a role using DELETE method."""
    await RoleService.retire_role(db, role_id)
    return {"message": "Role retired successfully"}
