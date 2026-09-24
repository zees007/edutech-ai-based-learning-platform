"""
EduTechAI — Learning Session Export Endpoints

Provides routes for downloading completed learning sessions in various formats:
- Plaintext Markdown (.md)
- Branded, styled PDF with rendered LaTeX & Mermaid diagrams (.pdf)
- Standalone interactive HTML study guide (.html)
"""

from __future__ import annotations

import asyncio
import logging

from fastapi import APIRouter, Depends
from fastapi.responses import HTMLResponse, PlainTextResponse, Response

from app.dependencies import get_current_user, require_privilege
from app.exceptions import NotFoundException
from app.privileges_config import ET_EXPORT_HTML, ET_EXPORT_MARKDOWN, ET_EXPORT_PDF
from app.routers.learning import get_session_or_404
from models.db_models import User
from services.export_service import (
    ExportService,
    check_session_completed,
    export_service,
    format_inline_math_for_pdf,
    generate_html,
    generate_markdown,
    generate_pdf,
    latex_inline_to_html,
    normalize_markdown_list_indentation,
)

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/export", tags=["Exports"])


@router.get(
    "/{session_id}/md",
    response_class=PlainTextResponse,
    dependencies=[Depends(require_privilege(ET_EXPORT_MARKDOWN))],
)
async def export_session_markdown(
    session_id: str,
    current_user: User = Depends(get_current_user),
):
    """
    Export the learning session as a Markdown text file.
    Requires ET_EXPORT_MARKDOWN privilege (Pro/Ultra).
    Only available when the learning session is 100% completed.
    """
    memory = await get_session_or_404(session_id)
    if memory.user_id != current_user.id:
        raise NotFoundException(error_code="SESSION_NOT_FOUND", errors="Session not found.")

    export_service.check_session_completed(memory)

    md_content = export_service.generate_markdown(memory)
    return PlainTextResponse(
        content=md_content,
        headers={"Content-Disposition": f'attachment; filename="session_{session_id}.md"'},
    )


@router.get(
    "/{session_id}/pdf",
    response_class=Response,
    dependencies=[Depends(require_privilege(ET_EXPORT_PDF))],
)
async def export_session_pdf(
    session_id: str,
    current_user: User = Depends(get_current_user),
):
    """
    Export the learning session as a clean, branded PDF file.
    Requires ET_EXPORT_PDF privilege (Ultra).
    Only available when the learning session is 100% completed.
    """
    memory = await get_session_or_404(session_id)
    if memory.user_id != current_user.id:
        raise NotFoundException(error_code="SESSION_NOT_FOUND", errors="Session not found.")

    export_service.check_session_completed(memory)

    try:
        pdf_bytes = await asyncio.wait_for(export_service.generate_pdf(memory), timeout=120.0)
        return Response(
            content=pdf_bytes,
            media_type="application/pdf",
            headers={"Content-Disposition": f'attachment; filename="session_{session_id}.pdf"'},
        )
    except asyncio.TimeoutError:
        logger.error(f"PDF generation timed out after 120s for session {session_id}")
        return PlainTextResponse(content="PDF generation timed out. Please try again.", status_code=504)
    except Exception as e:
        logger.error(f"Failed to generate PDF for session {session_id}: {e}")
        return PlainTextResponse(content="Error generating PDF", status_code=500)


@router.get(
    "/{session_id}/html",
    response_class=HTMLResponse,
    dependencies=[Depends(require_privilege(ET_EXPORT_HTML))],
)
async def export_session_html(
    session_id: str,
    current_user: User = Depends(get_current_user),
):
    """
    Export the learning session as an interactive, standalone HTML document.
    Requires ET_EXPORT_HTML privilege (Pro/Ultra).
    Only available when the learning session is 100% completed.
    """
    memory = await get_session_or_404(session_id)
    if memory.user_id != current_user.id:
        raise NotFoundException(error_code="SESSION_NOT_FOUND", errors="Session not found.")

    export_service.check_session_completed(memory)

    html_content = export_service.generate_html(memory)
    return HTMLResponse(
        content=html_content,
        headers={"Content-Disposition": f'inline; filename="session_{session_id}.html"'},
    )


__all__ = [
    "router",
    "export_service",
    "ExportService",
    "check_session_completed",
    "generate_markdown",
    "generate_pdf",
    "generate_html",
    "latex_inline_to_html",
    "format_inline_math_for_pdf",
    "normalize_markdown_list_indentation",
]
