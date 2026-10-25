"""
EduTechAI — Application Configuration

Reads all settings from .env file. Every model name, API key, and provider URL
is configurable here so you can swap providers without touching code.
"""

import os
from enum import Enum
from pathlib import Path
from typing import Any

from dotenv import load_dotenv
from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

# Load .env variables into os.environ
load_dotenv()






class LLMProvider(str, Enum):
    """Supported LLM inference providers."""

    GROQ = "groq"
    OLLAMA = "ollama"
    OPENAI_COMPATIBLE = "openai_compatible"


class Settings(BaseSettings):
    """
    Central configuration — loaded from .env file.

    To switch LLM providers, just change the .env values:
        LLM_PROVIDER=ollama
        LLM_BASE_URL=http://localhost:11434/v1
        ORCHESTRATOR_MODEL=llama3.1:8b
    """

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # ─── LLM Provider ───────────────────────────────────────────
    llm_provider: LLMProvider = LLMProvider.GROQ
    llm_base_url: str | None = None
    groq_api_key: str = ""
    llm_timeout: float = Field(default=120.0, description="Max timeout in seconds for LLM responses")

    # ─── Model Assignments (per agent) ──────────────────────────
    orchestrator_model: str = ""
    socratic_tutor_model: str = ""
    quiz_agent_model: str = ""

    # ─── YouTube ─────────────────────────────────────────────────
    youtube_api_key: str = ""
    youtube_max_results: int = 5

    @property
    def youtube_daily_search_limit(self) -> int:
        try:
            from services.setting_service import SettingService
            return int(SettingService.get_value("YOUTUBE_DAILY_SEARCH_LIMIT", "100"))
        except Exception:
            return int(os.environ.get("YOUTUBE_DAILY_SEARCH_LIMIT", "100"))

    @property
    def free_youtube_limit(self) -> int:
        try:
            from services.setting_service import SettingService
            return int(SettingService.get_value("FREE_YOUTUBE_LIMIT", "1"))
        except Exception:
            return 1

    @property
    def pro_youtube_limit(self) -> int:
        try:
            from services.setting_service import SettingService
            return int(SettingService.get_value("PRO_YOUTUBE_LIMIT", "3"))
        except Exception:
            return 3

    @property
    def ultra_youtube_limit(self) -> int:
        try:
            from services.setting_service import SettingService
            return int(SettingService.get_value("ULTRA_YOUTUBE_LIMIT", "5"))
        except Exception:
            return 5

    # ─── Socratic Follow-up Limits ───────────────────────────────
    @property
    def free_followup_limit(self) -> int:
        try:
            from services.setting_service import SettingService
            return int(SettingService.get_value("FREE_FOLLOWUP_LIMIT", "1"))
        except Exception:
            return 1

    @property
    def pro_followup_limit(self) -> int:
        try:
            from services.setting_service import SettingService
            return int(SettingService.get_value("PRO_FOLLOWUP_LIMIT", "5"))
        except Exception:
            return 5


    # ─── Academic APIs ───────────────────────────────────────────
    openalex_email: str = ""
    semantic_scholar_api_key: str = ""
    openalex_api_url: str = "https://api.openalex.org/works"
    semantic_scholar_api_url: str = "https://api.semanticscholar.org/graph/v1/paper/search"
    arxiv_api_url: str = "https://export.arxiv.org/api/query"

    # ─── Database ────────────────────────────────────────────────
    database_url: str = "postgresql+asyncpg://postgres:postgres@localhost:5432/edutechai"
    database_schema: str = "edutechAI"
    auto_create_tables: bool = True

    # ─── Vector Store ────────────────────────────────────────────
    chroma_persist_dir: str = "./data/chroma_db"
    chroma_collection_name: str = "youtube_transcripts"

    # ─── Server ──────────────────────────────────────────────────
    host: str = "127.0.0.1"
    port: int = 8000
    debug: bool = True

    # ─── JWT Security & Auth ─────────────────────────────────────
    jwt_secret_key: str = "D5rTsC2QeoxN3LRGPcFR6KJX5Z/SXw/J8JINJ2Kh35c="
    jwt_refresh_secret_key: str = "R7kTsC2QeoxN3LRGPcFR6KJX5Z/SXw/J8JINJ2Kh35c="
    jwt_algorithm: str = "HS256"
    jwt_access_expire_minutes: int = 15
    jwt_refresh_expire_days: int = 7

    # ─── Rate Limiting ───────────────────────────────────────────
    groq_max_retries: int = Field(default=3, description="Max retries on Groq rate limit")
    groq_retry_delay: float = Field(default=1.0, description="Base delay between retries (seconds)")

    @field_validator("database_url")
    @classmethod
    def normalize_database_url(cls, v: str) -> str:
        """Ensure async driver (asyncpg) is used for PostgreSQL connections."""
        if v.startswith("postgres://"):
            return "postgresql+asyncpg://" + v[len("postgres://"):]
        if v.startswith("postgresql://"):
            return "postgresql+asyncpg://" + v[len("postgresql://"):]
        return v

    @field_validator("groq_api_key")
    @classmethod
    def validate_groq_key(cls, v: str, info) -> str:
        """Warn if Groq key is missing when provider is Groq."""
        # We don't raise here — key might be set later or provider might change
        return v

    @property
    def data_dir(self) -> Path:
        """Ensure data directory exists and return its path."""
        path = Path("./data")
        path.mkdir(parents=True, exist_ok=True)
        return path

    def get_model_for_agent(self, agent_name: str) -> str:
        """Get the configured model name for a specific agent from SettingService or .env only."""
        try:
            from services.setting_service import SettingService
            model = SettingService.get_agent_model(agent_name)
            if model:
                return model
        except Exception:
            pass

        # Fallback strictly to .env setting
        mapping = {
            "orchestrator": self.orchestrator_model or os.environ.get("ORCHESTRATOR_MODEL", ""),
            "socratic_tutor": self.socratic_tutor_model or os.environ.get("SOCRATIC_TUTOR_MODEL", ""),
            "quiz_agent": self.quiz_agent_model or os.environ.get("QUIZ_AGENT_MODEL", ""),
        }
        return mapping.get(agent_name, "")



# ─── Singleton ───────────────────────────────────────────────────
_settings: Settings | None = None


def get_settings() -> Settings:
    """Get or create the global settings instance."""
    global _settings
    if _settings is None:
        _settings = Settings()
    return _settings
