"""
EduTechAI — Feedback & Testimonials REST Router

Handles learner feedback submission, public social proof display,
and admin review/moderation.
"""

from __future__ import annotations

import hashlib
import logging
import uuid
from typing import Annotated

from fastapi import APIRouter, Depends, Query
from sqlalchemy import case, func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies import get_current_user, require_privilege
from app.exceptions import BadRequestException, ForbiddenException, NotFoundException
from app.privileges_config import ET_MODERATE_FEEDBACK, ET_SUBMIT_FEEDBACK
from models.db_models import FeedbackRecord, GamificationRecord, SessionRecord, User
from models.feedback_schemas import (
    FeedbackAdminResponse,
    FeedbackCreateRequest,
    FeedbackPublicResponse,
    FeedbackStatusUpdateRequest,
    FeedbackSubmissionResponse,
    FeedbackSummaryMetrics,
    PaginatedFeedbackAdminResponse,
)
from services.database import get_db
from services.gamification import calculate_feedback_xp, calculate_level

logger = logging.getLogger(__name__)
router = APIRouter()

# High-contrast, brand-aligned avatar color palette
AVATAR_PALETTE = [
    "#2B68F6",  # Electric Blue
    "#10B981",  # Emerald Green
    "#8B5CF6",  # Vivid Purple
    "#F59E0B",  # Amber Gold
    "#00F5D4",  # Cyan Neon
    "#EC4899",  # Magenta Pink
]


def _pick_avatar_color(seed: str) -> str:
    """Deterministically select an avatar color based on user identity."""
    idx = int(hashlib.md5(seed.encode("utf-8")).hexdigest(), 16) % len(AVATAR_PALETTE)
    return AVATAR_PALETTE[idx]


# ─── 1. Learner Submission (Authenticated) ───────────────────────
@router.post(
    "/feedback",
    response_model=FeedbackSubmissionResponse,
    dependencies=[Depends(require_privilege(ET_SUBMIT_FEEDBACK))],
)
async def submit_feedback(
    request: FeedbackCreateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Submit feedback upon session completion.
    Awards +30 XP bonus to the learner. Regular users cannot view or edit later.
    """
    # 1. Verify session exists and belongs to current user
    session_stmt = select(SessionRecord).where(SessionRecord.session_id == request.session_id)
    session_res = await db.execute(session_stmt)
    session_rec = session_res.scalar_one_or_none()

    if not session_rec:
        raise NotFoundException(
            error_code="SESSION_NOT_FOUND",
            errors=f"Session '{request.session_id}' not found.",
        )

    if session_rec.user_id != current_user.id:
        raise ForbiddenException(
            error_code="SESSION_FORBIDDEN",
            errors="You can only submit feedback for your own learning sessions.",
        )

    # 2. Check for duplicate feedback submission
    dup_stmt = select(FeedbackRecord).where(
        FeedbackRecord.session_id == request.session_id,
        FeedbackRecord.user_id == current_user.id,
    )
    dup_res = await db.execute(dup_stmt)
    if dup_res.scalar_one_or_none():
        raise BadRequestException(
            error_code="FEEDBACK_ALREADY_SUBMITTED",
            errors="Feedback has already been submitted for this session.",
        )

    # 3. Clean inputs & normalize metadata
    cleaned_quote = request.quote.strip()
    education_level = session_rec.student_level.replace("_", " ").title()
    user_country = current_user.country or "Global Learner"
    topic_tag = session_rec.topic.strip()

    # 4. Insert feedback record (status defaults to 'pending')
    feedback_id = str(uuid.uuid4())
    new_feedback = FeedbackRecord(
        feedback_id=feedback_id,
        session_id=request.session_id,
        user_id=current_user.id,
        rating=request.rating,
        quote=cleaned_quote,
        education_level=education_level,
        user_country=user_country,
        topic_tag=topic_tag,
        is_public_consent=request.is_public_consent,
        status="pending",
    )
    db.add(new_feedback)

    # 5. Award +30 XP Gamification bonus
    gamification_stmt = select(GamificationRecord).where(
        GamificationRecord.session_id == request.session_id
    )
    gamification_res = await db.execute(gamification_stmt)
    gamification = gamification_res.scalar_one_or_none()

    feedback_xp = calculate_feedback_xp()  # 30 XP
    if gamification:
        old_level = calculate_level(gamification.xp_earned)["level"]
        gamification.xp_earned += feedback_xp
        new_level_data = calculate_level(gamification.xp_earned)
        gamification.level = new_level_data["level"]
        gamification.level_title = new_level_data["title"]
        new_total_xp = gamification.xp_earned
        new_level = gamification.level
        new_title = gamification.level_title
        leveled_up = new_level > old_level
    else:
        new_total_xp = feedback_xp
        new_level_data = calculate_level(new_total_xp)
        new_level = new_level_data["level"]
        new_title = new_level_data["title"]
        leveled_up = False

    await db.commit()

    return FeedbackSubmissionResponse(
        feedback_id=feedback_id,
        session_id=request.session_id,
        xp_awarded=feedback_xp,
        total_xp=new_total_xp,
        level=new_level,
        level_title=new_title,
        leveled_up=leveled_up,
        message="Thank you for your feedback! You earned +30 bonus XP.",
    )


# ─── 2. Public Homepage Display (Unauthenticated) ────────────────
@router.get(
    "/feedback/public",
    response_model=list[FeedbackPublicResponse],
)
async def get_public_featured_feedback(
    db: AsyncSession = Depends(get_db),
):
    """
    Public endpoint providing strictly admin-featured student testimonials
    for the homepage Wall of Love section.
    """
    stmt = (
        select(FeedbackRecord, User)
        .join(User, FeedbackRecord.user_id == User.id)
        .where(
            FeedbackRecord.status == "featured",
            FeedbackRecord.is_public_consent.is_(True),
            User.retired.is_(False),
        )
        .order_by(FeedbackRecord.updated_at.desc())
        .limit(12)
    )
    res = await db.execute(stmt)
    rows = res.all()

    result: list[FeedbackPublicResponse] = []
    for feedback, user in rows:
        name = f"{user.first_name} {user.last_name}"
        initial = f"{user.first_name[0]}{user.last_name[0]}".upper() if user.first_name and user.last_name else "ET"
        avatar_color = _pick_avatar_color(f"{user.id}-{name}")

        result.append(
            FeedbackPublicResponse(
                feedback_id=feedback.feedback_id,
                name=name,
                education_level=feedback.education_level,
                country=feedback.user_country,
                rating=feedback.rating,
                quote=feedback.quote,
                topic_tag=feedback.topic_tag,
                avatar_initial=initial,
                avatar_color=avatar_color,
                created_at=feedback.created_at,
            )
        )

    return result


# ─── 3. Admin Moderation & Listing (Admin Only) ──────────────────
@router.get(
    "/admin/feedback",
    response_model=PaginatedFeedbackAdminResponse,
    dependencies=[Depends(require_privilege(ET_MODERATE_FEEDBACK))],
)
async def list_admin_feedbacks(
    status: str | None = Query(default=None, description="Filter: 'pending', 'featured', or 'archived'"),
    lookup_text: str | None = Query(default=None, description="Search term for user name, email, topic, or quote"),
    page: int = Query(default=0, ge=0),
    size: int = Query(default=10, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
):
    """
    Admin-only endpoint to view, search, and paginate through submitted feedbacks.
    """
    # 1. Calculate overall metrics in a single consolidated aggregation query
    metrics_stmt = select(
        func.count(FeedbackRecord.id).label("total_count"),
        func.count(case((FeedbackRecord.status == "pending", FeedbackRecord.id))).label("pending_count"),
        func.count(case((FeedbackRecord.status == "featured", FeedbackRecord.id))).label("featured_count"),
        func.count(case((FeedbackRecord.status == "archived", FeedbackRecord.id))).label("archived_count"),
        func.coalesce(func.avg(FeedbackRecord.rating), 0.0).label("avg_rating"),
    )
    metrics_res = await db.execute(metrics_stmt)
    metrics_row = metrics_res.one()

    metrics = FeedbackSummaryMetrics(
        total_count=metrics_row.total_count or 0,
        pending_count=metrics_row.pending_count or 0,
        featured_count=metrics_row.featured_count or 0,
        archived_count=metrics_row.archived_count or 0,
        average_rating=round(float(metrics_row.avg_rating or 0.0), 1),
    )

    # 2. Build filtered query
    base_stmt = select(FeedbackRecord, User).join(User, FeedbackRecord.user_id == User.id)

    if status and status.strip() in ("pending", "featured", "archived"):
        base_stmt = base_stmt.where(FeedbackRecord.status == status.strip())

    if lookup_text and lookup_text.strip():
        term = f"%{lookup_text.strip()}%"
        base_stmt = base_stmt.where(
            or_(
                FeedbackRecord.quote.ilike(term),
                FeedbackRecord.topic_tag.ilike(term),
                User.first_name.ilike(term),
                User.last_name.ilike(term),
                User.email.ilike(term),
                FeedbackRecord.education_level.ilike(term),
            )
        )

    # Count filtered rows
    count_stmt = select(func.count()).select_from(base_stmt.subquery())
    filtered_total = (await db.execute(count_stmt)).scalar() or 0

    # Paginate and order
    paginated_stmt = (
        base_stmt.order_by(FeedbackRecord.created_at.desc())
        .offset(page * size)
        .limit(size)
    )
    rows = (await db.execute(paginated_stmt)).all()

    items: list[FeedbackAdminResponse] = []
    for fb, u in rows:
        items.append(
            FeedbackAdminResponse(
                id=fb.id,
                feedback_id=fb.feedback_id,
                session_id=fb.session_id,
                user_id=fb.user_id,
                user_name=f"{u.first_name} {u.last_name}",
                user_email=u.email,
                education_level=fb.education_level,
                country=fb.user_country,
                rating=fb.rating,
                quote=fb.quote,
                topic_tag=fb.topic_tag,
                is_public_consent=fb.is_public_consent,
                status=fb.status,
                admin_notes=fb.admin_notes,
                created_at=fb.created_at,
                updated_at=fb.updated_at,
            )
        )

    return PaginatedFeedbackAdminResponse(
        items=items,
        total=filtered_total,
        metrics=metrics,
    )


# ─── 4. Admin Status & Notes Update (Admin Only) ─────────────────
@router.patch(
    "/admin/feedback/{feedback_id}/status",
    response_model=FeedbackAdminResponse,
    dependencies=[Depends(require_privilege(ET_MODERATE_FEEDBACK))],
)
async def update_feedback_status(
    feedback_id: str,
    payload: FeedbackStatusUpdateRequest,
    db: AsyncSession = Depends(get_db),
):
    """
    Admin updates feedback feature status and/or appends private internal notes.
    Note: The student's quote, rating, and identity are read-only and cannot be altered.
    """
    valid_statuses = ("pending", "featured", "archived")
    if payload.status not in valid_statuses:
        raise BadRequestException(
            error_code="INVALID_STATUS",
            errors=f"Status must be one of: {', '.join(valid_statuses)}.",
        )

    stmt = select(FeedbackRecord, User).join(User, FeedbackRecord.user_id == User.id).where(
        FeedbackRecord.feedback_id == feedback_id
    )
    res = await db.execute(stmt)
    row = res.one_or_none()

    if not row:
        raise NotFoundException(
            error_code="FEEDBACK_NOT_FOUND",
            errors=f"Feedback '{feedback_id}' not found.",
        )

    feedback, user = row
    feedback.status = payload.status

    if payload.admin_notes is not None:
        feedback.admin_notes = payload.admin_notes.strip()

    await db.commit()
    await db.refresh(feedback)

    return FeedbackAdminResponse(
        id=feedback.id,
        feedback_id=feedback.feedback_id,
        session_id=feedback.session_id,
        user_id=feedback.user_id,
        user_name=f"{user.first_name} {user.last_name}",
        user_email=user.email,
        education_level=feedback.education_level,
        country=feedback.user_country,
        rating=feedback.rating,
        quote=feedback.quote,
        topic_tag=feedback.topic_tag,
        is_public_consent=feedback.is_public_consent,
        status=feedback.status,
        admin_notes=feedback.admin_notes,
        created_at=feedback.created_at,
        updated_at=feedback.updated_at,
    )

