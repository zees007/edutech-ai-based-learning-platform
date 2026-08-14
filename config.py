"""
EduTechAI — Application Configuration

Reads all settings from .env file. Every model name, API key, and provider URL
is configurable here so you can swap providers without touching code.
"""

from enum import Enum
from pathlib import Path

from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


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

    # ─── Model Assignments (per agent) ──────────────────────────
    orchestrator_model: str = "llama-3.1-8b-instant"
    socratic_tutor_model: str = "llama-3.1-8b-instant"
    quiz_agent_model: str = "llama-3.1-8b-instant"

    # ─── YouTube ─────────────────────────────────────────────────
    youtube_api_key: str = ""
    youtube_max_results: int = 5
    youtube_daily_search_limit: int = 100

    # ─── Academic APIs ───────────────────────────────────────────
    openalex_email: str = ""
    semantic_scholar_api_key: str = ""

    # ─── Database ────────────────────────────────────────────────
    database_url: str = "sqlite+aiosqlite:///./data/edutechai.db"
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
    jwt_algorithm: str = "HS256"
    jwt_expire_minutes: int = 60

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
        """Get the configured model name for a specific agent."""
        model_map = {
            "orchestrator": self.orchestrator_model,
            "socratic_tutor": self.socratic_tutor_model,
            "quiz_agent": self.quiz_agent_model,
        }
        return model_map.get(agent_name, self.orchestrator_model)


# ─── Singleton ───────────────────────────────────────────────────
_settings: Settings | None = None


def get_settings() -> Settings:
    """Get or create the global settings instance."""
    global _settings
    if _settings is None:
        _settings = Settings()
    return _settings
