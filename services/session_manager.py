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

from sqlalchemy import delete, func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from models.db_models import GamificationRecord, SessionRecord, StepProgress
from models.shared_memory import SharedMemory
from models.user_schemas import SearchDTO
from services.database import get_db_session

logger = logging.getLogger(__name__)


class SessionManager:
    """
    Session CRUD operations via SQLAlchemy ORM.

    The full SharedMemory state is serialized to JSON and stored in the
    `state_json` column, enabling complete session recovery on reconnect.
    """

    async def create_session(
        self, memory: SharedMemory, user_id: str | None = None
    ) -> SessionRecord:
        """Persist a new learning session to the database associated with a user."""
        effective_user_id = user_id or getattr(memory, "user_id", None)
        if not effective_user_id:
            raise ValueError("user_id is required to create a learning session.")

        async with get_db_session() as db:
            record = SessionRecord(
                session_id=memory.session_id,
                user_id=effective_user_id,
                topic=memory.topic,
                learning_mode=(
                    memory.learning_mode.value
                    if hasattr(memory.learning_mode, "value")
                    else str(memory.learning_mode)
                ),
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

            # Create initial step_progress records for all steps in the learning plan
            for i in range(len(memory.steps)):
                sp = StepProgress(
                    session_id=memory.session_id,
                    step_index=i,
                    status="in_progress" if i == 0 else "pending",
                    completed_at=None,
                    quiz_score=None,
                )
                db.add(sp)

            await db.commit()
            logger.info(
                f"Session {memory.session_id} (user={effective_user_id}) and {len(memory.steps)} step progress records persisted to database."
            )
            return record

    async def get_monthly_session_count(self, user_id: str) -> int:
        """Count how many sessions the user created in the current calendar month."""
        now = datetime.utcnow()
        start_of_month = datetime(now.year, now.month, 1)
        async with get_db_session() as db:
            query = select(func.count(SessionRecord.id)).where(
                SessionRecord.user_id == user_id,
                SessionRecord.created_at >= start_of_month
            )
            res = await db.execute(query)
            return res.scalar_one() or 0

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
                    memory = SharedMemory.model_validate(record.state_json)
                    # Ensure user_id and latest status are synchronized
                    if not memory.user_id:
                        memory.user_id = record.user_id
                    return memory
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

            if memory.user_id and not record.user_id:
                record.user_id = memory.user_id

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
                from services.gamification import calculate_level

                gam_record.xp_earned = memory.xp_earned
                gam_record.streak_count = memory.streak_count
                level_info = calculate_level(memory.xp_earned)
                gam_record.level = level_info["level"]
                gam_record.level_title = level_info["title"]

            # Synchronize step_progress records for all steps in memory
            for i, step in enumerate(memory.steps):
                sp_result = await db.execute(
                    select(StepProgress).where(
                        StepProgress.session_id == memory.session_id,
                        StepProgress.step_index == i,
                    )
                )
                sp_record = sp_result.scalar_one_or_none()
                score = memory.quiz_scores.get(i)
                status_val = step.status.value if hasattr(step.status, "value") else str(step.status)

                if sp_record:
                    sp_record.status = status_val
                    if score is not None:
                        sp_record.quiz_score = score
                    if status_val == "complete" and not sp_record.completed_at:
                        sp_record.completed_at = datetime.utcnow()
                else:
                    sp_record = StepProgress(
                        session_id=memory.session_id,
                        step_index=i,
                        status=status_val,
                        quiz_score=score,
                        completed_at=datetime.utcnow() if status_val == "complete" else None,
                    )
                    db.add(sp_record)

    async def search_user_sessions(
        self,
        user_id: str,
        dto: SearchDTO,
        status_filter: str = "all",
    ) -> tuple[list[dict], int]:
        """
        Search and paginate learning sessions belonging to a specific user.

        Sorting Rules:
          1. Incomplete sessions (is_complete=False) are sorted on top.
          2. Completed sessions (is_complete=True) follow.
          3. Within each group, ordered by updated_at descending.

        Pagination:
          0-indexed page (offset = dto.page * dto.size, limit = dto.size).
        """
        async with get_db_session() as db:
            query = select(SessionRecord).where(SessionRecord.user_id == user_id)

            # Apply Status Filter
            if status_filter == "in_progress":
                query = query.where(SessionRecord.is_complete == False)
            elif status_filter == "completed":
                query = query.where(SessionRecord.is_complete == True)

            # Apply Multi-Field Lookup Search
            lookup = dto.lookupText
            if lookup and lookup.strip():
                term = f"%{lookup.strip()}%"
                query = query.where(
                    or_(
                        SessionRecord.topic.ilike(term),
                        SessionRecord.learning_mode.ilike(term),
                        SessionRecord.student_level.ilike(term),
                    )
                )

            # Count total matching records before pagination
            count_query = select(func.count()).select_from(query.subquery())
            total_res = await db.execute(count_query)
            total = total_res.scalar_one() or 0

            # Strict Sorting: Incomplete first (is_complete=False -> 0, True -> 1), then updated_at DESC
            query = query.order_by(
                SessionRecord.is_complete.asc(),
                SessionRecord.updated_at.desc(),
            )

            # 0-indexed pagination
            offset = dto.page * dto.size
            query = query.offset(offset).limit(dto.size)

            res = await db.execute(query)
            records = list(res.scalars().all())

            items = []
            for r in records:
                # Calculate completed steps count from state_json if available
                completed_count = 0
                xp = 0
                if r.state_json:
                    steps = r.state_json.get("steps", [])
                    completed_count = sum(1 for s in steps if s.get("status") == "complete")
                    xp = r.state_json.get("xp_earned", 0)

                items.append(
                    {
                        "session_id": r.session_id,
                        "user_id": r.user_id,
                        "topic": r.topic,
                        "learning_mode": r.learning_mode,
                        "student_level": r.student_level,
                        "total_steps": r.total_steps,
                        "current_step_index": r.current_step_index,
                        "completed_steps": completed_count,
                        "is_complete": r.is_complete,
                        "xp_earned": xp,
                        "created_at": r.created_at.isoformat() if r.created_at else None,
                        "updated_at": r.updated_at.isoformat() if r.updated_at else None,
                    }
                )

            return items, total

    async def delete_session(self, session_id: str, user_id: str | None = None) -> bool:
        """
        Delete a session and all its associated progress and gamification records.
        If user_id is provided, guarantees ownership before deletion.
        """
        async with get_db_session() as db:
            query = select(SessionRecord).where(SessionRecord.session_id == session_id)
            if user_id:
                query = query.where(SessionRecord.user_id == user_id)

            res = await db.execute(query)
            record = res.scalar_one_or_none()
            if not record:
                return False

            # Delete related step progress and gamification
            await db.execute(
                delete(StepProgress).where(StepProgress.session_id == session_id)
            )
            await db.execute(
                delete(GamificationRecord).where(GamificationRecord.session_id == session_id)
            )
            await db.delete(record)
            logger.info(f"Session {session_id} successfully deleted.")
            return True

    async def save_step_progress(
        self,
        session_id: str,
        step_index: int,
        status: str,
        quiz_score: float | None = None,
    ) -> None:
        """Record progress for a specific step."""
        async with get_db_session() as db:
            result = await db.execute(
                select(StepProgress).where(
                    StepProgress.session_id == session_id,
                    StepProgress.step_index == step_index,
                )
            )
            record = result.scalar_one_or_none()

            if record:
                record.status = status
                if quiz_score is not None:
                    record.quiz_score = quiz_score
                if status == "complete" and not record.completed_at:
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
                    "user_id": r.user_id,
                    "topic": r.topic,
                    "learning_mode": r.learning_mode,
                    "total_steps": r.total_steps,
                    "current_step": r.current_step_index,
                    "is_complete": r.is_complete,
                    "created_at": r.created_at.isoformat() if r.created_at else None,
                }
                for r in records
            ]
