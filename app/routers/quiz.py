"""
EduTechAI — Quiz REST Endpoints

Handles quiz submission and grading.
"""

from __future__ import annotations

import logging

from fastapi import APIRouter, Depends

from app.dependencies import require_privilege
from app.exceptions import BadRequestException, NotFoundException
from app.privileges_config import ET_GENERATE_QUIZ, ET_SUBMIT_QUIZ
from models.schemas import QuestionFeedback, QuizResult, QuizSubmission

logger = logging.getLogger(__name__)
router = APIRouter()

# Import session store & database manager
from app.routers.learning import _sessions, get_session
from services.session_manager import SessionManager

session_manager = SessionManager()


@router.post(
    "/quiz/submit",
    response_model=QuizResult,
    dependencies=[Depends(require_privilege(ET_SUBMIT_QUIZ))],
)
async def submit_quiz(submission: QuizSubmission):
    """
    Submit quiz answers and get grading results with XP.

    The quiz must have been generated for the specified step.
    """
    memory = await get_session(submission.session_id)

    # Validate step has a quiz
    step_result = memory.step_results.get(submission.step_index)
    if not step_result or not step_result.quiz:
        raise BadRequestException(
            error_code="QUIZ_NOT_FOUND",
            errors=f"No quiz found for step {submission.step_index}.",
        )

    quiz = step_result.quiz
    feedback: list[QuestionFeedback] = []
    correct_count = 0

    for question in quiz.questions:
        student_answer = submission.answers.get(question.index, "")
        is_correct = student_answer.strip().lower() == question.correct_answer.strip().lower()

        if is_correct:
            correct_count += 1

        feedback.append(
            QuestionFeedback(
                question_index=question.index,
                is_correct=is_correct,
                student_answer=student_answer,
                correct_answer=question.correct_answer,
                explanation=question.explanation,
            )
        )

    total = len(quiz.questions)
    score = correct_count / total if total > 0 else 0.0

    # Calculate XP
    base_xp = 20  # Per question
    accuracy_bonus = int(score * 30)  # Bonus for high accuracy
    xp_earned = (correct_count * base_xp) + accuracy_bonus

    # Update memory
    memory.quiz_scores[submission.step_index] = score
    memory.xp_earned += xp_earned

    # Persist session & step progress to Supabase DB
    try:
        await session_manager.update_session(memory)
        await session_manager.save_step_progress(
            session_id=submission.session_id,
            step_index=submission.step_index,
            status="complete",
            quiz_score=score,
        )
    except Exception as e:
        logger.warning(f"Failed to persist quiz result to DB: {e}")

    logger.info(
        f"Quiz submitted: session={submission.session_id}, "
        f"step={submission.step_index}, score={score:.0%}, xp={xp_earned}"
    )

    return QuizResult(
        step_index=submission.step_index,
        total_questions=total,
        correct_count=correct_count,
        score=score,
        xp_earned=xp_earned,
        feedback=feedback,
    )


@router.get(
    "/quiz/{session_id}/{step_index}",
    dependencies=[Depends(require_privilege(ET_GENERATE_QUIZ))],
)
async def get_quiz(session_id: str, step_index: int):
    """Get the quiz for a specific step (if generated)."""
    memory = await get_session(session_id)

    step_result = memory.step_results.get(step_index)
    if not step_result or not step_result.quiz:
        raise NotFoundException(
            error_code="QUIZ_NOT_AVAILABLE",
            errors=f"No quiz available for step {step_index}.",
        )

    return step_result.quiz
