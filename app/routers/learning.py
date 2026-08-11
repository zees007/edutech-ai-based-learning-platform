"""
EduTechAI — Learning REST Endpoints

REST API for managing learning sessions:
- POST /api/learn — Start a new learning session
- GET /api/sessions/{session_id} — Get session state & progress
- POST /api/sessions/{session_id}/step/{step_index}/complete — Mark step done
- POST /api/sessions/{session_id}/mode — Switch learning mode
"""

from __future__ import annotations

import asyncio
import logging

from fastapi import APIRouter, HTTPException

from agents.orchestrator import OrchestratorAgent
from models.schemas import (
    LearningMode,
    LearningRequest,
    ModeChangeRequest,
    SessionResponse,
)
from models.shared_memory import SharedMemory

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
        
    raise HTTPException(status_code=404, detail=f"Session '{session_id}' not found.")

# Backward-compatible alias
get_session = get_session_or_404


@router.post("/learn", response_model=SessionResponse)
async def start_learning_session(request: LearningRequest):
    """
    Start a new learning session for a topic.

    The Orchestrator agent will decompose the topic into milestone steps.
    Returns the session ID and the learning plan.
    """
    logger.info(f"New learning session: topic='{request.topic}', mode={request.learning_mode}")

    # Create SharedMemory for this session
    memory = SharedMemory(
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
        await session_manager.create_session(memory)
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


@router.get("/sessions/{session_id}", response_model=SessionResponse)
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


@router.post("/sessions/{session_id}/step/{step_index}/complete")
async def complete_step(session_id: str, step_index: int):
    """
    Mark a milestone step as complete and advance to the next step.
    Awards XP for completion.
    """
    memory = await get_session_or_404(session_id)

    if step_index >= len(memory.steps):
        raise HTTPException(status_code=400, detail=f"Step {step_index} does not exist.")

    if step_index != memory.current_step_index:
        raise HTTPException(
            status_code=400,
            detail=f"Cannot complete step {step_index}. Current step is {memory.current_step_index}.",
        )

    # Mark step complete (this also advances current_step_index)
    memory.mark_step_complete(step_index)

    # Award base XP for completing a step
    base_xp = 50
    memory.xp_earned += base_xp

    # Persist updates to DB
    try:
        await session_manager.update_session(memory)
        await session_manager.save_step_progress(session_id, step_index, "complete")
    except Exception as e:
        logger.warning(f"Failed to update session progress in DB: {e}")

    logger.info(
        f"Session {session_id}: step {step_index} complete. "
        f"XP: +{base_xp} (total: {memory.xp_earned})"
    )

    return {
        "message": f"Step {step_index} completed!",
        "xp_earned": base_xp,
        "total_xp": memory.xp_earned,
        "next_step_index": memory.current_step_index,
        "is_session_complete": memory.is_complete,
        "progress_percentage": memory.progress_percentage,
    }


@router.post("/sessions/{session_id}/mode")
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


@router.get("/sessions")
async def list_sessions():
    """List all active learning sessions (for debugging)."""
    return {
        "sessions": [
            {
                "session_id": sid,
                "topic": mem.topic,
                "steps": len(mem.steps),
                "progress": f"{mem.progress_percentage:.0f}%",
            }
            for sid, mem in _sessions.items()
        ]
    }
