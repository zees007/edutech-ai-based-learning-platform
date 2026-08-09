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
        format="%(asctime)s │ %(name)-25s │ %(levelname)-7s │ %(message)s",
        datefmt="%H:%M:%S",
        handlers=[logging.StreamHandler(sys.stdout)],
    )

    settings = get_settings()

    uvicorn.run(
        "app.main:create_app",
        factory=True,
        host=settings.host,
        port=settings.port,
        reload=settings.debug,
        log_level="info",
    )


if __name__ == "__main__":
    main()
