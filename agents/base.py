"""
EduTechAI — Base Agent

Abstract base class for all agents in the multi-agent system.
All agents read from and write to SharedMemory — there is no
direct agent-to-agent communication.
"""

from __future__ import annotations

import logging
from abc import ABC, abstractmethod
from pathlib import Path

from config import Settings, get_settings
from services.llm_client import LLMClient, get_llm_client


class BaseAgent(ABC):
    """
    Base class for all EduTechAI agents.

    Agents follow a simple contract:
    1. Receive a reference to SharedMemory
    2. Read the sections they need
    3. Write their outputs to the designated slots
    4. No return value — all output goes into SharedMemory
    """

    def __init__(
        self,
        llm_client: LLMClient | None = None,
        settings: Settings | None = None,
    ):
        self.llm = llm_client or get_llm_client()
        self.settings = settings or get_settings()
        self.logger = logging.getLogger(self.__class__.__name__)

    @property
    def agent_name(self) -> str:
        """Human-readable agent name for logging."""
        return self.__class__.__name__

    @abstractmethod
    async def execute(self, memory, step_index: int | None = None) -> None:
        """
        Execute the agent's task.

        Args:
            memory: SharedMemory — the shared state object.
            step_index: Optional step index for step-specific agents.

        All output should be written directly to `memory`.
        """
        ...

    def _load_prompt_template(self, template_name: str) -> str:
        """
        Load a prompt template from the prompts/ directory.

        Args:
            template_name: Name of the .md file (without extension).

        Returns:
            The template string with {placeholders} for formatting.
        """
        prompt_path = Path("prompts") / f"{template_name}.md"
        if not prompt_path.exists():
            self.logger.warning(f"Prompt template not found: {prompt_path}")
            return ""
        return prompt_path.read_text(encoding="utf-8")

    def _format_prompt(self, template: str, **kwargs) -> str:
        """
        Format a prompt template with the given variables.
        Handles missing keys gracefully.
        """
        try:
            return template.format(**kwargs)
        except KeyError as e:
            self.logger.warning(f"Missing prompt variable: {e}")
            # Fill missing keys with placeholder
            for key in kwargs:
                template = template.replace(f"{{{key}}}", str(kwargs[key]))
            return template
