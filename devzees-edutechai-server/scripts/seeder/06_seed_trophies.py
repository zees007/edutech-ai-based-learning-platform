"""
EduTechAI — Dynamic Trophy Unlock & Progression Seeder

Allows seeding, upgrading, and downgrading trophies for a target user (defaults to ultra@gmail.com).

Usage:
    # Numeric parameter (0 to 6):
    python scripts/seeder/06_seed_trophies.py 1          # Unlock Bronze only
    python scripts/seeder/06_seed_trophies.py 2          # Unlock Bronze & Silver
    python scripts/seeder/06_seed_trophies.py 3          # Unlock up to Gold
    python scripts/seeder/06_seed_trophies.py 4          # Unlock up to Platinum
    python scripts/seeder/06_seed_trophies.py 5          # Unlock up to Sapphire
    python scripts/seeder/06_seed_trophies.py 6          # Unlock all (including Diamond)
    python scripts/seeder/06_seed_trophies.py 0          # Reset all trophies (0 unlocked)

    # Named tier aliases:
    python scripts/seeder/06_seed_trophies.py bronze
    python scripts/seeder/06_seed_trophies.py silver
    python scripts/seeder/06_seed_trophies.py gold
    python scripts/seeder/06_seed_trophies.py platinum
    python scripts/seeder/06_seed_trophies.py sapphire
    python scripts/seeder/06_seed_trophies.py diamond
    python scripts/seeder/06_seed_trophies.py reset

    # Optional custom user:
    python scripts/seeder/06_seed_trophies.py 3 --user pro@gmail.com
"""

from __future__ import annotations

import argparse
import asyncio
from datetime import datetime, time, timedelta, timezone
import os
import sys
import uuid

# Ensure server root is in sys.path
SERVER_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
if SERVER_ROOT not in sys.path:
    sys.path.insert(0, SERVER_ROOT)

from sqlalchemy import delete, select
from sqlalchemy.orm import selectinload

from models.db_models import GamificationRecord, SessionRecord, StepProgress, User, UserTrophy
from models.schemas import LearningMode, MilestoneStep, QuizResult, StepStatus
from models.shared_memory import SharedMemory
from services.analytics_service import AnalyticsService
from services.database import get_db_session
from services.gamification import calculate_level

# ─── 6-Tier Prestige Target Specifications ────────────────────────
TIER_TARGETS = {
    0: {
        "tier": "none",
        "title": "Reset (No Trophies)",
        "sessions": 0,
        "steps_per_session": 0,
        "total_steps": 0,
        "perfect_quizzes": 0,
        "streak_days": 0,
        "total_xp": 0,
        "expected_unlocked": [],
    },
    1: {
        "tier": "bronze",
        "title": "Bronze Trophy (Novice Explorer)",
        "sessions": 1,
        "steps_per_session": 5,
        "total_steps": 5,
        "perfect_quizzes": 3,
        "streak_days": 1,
        "total_xp": 250,
        "expected_unlocked": ["bronze"],
    },
    2: {
        "tier": "silver",
        "title": "Silver Trophy (Scholar)",
        "sessions": 5,
        "steps_per_session": 5,
        "total_steps": 25,
        "perfect_quizzes": 8,
        "streak_days": 2,
        "total_xp": 500,
        "expected_unlocked": ["bronze", "silver"],
    },
    3: {
        "tier": "gold",
        "title": "Gold Trophy (True Grand Sage)",
        "sessions": 10,
        "steps_per_session": 6,
        "total_steps": 60,
        "perfect_quizzes": 15,
        "streak_days": 3,
        "total_xp": 1050,  # >= 1000 required for Level 10 Grand Sage
        "expected_unlocked": ["bronze", "silver", "gold"],
    },
    4: {
        "tier": "platinum",
        "title": "Platinum Trophy (Master Architect)",
        "sessions": 25,
        "steps_per_session": 6,
        "total_steps": 150,
        "perfect_quizzes": 25,
        "streak_days": 7,
        "total_xp": 2500,
        "expected_unlocked": ["bronze", "silver", "gold", "platinum"],
    },
    5: {
        "tier": "sapphire",
        "title": "Sapphire Trophy (Apex Polymath)",
        "sessions": 50,
        "steps_per_session": 5,
        "total_steps": 250,
        "perfect_quizzes": 40,
        "streak_days": 14,
        "total_xp": 5000,
        "expected_unlocked": ["bronze", "silver", "gold", "platinum", "sapphire"],
    },
    6: {
        "tier": "diamond",
        "title": "Diamond Trophy (Transcendent Legend)",
        "sessions": 100,
        "steps_per_session": 5,
        "total_steps": 500,
        "perfect_quizzes": 75,
        "streak_days": 30,
        "total_xp": 10500,
        "expected_unlocked": ["bronze", "silver", "gold", "platinum", "sapphire", "diamond"],
    },
}

TIER_NAME_MAP = {
    "0": 0, "reset": 0, "none": 0,
    "1": 1, "bronze": 1,
    "2": 2, "silver": 2,
    "3": 3, "gold": 3,
    "4": 4, "platinum": 4,
    "5": 5, "sapphire": 5,
    "6": 6, "diamond": 6,
}


async def seed_user_trophies(target_level: int, email: str = "ultra@gmail.com") -> None:
    if target_level not in TIER_TARGETS:
        raise ValueError(f"Invalid target level {target_level}. Must be 0 through 6.")

    cfg = TIER_TARGETS[target_level]
    print("\n" + "=" * 70)
    print(f"🎯 EduTechAI Trophy Seeder: Setting target {cfg['title']}")
    print(f"👤 Target User: {email}")
    print("=" * 70)

    async with get_db_session() as db:
        # 1. Locate User
        user_res = await db.execute(select(User).where(User.email == email))
        user = user_res.scalar_one_or_none()
        if not user:
            print(f"❌ User '{email}' does not exist in the database.")
            print("   Please run scripts/seeder/03_seed_users_and_subscriptions.py first.")
            return

        user_id = str(user.id)

        # 2. Delete existing learning sessions, steps, and gamification records (Clean Upgrade/Downgrade)
        existing_sessions_res = await db.execute(
            select(SessionRecord.session_id).where(SessionRecord.user_id == user_id)
        )
        existing_session_ids = list(existing_sessions_res.scalars().all())

        if existing_session_ids:
            print(f"🧹 Pruning {len(existing_session_ids)} existing sessions for clean {cfg['tier']} calibration...")
            await db.execute(
                delete(GamificationRecord).where(GamificationRecord.session_id.in_(existing_session_ids))
            )
            await db.execute(
                delete(StepProgress).where(StepProgress.session_id.in_(existing_session_ids))
            )
            await db.execute(
                delete(SessionRecord).where(SessionRecord.user_id == user_id)
            )

        # Clear existing trophy records so calibration matches target tier precisely
        await db.execute(
            delete(UserTrophy).where(UserTrophy.user_id == user_id)
        )
        await db.flush()

        # Invalidate in-memory standing cache
        AnalyticsService.invalidate_standing_cache(user_id)

        # 3. If target is 0 (Reset), commit and print summary
        if target_level == 0:
            await db.commit()
            print("✅ Successfully cleared all learning progress. 0 trophies unlocked.")
            await _print_user_standing(db, user_id, cfg)
            return

        # 4. Generate Calibrated Sessions, Steps, and Gamification Data
        num_sessions = cfg["sessions"]
        steps_per_sess = cfg["steps_per_session"]
        streak_days = cfg["streak_days"]
        needed_perfect_quizzes = cfg["perfect_quizzes"]
        total_target_xp = cfg["total_xp"]

        now = datetime.now(timezone.utc).replace(tzinfo=None)
        today = now.date()

        # Distribute XP across sessions so SUM == total_target_xp
        base_xp = total_target_xp // num_sessions
        rem_xp = total_target_xp % num_sessions

        level_info = calculate_level(total_target_xp)
        perfect_quizzes_assigned = 0

        topics = [
            "Neural Networks & Deep Learning",
            "Distributed Systems Architecture",
            "Full-Stack Flutter & Dart",
            "Cloud-Native Kubernetes",
            "Algorithmic Game Theory",
            "Relational Database Indexing",
            "GraphQL & Modern Web APIs",
            "Cybersecurity & Threat Modeling",
            "Quantum Computing Principles",
            "Socratic Dialogue & Pedagogy",
        ]

        print(f"⚡ Generating {num_sessions} sessions with {cfg['total_steps']} total steps and {needed_perfect_quizzes} perfect quizzes...")

        for s_idx in range(num_sessions):
            session_id = f"s_ultra_{uuid.uuid4().hex[:12]}"
            topic = topics[s_idx % len(topics)]
            mode = "visual" if s_idx % 2 == 0 else "deep_dive"

            # Determine timestamp to produce EXACT streak
            if s_idx < streak_days:
                # Consecutive calendar days ending today (today - 0, today - 1, ...)
                session_date = today - timedelta(days=s_idx)
            else:
                # Discontinuous dates with 2-day gaps so streak is NOT accidentally inflated
                session_date = today - timedelta(days=streak_days + 2 + (s_idx - streak_days) * 2)

            session_timestamp = datetime.combine(session_date, time(14, 0))
            session_xp = base_xp + (rem_xp if s_idx == 0 else 0)

            # Build steps, step progress, and quiz results
            steps_obj: list[MilestoneStep] = []
            session_quiz_scores: dict[int, float] = {}
            step_base_xp = session_xp // steps_per_sess
            step_rem_xp = session_xp % steps_per_sess

            for st in range(steps_per_sess):
                step_time = session_timestamp - timedelta(minutes=5 * (steps_per_sess - st))
                this_step_xp = step_base_xp + (step_rem_xp if st == 0 else 0)

                # Allocate perfect quiz (1.0) until needed quota is met, else passing 0.67
                if perfect_quizzes_assigned < needed_perfect_quizzes:
                    q_score = 1.0
                    correct_cnt = 3
                    step_quiz_xp = 70  # 3 * 20 XP + 10 XP perfect score bonus
                    perfect_quizzes_assigned += 1
                else:
                    q_score = 0.67
                    correct_cnt = 2
                    step_quiz_xp = 40  # 2 * 20 XP

                session_quiz_scores[st] = q_score

                # Create StepProgress DB record
                step_prog = StepProgress(
                    session_id=session_id,
                    step_index=st,
                    status="complete",
                    quiz_score=q_score,
                    completed_at=step_time,
                    xp_earned=this_step_xp,
                )
                db.add(step_prog)

                # Create MilestoneStep domain object for SharedMemory
                steps_obj.append(
                    MilestoneStep(
                        index=st,
                        title=f"Milestone Step {st + 1}: Core Concepts of {topic.split()[0]}",
                        description=f"Master foundational concepts and applications of {topic}.",
                        status=StepStatus.COMPLETE,
                        estimated_minutes=5,
                        tutor_explanation=f"A structured conceptual overview and exploration of {topic}.",
                        xp_earned=this_step_xp,
                        quiz_result=QuizResult(
                            step_index=st,
                            total_questions=3,
                            correct_count=correct_cnt,
                            score=q_score,
                            xp_earned=step_quiz_xp,
                            feedback=[],
                        ),
                    )
                )

            # Complete SharedMemory serialized to state_json
            memory = SharedMemory(
                session_id=session_id,
                user_id=user_id,
                topic=topic,
                learning_mode=LearningMode(mode),
                student_level="general",
                created_at=session_timestamp - timedelta(minutes=30),
                steps=steps_obj,
                current_step_index=steps_per_sess,
                steps_completed=steps_per_sess,
                xp_earned=session_xp,
                streak_count=min(streak_days, s_idx + 1),
                quiz_scores=session_quiz_scores,
            )

            # Create SessionRecord with full state_json
            session_record = SessionRecord(
                session_id=session_id,
                user_id=user_id,
                topic=topic,
                learning_mode=mode,
                student_level="general",
                total_steps=steps_per_sess,
                current_step_index=steps_per_sess - 1,
                is_complete=True,
                created_at=session_timestamp - timedelta(minutes=30),
                updated_at=session_timestamp,
                state_json=memory.model_dump(mode="json"),
            )
            db.add(session_record)

            # Create GamificationRecord
            gamification_record = GamificationRecord(
                session_id=session_id,
                xp_earned=session_xp,
                streak_count=min(streak_days, s_idx + 1),
                level=level_info["level"],
                level_title=level_info["title"],
                updated_at=session_timestamp,
            )
            db.add(gamification_record)

        await db.commit()
        print(f"✅ Seeding transaction committed. Cache invalidated.")

        # 5. Verify & Print User Standing
        await _print_user_standing(db, user_id, cfg)


async def _print_user_standing(db, user_id: str, cfg: dict) -> None:
    # Query standing directly through AnalyticsService
    AnalyticsService.invalidate_standing_cache(user_id)
    standing = await AnalyticsService.get_user_standing(db, user_id)

    lvl_info = calculate_level(standing.total_xp)
    level = lvl_info["level"]
    level_title = lvl_info["title"]

    print("\n" + "─" * 70)
    print("🏆 CURRENT VERIFIED USER STANDING:")
    print(f"  • Level:        {level} ({level_title})")
    print(f"  • Total XP:     {standing.total_xp:,} XP")
    print(f"  • Current Streak: {standing.current_streak} days (Longest: {standing.longest_streak} days)")
    print(f"  • Highest Trophy: {standing.highest_trophy_title} (ID: {standing.highest_trophy_id})")
    if standing.next_trophy_title:
        print(f"  • Next Goal:    {standing.next_trophy_title} ({int(standing.trophy_progress_fraction * 100)}% progress)")
    else:
        print("  • Next Goal:    All trophies unlocked!")

    trophy_icons = {
        "bronze": "🥉",
        "silver": "🥈",
        "gold": "🥇",
        "platinum": "💿",
        "sapphire": "🔷",
        "diamond": "💎",
    }

    print("\n  Trophy Case Status:")
    all_matched = True
    for ach in standing.achievements:
        emoji = trophy_icons.get(ach.id, "🏆")
        expected_status = ach.id in cfg["expected_unlocked"]
        if ach.unlocked == expected_status:
            status_badge = "UNLOCKED ✅" if ach.unlocked else "LOCKED   🔒"
        else:
            status_badge = "MISMATCH ❌"
            all_matched = False
        print(f"    {emoji} {ach.title:<18} [{status_badge}]  (Key: {ach.id})")

    print("─" * 70)
    if all_matched:
        print(f"🎉 Verification SUCCESS! Exactly matches '{cfg['title']}' specifications.")
    else:
        print("⚠️ Warning: Trophy status differed from expected configuration.")
    print("=" * 70 + "\n")


def parse_args():
    parser = argparse.ArgumentParser(
        description="EduTechAI Prestige Trophy Seeder (Supports Upgrading & Downgrading)"
    )
    parser.add_argument(
        "level",
        nargs="?",
        default="1",
        help="Trophy level to set: 0 (Reset), 1 (Bronze), 2 (Silver), 3 (Gold), 4 (Platinum), 5 (Sapphire), 6 (Diamond). Also accepts name aliases (bronze, silver, etc.).",
    )
    parser.add_argument(
        "--user",
        default="ultra@gmail.com",
        help="Target user email (defaults to ultra@gmail.com).",
    )
    return parser.parse_args()


def main():
    args = parse_args()
    key = str(args.level).strip().lower()
    if key not in TIER_NAME_MAP:
        print(f"❌ Unknown tier level '{args.level}'.")
        print("   Valid choices: 0, 1, 2, 3, 4, 5, 6 or bronze, silver, gold, platinum, sapphire, diamond, reset")
        sys.exit(1)

    target_level = TIER_NAME_MAP[key]
    asyncio.run(seed_user_trophies(target_level, email=args.user))


if __name__ == "__main__":
    main()
