"""
EduTechAI — Orchestrator Agent (Supervisor)

The brain of the multi-agent system. Decomposes a student's topic into
a structured, progressive sequence of milestone steps and detects
prerequisite gaps.

Reads: memory.topic, memory.learning_mode, memory.student_level, memory.conversation_history
Writes: memory.steps[], memory.has_prerequisite_gap, memory.prerequisite_summary
Model: config.ORCHESTRATOR_MODEL
"""

from __future__ import annotations

import json

from agents.base import BaseAgent
from models.schemas import MilestoneStep, StepStatus
from models.shared_memory import SharedMemory


class OrchestratorAgent(BaseAgent):
    """
    Supervisor agent that plans the learning journey.

    Takes a topic and produces a list of milestone steps, adapting for:
    - Student level (middle_school → graduate)
    - Learning mode (visual, deep_dive, bite_sized)
    - Prerequisite gaps (auto-detects and prepends warmup steps)
    """

    async def execute(self, memory: SharedMemory, step_index: int | None = None) -> None:
        """
        Decompose the topic into milestone steps and write them to SharedMemory.
        """
        self.logger.info(f"Planning learning journey for: '{memory.topic}'")

        # Load and format the prompt template
        template = self._load_prompt_template("orchestrator")
        system_prompt = self._format_prompt(
            template,
            topic=memory.topic,
            student_level=memory.student_level,
            learning_mode=memory.learning_mode.value,
        )

        # Build the message list
        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": f"Create a learning plan for: {memory.topic}"},
        ]

        # Add recent conversation context if available
        if memory.conversation_history:
            context_msg = "Previous conversation context:\n"
            for turn in memory.conversation_history[-5:]:
                context_msg += f"- {turn.role}: {turn.content}\n"
            messages.insert(1, {"role": "user", "content": context_msg})

        # Call LLM with JSON response format
        model = self.settings.get_model_for_agent("orchestrator")
        try:
            result = await self.llm.chat_json(
                model=model,
                messages=messages,
                temperature=0.1,  # Ultra-low temp for strict structured planning
                max_tokens=2048,
            )
        except Exception as e:
            self.logger.error(f"Orchestrator LLM call failed: {e}")
            # Fallback: create a single generic step
            memory.steps = [
                MilestoneStep(
                    index=0,
                    title=f"Understanding {memory.topic}",
                    description=f"A comprehensive overview of {memory.topic}.",
                    is_prerequisite=False,
                    estimated_minutes=10,
                )
            ]
            return

        # Parse the response into SharedMemory
        self._parse_plan(memory, result)

        self.logger.info(
            f"Plan created: {len(memory.steps)} steps, "
            f"prerequisite_gap={memory.has_prerequisite_gap}"
        )

    def _parse_plan(self, memory: SharedMemory, result: dict) -> None:
        """Parse the LLM's JSON response into SharedMemory fields."""
        # Prerequisite detection
        memory.has_prerequisite_gap = result.get("has_prerequisite_gap", False)
        memory.prerequisite_summary = result.get("prerequisite_summary")

        # Parse steps
        raw_steps = result.get("steps", [])
        if not raw_steps:
            self.logger.warning("Orchestrator returned empty steps. Using fallback.")
            memory.steps = [
                MilestoneStep(
                    index=0,
                    title=f"Exploring {memory.topic}",
                    description=f"Let's explore the fundamentals of {memory.topic}.",
                    estimated_minutes=10,
                )
            ]
            return

        steps = []
        for i, raw_step in enumerate(raw_steps):
            try:
                step = MilestoneStep(
                    index=i,
                    title=raw_step.get("title", f"Step {i + 1}"),
                    description=raw_step.get("description", ""),
                    is_prerequisite=raw_step.get("is_prerequisite", False),
                    estimated_minutes=raw_step.get("estimated_minutes", 5),
                    status=StepStatus.PENDING,
                )
                steps.append(step)
            except Exception as e:
                self.logger.warning(f"Failed to parse step {i}: {e}")
                continue

        memory.steps = steps
        memory.current_step_index = 0
