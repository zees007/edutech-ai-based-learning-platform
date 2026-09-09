"""
EduTechAI — WebSocket Streaming Endpoint

Real-time streaming of agent outputs to the client.

Protocol:
    1. Client connects to /ws/learn/{session_id}
    2. Server streams events as agents complete their work:
       - plan: The learning plan from the Orchestrator
       - explanation_chunk: Streamed tokens from the Socratic Tutor
       - youtube_clip: Found video clips
       - academic_paper: Found papers
       - quiz: Quiz questions
       - step_complete: All agents done for this step
       - xp_update: XP earned
       - error: Error occurred
    3. Client sends messages to control the flow:
       - {"action": "start_step", "step_index": 0}
       - {"action": "next_step"}
"""

from __future__ import annotations

import asyncio
import json
import logging
import time

from fastapi import APIRouter, WebSocket, WebSocketDisconnect

from agents.orchestrator import OrchestratorAgent
from agents.socratic_tutor import SocraticTutorAgent
from agents.synthesizer import SynthesizerAgent
from models.schemas import ErrorEvent
from models.shared_memory import SharedMemory

logger = logging.getLogger(__name__)
router = APIRouter()

# Import the session store from learning router
from app.routers.learning import _sessions
from services.session_manager import SessionManager


class ConnectionManager:
    """Manages active WebSocket connections."""

    def __init__(self):
        self.active_connections: dict[str, WebSocket] = {}

    async def connect(self, session_id: str, websocket: WebSocket):
        await websocket.accept()
        self.active_connections[session_id] = websocket
        logger.info(f"WebSocket connected: session={session_id}")

    def disconnect(self, session_id: str):
        self.active_connections.pop(session_id, None)
        logger.info(f"WebSocket disconnected: session={session_id}")

    async def send_event(self, session_id: str, event):
        """Send a typed event as JSON to the client."""
        ws = self.active_connections.get(session_id)
        if ws:
            try:
                await ws.send_json(event.model_dump(mode="json"))
            except Exception as e:
                logger.error(f"Failed to send event to {session_id}: {e}")


manager = ConnectionManager()


@router.websocket("/ws/learn/{session_id}")
async def learning_websocket(websocket: WebSocket, session_id: str):
    """
    WebSocket endpoint for real-time learning session streaming.

    Flow:
    1. Connect and validate session exists
    2. Stream the learning plan
    3. For each step, run agents and stream their outputs
    4. Wait for client to advance to next step
    """
    await manager.connect(session_id, websocket)

    try:
        # Get or create session
        memory = _sessions.get(session_id)
        if memory is None:
            from services.session_manager import SessionManager
            memory = await SessionManager().get_session(session_id)
            if memory:
                _sessions[session_id] = memory

        if memory is None:
            await websocket.send_json({
                "event_type": "error",
                "message": f"Session '{session_id}' not found. Create one first via POST /api/learn.",
            })
            await websocket.close()
            return

        synthesizer = SynthesizerAgent()

        # Send the learning plan
        plan_event = synthesizer.create_plan_event(memory)
        await manager.send_event(session_id, plan_event)

        # Main event loop — wait for client commands
        while True:
            try:
                raw = await websocket.receive_text()
                message = json.loads(raw)
                action = message.get("action", "")

                if action == "start_step":
                    step_index = message.get("step_index", memory.current_step_index)
                    await _process_step(session_id, memory, step_index, synthesizer)

                elif action == "next_step":
                    if memory.is_complete:
                        await websocket.send_json({
                            "event_type": "session_complete",
                            "session_id": session_id,
                            "total_xp": memory.xp_earned,
                            "message": "Congratulations! You've completed all steps!",
                        })
                    else:
                        await _process_step(
                            session_id,
                            memory,
                            memory.current_step_index,
                            synthesizer,
                        )

                elif action == "chat":
                    # Handle follow-up student questions
                    student_message = message.get("content", "")
                    if student_message:
                        await _handle_chat(session_id, memory, student_message)

                else:
                    await websocket.send_json({
                        "event_type": "error",
                        "message": f"Unknown action: '{action}'. Use 'start_step', 'next_step', or 'chat'.",
                    })

            except json.JSONDecodeError:
                await websocket.send_json({
                    "event_type": "error",
                    "message": "Invalid JSON. Send: {\"action\": \"start_step\", \"step_index\": 0}",
                })

    except WebSocketDisconnect:
        manager.disconnect(session_id)
    except Exception as e:
        logger.error(f"WebSocket error for session {session_id}: {e}")
        manager.disconnect(session_id)


async def _process_step(
    session_id: str,
    memory: SharedMemory,
    step_index: int,
    synthesizer: SynthesizerAgent,
):
    """
    Run all agents for a given step and stream their outputs.

    Execution order:
    1. Socratic Tutor (streamed token-by-token)
    2. YouTube Curator + Academic Researcher (parallel, non-blocking)
    3. Quiz Agent (after tutor completes — needs explanation context)
    4. Step complete event
    """
    ws = manager.active_connections.get(session_id)
    if not ws:
        return

    if step_index >= len(memory.steps):
        await ws.send_json({
            "event_type": "error",
            "message": f"Step {step_index} does not exist.",
        })
        return

    logger.info(f"Processing step {step_index} for session {session_id}")
    step_start_time = time.time()

    async def _timed_execute(agent, memory, step_index, name):
        t0 = time.time()
        try:
            res = await agent.execute(memory, step_index)
            logger.info(f"[{name}] finished in {time.time() - t0:.2f}s")
            return res
        except Exception as e:
            logger.error(f"[{name}] failed in {time.time() - t0:.2f}s: {e}")
            raise e

    # ─── 1. Start parallel background tasks (YouTube + Academic Researcher) ─
    try:
        from agents.youtube_curator import YouTubeCuratorAgent
        youtube_agent = YouTubeCuratorAgent()
        youtube_task = asyncio.create_task(_timed_execute(youtube_agent, memory, step_index, "YouTubeCuratorAgent"))
    except ImportError:
        youtube_task = None

    try:
        from agents.academic_researcher import AcademicResearcherAgent
        academic_agent = AcademicResearcherAgent()
        academic_task = asyncio.create_task(_timed_execute(academic_agent, memory, step_index, "AcademicResearcherAgent"))
    except ImportError:
        academic_task = None

    # ─── 2. Stream Socratic Tutor explanation ────────────────
    tutor_start = time.time()
    tutor = SocraticTutorAgent()
    try:
        async for chunk in tutor.stream_explanation(memory, step_index):
            event = synthesizer.create_explanation_chunk_event(
                memory, step_index, chunk, is_final=False
            )
            await manager.send_event(session_id, event)

        # Send final chunk marker
        final_event = synthesizer.create_explanation_chunk_event(
            memory, step_index, "", is_final=True
        )
        await manager.send_event(session_id, final_event)
        logger.info(f"[SocraticTutorAgent] finished streaming in {time.time() - tutor_start:.2f}s")
    except Exception as e:
        logger.error(f"Tutor streaming failed: {e}")
        error_event = ErrorEvent(
            session_id=session_id,
            message=f"Tutor error: {e}",
            agent="SocraticTutor",
        )
        await manager.send_event(session_id, error_event)

    # ─── 3. Start Quiz Agent (needs explanation from tutor) ──
    quiz_task = None
    try:
        from agents.quiz_agent import QuizAgent
        quiz_agent = QuizAgent()
        quiz_task = asyncio.create_task(_timed_execute(quiz_agent, memory, step_index, "QuizAgent"))
    except ImportError:
        pass  # Quiz agent not yet implemented

    # Wait for parallel agents to complete
    tasks = [t for t in [youtube_task, academic_task, quiz_task] if t is not None]
    if tasks:
        results = await asyncio.gather(*tasks, return_exceptions=True)
        for r in results:
            if isinstance(r, Exception):
                logger.warning(f"Agent error (non-fatal): {r}")

    # Send YouTube clip and paper events
    for event in synthesizer.create_youtube_clip_events(memory, step_index):
        await manager.send_event(session_id, event)

    for event in synthesizer.create_academic_paper_events(memory, step_index):
        await manager.send_event(session_id, event)

    quiz_event = synthesizer.create_quiz_event(memory, step_index)
    if quiz_event:
        await manager.send_event(session_id, quiz_event)

    # ─── 4. Socratic questions ───────────────────────────────
    sq_event = synthesizer.create_socratic_questions_event(memory, step_index)
    if sq_event:
        await manager.send_event(session_id, sq_event)

    # ─── 5. Step complete ────────────────────────────────────
    step_complete = synthesizer.create_step_complete_event(memory, step_index)
    await manager.send_event(session_id, step_complete)

    total_time = time.time() - step_start_time
    logger.info(f"[SynthesizerAgent] Total time taken to render step {step_index}: {total_time:.2f}s")

    try:
        await SessionManager().update_session(memory)
    except Exception as e:
        logger.error(f"Failed to persist step {step_index} for session {session_id}: {e}")

    logger.info(f"Step {step_index} fully processed for session {session_id}")


async def _handle_chat(session_id: str, memory: SharedMemory, question: str):
    """Handle a follow-up question from the student during a step."""
    ws = manager.active_connections.get(session_id)
    if not ws:
        return

    step_index = memory.current_step_index
    step_result = memory.get_step_result(step_index)
    
    # ─── Enforce Follow-up Limits ───
    from services.database import get_db_session
    from sqlalchemy.orm import selectinload
    from sqlalchemy import select
    from models.db_models import User, Role
    from app.dependencies import has_privilege
    from app.privileges_config import ET_UNLIMITED_FOLLOW_UPS
    
    is_unlimited = False
    user_roles = []
    if memory.user_id:
        try:
            async with get_db_session() as db:
                res = await db.execute(
                    select(User).options(selectinload(User.roles).selectinload(Role.privileges))
                    .where(User.id == memory.user_id)
                )
                user = res.scalar_one_or_none()
            if user:
                is_unlimited = has_privilege(user, ET_UNLIMITED_FOLLOW_UPS)
                user_roles = [r.name for r in user.roles if not r.retired]
        except Exception as e:
            logger.warning(f"Failed to check user privileges for chat: {e}")
        
    from config import get_settings
    settings = get_settings()
    
    limit = settings.free_followup_limit
    if "Pro" in user_roles:
        limit = settings.pro_followup_limit
        
    if not is_unlimited and step_result.follow_up_count >= limit:
        await ws.send_json({
            "event_type": "error",
            "message": f"Follow-up limit reached for this step. Upgrade for more questions.",
        })
        return
            
    step_result.follow_up_count += 1
    memory.add_conversation_turn("student", question, step_index=step_index)

    tutor = SocraticTutorAgent()
    synthesizer = SynthesizerAgent()

    try:
        async for chunk in tutor.stream_followup(question, memory, step_index):
            event = synthesizer.create_explanation_chunk_event(
                memory, step_index, chunk, is_final=False
            )
            await manager.send_event(session_id, event)

        final_event = synthesizer.create_explanation_chunk_event(
            memory, step_index, "", is_final=True
        )
        await manager.send_event(session_id, final_event)
        
        try:
            await SessionManager().update_session(memory)
        except Exception as e:
            logger.error(f"Failed to persist chat response for session {session_id}: {e}")

    except Exception as e:
        logger.error(f"Chat response failed: {e}")
        error_event = ErrorEvent(
            session_id=session_id,
            message=f"Tutor chat failed: {e}",
            agent="SocraticTutor",
        )
        await manager.send_event(session_id, error_event)
