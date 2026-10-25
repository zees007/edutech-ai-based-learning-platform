"""
EduTechAI — Dynamic System Setting Service

Provides thread-safe in-memory caching and persistent DB operations for system settings,
including agent LLM models, subscription prices, and promotional coupons.
"""

from __future__ import annotations

import logging
import os
from typing import Any, Dict, List, Optional

from dotenv import load_dotenv

# Ensure .env is loaded into os.environ
load_dotenv()


from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.exceptions import NotFoundException
from models.db_models import SystemSetting

logger = logging.getLogger(__name__)

# Default system settings fallback definitions
DEFAULT_SYSTEM_SETTINGS: Dict[str, str] = {
    "ORCHESTRATOR_MODEL": os.environ.get("ORCHESTRATOR_MODEL", ""),
    "SOCRATIC_TUTOR_MODEL": os.environ.get("SOCRATIC_TUTOR_MODEL", ""),
    "QUIZ_AGENT_MODEL": os.environ.get("QUIZ_AGENT_MODEL", ""),
    "PRO_MONTHLY": "19",
    "PRO_ANNUALLY": "180",
    "ULTRA_MONTHLY": "49",
    "ULTRA_ANNUALLY": "470",
    "VALID_COUPONS": "EDU20:20,WELCOME50:50,STUDENT10:10,EDUTECH100:100",
    "YOUTUBE_DAILY_SEARCH_LIMIT": "100",
    "FREE_YOUTUBE_LIMIT": "1",
    "PRO_YOUTUBE_LIMIT": "3",
    "ULTRA_YOUTUBE_LIMIT": "5",
    "FREE_FOLLOWUP_LIMIT": "1",
    "PRO_FOLLOWUP_LIMIT": "5",
}


class SettingService:
    """
    Service layer for system configurations with in-memory caching.
    """

    # In-memory dictionary cache for zero-latency lookups
    _cache: Dict[str, str] = dict(DEFAULT_SYSTEM_SETTINGS)
    _is_synced: bool = False

    @classmethod
    def get_value(cls, code: str, default: Optional[str] = None) -> str:
        """
        Fast synchronous lookup for a setting value from the in-memory cache.
        Falls back to os.environ (.env), default parameter, or DEFAULT_SYSTEM_SETTINGS.
        """
        code_clean = code.strip().upper()
        if code_clean in cls._cache and cls._cache[code_clean]:
            return cls._cache[code_clean]
        env_val = os.environ.get(code_clean)
        if env_val:
            return env_val
        if default is not None:
            return default
        return DEFAULT_SYSTEM_SETTINGS.get(code_clean, "")

    @classmethod
    def get_int(cls, code: str, default: int = 0) -> int:
        """Helper to get integer setting value from cache with fallback."""
        val = cls.get_value(code, str(default))
        try:
            return int(val)
        except (ValueError, TypeError):
            return default

    @classmethod
    def get_float(cls, code: str, default: float = 0.0) -> float:
        """Helper to get float setting value from cache with fallback."""
        val = cls.get_value(code, str(default))
        try:
            return float(val)
        except (ValueError, TypeError):
            return default




    @classmethod
    async def sync_cache_from_db(cls, db: AsyncSession) -> Dict[str, str]:
        """
        Fetch all settings from the database and synchronize the in-memory cache.
        """
        try:
            stmt = select(SystemSetting).order_by(SystemSetting.order_number.asc())
            result = await db.execute(stmt)
            settings = result.scalars().all()
            for s in settings:
                cls._cache[s.code.strip().upper()] = s.value
            cls._is_synced = True
            logger.info(f"[SettingService] Synchronized {len(settings)} settings into cache.")
        except Exception as e:
            logger.warning(f"[SettingService] Could not sync settings from DB (using defaults): {e}")
        return dict(cls._cache)

    @classmethod
    async def get_all_settings(cls, db: AsyncSession) -> List[SystemSetting]:
        """
        Retrieve all settings from the database ordered by order_number ascending.
        Synchronizes cache in the process.
        """
        stmt = select(SystemSetting).order_by(SystemSetting.order_number.asc(), SystemSetting.id.asc())
        result = await db.execute(stmt)
        settings = list(result.scalars().all())

        # Update cache
        for s in settings:
            cls._cache[s.code.strip().upper()] = s.value

        return settings

    @classmethod
    async def get_setting_by_code(cls, db: AsyncSession, code: str) -> SystemSetting:
        """
        Retrieve a single setting by its code. Raises NotFoundException if not found.
        """
        code_clean = code.strip().upper()
        stmt = select(SystemSetting).where(SystemSetting.code == code_clean)
        result = await db.execute(stmt)
        setting = result.scalar_one_or_none()
        if not setting:
            raise NotFoundException(
                error_code="SETTING_NOT_FOUND",
                errors=f"System setting with code '{code_clean}' not found.",
            )
        cls._cache[setting.code] = setting.value
        return setting

    @classmethod
    async def update_setting(
        cls,
        db: AsyncSession,
        code: str,
        value: str,
        order_number: Optional[int] = None,
    ) -> SystemSetting:
        """
        Update an existing setting or create it if missing, and immediately update the cache.
        """
        code_clean = code.strip().upper()
        stmt = select(SystemSetting).where(SystemSetting.code == code_clean)
        result = await db.execute(stmt)
        setting = result.scalar_one_or_none()

        if setting:
            setting.value = str(value)
            if order_number is not None:
                setting.order_number = order_number
        else:
            setting = SystemSetting(
                code=code_clean,
                value=str(value),
                order_number=order_number or 0,
            )
            db.add(setting)

        await db.commit()
        await db.refresh(setting)

        # Invalidate/update cache immediately
        cls._cache[code_clean] = setting.value
        logger.info(f"[SettingService] Updated setting '{code_clean}' = '{value}'")
        return setting

    # ─── Domain-Specific Helpers ─────────────────────────────────────

    @classmethod
    def get_agent_model(cls, agent_name: str) -> str:
        """
        Resolves the LLM model name for a specific agent.
        Picks from DB settings first, falling back strictly to .env setting.
        """
        name_clean = agent_name.strip().lower()
        mapping = {
            "orchestrator": "ORCHESTRATOR_MODEL",
            "socratic_tutor": "SOCRATIC_TUTOR_MODEL",
            "quiz_agent": "QUIZ_AGENT_MODEL",
        }
        code = mapping.get(name_clean, "ORCHESTRATOR_MODEL")
        if code in cls._cache and cls._cache[code]:
            return cls._cache[code]
        return os.environ.get(code, "")


    @classmethod
    def get_pricing_catalog(cls) -> Dict[str, Dict[str, float]]:
        """
        Returns the parsed pricing catalog with dynamic values for Pro and Ultra tiers.
        """
        try:
            pro_m = float(cls.get_value("PRO_MONTHLY", "19"))
        except (ValueError, TypeError):
            pro_m = 19.0

        try:
            pro_a = float(cls.get_value("PRO_ANNUALLY", "180"))
        except (ValueError, TypeError):
            pro_a = 180.0

        try:
            ultra_m = float(cls.get_value("ULTRA_MONTHLY", "49"))
        except (ValueError, TypeError):
            ultra_m = 49.0

        try:
            ultra_a = float(cls.get_value("ULTRA_ANNUALLY", "470"))
        except (ValueError, TypeError):
            ultra_a = 470.0

        return {
            "free": {"monthly": 0.0, "annual": 0.0},
            "pro": {"monthly": pro_m, "annual": pro_a},
            "ultra": {"monthly": ultra_m, "annual": ultra_a},
        }

    @classmethod
    def get_valid_coupons(cls) -> Dict[str, float]:
        """
        Parses the comma-separated VALID_COUPONS string (e.g. 'EDU20:20,WELCOME50:50')
        into a dictionary { code: discount_percentage }.
        """
        coupons_str = cls.get_value(
            "VALID_COUPONS",
            default="EDU20:20,WELCOME50:50,STUDENT10:10,EDUTECH100:100",
        )
        coupons_map: Dict[str, float] = {}
        for token in coupons_str.split(","):
            token = token.strip()
            if not token:
                continue
            # Supports delimiter ':' or '='
            if ":" in token:
                parts = token.split(":", 1)
            elif "=" in token:
                parts = token.split("=", 1)
            else:
                continue

            c_code = parts[0].strip().upper()
            try:
                c_pct = float(parts[1].strip())
                if c_code:
                    coupons_map[c_code] = c_pct
            except ValueError:
                continue

        # If empty or malformed, provide standard fallback
        if not coupons_map:
            coupons_map = {
                "EDU20": 20.0,
                "WELCOME50": 50.0,
                "STUDENT10": 10.0,
                "EDUTECH100": 100.0,
            }
        return coupons_map
