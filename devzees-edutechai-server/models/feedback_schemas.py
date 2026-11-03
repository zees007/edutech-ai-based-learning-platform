"""
EduTechAI — Feedback Pydantic Schemas (DTOs)

Request and response models for session feedback and admin moderation.
"""

from __future__ import annotations

from datetime import datetime
from pydantic import BaseModel, ConfigDict, Field


class FeedbackCreateRequest(BaseModel):
    """Payload sent by learner upon completing a learning session."""

    session_id: str = Field(..., min_length=1, max_length=24, description="ID of completed learning session")
    rating: int = Field(..., ge=1, le=5, description="Star rating from 1 to 5")
    quote: str = Field(..., min_length=5, max_length=250, description="Testimonial quote (max 250 characters)")
    is_public_consent: bool = Field(default=True, description="Consent to feature publicly on homepage")


class FeedbackSubmissionResponse(BaseModel):
    """Response returned after learner submits feedback with gamification rewards."""

    feedback_id: str
    session_id: str
    xp_awarded: int
    total_xp: int
    level: int
    level_title: str
    leveled_up: bool
    message: str = "Thank you for your feedback!"


class FeedbackPublicResponse(BaseModel):
    """Public testimonial displayed in the homepage Wall of Love section."""

    feedback_id: str
    name: str
    education_level: str
    country: str | None = None
    rating: int
    quote: str
    topic_tag: str
    avatar_initial: str
    avatar_color: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class FeedbackAdminResponse(BaseModel):
    """Detailed feedback view for the Admin Console."""

    id: int
    feedback_id: str
    session_id: str
    user_id: str
    user_name: str
    user_email: str
    education_level: str
    country: str | None = None
    rating: int
    quote: str
    topic_tag: str
    is_public_consent: bool
    status: str
    admin_notes: str | None = None
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


class FeedbackStatusUpdateRequest(BaseModel):
    """Payload used by Admin to toggle feature status and attach private admin notes."""

    status: str = Field(..., description="Target status: 'featured', 'pending', or 'archived'")
    admin_notes: str | None = Field(default=None, max_length=255, description="Private admin note")


class FeedbackSummaryMetrics(BaseModel):
    """Aggregated counters for admin moderation bar."""

    total_count: int
    pending_count: int
    featured_count: int
    archived_count: int
    average_rating: float


class PaginatedFeedbackAdminResponse(BaseModel):
    """Paginated feedback response with summary metrics for admin view."""

    items: list[FeedbackAdminResponse] = Field(default_factory=list)
    total: int
    metrics: FeedbackSummaryMetrics

