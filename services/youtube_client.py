"""
EduTechAI — YouTube Client Service

Handles YouTube Data API v3 search, transcript fetching via youtube-transcript-api,
and timestamp matching via ChromaDB embeddings.

Daily quota: 100 search.list calls/day (as of June 2026).
"""

from __future__ import annotations

import logging
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
            "q": query + " educational tutorial explained",
            "type": "video",
            "maxResults": max_results,
            "videoCaption": "closedCaption",  # Prefer videos with captions
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

        Returns:
            List of transcript segments: [{"text": "...", "start": 12.5, "duration": 5.0}, ...]
        """
        try:
            transcript = YouTubeTranscriptApi.get_transcript(video_id, languages=["en"])
            logger.info(f"Transcript fetched for {video_id}: {len(transcript)} segments")
            return transcript
        except Exception as e:
            logger.warning(f"Transcript unavailable for {video_id}: {e}")
            return []

    async def get_timestamped_clip(
        self,
        video_id: str,
        video_title: str,
        channel: str,
        thumbnail_url: str,
        query: str,
    ) -> YouTubeClip | None:
        """
        Find the best timestamp range in a video's transcript for a given query.

        Uses ChromaDB for semantic matching if available, otherwise falls back
        to simple keyword matching.
        """
        # Get transcript
        transcript = self.get_transcript(video_id)
        if not transcript:
            return None

        # Try semantic search with ChromaDB
        try:
            from services.vector_store import VectorStore
            vs = VectorStore()
            best_match = await vs.find_best_timestamp(
                video_id=video_id,
                transcript=transcript,
                query=query,
            )
            if best_match:
                return YouTubeClip(
                    video_id=video_id,
                    title=video_title,
                    channel=channel,
                    thumbnail_url=thumbnail_url,
                    start_time=best_match["start_time"],
                    end_time=best_match["end_time"],
                    relevance_snippet=best_match["snippet"],
                )
        except ImportError:
            logger.info("VectorStore not available — using keyword fallback.")
        except Exception as e:
            logger.warning(f"ChromaDB search failed, using fallback: {e}")

        # Fallback: keyword matching
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
    ) -> YouTubeClip | None:
        """Simple keyword matching fallback for timestamp detection."""
        keywords = query.lower().split()

        best_score = 0
        best_start = 0
        best_end = 60  # Default: first minute

        # Score each segment
        for i, segment in enumerate(transcript):
            text = segment["text"].lower()
            score = sum(1 for kw in keywords if kw in text)
            if score > best_score:
                best_score = score
                best_start = int(segment["start"])
                # Clip is ~2 minutes from this point
                end_time = best_start + 120
                # Find the nearest segment end
                for j in range(i, min(i + 20, len(transcript))):
                    if transcript[j]["start"] >= end_time:
                        break
                    end_time = int(transcript[j]["start"] + transcript[j].get("duration", 5))
                best_end = end_time

        return YouTubeClip(
            video_id=video_id,
            title=video_title,
            channel=channel,
            thumbnail_url=thumbnail_url,
            start_time=best_start,
            end_time=best_end,
            relevance_snippet=f"Keyword match (score: {best_score})",
        )
