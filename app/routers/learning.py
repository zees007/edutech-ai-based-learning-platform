"""
EduTechAI — Learning REST Endpoints

REST API for managing learning sessions:
- POST /api/learn — Start a new learning session
- GET /api/sessions/{session_id} — Get session state & progress
- POST /api/sessions/{session_id}/step/{step_index}/complete — Mark step done
- POST /api/sessions/{session_id}/mode — Switch learning mode
- GET /api/sessions — Search & paginate user learning sessions
- DELETE /api/sessions/{session_id} — Delete learning session
"""

from __future__ import annotations

import asyncio
import logging

from fastapi import APIRouter, Depends, Query

from agents.orchestrator import OrchestratorAgent
from app.dependencies import get_current_user, require_privilege
from app.exceptions import BadRequestException, NotFoundException
from app.privileges_config import (
    ET_INTERACT_LEARNING_SESSION,
    ET_START_LEARNING_SESSION,
    ET_VIEW_LEARNING_HISTORY,
)
from models.db_models import User
from models.schemas import (
    LearningMode,
    LearningRequest,
    ModeChangeRequest,
    SessionResponse,
)
from models.shared_memory import SharedMemory
from models.user_schemas import SearchDTO
from services.session_manager import SessionManager

logger = logging.getLogger(__name__)
router = APIRouter()
session_manager = SessionManager()

# ─── In-memory session store ─────────────────────────────────────
_sessions: dict[str, SharedMemory] = {}


async def get_session_or_404(session_id: str) -> SharedMemory:
    """Retrieve a session from memory or DB, or raise 404."""
    if session_id in _sessions:
        return _sessions[session_id]

    memory = await session_manager.get_session(session_id)
    if memory:
        _sessions[session_id] = memory
        return memory

    raise NotFoundException(
        error_code="SESSION_NOT_FOUND",
        errors=f"Session '{session_id}' not found.",
    )


# Backward-compatible alias
get_session = get_session_or_404


@router.post(
    "/learn",
    response_model=SessionResponse,
    dependencies=[Depends(require_privilege(ET_START_LEARNING_SESSION))],
)
async def start_learning_session(
    request: LearningRequest,
    current_user: User = Depends(get_current_user),
):
    """
    Start a new learning session for a topic.

    The Orchestrator agent will decompose the topic into milestone steps.
    Returns the session ID and the learning plan.
    """
    logger.info(
        f"New learning session for user '{current_user.id}': topic='{request.topic}', mode={request.learning_mode}"
    )

    # Create SharedMemory for this session
    memory = SharedMemory(
        user_id=current_user.id,
        topic=request.topic,
        learning_mode=request.learning_mode,
        student_level=request.student_level,
    )

    # Run the Orchestrator to create the learning plan
    orchestrator = OrchestratorAgent()
    await orchestrator.execute(memory)

    # Store in-memory and persist to Supabase database
    _sessions[memory.session_id] = memory
    try:
        await session_manager.create_session(memory, user_id=current_user.id)
    except Exception as e:
        logger.warning(f"Failed to persist session {memory.session_id} to DB: {e}")

    logger.info(f"Session {memory.session_id} created with {len(memory.steps)} steps")

    return SessionResponse(
        session_id=memory.session_id,
        topic=memory.topic,
        learning_mode=memory.learning_mode,
        student_level=memory.student_level,
        created_at=memory.created_at,
        steps=memory.steps,
        current_step_index=memory.current_step_index,
        xp_earned=memory.xp_earned,
        steps_completed=memory.steps_completed,
    )


@router.get(
    "/sessions/{session_id}",
    response_model=SessionResponse,
    dependencies=[Depends(require_privilege(ET_INTERACT_LEARNING_SESSION))],
)
async def get_session_state(session_id: str):
    """Retrieve the current state of a learning session."""
    memory = await get_session_or_404(session_id)
    return SessionResponse(
        session_id=memory.session_id,
        topic=memory.topic,
        learning_mode=memory.learning_mode,
        student_level=memory.student_level,
        created_at=memory.created_at,
        steps=memory.steps,
        current_step_index=memory.current_step_index,
        xp_earned=memory.xp_earned,
        steps_completed=memory.steps_completed,
    )


@router.post(
    "/sessions/{session_id}/step/{step_index}/complete",
    dependencies=[Depends(require_privilege(ET_INTERACT_LEARNING_SESSION))],
)
async def complete_step(session_id: str, step_index: int):
    """
    Mark a step as complete and advance the session progress.
    Awards XP via Gamification service.
    """
    memory = await get_session_or_404(session_id)

    if step_index < 0 or step_index >= len(memory.steps):
        raise BadRequestException(
            error_code="INVALID_STEP_INDEX",
            errors=f"Step index {step_index} out of range [0, {len(memory.steps) - 1}]",
        )

    # Mark complete
    memory.mark_step_complete(step_index)

    # Award XP
    from services.gamification import calculate_step_xp

    base_xp = calculate_step_xp(streak_count=memory.streak_count)
    memory.xp_earned += base_xp

    # Persist to database
    try:
        await session_manager.update_session(memory)
        await session_manager.save_step_progress(
            session_id=session_id,
            step_index=step_index,
            status="complete",
        )
    except Exception as e:
        logger.warning(f"Failed to persist step progress to DB: {e}")

    logger.info(
        f"Session {session_id}: step {step_index} completed (+{base_xp} XP, total={memory.xp_earned})"
    )

    return {
        "message": f"Step {step_index} completed!",
        "xp_earned": base_xp,
        "total_xp": memory.xp_earned,
        "next_step_index": memory.current_step_index,
        "is_session_complete": memory.is_complete,
        "progress_percentage": memory.progress_percentage,
    }


@router.post(
    "/sessions/{session_id}/mode",
    dependencies=[Depends(require_privilege(ET_INTERACT_LEARNING_SESSION))],
)
async def change_learning_mode(session_id: str, request: ModeChangeRequest):
    """
    Switch the learning mode for an active session.
    Affects how subsequent steps are generated (content depth, media emphasis).
    """
    memory = await get_session_or_404(session_id)
    old_mode = memory.learning_mode
    memory.learning_mode = request.learning_mode

    try:
        await session_manager.update_session(memory)
    except Exception as e:
        logger.warning(f"Failed to update session mode in DB: {e}")

    logger.info(f"Session {session_id}: mode changed {old_mode} → {request.learning_mode}")

    return {
        "message": f"Learning mode changed to {request.learning_mode.value}",
        "previous_mode": old_mode.value,
        "new_mode": request.learning_mode.value,
    }


@router.get(
    "/sessions",
    dependencies=[Depends(require_privilege(ET_VIEW_LEARNING_HISTORY))],
)
async def list_user_sessions(
    page: int = Query(0, ge=0, description="0-indexed page number"),
    size: int = Query(20, ge=1, le=100, description="Page size limit"),
    lookup_text: str | None = Query(None, description="Search term for topic, mode, level"),
    status_filter: str = Query("all", description="Status filter: all, in_progress, completed"),
    current_user: User = Depends(get_current_user),
):
    """
    Search & paginate learning sessions for the currently authenticated user.
    Incomplete sessions are sorted to the top, followed by completed sessions.
    """
    search_dto = SearchDTO(
        page=page,
        size=size,
        sortBy="updated_at",
        isDesc=True,
        lookupText=lookup_text,
    )
    items, total = await session_manager.search_user_sessions(
        user_id=current_user.id,
        dto=search_dto,
        status_filter=status_filter,
    )

    return {
        "items": items,
        "total": total,
        "page": page,
        "size": size,
    }


@router.delete(
    "/sessions/{session_id}",
    dependencies=[Depends(require_privilege(ET_INTERACT_LEARNING_SESSION))],
)
async def delete_user_session(
    session_id: str,
    current_user: User = Depends(get_current_user),
):
    """
    Delete a learning session and associated progress records belonging to the current user.
    """
    deleted = await session_manager.delete_session(session_id=session_id, user_id=current_user.id)
    if not deleted:
        raise NotFoundException(
            error_code="SESSION_NOT_FOUND",
            errors=f"Session '{session_id}' not found or not owned by user.",
        )

    # Remove from in-memory cache if present
    _sessions.pop(session_id, None)

    return {"message": f"Session '{session_id}' deleted successfully"}
