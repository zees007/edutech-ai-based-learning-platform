#!/usr/bin/env python3
"""
EduTechAI — Clear ChromaDB YouTube Transcripts Script

This script deletes existing YouTube transcript embeddings from ChromaDB.
It drops the transcript collection and recreates an empty one with the
expected distance metric (cosine similarity), ensuring a clean state.

Usage:
    # Delete all transcripts (prompts for confirmation):
    python scripts/clear_transcripts.py

    # Delete all transcripts immediately (skip prompt):
    python scripts/clear_transcripts.py --yes

    # Delete transcripts for a specific YouTube video ID only:
    python scripts/clear_transcripts.py --video-id <VIDEO_ID>

    # Check transcript count and collection status without deleting:
    python scripts/clear_transcripts.py --status
"""

from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path

# Ensure devzees-edutechai-server root is on sys.path and is the working directory
SERVER_DIR = Path(__file__).resolve().parent.parent
if str(SERVER_DIR) not in sys.path:
    sys.path.insert(0, str(SERVER_DIR))
os.chdir(SERVER_DIR)

from config import get_settings
from services.vector_store import VectorStore


def print_header(title: str):
    print("=" * 64)
    print(f"  {title}")
    print("=" * 64)


def show_status(vs: VectorStore):
    """Print current ChromaDB transcript collection status."""
    stats = vs.get_collection_stats()
    persist_abs = os.path.abspath(stats["persist_dir"])
    count = stats["total_chunks"]

    print_header("ChromaDB YouTube Transcripts Status")
    print(f"  Persist Directory : {persist_abs}")
    print(f"  Collection Name   : {stats['collection']}")
    print(f"  Total Chunks      : {count:,}")
    print("=" * 64)
    return count


def main():
    parser = argparse.ArgumentParser(
        description="Delete existing YouTube transcripts from ChromaDB.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python scripts/clear_transcripts.py
  python scripts/clear_transcripts.py --yes
  python scripts/clear_transcripts.py --video-id dQw4w9WgXcQ
  python scripts/clear_transcripts.py --status
        """,
    )
    parser.add_argument(
        "-y", "--yes", "--force",
        action="store_true",
        dest="force",
        help="Skip confirmation prompt and immediately delete.",
    )
    parser.add_argument(
        "--video-id",
        type=str,
        default=None,
        help="Delete transcript chunks for a specific YouTube video ID only.",
    )
    parser.add_argument(
        "-s", "--status", "--info",
        action="store_true",
        help="Show collection status and chunk count without deleting.",
    )

    args = parser.parse_args()

    vs = VectorStore()
    total_count = show_status(vs)

    if args.status:
        return

    # Delete specific video ID if provided
    if args.video_id:
        video_id = args.video_id.strip()
        existing = vs.collection.get(where={"video_id": video_id})
        ids = existing.get("ids", [])
        if not ids:
            print(f"\n[INFO] No transcript chunks found for video_id='{video_id}'.")
            return

        if not args.force:
            confirm = input(
                f"\nFound {len(ids)} chunk(s) for video '{video_id}'. Delete them? (y/N): "
            ).strip().lower()
            if confirm not in ("y", "yes"):
                print("[ABORTED] Operation cancelled by user.")
                return

        deleted = vs.delete_by_video_id(video_id)
        remaining = vs.collection.count()
        print(f"\n[SUCCESS] Deleted {deleted:,} chunks for video '{video_id}'.")
        print(f"          Remaining total chunks in ChromaDB: {remaining:,}\n")
        return

    # Delete all transcripts
    if total_count == 0:
        print("\n[INFO] Collection is already empty (0 chunks). Nothing to delete.\n")
        return

    if not args.force:
        confirm = input(
            f"\nWARNING: This will permanently delete ALL {total_count:,} transcript chunks.\n"
            f"Are you sure you want to proceed? (y/N): "
        ).strip().lower()
        if confirm not in ("y", "yes"):
            print("[ABORTED] Operation cancelled by user.")
            return

    print(f"\n[DELETING] Purging {total_count:,} transcript chunks from ChromaDB...")
    deleted_count = vs.delete_all()
    new_count = vs.collection.count()

    print(f"[SUCCESS] ChromaDB transcripts cleared successfully!")
    print(f"          Chunks deleted : {deleted_count:,}")
    print(f"          Current count  : {new_count}\n")


if __name__ == "__main__":
    main()
