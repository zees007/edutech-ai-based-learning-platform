"""Tests for clear_transcripts CLI script."""

import subprocess
import sys
from pathlib import Path


def test_clear_transcripts_cli_status():
    server_dir = Path(__file__).resolve().parent.parent
    script_path = server_dir / "scripts" / "clear_transcripts.py"
    
    result = subprocess.run(
        [sys.executable, str(script_path), "--status"],
        cwd=str(server_dir),
        capture_output=True,
        text=True,
    )
    assert result.returncode == 0
    assert "ChromaDB YouTube Transcripts Status" in result.stdout
    assert "youtube_transcripts" in result.stdout

