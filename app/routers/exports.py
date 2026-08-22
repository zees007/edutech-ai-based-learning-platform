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
    """Generate a comprehensive Markdown string representing the entire learning session."""
    from datetime import datetime

    mode_str = memory.learning_mode.value if hasattr(memory.learning_mode, 'value') else str(memory.learning_mode)
    total_steps = len(memory.steps) if memory.steps else 0
    completed_steps = sum(1 for s in memory.steps if getattr(s, 'status', None) and s.status.value == 'complete') if memory.steps else 0
    progress_pct = (completed_steps / total_steps * 100) if total_steps > 0 else 0

    # ─── Session Header ─────────────────────────────────────────
    md = f"# 📚 {memory.topic}\n\n"
    md += f"| Detail | Value |\n"
    md += f"|---|---|\n"
    md += f"| **Learning Mode** | {mode_str.replace('_', ' ').title()} |\n"
    md += f"| **Student Level** | {memory.student_level.replace('_', ' ').title()} |\n"
    md += f"| **Total Steps** | {total_steps} |\n"
    md += f"| **Completed** | {completed_steps}/{total_steps} ({progress_pct:.0f}%) |\n"
    md += f"| **XP Earned** | {getattr(memory, 'xp_earned', 0)} |\n"
    md += f"| **Streak** | {getattr(memory, 'streak_count', 0)} days |\n"
    md += f"| **Exported On** | {datetime.now().strftime('%B %d, %Y at %I:%M %p')} |\n\n"
    md += "---\n\n"

    # ─── Per-Step Sections ───────────────────────────────────────
    for step in memory.steps:
        step_idx = step.index
        status_val = step.status.value if hasattr(step.status, 'value') else str(step.status)
        status_badge = "✅ Complete" if status_val == 'complete' else ("⚡ In Progress" if status_val == 'in_progress' else "🔒 Pending")
        est_min = getattr(step, 'estimated_minutes', 5)

        md += f"## Step {step_idx + 1}: {step.title} — {status_badge}\n\n"
        md += f"**Objective:** {step.description}\n\n"
        md += f"**Estimated Time:** {est_min} min\n\n"

        # Get StepResult as fallback source
        step_result = memory.get_step_result(step_idx) if hasattr(memory, 'get_step_result') else None

        # ── Socratic Tutor Explanation ──
        explanation = getattr(step, 'tutor_explanation', None) or (step_result.explanation if step_result else None)
        if explanation:
            md += f"### 🎓 Socratic Tutor Explanation\n\n{explanation}\n\n"

        # ── Socratic Follow-Up Questions ──
        socratic_qs = getattr(step, 'socratic_questions', []) or (step_result.socratic_questions if step_result else [])
        if socratic_qs:
            md += "### 💡 Suggested Socratic Questions\n\n"
            for qi, q in enumerate(socratic_qs, 1):
                md += f"{qi}. {q}\n"
            md += "\n"

        # ── YouTube Videos ──
        videos = getattr(step, 'videos', []) or (step_result.youtube_clips if step_result else [])
        if videos:
            md += "### 🎬 Recommended YouTube Videos\n\n"
            for vid in videos:
                v_title = _get_attr(vid, 'title', 'Video')
                v_channel = _get_attr(vid, 'channel', 'YouTube')
                v_video_id = _get_attr(vid, 'video_id', '')
                v_ts = _get_attr(vid, 'timestamp_seconds', None) or _get_attr(vid, 'start_time', 0)
                v_url = _get_attr(vid, 'url', '') or _get_attr(vid, 'timestamp_url', '')
                if not v_url and v_video_id:
                    v_url = f"https://www.youtube.com/watch?v={v_video_id}&t={int(v_ts or 0)}"
                v_snippet = _get_attr(vid, 'relevance_snippet', '') or _get_attr(vid, 'relevant_snippet', '')
                v_explanation = _get_attr(vid, 'timestamp_explanation', '')

                md += f"- **[{v_title}]({v_url})** — *{v_channel}*\n"
                if v_explanation:
                    md += f"  - 📌 Key Clip: {v_explanation}\n"
                if v_snippet:
                    md += f"  - 💬 Transcript: _{v_snippet}_\n"
            md += "\n"

        # ── Academic Papers ──
        papers = getattr(step, 'papers', []) or (step_result.academic_papers if step_result else [])
        if papers:
            md += "### 📚 Academic Research Papers\n\n"
            for paper in papers:
                p_title = _get_attr(paper, 'title', 'Research Paper')
                p_authors = _get_attr(paper, 'authors', [])
                p_year = _get_attr(paper, 'year', None)
                p_url = _get_attr(paper, 'url', '') or _get_attr(paper, 'pdf_url', '')
                p_source = str(_get_attr(paper, 'source', 'Academic')).title()
                p_summary = _get_attr(paper, 'ai_summary', '') or _get_attr(paper, 'tldr', '') or _get_attr(paper, 'abstract', '')

                authors_str = ', '.join(p_authors[:3]) if isinstance(p_authors, list) and p_authors else 'Unknown Authors'
                year_str = f" ({p_year})" if p_year else ""

                if p_url:
                    md += f"- **[{p_title}]({p_url})**{year_str} — {authors_str} | Source: {p_source}\n"
                else:
                    md += f"- **{p_title}**{year_str} — {authors_str} | Source: {p_source}\n"
                if p_summary:
                    summary_short = p_summary[:250] + "..." if len(p_summary) > 250 else p_summary
                    md += f"  - 🔍 Key Insight: _{summary_short}_\n"
            md += "\n"

        # ── Quiz Results ──
        quiz_data = getattr(step, 'quiz', [])
        quiz_score = getattr(step, 'quiz_score', None)
        user_answers = getattr(step, 'user_answers', {})
        user_full_answers = getattr(step, 'user_full_answers', {})

        if quiz_data and isinstance(quiz_data, list) and len(quiz_data) > 0:
            md += "### 📝 Quiz Results\n\n"
            if quiz_score is not None:
                md += f"**Score: {quiz_score:.0%}**\n\n"
            for qi, q_item in enumerate(quiz_data):
                question_text = _get_attr(q_item, 'question', f'Question {qi + 1}')
                correct_answer = _get_attr(q_item, 'correct_answer', '')
                explanation_text = _get_attr(q_item, 'explanation', '')
                student_ans = user_full_answers.get(qi, user_answers.get(qi, '—'))
                is_correct = str(student_ans).strip().lower() == str(correct_answer).strip().lower() if student_ans != '—' else False
                result_icon = "✅" if is_correct else "❌" if student_ans != '—' else "⏭️"

                md += f"{qi + 1}. **{question_text}**\n"
                if student_ans != '—':
                    md += f"   - Your Answer: {student_ans} {result_icon}\n"
                    md += f"   - Correct Answer: {correct_answer}\n"
                if explanation_text:
                    md += f"   - 💡 _{explanation_text}_\n"
                md += "\n"

        md += "---\n\n"

    # ─── Session Summary Footer ──────────────────────────────────
    quiz_scores = getattr(memory, 'quiz_scores', {})
    if quiz_scores:
        avg_score = sum(quiz_scores.values()) / len(quiz_scores)
        md += f"## 🏆 Session Summary\n\n"
        md += f"- **Overall Quiz Average:** {avg_score:.0%}\n"
        md += f"- **XP Earned:** {getattr(memory, 'xp_earned', 0)}\n"
        md += f"- **Learning Streak:** {getattr(memory, 'streak_count', 0)} days\n"
        md += f"- **Completion:** {completed_steps}/{total_steps} steps ({progress_pct:.0f}%)\n\n"

    md += "*Exported from EduTechAI — Your AI-Powered Learning Companion* ⚡\n"

    return md


def _get_attr(item, key, default=None):
    """Safely get an attribute from a dict or object."""
    if isinstance(item, dict):
        return item.get(key, default)
    return getattr(item, key, default)


def generate_pdf(memory) -> bytes:
    """Generate a PDF byte stream from the learning session memory."""
    import re
    md_content = generate_markdown(memory)
    # Strip Mermaid code blocks — xhtml2pdf cannot render them
    md_content = re.sub(
        r'```mermaid\s*\n.*?```',
        '*📊 A visual diagram is available in the Markdown export. Open the .md file in GitHub, Obsidian, or Typora to view it.*',
        md_content,
        flags=re.DOTALL,
    )
    html_content = markdown.markdown(md_content, extensions=['tables'])
    
    styled_html = f"""
    <html>
    <head>
        <meta charset="utf-8">
        <style>
            @page {{ size: a4; margin: 2cm; }}
            body {{ font-family: Helvetica, Arial, sans-serif; font-size: 11pt; line-height: 1.6; color: #1E293B; }}
            h1 {{ color: #2563EB; border-bottom: 2px solid #3B82F6; padding-bottom: 8px; font-size: 22pt; }}
            h2 {{ color: #1D4ED8; margin-top: 24px; border-bottom: 1px solid #E5E7EB; padding-bottom: 4px; font-size: 16pt; }}
            h3 {{ color: #3B82F6; font-size: 13pt; margin-top: 16px; }}
            p {{ margin-bottom: 8px; }}
            a {{ color: #2563EB; text-decoration: none; }}
            table {{ border-collapse: collapse; width: 100%; margin-bottom: 16px; }}
            th, td {{ border: 1px solid #CBD5E1; padding: 6px 10px; text-align: left; font-size: 10pt; }}
            th {{ background-color: #EFF6FF; color: #1E40AF; font-weight: bold; }}
            ul, ol {{ margin-bottom: 10px; padding-left: 20px; }}
            li {{ margin-bottom: 4px; }}
            hr {{ border: none; border-top: 1px solid #E5E7EB; margin: 20px 0; }}
            em {{ color: #475569; }}
            strong {{ color: #0F172A; }}
            blockquote {{ border-left: 3px solid #3B82F6; padding-left: 12px; margin: 10px 0; color: #475569; }}
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
