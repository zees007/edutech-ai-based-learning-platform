"""
EduTechAI — Academic Client Service

Unified async client for searching academic papers across:
- OpenAlex API (broad multidisciplinary coverage)
- Semantic Scholar API (AI-enhanced with TLDR summaries)
- arXiv API (STEM preprints)

All searches run in parallel via asyncio.gather() and results
are deduplicated and ranked by relevance.
"""

from __future__ import annotations

import asyncio
import logging
import xml.etree.ElementTree as ET
from typing import Any

import httpx

from config import get_settings
from models.schemas import AcademicPaper

logger = logging.getLogger(__name__)


class AcademicClient:
    """
    Unified academic paper search client.
    Searches OpenAlex, Semantic Scholar, and arXiv in parallel.
    """

    def __init__(self):
        self.settings = get_settings()
        self._openalex_email = self.settings.openalex_email
        self._s2_api_key = self.settings.semantic_scholar_api_key

    async def search_all(
        self,
        query: str,
        max_results: int = 3,
    ) -> list[AcademicPaper]:
        """
        Search all academic sources in parallel and return ranked, deduplicated results.
        """
        # Run all searches in parallel
        results = await asyncio.gather(
            self._search_openalex(query, max_results),
            self._search_semantic_scholar(query, max_results),
            self._search_arxiv(query, max_results),
            return_exceptions=True,
        )

        all_papers: list[AcademicPaper] = []
        for i, result in enumerate(results):
            source = ["OpenAlex", "Semantic Scholar", "arXiv"][i]
            if isinstance(result, Exception):
                logger.warning(f"{source} search failed: {result}")
            elif isinstance(result, list):
                all_papers.extend(result)
                logger.info(f"{source}: found {len(result)} papers")

        # Deduplicate by title similarity
        deduplicated = self._deduplicate(all_papers)

        # Sort by relevance score (descending)
        deduplicated.sort(key=lambda p: p.relevance_score, reverse=True)

        return deduplicated[:max_results]

    async def _search_openalex(self, query: str, max_results: int) -> list[AcademicPaper]:
        """Search OpenAlex API."""
        url = "https://api.openalex.org/works"
        params: dict[str, Any] = {
            "search": query,
            "per_page": max_results,
            "sort": "relevance_score:desc",
            "select": "id,title,authorships,publication_year,cited_by_count,doi,open_access,abstract_inverted_index",
        }
        if self._openalex_email:
            params["mailto"] = self._openalex_email

        async with httpx.AsyncClient() as client:
            response = await client.get(url, params=params, timeout=10.0)
            response.raise_for_status()
            data = response.json()

        papers = []
        for work in data.get("results", []):
            # Reconstruct abstract from inverted index
            abstract = self._reconstruct_abstract(work.get("abstract_inverted_index"))

            # Get authors
            authors = [
                a.get("author", {}).get("display_name", "Unknown")
                for a in work.get("authorships", [])[:5]
            ]

            # Get PDF URL
            oa = work.get("open_access", {})
            pdf_url = oa.get("oa_url", "") or ""

            papers.append(AcademicPaper(
                title=work.get("title", "Untitled"),
                authors=authors,
                year=work.get("publication_year"),
                abstract=abstract,
                pdf_url=pdf_url,
                source="openalex",
                relevance_score=0.7,
                doi=work.get("doi", "") or "",
            ))

        return papers

    async def _search_semantic_scholar(self, query: str, max_results: int) -> list[AcademicPaper]:
        """Search Semantic Scholar API."""
        url = "https://api.semanticscholar.org/graph/v1/paper/search"
        params = {
            "query": query,
            "limit": max_results,
            "fields": "title,authors,year,abstract,tldr,openAccessPdf,citationCount,externalIds",
        }

        headers = {}
        if self._s2_api_key:
            headers["x-api-key"] = self._s2_api_key

        async with httpx.AsyncClient() as client:
            response = await client.get(url, params=params, headers=headers, timeout=10.0)
            response.raise_for_status()
            data = response.json()

        papers = []
        for paper in data.get("data", []):
            authors = [a.get("name", "Unknown") for a in paper.get("authors", [])[:5]]
            tldr = paper.get("tldr", {})
            tldr_text = tldr.get("text", "") if tldr else ""
            oa_pdf = paper.get("openAccessPdf", {})
            pdf_url = oa_pdf.get("url", "") if oa_pdf else ""

            ext_ids = paper.get("externalIds", {}) or {}
            doi = ext_ids.get("DOI", "") or ""

            papers.append(AcademicPaper(
                title=paper.get("title", "Untitled"),
                authors=authors,
                year=paper.get("year"),
                abstract=paper.get("abstract", "") or "",
                tldr=tldr_text,
                pdf_url=pdf_url,
                source="semantic_scholar",
                relevance_score=0.8,
                doi=doi,
            ))

        return papers

    async def _search_arxiv(self, query: str, max_results: int) -> list[AcademicPaper]:
        """Search arXiv API (Atom XML)."""
        url = "http://export.arxiv.org/api/query"
        params = {
            "search_query": f"all:{query}",
            "start": 0,
            "max_results": max_results,
            "sortBy": "relevance",
            "sortOrder": "descending",
        }

        async with httpx.AsyncClient() as client:
            response = await client.get(url, params=params, timeout=10.0)
            response.raise_for_status()

        # Parse Atom XML
        root = ET.fromstring(response.text)
        ns = {"atom": "http://www.w3.org/2005/Atom"}

        papers = []
        for entry in root.findall("atom:entry", ns):
            title = entry.findtext("atom:title", "", ns).strip().replace("\n", " ")
            abstract = entry.findtext("atom:summary", "", ns).strip().replace("\n", " ")

            authors = []
            for author in entry.findall("atom:author", ns):
                name = author.findtext("atom:name", "Unknown", ns)
                authors.append(name)

            # Get publication year from <published>
            published = entry.findtext("atom:published", "", ns)
            year = int(published[:4]) if published else None

            # Get PDF link
            pdf_url = ""
            for link in entry.findall("atom:link", ns):
                if link.get("title") == "pdf":
                    pdf_url = link.get("href", "")
                    break

            # Get arXiv ID
            arxiv_id = entry.findtext("atom:id", "", ns)

            papers.append(AcademicPaper(
                title=title,
                authors=authors[:5],
                year=year,
                abstract=abstract[:500],
                pdf_url=pdf_url,
                source="arxiv",
                relevance_score=0.6,
                doi="",
            ))

        return papers

    @staticmethod
    def _reconstruct_abstract(inverted_index: dict | None) -> str:
        """Reconstruct abstract from OpenAlex inverted index format."""
        if not inverted_index:
            return ""
        # inverted_index: {"word": [position1, position2], ...}
        words: list[tuple[int, str]] = []
        for word, positions in inverted_index.items():
            for pos in positions:
                words.append((pos, word))
        words.sort(key=lambda x: x[0])
        return " ".join(w for _, w in words)

    @staticmethod
    def _deduplicate(papers: list[AcademicPaper]) -> list[AcademicPaper]:
        """Remove duplicate papers based on DOI or title similarity."""
        seen_dois: set[str] = set()
        seen_titles: set[str] = set()
        unique: list[AcademicPaper] = []

        for paper in papers:
            # Check DOI
            if paper.doi and paper.doi in seen_dois:
                continue
            # Check title (normalized)
            normalized_title = paper.title.lower().strip()
            if normalized_title in seen_titles:
                continue

            if paper.doi:
                seen_dois.add(paper.doi)
            seen_titles.add(normalized_title)
            unique.append(paper)

        return unique
