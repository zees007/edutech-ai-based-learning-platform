"""
EduTechAI — Quiz Agent

Dynamically generates comprehension check questions based on the
Socratic Tutor's explanation for the current step.

Reads: memory.step_results[step_index].explanation, memory.student_level
Writes: memory.step_results[step_index].quiz
Model: config.QUIZ_AGENT_MODEL

Runs AFTER the Socratic Tutor completes (needs the explanation as context).
"""

from __future__ import annotations

from agents.base import BaseAgent
from models.schemas import Quiz, QuizQuestion, QuestionType
from models.shared_memory import SharedMemory


class QuizAgent(BaseAgent):
    """
    Assessment & Quiz agent.

    Generates 2-3 comprehension check questions contextually derived
    from the Socratic Tutor's explanation for the current step.
    """

    async def execute(self, memory: SharedMemory, step_index: int | None = None) -> None:
        """Generate quiz questions for the given step."""
        if step_index is None:
            step_index = memory.current_step_index

        step = memory.steps[step_index] if step_index < len(memory.steps) else None
        if step is None:
            return

        step_result = memory.get_step_result(step_index)
        if not step_result.explanation:
            self.logger.warning(f"No explanation for step {step_index} — cannot generate quiz.")
            return

        self.logger.info(f"Generating quiz for step {step_index}: '{step.title}'")

        # Load and format the prompt
        template = self._load_prompt_template("quiz_agent")
        system_prompt = self._format_prompt(
            template,
            topic=memory.topic,
            step_title=step.title,
            student_level=memory.student_level,
            explanation=step_result.explanation[:3000],  # Truncate to stay within context
        )

        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": "Generate quiz questions for this step."},
        ]

        model = self.settings.get_model_for_agent("quiz_agent")

        try:
            result = await self.llm.chat_json(
                model=model,
                messages=messages,
                temperature=0.1,
                max_tokens=1500,
            )
        except Exception as e:
            self.logger.error(f"Quiz generation failed: {e}")
            # Fallback: create a simple generic question
            step_result.quiz = Quiz(
                step_index=step_index,
                questions=[
                    QuizQuestion(
                        index=0,
                        question=f"What is the key takeaway from this step about {step.title}?",
                        question_type=QuestionType.FILL_IN_BLANK,
                        options=[],
                        correct_answer="(Open-ended — any thoughtful response is valid)",
                        explanation="Reflect on what you just learned!",
                    )
                ],
            )
            return

        # Parse the response
        quiz = self._parse_quiz(step_index, result)
        step_result.quiz = quiz

        self.logger.info(f"Quiz generated: {len(quiz.questions)} questions for step {step_index}")

    def _parse_quiz(self, step_index: int, result: dict) -> Quiz:
        """Parse the LLM's JSON response into a Quiz object."""
        raw_questions = result.get("questions", [])
        questions = []

        for i, raw_q in enumerate(raw_questions):
            try:
                q_type_str = raw_q.get("question_type", "multiple_choice")
                try:
                    q_type = QuestionType(q_type_str)
                except ValueError:
                    q_type = QuestionType.MULTIPLE_CHOICE

                question = QuizQuestion(
                    index=i,
                    question=raw_q.get("question", f"Question {i + 1}"),
                    question_type=q_type,
                    options=raw_q.get("options", []),
                    correct_answer=raw_q.get("correct_answer", ""),
                    explanation=raw_q.get("explanation", ""),
                )
                questions.append(question)
            except Exception as e:
                self.logger.warning(f"Failed to parse question {i}: {e}")
                continue

        return Quiz(step_index=step_index, questions=questions)
