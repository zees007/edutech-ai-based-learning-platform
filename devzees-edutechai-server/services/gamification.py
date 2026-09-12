"""
EduTechAI — Gamification Service

XP calculation, leveling, and streak tracking.
"""

from __future__ import annotations

from datetime import datetime, timezone
import logging

logger = logging.getLogger(__name__)


# ─── Level Thresholds & Titles ───────────────────────────────────
LEVELS = [
    {"level": 1, "xp_required": 0, "title": "Curious Explorer"},
    {"level": 2, "xp_required": 100, "title": "Knowledge Seeker"},
    {"level": 3, "xp_required": 300, "title": "Quick Learner"},
    {"level": 4, "xp_required": 600, "title": "Deep Thinker"},
    {"level": 5, "xp_required": 1000, "title": "Rising Scholar"},
    {"level": 6, "xp_required": 1500, "title": "Concept Master"},
    {"level": 7, "xp_required": 2200, "title": "Wisdom Weaver"},
    {"level": 8, "xp_required": 3000, "title": "Knowledge Architect"},
    {"level": 9, "xp_required": 4000, "title": "Enlightened Mind"},
    {"level": 10, "xp_required": 5500, "title": "Grand Sage"},
]


# ─── XP Rewards ──────────────────────────────────────────────────
XP_STEP_COMPLETE = 50            # Completing a milestone step
XP_QUIZ_PER_QUESTION = 20       # Per correct quiz answer
XP_QUIZ_ACCURACY_BONUS = 30     # Bonus for 100% quiz accuracy
XP_SESSION_COMPLETE = 100        # Bonus for finishing all steps
XP_STREAK_MULTIPLIER = 0.1      # +10% per streak day


def calculate_level(total_xp: int) -> dict:
    """
    Determine the player's level and title based on total XP.

    Returns:
        Dict with level, title, xp_for_current_level, xp_for_next_level, progress.
    """
    current = LEVELS[0]
    next_level = LEVELS[1] if len(LEVELS) > 1 else None

    for i, level_info in enumerate(LEVELS):
        if total_xp >= level_info["xp_required"]:
            current = level_info
            next_level = LEVELS[i + 1] if i + 1 < len(LEVELS) else None
        else:
            break

    if next_level:
        xp_in_level = total_xp - current["xp_required"]
        xp_needed = next_level["xp_required"] - current["xp_required"]
        progress = (xp_in_level / xp_needed) if xp_needed > 0 else 1.0
    else:
        xp_in_level = total_xp - current["xp_required"]
        xp_needed = 0
        progress = 1.0

    return {
        "level": current["level"],
        "title": current["title"],
        "total_xp": total_xp,
        "xp_for_current_level": current["xp_required"],
        "xp_for_next_level": next_level["xp_required"] if next_level else current["xp_required"],
        "xp_in_level": xp_in_level,
        "xp_needed_for_next": xp_needed,
        "progress": round(progress, 2),
        "progress_to_next": round(progress * 100.0, 1),
    }


def calculate_quiz_xp(
    correct_count: int | float,
    total_questions: int = 1,
    multiplier: float = 1.0,
) -> int:
    """
    Calculate XP earned from a quiz according to specification:
    - 20 XP per correct question
    - +30 XP bonus strictly for 100% accuracy
    - Scaled by user role multiplier (Free 1.0x, Pro 1.5x, Ultra 2.0x)
    """
    if isinstance(correct_count, float) and correct_count <= 1.0 and total_questions == 1:
        accuracy = correct_count
        c_count = round(accuracy * 3) if accuracy > 0 else 0
        total_questions = 3
    else:
        c_count = int(correct_count)
        accuracy = c_count / total_questions if total_questions > 0 else 0.0

    base_xp = c_count * XP_QUIZ_PER_QUESTION
    # Accuracy bonus (+30 XP) strictly awarded for 100% accuracy
    accuracy_bonus = XP_QUIZ_ACCURACY_BONUS if (total_questions > 0 and c_count >= total_questions) else 0

    return int((base_xp + accuracy_bonus) * multiplier)


def calculate_step_xp(streak_count: int = 0) -> int:
    """
    Calculate XP for completing a milestone step.

    Streak multiplier gives bonus XP for consecutive sessions (+10% per day, max 10 days).
    """
    base_xp = XP_STEP_COMPLETE
    streak_bonus = int(base_xp * XP_STREAK_MULTIPLIER * min(streak_count, 10))
    return base_xp + streak_bonus


def update_streak(last_activity: datetime | None, current_streak: int) -> int:
    """
    Update streak based on consecutive activity window per specification:
    - Within same calendar day: streak remains unchanged.
    - Exactly 1 day after last activity: streak increases by 1 (capped at 10 days).
    - More than 1 day missed: streak resets to 1.
    """
    now = datetime.now(timezone.utc)
    if not last_activity:
        return max(1, current_streak)

    if last_activity.tzinfo is None:
        last_activity = last_activity.replace(tzinfo=timezone.utc)

    diff_days = (now.date() - last_activity.date()).days
    if diff_days <= 0:
        return max(1, current_streak)
    elif diff_days == 1:
        return min(max(1, current_streak) + 1, 10)
    else:
        return 1

