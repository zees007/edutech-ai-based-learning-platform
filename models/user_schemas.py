"""
EduTechAI — User Management Pydantic Schemas (DTOs)

Request and response models for user API endpoints.
"""

from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, ConfigDict, EmailStr, Field, model_validator


class UserCreateRequest(BaseModel):
    """Payload for creating a new user."""

    first_name: str = Field(..., min_length=1, max_length=100, description="User's first name")
    last_name: str = Field(..., min_length=1, max_length=100, description="User's last name")
    email: EmailStr = Field(..., max_length=255, description="Unique email address")
    password: str = Field(..., min_length=6, max_length=72, description="User password")
    mobile: str | None = Field(default=None, max_length=20, description="Contact mobile number")
    country: str | None = Field(default=None, max_length=100, description="Country of residence")


class UserEditRequest(BaseModel):
    """Payload for updating an existing user profile (all fields optional)."""

    first_name: str | None = Field(default=None, min_length=1, max_length=100)
    last_name: str | None = Field(default=None, min_length=1, max_length=100)
    email: EmailStr | None = Field(default=None, max_length=255)
    mobile: str | None = Field(default=None, max_length=20)
    country: str | None = Field(default=None, max_length=100)


class ChangePasswordRequest(BaseModel):
    """Payload for changing a user's password."""

    old_password: str = Field(..., min_length=1, max_length=72, description="Old password")
    new_password: str = Field(..., min_length=6, max_length=72, description="New password")
    confirm_password: str = Field(..., min_length=6, max_length=72, description="Confirm new password")

    @model_validator(mode="after")
    def validate_passwords_match(self) -> ChangePasswordRequest:
        if self.new_password != self.confirm_password:
            raise ValueError("new_password and confirm_password do not match.")
        return self


class SearchDTO(BaseModel):
    """Query parameters for user pagination and search."""

    page: int = Field(default=0, ge=0, description="Page number (0-indexed)")
    size: int = Field(default=10, ge=1, le=100, description="Page size limit")
    sortBy: str = Field(default="created_at", alias="sort_by", description="Field name to sort by")
    isDesc: bool = Field(default=True, alias="is_desc", description="Sort direction: True for descending, False for ascending")
    lookupText: str | None = Field(
        default=None,
        alias="lookup_text",
        description="Search term to filter by first_name, last_name, email, or mobile",
    )

    model_config = ConfigDict(populate_by_name=True)


class UserResponse(BaseModel):
    """API response model for a single user."""

    id: str
    first_name: str
    last_name: str
    email: str
    mobile: str | None = None
    country: str | None = None
    created_at: datetime
    retired: bool = False
    retired_at: datetime | None = None
    retired_by: str | None = None

    model_config = ConfigDict(from_attributes=True)


class PaginatedUserResponse(BaseModel):
    """Paginated list of users."""

    items: list[UserResponse] = Field(default_factory=list)
    total: int = Field(..., description="Total count of matching records")
    page: int = Field(..., description="Current page number")
    size: int = Field(..., description="Page size limit")
    total_pages: int = Field(..., description="Total number of pages available")
