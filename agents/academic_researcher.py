"""
EduTechAI — Academic Resource Agent

Searches open-access academic repositories for papers, articles, and textbooks
relevant to the current learning step.

Searches across three free APIs in parallel:
- OpenAlex API — Broad multidisciplinary coverage
- Semantic Scholar API — AI-enhanced with TLDR summaries
- arXiv API — Preprints in STEM fields

Reads: memory.steps[step_index], memory.learning_mode
Writes: memory.step_results[step_index].academic_papers[]
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

    Searches multiple scholarly sources in parallel and returns
    ranked, deduplicated papers for the current step.
    """

    async def curate_papers(self, step: Any, topic: str = "") -> list[AcademicPaper]:
        """Convenience method to search academic papers for a step."""
        try:
            from services.academic_client import AcademicClient
            client = AcademicClient()
            title = getattr(step, "title", str(step))
            query = f"{topic} {title}".strip()
            papers = await client.search_all(query, max_results=3)
            return papers or []
        except Exception as e:
            self.logger.error(f"Academic paper search failed: {e}")
            return []

    async def execute(self, memory: SharedMemory, step_index: int | None = None) -> None:
        """Find relevant academic papers for the given step."""
        if step_index is None:
            step_index = memory.current_step_index

        step = memory.steps[step_index] if step_index < len(memory.steps) else None
        if step is None:
            return

        # Mode adaptation: skip in bite_sized, minimal in visual
        if memory.learning_mode == LearningMode.BITE_SIZED:
            self.logger.info("Bite-Sized mode — skipping academic search.")
            return

        self.logger.info(f"Searching academic sources for step {step_index}: '{step.title}'")

        step_result = memory.get_step_result(step_index)

        try:
            from services.academic_client import AcademicClient
            client = AcademicClient()

            # Search query
            query = f"{memory.topic} {step.title}"

            # Set max results based on mode
            max_results = 3 if memory.learning_mode == LearningMode.DEEP_DIVE else 2

            # Search across all sources in parallel
            papers = await client.search_all(query, max_results=max_results)

            step_result.academic_papers = papers
            self.logger.info(f"Found {len(papers)} papers for step {step_index}")

        except ImportError:
            self.logger.warning("AcademicClient not available — skipping paper search.")
        except Exception as e:
            self.logger.error(f"Academic search failed: {e}")
