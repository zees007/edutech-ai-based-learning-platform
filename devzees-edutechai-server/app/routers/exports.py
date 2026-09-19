from __future__ import annotations

import io
import logging
import re
from datetime import datetime

from fastapi import APIRouter, Depends
from fastapi.responses import PlainTextResponse, Response
import markdown
from xhtml2pdf import pisa

from app.dependencies import get_current_user, require_privilege
from app.exceptions import BadRequestException, NotFoundException
from app.privileges_config import ET_EXPORT_MARKDOWN, ET_EXPORT_PDF
from models.db_models import User
from app.routers.learning import get_session_or_404

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/export", tags=["Exports"])


def check_session_completed(memory) -> None:
    """Verify that the learning session has completed all steps before allowing export."""
    steps = getattr(memory, "steps", []) or []
    total_steps = len(steps)
    if total_steps == 0:
        raise BadRequestException(
            error_code="SESSION_INCOMPLETE",
            errors="Export is only available when the learning journey is completed. Session has no steps.",
        )

    completed_steps = sum(
        1 for s in steps
        if getattr(s, "status", None) and (
            s.status.value == "complete" if hasattr(s.status, "value") else str(s.status) == "complete"
        )
    )

    is_complete = (
        getattr(memory, "is_complete", False)
        or completed_steps >= total_steps
        or getattr(memory, "steps_completed", 0) >= total_steps
    )

    if not is_complete:
        raise BadRequestException(
            error_code="SESSION_INCOMPLETE",
            errors="Export is only available when the learning journey is completed. All steps must be finished.",
        )


def _get_attr(item, key, default=None):
    """Safely get an attribute from a dict or object."""
    if item is None:
        return default
    if isinstance(item, dict):
        return item.get(key, default)
    return getattr(item, key, default)


def generate_markdown(memory) -> str:
    """
    Generate an attractive, concise, and structured Markdown string
    representing the completed learning session.
    """
    mode_raw = _get_attr(memory, "learning_mode", "visual")
    mode_str = mode_raw.value if hasattr(mode_raw, "value") else str(mode_raw)
    steps = _get_attr(memory, "steps", []) or []
    total_steps = len(steps)
    completed_steps = sum(
        1 for s in steps
        if (getattr(s, "status", None) and (
            s.status.value == "complete" if hasattr(s.status, "value") else str(s.status) == "complete"
        )) or (_get_attr(s, "status") == "complete")
    )
    progress_pct = (completed_steps / total_steps * 100) if total_steps > 0 else 100
    student_level = _get_attr(memory, "student_level", "general")
    topic = _get_attr(memory, "topic", "Learning Session")
    xp_earned = _get_attr(memory, "xp_earned", 0)
    streak_count = _get_attr(memory, "streak_count", 0)
    session_papers = _get_attr(memory, "academic_papers", []) or []
    quiz_scores_map = _get_attr(memory, "quiz_scores", {}) or {}

    # ─── Brand & Header Banner ──────────────────────────────────
    md = f"# ⚡ EduTechAI — Learning Journey Summary\n\n"
    md += f"> **Topic:** {topic}  \n"
    md += f"> **Status:** Mastered & Completed ✅  \n"
    md += f"> **Exported On:** {datetime.now().strftime('%B %d, %Y at %I:%M %p')}\n\n"

    # ─── Key Metrics Table ──────────────────────────────────────
    md += "### 📊 Journey Overview\n\n"
    md += "| Metric | Details |\n"
    md += "|---|---|\n"
    md += f"| **Learning Mode** | {mode_str.replace('_', ' ').title()} |\n"
    md += f"| **Student Level** | {str(student_level).replace('_', ' ').title()} |\n"
    md += f"| **Milestones Completed** | {completed_steps}/{total_steps} ({progress_pct:.0f}%) |\n"
    md += f"| **Total XP Earned** | +{xp_earned} XP |\n"
    md += f"| **Learning Streak** | {streak_count} days |\n\n"
    md += "---\n\n"

    # ─── Milestone Steps ────────────────────────────────────────
    md += "## 🎯 Mastered Milestones\n\n"

    for step in steps:
        step_idx = _get_attr(step, "index", 0)
        title = _get_attr(step, "title", f"Step {step_idx + 1}")
        description = _get_attr(step, "description", "")
        est_min = _get_attr(step, "estimated_minutes", 5)

        md += f"### Milestone {step_idx + 1}: {title} ✅\n\n"
        if description:
            md += f"**Objective:** {description} *(Est. {est_min} min)*\n\n"

        # ── Socratic Explanation ──
        explanation = _get_attr(step, "tutor_explanation", None)
        if explanation:
            md += f"#### 🎓 Key Conceptual Takeaways\n\n{explanation.strip()}\n\n"

        # ── Socratic Questions ──
        socratic_qs = _get_attr(step, "socratic_questions", []) or []
        if socratic_qs:
            md += "#### 💡 Reflection & Socratic Prompts\n\n"
            for qi, q in enumerate(socratic_qs, 1):
                md += f"{qi}. {q}\n"
            md += "\n"

        # ── YouTube Videos ──
        videos = _get_attr(step, "videos", []) or []
        if videos:
            md += "#### 🎬 Recommended Video Clips\n\n"
            for vid in videos:
                v_title = _get_attr(vid, "title", "Video Clip")
                v_channel = _get_attr(vid, "channel", "YouTube")
                v_video_id = _get_attr(vid, "video_id", "")
                v_ts = _get_attr(vid, "start_time", 0) or _get_attr(vid, "timestamp_seconds", 0)
                v_url = _get_attr(vid, "url", "") or _get_attr(vid, "timestamp_url", "")
                if not v_url and v_video_id:
                    v_url = f"https://www.youtube.com/watch?v={v_video_id}&t={int(v_ts or 0)}"
                v_explanation = _get_attr(vid, "timestamp_explanation", "") or _get_attr(vid, "relevance_snippet", "")

                md += f"- **[{v_title}]({v_url})** — *{v_channel}*\n"
                if v_explanation:
                    md += f"  - 📌 *Highlight:* {v_explanation.strip()}\n"
            md += "\n"

        # ── Step Academic Papers ──
        step_papers = _get_attr(step, "papers", []) or []
        if step_papers:
            md += "#### 📚 Academic Research Papers\n\n"
            for paper in step_papers:
                p_title = _get_attr(paper, "title", "Research Paper")
                p_authors = _get_attr(paper, "authors", [])
                p_year = _get_attr(paper, "year", None)
                p_url = _get_attr(paper, "url", "") or _get_attr(paper, "pdf_url", "")
                p_source = str(_get_attr(paper, "source", "Academic")).title()
                p_summary = (
                    _get_attr(paper, "tldr", "")
                    or _get_attr(paper, "ai_summary", "")
                    or _get_attr(paper, "abstract", "")
                )
                authors_str = ", ".join(p_authors[:3]) if isinstance(p_authors, list) and p_authors else "Scholarly Source"
                year_str = f" ({p_year})" if p_year else ""

                if p_url:
                    md += f"- **[{p_title}]({p_url})**{year_str} — *{authors_str}* | Source: {p_source}\n"
                else:
                    md += f"- **{p_title}**{year_str} — *{authors_str}* | Source: {p_source}\n"
                if p_summary:
                    summary_short = p_summary[:200] + "..." if len(p_summary) > 200 else p_summary
                    md += f"  - 🔍 *Key Insight:* _{summary_short.strip()}_\n"
            md += "\n"

        # ── Quiz Results ──
        quiz_data = _get_attr(step, "quiz", []) or []
        quiz_score = _get_attr(step, "quiz_score", None)
        if quiz_score is None:
            quiz_score = quiz_scores_map.get(step_idx, quiz_scores_map.get(str(step_idx), None))

        user_answers = _get_attr(step, "user_answers", {}) or {}
        user_full_answers = _get_attr(step, "user_full_answers", {}) or {}

        if quiz_data and isinstance(quiz_data, list) and len(quiz_data) > 0:
            score_str = f"{quiz_score:.0%}" if quiz_score is not None else "100%"
            md += f"#### 📝 Comprehension Quiz Results (Score: {score_str})\n\n"
            for qi, q_item in enumerate(quiz_data):
                q_text = _get_attr(q_item, "question", f"Question {qi + 1}")
                correct_ans = _get_attr(q_item, "correct_answer", "")
                explanation_text = _get_attr(q_item, "explanation", "")

                student_ans = (
                    user_full_answers.get(qi)
                    or user_full_answers.get(str(qi))
                    or user_answers.get(qi)
                    or user_answers.get(str(qi))
                    or "—"
                )
                is_correct = (
                    str(student_ans).strip().lower() == str(correct_ans).strip().lower()
                    if student_ans != "—"
                    else False
                )
                status_icon = "✅" if is_correct else ("❌" if student_ans != "—" else "⏭️")

                md += f"{qi + 1}. **{q_text}**\n"
                if student_ans != "—":
                    md += f"   - **Your Answer:** {student_ans} {status_icon}\n"
                    md += f"   - **Correct Answer:** {correct_ans}\n"
                if explanation_text:
                    md += f"   - 💡 *Explanation:* {explanation_text}\n"
                md += "\n"

        md += "---\n\n"

    # ── Session-Level Academic Papers (if not shown per step) ──
    has_step_papers = any(_get_attr(s, "papers", []) for s in steps)
    if session_papers and not has_step_papers:
        md += "## 📚 Curated Academic Research\n\n"
        for paper in session_papers:
            p_title = _get_attr(paper, "title", "Research Paper")
            p_authors = _get_attr(paper, "authors", [])
            p_year = _get_attr(paper, "year", None)
            p_url = _get_attr(paper, "url", "") or _get_attr(paper, "pdf_url", "")
            p_source = str(_get_attr(paper, "source", "Academic")).title()
            p_summary = (
                _get_attr(paper, "tldr", "")
                or _get_attr(paper, "ai_summary", "")
                or _get_attr(paper, "abstract", "")
            )
            authors_str = ", ".join(p_authors[:3]) if isinstance(p_authors, list) and p_authors else "Scholarly Source"
            year_str = f" ({p_year})" if p_year else ""

            if p_url:
                md += f"- **[{p_title}]({p_url})**{year_str} — *{authors_str}* | Source: {p_source}\n"
            else:
                md += f"- **{p_title}**{year_str} — *{authors_str}* | Source: {p_source}\n"
            if p_summary:
                summary_short = p_summary[:200] + "..." if len(p_summary) > 200 else p_summary
                md += f"  - 🔍 *Key Insight:* _{summary_short.strip()}_\n"
        md += "\n---\n\n"

    # ── Session Summary Footer ──
    if quiz_scores_map:
        avg_score = sum(quiz_scores_map.values()) / len(quiz_scores_map)
        md += "## 🏆 Session Mastery Summary\n\n"
        md += f"- **Comprehension Quiz Average:** {avg_score:.0%}\n"
        md += f"- **Milestone Completion Rate:** 100% ({total_steps}/{total_steps} steps)\n"
        md += f"- **Total Experience Earned:** +{xp_earned} XP\n\n"

    md += "*Generated by EduTechAI — Your AI-Powered Learning Companion* ⚡\n"
    return md


def generate_pdf(memory) -> bytes:
    """Generate an executive-grade, beautifully branded PDF byte stream."""
    md_content = generate_markdown(memory)

    # Strip Mermaid code blocks if any — replace with clean notice
    md_content = re.sub(
        r"```mermaid\s*\n.*?```",
        "*📊 A visual diagram is available in the Markdown export. Open the .md file in GitHub, Obsidian, or Typora to view it.*",
        md_content,
        flags=re.DOTALL,
    )

    # Convert markdown body to HTML with table support
    html_body = markdown.markdown(md_content, extensions=["tables"])

    styled_html = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <style>
            @page {{
                size: a4;
                margin: 18mm 14mm 18mm 14mm;
            }}
            body {{
                font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
                font-size: 10pt;
                line-height: 1.55;
                color: #1E293B;
                margin: 0;
                padding: 0;
            }}
            /* ── App Logo Header ── */
            .logo-table {{
                width: 100%;
                border: none;
                margin-bottom: 18px;
                border-bottom: 2px solid #6366F1;
                padding-bottom: 12px;
            }}
            .logo-brand {{
                font-size: 22pt;
                font-weight: bold;
                color: #0F172A;
                letter-spacing: -0.5px;
            }}
            .logo-brand-accent {{
                color: #7C3AED;
            }}
            .logo-brand-ai {{
                color: #2563EB;
            }}
            .logo-badge {{
                font-size: 8pt;
                background-color: #EEF2FF;
                color: #4F46E5;
                border: 1px solid #C7D2FE;
                padding: 2px 7px;
                border-radius: 6px;
                font-weight: bold;
                vertical-align: middle;
                margin-left: 6px;
            }}
            .logo-subtitle {{
                font-size: 9pt;
                color: #64748B;
                margin-top: 3px;
                font-weight: 500;
            }}
            .logo-meta {{
                font-size: 8.5pt;
                color: #64748B;
                line-height: 1.4;
                text-align: right;
            }}
            /* ── Typography & Headings ── */
            h1 {{
                display: none; /* Replaced by logo header */
            }}
            h2 {{
                color: #1E293B;
                font-size: 14pt;
                font-weight: bold;
                margin-top: 20px;
                margin-bottom: 10px;
                border-bottom: 1.5px solid #E2E8F0;
                padding-bottom: 4px;
            }}
            h3 {{
                color: #4F46E5;
                font-size: 12pt;
                font-weight: bold;
                margin-top: 16px;
                margin-bottom: 6px;
            }}
            h4 {{
                color: #334155;
                font-size: 10.5pt;
                font-weight: bold;
                margin-top: 12px;
                margin-bottom: 4px;
            }}
            p {{
                margin: 0 0 8px 0;
            }}
            a {{
                color: #4F46E5;
                text-decoration: none;
                font-weight: bold;
            }}
            /* ── Tables ── */
            table {{
                border-collapse: collapse;
                width: 100%;
                margin-top: 8px;
                margin-bottom: 14px;
            }}
            th, td {{
                border: 1px solid #E2E8F0;
                padding: 6px 10px;
                text-align: left;
                font-size: 9pt;
            }}
            th {{
                background-color: #F8FAFC;
                color: #334155;
                font-weight: bold;
            }}
            /* ── Lists & Quotes ── */
            ul, ol {{
                margin: 0 0 10px 0;
                padding-left: 18px;
            }}
            li {{
                margin-bottom: 4px;
            }}
            hr {{
                border: none;
                border-top: 1px solid #E2E8F0;
                margin: 16px 0;
            }}
            blockquote {{
                background-color: #F8FAFC;
                border-left: 3px solid #6366F1;
                margin: 8px 0;
                padding: 6px 12px;
                color: #475569;
                font-size: 9.5pt;
                border-radius: 4px;
            }}
            strong {{
                color: #0F172A;
            }}
            em {{
                color: #475569;
            }}
        </style>
    </head>
    <body>
        <!-- Official Brand Logo & Header -->
        <table class="logo-table">
            <tr>
                <td style="border: none; padding: 0; vertical-align: middle;">
                    <div class="logo-brand">
                        <span class="logo-brand-accent">⚡ EduTech</span><span class="logo-brand-ai">AI</span>
                        <span class="logo-badge">MASTERED JOURNEY</span>
                    </div>
                    <div class="logo-subtitle">
                        AI-Powered Learning Mastery & Comprehensive Study Guide
                    </div>
                </td>
                <td style="border: none; padding: 0; vertical-align: middle;" class="logo-meta">
                    <strong>Status:</strong> <span style="color: #059669; font-weight: bold;">100% Completed ✅</span><br/>
                    <strong>Exported:</strong> {datetime.now().strftime('%B %d, %Y')}
                </td>
            </tr>
        </table>

        <!-- Rendered Content -->
        {html_body}
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
    Only available when the learning session is 100% completed.
    """
    memory = await get_session_or_404(session_id)
    if memory.user_id != current_user.id:
        raise NotFoundException(error_code="SESSION_NOT_FOUND", errors="Session not found.")

    check_session_completed(memory)

    md_content = generate_markdown(memory)
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
    Export the learning session as a PDF file.
    Requires ET_EXPORT_PDF privilege (Ultra).
    Only available when the learning session is 100% completed.
    """
    memory = await get_session_or_404(session_id)
    if memory.user_id != current_user.id:
        raise NotFoundException(error_code="SESSION_NOT_FOUND", errors="Session not found.")

    check_session_completed(memory)

    try:
        pdf_bytes = generate_pdf(memory)
        return Response(
            content=pdf_bytes,
            media_type="application/pdf",
            headers={"Content-Disposition": f'attachment; filename="session_{session_id}.pdf"'},
        )
    except Exception as e:
        logger.error(f"Failed to generate PDF for session {session_id}: {e}")
        return PlainTextResponse(content="Error generating PDF", status_code=500)
