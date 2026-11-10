"""Tests for VectorStore methods including delete_all and delete_by_video_id."""

import tempfile
import pytest
from unittest.mock import patch

from services.vector_store import VectorStore


@pytest.fixture
def temp_vector_store():
    tmp = tempfile.TemporaryDirectory(ignore_cleanup_errors=True)
    with patch("services.vector_store.get_settings") as mock_settings:
        mock_inst = mock_settings.return_value
        mock_inst.chroma_persist_dir = tmp.name
        mock_inst.chroma_collection_name = "test_transcripts"

        vs = VectorStore()
        yield vs
    tmp.cleanup()


def test_delete_all_and_delete_by_video_id(temp_vector_store):
    vs = temp_vector_store

    # Seed mock transcript chunks
    sample_transcript_v1 = [
        {"start": 0.0, "duration": 5.0, "text": "Welcome to python tutorial part 1."},
        {"start": 5.0, "duration": 5.0, "text": "Today we cover variables."},
    ]
    sample_transcript_v2 = [
        {"start": 0.0, "duration": 4.0, "text": "Machine learning basics part 2."},
    ]

    count_v1 = vs.embed_transcript("video_1", sample_transcript_v1)
    count_v2 = vs.embed_transcript("video_2", sample_transcript_v2)

    assert count_v1 > 0
    assert count_v2 > 0
    assert vs.collection.count() == count_v1 + count_v2

    # Delete video_1 only
    deleted_v1 = vs.delete_by_video_id("video_1")
    assert deleted_v1 == count_v1
    assert vs.collection.count() == count_v2

    # Delete all remaining transcripts
    total_deleted = vs.delete_all()
    assert total_deleted == count_v2
    assert vs.collection.count() == 0
