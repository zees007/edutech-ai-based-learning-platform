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


def test_free_user_seven_steps_reaches_grand_sage():
    """A free user completing 7 steps with 100% quiz scores earns 1,080 XP and unlocks Grand Sage."""
    step_xp = 7 * XP_STEP_COMPLETE  # 350
    quiz_xp = 7 * calculate_quiz_xp(3, 3, multiplier=1.0)  # 630
    session_bonus = XP_SESSION_COMPLETE  # 100
    total_xp = step_xp + quiz_xp + session_bonus

    assert total_xp == 1080
    info = calculate_level(total_xp)
    assert info["level"] == 10
    assert info["title"] == "Grand Sage"
    assert info["progress"] == 1.0


def test_pro_and_ultra_reach_grand_sage():
    """Pro (1.5x) and Ultra (2.0x) users reach Grand Sage with ample margin."""
    # Pro User (1.5x)
    pro_step = 7 * int(XP_STEP_COMPLETE * 1.5)
    pro_quiz = 7 * calculate_quiz_xp(3, 3, multiplier=1.5)
    pro_bonus = int(XP_SESSION_COMPLETE * 1.5)
    total_pro = pro_step + pro_quiz + pro_bonus

    assert total_pro == 1620
    pro_info = calculate_level(total_pro)
    assert pro_info["level"] == 10
    assert pro_info["title"] == "Grand Sage"

    # Ultra User (2.0x)
    ultra_step = 7 * int(XP_STEP_COMPLETE * 2.0)
    ultra_quiz = 7 * calculate_quiz_xp(3, 3, multiplier=2.0)
    ultra_bonus = int(XP_SESSION_COMPLETE * 2.0)
    total_ultra = ultra_step + ultra_quiz + ultra_bonus

    assert total_ultra == 2160
    ultra_info = calculate_level(total_ultra)
    assert ultra_info["level"] == 10
    assert ultra_info["title"] == "Grand Sage"


def test_alice_scenario_calculations():
    """Test 6-step journey (940 XP) lands at Level 9 (Enlightened Mind)."""
    step_xp = 6 * XP_STEP_COMPLETE  # 300
    quiz_xp = 6 * calculate_quiz_xp(3, 3, multiplier=1.0)  # 540
    session_bonus = XP_SESSION_COMPLETE  # 100
    total_alice = step_xp + quiz_xp + session_bonus

    assert total_alice == 940
    info = calculate_level(total_alice)
    assert info["level"] == 9
    assert info["title"] == "Enlightened Mind"
    assert info["xp_in_level"] == 20
    assert info["xp_needed_for_next"] == 80
    assert info["progress"] == 0.25

