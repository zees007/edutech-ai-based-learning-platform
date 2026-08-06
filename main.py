"""
EduTechAI — Entry Point

Starts the FastAPI server with uvicorn.
"""

import logging
import sys

import uvicorn

from config import get_settings


def main():
    """Start the EduTechAI server."""
    # Configure logging
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s | %(name)-25s | %(levelname)-7s | %(message)s",
        datefmt="%H:%M:%S",
        handlers=[logging.StreamHandler(sys.stdout)],
    )

    settings = get_settings()

    # On Windows, multiprocessing requires freeze_support when spawning reloader processes
    import multiprocessing
    multiprocessing.freeze_support()

    # Pass app instance directly to avoid Windows multiprocessing spawn reloader issues
    from app.main import create_app
    app = create_app()

    uvicorn.run(
        app,
        host=settings.host,
        port=settings.port,
        reload=False,  # Set reload=False when running via python main.py; use 'uvicorn app.main:create_app --reload' for CLI hot-reload
        log_level="info",
    )


if __name__ == "__main__":
    main()
