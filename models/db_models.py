"""
EduTechAI — SQLAlchemy ORM Models

Database models for session persistence. Uses SQLAlchemy async ORM so the
database engine can be swapped (SQLite → PostgreSQL) by changing DATABASE_URL
in .env — zero code changes needed.

Current tables:
    - SessionRecord: Learning session metadata + serialized SharedMemory state
    - StepProgress: Per-step completion tracking
    - GamificationRecord: XP, streaks, and level tracking

Future tables (when auth is added):
    - User, UserSession, Achievement
"""

from __future__ import annotations

from datetime import datetime

from sqlalchemy import (
    JSON,
    Boolean,
    DateTime,
    Float,
    Integer,
    String,
    Text,
    func,
)
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column


class Base(DeclarativeBase):
    """Base class for all ORM models."""

    pass


class SessionRecord(Base):
    """
    Persisted learning session.

    The `state_json` column stores the full SharedMemory serialized as JSON,
    enabling session recovery on reconnect without losing any agent outputs.
    """

    __tablename__ = "sessions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    session_id: Mapped[str] = mapped_column(String(24), unique=True, index=True, nullable=False)
    topic: Mapped[str] = mapped_column(Text, nullable=False)
    learning_mode: Mapped[str] = mapped_column(String(20), nullable=False, default="visual")
    student_level: Mapped[str] = mapped_column(String(30), nullable=False, default="general")
    total_steps: Mapped[int] = mapped_column(Integer, default=0)
    current_step_index: Mapped[int] = mapped_column(Integer, default=0)
    is_complete: Mapped[bool] = mapped_column(Boolean, default=False)
    state_json: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime, nullable=False, server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, nullable=False, server_default=func.now(), onupdate=func.now()
    )

    def __repr__(self) -> str:
        return f"<Session {self.session_id}: '{self.topic[:40]}'>"


class StepProgress(Base):
    """
    Tracks completion status and quiz scores for each milestone step.
    Separate from SessionRecord to allow efficient per-step queries.
    """

    __tablename__ = "step_progress"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    session_id: Mapped[str] = mapped_column(String(24), index=True, nullable=False)
    step_index: Mapped[int] = mapped_column(Integer, nullable=False)
    status: Mapped[str] = mapped_column(String(20), nullable=False, default="pending")
    quiz_score: Mapped[float | None] = mapped_column(Float, nullable=True)
    completed_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)

    def __repr__(self) -> str:
        return f"<StepProgress session={self.session_id} step={self.step_index} status={self.status}>"


class GamificationRecord(Base):
    """
    Tracks XP, streaks, and leveling for a session.
    When user accounts are added, this will link to a User record instead.
    """

    __tablename__ = "gamification"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    session_id: Mapped[str] = mapped_column(String(24), unique=True, index=True, nullable=False)
    xp_earned: Mapped[int] = mapped_column(Integer, default=0)
    streak_count: Mapped[int] = mapped_column(Integer, default=0)
    level: Mapped[int] = mapped_column(Integer, default=1)
    level_title: Mapped[str] = mapped_column(String(50), default="Curious Explorer")
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, nullable=False, server_default=func.now(), onupdate=func.now()
    )

    def __repr__(self) -> str:
        return f"<Gamification session={self.session_id} xp={self.xp_earned} level={self.level}>"
