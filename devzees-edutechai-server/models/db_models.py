"""
EduTechAI — SQLAlchemy ORM Models

Database models for session persistence. Uses SQLAlchemy async ORM.

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
    Index,
    Integer,
    String,
    Table,
    Text,
    UniqueConstraint,
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
    tokens_invalidated_before: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

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
    feedbacks: Mapped[list[FeedbackRecord]] = relationship(
        "FeedbackRecord",
        back_populates="user",
        cascade="all, delete-orphan",
        lazy="selectin",
    )
    refresh_tokens: Mapped[list[RefreshToken]] = relationship(
        "RefreshToken",
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

    tiers: Mapped[list[SubscriptionTier]] = relationship(
        "SubscriptionTier",
        back_populates="role",
    )

    def __repr__(self) -> str:
        return f"<Role {self.id} '{self.name}'>"


class SubscriptionTier(LoggedEntity, Base):
    """
    Dynamic subscription tier defined and managed by admins.
    Binds commercial packaging (pricing & limits) to a database Role (privileges).
    """

    __tablename__ = "subscription_tiers"

    slug: Mapped[str] = mapped_column(String(50), unique=True, nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)

    # ── Role Binding ──
    role_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("roles.id", ondelete="RESTRICT"), nullable=False, index=True
    )
    role: Mapped[Role] = relationship("Role", back_populates="tiers", lazy="selectin")

    # ── Pricing & Commerce ──
    price_monthly: Mapped[float] = mapped_column(Float, nullable=False, default=0.0)
    price_annual: Mapped[float] = mapped_column(Float, nullable=False, default=0.0)
    currency: Mapped[str] = mapped_column(String(10), nullable=False, default="USD")
    is_public: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    order_index: Mapped[int] = mapped_column(Integer, nullable=False, default=0)

    # ── Entitlements / Quotas (None means Unlimited) ──
    monthly_session_limit: Mapped[int | None] = mapped_column(Integer, nullable=True)
    follow_up_limit_per_step: Mapped[int | None] = mapped_column(Integer, nullable=True)
    youtube_limit_per_step: Mapped[int | None] = mapped_column(Integer, nullable=True)
    streak_multiplier: Mapped[float] = mapped_column(Float, nullable=False, default=1.0, server_default="1.0")

    subscriptions: Mapped[list[Subscription]] = relationship(
        "Subscription", back_populates="tier_ref"
    )

    def __repr__(self) -> str:
        return f"<SubscriptionTier {self.slug} ('{self.name}') role_id={self.role_id}>"


class Subscription(Base):
    """
    Tracks user subscription tier (Free, Pro, Ultra, or custom dynamic tier) and billing status.
    """

    __tablename__ = "subscriptions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False, index=True
    )
    tier: Mapped[str] = mapped_column(String(50), nullable=False, default="free", index=True)
    tier_id: Mapped[str | None] = mapped_column(
        String(36), ForeignKey("subscription_tiers.id", ondelete="SET NULL"), nullable=True, index=True
    )
    status: Mapped[str] = mapped_column(String(50), nullable=False, default="active")
    billing_cycle: Mapped[str] = mapped_column(String(20), nullable=False, default="monthly")
    price_amount: Mapped[float] = mapped_column(Float, nullable=False, default=0.0)
    current_period_start: Mapped[datetime] = mapped_column(
        DateTime, nullable=False, server_default=func.now()
    )
    current_period_end: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    gateway_provider: Mapped[str] = mapped_column(String(50), nullable=False, default="razorpay")
    gateway_subscription_id: Mapped[str | None] = mapped_column(String(255), nullable=True)
    gateway_customer_id: Mapped[str | None] = mapped_column(String(255), nullable=True)
    gateway_metadata: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    payment_gateway_ref: Mapped[str | None] = mapped_column(String(255), nullable=True)
    cancel_at_period_end: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    auto_renew: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)

    user: Mapped[User] = relationship("User", back_populates="subscription")
    tier_ref: Mapped[SubscriptionTier | None] = relationship(
        "SubscriptionTier", back_populates="subscriptions", lazy="selectin"
    )
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
    gateway_provider: Mapped[str] = mapped_column(String(50), nullable=False, default="razorpay")
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
    feedback: Mapped[FeedbackRecord | None] = relationship(
        "FeedbackRecord",
        back_populates="session",
        uselist=False,
        cascade="all, delete-orphan",
        lazy="selectin",
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
    xp_earned: Mapped[int] = mapped_column(Integer, default=0, server_default="0", nullable=False)

    __table_args__ = (
        Index("ix_step_progress_session_status", "session_id", "status"),
    )

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


class UserTrophy(Base):
    """
    Persisted trophy unlock records. Once a trophy is unlocked, it stays
    permanently — the row is never deleted or updated to unlocked=False.
    """

    __tablename__ = "user_trophies"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    trophy_id: Mapped[str] = mapped_column(String(20), nullable=False)
    unlocked_at: Mapped[datetime] = mapped_column(DateTime, nullable=False)

    __table_args__ = (
        UniqueConstraint("user_id", "trophy_id", name="uq_user_trophy"),
    )

    def __repr__(self) -> str:
        return f"<UserTrophy user={self.user_id} trophy={self.trophy_id}>"


class RefreshToken(Base):
    """
    Session refresh token for maintaining user sessions securely.
    """

    __tablename__ = "refresh_tokens"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False)
    token_hash: Mapped[str] = mapped_column(String(255), unique=True, index=True, nullable=False)
    family_id: Mapped[str] = mapped_column(String(36), index=True, nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, nullable=False, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime, nullable=False, server_default=func.now(), onupdate=func.now())

    user: Mapped[User] = relationship("User", back_populates="refresh_tokens")

    def __repr__(self) -> str:
        return f"<RefreshToken {self.id} for user={self.user_id}>"




class FeedbackRecord(Base):
    """
    Testimonial and feedback submitted by learners upon session completion.
    Visible only to Admins. Displayed on homepage ONLY if status == 'featured'.
    """

    __tablename__ = "feedbacks"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    feedback_id: Mapped[str] = mapped_column(String(36), unique=True, index=True, nullable=False)
    session_id: Mapped[str | None] = mapped_column(
        String(24), ForeignKey("sessions.session_id", ondelete="CASCADE"), nullable=True, index=True
    )
    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    rating: Mapped[int] = mapped_column(Integer, nullable=False)  # 1 to 5 stars
    quote: Mapped[str] = mapped_column(String(250), nullable=False)  # max 250 chars
    education_level: Mapped[str] = mapped_column(String(50), nullable=False)
    user_country: Mapped[str | None] = mapped_column(String(100), nullable=True)
    topic_tag: Mapped[str] = mapped_column(String(150), nullable=False)
    is_public_consent: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    status: Mapped[str] = mapped_column(
        String(20), default="pending", nullable=False, index=True
    )  # "pending", "featured", "archived"
    admin_notes: Mapped[str | None] = mapped_column(String(255), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime, nullable=False, server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, nullable=False, server_default=func.now(), onupdate=func.now()
    )

    __table_args__ = (
        UniqueConstraint("session_id", "user_id", name="uq_session_user_feedback"),
    )

    user: Mapped[User] = relationship("User", back_populates="feedbacks")
    session: Mapped[SessionRecord | None] = relationship("SessionRecord", back_populates="feedback")

    def __repr__(self) -> str:
        return f"<Feedback {self.feedback_id} session={self.session_id} rating={self.rating} status={self.status}>"


class SystemSetting(Base):
    """
    Dynamic system configuration key-value entity.
    Stores agent LLM models, subscription prices, promotional coupons, etc.
    """

    __tablename__ = "settings"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    code: Mapped[str] = mapped_column(String(100), unique=True, nullable=False, index=True)
    value: Mapped[str] = mapped_column(Text, nullable=False)
    order_number: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    created_at: Mapped[datetime] = mapped_column(
        DateTime, nullable=False, server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, nullable=False, server_default=func.now(), onupdate=func.now()
    )

    def __repr__(self) -> str:
        return f"<SystemSetting {self.code}={self.value}>"


class SessionUsageLog(Base):
    """
    Audit record for consumed sessions (e.g. sessions cancelled during active synthesis)
    to ensure free-tier monthly session quotas are accurately enforced.
    """

    __tablename__ = "session_usage_logs"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    session_id: Mapped[str] = mapped_column(String(24), index=True, nullable=False)
    action: Mapped[str] = mapped_column(String(50), nullable=False, default="cancelled_in_synthesis")
    created_at: Mapped[datetime] = mapped_column(
        DateTime, nullable=False, server_default=func.now()
    )

    def __repr__(self) -> str:
        return f"<SessionUsageLog user={self.user_id} session={self.session_id} action={self.action}>"


