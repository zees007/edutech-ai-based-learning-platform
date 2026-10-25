"""
EduTechAI — System Setting Schemas

Pydantic validation schemas for system settings endpoints and DTOs.
"""

from __future__ import annotations

from datetime import datetime
from pydantic import BaseModel, ConfigDict, Field


class SettingDTO(BaseModel):
    """Data Transfer Object representing a system setting."""

    model_config = ConfigDict(from_attributes=True)

    id: int
    code: str
    value: str
    order_number: int = 0
    created_at: datetime
    updated_at: datetime


class SettingUpdateRequest(BaseModel):
    """Payload to update an existing system setting."""

    value: str = Field(..., description="Configured value as a string")
    order_number: int | None = Field(default=None, description="Display order number")


class SettingResponse(SettingDTO):
    """Standard API response for a single system setting."""

    pass
