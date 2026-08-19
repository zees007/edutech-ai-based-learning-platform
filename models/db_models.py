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
    Column,
    DateTime,
    Float,
    ForeignKey,
    Integer,
    String,
    Table,
    Text,
    func,
)
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship


from models.base_entity import LoggedEntity


class Base(DeclarativeBase):
    """Base class for all ORM models."""

    pass


user_roles = Table(
    "user_roles",
    Base.metadata,
    Column("user_id", String(36), ForeignKey("users.id", ondelete="CASCADE"), primary_key=True),
    Column("role_id", String(36), ForeignKey("roles.id", ondelete="CASCADE"), primary_key=True),
    Column("assigned_at", DateTime, nullable=False, server_default=func.now()),
)


class User(LoggedEntity, Base):
    """
    User account record.

    Inherits id (UUID4), created_at, retired, retired_at, retired_by from LoggedEntity.
    """

    __tablename__ = "users"

    first_name: Mapped[str] = mapped_column(String(100), nullable=False)
    last_name: Mapped[str] = mapped_column(String(100), nullable=False)
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False, index=True)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    mobile: Mapped[str | None] = mapped_column(String(20), nullable=True)
    country: Mapped[str | None] = mapped_column(String(100), nullable=True)

    roles: Mapped[list[Role]] = relationship(
        "Role",
        secondary=user_roles,
        back_populates="users",
        lazy="selectin",
    )
    subscription: Mapped[Subscription | None] = relationship(
        "Subscription",
        back_populates="user",
        uselist=False,
        cascade="all, delete-orphan",
        lazy="selectin",
    )
    sessions: Mapped[list[SessionRecord]] = relationship(
        "SessionRecord",
        back_populates="user",
        cascade="all, delete-orphan",
        lazy="selectin",
    )

    def __repr__(self) -> str:
        return f"<User {self.id} {self.first_name} {self.last_name} ({self.email})>"


role_privileges = Table(
    "role_privileges",
    Base.metadata,
    Column("role_id", String(36), ForeignKey("roles.id", ondelete="CASCADE"), primary_key=True),
    Column("privilege_id", Integer, ForeignKey("privileges.id", ondelete="CASCADE"), primary_key=True),
)


class Privilege(Base):
    """
    Privilege lookup entity.

    Contains system permissions/privileges. Data is manually inserted into this table.
    Self-referencing relationship allows hierarchy via parent_id.
    """

    __tablename__ = "privileges"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    code: Mapped[str] = mapped_column(String(100), unique=True, nullable=False, index=True)
    order_number: Mapped[int | None] = mapped_column(Integer, nullable=True, default=0)
    parent_id: Mapped[int | None] = mapped_column(
        Integer, ForeignKey("privileges.id", ondelete="SET NULL"), nullable=True
    )

    parent: Mapped[Privilege | None] = relationship(
        "Privilege", remote_side=[id], back_populates="children"
    )
    children: Mapped[list[Privilege]] = relationship(
        "Privilege", back_populates="parent", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<Privilege {self.id}: {self.code} ('{self.name}')>"


class Role(LoggedEntity, Base):
    """
    Role account record.

    Inherits id (UUID4), created_at, retired, retired_at, retired_by from LoggedEntity.
    Holds a set of Privileges via many-to-many relationship (`role_privileges`).
    """

    __tablename__ = "roles"

    name: Mapped[str] = mapped_column(String(100), unique=True, nullable=False, index=True)

    privileges: Mapped[list[Privilege]] = relationship(
        "Privilege",
        secondary=role_privileges,
        lazy="selectin",
    )
    users: Mapped[list[User]] = relationship(
        "User",
        secondary=user_roles,
        back_populates="roles",
    )

    def __repr__(self) -> str:
        return f"<Role {self.id} '{self.name}'>"


class Subscription(Base):
    """
    Tracks user subscription tier (Normal, Pro, Ultra) and billing status.
    """

    __tablename__ = "subscriptions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False, index=True
    )
    tier: Mapped[str] = mapped_column(String(50), nullable=False, default="normal", index=True)
    status: Mapped[str] = mapped_column(String(50), nullable=False, default="active")
    billing_cycle: Mapped[str] = mapped_column(String(20), nullable=False, default="monthly")
    price_amount: Mapped[float] = mapped_column(Float, nullable=False, default=0.0)
    current_period_start: Mapped[datetime] = mapped_column(
        DateTime, nullable=False, server_default=func.now()
    )
    current_period_end: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    gateway_provider: Mapped[str] = mapped_column(String(50), nullable=False, default="sandbox")
    gateway_subscription_id: Mapped[str | None] = mapped_column(String(255), nullable=True)
    gateway_customer_id: Mapped[str | None] = mapped_column(String(255), nullable=True)
    gateway_metadata: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    payment_gateway_ref: Mapped[str | None] = mapped_column(String(255), nullable=True)
    cancel_at_period_end: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    auto_renew: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)

    user: Mapped[User] = relationship("User", back_populates="subscription")
    transactions: Mapped[list[PaymentTransaction]] = relationship("PaymentTransaction", back_populates="subscription", cascade="all, delete-orphan")

    def __repr__(self) -> str:
        return f"<Subscription user={self.user_id} tier={self.tier} provider={self.gateway_provider} status={self.status}>"


class PaymentTransaction(Base):
    """
    Ledger record for subscription charges, invoices, and refunds.
    """

    __tablename__ = "payment_transactions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    transaction_id: Mapped[str] = mapped_column(String(100), unique=True, nullable=False, index=True)
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    subscription_id: Mapped[int | None] = mapped_column(Integer, ForeignKey("subscriptions.id", ondelete="SET NULL"), nullable=True)
    gateway_provider: Mapped[str] = mapped_column(String(50), nullable=False, default="paddle")
    amount: Mapped[float] = mapped_column(Float, nullable=False)
    currency: Mapped[str] = mapped_column(String(10), nullable=False, default="USD")
    status: Mapped[str] = mapped_column(String(30), nullable=False, default="completed")
    tier: Mapped[str] = mapped_column(String(30), nullable=False)
    billing_cycle: Mapped[str] = mapped_column(String(20), nullable=False, default="monthly")
    payment_method: Mapped[str | None] = mapped_column(String(50), nullable=True)
    coupon_code: Mapped[str | None] = mapped_column(String(50), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, nullable=False, server_default=func.now())

    subscription: Mapped[Subscription | None] = relationship("Subscription", back_populates="transactions")

    def __repr__(self) -> str:
        return f"<PaymentTransaction id={self.transaction_id} provider={self.gateway_provider} amount={self.amount} status={self.status}>"





class SessionRecord(Base):
    """
    Persisted learning session.

    The `state_json` column stores the full SharedMemory serialized as JSON,
    enabling session recovery on reconnect without losing any agent outputs.
    """

    __tablename__ = "sessions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    session_id: Mapped[str] = mapped_column(String(24), unique=True, index=True, nullable=False)
    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
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

    user: Mapped[User] = relationship("User", back_populates="sessions")

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
