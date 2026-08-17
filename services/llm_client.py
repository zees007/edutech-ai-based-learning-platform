"""
EduTechAI — Provider-Agnostic LLM Client

Unified client that works with Groq, Ollama, or any OpenAI-compatible API.
To switch providers, just change .env:

    # Groq (default)
    LLM_PROVIDER=groq
    GROQ_API_KEY=gsk_...
    ORCHESTRATOR_MODEL=llama-3.1-8b-instant

    # Ollama (local)
    LLM_PROVIDER=ollama
    LLM_BASE_URL=http://localhost:11434/v1
    ORCHESTRATOR_MODEL=llama3.1:8b
"""

from __future__ import annotations

import asyncio
import json
import logging
import re
from typing import Any, AsyncGenerator

from groq import AsyncGroq, RateLimitError
import httpx

from config import LLMProvider, Settings, get_settings

logger = logging.getLogger(__name__)


class LLMClient:
    """
    Unified async LLM client.

    Supports:
    - Groq Cloud via Groq SDK
    - Ollama (local) via OpenAI-compatible HTTP API
    - Any OpenAI-compatible endpoint via HTTP API
    """

    def __init__(self, settings: Settings | None = None):
        self.settings = settings or get_settings()
        self._groq_client: AsyncGroq | None = None
        self._http_client: httpx.AsyncClient | None = None
        self._base_url: str = ""

        if self.settings.llm_provider == LLMProvider.GROQ:
            base_url = self.settings.llm_base_url
            if not base_url or "api.groq.com" in base_url:
                base_url = None

            self._groq_client = AsyncGroq(
                api_key=self.settings.groq_api_key or "",
                base_url=base_url,
                timeout=self.settings.llm_timeout,
            )
            logger.info(
                f"LLM client initialized: provider=groq, "
                f"base_url={base_url or 'default (Groq Cloud)'}, "
                f"timeout={self.settings.llm_timeout}s"
            )
        else:
            raw_base_url = (self.settings.llm_base_url or "").rstrip("/")
            if not raw_base_url:
                raw_base_url = "http://localhost:11434/v1"
            elif self.settings.llm_provider == LLMProvider.OLLAMA and not raw_base_url.endswith("/v1"):
                raw_base_url = f"{raw_base_url}/v1"

            self._base_url = raw_base_url
            headers = {"Content-Type": "application/json"}
            if self.settings.groq_api_key:
                headers["Authorization"] = f"Bearer {self.settings.groq_api_key}"
            else:
                headers["Authorization"] = "Bearer ollama"

            self._http_client = httpx.AsyncClient(
                headers=headers,
                timeout=httpx.Timeout(self.settings.llm_timeout, connect=15.0),
            )
            logger.info(
                f"LLM client initialized: provider={self.settings.llm_provider.value}, "
                f"base_url={self._base_url}, "
                f"timeout={self.settings.llm_timeout}s"
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
            model: Model name (e.g., "llama-3.1-8b-instant" or "llama3.1:8b")
            messages: Chat messages [{"role": "system", "content": "..."}, ...]
            temperature: Sampling temperature (0.0 = deterministic, 1.0 = creative)
            max_tokens: Maximum tokens in the response
            response_format: Optional JSON schema for structured output
            **kwargs: Additional parameters passed to the API

        Returns:
            The model's response text.
        """
        if self.settings.llm_provider == LLMProvider.GROQ and self._groq_client:
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
                self._groq_client.chat.completions.create,
                **completion_kwargs,
            )
            content = response.choices[0].message.content or ""
            logger.debug(f"LLM response ({model}): {content[:100]}...")
            return content
        else:
            url = f"{self._base_url}/chat/completions"
            payload: dict[str, Any] = {
                "model": model,
                "messages": messages,
                "temperature": temperature,
                "max_tokens": max_tokens,
                **kwargs,
            }
            if response_format is not None:
                payload["response_format"] = response_format

            async def _send():
                assert self._http_client is not None
                response = await self._http_client.post(url, json=payload)
                response.raise_for_status()
                return response.json()

            data = await self._call_with_retry(_send)
            content = data["choices"][0]["message"]["content"] or ""
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
        if self.settings.llm_provider == LLMProvider.GROQ and self._groq_client:
            response = await self._call_with_retry(
                self._groq_client.chat.completions.create,
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
        else:
            url = f"{self._base_url}/chat/completions"
            payload: dict[str, Any] = {
                "model": model,
                "messages": messages,
                "temperature": temperature,
                "max_tokens": max_tokens,
                "stream": True,
                **kwargs,
            }
            assert self._http_client is not None
            async with self._http_client.stream("POST", url, json=payload) as resp:
                resp.raise_for_status()
                async for line in resp.aiter_lines():
                    line = line.strip()
                    if not line or not line.startswith("data:"):
                        continue
                    data_str = line[5:].strip()
                    if data_str == "[DONE]":
                        break
                    try:
                        chunk_data = json.loads(data_str)
                        choices = chunk_data.get("choices", [])
                        if choices and "delta" in choices[0]:
                            delta_content = choices[0]["delta"].get("content", "")
                            if delta_content:
                                yield delta_content
                    except json.JSONDecodeError:
                        continue

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
            except (RateLimitError, httpx.HTTPStatusError) as e:
                if isinstance(e, httpx.HTTPStatusError) and e.response.status_code != 429:
                    logger.error(f"HTTP error {e.response.status_code}: {e.response.text}")
                    raise
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
        json_match = re.search(r"```(?:json)?\s*\n?(.*?)\n?```", text, re.DOTALL)
        if json_match:
            try:
                return json.loads(json_match.group(1))
            except json.JSONDecodeError:
                pass

        for start_char, end_char in [("{", "}"), ("[", "]")]:
            start_idx = text.find(start_char)
            end_idx = text.rfind(end_char)
            if start_idx != -1 and end_idx > start_idx:
                try:
                    return json.loads(text[start_idx : end_idx + 1])
                except json.JSONDecodeError:
                    continue

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
