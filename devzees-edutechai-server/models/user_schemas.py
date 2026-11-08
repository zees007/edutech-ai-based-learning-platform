"""
EduTechAI — User Management Pydantic Schemas (DTOs)

Request and response models for user API endpoints.
"""

from __future__ import annotations

import re
from datetime import datetime

from pydantic import BaseModel, ConfigDict, EmailStr, Field, field_validator, model_validator


def _normalize_and_validate_mobile(mobile: str | None) -> str | None:
    """Validate and format international phone number into standardized E.164 format."""
    if not mobile:
        return None

    clean = mobile.strip()
    if not clean:
        return None

    try:
        import phonenumbers
        from phonenumbers import NumberParseException, PhoneNumberFormat

        parsed = phonenumbers.parse(clean if clean.startswith("+") else f"+{clean}", None)
        if not phonenumbers.is_valid_number(parsed):
            raise ValueError("Invalid international phone number format. Please check the country code.")

        return phonenumbers.format_number(parsed, PhoneNumberFormat.E164)
    except (ImportError, NameError):
        # Fallback if phonenumbers is not yet installed in local environment
        digits = re.sub(r"[^\d]", "", clean)
        if not (7 <= len(digits) <= 15):
            raise ValueError("Invalid phone number length (must be between 7 and 15 digits).")
        return f"+{digits}"
    except Exception:
        raise ValueError("Could not parse phone number. Please include a valid country dial code (e.g. +1...).")


class UserCreateRequest(BaseModel):
    """Payload for creating a new user."""

    first_name: str = Field(..., min_length=1, max_length=100, description="User's first name")
    last_name: str = Field(..., min_length=1, max_length=100, description="User's last name")
    email: EmailStr = Field(..., max_length=255, description="Unique email address")
    password: str = Field(..., min_length=6, max_length=72, description="User password")
    mobile: str | None = Field(default=None, max_length=25, description="Contact mobile number")
    country: str | None = Field(default=None, max_length=100, description="Country of residence")

    @field_validator("mobile")
    @classmethod
    def validate_mobile(cls, v: str | None) -> str | None:
        return _normalize_and_validate_mobile(v)


class UserEditRequest(BaseModel):
    """Payload for updating an existing user profile (all fields optional)."""

    first_name: str | None = Field(default=None, min_length=1, max_length=100)
    last_name: str | None = Field(default=None, min_length=1, max_length=100)
    email: EmailStr | None = Field(default=None, max_length=255)
    mobile: str | None = Field(default=None, max_length=25)
    country: str | None = Field(default=None, max_length=100)

    @field_validator("mobile")
    @classmethod
    def validate_mobile(cls, v: str | None) -> str | None:
        return _normalize_and_validate_mobile(v)


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
    size: int = Field(default=10, ge=1, le=1000, description="Page size limit")
    sortBy: str = Field(default="created_at", alias="sort_by", description="Field name to sort by")
    isDesc: bool = Field(default=True, alias="is_desc", description="Sort direction: True for descending, False for ascending")
    lookupText: str | None = Field(
        default=None,
        alias="lookup_text",
        description="Search term to filter by first_name, last_name, email, or mobile",
    )

    model_config = ConfigDict(populate_by_name=True)


from models.role_schemas import RoleResponse
from models.subscription_schemas import SubscriptionResponse


class UserRoleAssignRequest(BaseModel):
    """Payload for updating a user's assigned role IDs."""

    role_ids: list[str] = Field(..., alias="roleIds", description="List of Role UUIDs to assign to user")

    model_config = ConfigDict(populate_by_name=True)


class UserResponse(BaseModel):
    """API response model for a single user."""

    id: str
    first_name: str
    last_name: str
    email: str
    mobile: str | None = None
    country: str | None = None
    roles: list[RoleResponse] = Field(default_factory=list)
    subscription: SubscriptionResponse | None = None
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
