"""
EduTechAI — Authentication & Authorization Pydantic Schemas (DTOs)

Request and response DTOs for JWT authentication and current user profile endpoints.
"""

from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, ConfigDict, EmailStr, Field

from models.role_schemas import RoleResponse
from models.subscription_schemas import SubscriptionResponse


class LoginRequest(BaseModel):
    """Payload for user login authentication."""

    email: EmailStr = Field(..., description="Registered user email address")
    password: str = Field(..., min_length=1, max_length=72, description="User password")


class UserCurrentProfileResponse(BaseModel):
    """
    Unified user current profile response returned by GET /api/v1/auth/me.

    Includes user details, assigned active roles, subscription details,
    and a flat list of active privilege codes across all assigned roles.
    """

    id: str
    first_name: str
    last_name: str
    email: str
    mobile: str | None = None
    country: str | None = None
    created_at: datetime
    roles: list[str] = Field(default_factory=list, description="List of assigned active role names")
    subscription: SubscriptionResponse | None = None
    privilege_codes: list[str] = Field(
        default_factory=list,
        description="Flat deduplicated list of active privilege codes granted to the user",
    )

    model_config = ConfigDict(from_attributes=True)
