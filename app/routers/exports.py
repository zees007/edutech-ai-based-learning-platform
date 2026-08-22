from __future__ import annotations

import logging

from fastapi import APIRouter, Depends
from fastapi.responses import PlainTextResponse, Response
import io
import markdown
from xhtml2pdf import pisa

from app.dependencies import get_current_user, require_privilege
from app.exceptions import NotFoundException
from app.privileges_config import ET_EXPORT_MARKDOWN, ET_EXPORT_PDF
from models.db_models import User
from app.routers.learning import get_session_or_404

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/export", tags=["Exports"])


def generate_markdown(memory) -> str:
    """Generate a Markdown string representing the entire learning session."""
    md = f"# {memory.topic}\n\n"
    md += f"**Mode:** {memory.learning_mode.value if hasattr(memory.learning_mode, 'value') else memory.learning_mode}\n"
    md += f"**Level:** {memory.student_level}\n\n"

    for step in memory.steps:
        md += f"## Step {step.index + 1}: {step.title}\n"
        md += f"{step.description}\n\n"

        step_result = memory.get_step_result(step.index)
        if step_result and step_result.explanation:
            md += f"### Explanation\n{step_result.explanation}\n\n"

        if step_result and step_result.youtube_clips:
            md += "### Recommended Videos\n"
            for clip in step_result.youtube_clips:
                md += f"- [{clip.title}]({clip.url})\n"
            md += "\n"

        if step_result and step_result.academic_papers:
            md += "### Recommended Academic Papers\n"
            for paper in step_result.academic_papers:
                pdf_link = f" ([PDF]({paper.pdf_url}))" if paper.pdf_url else ""
                md += f"- **{paper.title}** by {', '.join(paper.authors)}{pdf_link}\n"
            md += "\n"

    return md


def generate_pdf(memory) -> bytes:
    """Generate a PDF byte stream from the learning session memory."""
    md_content = generate_markdown(memory)
    html_content = markdown.markdown(md_content)
    
    styled_html = f"""
    <html>
    <head>
        <meta charset="utf-8">
        <style>
            @page {{ size: a4; margin: 2cm; }}
            body {{ font-family: Helvetica, Arial, sans-serif; font-size: 12pt; line-height: 1.5; color: #1E293B; }}
            h1 {{ color: #2563EB; border-bottom: 2px solid #E5E7EB; padding-bottom: 5px; }}
            h2 {{ color: #1D4ED8; margin-top: 20px; border-bottom: 1px solid #E5E7EB; }}
            h3 {{ color: #3B82F6; }}
            p {{ margin-bottom: 10px; }}
            a {{ color: #2563EB; text-decoration: none; }}
        </style>
    </head>
    <body>
        {html_content}
    </body>
    </html>
    """
    
    pdf_buffer = io.BytesIO()
    pisa_status = pisa.CreatePDF(io.StringIO(styled_html), dest=pdf_buffer)
    
    if pisa_status.err:
        raise Exception("Failed to generate PDF")
        
    return pdf_buffer.getvalue()


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
    """
    memory = await get_session_or_404(session_id)
    if memory.user_id != current_user.id:
        raise NotFoundException(error_code="SESSION_NOT_FOUND", errors="Session not found.")

    md_content = generate_markdown(memory)
    return PlainTextResponse(
        content=md_content,
        headers={"Content-Disposition": f"attachment; filename=\"session_{session_id}.md\""},
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
    Export the learning session as a PDF file.
    Requires ET_EXPORT_PDF privilege (Ultra).
    """
    memory = await get_session_or_404(session_id)
    if memory.user_id != current_user.id:
        raise NotFoundException(error_code="SESSION_NOT_FOUND", errors="Session not found.")

    try:
        pdf_bytes = generate_pdf(memory)
        return Response(
            content=pdf_bytes,
            media_type="application/pdf",
            headers={"Content-Disposition": f"attachment; filename=\"session_{session_id}.pdf\""},
        )
    except Exception as e:
        logger.error(f"Failed to generate PDF for session {session_id}: {e}")
        return PlainTextResponse(content="Error generating PDF", status_code=500)
