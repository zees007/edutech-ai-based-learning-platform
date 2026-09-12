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

from pydantic import BaseModel
from agents.orchestrator import OrchestratorAgent
from agents.socratic_tutor import SocraticTutorAgent
from app.dependencies import get_current_user, require_privilege, has_privilege
from app.exceptions import BadRequestException, NotFoundException, ForbiddenException
from app.privileges_config import (
    ET_INTERACT_LEARNING_SESSION,
    ET_START_LEARNING_SESSION,
    ET_VIEW_LEARNING_HISTORY,
    ET_ACCESS_ADVANCED_MODES,
    ET_REGENERATE_STEP,
    ET_ACCESS_ACADEMIC_SEARCH,
)
from models.db_models import User
from models.schemas import (
    AcademicPaper,
    LearningMode,
    LearningRequest,
    ModeChangeRequest,
    SessionResponse,
    StepStatus,
)
from models.shared_memory import SharedMemory
from models.user_schemas import SearchDTO
from services.session_manager import SessionManager

class FollowUpRequest(BaseModel):
    question: str

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


def _build_session_response(memory: SharedMemory) -> SessionResponse:
    """Helper to merge step results into the milestone steps for API responses."""
    for idx, step in enumerate(memory.steps):
        result = memory.step_results.get(idx)
        if result:
            step.tutor_explanation = result.explanation or step.tutor_explanation
            step.socratic_questions = result.socratic_questions or step.socratic_questions
            step.videos = result.youtube_clips or step.videos
            step.papers = result.academic_papers or step.papers
            step.quiz = result.quiz.questions if result.quiz else step.quiz
            if result.status and result.status != StepStatus.PENDING:
                step.status = result.status

        # Synchronize quiz score from session-level dict onto the step if not set
        if step.quiz_score is None and idx in memory.quiz_scores:
            step.quiz_score = memory.quiz_scores[idx]

        if idx < memory.steps_completed:
            step.status = StepStatus.COMPLETE
        elif idx == memory.current_step_index and step.status != StepStatus.COMPLETE:
            step.status = StepStatus.IN_PROGRESS

        step.conversation_history = [
            turn for turn in memory.conversation_history
            if turn.step_index == idx
        ]

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
        conversation_history=memory.conversation_history,
    )


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

    # 1. Enforce Learning Mode Privilege
    if request.learning_mode in [LearningMode.VISUAL, LearningMode.DEEP_DIVE]:
        if not has_privilege(current_user, ET_ACCESS_ADVANCED_MODES):
            raise ForbiddenException(
                error_code="MODE_UPGRADE_REQUIRED",
                errors="Upgrade to Pro or Ultra to access Visual or Deep Dive modes."
            )

    # 2. Enforce Monthly Session Quota for Free Tier
    # (Assuming any user without ET_ACCESS_ADVANCED_MODES is on the Free tier)
    is_premium = has_privilege(current_user, ET_ACCESS_ADVANCED_MODES)
    if not is_premium:
        monthly_sessions = await session_manager.get_monthly_session_count(current_user.id)
        if monthly_sessions >= 10:
            raise ForbiddenException(
                error_code="SESSION_QUOTA_EXCEEDED",
                errors="You have reached your limit of 10 free AI sessions this month. Upgrade to Pro for unlimited sessions."
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

    return _build_session_response(memory)


@router.get(
    "/sessions/{session_id}",
    response_model=SessionResponse,
    dependencies=[Depends(require_privilege(ET_INTERACT_LEARNING_SESSION))],
)
async def get_session_state(session_id: str):
    """Retrieve the current state of a learning session."""
    memory = await get_session_or_404(session_id)
    return _build_session_response(memory)


@router.post(
    "/sessions/{session_id}/step/{step_index}/complete",
    dependencies=[Depends(require_privilege(ET_INTERACT_LEARNING_SESSION))],
)
async def complete_step(
    session_id: str, 
    step_index: int,
    current_user: User = Depends(get_current_user)
):
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
    from services.gamification import calculate_step_xp, update_streak, XP_SESSION_COMPLETE

    memory.streak_count = update_streak(
        memory.created_at,
        getattr(memory, "streak_count", 0),
    )
    base_xp = calculate_step_xp(streak_count=memory.streak_count)
    
    # Apply XP Multiplier (Ultra=2.0x, Pro=1.5x, Free=1.0x)
    user_roles = [r.name for r in current_user.roles if not r.retired] if hasattr(current_user, "roles") else []
    multiplier = 1.0
    if "Ultra" in user_roles or "Admin" in user_roles:
        multiplier = 2.0
    elif "Pro" in user_roles:
        multiplier = 1.5
        
    awarded_xp = int(base_xp * multiplier)

    # Award +100 XP session completion bonus if all milestone steps are now complete
    if memory.is_complete:
        session_bonus = int(XP_SESSION_COMPLETE * multiplier)
        awarded_xp += session_bonus

    memory.xp_earned += awarded_xp

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
        f"Session {session_id}: step {step_index} completed (+{awarded_xp} XP, total={memory.xp_earned})"
    )

    return {
        "message": f"Step {step_index} completed!",
        "xp_earned": awarded_xp,
        "total_xp": memory.xp_earned,
        "next_step_index": memory.current_step_index,
        "is_session_complete": memory.is_complete,
        "progress_percentage": memory.progress_percentage,
    }


@router.post(
    "/sessions/{session_id}/step/{step_index}/followup",
    dependencies=[Depends(require_privilege(ET_INTERACT_LEARNING_SESSION))],
)
async def answer_followup(
    session_id: str, 
    step_index: int,
    request: FollowUpRequest,
    current_user: User = Depends(get_current_user)
):
    """
    Answer a follow up question from the student on a specific step.
    """
    memory = await get_session_or_404(session_id)

    if step_index < 0 or step_index >= len(memory.steps):
        raise BadRequestException(
            error_code="INVALID_STEP_INDEX",
            errors=f"Step index {step_index} out of range [0, {len(memory.steps) - 1}]",
        )

    tutor = SocraticTutorAgent()
    step = memory.steps[step_index]
    step_result = memory.get_step_result(step_index)
    
    memory.add_conversation_turn("student", request.question, step_index=step_index)

    chat_history_dicts = [
        {"role": "user" if t.role == "student" else "assistant", "text": t.content}
        for t in memory.conversation_history
    ]

    answer = await tutor.answer_followup(
        question=request.question,
        step_title=step.title,
        step_description=step.description,
        explanation=step_result.explanation or "",
        topic=memory.topic,
        student_level=memory.student_level,
        chat_history=chat_history_dicts,
    )
    
    memory.add_conversation_turn("tutor", answer, step_index=step_index)
    
    try:
        await session_manager.update_session(memory)
    except Exception as e:
        logger.warning(f"Failed to persist session after follow-up: {e}")

    return {"answer": answer}

@router.post(
    "/sessions/{session_id}/step/{step_index}/regenerate",
    dependencies=[Depends(require_privilege(ET_REGENERATE_STEP))],
)
async def regenerate_step(
    session_id: str, 
    step_index: int,
):
    """
    Regenerate the content and results for a specific step.
    Requires ET_REGENERATE_STEP privilege (Pro/Ultra feature).
    """
    memory = await get_session_or_404(session_id)

    if step_index < 0 or step_index >= len(memory.steps):
        raise BadRequestException(
            error_code="INVALID_STEP_INDEX",
            errors=f"Step index {step_index} out of range [0, {len(memory.steps) - 1}]",
        )

    # Clear the step result so it can be regenerated upon next interaction or load
    if step_index in memory.step_results:
        del memory.step_results[step_index]
    
    # We could optionally trigger the agents right here, but typically the orchestrator/ws layer 
    # lazy-loads or we just return success and let the client re-fetch/re-interact.

    try:
        await session_manager.update_session(memory)
    except Exception as e:
        logger.warning(f"Failed to update session after step regeneration: {e}")

    logger.info(f"Session {session_id}: step {step_index} cleared for regeneration")

    return {
        "message": f"Step {step_index} has been marked for regeneration.",
    }


@router.post(
    "/sessions/{session_id}/mode",
    dependencies=[Depends(require_privilege(ET_INTERACT_LEARNING_SESSION))],
)
async def change_learning_mode(
    session_id: str, 
    request: ModeChangeRequest,
    current_user: User = Depends(get_current_user)
):
    """
    Switch the learning mode for an active session.
    Affects how subsequent steps are generated (content depth, media emphasis).
    """
    memory = await get_session_or_404(session_id)
    
    # Check privilege for advanced modes
    if request.learning_mode in [LearningMode.VISUAL, LearningMode.DEEP_DIVE]:
        if not has_privilege(current_user, ET_ACCESS_ADVANCED_MODES):
            raise ForbiddenException(
                error_code="MODE_UPGRADE_REQUIRED",
                errors="Upgrade to Pro or Ultra to access Visual or Deep Dive modes."
            )

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


@router.get(
    "/academic/search",
    response_model=list[AcademicPaper],
    dependencies=[Depends(require_privilege(ET_ACCESS_ACADEMIC_SEARCH))],
)
async def search_academic_papers(
    query: str = Query(..., min_length=1, description="Topic or query keywords for scholarly research"),
    max_results: int = Query(5, ge=1, le=10, description="Maximum number of papers to return"),
    current_user: User = Depends(get_current_user),
):
    """
    Search across OpenAlex, Semantic Scholar, and arXiv in parallel.
    Returns deduplicated, relevance-ranked papers with AI TLDR summaries & open-access links.
    Protected by ET_ACCESS_ACADEMIC_SEARCH privilege.
    """
    from services.academic_client import AcademicClient

    client = AcademicClient()
    papers = await client.search_all(query=query, max_results=max_results)
    return papers

