"""
EduTechAI — Role & Privilege Management Pydantic Schemas (DTOs)

Request and response models for Role and Privilege API endpoints.
"""

from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class PrivilegeResponse(BaseModel):
    """API response model for a single privilege."""

    id: int
    name: str
    code: str
    order_number: int | None = 0
    parent_id: int | None = None

    model_config = ConfigDict(from_attributes=True)


class PrivilegeTreeResponse(BaseModel):
    """Hierarchical tree response model for privileges."""

    id: int
    name: str
    code: str
    order_number: int | None = 0
    parent_id: int | None = None
    children: list[PrivilegeTreeResponse] = Field(default_factory=list)

    model_config = ConfigDict(from_attributes=True)


class RoleCreateRequest(BaseModel):
    """Payload for creating a new role."""

    name: str = Field(..., min_length=1, max_length=100, description="Role name")
    privilege_ids: list[int] = Field(
        default_factory=list,
        alias="privilegeIds",
        description="List of privilege IDs to assign to the role",
    )

    model_config = ConfigDict(populate_by_name=True)


class RoleEditRequest(BaseModel):
    """Payload for updating an existing role."""

    name: str | None = Field(default=None, min_length=1, max_length=100, description="Role name")
    privilege_ids: list[int] | None = Field(
        default=None,
        alias="privilegeIds",
        description="List of privilege IDs to assign to the role",
    )

    model_config = ConfigDict(populate_by_name=True)


class RoleResponse(BaseModel):
    """API response model for a single role."""

    id: str
    name: str
    privileges: list[PrivilegeResponse] = Field(default_factory=list)
    created_at: datetime
    retired: bool = False
    retired_at: datetime | None = None
    retired_by: str | None = None

    model_config = ConfigDict(from_attributes=True)


class PaginatedRoleResponse(BaseModel):
    """Paginated list of roles."""

    items: list[RoleResponse] = Field(default_factory=list)
    total: int = Field(..., description="Total count of matching records")
    page: int = Field(..., description="Current page number")
    size: int = Field(..., description="Page size limit")
    total_pages: int = Field(..., description="Total number of pages available")
