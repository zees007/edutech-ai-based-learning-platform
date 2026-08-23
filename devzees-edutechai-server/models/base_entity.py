"""
EduTechAI — Shared Base Entity

Reusable mixin class for all auditable database models.
Provides UUID primary key, creation timestamp, and soft-retire attributes.
"""

from __future__ import annotations

from datetime import datetime
from uuid import uuid4

from sqlalchemy import Boolean, DateTime, String, func
from sqlalchemy.orm import Mapped, mapped_column


class LoggedEntity:
    """
    Reusable mixin for all auditable entities.

    Provides:
        - id: UUID4 primary key string
        - created_at: Timestamp when record was created
        - retired: Soft deletion flag
        - retired_at: Timestamp when soft-retired
        - retired_by: User UUID who retired the entity (optional)
    """

    id: Mapped[str] = mapped_column(
        String(36),
        primary_key=True,
        default=lambda: str(uuid4()),
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        server_default=func.now(),
    )
    retired: Mapped[bool] = mapped_column(
        Boolean,
        nullable=False,
        default=False,
    )
    retired_at: Mapped[datetime | None] = mapped_column(
        DateTime,
        nullable=True,
    )
    retired_by: Mapped[str | None] = mapped_column(
        String(36),
        nullable=True,
    )
