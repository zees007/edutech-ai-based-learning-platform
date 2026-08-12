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

from typing import Any

from agents.base import BaseAgent
from models.schemas import Quiz, QuizQuestion, QuestionType
from models.shared_memory import SharedMemory


class QuizAgent(BaseAgent):
    """
    Assessment & Quiz agent.

    Generates 2-3 comprehension check questions contextually derived
    from the Socratic Tutor's explanation for the current step.
    """

    async def generate_quiz(self, step: Any, topic: str = "", student_level: str = "general") -> list[Any]:
        """Convenience method to generate quiz questions for a step."""
        title = getattr(step, "title", str(step))
        desc = getattr(step, "description", "")
        explanation = getattr(step, "tutor_explanation", None) or desc

        template = self._load_prompt_template("quiz_agent")
        system_prompt = self._format_prompt(
            template,
            topic=topic,
            step_title=title,
            student_level=student_level,
            explanation=explanation[:3000],
        )

        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": "Generate quiz questions for this step."},
        ]

        model = self.settings.get_model_for_agent("quiz_agent")
        try:
            response = await self.llm.chat(
                model=model,
                messages=messages,
                temperature=0.3,
                max_tokens=1024,
            )
            # Parse JSON questions or fallback to mock
            from services.json_parser import parse_json_from_llm
            data = parse_json_from_llm(response)
            questions_raw = data.get("questions", []) if isinstance(data, dict) else []
            parsed = []
            for idx, q_data in enumerate(questions_raw):
                if isinstance(q_data, dict):
                    c_opt = q_data.get("correct_answer", "A")
                    q_obj = QuizQuestion(
                        index=idx,
                        question=q_data.get("question", f"Question {idx+1}"),
                        question_type=QuestionType.MULTIPLE_CHOICE,
                        options=q_data.get("options", ["A", "B", "C", "D"]),
                        correct_answer=c_opt,
                        correct_option=c_opt,
                        explanation=q_data.get("explanation", ""),
                    )
                    parsed.append(q_obj)
            return parsed or self._generate_fallback_quiz(title)
        except Exception as e:
            self.logger.error(f"Quiz generation failed: {e}")
            return self._generate_fallback_quiz(title)

    def _generate_fallback_quiz(self, title: str) -> list[Any]:
        q1 = QuizQuestion(
            index=0,
            question=f"What is the main learning goal of {title}?",
            question_type=QuestionType.MULTIPLE_CHOICE,
            options=["A: Master core principles & practical concepts", "B: Memorize random definitions", "C: Skip foundational knowledge", "D: Avoid real-world application"],
            correct_answer="A: Master core principles & practical concepts",
            correct_option="A",
            explanation="Mastering core principles is key to building deep understanding.",
        )

        q2 = QuizQuestion(
            index=1,
            question=f"True or False: Mastering {title} provides the foundation for subsequent milestone steps.",
            question_type=QuestionType.TRUE_FALSE,
            options=["True", "False"],
            correct_answer="True",
            correct_option="True",
            explanation="Each milestone step builds prerequisite knowledge for advanced topics.",
        )

        q3 = QuizQuestion(
            index=2,
            question=f"Fill in the blank: To achieve long-term mastery of {title}, students should connect concepts to ___ examples.",
            question_type=QuestionType.FILL_IN_BLANK,
            options=[],
            correct_answer="real-world",
            correct_option="real-world",
            explanation="Connecting abstract concepts to real-world examples strengthens retention.",
        )

        return [q1, q2, q3]

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
                temperature=0.4,
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
