"""
EduTechAI — Web Search Grounding Service

Provides real-time web grounding via Tavily AI Search API (primary)
or DuckDuckGo Search fallback (zero API key required).
"""

from __future__ import annotations

import logging
import re
from typing import Any

import httpx

from config import get_settings
from models.schemas import WebSearchResult

logger = logging.getLogger(__name__)


class WebSearchClient:
    """
    Web search client for retrieving real-time web grounding context.

    Pipeline:
    1. If tavily_api_key is configured -> Tavily AI Search API
    2. Fallback -> DuckDuckGo HTML/API search (zero API key required)
    """

    def __init__(self):
        self.settings = get_settings()
        self._tavily_api_key = self.settings.tavily_api_key
        self._max_results = self.settings.web_search_max_results

    async def search(self, query: str, max_results: int | None = None) -> list[WebSearchResult]:
        """
        Search the web for up-to-date information on a given query.

        Args:
            query: The search query string.
            max_results: Max results to return (defaults to config).

        Returns:
            List of WebSearchResult models.
        """
        if not self.settings.enable_web_search:
            logger.info("Web search disabled in configuration. Skipping.")
            return []

        max_results = max_results or self._max_results

        # Try Tavily first if key is available
        if self._tavily_api_key and self._tavily_api_key != "your_tavily_api_key_here":
            results = await self._search_tavily(query, max_results)
            if results:
                return results

        # Fallback to DuckDuckGo search
        return await self._search_duckduckgo(query, max_results)

    async def _search_tavily(self, query: str, max_results: int) -> list[WebSearchResult]:
        """Search using Tavily AI Search API."""
        url = "https://api.tavily.com/search"
        payload = {
            "api_key": self._tavily_api_key,
            "query": query,
            "search_depth": "basic",
            "include_answer": False,
            "max_results": max_results,
        }

        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(url, json=payload, timeout=8.0)
                response.raise_for_status()
                data = response.json()

            results = []
            for item in data.get("results", []):
                results.append(
                    WebSearchResult(
                        title=item.get("title", ""),
                        url=item.get("url", ""),
                        snippet=item.get("content", "")[:300],
                        source="tavily",
                    )
                )

            logger.info(f"Tavily search: '{query}' → {len(results)} results")
            return results

        except Exception as e:
            logger.warning(f"Tavily search failed ({e}). Falling back to DuckDuckGo.")
            return []

    async def _search_duckduckgo(self, query: str, max_results: int) -> list[WebSearchResult]:
        """Search using DuckDuckGo HTML parser as zero-key fallback."""
        url = "https://html.duckduckgo.com/html/"
        headers = {
            "User-Agent": (
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                "AppleWebKit/537.36 (KHTML, like Gecko) "
                "Chrome/120.0.0.0 Safari/537.36"
            )
        }
        data = {"q": query}

        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(url, data=data, headers=headers, timeout=8.0)
                response.raise_for_status()
                html = response.text

            # Parse results from DDG HTML response using regex
            results = []
            blocks = re.findall(
                r'<a class="result__url" href="([^"]+)".*?>.*?</a>.*?<a class="result__snippet[^"]*"[^>]*>(.*?)</a>',
                html,
                re.DOTALL,
            )

            # Fallback block regex if first pattern yields few results
            if not blocks:
                titles_urls = re.findall(r'<a class="result__a" href="([^"]+)">(.*?)</a>', html)
                snippets = re.findall(r'<a class="result__snippet[^"]*"[^>]*>(.*?)</a>', html, re.DOTALL)
                
                for (link, title_raw), snippet_raw in zip(titles_urls[:max_results], snippets[:max_results]):
                    title = self._clean_html(title_raw)
                    snippet = self._clean_html(snippet_raw)
                    # Clean redirect URL if present
                    if "uddg=" in link:
                        link = link.split("uddg=")[-1].split("&")[0]
                        from urllib.parse import unquote
                        link = unquote(link)

                    results.append(
                        WebSearchResult(
                            title=title,
                            url=link,
                            snippet=snippet[:300],
                            source="duckduckgo",
                        )
                    )
            else:
                for link, snippet_raw in blocks[:max_results]:
                    snippet = self._clean_html(snippet_raw)
                    if "uddg=" in link:
                        link = link.split("uddg=")[-1].split("&")[0]
                        from urllib.parse import unquote
                        link = unquote(link)

                    results.append(
                        WebSearchResult(
                            title=query.title(),
                            url=link,
                            snippet=snippet[:300],
                            source="duckduckgo",
                        )
                    )

            logger.info(f"DuckDuckGo search: '{query}' → {len(results)} results")
            return results

        except Exception as e:
            logger.warning(f"DuckDuckGo search failed: {e}")
            return []

    @staticmethod
    def _clean_html(text: str) -> str:
        """Strip HTML tags and clean up string formatting."""
        clean = re.sub(r"<[^>]+>", "", text)
        clean = clean.replace("&amp;", "&").replace("&quot;", '"').replace("&lt;", "<").replace("&gt;", ">")
        return " ".join(clean.split())
