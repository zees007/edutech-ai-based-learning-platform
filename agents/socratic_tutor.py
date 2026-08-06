"""
EduTechAI — Socratic Tutor Agent

The teaching voice of the system. Generates warm, engaging explanations
using the Socratic method — guiding students to discover understanding
through questions and analogies rather than giving direct answers.

Reads: memory.steps[step_index], memory.learning_mode, memory.student_level, memory.conversation_history
Writes: memory.step_results[step_index].explanation, .socratic_questions
Model: config.SOCRATIC_TUTOR_MODEL

Supports token-by-token streaming via Groq streaming API for real-time UI rendering.
"""

from __future__ import annotations

from typing import AsyncGenerator

from agents.base import BaseAgent
from models.schemas import StepStatus
from models.shared_memory import SharedMemory


class SocraticTutorAgent(BaseAgent):
    """
    Socratic teaching agent.

    For each milestone step, generates:
    - A clear, age-appropriate explanation with analogies
    - 1-2 guiding Socratic questions
    - Adapts style based on learning mode and student level
    """

    async def execute(self, memory: SharedMemory, step_index: int | None = None) -> None:
        """
        Generate the Socratic explanation for a given step and write it to SharedMemory.
        """
        if step_index is None:
            step_index = memory.current_step_index

        step = memory.steps[step_index] if step_index < len(memory.steps) else None
        if step is None:
            self.logger.error(f"Step {step_index} not found in memory.")
            return

        self.logger.info(f"Teaching step {step_index}: '{step.title}'")

        # Mark step as in progress
        step_result = memory.get_step_result(step_index)
        step_result.status = StepStatus.IN_PROGRESS

        # Load and format the prompt with Web Search grounding
        web_context, web_results = await self._fetch_web_grounding(memory.topic, step.title)
        step_result.web_results = web_results

        template = self._load_prompt_template("socratic_tutor")
        system_prompt = self._format_prompt(
            template,
            topic=memory.topic,
            step_title=step.title,
            step_description=step.description,
            student_level=memory.student_level,
            learning_mode=memory.learning_mode.value,
            is_prerequisite=str(step.is_prerequisite),
            web_grounding_context=web_context,
        )

        # Build messages
        messages = [
            {"role": "system", "content": system_prompt},
        ]

        # Add recent conversation for context continuity
        for turn in memory.conversation_history[-6:]:
            messages.append({
                "role": "user" if turn.role == "student" else "assistant",
                "content": turn.content,
            })

        messages.append({
            "role": "user",
            "content": f"Please explain this step: {step.title} — {step.description}",
        })

        # Call LLM (non-streaming for SharedMemory write)
        model = self.settings.get_model_for_agent("socratic_tutor")
        try:
            response = await self.llm.chat(
                model=model,
                messages=messages,
                temperature=0.7,  # Slightly creative for engaging explanations
                max_tokens=2048,
            )
        except Exception as e:
            self.logger.error(f"Socratic Tutor LLM call failed: {e}")
            step_result.explanation = (
                f"Let's explore **{step.title}** together! "
                f"{step.description} "
                f"(The AI tutor is temporarily unavailable — please try again.)"
            )
            step_result.socratic_questions = [
                f"What do you already know about {step.title}?",
                f"Why do you think {memory.topic} is important?",
            ]
            return

        # Parse the response — split explanation from Socratic questions
        explanation, questions = self._parse_response(response)

        step_result.explanation = explanation
        step_result.socratic_questions = questions

        # Add to conversation history
        memory.add_conversation_turn("tutor", explanation)

        self.logger.info(
            f"Step {step_index} explained ({len(explanation)} chars, "
            f"{len(questions)} Socratic questions)"
        )

    async def _fetch_web_grounding(self, topic: str, step_title: str) -> tuple[str, list]:
        """Fetch live web search results and format them for the prompt template."""
        try:
            from services.web_search import WebSearchClient
            client = WebSearchClient()
            query = f"{topic} {step_title}"
            web_results = await client.search(query)
            if not web_results:
                return ("No live web search context available.", [])

            formatted = []
            for i, r in enumerate(web_results, 1):
                formatted.append(f"{i}. [{r.title}]({r.url}) - {r.snippet}")
            return ("\n".join(formatted), web_results)
        except Exception as e:
            self.logger.warning(f"Web search grounding failed: {e}")
            return ("No live web search context available.", [])

    async def stream_explanation(
        self,
        memory: SharedMemory,
        step_index: int | None = None,
    ) -> AsyncGenerator[str, None]:
        """
        Stream the explanation token-by-token for real-time UI rendering.

        This is used by the WebSocket handler. The full explanation is also
        written to SharedMemory after streaming completes.

        Yields:
            Individual text chunks as they arrive from the model.
        """
        if step_index is None:
            step_index = memory.current_step_index

        step = memory.steps[step_index] if step_index < len(memory.steps) else None
        if step is None:
            yield "Step not found."
            return

        step_result = memory.get_step_result(step_index)
        web_context, web_results = await self._fetch_web_grounding(memory.topic, step.title)
        step_result.web_results = web_results

        # Build the same prompt as execute()
        template = self._load_prompt_template("socratic_tutor")
        system_prompt = self._format_prompt(
            template,
            topic=memory.topic,
            step_title=step.title,
            step_description=step.description,
            student_level=memory.student_level,
            learning_mode=memory.learning_mode.value,
            is_prerequisite=str(step.is_prerequisite),
            web_grounding_context=web_context,
        )

        messages = [
            {"role": "system", "content": system_prompt},
        ]
        for turn in memory.conversation_history[-6:]:
            messages.append({
                "role": "user" if turn.role == "student" else "assistant",
                "content": turn.content,
            })
        messages.append({
            "role": "user",
            "content": f"Please explain this step: {step.title} — {step.description}",
        })

        model = self.settings.get_model_for_agent("socratic_tutor")
        full_response = ""
        questions_marker_found = False
        delimiter_variants = [
            "**Socratic Questions",
            "Socratic Questions:",
            "**Questions:",
            "**Guiding Questions:",
            "🤔 Socratic Questions"
        ]

        try:
            async for chunk in self.llm.chat_stream(
                model=model,
                messages=messages,
                temperature=0.7,
                max_tokens=2048,
            ):
                full_response += chunk
                
                if not questions_marker_found:
                    for d in delimiter_variants:
                        if d in full_response:
                            questions_marker_found = True
                            break
                    
                    if not questions_marker_found:
                        yield chunk
        except Exception as e:
            self.logger.error(f"Streaming failed: {e}")
            yield f"\n\n(Streaming interrupted: {e})"

        # After streaming completes, write the full response to SharedMemory
        explanation, questions = self._parse_response(full_response)
        step_result = memory.get_step_result(step_index)
        step_result.explanation = explanation
        step_result.socratic_questions = questions
        memory.add_conversation_turn("tutor", explanation)

    def _parse_response(self, response: str) -> tuple[str, list[str]]:
        """
        Split the tutor's response into explanation and Socratic questions.

        The prompt instructs the tutor to use "**Socratic Questions:**" as a delimiter.
        """
        # Look for the Socratic Questions section
        delimiter_variants = [
            "**Socratic Questions:**",
            "**Socratic Questions**:",
            "Socratic Questions:",
            "**Questions:**",
            "**Guiding Questions:**",
            "🤔 Socratic Questions"
        ]

        explanation = response
        questions = []

        for delimiter in delimiter_variants:
            if delimiter in response:
                parts = response.split(delimiter, 1)
                explanation = parts[0].strip()
                questions_text = parts[1].strip()

                # Parse numbered questions
                for line in questions_text.split("\n"):
                    line = line.strip()
                    if line and (line[0].isdigit() or line.startswith("-")):
                        # Remove numbering (1., 2., -, *)
                        question = line.lstrip("0123456789.-*) ").strip()
                        if question:
                            questions.append(question)
                break

        # Fallback: generate generic questions if none found
        if not questions:
            questions = [
                "What part of this explanation was most surprising to you?",
                "Can you think of a real-world example of this concept?",
            ]

        return explanation, questions
