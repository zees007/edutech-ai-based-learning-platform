"""
EduTechAI — Vector Store Service (ChromaDB)

Handles transcript embedding, storage, and semantic search for
matching YouTube transcript segments to learning step topics.

Uses ChromaDB with its default embedding model (all-MiniLM-L6-v2).

Storage note:
- ChromaDB is PERSISTENT (data/chroma_db) — data survives server restarts.
- Each unique video_id is embedded once (idempotent embed_transcript).
- Storage grows with unique videos. Monitor via `collection.count()`.
"""

from __future__ import annotations

import asyncio
import logging
import time
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

    _embed_lock: asyncio.Lock | None = None

    @classmethod
    def get_lock(cls) -> asyncio.Lock:
        if cls._embed_lock is None:
            cls._embed_lock = asyncio.Lock()
        return cls._embed_lock

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
        Skips if already embedded (idempotent).

        Returns:
            Number of chunks embedded (0 if already cached).
        """
        # Check if already embedded
        existing = self.collection.get(
            where={"video_id": video_id},
            limit=1,
        )
        if existing and existing["ids"]:
            logger.info(f"[VectorStore] Transcript for {video_id} already embedded — skipping embed.")
            return 0

        chunks = self.chunk_transcript(video_id, transcript)
        if not chunks:
            return 0

        t0 = time.time()
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

        elapsed = time.time() - t0
        total_docs = self.collection.count()
        logger.info(
            f"[VectorStore] Embedded {len(chunks)} chunks for {video_id} in {elapsed:.2f}s. "
            f"Total ChromaDB docs: {total_docs}"
        )
        return len(chunks)

    async def is_transcript_embedded(self, video_id: str) -> bool:
        """
        Check if a video's transcript is already in ChromaDB.
        Used by the caller to skip transcript network fetch on cache-hits.
        """
        def _check() -> bool:
            existing = self.collection.get(
                where={"video_id": video_id},
                limit=1,
            )
            return bool(existing and existing["ids"])
        return await asyncio.to_thread(_check)
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
        def _sync_search() -> dict | None:
            t0 = time.time()
            # Ensure transcript is embedded (skips if already cached)
            chunks_added = self.embed_transcript(video_id, transcript)
            embed_ms = (time.time() - t0) * 1000

            # Semantic search filtered to this video
            t1 = time.time()
            results = self.collection.query(
                query_texts=[query],
                n_results=n_results,
                where={"video_id": video_id},
            )
            query_ms = (time.time() - t1) * 1000

            logger.info(
                f"[VectorStore] {video_id}: embed={'new' if chunks_added else 'cached'} "
                f"embed_time={embed_ms:.0f}ms query_time={query_ms:.0f}ms"
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

        # PERF: ChromaDB uses SQLite (which locks on concurrent writes) and CPU-heavy 
        # embedding models. Running these concurrently causes CPU thrashing and lock waits.
        # We use a global lock to serialize the CPU/DB work while allowing the network 
        # transcript fetches to remain perfectly parallel.
        async with self.get_lock():
            return await asyncio.to_thread(_sync_search)

    def get_collection_stats(self) -> dict:
        """Return ChromaDB collection size for monitoring/alerting."""
        count = self.collection.count()
        return {
            "collection": self.settings.chroma_collection_name,
            "persist_dir": self.settings.chroma_persist_dir,
            "total_chunks": count,
            "note": "Each unique YouTube video adds ~50-400 chunks. Monitor for unbounded growth.",
        }
