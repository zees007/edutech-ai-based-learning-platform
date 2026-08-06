"""
EduTechAI — Synthesizer Agent

Read-only agent that assembles outputs from all worker agents into structured
WebSocket events for the client. Does NOT write to SharedMemory.

Reads: memory.step_results[step_index], memory.steps, memory.xp_earned
Writes: Nothing — streams events to the WebSocket instead
"""

from __future__ import annotations

from datetime import datetime

from agents.base import BaseAgent
from models.schemas import (
    AcademicPaperEvent,
    ExplanationChunkEvent,
    PlanEvent,
    QuizEvent,
    SocraticQuestionsEvent,
    StepCompleteEvent,
    WSEvent,
    YouTubeClipEvent,
)
from models.shared_memory import SharedMemory


class SynthesizerAgent(BaseAgent):
    """
    Output assembly agent.

    Collects agent outputs from SharedMemory and converts them into
    structured WebSocket events. This agent is read-only — it never
    writes to SharedMemory.
    """

    async def execute(self, memory: SharedMemory, step_index: int | None = None) -> None:
        """
        Not used directly — the Synthesizer works through event generation methods.
        Use synthesize_step() or create_plan_event() instead.
        """
        pass

    def create_plan_event(self, memory: SharedMemory) -> PlanEvent:
        """Create a WebSocket event announcing the learning plan."""
        return PlanEvent(
            session_id=memory.session_id,
            steps=memory.steps,
            has_prerequisite_gap=memory.has_prerequisite_gap,
            prerequisite_summary=memory.prerequisite_summary,
        )

    def create_explanation_chunk_event(
        self,
        memory: SharedMemory,
        step_index: int,
        content: str,
        is_final: bool = False,
    ) -> ExplanationChunkEvent:
        """Create a WebSocket event for a streamed explanation chunk."""
        return ExplanationChunkEvent(
            session_id=memory.session_id,
            step_index=step_index,
            content=content,
            is_final=is_final,
        )

    def create_socratic_questions_event(
        self,
        memory: SharedMemory,
        step_index: int,
    ) -> SocraticQuestionsEvent | None:
        """Create a WebSocket event for Socratic questions (after explanation)."""
        step_result = memory.step_results.get(step_index)
        if not step_result or not step_result.socratic_questions:
            return None
        return SocraticQuestionsEvent(
            session_id=memory.session_id,
            step_index=step_index,
            questions=step_result.socratic_questions,
        )

    def create_youtube_clip_events(
        self,
        memory: SharedMemory,
        step_index: int,
    ) -> list[YouTubeClipEvent]:
        """Create WebSocket events for YouTube clips found for a step."""
        step_result = memory.step_results.get(step_index)
        if not step_result:
            return []
        return [
            YouTubeClipEvent(
                session_id=memory.session_id,
                step_index=step_index,
                clip=clip,
            )
            for clip in step_result.youtube_clips
        ]

    def create_academic_paper_events(
        self,
        memory: SharedMemory,
        step_index: int,
    ) -> list[AcademicPaperEvent]:
        """Create WebSocket events for academic papers found for a step."""
        step_result = memory.step_results.get(step_index)
        if not step_result:
            return []
        return [
            AcademicPaperEvent(
                session_id=memory.session_id,
                step_index=step_index,
                paper=paper,
            )
            for paper in step_result.academic_papers
        ]

    def create_quiz_event(
        self,
        memory: SharedMemory,
        step_index: int,
    ) -> QuizEvent | None:
        """Create a WebSocket event for the quiz (after all agents finish)."""
        step_result = memory.step_results.get(step_index)
        if not step_result or not step_result.quiz:
            return None
        return QuizEvent(
            session_id=memory.session_id,
            step_index=step_index,
            quiz=step_result.quiz,
        )

    def create_step_complete_event(
        self,
        memory: SharedMemory,
        step_index: int,
    ) -> StepCompleteEvent:
        """Create a WebSocket event indicating step completion."""
        return StepCompleteEvent(
            session_id=memory.session_id,
            step_index=step_index,
        )

    def synthesize_step_events(
        self,
        memory: SharedMemory,
        step_index: int,
    ) -> list[WSEvent]:
        """
        Collect all available events for a completed step.

        Returns events in the order they should be sent to the client:
        1. YouTube clips (show media first)
        2. Academic papers
        3. Socratic questions (after explanation — but explanation was streamed separately)
        4. Quiz
        5. Step complete
        """
        events: list[WSEvent] = []

        # YouTube clips
        events.extend(self.create_youtube_clip_events(memory, step_index))

        # Academic papers
        events.extend(self.create_academic_paper_events(memory, step_index))

        # Socratic questions
        sq_event = self.create_socratic_questions_event(memory, step_index)
        if sq_event:
            events.append(sq_event)

        # Quiz
        quiz_event = self.create_quiz_event(memory, step_index)
        if quiz_event:
            events.append(quiz_event)

        # Step complete
        events.append(self.create_step_complete_event(memory, step_index))

        return events
