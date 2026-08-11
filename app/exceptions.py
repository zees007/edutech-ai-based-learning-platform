"""
EduTechAI — Standardised Exception Handling & API Error Format

Provides custom application exceptions and an APIError response model
to ensure uniform error JSON structure across all REST APIs.
"""

from __future__ import annotations

from datetime import datetime
from typing import Any

from pydantic import BaseModel, Field


class APIError(BaseModel):
    """Standardised error response payload for API errors."""

    http_status: int = Field(..., description="HTTP status code (e.g. 400, 404, 409)")
    errors: list[str] = Field(..., description="List of human-readable error messages")
    timestamp: datetime = Field(
        default_factory=datetime.utcnow, description="UTC timestamp of when the error occurred"
    )
    path_uri: str = Field(..., description="Request URI path that produced the error")
    error_code: str = Field(..., description="Domain-specific error code string")


class AppException(Exception):
    """Base application exception with structured status code and error details."""

    def __init__(
        self,
        status_code: int,
        error_code: str,
        errors: list[str] | str,
    ) -> None:
        self.status_code = status_code
        self.error_code = error_code
        if isinstance(errors, str):
            self.errors = [errors]
        else:
            self.errors = errors
        super().__init__(self.errors[0] if self.errors else error_code)


class NotFoundException(AppException):
    """HTTP 404 Resource Not Found."""

    def __init__(self, error_code: str = "RESOURCE_NOT_FOUND", errors: list[str] | str = "Resource not found.") -> None:
        super().__init__(status_code=404, error_code=error_code, errors=errors)


class ConflictException(AppException):
    """HTTP 409 Resource Conflict (e.g. unique constraint violation)."""

    def __init__(self, error_code: str = "RESOURCE_CONFLICT", errors: list[str] | str = "Resource conflict.") -> None:
        super().__init__(status_code=409, error_code=error_code, errors=errors)


class BadRequestException(AppException):
    """HTTP 400 Bad Request / Validation Failure."""

    def __init__(self, error_code: str = "BAD_REQUEST", errors: list[str] | str = "Bad request.") -> None:
        super().__init__(status_code=400, error_code=error_code, errors=errors)
