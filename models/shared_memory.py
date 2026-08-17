"""
EduTechAI — SharedMemory

The central state object shared across all agents in a learning session.
All agents read from and write to this object — there is no direct
agent-to-agent communication. The Orchestrator controls the flow.

Agent Read/Write Map:
    ┌──────────────────────┬───────┬───────┐
    │ Agent                │ Reads │ Writes│
    ├──────────────────────┼───────┼───────┤
    │ Orchestrator         │ SI,CH │ LP    │
    │ Socratic Tutor       │ SI,LP,CH │ SR │
    │ YouTube Curator      │ SI,LP │ SR    │
    │ Academic Researcher  │ SI,LP │ SR    │
    │ Quiz Agent           │ SI,SR │ SR    │
    │ Synthesizer          │ LP,SR,GS │ — (read-only) │
    │ API Layer            │ —     │ SI,CH,GS │
    └──────────────────────┴───────┴───────┘

    SI = Session Info, LP = Learning Plan, SR = Step Results,
    CH = Conversation History, GS = Gamification State
"""

from __future__ import annotations

import uuid
from datetime import datetime

from pydantic import BaseModel, Field

from models.schemas import (
    ConversationTurn,
    LearningMode,
    MilestoneStep,
    StepResult,
    StepStatus,
)


class SharedMemory(BaseModel):
    """
    Central state object shared across all agents in a learning session.
    Each agent reads the sections it needs and writes its output to designated slots.

    This is an in-memory object for a single session. It gets serialized to the
    database (via SessionManager) for persistence and recovery.
    """

    # ─── Session Info (set once by API layer) ───────────────────
    session_id: str = Field(default_factory=lambda: uuid.uuid4().hex[:12])
    user_id: str | None = None
    topic: str = ""
    learning_mode: LearningMode = LearningMode.VISUAL
    student_level: str = "general"
    created_at: datetime = Field(default_factory=datetime.utcnow)

    # ─── Learning Plan (written by Orchestrator) ────────────────
    has_prerequisite_gap: bool = False
    prerequisite_summary: str | None = None
    steps: list[MilestoneStep] = Field(default_factory=list)
    current_step_index: int = 0

    # ─── Per-Step Agent Outputs (written by worker agents) ──────
    step_results: dict[int, StepResult] = Field(default_factory=dict)

    # ─── Conversation History (append-only) ─────────────────────
    conversation_history: list[ConversationTurn] = Field(default_factory=list)

    # ─── Gamification State ─────────────────────────────────────
    xp_earned: int = 0
    steps_completed: int = 0
    quiz_scores: dict[int, float] = Field(default_factory=dict)
    streak_count: int = 0

    # ═══════════════════════════════════════════════════════════════
    # Helper Methods
    # ═══════════════════════════════════════════════════════════════

    @property
    def current_step(self) -> MilestoneStep | None:
        """Get the currently active milestone step."""
        if 0 <= self.current_step_index < len(self.steps):
            return self.steps[self.current_step_index]
        return None

    @property
    def is_complete(self) -> bool:
        """True if all steps have been completed."""
        return (
            len(self.steps) > 0
            and self.current_step_index >= len(self.steps)
        )

    @property
    def total_steps(self) -> int:
        """Total number of steps in the learning plan."""
        return len(self.steps)

    @property
    def progress_percentage(self) -> float:
        """Completion percentage (0.0 to 100.0)."""
        if not self.steps:
            return 0.0
        return (self.steps_completed / len(self.steps)) * 100.0

    def get_step_result(self, step_index: int) -> StepResult:
        """Get or create a StepResult for the given step index."""
        if step_index not in self.step_results:
            self.step_results[step_index] = StepResult(step_index=step_index)
        return self.step_results[step_index]

    def mark_step_complete(self, step_index: int) -> None:
        """Mark a step as complete and advance to the next."""
        if step_index < len(self.steps):
            self.steps[step_index].status = StepStatus.COMPLETE
            result = self.get_step_result(step_index)
            result.status = StepStatus.COMPLETE
            self.steps_completed += 1
            if self.current_step_index == step_index:
                self.current_step_index += 1

    def add_conversation_turn(self, role: str, content: str) -> None:
        """Add a turn to the conversation history."""
        self.conversation_history.append(
            ConversationTurn(role=role, content=content)  # type: ignore[arg-type]
        )

    def get_context_for_step(self, step_index: int) -> dict:
        """
        Build the context dict that agents need for a specific step.
        Used to avoid passing the entire SharedMemory when only a subset is needed.
        """
        step = self.steps[step_index] if step_index < len(self.steps) else None
        return {
            "session_id": self.session_id,
            "topic": self.topic,
            "learning_mode": self.learning_mode.value,
            "student_level": self.student_level,
            "step_index": step_index,
            "step_title": step.title if step else "",
            "step_description": step.description if step else "",
            "is_prerequisite": step.is_prerequisite if step else False,
            "total_steps": self.total_steps,
            "recent_conversation": [
                turn.model_dump() for turn in self.conversation_history[-10:]
            ],
        }
