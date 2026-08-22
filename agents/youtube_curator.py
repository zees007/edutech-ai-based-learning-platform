"""
EduTechAI — YouTube & Media Curator Agent

Finds relevant YouTube video clips with precise timestamps matching
the current learning step.

Pipeline:
1. YouTube Data API v3 search → find relevant videos
2. youtube-transcript-api → fetch transcripts
3. ChromaDB → embed transcript chunks with timestamp metadata
4. Semantic search → find the best matching timestamp range
5. Return structured YouTubeClip objects

Reads: memory.steps[step_index], memory.learning_mode
Writes: memory.step_results[step_index].youtube_clips[]
"""

from __future__ import annotations

import logging
from typing import Any

from agents.base import BaseAgent
from models.schemas import YouTubeClip
from models.shared_memory import SharedMemory

logger = logging.getLogger(__name__)


class YouTubeCuratorAgent(BaseAgent):
    """
    YouTube & Media Curator agent.

    Searches YouTube for educational videos relevant to the current step,
    fetches their transcripts, and finds precise timestamp ranges that
    match the step's content.
    """

    async def curate_videos(self, step: Any, topic: str = "", student_level: str = "general") -> list[YouTubeClip]:
        """Convenience method to curate YouTube videos for a step."""
        try:
            from services.youtube_client import YouTubeClient
            client = YouTubeClient()
            title = getattr(step, "title", str(step))
            clean_title = title.split(":")[0].strip() if ":" in title else title
            query = f"{topic} {clean_title}".strip()
            videos = await client.search_videos(query)
            return videos or []
        except Exception as e:
            self.logger.error(f"YouTube curation failed: {e}")
            return []

    async def execute(self, memory: SharedMemory, step_index: int | None = None) -> None:
        """Find relevant YouTube clips for the given step."""
        if step_index is None:
            step_index = memory.current_step_index

        step = memory.steps[step_index] if step_index < len(memory.steps) else None
        if step is None:
            return

        self.logger.info(f"Searching YouTube for step {step_index}: '{step.title}'")

        step_result = memory.get_step_result(step_index)

        try:
            # Import the YouTube client service
            from services.youtube_client import YouTubeClient
            client = YouTubeClient()

            # Step 1: Search YouTube for relevant videos
            # Build clean search query (Topic + main step keywords)
            clean_step_title = step.title.split(":")[0].strip() if ":" in step.title else step.title
            search_query = f"{memory.topic} {clean_step_title}".strip()
            videos = await client.search_videos(search_query)

            if not videos:
                self.logger.info(f"No YouTube videos found for: {search_query}")
                return

            # Step 2: Determine User Tier Limit
            from services.database import get_db_session
            from models.db_models import User, Role
            from sqlalchemy.orm import selectinload
            from sqlalchemy import select
            
            user_roles = []
            async with get_db_session() as db:
                res = await db.execute(
                    select(User).options(selectinload(User.roles).selectinload(Role.privileges))
                    .where(User.id == memory.user_id)
                )
                u = res.scalar_one_or_none()
                if u:
                    user_roles = [r.name for r in u.roles if not r.retired]
            
            from config import get_settings
            settings = get_settings()
            
            limit = settings.free_youtube_limit
            if "Ultra" in user_roles or "Admin" in user_roles:
                limit = settings.ultra_youtube_limit
            elif "Pro" in user_roles:
                limit = settings.pro_youtube_limit

            # Step 3-5: For each video, try to get transcript and find best timestamp
            clips = []
            for video in videos[:limit]:  # Process top N results based on tier
                try:
                    clip = await client.get_timestamped_clip(
                        video_id=video["video_id"],
                        video_title=video["title"],
                        channel=video["channel"],
                        thumbnail_url=video.get("thumbnail_url", ""),
                        query=f"{step.title} {step.description}",
                        description=video.get("description", ""),
                    )
                    if clip:
                        clips.append(clip)
                except Exception as e:
                    self.logger.warning(f"Failed to process video {video['video_id']}: {e}")
                    continue

            # In Visual mode, prioritize more clips; in Bite-Sized, take only the best one
            if memory.learning_mode.value == "bite_sized" and clips:
                clips = [clips[0]]

            step_result.youtube_clips = clips
            self.logger.info(f"Found {len(clips)} YouTube clips for step {step_index}")

        except ImportError:
            self.logger.warning("YouTubeClient not available — skipping video search.")
        except Exception as e:
            self.logger.error(f"YouTube search failed: {e}")
