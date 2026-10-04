"""
EduTechAI — YouTube Client Service

Handles YouTube Data API v3 search, transcript fetching via youtube-transcript-api,
and timestamp matching via ChromaDB embeddings.

Daily quota: 100 search.list calls/day (as of June 2026).
"""

from __future__ import annotations

import asyncio
import logging
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
            logger.warning(f"Transcript extraction failed for {video_id}: {e}")
            return []

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
        1. ChromaDB cache check — if already embedded, skip transcript fetch entirely.
        2. VectorStore (ChromaDB) semantic search (Tier 1).
        3. Keyword score matching in transcript (Tier 2 fallback).
        4. Returns video at 0s if transcript unavailable (Tier 3 fallback).

        PERF FIX: ChromaDB cache is checked BEFORE fetching the transcript.
        On a cache-hit (repeat video), the ~5-15s YouTube transcript API call
        is completely skipped — we go straight to semantic search.
        """
        t0 = time.time()

        # ── Tier 1: ChromaDB (semantic timestamp matching) ──────────────
        try:
            from services.vector_store import VectorStore
            vs = VectorStore()

            # PERF: Check if transcript is already embedded in ChromaDB.
            # If yes, skip the transcript network fetch entirely.
            already_embedded = await vs.is_transcript_embedded(video_id)

            if already_embedded:
                logger.info(f"[YouTubeClient] {video_id}: ChromaDB cache HIT — skipping transcript fetch")
                transcript = []  # not needed; embed_transcript will skip inside find_best_timestamp
            else:
                logger.info(f"[YouTubeClient] {video_id}: ChromaDB cache MISS — fetching transcript")
                transcript = await asyncio.to_thread(self.get_transcript, video_id)
                logger.info(f"[YouTubeClient] {video_id}: transcript fetched in {time.time()-t0:.2f}s ({len(transcript)} segments)")

            best_match = await vs.find_best_timestamp(
                video_id=video_id,
                transcript=transcript,
                query=query,
            )
            if best_match:
                logger.info(f"[YouTubeClient] {video_id}: ChromaDB match found in {time.time()-t0:.2f}s")
                return YouTubeClip(
                    video_id=video_id,
                    title=video_title,
                    channel=channel,
                    thumbnail_url=thumbnail_url,
                    start_time=best_match["start_time"],
                    end_time=best_match["end_time"],
                    relevance_snippet=best_match["snippet"],
                )
            # If no semantic match but transcript exists, fall through to keyword
            if not already_embedded and not transcript:
                # Tier 3: No transcript available at all
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

        except ImportError:
            logger.info("[YouTubeClient] VectorStore not available — fetching transcript for keyword fallback.")
            transcript = await asyncio.to_thread(self.get_transcript, video_id)
        except Exception as e:
            logger.warning(f"[YouTubeClient] {video_id}: ChromaDB search failed ({e}), falling back to keyword match")
            transcript = await asyncio.to_thread(self.get_transcript, video_id)

        # ── Tier 3 Fallback: No transcript ──────────────────────────────
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

        # ── Tier 2: Keyword matching fallback ───────────────────────────
        logger.info(f"[YouTubeClient] {video_id}: Using keyword fallback in {time.time()-t0:.2f}s")
        clip = self._keyword_match(video_id, video_title, channel, thumbnail_url, transcript, query)
        return clip

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
