from __future__ import annotations

import html
import io
import logging
import re
from datetime import datetime

from fastapi import APIRouter, Depends
from fastapi.responses import HTMLResponse, PlainTextResponse, Response
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


def _sanitize_text_for_pdf(text: str) -> str:
    """
    Sanitize text to prevent ReportLab / xhtml2pdf from rendering black box ('tofu') glyphs.
    Normalizes unicode hyphens, quotes, converts emojis to clean text badges, and filters
    characters outside standard printable ASCII/Latin-1.
    """
    if not text:
        return ""

    # 1. Normalize unicode hyphens, dashes, and spaces
    dash_map = {
        "\u2010": "-",
        "\u2011": "-",  # Non-breaking hyphen (primary cause of 'kitchen■robot')
        "\u2012": "-",
        "\u2013": "-",  # En dash
        "\u2014": " - ",  # Em dash
        "\u2015": " - ",
        "\u2212": "-",  # Minus sign
        "\u00ad": "",   # Soft hyphen
        "\u00a0": " ",  # Non-breaking space
    }
    for k, v in dash_map.items():
        text = text.replace(k, v)

    # 2. Normalize smart quotes and ellipsis
    quote_map = {
        "\u2018": "'",
        "\u2019": "'",
        "\u201a": "'",
        "\u201b": "'",
        "\u201c": '"',
        "\u201d": '"',
        "\u201e": '"',
        "\u2026": "...",
    }
    for k, v in quote_map.items():
        text = text.replace(k, v)

    # 3. Replace common emojis with textual tags or empty strings
    emoji_map = {
        "⚡": "",
        "✅": "[Correct]",
        "❌": "[Incorrect]",
        "⏭️": "[Skipped]",
        "📊": "",
        "🎯": "",
        "🎓": "",
        "💡": "",
        "🎬": "",
        "📌": "",
        "📚": "",
        "📝": "",
        "🏆": "",
        "🔍": "",
    }
    for k, v in emoji_map.items():
        text = text.replace(k, v)

    # 4. Remove any remaining characters outside standard Latin-1 / ASCII (e.g. Indic, Asian, emoji symbols)
    cleaned = []
    for ch in text:
        cp = ord(ch)
        if cp in (9, 10, 13) or (32 <= cp <= 126) or (160 <= cp <= 255):
            cleaned.append(ch)
        elif cp > 255:
            # Drop unrenderable Unicode characters
            continue
    return "".join(cleaned)


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
    md = "# ⚡ EduTechAI — Learning Journey Summary\n\n"
    md += f"> **Topic:** {topic}  \n"
    md += "> **Status:** Mastered & Completed ✅  \n"
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

        # ── YouTube Videos (Curated Top 3) ──
        videos = _get_attr(step, "videos", []) or []
        if videos:
            md += "#### 🎬 Recommended Video Clips\n\n"
            curated_videos = videos[:3]
            for vid in curated_videos:
                v_title = _get_attr(vid, "title", "Video Clip")
                v_channel = _get_attr(vid, "channel", "YouTube")
                v_video_id = _get_attr(vid, "video_id", "")
                v_ts = _get_attr(vid, "start_time", 0) or _get_attr(vid, "timestamp_seconds", 0)
                v_url = _get_attr(vid, "url", "") or _get_attr(vid, "timestamp_url", "")
                if not v_url and v_video_id:
                    v_url = f"https://www.youtube.com/watch?v={v_video_id}&t={int(v_ts or 0)}"
                v_explanation = _get_attr(vid, "timestamp_explanation", "") or _get_attr(vid, "relevance_snippet", "")

                # Filter promotional spam
                if any(bad in v_explanation.lower() for bad in ["bootcamp", "discount", "$", "code ", "off "]):
                    v_explanation = ""

                md += f"- **[{v_title}]({v_url})** — *{v_channel}*\n"
                if v_explanation:
                    snippet = v_explanation.strip()[:140] + ("..." if len(v_explanation.strip()) > 140 else "")
                    md += f"  - 📌 *Highlight:* {snippet}\n"
            md += "\n"

        # ── Step Academic Papers ──
        step_papers = _get_attr(step, "papers", []) or []
        if step_papers:
            md += "#### 📚 Academic Research Papers\n\n"
            for paper in step_papers[:3]:
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
                    summary_short = p_summary[:160] + "..." if len(p_summary) > 160 else p_summary
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

    # ── Session-Level Academic Papers ──
    has_step_papers = any(_get_attr(s, "papers", []) for s in steps)
    if session_papers and not has_step_papers:
        md += "## 📚 Curated Academic Research\n\n"
        for paper in session_papers[:5]:
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
                summary_short = p_summary[:160] + "..." if len(p_summary) > 160 else p_summary
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
    """Generate an executive-grade, beautifully branded, and glyph-clean PDF byte stream."""
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
    quiz_scores_map = _get_attr(memory, "quiz_scores", {}) or {}
    mode_raw = _get_attr(memory, "learning_mode", "visual")
    mode_str = mode_raw.value if hasattr(mode_raw, "value") else str(mode_raw)

    # Sanitize inputs for PDF
    topic_clean = _sanitize_text_for_pdf(topic)
    mode_clean = _sanitize_text_for_pdf(mode_str.replace("_", " ").title())
    level_clean = _sanitize_text_for_pdf(str(student_level).replace("_", " ").title())

    # Build PDF Body HTML with clean non-list containers for Quizzes and pre-blocks for code
    body_html = ""

    # 1. Overview Table
    body_html += f"""
    <div class="card">
        <h3>Journey Overview</h3>
        <table class="overview-table">
            <tr><th style="width: 35%;">Metric</th><th>Details</th></tr>
            <tr><td><strong>Topic</strong></td><td>{topic_clean}</td></tr>
            <tr><td><strong>Learning Mode</strong></td><td>{mode_clean}</td></tr>
            <tr><td><strong>Student Level</strong></td><td>{level_clean}</td></tr>
            <tr><td><strong>Milestones Completed</strong></td><td>{completed_steps}/{total_steps} ({progress_pct:.0f}%)</td></tr>
            <tr><td><strong>Total XP Earned</strong></td><td>+{xp_earned} XP</td></tr>
            <tr><td><strong>Learning Streak</strong></td><td>{streak_count} days</td></tr>
        </table>
    </div>
    """

    # 2. Milestones
    body_html += '<h2 style="margin-top: 24px; border-bottom: 2px solid #4F46E5; padding-bottom: 4px;">Mastered Milestones</h2>'

    for step in steps:
        step_idx = _get_attr(step, "index", 0)
        title = _sanitize_text_for_pdf(_get_attr(step, "title", f"Step {step_idx + 1}"))
        description = _sanitize_text_for_pdf(_get_attr(step, "description", ""))
        est_min = _get_attr(step, "estimated_minutes", 5)

        body_html += f"""
        <div class="milestone-block">
            <h3 class="milestone-title">Milestone {step_idx + 1}: {title} <span class="badge-success">[Mastered]</span></h3>
        """

        if description:
            body_html += f'<p class="objective-box"><strong>Objective:</strong> {description} <em>(Est. {est_min} min)</em></p>'

        # Tutor explanation
        explanation = _get_attr(step, "tutor_explanation", "")
        if explanation:
            # Strip Mermaid diagrams
            explanation = re.sub(r"```mermaid\s*\n.*?```", "", explanation, flags=re.DOTALL)
            sanitized_exp = _sanitize_text_for_pdf(explanation)

            # Convert to markdown with fenced_code and tables
            exp_html = markdown.markdown(sanitized_exp, extensions=["tables", "fenced_code"])
            # Normalize code blocks to <pre><code>
            exp_html = re.sub(
                r"<p><code>(?:[a-zA-Z0-9_\-]+\n)?(.*?)</code></p>",
                r"<pre><code>\1</code></pre>",
                exp_html,
                flags=re.DOTALL,
            )
            body_html += f'<h4>Key Conceptual Takeaways</h4><div class="explanation-content">{exp_html}</div>'

        # Socratic Prompts
        socratic_qs = _get_attr(step, "socratic_questions", []) or []
        if socratic_qs:
            body_html += "<h4>Reflection & Socratic Prompts</h4><ol class='socratic-list'>"
            for q in socratic_qs:
                q_clean = _sanitize_text_for_pdf(q)
                body_html += f"<li>{q_clean}</li>"
            body_html += "</ol>"

        # Recommended Video Clips (Top 2 to keep document concise)
        videos = _get_attr(step, "videos", []) or []
        if videos:
            body_html += "<h4>Recommended Video Clips</h4><table class='video-table'>"
            for vid in videos[:2]:
                v_title = _sanitize_text_for_pdf(_get_attr(vid, "title", "Video Clip"))
                v_channel = _sanitize_text_for_pdf(_get_attr(vid, "channel", "YouTube"))
                v_exp = _sanitize_text_for_pdf(_get_attr(vid, "timestamp_explanation", "") or _get_attr(vid, "relevance_snippet", ""))
                if any(bad in v_exp.lower() for bad in ["bootcamp", "discount", "$", "code ", "off "]):
                    v_exp = ""
                snippet = f"<br/><small style='color: #64748B;'>{v_exp[:110]}...</small>" if v_exp else ""
                body_html += f"<tr><td><strong>{v_title}</strong> — <em>{v_channel}</em>{snippet}</td></tr>"
            body_html += "</table>"

        # Academic Papers
        step_papers = _get_attr(step, "papers", []) or []
        if step_papers:
            body_html += "<h4>Academic Research Papers</h4><ul class='paper-list'>"
            for paper in step_papers[:2]:
                p_title = _sanitize_text_for_pdf(_get_attr(paper, "title", "Research Paper"))
                p_authors = _get_attr(paper, "authors", [])
                p_year = _get_attr(paper, "year", None)
                year_str = f" ({p_year})" if p_year else ""
                authors_str = _sanitize_text_for_pdf(", ".join(p_authors[:2])) if p_authors else "Scholarly Source"
                body_html += f"<li><strong>{p_title}</strong>{year_str} — <em>{authors_str}</em></li>"
            body_html += "</ul>"

        # Comprehension Quiz (Table structure — completely fixes the 1, 2, 3 -> 6, 7 -> 10, 11, 12 list bug)
        quiz_data = _get_attr(step, "quiz", []) or []
        quiz_score = _get_attr(step, "quiz_score", None)
        if quiz_score is None:
            quiz_score = quiz_scores_map.get(step_idx, quiz_scores_map.get(str(step_idx), None))

        user_answers = _get_attr(step, "user_answers", {}) or {}
        user_full_answers = _get_attr(step, "user_full_answers", {}) or {}

        if quiz_data and isinstance(quiz_data, list) and len(quiz_data) > 0:
            score_str = f"{quiz_score:.0%}" if quiz_score is not None else "100%"
            body_html += f"<h4>Comprehension Quiz Results (Score: {score_str})</h4>"
            for qi, q_item in enumerate(quiz_data):
                q_text = _sanitize_text_for_pdf(_get_attr(q_item, "question", f"Question {qi + 1}"))
                correct_ans = _sanitize_text_for_pdf(str(_get_attr(q_item, "correct_answer", "")))
                explanation_text = _sanitize_text_for_pdf(_get_attr(q_item, "explanation", ""))

                student_ans = (
                    user_full_answers.get(qi)
                    or user_full_answers.get(str(qi))
                    or user_answers.get(qi)
                    or user_answers.get(str(qi))
                    or "-"
                )
                student_ans_clean = _sanitize_text_for_pdf(str(student_ans))
                is_correct = (
                    student_ans_clean.strip().lower() == correct_ans.strip().lower()
                    if student_ans_clean != "-"
                    else False
                )
                status_badge = (
                    '<span class="badge-success">Correct</span>'
                    if is_correct
                    else ('<span class="badge-danger">Incorrect</span>' if student_ans_clean != "-" else '<span class="badge-muted">Skipped</span>')
                )

                body_html += f"""
                <div class="quiz-card">
                    <p class="quiz-q-title"><strong>Q{qi + 1}: {q_text}</strong></p>
                    <table class="quiz-ans-table">
                        <tr>
                            <td style="width: 25%;"><strong>Your Answer:</strong></td>
                            <td>{student_ans_clean} {status_badge}</td>
                        </tr>
                        <tr>
                            <td><strong>Correct Answer:</strong></td>
                            <td>{correct_ans}</td>
                        </tr>
                        {"<tr><td colspan='2'><small style='color: #475569;'><em>Explanation:</em> " + explanation_text + "</small></td></tr>" if explanation_text else ""}
                    </table>
                </div>
                """

        body_html += "</div><hr class='milestone-divider'/>"

    # 3. Session Mastery Summary
    if quiz_scores_map:
        avg_score = sum(quiz_scores_map.values()) / len(quiz_scores_map)
        body_html += f"""
        <div class="card summary-card">
            <h3>Session Mastery Summary</h3>
            <table class="overview-table">
                <tr><td><strong>Comprehension Quiz Average:</strong></td><td>{avg_score:.0%}</td></tr>
                <tr><td><strong>Milestone Completion Rate:</strong></td><td>100% ({total_steps}/{total_steps} steps)</td></tr>
                <tr><td><strong>Total Experience Earned:</strong></td><td>+{xp_earned} XP</td></tr>
            </table>
        </div>
        """

    body_html += '<p class="footer-note">Generated by EduTechAI — Your AI-Powered Learning Companion</p>'

    styled_html = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <style>
            @page {{
                size: a4;
                margin: 14mm 12mm 14mm 12mm;
            }}
            body {{
                font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
                font-size: 9.5pt;
                line-height: 1.5;
                color: #1E293B;
                margin: 0;
                padding: 0;
            }}
            /* ── App Brand Header (Pure CSS vector, zero raw emojis) ── */
            .logo-table {{
                width: 100%;
                border: none;
                margin-bottom: 14px;
                border-bottom: 2px solid #4F46E5;
                padding-bottom: 8px;
            }}
            .logo-brand {{
                font-size: 20pt;
                font-weight: bold;
                color: #0F172A;
                letter-spacing: -0.5px;
            }}
            .logo-brand-accent {{
                color: #4F46E5;
            }}
            .logo-brand-ai {{
                color: #2563EB;
            }}
            .logo-badge {{
                font-size: 7.5pt;
                background-color: #EEF2FF;
                color: #4F46E5;
                border: 1px solid #C7D2FE;
                padding: 2px 6px;
                border-radius: 4px;
                font-weight: bold;
                vertical-align: middle;
                margin-left: 6px;
            }}
            .logo-subtitle {{
                font-size: 8.5pt;
                color: #64748B;
                margin-top: 2px;
                font-weight: 500;
            }}
            .logo-meta {{
                font-size: 8pt;
                color: #64748B;
                line-height: 1.4;
                text-align: right;
            }}
            /* ── Typography & Headings ── */
            h2 {{
                color: #1E293B;
                font-size: 13pt;
                font-weight: bold;
                margin-top: 16px;
                margin-bottom: 8px;
                page-break-after: avoid;
            }}
            h3 {{
                color: #4F46E5;
                font-size: 11pt;
                font-weight: bold;
                margin-top: 12px;
                margin-bottom: 4px;
                page-break-after: avoid;
            }}
            h4 {{
                color: #334155;
                font-size: 9.5pt;
                font-weight: bold;
                margin-top: 10px;
                margin-bottom: 3px;
                page-break-after: avoid;
            }}
            p {{
                margin: 0 0 6px 0;
            }}
            .objective-box {{
                background-color: #F8FAFC;
                border-left: 3px solid #6366F1;
                padding: 5px 8px;
                font-size: 8.5pt;
                color: #475569;
                margin-bottom: 8px;
            }}
            /* ── Badges ── */
            .badge-success {{
                font-size: 7.5pt;
                background-color: #ECFDF5;
                color: #059669;
                border: 1px solid #A7F3D0;
                padding: 1px 5px;
                border-radius: 3px;
                font-weight: bold;
            }}
            .badge-danger {{
                font-size: 7.5pt;
                background-color: #FEF2F2;
                color: #DC2626;
                border: 1px solid #FECACA;
                padding: 1px 5px;
                border-radius: 3px;
                font-weight: bold;
            }}
            .badge-muted {{
                font-size: 7.5pt;
                background-color: #F1F5F9;
                color: #64748B;
                padding: 1px 5px;
                border-radius: 3px;
            }}
            /* ── Code Blocks (Monospace + background card) ── */
            pre {{
                background-color: #F8FAFC;
                border: 1px solid #E2E8F0;
                border-left: 3px solid #4F46E5;
                padding: 6px 8px;
                font-family: Courier, monospace;
                font-size: 8pt;
                line-height: 1.4;
                color: #0F172A;
                white-space: pre-wrap;
                margin: 6px 0 8px 0;
            }}
            code {{
                font-family: Courier, monospace;
                font-size: 8pt;
                background-color: #F1F5F9;
                padding: 1px 3px;
            }}
            /* ── Tables ── */
            table {{
                border-collapse: collapse;
                width: 100%;
                margin-top: 4px;
                margin-bottom: 8px;
                page-break-inside: avoid;
            }}
            th, td {{
                border: 1px solid #E2E8F0;
                padding: 4px 8px;
                text-align: left;
                font-size: 8.5pt;
            }}
            th {{
                background-color: #F8FAFC;
                color: #334155;
                font-weight: bold;
            }}
            /* ── Quiz Card Layout ── */
            .quiz-card {{
                border: 1px solid #E2E8F0;
                background-color: #FAFAFA;
                padding: 6px 8px;
                margin-bottom: 6px;
                border-radius: 4px;
                page-break-inside: avoid;
            }}
            .quiz-q-title {{
                font-size: 9pt;
                color: #0F172A;
                margin-bottom: 4px;
            }}
            .quiz-ans-table {{
                margin: 0;
                background-color: #FFFFFF;
            }}
            .quiz-ans-table td {{
                border: 1px solid #EEF2FF;
                padding: 3px 6px;
                font-size: 8pt;
            }}
            /* ── Lists & Dividers ── */
            ol, ul {{
                margin: 0 0 6px 0;
                padding-left: 16px;
            }}
            li {{
                margin-bottom: 2px;
                font-size: 8.5pt;
            }}
            .milestone-divider {{
                border: none;
                border-top: 1px solid #E2E8F0;
                margin: 12px 0;
            }}
            .footer-note {{
                font-size: 8pt;
                color: #94A3B8;
                text-align: center;
                margin-top: 14px;
            }}
        </style>
    </head>
    <body>
        <!-- Header -->
        <table class="logo-table">
            <tr>
                <td style="border: none; padding: 0; vertical-align: middle;">
                    <div class="logo-brand">
                        <span class="logo-brand-accent">EduTech</span><span class="logo-brand-ai">AI</span>
                        <span class="logo-badge">MASTERED JOURNEY</span>
                    </div>
                    <div class="logo-subtitle">
                        AI-Powered Learning Mastery &amp; Comprehensive Study Guide
                    </div>
                </td>
                <td style="border: none; padding: 0; vertical-align: middle;" class="logo-meta">
                    <strong>Status:</strong> <span style="color: #059669; font-weight: bold;">100% Completed</span><br/>
                    <strong>Exported:</strong> {datetime.now().strftime('%B %d, %Y')}
                </td>
            </tr>
        </table>

        <!-- Body -->
        {body_html}
    </body>
    </html>
    """

    pdf_buffer = io.BytesIO()
    pisa_status = pisa.CreatePDF(io.StringIO(styled_html), dest=pdf_buffer)

    if pisa_status.err:
        raise Exception("Failed to generate PDF")

    return pdf_buffer.getvalue()


def generate_html(memory) -> str:
    """Generate a modern, responsive, executive-grade standalone HTML document with browser print capability."""
    steps = _get_attr(memory, "steps", []) or []
    total_steps = len(steps)
    completed_steps = sum(
        1 for s in steps
        if (getattr(s, "status", None) and (
            s.status.value == "complete" if hasattr(s.status, "value") else str(s.status) == "complete"
        )) or (_get_attr(s, "status") == "complete")
    )
    student_level = _get_attr(memory, "student_level", "general")
    topic = _get_attr(memory, "topic", "Learning Session")
    xp_earned = _get_attr(memory, "xp_earned", 0)
    streak_count = _get_attr(memory, "streak_count", 0)
    quiz_scores_map = _get_attr(memory, "quiz_scores", {}) or {}
    mode_raw = _get_attr(memory, "learning_mode", "visual")
    mode_str = mode_raw.value if hasattr(mode_raw, "value") else str(mode_raw)

    topic_esc = html.escape(str(topic))
    mode_esc = html.escape(str(mode_str.replace("_", " ").title()))
    level_esc = html.escape(str(student_level).replace("_", " ").title())
    date_str = datetime.now().strftime("%B %d, %Y at %I:%M %p")

    # Render milestones
    milestones_html = ""
    for step in steps:
        step_idx = _get_attr(step, "index", 0)
        title = html.escape(str(_get_attr(step, "title", f"Step {step_idx + 1}")))
        description = html.escape(str(_get_attr(step, "description", "")))
        est_min = _get_attr(step, "estimated_minutes", 5)

        milestones_html += f"""
        <section class="milestone-card">
            <div class="milestone-header">
                <span class="milestone-tag">Milestone {step_idx + 1}</span>
                <h3 class="milestone-name">{title}</h3>
                <span class="mastered-pill">Mastered</span>
            </div>
        """

        if description:
            milestones_html += f"""
            <div class="objective-callout">
                <div class="callout-icon">🎯</div>
                <div><strong>Objective:</strong> {description} <span class="est-time">• Est. {est_min} min</span></div>
            </div>
            """

        explanation = _get_attr(step, "tutor_explanation", "")
        if explanation:
            explanation_clean = re.sub(r"```mermaid\s*\n.*?```", "", explanation, flags=re.DOTALL)
            exp_html = markdown.markdown(explanation_clean, extensions=["tables", "fenced_code"])
            # Format code blocks with language badge
            exp_html = re.sub(
                r"<p><code>(?:([a-zA-Z0-9_\-]+)\n)?(.*?)</code></p>",
                r'<div class="code-wrapper"><span class="code-badge">\1</span><pre><code>\2</code></pre></div>',
                exp_html,
                flags=re.DOTALL,
            )
            milestones_html += f"""
            <div class="content-block">
                <h4>🎓 Key Conceptual Takeaways</h4>
                <div class="explanation-body">{exp_html}</div>
            </div>
            """

        socratic_qs = _get_attr(step, "socratic_questions", []) or []
        if socratic_qs:
            milestones_html += """
            <div class="content-block">
                <h4>💡 Reflection &amp; Socratic Prompts</h4>
                <ul class="socratic-items">
            """
            for q in socratic_qs:
                milestones_html += f"<li>{html.escape(str(q))}</li>"
            milestones_html += "</ul></div>"

        videos = _get_attr(step, "videos", []) or []
        if videos:
            milestones_html += """
            <div class="content-block">
                <h4>🎬 Recommended Video Clips</h4>
                <div class="video-grid">
            """
            for vid in videos[:3]:
                v_title = html.escape(str(_get_attr(vid, "title", "Video Clip")))
                v_channel = html.escape(str(_get_attr(vid, "channel", "YouTube")))
                v_video_id = _get_attr(vid, "video_id", "")
                v_ts = _get_attr(vid, "start_time", 0) or _get_attr(vid, "timestamp_seconds", 0)
                v_url = _get_attr(vid, "url", "") or _get_attr(vid, "timestamp_url", "")
                if not v_url and v_video_id:
                    v_url = f"https://www.youtube.com/watch?v={v_video_id}&t={int(v_ts or 0)}"
                v_url_esc = html.escape(v_url)
                v_exp = _get_attr(vid, "timestamp_explanation", "") or _get_attr(vid, "relevance_snippet", "")
                if any(bad in v_exp.lower() for bad in ["bootcamp", "discount", "$", "code ", "off "]):
                    v_exp = ""
                snippet = f'<p class="video-snippet">{html.escape(v_exp[:120])}...</p>' if v_exp else ""

                milestones_html += f"""
                <div class="video-card">
                    <a href="{v_url_esc}" target="_blank" rel="noopener" class="video-link">
                        <span class="play-icon">▶</span>
                        <div>
                            <div class="video-title">{v_title}</div>
                            <div class="video-channel">{v_channel}</div>
                        </div>
                    </a>
                    {snippet}
                </div>
                """
            milestones_html += "</div></div>"

        # Quizzes
        quiz_data = _get_attr(step, "quiz", []) or []
        quiz_score = _get_attr(step, "quiz_score", None)
        if quiz_score is None:
            quiz_score = quiz_scores_map.get(step_idx, quiz_scores_map.get(str(step_idx), None))

        user_answers = _get_attr(step, "user_answers", {}) or {}
        user_full_answers = _get_attr(step, "user_full_answers", {}) or {}

        if quiz_data and isinstance(quiz_data, list) and len(quiz_data) > 0:
            score_str = f"{quiz_score:.0%}" if quiz_score is not None else "100%"
            milestones_html += f"""
            <div class="content-block">
                <div class="quiz-header-row">
                    <h4>📝 Comprehension Quiz Results</h4>
                    <span class="quiz-score-pill">Score: {score_str}</span>
                </div>
                <div class="quiz-deck">
            """
            for qi, q_item in enumerate(quiz_data):
                q_text = html.escape(str(_get_attr(q_item, "question", f"Question {qi + 1}")))
                correct_ans = html.escape(str(_get_attr(q_item, "correct_answer", "")))
                explanation_text = html.escape(str(_get_attr(q_item, "explanation", "")))

                student_ans = (
                    user_full_answers.get(qi)
                    or user_full_answers.get(str(qi))
                    or user_answers.get(qi)
                    or user_answers.get(str(qi))
                    or "—"
                )
                student_ans_clean = str(student_ans).strip()
                is_correct = (
                    student_ans_clean.lower() == str(correct_ans).strip().lower()
                    if student_ans_clean != "—"
                    else False
                )
                status_class = "correct" if is_correct else ("wrong" if student_ans_clean != "—" else "skipped")
                status_label = "Correct" if is_correct else ("Incorrect" if student_ans_clean != "—" else "Skipped")

                milestones_html += f"""
                <div class="interactive-quiz-item {status_class}">
                    <div class="q-title-row">
                        <span class="q-num">Q{qi + 1}</span>
                        <span class="q-text">{q_text}</span>
                        <span class="q-badge {status_class}">{status_label}</span>
                    </div>
                    <div class="q-answers-grid">
                        <div class="ans-box user-box">
                            <span class="ans-label">Your Answer:</span>
                            <span class="ans-val">{html.escape(student_ans_clean)}</span>
                        </div>
                        <div class="ans-box correct-box">
                            <span class="ans-label">Correct Answer:</span>
                            <span class="ans-val">{correct_ans}</span>
                        </div>
                    </div>
                    {"<div class='q-exp-box'><strong>Insight:</strong> " + explanation_text + "</div>" if explanation_text else ""}
                </div>
                """
            milestones_html += "</div></div>"

        milestones_html += "</section>"

    # Average score
    avg_score_str = "100%"
    if quiz_scores_map:
        avg_score = sum(quiz_scores_map.values()) / len(quiz_scores_map)
        avg_score_str = f"{avg_score:.0%}"

    return f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{topic_esc} — EduTechAI Learning Journey</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <style>
        :root {{
            --primary: #4F46E5;
            --primary-dark: #3730A3;
            --primary-light: #EEF2FF;
            --success: #059669;
            --success-light: #ECFDF5;
            --danger: #DC2626;
            --danger-light: #FEF2F2;
            --slate-900: #0F172A;
            --slate-800: #1E293B;
            --slate-700: #334155;
            --slate-600: #475569;
            --slate-500: #64748B;
            --slate-200: #E2E8F0;
            --slate-100: #F1F5F9;
            --slate-50: #F8FAFC;
        }}
        * {{
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }}
        body {{
            font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif;
            background-color: #F8FAFC;
            color: var(--slate-800);
            line-height: 1.6;
            -webkit-font-smoothing: antialiased;
        }}
        /* ── Sticky Action Bar (Hidden in Print) ── */
        .top-action-bar {{
            position: sticky;
            top: 0;
            z-index: 100;
            background: rgba(15, 23, 42, 0.92);
            backdrop-filter: blur(12px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            color: #FFFFFF;
            padding: 12px 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }}
        .brand-cluster {{
            display: flex;
            align-items: center;
            gap: 10px;
        }}
        .brand-logo {{
            font-size: 1.25rem;
            font-weight: 800;
            letter-spacing: -0.5px;
        }}
        .brand-accent {{
            color: #818CF8;
        }}
        .badge-report {{
            font-size: 0.75rem;
            background: rgba(99, 102, 241, 0.2);
            color: #C7D2FE;
            border: 1px solid rgba(129, 140, 248, 0.4);
            padding: 2px 8px;
            border-radius: 9999px;
            font-weight: 600;
        }}
        .action-buttons {{
            display: flex;
            gap: 12px;
        }}
        .btn {{
            font-family: inherit;
            font-size: 0.875rem;
            font-weight: 600;
            padding: 8px 16px;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            border: none;
        }}
        .btn-print {{
            background: var(--primary);
            color: #FFFFFF;
        }}
        .btn-print:hover {{
            background: var(--primary-dark);
            transform: translateY(-1px);
        }}
        .btn-download {{
            background: rgba(255, 255, 255, 0.12);
            color: #FFFFFF;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }}
        .btn-download:hover {{
            background: rgba(255, 255, 255, 0.2);
        }}
        /* ── Page Container ── */
        .container {{
            max-width: 900px;
            margin: 32px auto;
            padding: 0 20px;
        }}
        /* ── Hero Banner ── */
        .hero-card {{
            background: #FFFFFF;
            border-radius: 16px;
            padding: 32px;
            border: 1px solid var(--slate-200);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -2px rgba(0, 0, 0, 0.05);
            margin-bottom: 28px;
        }}
        .hero-title {{
            font-size: 1.85rem;
            font-weight: 800;
            color: var(--slate-900);
            letter-spacing: -0.5px;
            margin-bottom: 8px;
        }}
        .hero-meta {{
            color: var(--slate-500);
            font-size: 0.875rem;
            margin-bottom: 20px;
        }}
        .metrics-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
            gap: 16px;
            margin-top: 20px;
            border-top: 1px solid var(--slate-200);
            padding-top: 20px;
        }}
        .metric-card {{
            background: var(--slate-50);
            border-radius: 10px;
            padding: 12px 16px;
            border: 1px solid var(--slate-200);
        }}
        .metric-title {{
            font-size: 0.75rem;
            text-transform: uppercase;
            font-weight: 700;
            color: var(--slate-500);
            letter-spacing: 0.5px;
        }}
        .metric-value {{
            font-size: 1.15rem;
            font-weight: 800;
            color: var(--slate-900);
            margin-top: 2px;
        }}
        /* ── Milestone Cards ── */
        .milestone-card {{
            background: #FFFFFF;
            border-radius: 16px;
            padding: 28px;
            border: 1px solid var(--slate-200);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.04);
            margin-bottom: 24px;
        }}
        .milestone-header {{
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 16px;
            flex-wrap: wrap;
        }}
        .milestone-tag {{
            font-size: 0.8rem;
            font-weight: 700;
            background: var(--primary-light);
            color: var(--primary);
            padding: 4px 10px;
            border-radius: 6px;
        }}
        .milestone-name {{
            font-size: 1.35rem;
            font-weight: 700;
            color: var(--slate-900);
            flex: 1;
        }}
        .mastered-pill {{
            font-size: 0.75rem;
            font-weight: 700;
            background: var(--success-light);
            color: var(--success);
            padding: 4px 10px;
            border-radius: 9999px;
            border: 1px solid #A7F3D0;
        }}
        .objective-callout {{
            background: var(--slate-50);
            border-left: 4px solid var(--primary);
            padding: 12px 16px;
            border-radius: 0 8px 8px 0;
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 0.95rem;
            color: var(--slate-700);
            margin-bottom: 20px;
        }}
        .content-block {{
            margin-top: 20px;
        }}
        .content-block h4 {{
            font-size: 1.05rem;
            font-weight: 700;
            color: var(--slate-900);
            margin-bottom: 10px;
            border-bottom: 1px solid var(--slate-200);
            padding-bottom: 6px;
        }}
        .explanation-body {{
            font-size: 0.95rem;
            color: var(--slate-700);
            line-height: 1.7;
        }}
        .explanation-body p {{
            margin-bottom: 12px;
        }}
        /* ── Code Blocks ── */
        .code-wrapper {{
            position: relative;
            margin: 14px 0;
            border-radius: 10px;
            background: #0F172A;
            overflow: hidden;
            border: 1px solid #334155;
        }}
        .code-badge {{
            position: absolute;
            top: 8px;
            right: 12px;
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.75rem;
            color: #94A3B8;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }}
        pre {{
            margin: 0;
            padding: 16px 20px;
            overflow-x: auto;
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.9rem;
            color: #38BDF8;
            line-height: 1.5;
        }}
        /* ── Quizzes ── */
        .quiz-header-row {{
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 12px;
        }}
        .quiz-score-pill {{
            font-size: 0.8rem;
            font-weight: 700;
            background: var(--primary-light);
            color: var(--primary);
            padding: 3px 10px;
            border-radius: 6px;
        }}
        .interactive-quiz-item {{
            background: var(--slate-50);
            border-radius: 12px;
            padding: 16px;
            border: 1px solid var(--slate-200);
            margin-bottom: 12px;
        }}
        .interactive-quiz-item.correct {{
            border-left: 4px solid var(--success);
        }}
        .interactive-quiz-item.wrong {{
            border-left: 4px solid var(--danger);
        }}
        .q-title-row {{
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 12px;
        }}
        .q-num {{
            font-weight: 800;
            color: var(--primary);
            font-size: 0.9rem;
        }}
        .q-text {{
            font-weight: 600;
            color: var(--slate-900);
            flex: 1;
        }}
        .q-badge {{
            font-size: 0.75rem;
            font-weight: 700;
            padding: 2px 8px;
            border-radius: 4px;
        }}
        .q-badge.correct {{
            background: var(--success-light);
            color: var(--success);
        }}
        .q-badge.wrong {{
            background: var(--danger-light);
            color: var(--danger);
        }}
        .q-answers-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 10px;
            margin-bottom: 10px;
        }}
        .ans-box {{
            padding: 8px 12px;
            border-radius: 8px;
            font-size: 0.875rem;
            background: #FFFFFF;
            border: 1px solid var(--slate-200);
        }}
        .ans-label {{
            font-weight: 600;
            color: var(--slate-500);
            display: block;
            font-size: 0.75rem;
            margin-bottom: 2px;
        }}
        .ans-val {{
            font-weight: 700;
            color: var(--slate-900);
        }}
        .q-exp-box {{
            font-size: 0.85rem;
            color: var(--slate-600);
            background: #FFFFFF;
            padding: 8px 12px;
            border-radius: 6px;
            border: 1px dashed var(--slate-200);
        }}
        /* ── Videos ── */
        .video-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 12px;
        }}
        .video-card {{
            background: var(--slate-50);
            border: 1px solid var(--slate-200);
            border-radius: 10px;
            padding: 12px;
        }}
        .video-link {{
            text-decoration: none;
            color: var(--slate-900);
            display: flex;
            align-items: flex-start;
            gap: 10px;
        }}
        .play-icon {{
            background: #EF4444;
            color: #FFFFFF;
            border-radius: 50%;
            width: 28px;
            height: 28px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.75rem;
            flex-shrink: 0;
        }}
        .video-title {{
            font-weight: 700;
            font-size: 0.85rem;
            line-height: 1.3;
        }}
        .video-channel {{
            font-size: 0.75rem;
            color: var(--slate-500);
            margin-top: 2px;
        }}
        /* ── Summary & Footer ── */
        .summary-card {{
            background: linear-gradient(135deg, #4F46E5 0%, #3730A3 100%);
            color: #FFFFFF;
            border-radius: 16px;
            padding: 32px;
            margin-bottom: 32px;
        }}
        .summary-card h3 {{
            color: #FFFFFF;
            font-size: 1.5rem;
            margin-bottom: 16px;
        }}
        .summary-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 16px;
        }}
        .summary-metric {{
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(8px);
            padding: 14px 18px;
            border-radius: 10px;
            border: 1px solid rgba(255, 255, 255, 0.15);
        }}
        .summary-metric-val {{
            font-size: 1.5rem;
            font-weight: 800;
        }}
        .page-footer {{
            text-align: center;
            color: var(--slate-500);
            font-size: 0.875rem;
            padding: 24px 0 40px 0;
        }}
        /* ── Print Stylesheet ── */
        @media print {{
            .no-print {{
                display: none !important;
            }}
            body {{
                background: #FFFFFF !important;
                color: #0F172A !important;
                font-size: 10pt;
            }}
            .container {{
                max-width: 100% !important;
                margin: 0 !important;
                padding: 0 !important;
            }}
            .hero-card, .milestone-card, .summary-card {{
                box-shadow: none !important;
                border: 1px solid #CBD5E1 !important;
                page-break-inside: avoid;
                margin-bottom: 16px !important;
            }}
            .summary-card {{
                background: #F8FAFC !important;
                color: #0F172A !important;
            }}
            .summary-card h3 {{
                color: #0F172A !important;
            }}
            .summary-metric {{
                background: #FFFFFF !important;
                color: #0F172A !important;
                border: 1px solid #CBD5E1 !important;
            }}
            @page {{
                size: A4;
                margin: 15mm 12mm 15mm 12mm;
            }}
        }}
    </style>
</head>
<body>
    <!-- Top Action Bar -->
    <header class="top-action-bar no-print">
        <div class="brand-cluster">
            <span class="brand-logo">⚡ EduTech<span class="brand-accent">AI</span></span>
            <span class="badge-report">Interactive Study Report</span>
        </div>
        <div class="action-buttons">
            <button class="btn btn-print" onclick="window.print()">
                🖨️ Print / Save as PDF
            </button>
            <button class="btn btn-download" onclick="downloadCurrentHtml()">
                📥 Download HTML
            </button>
        </div>
    </header>

    <div class="container">
        <!-- Hero Banner -->
        <header class="hero-card">
            <h1 class="hero-title">{topic_esc}</h1>
            <p class="hero-meta">Exported on {date_str} • 100% Mastered Journey</p>
            <div class="metrics-grid">
                <div class="metric-card">
                    <div class="metric-title">Learning Mode</div>
                    <div class="metric-value">{mode_esc}</div>
                </div>
                <div class="metric-card">
                    <div class="metric-title">Student Level</div>
                    <div class="metric-value">{level_esc}</div>
                </div>
                <div class="metric-card">
                    <div class="metric-title">Milestones</div>
                    <div class="metric-value">{completed_steps}/{total_steps}</div>
                </div>
                <div class="metric-card">
                    <div class="metric-title">XP Earned</div>
                    <div class="metric-value">+{xp_earned} XP</div>
                </div>
                <div class="metric-card">
                    <div class="metric-title">Streak</div>
                    <div class="metric-value">{streak_count} Days</div>
                </div>
            </div>
        </header>

        <!-- Milestones List -->
        {milestones_html}

        <!-- Final Summary -->
        <footer class="summary-card">
            <h3>🏆 Session Mastery Summary</h3>
            <div class="summary-grid">
                <div class="summary-metric">
                    <div class="metric-title" style="color: rgba(255,255,255,0.8);">Quiz Score Average</div>
                    <div class="summary-metric-val">{avg_score_str}</div>
                </div>
                <div class="summary-metric">
                    <div class="metric-title" style="color: rgba(255,255,255,0.8);">Completion Rate</div>
                    <div class="summary-metric-val">100%</div>
                </div>
                <div class="summary-metric">
                    <div class="metric-title" style="color: rgba(255,255,255,0.8);">Total Experience</div>
                    <div class="summary-metric-val">+{xp_earned} XP</div>
                </div>
            </div>
        </footer>

        <p class="page-footer">Generated by EduTechAI — Your AI-Powered Learning Companion</p>
    </div>

    <script>
        function downloadCurrentHtml() {{
            const blob = new Blob([document.documentElement.outerHTML], {{ type: 'text/html' }});
            const a = document.createElement('a');
            a.href = URL.createObjectURL(blob);
            a.download = 'session_study_guide.html';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
        }}
    </script>
</body>
</html>"""


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
    Export the learning session as a clean, branded PDF file.
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


@router.get(
    "/{session_id}/html",
    response_class=HTMLResponse,
    dependencies=[Depends(require_privilege(ET_EXPORT_MARKDOWN, ET_EXPORT_PDF))],
)
async def export_session_html(
    session_id: str,
    current_user: User = Depends(get_current_user),
):
    """
    Export the learning session as an interactive, standalone HTML document.
    Requires ET_EXPORT_MARKDOWN or ET_EXPORT_PDF privilege (Pro/Ultra).
    Only available when the learning session is 100% completed.
    """
    memory = await get_session_or_404(session_id)
    if memory.user_id != current_user.id:
        raise NotFoundException(error_code="SESSION_NOT_FOUND", errors="Session not found.")

    check_session_completed(memory)

    html_content = generate_html(memory)
    return HTMLResponse(
        content=html_content,
        headers={"Content-Disposition": f'inline; filename="session_{session_id}.html"'},
    )
