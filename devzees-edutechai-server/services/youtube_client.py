"""
EduTechAI — YouTube Client Service

Handles YouTube Data API v3 search, transcript fetching via youtube-transcript-api,
and timestamp matching via ChromaDB embeddings.

Daily quota: 100 search.list calls/day (as of June 2026).
"""

from __future__ import annotations

import asyncio
import logging
import re
import time
from typing import Any

import httpx
from youtube_transcript_api import YouTubeTranscriptApi

from config import get_settings
from models.schemas import YouTubeClip

logger = logging.getLogger(__name__)


class YouTubeClient:
    """
    YouTube video search and transcript extraction client.

    Pipeline:
    1. search_videos() — YouTube Data API v3
    2. get_transcript() — youtube-transcript-api
    3. get_timestamped_clip() — ChromaDB semantic search for best timestamp
    """

    _scraping_blocked_until: float = 0.0

    def __init__(self):
        self.settings = get_settings()
        self._api_key = self.settings.youtube_api_key
        self._max_results = self.settings.youtube_max_results
        self._base_url = "https://www.googleapis.com/youtube/v3"
        self._daily_calls = 0

    async def search_videos(
        self,
        query: str,
        max_results: int | None = None,
    ) -> list[dict[str, Any]]:
        """
        Search YouTube for educational videos.

        Args:
            query: Search query string.
            max_results: Max number of results (defaults to config value).

        Returns:
            List of video metadata dicts with video_id, title, channel, thumbnail_url.
        """
        if not self._api_key or self._api_key == "your_youtube_api_key_here":
            logger.warning("YouTube API key not configured. Skipping search.")
            return []

        max_results = max_results or self._max_results

        # Check daily quota
        if self._daily_calls >= self.settings.youtube_daily_search_limit:
            logger.warning("YouTube daily search limit reached.")
            return []

        params = {
            "part": "snippet",
            "q": query.strip(),
            "type": "video",
            "maxResults": max_results,
            "relevanceLanguage": "en",
            "safeSearch": "strict",
            "key": self._api_key,
        }

        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(
                    f"{self._base_url}/search",
                    params=params,
                    timeout=10.0,
                )
                response.raise_for_status()
                data = response.json()
                self._daily_calls += 1

            videos = []
            for item in data.get("items", []):
                snippet = item.get("snippet", {})
                videos.append({
                    "video_id": item["id"]["videoId"],
                    "title": snippet.get("title", ""),
                    "channel": snippet.get("channelTitle", ""),
                    "thumbnail_url": snippet.get("thumbnails", {}).get("medium", {}).get("url", ""),
                    "description": snippet.get("description", ""),
                })

            logger.info(f"YouTube search: '{query}' → {len(videos)} results (call #{self._daily_calls})")
            return videos

        except httpx.HTTPStatusError as e:
            logger.error(f"YouTube API error: {e.response.status_code} - {e.response.text[:200]}")
            return []
        except Exception as e:
            logger.error(f"YouTube search failed: {e}")
            return []

    def get_transcript(self, video_id: str) -> list[dict]:
        """
        Fetch the transcript for a YouTube video.
        Supports both manually uploaded and auto-generated transcripts (ASR)
        across multiple English dialect tags (en, en-US, en-GB, etc.).

        Returns:
            List of transcript segments: [{"text": "...", "start": 12.5, "duration": 5.0}, ...]
        """
        if time.time() < self._scraping_blocked_until:
            remaining = int(self._scraping_blocked_until - time.time())
            logger.info(
                f"[YouTubeClient] YouTube IP scraping is temporarily blocked (cooldown {remaining}s remaining) "
                f"— skipping transcript scrape for {video_id} and using fast chapter/metadata fallback."
            )
            return []

        try:
            api = YouTubeTranscriptApi()
            transcript_list = api.list(video_id)
            target_langs = ["en", "en-US", "en-GB", "en-CA", "en-AU"]

            transcript_obj = None

            # 1. Try manually created English transcript
            try:
                transcript_obj = transcript_list.find_manually_created_transcript(target_langs)
            except Exception:
                pass

            # 2. Try auto-generated English transcript
            if not transcript_obj:
                try:
                    transcript_obj = transcript_list.find_generated_transcript(target_langs)
                except Exception:
                    pass

            # 3. Fallback to any transcript available (and translate to English if needed)
            if not transcript_obj:
                try:
                    first_transcript = next(iter(transcript_list))
                    if first_transcript.is_translatable:
                        transcript_obj = first_transcript.translate("en")
                    else:
                        transcript_obj = first_transcript
                except Exception:
                    pass

            if not transcript_obj:
                logger.warning(f"No suitable transcript found for video {video_id}")
                return []

            fetched = transcript_obj.fetch()
            transcript = []
            for item in fetched:
                if isinstance(item, dict):
                    text = item.get("text", "")
                    start = float(item.get("start", 0.0))
                    duration = float(item.get("duration", 5.0))
                else:
                    text = getattr(item, "text", "")
                    start = float(getattr(item, "start", 0.0))
                    duration = float(getattr(item, "duration", 5.0))

                transcript.append({
                    "text": text,
                    "start": start,
                    "duration": duration,
                })

            trans_type = "generated" if getattr(transcript_obj, "is_generated", False) else "manual"
            logger.info(f"Transcript fetched for {video_id}: {len(transcript)} segments ({trans_type})")
            return transcript

        except Exception as e:
            err_msg = str(e)
            if any(term in err_msg for term in ["blocking requests from your IP", "sorry/index", "SSLEOFError", "Read timed out", "IpBlocked", "RequestBlocked"]):
                YouTubeClient._scraping_blocked_until = time.time() + 600
                logger.warning(f"[YouTubeClient] YouTube IP block / rate limit detected. Tripping scraping circuit breaker for 10m: {e}")
            else:
                logger.warning(f"Transcript extraction failed for {video_id}: {e}")
            return []

    def _find_chapter_match(
        self,
        video_id: str,
        video_title: str,
        channel: str,
        thumbnail_url: str,
        description: str,
        query: str,
    ) -> YouTubeClip | None:
        """Parse YouTube description for timestamped chapters and match query."""
        if not description:
            return None

        # Regex for lines like "01:23 Topic Name", "0:00 Intro", "1:02:30 Advanced Pointers"
        chapter_regex = re.compile(
            r'^(?:(?P<hours>\d{1,2}):)?(?P<minutes>\d{1,2}):(?P<seconds>\d{2})\s*[-–—:]?\s*(?P<title>.+)$',
            re.MULTILINE,
        )

        chapters: list[tuple[int, str]] = []
        for match in chapter_regex.finditer(description):
            h = int(match.group('hours') or 0)
            m = int(match.group('minutes'))
            s = int(match.group('seconds'))
            start_seconds = h * 3600 + m * 60 + s
            title = match.group('title').strip()
            chapters.append((start_seconds, title))

        if not chapters or len(chapters) < 2:
            return None

        keywords = [kw for kw in re.findall(r'\w+', query.lower()) if len(kw) > 2]
        if not keywords:
            return None

        best_chapter = None
        best_score = 0
        best_index = -1

        for i, (start_sec, ch_title) in enumerate(chapters):
            ch_lower = ch_title.lower()
            score = sum(2 if kw in ch_lower else 0 for kw in keywords)
            if score > best_score:
                best_score = score
                best_chapter = (start_sec, ch_title)
                best_index = i

        if best_chapter and best_score >= 2:
            start_time, ch_title = best_chapter
            if best_index + 1 < len(chapters):
                end_time = chapters[best_index + 1][0]
                if end_time - start_time > 300:  # cap at 5 min
                    end_time = start_time + 240
            else:
                end_time = start_time + 180

            logger.info(f"[YouTubeClient] {video_id}: Found chapter match '{ch_title}' at {start_time}s (score={best_score})")
            return YouTubeClip(
                video_id=video_id,
                title=video_title,
                channel=channel,
                thumbnail_url=thumbnail_url,
                start_time=start_time,
                end_time=end_time,
                relevance_snippet=f"[Chapter: {ch_title}] Direct match from video chapter index.",
            )

        return None

    async def get_timestamped_clip(
        self,
        video_id: str,
        video_title: str,
        channel: str,
        thumbnail_url: str,
        query: str,
        description: str = "",
    ) -> YouTubeClip | None:
        """
        Find the best timestamp range in a video's transcript for a given query.

        Pipeline:
        0. Instant Chapter match (0ms) — scans video description for chapter markers.
        1. ChromaDB cache check — if already embedded, skip transcript fetch entirely.
        2. Fast Keyword match — if transcript has strong keyword density, match in <5ms.
        3. VectorStore (ChromaDB) semantic search with optimized chunk_size (Tier 1).
        4. Returns overview clip at 0s if transcript unavailable (Tier 3 fallback).
        """
        t0 = time.time()

        # ── Step 0: Fast-path description chapter detection (0ms) ────────
        chapter_clip = self._find_chapter_match(
            video_id=video_id,
            video_title=video_title,
            channel=channel,
            thumbnail_url=thumbnail_url,
            description=description,
            query=query,
        )
        if chapter_clip:
            logger.info(f"[YouTubeClient] {video_id}: Resolved via video chapter in {time.time()-t0:.3f}s")
            return chapter_clip

        # ── Step 1: ChromaDB cache check ─────────────────────────────────
        try:
            from services.vector_store import VectorStore
            vs = VectorStore()
            already_embedded = await vs.is_transcript_embedded(video_id)
        except Exception:
            vs = None
            already_embedded = False

        if already_embedded and vs:
            logger.info(f"[YouTubeClient] {video_id}: ChromaDB cache HIT — skipping transcript fetch")
            best_match = await vs.find_best_timestamp(
                video_id=video_id,
                transcript=[],
                query=query,
            )
            if best_match:
                logger.info(f"[YouTubeClient] {video_id}: ChromaDB cached match found in {time.time()-t0:.2f}s")
                return YouTubeClip(
                    video_id=video_id,
                    title=video_title,
                    channel=channel,
                    thumbnail_url=thumbnail_url,
                    start_time=best_match["start_time"],
                    end_time=best_match["end_time"],
                    relevance_snippet=best_match["snippet"],
                )

        # ── Step 2: Fetch transcript from YouTube (with 3.5s timeout) ─────
        try:
            transcript = await asyncio.wait_for(
                asyncio.to_thread(self.get_transcript, video_id),
                timeout=3.5,
            )
            logger.info(f"[YouTubeClient] {video_id}: transcript fetched in {time.time()-t0:.2f}s ({len(transcript)} segments)")
        except asyncio.TimeoutError:
            logger.warning(f"[YouTubeClient] {video_id}: transcript fetch timed out (3.5s limit) — using fallback")
            transcript = []
        except Exception as e:
            logger.warning(f"[YouTubeClient] {video_id}: transcript fetch failed ({e}) — using fallback")
            transcript = []

        # ── Step 3: Tier 3 Fallback if no transcript available ───────────
        if not transcript:
            snippet_preview = description[:180] + "..." if description else "Recommended video for this learning step."
            logger.info(f"[YouTubeClient] {video_id}: Tier 3 fallback (no transcript) in {time.time()-t0:.2f}s")
            return YouTubeClip(
                video_id=video_id,
                title=video_title,
                channel=channel,
                thumbnail_url=thumbnail_url,
                start_time=0,
                end_time=180,
                relevance_snippet=f"[Overview] {snippet_preview}",
            )

        # ── Step 4: Fast Keyword matching heuristic (<5ms) ───────────────
        keyword_clip = self._keyword_match(video_id, video_title, channel, thumbnail_url, transcript, query)
        # If keyword matching found an explicit multi-term hit (best_score >= 2), use it directly
        if "score: " in keyword_clip.relevance_snippet:
            score_str = keyword_clip.relevance_snippet.split("score: ")[1].rstrip(")")
            try:
                score = int(score_str)
                if score >= 2:
                    logger.info(f"[YouTubeClient] {video_id}: Resolved via fast keyword match (score={score}) in {time.time()-t0:.2f}s")
                    return keyword_clip
            except ValueError:
                pass

        # ── Step 5: Semantic search via ChromaDB (optimized chunk_size) ──
        if vs:
            try:
                best_match = await vs.find_best_timestamp(
                    video_id=video_id,
                    transcript=transcript,
                    query=query,
                )
                if best_match:
                    logger.info(f"[YouTubeClient] {video_id}: ChromaDB semantic match found in {time.time()-t0:.2f}s")
                    return YouTubeClip(
                        video_id=video_id,
                        title=video_title,
                        channel=channel,
                        thumbnail_url=thumbnail_url,
                        start_time=best_match["start_time"],
                        end_time=best_match["end_time"],
                        relevance_snippet=best_match["snippet"],
                    )
            except Exception as e:
                logger.warning(f"[YouTubeClient] {video_id}: ChromaDB search failed ({e})")

        # Fallback to keyword clip if semantic returned nothing
        return keyword_clip

    def _keyword_match(
        self,
        video_id: str,
        video_title: str,
        channel: str,
        thumbnail_url: str,
        transcript: list[dict],
        query: str,
    ) -> YouTubeClip:
        """Simple keyword matching fallback for timestamp detection."""
        keywords = [kw for kw in query.lower().split() if len(kw) > 3]

        best_score = 0
        best_start = 0
        best_end = 120  # Default: 2 mins

        # Score each segment
        if keywords:
            for i, segment in enumerate(transcript):
                text = segment["text"].lower()
                score = sum(1 for kw in keywords if kw in text)
                if score > best_score:
                    best_score = score
                    best_start = int(segment["start"])
                    end_time = best_start + 120
                    for j in range(i, min(i + 20, len(transcript))):
                        if transcript[j]["start"] >= end_time:
                            break
                        end_time = int(transcript[j]["start"] + transcript[j].get("duration", 5))
                    best_end = end_time

        snippet = f"Key segment match (score: {best_score})" if best_score > 0 else "Topic overview clip"

        return YouTubeClip(
            video_id=video_id,
            title=video_title,
            channel=channel,
            thumbnail_url=thumbnail_url,
            start_time=best_start,
            end_time=best_end,
            relevance_snippet=snippet,
        )
