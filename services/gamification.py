"""
EduTechAI — Gamification Service

XP calculation, leveling, and streak tracking.
"""

from __future__ import annotations

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


def calculate_quiz_xp(correct_count: int | float, total_questions: int = 1) -> int:
    """
    Calculate XP earned from a quiz.

    Supports calling with:
    - calculate_quiz_xp(correct_count, total_questions)
    - calculate_quiz_xp(score_float)
    """
    if isinstance(correct_count, float) and correct_count <= 1.0 and total_questions == 1:
        accuracy = correct_count
        base_xp = int(accuracy * 50)
    else:
        c_count = int(correct_count)
        base_xp = c_count * XP_QUIZ_PER_QUESTION
        accuracy = c_count / total_questions if total_questions > 0 else 0

    # Accuracy bonus for perfect scores
    accuracy_bonus = XP_QUIZ_ACCURACY_BONUS if accuracy == 1.0 else int(accuracy * XP_QUIZ_ACCURACY_BONUS)

    return base_xp + accuracy_bonus


def calculate_step_xp(streak_count: int = 0) -> int:
    """
    Calculate XP for completing a milestone step.

    Streak multiplier gives bonus XP for consecutive sessions.
    """
    base_xp = XP_STEP_COMPLETE
    streak_bonus = int(base_xp * XP_STREAK_MULTIPLIER * min(streak_count, 10))
    return base_xp + streak_bonus
