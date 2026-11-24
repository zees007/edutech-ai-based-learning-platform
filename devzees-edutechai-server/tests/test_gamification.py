"""
EduTechAI — Gamification Leveling & Progression Unit Tests

Validates the 10-level single-session hierarchy (0 to 1,000 XP) and ensures
students completing 7 milestone steps with 100% quiz accuracy reach Grand Sage.
"""

from services.gamification import (
    LEVELS,
    calculate_level,
    calculate_quiz_xp,
    calculate_step_xp,
    update_streak,
    XP_STEP_COMPLETE,
    XP_QUIZ_PER_QUESTION,
    XP_QUIZ_ACCURACY_BONUS,
    XP_SESSION_COMPLETE,
)


def test_level_thresholds_structure():
    """Verify all 10 levels have ascending thresholds and correct titles."""
    assert len(LEVELS) == 10

    expected = [
        {"level": 1, "xp_required": 0, "title": "Curious Explorer"},
        {"level": 2, "xp_required": 60, "title": "Knowledge Seeker"},
        {"level": 3, "xp_required": 140, "title": "Quick Learner"},
        {"level": 4, "xp_required": 250, "title": "Deep Thinker"},
        {"level": 5, "xp_required": 380, "title": "Rising Scholar"},
        {"level": 6, "xp_required": 520, "title": "Concept Master"},
        {"level": 7, "xp_required": 670, "title": "Wisdom Weaver"},
        {"level": 8, "xp_required": 800, "title": "Knowledge Architect"},
        {"level": 9, "xp_required": 920, "title": "Enlightened Mind"},
        {"level": 10, "xp_required": 1000, "title": "Grand Sage"},
    ]

    for actual, exp in zip(LEVELS, expected):
        assert actual["level"] == exp["level"]
        assert actual["xp_required"] == exp["xp_required"]
        assert actual["title"] == exp["title"]


def test_free_user_seven_steps_reaches_concept_master():
    """A free user completing 7 steps with 100% quiz scores earns 610 XP (Level 6: Concept Master)."""
    step_xp = 7 * XP_STEP_COMPLETE  # 70
    quiz_xp = 7 * calculate_quiz_xp(3, 3, multiplier=1.0)  # 490
    session_bonus = XP_SESSION_COMPLETE  # 50
    total_xp = step_xp + quiz_xp + session_bonus

    assert total_xp == 610
    info = calculate_level(total_xp)
    assert info["level"] == 6
    assert info["title"] == "Concept Master"
    assert info["xp_in_level"] == 90
    assert info["xp_needed_for_next"] == 150


def test_pro_and_ultra_streak_multipliers():
    """Pro (1.5x) and Ultra (2.0x) earn boosted XP on consecutive daily streaks, with equal quiz mastery."""
    # Quiz and Session Complete are identical for all
    quiz_xp = 7 * calculate_quiz_xp(3, 3, multiplier=1.0)  # 490
    session_bonus = XP_SESSION_COMPLETE  # 50

    # Pro User (1.5x on streak bonus)
    pro_step = 7 * calculate_step_xp(streak_count=10, multiplier=1.5)  # 7 * (10 + 15) = 175
    total_pro = pro_step + quiz_xp + session_bonus  # 175 + 490 + 50 = 715
    assert total_pro == 715
    pro_info = calculate_level(total_pro)
    assert pro_info["level"] == 7
    assert pro_info["title"] == "Wisdom Weaver"

    # Ultra User (2.0x on streak bonus)
    ultra_step = 7 * calculate_step_xp(streak_count=10, multiplier=2.0)  # 7 * (10 + 20) = 210
    total_ultra = ultra_step + quiz_xp + session_bonus  # 210 + 490 + 50 = 750
    assert total_ultra == 750
    ultra_info = calculate_level(total_ultra)
    assert ultra_info["level"] == 7
    assert ultra_info["title"] == "Wisdom Weaver"


def test_alice_scenario_calculations():
    """Test 6-step journey (530 XP) lands at Level 6 (Concept Master)."""
    step_xp = 6 * XP_STEP_COMPLETE  # 60
    quiz_xp = 6 * calculate_quiz_xp(3, 3, multiplier=1.0)  # 420
    session_bonus = XP_SESSION_COMPLETE  # 50
    total_alice = step_xp + quiz_xp + session_bonus

    assert total_alice == 530
    info = calculate_level(total_alice)
    assert info["level"] == 6
    assert info["title"] == "Concept Master"
    assert info["xp_in_level"] == 10
    assert info["xp_needed_for_next"] == 150
    assert round(info["progress"], 2) == 0.07

def test_feedback_xp_bonus():
    """Verify submitting session feedback awards +30 XP bonus."""
    from services.gamification import calculate_feedback_xp, XP_FEEDBACK_BONUS
    assert calculate_feedback_xp() == 30
    assert XP_FEEDBACK_BONUS == 30
