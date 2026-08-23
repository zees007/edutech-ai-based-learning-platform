"""
EduTechAI — Academic Resource Agent

Searches open-access academic repositories for landmark papers, articles, and textbooks
relevant to the learning session.

Searches across three free APIs in parallel:
- OpenAlex API — Broad multidisciplinary coverage & citation metrics
- Semantic Scholar API — AI-enhanced with TLDR summaries
- arXiv API — Preprints in STEM fields

Architecture:
- Curated ONCE per session (Topic-level landmark research)
- Zero-latency retrieval across steps
- Gated: automatically skipped for middle/high school & bite-sized mode

Reads: memory.topic, memory.learning_mode, memory.student_level
Writes: memory.academic_papers[], memory.step_results[step_index].academic_papers[]
"""

from __future__ import annotations

import logging
from typing import Any

from agents.base import BaseAgent
from models.schemas import AcademicPaper, LearningMode
from models.shared_memory import SharedMemory

logger = logging.getLogger(__name__)


class AcademicResearcherAgent(BaseAgent):
    """
    Academic Resource agent.

    Searches multiple scholarly sources in parallel once per session and returns
    ranked, deduplicated landmark papers for the overarching topic.
    """

    async def curate_papers_for_session(
        self,
        topic: str = "",
        student_level: str = "general",
        learning_mode: Any = "visual",
        max_results: int = 3,
    ) -> list[AcademicPaper]:
        """
        Search landmark academic papers once for the entire topic session.

        Applies educational level & mode gating:
        - Skips for middle_school and high_school to avoid cognitive overload.
        - Skips for bite_sized mode to maintain rapid scan experience.
        - Fetches top 3-4 papers for undergraduate, graduate, and general in visual/deep_dive modes.
        """
        mode_val = learning_mode.value if hasattr(learning_mode, "value") else str(learning_mode)

        # Gating 1: Skip for younger students
        if student_level.lower() in ["middle_school", "high_school"]:
            self.logger.info(f"Skipping academic paper search for student_level: '{student_level}'")
            return []

        # Gating 2: Skip for bite-sized mode
        if mode_val == "bite_sized":
            self.logger.info("Bite-Sized mode — skipping academic search.")
            return []

        if not topic or not topic.strip():
            return []

        clean_topic = topic.strip()
        self.logger.info(f"Curating session landmark papers for topic: '{clean_topic}' (level={student_level}, mode={mode_val})")

        try:
            from services.academic_client import AcademicClient
            client = AcademicClient()

            # For deep dive, fetch up to 4 papers; otherwise 3
            limit = 4 if mode_val == "deep_dive" else max_results

            papers = await client.search_all(clean_topic, max_results=limit)
            self.logger.info(f"Curated {len(papers)} landmark papers for session '{clean_topic}'")
            return papers or []
        except ImportError:
            self.logger.warning("AcademicClient not available — skipping paper search.")
            return []
        except Exception as e:
            self.logger.error(f"Session academic paper curation failed: {e}")
            return []

    async def curate_papers(
        self,
        step: Any = None,
        topic: str = "",
        student_level: str = "general",
        learning_mode: Any = "visual",
    ) -> list[AcademicPaper]:
        """
        Convenience method to retrieve academic papers.
        If step already contains papers, returns them; otherwise curates for the session topic.
        """
        existing_papers = getattr(step, "papers", None) if step else None
        if existing_papers and isinstance(existing_papers, list):
            return existing_papers

        return await self.curate_papers_for_session(
            topic=topic,
            student_level=student_level,
            learning_mode=learning_mode,
        )

    async def execute(self, memory: SharedMemory, step_index: int | None = None) -> None:
        """
        Find relevant academic papers for the session and link to the given step.
        """
        if step_index is None:
            step_index = memory.current_step_index

        # If session already has cached papers, just assign to step result
        if memory.academic_papers:
            if step_index < len(memory.steps):
                step_result = memory.get_step_result(step_index)
                step_result.academic_papers = memory.academic_papers
            return

        # Check gating before calling APIs
        if memory.student_level.lower() in ["middle_school", "high_school"] or memory.learning_mode == LearningMode.BITE_SIZED:
            self.logger.info(f"Skipping academic search (level={memory.student_level}, mode={memory.learning_mode})")
            return

        # Fetch once at session level
        papers = await self.curate_papers_for_session(
            topic=memory.topic,
            student_level=memory.student_level,
            learning_mode=memory.learning_mode,
        )

        memory.academic_papers = papers

        if step_index < len(memory.steps):
            step_result = memory.get_step_result(step_index)
            step_result.academic_papers = papers
