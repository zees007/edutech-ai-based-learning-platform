"""
EduTechAI — Session Manager Service

Handles session persistence via SQLAlchemy ORM.
Serializes/deserializes SharedMemory state to/from the database.

Uses SQLAlchemy async sessions — portable across SQLite and PostgreSQL
(change DATABASE_URL in .env to switch).
"""

from __future__ import annotations

import json
import logging
from datetime import datetime

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from models.db_models import GamificationRecord, SessionRecord, StepProgress
from models.shared_memory import SharedMemory
from services.database import get_db_session

logger = logging.getLogger(__name__)


class SessionManager:
    """
    Session CRUD operations via SQLAlchemy ORM.

    The full SharedMemory state is serialized to JSON and stored in the
    `state_json` column, enabling complete session recovery on reconnect.
    """

    async def create_session(self, memory: SharedMemory) -> SessionRecord:
        """Persist a new learning session to the database."""
        async with get_db_session() as db:
            record = SessionRecord(
                session_id=memory.session_id,
                topic=memory.topic,
                learning_mode=memory.learning_mode.value,
                student_level=memory.student_level,
                total_steps=len(memory.steps),
                current_step_index=memory.current_step_index,
                is_complete=memory.is_complete,
                state_json=memory.model_dump(mode="json"),
            )
            db.add(record)

            # Create gamification record
            gamification = GamificationRecord(
                session_id=memory.session_id,
                xp_earned=memory.xp_earned,
                streak_count=memory.streak_count,
            )
            db.add(gamification)

            logger.info(f"Session {memory.session_id} persisted to database.")
            return record

    async def get_session(self, session_id: str) -> SharedMemory | None:
        """Retrieve a session from the database and reconstruct SharedMemory."""
        async with get_db_session() as db:
            result = await db.execute(
                select(SessionRecord).where(SessionRecord.session_id == session_id)
            )
            record = result.scalar_one_or_none()

            if record is None:
                return None

            if record.state_json:
                try:
                    return SharedMemory.model_validate(record.state_json)
                except Exception as e:
                    logger.error(f"Failed to deserialize session {session_id}: {e}")
                    return None
            return None

    async def update_session(self, memory: SharedMemory) -> None:
        """Update an existing session in the database."""
        async with get_db_session() as db:
            result = await db.execute(
                select(SessionRecord).where(SessionRecord.session_id == memory.session_id)
            )
            record = result.scalar_one_or_none()

            if record is None:
                logger.warning(f"Session {memory.session_id} not found for update. Creating.")
                await self.create_session(memory)
                return

            record.current_step_index = memory.current_step_index
            record.total_steps = len(memory.steps)
            record.is_complete = memory.is_complete
            record.state_json = memory.model_dump(mode="json")
            record.updated_at = datetime.utcnow()

            # Update gamification
            gam_result = await db.execute(
                select(GamificationRecord).where(
                    GamificationRecord.session_id == memory.session_id
                )
            )
            gam_record = gam_result.scalar_one_or_none()
            if gam_record:
                gam_record.xp_earned = memory.xp_earned
                gam_record.streak_count = memory.streak_count

    async def save_step_progress(
        self,
        session_id: str,
        step_index: int,
        status: str,
        quiz_score: float | None = None,
    ) -> None:
        """Record progress for a specific step."""
        async with get_db_session() as db:
            # Check if progress already exists
            result = await db.execute(
                select(StepProgress).where(
                    StepProgress.session_id == session_id,
                    StepProgress.step_index == step_index,
                )
            )
            record = result.scalar_one_or_none()

            if record:
                record.status = status
                record.quiz_score = quiz_score
                if status == "complete":
                    record.completed_at = datetime.utcnow()
            else:
                record = StepProgress(
                    session_id=session_id,
                    step_index=step_index,
                    status=status,
                    quiz_score=quiz_score,
                    completed_at=datetime.utcnow() if status == "complete" else None,
                )
                db.add(record)

    async def list_sessions(self, limit: int = 20) -> list[dict]:
        """List recent sessions (for debugging/admin)."""
        async with get_db_session() as db:
            result = await db.execute(
                select(SessionRecord)
                .order_by(SessionRecord.created_at.desc())
                .limit(limit)
            )
            records = result.scalars().all()

            return [
                {
                    "session_id": r.session_id,
                    "topic": r.topic,
                    "learning_mode": r.learning_mode,
                    "total_steps": r.total_steps,
                    "current_step": r.current_step_index,
                    "is_complete": r.is_complete,
                    "created_at": r.created_at.isoformat() if r.created_at else None,
                }
                for r in records
            ]
