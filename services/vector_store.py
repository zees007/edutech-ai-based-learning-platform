"""
EduTechAI — Vector Store Service (ChromaDB)

Handles transcript embedding, storage, and semantic search for
matching YouTube transcript segments to learning step topics.

Uses ChromaDB with its default embedding model (all-MiniLM-L6-v2).
"""

from __future__ import annotations

import logging
from typing import Any

import chromadb

from config import get_settings

logger = logging.getLogger(__name__)


class VectorStore:
    """
    ChromaDB-based vector store for YouTube transcript semantic search.

    Transcripts are chunked with timestamp metadata so semantic queries
    return the exact timestamp range matching the learning step.
    """

    def __init__(self):
        self.settings = get_settings()
        self._client: chromadb.ClientAPI | None = None
        self._collection: chromadb.Collection | None = None

    @property
    def client(self) -> chromadb.ClientAPI:
        """Lazy-init ChromaDB persistent client."""
        if self._client is None:
            self._client = chromadb.PersistentClient(
                path=self.settings.chroma_persist_dir
            )
            logger.info(f"ChromaDB initialized at: {self.settings.chroma_persist_dir}")
        return self._client

    @property
    def collection(self) -> chromadb.Collection:
        """Get or create the transcript collection."""
        if self._collection is None:
            self._collection = self.client.get_or_create_collection(
                name=self.settings.chroma_collection_name,
                metadata={"hnsw:space": "cosine"},
            )
        return self._collection

    def chunk_transcript(
        self,
        video_id: str,
        transcript: list[dict],
        chunk_size: int = 5,
    ) -> list[dict[str, Any]]:
        """
        Group transcript segments into chunks for embedding.

        Args:
            video_id: YouTube video ID.
            transcript: Raw transcript segments from youtube-transcript-api.
            chunk_size: Number of segments per chunk (default 5, ~30s of speech).

        Returns:
            List of chunks with text, start_time, end_time, and metadata.
        """
        chunks = []
        for i in range(0, len(transcript), chunk_size):
            segment_group = transcript[i : i + chunk_size]
            text = " ".join(seg["text"] for seg in segment_group)
            start_time = int(segment_group[0]["start"])
            end_time = int(
                segment_group[-1]["start"]
                + segment_group[-1].get("duration", 5)
            )

            chunks.append({
                "id": f"{video_id}_{i}",
                "text": text,
                "start_time": start_time,
                "end_time": end_time,
                "video_id": video_id,
            })

        return chunks

    def embed_transcript(
        self,
        video_id: str,
        transcript: list[dict],
    ) -> int:
        """
        Embed a video's transcript chunks into ChromaDB.
        Skips if already embedded.

        Returns:
            Number of chunks embedded.
        """
        # Check if already embedded
        existing = self.collection.get(
            where={"video_id": video_id},
            limit=1,
        )
        if existing and existing["ids"]:
            logger.info(f"Transcript for {video_id} already embedded. Skipping.")
            return 0

        chunks = self.chunk_transcript(video_id, transcript)
        if not chunks:
            return 0

        self.collection.add(
            ids=[c["id"] for c in chunks],
            documents=[c["text"] for c in chunks],
            metadatas=[
                {
                    "video_id": c["video_id"],
                    "start_time": c["start_time"],
                    "end_time": c["end_time"],
                }
                for c in chunks
            ],
        )

        logger.info(f"Embedded {len(chunks)} transcript chunks for video {video_id}")
        return len(chunks)

    async def find_best_timestamp(
        self,
        video_id: str,
        transcript: list[dict],
        query: str,
        n_results: int = 1,
    ) -> dict | None:
        """
        Find the transcript chunk most relevant to the query.

        Embeds the transcript if not already stored, then performs
        semantic search filtered to the specific video.

        Returns:
            Dict with start_time, end_time, and snippet, or None if no match.
        """
        # Ensure transcript is embedded
        self.embed_transcript(video_id, transcript)

        # Semantic search filtered to this video
        results = self.collection.query(
            query_texts=[query],
            n_results=n_results,
            where={"video_id": video_id},
        )

        if not results or not results["ids"] or not results["ids"][0]:
            return None

        # Get the best match
        metadata = results["metadatas"][0][0]  # type: ignore
        document = results["documents"][0][0]  # type: ignore

        return {
            "start_time": int(metadata["start_time"]),
            "end_time": int(metadata["end_time"]),
            "snippet": document[:200],
        }
