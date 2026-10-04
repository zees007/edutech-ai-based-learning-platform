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

from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Query

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
                data = event if isinstance(event, dict) else event.model_dump(mode="json")
                await ws.send_json(data)
            except Exception as e:
                logger.error(f"Failed to send event to {session_id}: {e}")


manager = ConnectionManager()


@router.websocket("/ws/learn/{session_id}")
async def learning_websocket(websocket: WebSocket, session_id: str, token: str | None = Query(None)):
    """
    WebSocket endpoint for real-time learning session streaming.
    """
    await manager.connect(session_id, websocket)

    actual_token = token or websocket.cookies.get("access_token")
    if not actual_token:
        await websocket.send_json({
            "event_type": "error",
            "message": "Authentication token missing. Please pass ?token=YOUR_JWT_TOKEN or set access_token cookie.",
        })
        await websocket.close()
        return

    try:
        from services.auth_service import AuthService
        from services.database import get_db_session
        from sqlalchemy import select
        from models.db_models import User
        from app.dependencies import has_privilege
        from app.privileges_config import ET_INTERACT_LEARNING_SESSION
        
        try:
            payload = AuthService.decode_access_token(actual_token)
            user_id = payload.get("sub")
        except Exception:
            await websocket.send_json({"event_type": "error", "message": "Invalid token."})
            await websocket.close()
            return
            
        async with get_db_session() as db:
            res = await db.execute(select(User).where(User.id == user_id))
            user = res.scalar_one_or_none()
            
        if not user or user.retired:
            await websocket.send_json({"event_type": "error", "message": "User not found or retired."})
            await websocket.close()
            return
            
        if not has_privilege(user, ET_INTERACT_LEARNING_SESSION):
            await websocket.send_json({"event_type": "error", "message": "Missing required privilege: ET_INTERACT_LEARNING_SESSION."})
            await websocket.close()
            return

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
            
        if memory.user_id != user.id and not has_privilege(user, "ET_ALL"):
            await websocket.send_json({
                "event_type": "error",
                "message": "You do not own this session.",
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

    # Timing buckets (ms) collected per agent/phase for the perf_summary WS event
    _timings: dict[str, float] = {}

    async def _timed_execute(agent, memory, step_index, name):
        t0 = time.time()
        try:
            res = await agent.execute(memory, step_index)
            elapsed = time.time() - t0
            _timings[name] = elapsed * 1000
            logger.info(f"[WS][{name}] finished in {elapsed:.2f}s ({elapsed*1000:.0f}ms)")
            return res
        except Exception as e:
            elapsed = time.time() - t0
            _timings[name] = elapsed * 1000
            logger.error(f"[WS][{name}] FAILED in {elapsed:.2f}s: {e}")
            raise e

    # ─── 1. Start parallel background tasks (YouTube + Academic Researcher) ─
    step = memory.steps[step_index] if step_index < len(memory.steps) else None

    youtube_start_time = time.time()
    try:
        from agents.youtube_curator import YouTubeCuratorAgent
        youtube_agent = YouTubeCuratorAgent()
        youtube_task = None
        if step and not step.videos:
            logger.info(f"[WS][YouTubeCuratorAgent] Starting parallel task for step {step_index}")
            youtube_task = asyncio.create_task(_timed_execute(youtube_agent, memory, step_index, "YouTubeCuratorAgent"))
        else:
            logger.info(f"[WS][YouTubeCuratorAgent] Skipping — videos already cached for step {step_index}")
    except ImportError:
        youtube_task = None

    try:
        from agents.academic_researcher import AcademicResearcherAgent
        academic_agent = AcademicResearcherAgent()
        academic_task = None
        if step and not step.papers:
            logger.info(f"[WS][AcademicResearcherAgent] Starting parallel task for step {step_index}")
            academic_task = asyncio.create_task(_timed_execute(academic_agent, memory, step_index, "AcademicResearcherAgent"))
        else:
            logger.info(f"[WS][AcademicResearcherAgent] Skipping — papers already cached for step {step_index}")
    except ImportError:
        academic_task = None

    # ─── 2. Stream Socratic Tutor explanation ────────────────
    tutor_start = time.time()
    logger.info(f"[WS][SocraticTutorAgent] Streaming explanation for step {step_index}...")
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
        tutor_elapsed = time.time() - tutor_start
        _timings["SocraticTutorAgent"] = tutor_elapsed * 1000
        logger.info(f"[WS][SocraticTutorAgent] Finished streaming in {tutor_elapsed:.2f}s ({tutor_elapsed*1000:.0f}ms)")
    except Exception as e:
        tutor_elapsed = time.time() - tutor_start
        _timings["SocraticTutorAgent"] = tutor_elapsed * 1000
        logger.error(f"[WS][SocraticTutorAgent] Streaming FAILED after {tutor_elapsed:.2f}s: {e}")
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
        logger.info(f"[WS][QuizAgent] Starting task for step {step_index}")
        quiz_task = asyncio.create_task(_timed_execute(quiz_agent, memory, step_index, "QuizAgent"))
    except ImportError:
        pass  # Quiz agent not yet implemented

    # ─── 4. Wait for core pedagogical agents (Academic Researcher + Quiz Agent) ──
    # PERF DECOUPLING: Academic Researcher (~1.5s) and Quiz Agent (~1s) complete rapidly.
    # We do NOT block step_complete on YouTube transcript indexing.
    # The client renders the full workspace immediately, and video clips hydrate
    # progressively via "step_videos_ready" when finished.
    parallel_wait_start = time.time()
    core_tasks = [t for t in [academic_task, quiz_task] if t is not None]
    if core_tasks:
        logger.info(f"[WS] Waiting for {len(core_tasks)} core parallel task(s) (Academic + Quiz)...")
        results = await asyncio.gather(*core_tasks, return_exceptions=True)
        for r in results:
            if isinstance(r, Exception):
                logger.warning(f"[WS] Core parallel agent error (non-fatal): {r}")
        _timings["parallel_gather_wall"] = (time.time() - parallel_wait_start) * 1000
        logger.info(f"[WS] Core parallel tasks completed in {_timings['parallel_gather_wall']:.0f}ms")

    # If YouTube Curator finished early (e.g. cache hit or chapter match), emit clips now
    youtube_already_done = youtube_task is not None and youtube_task.done()
    if youtube_already_done:
        for event in synthesizer.create_youtube_clip_events(memory, step_index):
            await manager.send_event(session_id, event)

    for event in synthesizer.create_academic_paper_events(memory, step_index):
        await manager.send_event(session_id, event)

    quiz_event = synthesizer.create_quiz_event(memory, step_index)
    if quiz_event:
        await manager.send_event(session_id, quiz_event)

    # Socratic questions
    sq_event = synthesizer.create_socratic_questions_event(memory, step_index)
    if sq_event:
        await manager.send_event(session_id, sq_event)

    # ─── 5. Persist core step BEFORE step_complete ───────────────────────────
    persist_start = time.time()
    try:
        await SessionManager().update_session(memory)
        _timings["db_persist"] = (time.time() - persist_start) * 1000
        logger.info(f"[WS] Session persisted to DB in {_timings['db_persist']:.0f}ms (before step_complete)")
    except Exception as e:
        _timings["db_persist"] = (time.time() - persist_start) * 1000
        logger.error(f"[WS] Failed to persist step {step_index} for session {session_id} ({_timings['db_persist']:.0f}ms): {e}")

    total_time = time.time() - step_start_time
    _timings["total_backend_ms"] = total_time * 1000

    # Determine YouTube Curator Agent status at the moment of core step completion
    youtube_status = "idle"
    if step and step.videos:
        youtube_status = "cached"
        _timings["YouTubeCuratorAgent"] = 0.0
    elif youtube_task is not None:
        if youtube_task.done():
            youtube_status = "completed"
            # _timings["YouTubeCuratorAgent"] already populated by _timed_execute
        else:
            youtube_status = "in_background"
            # Omit or pop from _timings so we don't send 0.0 when it is actually still running
            _timings.pop("YouTubeCuratorAgent", None)

    # ─── 6. Emit perf_summary so the client can log the backend breakdown ────
    try:
        perf_ws = manager.active_connections.get(session_id)
        if perf_ws:
            await perf_ws.send_json({
                "event_type": "perf_summary",
                "step_index": step_index,
                "timings_ms": {k: round(v, 1) for k, v in _timings.items()},
                "youtube_status": youtube_status,
            })
    except Exception:
        pass

    # ─── 7. Emit step_complete (User UI immediately unlocks in ~2.5s) ────────
    step_complete = synthesizer.create_step_complete_event(memory, step_index)
    await manager.send_event(session_id, step_complete)

    logger.info(
        "[WS] Step %d CORE DONE for session %s | total=%.2fs | "
        "tutor=%.0fms | youtube_status=%s (done_early=%s) | academic=%.0fms | quiz=%.0fms | db_persist=%.0fms",
        step_index, session_id, total_time,
        _timings.get("SocraticTutorAgent", 0),
        youtube_status,
        youtube_already_done,
        _timings.get("AcademicResearcherAgent", 0),
        _timings.get("QuizAgent", 0),
        _timings.get("db_persist", 0),
    )

    # ─── 8. Background video hydration if YouTube Curator is still indexing ──
    if youtube_task is not None and not youtube_already_done:
        async def _finish_youtube_and_notify():
            try:
                await youtube_task
                duration_ms = _timings.get("YouTubeCuratorAgent", (time.time() - youtube_start_time) * 1000)
                # Persist updated videos to DB
                await SessionManager().update_session(memory)
                step_obj = memory.steps[step_index] if step_index < len(memory.steps) else None
                videos_data = [v.model_dump() for v in step_obj.videos] if (step_obj and step_obj.videos) else []

                # Emit individual clip events for backward compatibility
                for event in synthesizer.create_youtube_clip_events(memory, step_index):
                    await manager.send_event(session_id, event)

                # Emit progressive step_videos_ready event to hydrate UI shimmer
                ready_event = synthesizer.create_step_videos_ready_event(
                    memory, step_index, duration_ms=round(duration_ms, 1)
                )
                await manager.send_event(session_id, ready_event)
                logger.info(
                    f"[WS] Background YouTube curation completed for step {step_index} in "
                    f"{duration_ms:.0f}ms ({duration_ms/1000:.2f}s): {len(videos_data)} clips"
                )
            except Exception as e:
                duration_ms = _timings.get("YouTubeCuratorAgent", (time.time() - youtube_start_time) * 1000)
                logger.warning(
                    f"[WS] Background YouTube curation failed for step {step_index} after "
                    f"{duration_ms:.0f}ms: {e}"
                )
                # Still emit step_videos_ready with empty list so client removes shimmer
                await manager.send_event(session_id, {
                    "event_type": "step_videos_ready",
                    "session_id": session_id,
                    "step_index": step_index,
                    "videos": [],
                    "duration_ms": round(duration_ms, 1),
                })

        asyncio.create_task(_finish_youtube_and_notify())


async def _handle_chat(session_id: str, memory: SharedMemory, question: str):
    """Handle a follow-up question from the student during a step."""
    ws = manager.active_connections.get(session_id)
    if not ws:
        return

    step_index = memory.current_step_index
    step = memory.steps[step_index]
    
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
        
    if not is_unlimited and step.follow_up_count >= limit:
        await ws.send_json({
            "event_type": "error",
            "message": f"Follow-up limit reached for this step. Upgrade for more questions.",
        })
        return
            
    step.follow_up_count += 1
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
