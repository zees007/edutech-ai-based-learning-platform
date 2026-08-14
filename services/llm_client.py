"""
EduTechAI — Provider-Agnostic LLM Client

Unified client that works with Groq, Ollama, or any OpenAI-compatible API.
To switch providers, just change .env:

    # Groq (default)
    LLM_PROVIDER=groq
    LLM_BASE_URL=https://api.groq.com/openai/v1
    GROQ_API_KEY=gsk_...

    # Ollama (local)
    LLM_PROVIDER=ollama
    LLM_BASE_URL=http://localhost:11434/v1
    ORCHESTRATOR_MODEL=llama3.1:8b
"""

from __future__ import annotations

import asyncio
import json
import logging
from typing import Any, AsyncGenerator

from groq import AsyncGroq, RateLimitError

from config import LLMProvider, Settings, get_settings

logger = logging.getLogger(__name__)


class LLMClient:
    """
    Unified async LLM client.

    Uses the Groq SDK (which is OpenAI-compatible) as the base client.
    This means it works with Groq, Ollama, and any OpenAI-compatible endpoint
    out of the box — just change the base_url.
    """

    def __init__(self, settings: Settings | None = None):
        self.settings = settings or get_settings()

        # For Groq provider, omit base_url (or ignore https://api.groq.com/...) so the Groq SDK uses its native endpoint
        base_url = self.settings.llm_base_url
        if self.settings.llm_provider == LLMProvider.GROQ:
            if not base_url or "api.groq.com" in base_url:
                base_url = None

        self._client = AsyncGroq(
            api_key=self.settings.groq_api_key or "ollama",  # Ollama doesn't need a real key
            base_url=base_url,
        )
        logger.info(
            f"LLM client initialized: provider={self.settings.llm_provider.value}, "
            f"base_url={base_url or 'default'}"
        )

    async def chat(
        self,
        model: str,
        messages: list[dict[str, str]],
        temperature: float = 0.7,
        max_tokens: int = 2048,
        response_format: dict | None = None,
        **kwargs: Any,
    ) -> str:
        """
        Send a chat completion request and return the full response text.

        Args:
            model: Model name (e.g., "llama-3.1-8b-instant")
            messages: Chat messages [{"role": "system", "content": "..."}, ...]
            temperature: Sampling temperature (0.0 = deterministic, 1.0 = creative)
            max_tokens: Maximum tokens in the response
            response_format: Optional JSON schema for structured output
            **kwargs: Additional parameters passed to the API

        Returns:
            The model's response text.
        """
        completion_kwargs: dict[str, Any] = {
            "model": model,
            "messages": messages,
            "temperature": temperature,
            "max_tokens": max_tokens,
            **kwargs,
        }
        if response_format is not None:
            completion_kwargs["response_format"] = response_format

        response = await self._call_with_retry(
            self._client.chat.completions.create,
            **completion_kwargs,
        )
        content = response.choices[0].message.content or ""
        logger.debug(f"LLM response ({model}): {content[:100]}...")
        return content

    async def chat_stream(
        self,
        model: str,
        messages: list[dict[str, str]],
        temperature: float = 0.7,
        max_tokens: int = 2048,
        **kwargs: Any,
    ) -> AsyncGenerator[str, None]:
        """
        Stream a chat completion response token-by-token.

        Yields:
            Individual text chunks as they arrive from the model.
        """
        response = await self._call_with_retry(
            self._client.chat.completions.create,
            model=model,
            messages=messages,
            temperature=temperature,
            max_tokens=max_tokens,
            stream=True,
            **kwargs,
        )

        async for chunk in response:
            if chunk.choices and chunk.choices[0].delta.content:
                yield chunk.choices[0].delta.content

    async def chat_json(
        self,
        model: str,
        messages: list[dict[str, str]],
        temperature: float = 0.3,
        max_tokens: int = 2048,
        **kwargs: Any,
    ) -> dict | list:
        """
        Send a chat request expecting a JSON response.
        Parses the response and returns the Python dict/list.

        Uses lower temperature by default for more deterministic structured output.
        """
        response_text = await self.chat(
            model=model,
            messages=messages,
            temperature=temperature,
            max_tokens=max_tokens,
            response_format={"type": "json_object"},
            **kwargs,
        )
        try:
            return json.loads(response_text)
        except json.JSONDecodeError as e:
            logger.error(f"Failed to parse JSON from LLM response: {e}\nResponse: {response_text[:500]}")
            # Try to extract JSON from the response (common with some models)
            return self._extract_json(response_text)

    async def _call_with_retry(self, func, **kwargs) -> Any:
        """
        Call an API function with exponential backoff on rate limit errors.
        """
        max_retries = self.settings.groq_max_retries
        base_delay = self.settings.groq_retry_delay

        for attempt in range(max_retries + 1):
            try:
                return await func(**kwargs)
            except RateLimitError as e:
                if attempt == max_retries:
                    logger.error(f"Rate limit exceeded after {max_retries} retries")
                    raise
                delay = base_delay * (2 ** attempt)
                logger.warning(
                    f"Rate limited (attempt {attempt + 1}/{max_retries + 1}). "
                    f"Retrying in {delay:.1f}s..."
                )
                await asyncio.sleep(delay)
            except Exception as e:
                logger.error(f"LLM API error: {type(e).__name__}: {e}")
                raise

    @staticmethod
    def _extract_json(text: str) -> dict:
        """
        Try to extract JSON from a text response that may contain extra content.
        Handles cases where models wrap JSON in markdown code blocks.
        """
        # Try to find JSON within code blocks
        import re
        json_match = re.search(r"```(?:json)?\s*\n?(.*?)\n?```", text, re.DOTALL)
        if json_match:
            try:
                return json.loads(json_match.group(1))
            except json.JSONDecodeError:
                pass

        # Try to find raw JSON object/array
        for start_char, end_char in [("{", "}"), ("[", "]")]:
            start_idx = text.find(start_char)
            end_idx = text.rfind(end_char)
            if start_idx != -1 and end_idx > start_idx:
                try:
                    return json.loads(text[start_idx : end_idx + 1])
                except json.JSONDecodeError:
                    continue

        # Last resort — return empty dict
        logger.error(f"Could not extract JSON from response: {text[:200]}")
        return {}


# ─── Singleton ───────────────────────────────────────────────────
_llm_client: LLMClient | None = None


def get_llm_client() -> LLMClient:
    """Get or create the global LLM client instance."""
    global _llm_client
    if _llm_client is None:
        _llm_client = LLMClient()
    return _llm_client
