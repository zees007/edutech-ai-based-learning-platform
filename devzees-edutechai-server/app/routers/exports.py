from __future__ import annotations

import base64
import html
import io
import json
import logging
import re
from datetime import datetime

import asyncio
import httpx
from fastapi import APIRouter, Depends
from fastapi.responses import HTMLResponse, PlainTextResponse, Response
import markdown
from xhtml2pdf import pisa

from app.dependencies import get_current_user, require_privilege
from app.exceptions import BadRequestException, NotFoundException
from app.privileges_config import ET_EXPORT_HTML, ET_EXPORT_MARKDOWN, ET_EXPORT_PDF
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


LEVEL_ICONS = {
    1: "🧭",
    2: "🔍",
    3: "⚡",
    4: "🧠",
    5: "📚",
    6: "🎯",
    7: "🔮",
    8: "🏛️",
    9: "💡",
    10: "👑",
}


def _calculate_level_and_grade(xp_earned: int, quiz_scores_map: dict | None = None) -> dict:
    """Calculate the student's gamification level title and academic performance grade."""
    from services.gamification import calculate_level

    level_info = calculate_level(xp_earned or 0)
    level_num = level_info.get("level", 1)
    level_title = level_info.get("title", "Curious Explorer")
    level_icon = LEVEL_ICONS.get(level_num, "🌟")

    letter_grade = "A+"
    if quiz_scores_map and len(quiz_scores_map) > 0:
        avg = sum(quiz_scores_map.values()) / len(quiz_scores_map)
        if avg >= 0.90:
            letter_grade = "A+"
        elif avg >= 0.80:
            letter_grade = "A"
        elif avg >= 0.70:
            letter_grade = "B"
        elif avg >= 0.60:
            letter_grade = "C"
        else:
            letter_grade = "Pass"

    return {
        "level": level_num,
        "title": level_title,
        "icon": level_icon,
        "grade": letter_grade,
        "display": f"{level_icon} {level_title}",
        "badge": f"Level {level_num} • Grade {letter_grade}",
        "clean_title": level_title,
    }


# ── Math Unicode symbols that should be preserved in PDF text fallback ──
_MATH_UNICODE_MAP = {
    "\u2211": "sum",       # ∑
    "\u220F": "prod",      # ∏
    "\u222B": "int",       # ∫
    "\u221A": "sqrt",      # √
    "\u221E": "inf",       # ∞
    "\u2202": "d",         # ∂
    "\u2207": "nabla",     # ∇
    "\u2208": "in",        # ∈
    "\u2209": "not in",    # ∉
    "\u2260": "!=",        # ≠
    "\u2264": "<=",        # ≤
    "\u2265": ">=",        # ≥
    "\u00D7": "x",        # ×
    "\u00F7": "/",        # ÷
    "\u00B1": "+/-",      # ±
    "\u2248": "~=",        # ≈
    "\u2261": "==",        # ≡
    "\u2282": "subset",   # ⊂
    "\u2283": "superset", # ⊃
    "\u222A": "union",    # ∪
    "\u2229": "intersect",# ∩
    "\u2192": "->",       # →
    "\u2190": "<-",       # ←
    "\u21D2": "=>",       # ⇒
    "\u21D0": "<=",       # ⇐
    "\u2200": "forall",   # ∀
    "\u2203": "exists",   # ∃
    "\u03B1": "alpha",    # α
    "\u03B2": "beta",     # β
    "\u03B3": "gamma",    # γ
    "\u03B4": "delta",    # δ
    "\u03B5": "epsilon",  # ε
    "\u03B8": "theta",    # θ
    "\u03BB": "lambda",   # λ
    "\u03BC": "mu",       # μ
    "\u03C0": "pi",       # π
    "\u03C3": "sigma",    # σ
    "\u03C6": "phi",      # φ
    "\u03C9": "omega",    # ω
}


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

    # 4. Convert known math Unicode to ASCII-safe equivalents
    for k, v in _MATH_UNICODE_MAP.items():
        text = text.replace(k, v)

    # 5. Remove any remaining characters outside standard Latin-1 / ASCII (e.g. Indic, Asian, emoji symbols)
    cleaned = []
    for ch in text:
        cp = ord(ch)
        if cp in (9, 10, 13) or (32 <= cp <= 126) or (160 <= cp <= 255):
            cleaned.append(ch)
        elif cp > 255:
            # Drop unrenderable Unicode characters
            continue
    return "".join(cleaned)


# ── Mermaid keywords used for detection ──────────────────────────
_MERMAID_KEYWORDS = (
    r"graph\s+[A-Z]{2}",
    r"flowchart\s+[A-Z]{2}",
    r"sequenceDiagram",
    r"classDiagram",
    r"stateDiagram(?:-v2)?",
    r"erDiagram",
    r"gantt",
    r"pie",
    r"mindmap",
    r"gitGraph",
)
_MERMAID_KEYWORDS_RE = "|".join(_MERMAID_KEYWORDS)


def _sanitize_mermaid_syntax(m_code: str) -> str:
    """Fix LLM hallucinated unclosed pipe string syntax (e.g. A -->|"text" B instead of A -->|"text"| B)"""
    return re.sub(r'(-->\|"[^"]+")(\s*[a-zA-Z0-9_]+)', r'\1|\2', m_code)


def _sanitize_math_tex(content: str) -> str:
    """
    Sanitize raw TeX to fix LLM hallucinations based on established patterns.
    Only fixes genuinely broken patterns — preserves valid LaTeX constructs.
    """
    clean = content
    # Fix: collapse 3+ consecutive backslashes into a proper \\ (line-break)
    # but leave single \ and double \\ untouched (they are valid TeX)
    clean = re.sub(r'\\{3,}', r'\\\\', clean)
    # Fix: remove spurious \\ immediately before \end{...} (LLM hallucination)
    clean = re.sub(r'\\\\\s*(?=\\end\{)', '\n', clean)
    return clean


def _sanitize_math_blocks(text: str) -> str:
    """Find all math blocks in text and sanitize their LaTeX content."""
    if not text:
        return text

    def replacer(match):
        return _sanitize_math_tex(match.group(0))

    # 1. $$ ... $$
    text = re.sub(r'\$\$[\s\S]+?\$\$', replacer, text)
    # 2. \[ ... \]
    text = re.sub(r'\\\[[\s\S]+?\\\]', replacer, text)
    # 3. ```math or ```latex
    text = re.sub(r'```(?:math|latex)\s*\n[\s\S]+?```', replacer, text)
    # 4. \begin{...} ... \end{...}
    text = re.sub(r'\\begin\{[a-zA-Z0-9_\*]+\}[\s\S]+?\\end\{[a-zA-Z0-9_\*]+\}', replacer, text)

    return text


# ── Mappings for LaTeX inline math conversion to HTML in PDFs ───────
_LATEX_GREEK_MAP = {
    r'\alpha': '&alpha;',
    r'\beta': '&beta;',
    r'\gamma': '&gamma;',
    r'\Gamma': '&Gamma;',
    r'\delta': '&delta;',
    r'\Delta': '&Delta;',
    r'\epsilon': '&epsilon;',
    r'\varepsilon': '&epsilon;',
    r'\zeta': '&zeta;',
    r'\eta': '&eta;',
    r'\theta': '&theta;',
    r'\Theta': '&Theta;',
    r'\iota': '&iota;',
    r'\kappa': '&kappa;',
    r'\lambda': '&lambda;',
    r'\Lambda': '&Lambda;',
    r'\mu': '&mu;',
    r'\nu': '&nu;',
    r'\xi': '&xi;',
    r'\Xi': '&Xi;',
    r'\pi': '&pi;',
    r'\Pi': '&Pi;',
    r'\rho': '&rho;',
    r'\sigma': '&sigma;',
    r'\Sigma': '&Sigma;',
    r'\tau': '&tau;',
    r'\upsilon': '&upsilon;',
    r'\phi': '&phi;',
    r'\varphi': '&phi;',
    r'\Phi': '&Phi;',
    r'\chi': '&chi;',
    r'\psi': '&psi;',
    r'\Psi': '&Psi;',
    r'\omega': '&omega;',
    r'\Omega': '&Omega;',
}

_LATEX_SYMBOL_MAP = {
    r'\rightarrow': '&rarr;',
    r'\leftarrow': '&larr;',
    r'\Rightarrow': '&rArr;',
    r'\Leftarrow': '&lArr;',
    r'\leftrightarrow': '&harr;',
    r'\Leftrightarrow': '&hArr;',
    r'\to': '&rarr;',
    r'\times': '&times;',
    r'\div': '&divide;',
    r'\pm': '&plusmn;',
    r'\mp': '&#8723;',
    r'\leq': '&le;',
    r'\geq': '&ge;',
    r'\neq': '&ne;',
    r'\le': '&le;',
    r'\ge': '&ge;',
    r'\ne': '&ne;',
    r'\approx': '&asymp;',
    r'\equiv': '&equiv;',
    r'\sim': '~',
    r'\propto': '&prop;',
    r'\infty': '&infin;',
    r'\notin': '&notin;',
    r'\in': '&isin;',
    r'\subseteq': '&sube;',
    r'\subset': '&sub;',
    r'\cup': '&cup;',
    r'\cap': '&cap;',
    r'\forall': '&forall;',
    r'\exists': '&exist;',
    r'\nabla': '&nabla;',
    r'\partial': '&part;',
    r'\cdot': '&sdot;',
    r'\cdots': '&hellip;',
    r'\dots': '&hellip;',
    r'\ldots': '&hellip;',
    r'\mid': '|',
    r'\parallel': '||',
    r'\setminus': '\\',
    r'\mathbb{R}': '<b>R</b>',
    r'\mathbb{N}': '<b>N</b>',
    r'\mathbb{Z}': '<b>Z</b>',
    r'\mathbb{C}': '<b>C</b>',
    r'\mathbb{E}': '<b>E</b>',
    r'\sum': '&sum;',
    r'\prod': '&prod;',
    r'\int': '&int;',
    r'\langle': '&lang;',
    r'\rangle': '&rang;',
    r'\quad': '&nbsp;&nbsp;',
    r'\qquad': '&nbsp;&nbsp;&nbsp;&nbsp;',
    r'\top': '&#8868;',
    r'\prime': '&prime;',
    r'\Pr': 'Pr',
    r'\log': 'log',
    r'\exp': 'exp',
    r'\sin': 'sin',
    r'\cos': 'cos',
    r'\tan': 'tan',
    r'\max': 'max',
    r'\min': 'min',
    r'\arg': 'arg',
}

_SORTED_LATEX_SYMBOLS = sorted(_LATEX_SYMBOL_MAP.items(), key=lambda x: len(x[0]), reverse=True)
_SORTED_LATEX_GREEK = sorted(_LATEX_GREEK_MAP.items(), key=lambda x: len(x[0]), reverse=True)


def latex_inline_to_html(tex: str) -> str:
    """
    Convert an inline LaTeX formula (e.g. `\\sigma`, `\\pi_\\phi`, `R_\\theta`, `\\mathcal{S}`)
    into cleanly formatted HTML with Greek entities, subscripts, superscripts, and math typography.
    Avoids external network calls and renders sharply in xhtml2pdf / ReportLab.
    """
    s = tex.strip()
    if s.startswith(r'\(') and s.endswith(r'\)'):
        s = s[2:-2].strip()
    elif s.startswith('$') and s.endswith('$'):
        s = s[1:-1].strip()

    # Normalize delimiters
    s = s.replace(r'\bigl(', '(').replace(r'\bigr)', ')')
    s = s.replace(r'\Bigl(', '(').replace(r'\Bigr)', ')')
    s = s.replace(r'\left(', '(').replace(r'\right)', ')')
    s = s.replace(r'\left[', '[').replace(r'\right]', ']')
    s = s.replace(r'\left\{', '{').replace(r'\right\}', '}')
    s = s.replace(r'\{', '{').replace(r'\}', '}')

    # Fractions \frac{a}{b} -> (a)/(b) and \sqrt{x} -> √(x)
    s = re.sub(r'\\frac\{([^}]+)\}\{([^}]+)\}', r'(\1)/(\2)', s)
    s = re.sub(r'\\sqrt\{([^}]+)\}', r'&radic;(\1)', s)

    # Styles
    s = re.sub(r'\\mathcal\{([A-Za-z0-9]+)\}', r'<span class="math-cal">\1</span>', s)
    s = re.sub(r'\\mathbf\{([A-Za-z0-9]+)\}', r'<b>\1</b>', s)
    s = re.sub(r'\\mathrm\{([A-Za-z0-9]+)\}', r'\1', s)
    s = re.sub(r'\\text\{([A-Za-z0-9\s]+)\}', r'\1', s)
    s = re.sub(r'\\hat\{([A-Za-z0-9])\}', r'\1&#770;', s)

    # Symbols & Greek (longest first to avoid prefix collisions)
    for k, v in _SORTED_LATEX_SYMBOLS:
        s = re.sub(re.escape(k) + r'(?![a-zA-Z])', lambda _, val=v: val, s)
    for k, v in _SORTED_LATEX_GREEK:
        s = re.sub(re.escape(k) + r'(?![a-zA-Z])', lambda _, val=v: val, s)

    # Prime: w' -> w&prime;
    s = re.sub(r"([a-zA-Z0-9_]+)'", r'\1&prime;', s)

    # Subscripts and Superscripts
    s = re.sub(r'_\{([^}]+)\}', lambda m: f"<sub>{html.escape(m.group(1))}</sub>", s)
    s = re.sub(r'\^\{([^}]+)\}', lambda m: f"<sup>{html.escape(m.group(1))}</sup>", s)
    s = re.sub(r'_(&[a-zA-Z0-9#]+;|[a-zA-Z0-9])', r'<sub>\1</sub>', s)
    s = re.sub(r'\^(&[a-zA-Z0-9#]+;|[a-zA-Z0-9])', r'<sup>\1</sup>', s)

    # Clean whitespace and lingering commands
    s = s.replace(r'\,', ' ').replace(r'\;', ' ').replace(r'\!', '').replace(r'\quad', ' ')
    s = re.sub(r'\\[a-zA-Z]+', '', s)
    s = s.strip()

    return f'<span class="math-inline-pdf">{s}</span>'


def format_inline_math_for_pdf(text: str) -> str:
    r"""Format inline LaTeX math delimiters \(...\) and $...$ into crisp HTML math typography for PDF."""
    if not text:
        return text
    # 1. \( ... \) (inline math)
    text = re.sub(r'\\\(([\s\S]+?)\\\)', lambda m: latex_inline_to_html(m.group(1)), text)
    # 2. $...$ (inline math, single-line only, avoiding $$)
    text = re.sub(r'(?<!\$)\$(?!\$)(.+?)(?<!\$)\$(?!\$)', lambda m: latex_inline_to_html(m.group(1)), text)
    return text


async def _render_mermaid_as_image(m_code: str) -> str | None:
    """
    Render a Mermaid diagram to a PNG image via the Mermaid Ink API.
    Returns a base64-encoded PNG data URI string, or None on failure.
    """
    try:
        # Build a Mermaid Ink config payload for a clean light-themed render
        payload = {
            "code": m_code.strip(),
            "mermaid": {
                "theme": "default",
                "themeVariables": {
                    "fontFamily": "Helvetica, Arial, sans-serif",
                    "fontSize": "14px",
                    "primaryColor": "#EEF2FF",
                    "primaryBorderColor": "#6366F1",
                    "primaryTextColor": "#1E1B4B",
                    "lineColor": "#64748B",
                    "secondaryColor": "#F0FDF4",
                    "tertiaryColor": "#FEF3C7",
                },
            },
        }
        # Mermaid Ink expects base64-encoded JSON in the URL path
        payload_json = json.dumps(payload, ensure_ascii=True)
        encoded = base64.urlsafe_b64encode(payload_json.encode("utf-8")).decode("ascii")
        url = f"https://mermaid.ink/img/{encoded}"

        async with httpx.AsyncClient(timeout=4.0) as client:
            resp = await client.get(url)
            if resp.status_code == 200 and len(resp.content) > 200:
                img_b64 = base64.b64encode(resp.content).decode("ascii")
                return f"data:image/png;base64,{img_b64}"

        logger.warning("Mermaid Ink API returned non-200 or empty image, using fallback.")
        return None
    except Exception as e:
        logger.warning(f"Mermaid Ink API call failed, using fallback: {e}")
        return None


async def _render_math_as_image(math_code: str) -> str | None:
    """
    Render LaTeX math to a PNG image via CodeCogs API.
    Returns a base64-encoded PNG data URI string, or None on failure.
    """
    try:
        import urllib.parse
        clean_code = math_code.strip()
        # Normalizations for CodeCogs compatibility
        clean_code = clean_code.replace(r'\bigl(', '(').replace(r'\bigr)', ')')
        clean_code = clean_code.replace(r'\Bigl(', '(').replace(r'\Bigr)', ')')
        clean_code = clean_code.replace(r'\left(', '(').replace(r'\right)', ')')
        clean_code = re.sub(r"([a-zA-Z0-9_]+)'", r"\1^{\\prime}", clean_code)
        clean_code = re.sub(r'\\text\{([^}]+)\}', r'\\mathrm{\1}', clean_code)
        clean_code = clean_code.replace(r'\mid', '|')

        encoded = urllib.parse.quote(clean_code)
        url = f"https://latex.codecogs.com/png.image?\\dpi{{150}}\\bg_white\\;{encoded}"
        
        async with httpx.AsyncClient(timeout=3.0) as client:
            resp = await client.get(url)
            if resp.status_code == 200 and len(resp.content) > 100:
                img_b64 = base64.b64encode(resp.content).decode("ascii")
                return f"data:image/png;base64,{img_b64}"

        return None
    except Exception as e:
        logger.warning(f"Math image API call failed, using fallback: {e}")
        return None


def _render_mermaid_fallback_for_pdf(m_code: str) -> str:
    """
    Parse Mermaid flowchart code into a styled visual flow table for PDF.
    Used as a fallback when the Mermaid Ink API is unavailable.
    Extracts nodes and transitions into structured table rows with styled
    node boxes and arrow connectors, with proper deduplication.
    """
    lines = [line.strip() for line in m_code.strip().split("\n") if line.strip()]
    transitions: list[tuple[str, str, str]] = []
    node_labels: dict[str, str] = {}

    # Extended node label patterns:
    # A["Label"], A["Label (info)"], A(["Label"]), A(Label), A{Label}, A>Label]
    node_patterns = [
        r'([a-zA-Z0-9_\-]+)\s*\[\s*"(.*?)"\s*\]',          # A["Label"]
        r'([a-zA-Z0-9_\-]+)\s*\[\s*([^"\]]+?)\s*\]',       # A[Label]
        r'([a-zA-Z0-9_\-]+)\s*\(\s*\[\s*"(.*?)"\s*\]\s*\)', # A(["Label"])
        r'([a-zA-Z0-9_\-]+)\s*\(\s*\[\s*([^"\]]+?)\s*\]\s*\)',  # A([Label])
        r'([a-zA-Z0-9_\-]+)\s*\(\s*"(.*?)"\s*\)',          # A("Label")
        r'([a-zA-Z0-9_\-]+)\s*\(\s*([^"\)]+?)\s*\)',       # A(Label)
        r'([a-zA-Z0-9_\-]+)\s*\{\s*"(.*?)"\s*\}',          # A{"Label"}
        r'([a-zA-Z0-9_\-]+)\s*\{\s*([^"\}]+?)\s*\}',       # A{Label}
    ]

    for line in lines:
        for pattern in node_patterns:
            for match in re.finditer(pattern, line):
                nid = match.group(1)
                lbl = match.group(2)
                if lbl and nid not in node_labels:
                    node_labels[nid] = lbl.strip()

    # Extract edges: A --> B, A --> B["Label"], A["Label"] --> B, A -->|label| B, A ==> B, A -.-> B
    # The node label definition (e.g. ["Label"], (Label), {Label}) can appear between the
    # source node ID and the arrow, so we need to skip over it.
    edge_pattern = re.compile(
        r'([a-zA-Z0-9_\-]+)'           # src node ID
        r'(?:\s*(?:\[.*?\]|\(.*?\)|\{.*?\}))?'  # optional node label definition (skip)
        r'\s*(?:--+>|=+>|-\.+->)'       # arrow
        r'(?:\|\s*"?(.*?)"?\s*\|)?'     # optional edge label
        r'\s*'
        r'([a-zA-Z0-9_\-]+)'           # dst node ID
    )
    for line in lines:
        for match in edge_pattern.finditer(line):
            src = match.group(1)
            edge_lbl = (match.group(2) or "").strip()
            dst = match.group(3)
            src_name = node_labels.get(src, src)
            dst_name = node_labels.get(dst, dst)
            transitions.append((src_name, edge_lbl, dst_name))

    if transitions:
        flow_rows = []
        rendered_nodes: set[str] = set()
        for i, (src, edge_lbl, dst) in enumerate(transitions):
            # Only render the source node if it hasn't been rendered yet
            if src not in rendered_nodes:
                s_esc = html.escape(_sanitize_text_for_pdf(src))
                flow_rows.append(f'<tr><td class="flow-node-cell"><strong>{s_esc}</strong></td></tr>')
                rendered_nodes.add(src)
            # Arrow with optional edge label
            arrow_txt = f'&darr; <em>{html.escape(_sanitize_text_for_pdf(edge_lbl))}</em>' if edge_lbl else '&darr;'
            flow_rows.append(f'<tr><td class="flow-arrow-cell">{arrow_txt}</td></tr>')
            # Destination node
            if dst not in rendered_nodes:
                d_esc = html.escape(_sanitize_text_for_pdf(dst))
                flow_rows.append(f'<tr><td class="flow-node-cell"><strong>{d_esc}</strong></td></tr>')
                rendered_nodes.add(dst)

        return f'<table class="flow-sequence-table">{"".join(flow_rows)}</table>'
    else:
        clean_code = html.escape(_sanitize_text_for_pdf(m_code.strip()))
        return f'<pre class="diagram-code-box"><code>{clean_code}</code></pre>'


def _normalize_markdown_diagrams(text: str) -> str:
    """Ensure any Mermaid diagrams (flowcharts, sequence diagrams, etc.) are enclosed in standard ```mermaid ... ``` code blocks."""
    if not text:
        return text

    # Protect existing code blocks and collect them
    fenced_blocks: list[str] = []

    def _save_block(m):
        idx = len(fenced_blocks)
        fenced_blocks.append(m.group(0))
        return f"@@MD_BLOCK_{idx}@@"

    processed = re.sub(r"```[\s\S]*?```", _save_block, text)

    # 1. Detect unfenced mermaid diagrams (bare mermaid keywords not inside code blocks)
    #    Match: optional blank line(s), then a mermaid keyword, then content until next
    #    blank-line-followed-by-non-whitespace, or heading, or end-of-string.
    mermaid_unfenced = re.compile(
        r"(?:^|\n\s*\n|\n)\s*(" + _MERMAID_KEYWORDS_RE + r")"
        r"([\s\S]*?)"
        r"(?=\n\s*\n\S|\n\s*\n#|\n@@MD_BLOCK_|$)",
        re.IGNORECASE,
    )
    processed = mermaid_unfenced.sub(r"\n\n```mermaid\n\1\2\n```\n\n", processed)

    # 2. Restore fenced blocks, normalizing their language tags
    for idx, block in enumerate(fenced_blocks):
        clean_block = block
        # ```flowchart ... ``` → ```mermaid ... ```
        clean_block = re.sub(
            r"^```flowchart\b",
            "```mermaid",
            clean_block,
            flags=re.MULTILINE,
        )
        # ``` (no language) with mermaid content → ```mermaid
        clean_block = re.sub(
            r"^```\s*\n\s*(" + _MERMAID_KEYWORDS_RE + r")",
            r"```mermaid\n\1",
            clean_block,
            flags=re.IGNORECASE | re.MULTILINE,
        )
        processed = processed.replace(f"@@MD_BLOCK_{idx}@@", clean_block)

    return _sanitize_mermaid_syntax(processed)


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
    level_grade_data = _calculate_level_and_grade(xp_earned, quiz_scores_map)
    md += "### 📊 Journey Overview\n\n"
    md += "| Metric | Details |\n"
    md += "|---|---|\n"
    md += f"| **Learning Mode** | {mode_str.replace('_', ' ').title()} |\n"
    md += f"| **Student Level** | {str(student_level).replace('_', ' ').title()} |\n"
    md += f"| **Level Grade** | {level_grade_data['display']} ({level_grade_data['badge']}) |\n"
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

        md += f"### Step {step_idx + 1}: {title} ✅\n\n"
        if description:
            md += f"**Objective:** {description} *(Est. {est_min} min)*\n\n"

        # ── Socratic Explanation ──
        explanation = _get_attr(step, "tutor_explanation", None)
        if explanation:
            # For Markdown export, preserve LaTeX as-is (MD viewers/renderers handle it natively)
            # Only normalize Mermaid diagrams, do NOT sanitize math content
            norm_exp = _normalize_markdown_diagrams(explanation.strip())
            md += f"#### 🎓 Key Conceptual Takeaways\n\n{norm_exp}\n\n"


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


async def generate_pdf(memory) -> bytes:
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
    level_grade_data = _calculate_level_and_grade(xp_earned, quiz_scores_map)
    level_title_clean = _sanitize_text_for_pdf(level_grade_data["clean_title"])
    level_badge_clean = _sanitize_text_for_pdf(level_grade_data["badge"])

    # Build PDF Body HTML with clean non-list containers for Quizzes and pre-blocks for code
    body_html = ""

    # 1. Hero Overview Banner & Metrics Table (Matches HTML design)
    body_html += f"""
    <table class="hero-banner-table">
        <tr>
            <td colspan="6" class="hero-header-cell">
                <div class="hero-title">{topic_clean}</div>
                <div class="hero-subtitle">Exported on {datetime.now().strftime('%B %d, %Y')} &bull; 100% Mastered Journey</div>
            </td>
        </tr>
        <tr>
            <td class="hero-metric-cell">
                <div class="metric-label">Learning Mode</div>
                <div class="metric-val">{mode_clean}</div>
            </td>
            <td class="hero-metric-cell">
                <div class="metric-label">Student Level</div>
                <div class="metric-val">{level_clean}</div>
            </td>
            <td class="hero-metric-cell highlight-level-pdf">
                <div class="metric-label">Level Grade</div>
                <div class="metric-val">{level_title_clean}</div>
                <div class="metric-sub-pdf">{level_badge_clean}</div>
            </td>
            <td class="hero-metric-cell">
                <div class="metric-label">Milestones</div>
                <div class="metric-val">{completed_steps}/{total_steps}</div>
            </td>
            <td class="hero-metric-cell">
                <div class="metric-label">XP Earned</div>
                <div class="metric-val">+{xp_earned} XP</div>
            </td>
            <td class="hero-metric-cell">
                <div class="metric-label">Streak</div>
                <div class="metric-val">{streak_count} Days</div>
            </td>
        </tr>
    </table>
    """

    # 2. Executive Milestone Roadmap Table (Mirrors HTML Learning Journey Milestone Path)
    if len(steps) >= 2:
        path_rows = []
        for si, st in enumerate(steps):
            s_title = _get_attr(st, "title", f"Step {si + 1}")
            s_title_clean = html.escape(_sanitize_text_for_pdf(str(s_title)))
            path_rows.append(f"""
            <tr>
                <td class="path-step-col">
                    <table class="path-inner-table">
                        <tr>
                            <td class="path-num-cell">STEP {si + 1}</td>
                            <td class="path-title-cell">{s_title_clean}</td>
                            <td class="path-badge-cell">[100% Mastered]</td>
                        </tr>
                    </table>
                </td>
            </tr>
            """)
            path_rows.append('<tr><td class="path-arrow-col">&darr;</td></tr>')

        path_rows.append("""
        <tr>
            <td class="path-step-col">
                <table class="path-mastered-table">
                    <tr>
                        <td class="path-mastered-cell">
                            <strong>JOURNEY MASTERED</strong> &bull; All milestones completed with comprehensive retention
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        """)

        body_html += f"""
        <table class="roadmap-table-pdf">
            <tr>
                <td class="roadmap-header-cell">
                    <span class="roadmap-badge">[Roadmap]</span>
                    <span class="roadmap-heading">Learning Journey Milestone Path</span>
                </td>
            </tr>
            <tr>
                <td class="roadmap-body-cell">
                    <table class="roadmap-path-table">
                        {"".join(path_rows)}
                    </table>
                </td>
            </tr>
        </table>
        """

    # 3. Milestones
    body_html += '<h2 class="section-title">Mastered Steps</h2>'

    # Pre-scan all steps to fetch all Mermaid and Math images concurrently across the document
    step_prepared_data = []
    all_mermaid_tasks = []
    all_math_tasks = []

    for step in steps:
        explanation = _get_attr(step, "tutor_explanation", "")
        math_pdf_blocks = []
        mermaid_blocks = []
        cleaned_math = []

        if explanation:
            explanation = _sanitize_math_blocks(explanation)

            def _extract_math_pdf(match):
                idx = len(math_pdf_blocks)
                math_pdf_blocks.append(match.group(0))
                return f"\n\n<!--MATH_PDF_PLACEHOLDER_{idx}-->\n\n"

            # 1. ```math / ```latex fenced blocks
            explanation = re.sub(r'```(?:math|latex)\s*\n([\s\S]+?)```', _extract_math_pdf, explanation)
            # 2. \begin{...} ... \end{...} environments
            explanation = re.sub(r'\\begin\{[a-zA-Z0-9_\*]+\}[\s\S]+?\\end\{[a-zA-Z0-9_\*]+\}', _extract_math_pdf, explanation)
            # 3. $$ ... $$ (display math)
            explanation = re.sub(r'\$\$([\s\S]+?)\$\$', _extract_math_pdf, explanation)
            # 4. \[ ... \] (display math)
            explanation = re.sub(r'\\\[([\s\S]+?)\\\]', _extract_math_pdf, explanation)

            # Format inline math cleanly in-line with math typography
            explanation = format_inline_math_for_pdf(explanation)

            def _extract_mermaid_pdf(match):
                idx = len(mermaid_blocks)
                mermaid_blocks.append(match.group(1).strip())
                return f"\n\n<!--MERMAID_PLACEHOLDER_{idx}-->\n\n"

            explanation_clean = re.sub(
                r"```(?:mermaid|flowchart)[^\n]*\n(.*?)```",
                _extract_mermaid_pdf,
                explanation,
                flags=re.DOTALL,
            )

            for mb in math_pdf_blocks:
                c = mb
                c = re.sub(r'^\$\$|\$\$$', '', c)
                c = re.sub(r'^\\\[|\\\]$', '', c)
                c = re.sub(r'^\\\(|\\\)$', '', c)
                c = re.sub(r'^\$|\$$', '', c)
                c = re.sub(r'^```(?:math|latex)\s*\n|```$', '', c)
                cleaned_math.append(c.strip())
        else:
            explanation_clean = ""

        step_prepared_data.append({
            "explanation_clean": explanation_clean,
            "math_blocks": math_pdf_blocks,
            "cleaned_math": cleaned_math,
            "mermaid_blocks": mermaid_blocks,
        })
        for m in mermaid_blocks:
            all_mermaid_tasks.append(_render_mermaid_as_image(_sanitize_mermaid_syntax(m)))
        for cm in cleaned_math:
            all_math_tasks.append(_render_math_as_image(cm))

    # Fetch ALL mermaid and math images concurrently for the entire document
    all_mermaid_uris, all_math_uris = await asyncio.gather(
        asyncio.gather(*all_mermaid_tasks) if all_mermaid_tasks else asyncio.sleep(0, result=[]),
        asyncio.gather(*all_math_tasks) if all_math_tasks else asyncio.sleep(0, result=[]),
    )

    mermaid_ptr = 0
    math_ptr = 0

    for step_idx, step in enumerate(steps):
        prep = step_prepared_data[step_idx]
        title = format_inline_math_for_pdf(_sanitize_text_for_pdf(_get_attr(step, "title", f"Step {step_idx + 1}")))
        description = format_inline_math_for_pdf(_sanitize_text_for_pdf(_get_attr(step, "description", "")))
        est_min = _get_attr(step, "estimated_minutes", 5)

        body_html += f"""
        <div class="milestone-block">
            <table class="milestone-header-table">
                <tr>
                    <td class="milestone-header-left">
                        <span class="milestone-badge">STEP {step_idx + 1}</span>
                        <span class="milestone-heading">{title}</span>
                    </td>
                    <td class="milestone-header-right">
                        <span class="badge-success">100% Mastered</span>
                    </td>
                </tr>
            </table>
        """

        if description:
            body_html += f'<div class="objective-box"><strong>Objective:</strong> {description} <em>(Est. {est_min} min)</em></div>'

        # Tutor explanation
        explanation_clean = prep["explanation_clean"]
        if explanation_clean:
            sanitized_exp = _sanitize_text_for_pdf(explanation_clean)

            # Convert to markdown with fenced_code and tables
            exp_html = markdown.markdown(sanitized_exp, extensions=["tables", "fenced_code"])
            # Normalize code blocks to <pre><code>
            exp_html = re.sub(
                r"<p><code>(?:[a-zA-Z0-9_\-]+\n)?(.*?)</code></p>",
                r"<pre><code>\1</code></pre>",
                exp_html,
                flags=re.DOTALL,
            )

            # Re-inject Mermaid diagrams as executive PDF diagram cards
            for m_idx, m_code in enumerate(prep["mermaid_blocks"]):
                m_code = _sanitize_mermaid_syntax(m_code)
                m_uri = all_mermaid_uris[mermaid_ptr] if mermaid_ptr < len(all_mermaid_uris) else None
                mermaid_ptr += 1
                if m_uri:
                    diagram_rendered = (
                        f'<div style="text-align: center; padding: 6px 0;">'
                        f'<img src="{m_uri}" class="mermaid-image" />'
                        f'</div>'
                    )
                else:
                    diagram_rendered = _render_mermaid_fallback_for_pdf(m_code)

                diagram_card = f"""
                <table class="diagram-card-pdf">
                    <tr>
                        <td class="diagram-header-cell">
                            <span class="diagram-badge">[Architecture]</span>
                            <span class="diagram-heading">Concept Architecture &amp; Flowchart</span>
                        </td>
                    </tr>
                    <tr>
                        <td class="diagram-body-cell">
                            {diagram_rendered}
                        </td>
                    </tr>
                </table>
                """
                exp_html = re.sub(
                    rf"(?:<p>)?<!--MERMAID_PLACEHOLDER_{m_idx}-->(?:</p>)?",
                    lambda _, c=diagram_card: c,
                    exp_html,
                )

            # Re-inject Math diagrams as executive PDF images
            for m_idx, (math_code, cleaned_code) in enumerate(zip(prep["math_blocks"], prep["cleaned_math"])):
                math_img_uri = all_math_uris[math_ptr] if math_ptr < len(all_math_uris) else None
                math_ptr += 1
                if math_img_uri:
                    math_rendered = (
                        f'<div style="text-align: center; padding: 6px 0;">'
                        f'<img src="{math_img_uri}" class="mermaid-image" />'
                        f'</div>'
                    )
                else:
                    sanitized_fallback = _sanitize_text_for_pdf(cleaned_code)
                    math_rendered = (
                        f'<div class="math-fallback-box">'
                        f'<code>{html.escape(sanitized_fallback)}</code>'
                        f'</div>'
                    )

                exp_html = re.sub(
                    rf"(?:<p>)?<!--MATH_PDF_PLACEHOLDER_{m_idx}-->(?:</p>)?",
                    lambda _, r=math_rendered: r,
                    exp_html,
                )

            body_html += f'<h4 class="subhead">Key Conceptual Takeaways</h4><div class="explanation-content">{exp_html}</div>'


        # Recommended Video Clips
        videos = _get_attr(step, "videos", []) or []
        if videos:
            body_html += "<h4 class='subhead'>Recommended Video Clips</h4><table class='video-table'>"
            for vid in videos:
                v_title = _sanitize_text_for_pdf(_get_attr(vid, "title", "Video Clip"))
                v_channel = _sanitize_text_for_pdf(_get_attr(vid, "channel", "YouTube"))
                
                v_video_id = _get_attr(vid, "video_id", "")
                v_ts = _get_attr(vid, "start_time", 0) or _get_attr(vid, "timestamp_seconds", 0)
                v_url = _get_attr(vid, "url", "") or _get_attr(vid, "timestamp_url", "")
                if not v_url and v_video_id:
                    v_url = f"https://www.youtube.com/watch?v={v_video_id}&t={int(v_ts or 0)}"
                v_url_clean = html.escape(v_url) if v_url else ""

                v_exp = _sanitize_text_for_pdf(_get_attr(vid, "timestamp_explanation", "") or _get_attr(vid, "relevance_snippet", ""))
                if any(bad in v_exp.lower() for bad in ["bootcamp", "discount", "$", "code ", "off "]):
                    v_exp = ""
                snippet = f"<br/><small style='color: #64748B;'>{v_exp[:110]}...</small>" if v_exp else ""
                
                url_display = f"<br/><small style='color: #4F46E5;'>&#128279; <a href='{v_url_clean}' style='color: #4F46E5; text-decoration: none;'>{v_url_clean}</a></small>" if v_url_clean else ""
                title_display = f"<a href='{v_url_clean}' style='color: inherit; text-decoration: none;'><strong>{v_title}</strong></a>" if v_url_clean else f"<strong>{v_title}</strong>"
                
                body_html += f"<tr><td class='video-cell'><span class='video-tag'>VIDEO</span> {title_display} &mdash; <em>{v_channel}</em>{snippet}{url_display}</td></tr>"
            body_html += "</table>"

        # Academic Papers
        step_papers = _get_attr(step, "papers", []) or []
        if step_papers:
            body_html += "<h4 class='subhead'>Academic Research Papers</h4><ul class='paper-list'>"
            for paper in step_papers[:2]:
                p_title = _sanitize_text_for_pdf(_get_attr(paper, "title", "Research Paper"))
                p_authors = _get_attr(paper, "authors", [])
                p_year = _get_attr(paper, "year", None)
                year_str = f" ({p_year})" if p_year else ""
                authors_str = _sanitize_text_for_pdf(", ".join(p_authors[:2])) if p_authors else "Scholarly Source"
                body_html += f"<li><strong>{p_title}</strong>{year_str} &mdash; <em>{authors_str}</em></li>"
            body_html += "</ul>"

        # Comprehension Quiz (Table structure matching interactive cards in HTML)
        quiz_data = _get_attr(step, "quiz", []) or []
        quiz_score = _get_attr(step, "quiz_score", None)
        if quiz_score is None:
            quiz_score = quiz_scores_map.get(step_idx, quiz_scores_map.get(str(step_idx), None))

        user_answers = _get_attr(step, "user_answers", {}) or {}
        user_full_answers = _get_attr(step, "user_full_answers", {}) or {}

        if quiz_data and isinstance(quiz_data, list) and len(quiz_data) > 0:
            score_str = f"{quiz_score:.0%}" if quiz_score is not None else "100%"
            body_html += f"<h4 class='subhead'>Comprehension Quiz Results (Score: {score_str})</h4>"
            for qi, q_item in enumerate(quiz_data):
                q_text = format_inline_math_for_pdf(_sanitize_text_for_pdf(_get_attr(q_item, "question", f"Question {qi + 1}")))
                correct_ans = format_inline_math_for_pdf(_sanitize_text_for_pdf(str(_get_attr(q_item, "correct_answer", ""))))
                explanation_text = format_inline_math_for_pdf(_sanitize_text_for_pdf(_get_attr(q_item, "explanation", "")))

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
                    <table class="quiz-title-table">
                        <tr>
                            <td class="q-title-left"><span class="q-num">Q{qi + 1}</span> <strong>{q_text}</strong></td>
                            <td class="q-title-right">{status_badge}</td>
                        </tr>
                    </table>
                    <table class="quiz-ans-table">
                        <tr>
                            <td style="width: 25%; color: #64748B;"><strong>Your Answer:</strong></td>
                            <td>{student_ans_clean}</td>
                        </tr>
                        <tr>
                            <td style="color: #64748B;"><strong>Correct Answer:</strong></td>
                            <td><strong style="color: #059669;">{correct_ans}</strong></td>
                        </tr>
                        {"<tr><td colspan='2' class='quiz-exp-cell'><small style='color: #475569;'><em>Explanation:</em> " + explanation_text + "</small></td></tr>" if explanation_text else ""}
                    </table>
                </div>
                """

        body_html += "</div><hr class='milestone-divider'/>"

    # 3. Session Mastery Summary (Matching HTML 3-metric summary card)
    if quiz_scores_map:
        avg_score = sum(quiz_scores_map.values()) / len(quiz_scores_map)
        avg_score_str = f"{avg_score:.0%}"
    else:
        avg_score_str = "100%"

    body_html += f"""
    <table class="summary-card-table">
        <tr>
            <td colspan="3" class="summary-card-header">
                <h3>Session Mastery Summary</h3>
            </td>
        </tr>
        <tr>
            <td class="summary-metric-col">
                <div class="summary-metric-label">Quiz Score Average</div>
                <div class="summary-metric-val">{avg_score_str}</div>
            </td>
            <td class="summary-metric-col">
                <div class="summary-metric-label">Completion Rate</div>
                <div class="summary-metric-val">100%</div>
            </td>
            <td class="summary-metric-col">
                <div class="summary-metric-label">Total Experience</div>
                <div class="summary-metric-val">+{xp_earned} XP</div>
            </td>
        </tr>
    </table>
    """

    body_html += '<p class="footer-note">Generated by EduTechAI &mdash; Your AI-Powered Learning Companion</p>'

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
            /* ── App Brand Header ── */
            .logo-table {{
                width: 100%;
                border: none;
                margin-bottom: 12px;
                border-bottom: 2px solid #4F46E5;
                padding-bottom: 8px;
            }}
            .logo-brand {{
                font-size: 18pt;
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
            /* ── Hero Banner Card (Mirrors HTML Hero Card) ── */
            .hero-banner-table {{
                width: 100%;
                border: 1px solid #CBD5E1;
                background-color: #0F172A;
                border-radius: 6px;
                margin-bottom: 16px;
                page-break-inside: avoid;
            }}
            .hero-header-cell {{
                border: none;
                padding: 12px 14px 10px 14px;
                color: #FFFFFF;
                border-bottom: 1px solid #334155;
            }}
            .hero-title {{
                font-size: 15pt;
                font-weight: bold;
                color: #FFFFFF;
                margin-bottom: 2px;
            }}
            .hero-subtitle {{
                font-size: 8.5pt;
                color: #94A3B8;
            }}
            .hero-metric-cell {{
                border: none;
                background-color: #1E293B;
                padding: 8px 10px;
                text-align: center;
                border-right: 1px solid #334155;
            }}
            .highlight-level-pdf {{
                background-color: #312E81 !important;
                border: 1px solid #6366F1 !important;
            }}
            .metric-sub-pdf {{
                font-size: 6.5pt;
                color: #A5B4FC;
                margin-top: 2px;
                font-weight: bold;
            }}
            .metric-label {{
                font-size: 7.5pt;
                color: #94A3B8;
                text-transform: uppercase;
                margin-bottom: 2px;
                font-weight: 600;
            }}
            .metric-val {{
                font-size: 11pt;
                font-weight: bold;
                color: #38BDF8;
            }}
            /* ── Roadmap Table (Mirrors HTML Journey Milestone Path) ── */
            .roadmap-table-pdf {{
                width: 100%;
                border: 1px solid #CBD5E1;
                background-color: #FFFFFF;
                border-radius: 6px;
                margin-bottom: 14px;
                page-break-inside: avoid;
            }}
            .roadmap-header-cell {{
                background-color: #F8FAFC;
                border: none;
                border-bottom: 1px solid #E2E8F0;
                padding: 7px 10px;
            }}
            .roadmap-badge {{
                font-size: 7pt;
                background-color: #EEF2FF;
                color: #4F46E5;
                font-weight: bold;
                padding: 2px 5px;
                border-radius: 3px;
                margin-right: 6px;
            }}
            .roadmap-heading {{
                font-size: 9pt;
                font-weight: bold;
                color: #0F172A;
            }}
            .roadmap-body-cell {{
                border: none;
                padding: 8px 12px;
            }}
            .roadmap-path-table {{
                width: 100%;
                border: none;
            }}
            .path-step-col {{
                border: none;
                padding: 0;
            }}
            .path-inner-table {{
                width: 100%;
                background-color: #F8FAFC;
                border: 1px solid #CBD5E1;
                border-radius: 4px;
                padding: 4px 8px;
            }}
            .path-num-cell {{
                border: none;
                font-size: 7pt;
                font-weight: bold;
                color: #4F46E5;
                width: 55px;
            }}
            .path-title-cell {{
                border: none;
                font-size: 8.5pt;
                font-weight: bold;
                color: #1E293B;
            }}
            .path-badge-cell {{
                border: none;
                font-size: 7pt;
                font-weight: bold;
                color: #059669;
                text-align: right;
                width: 100px;
            }}
            .path-arrow-col {{
                border: none;
                text-align: center;
                font-size: 8.5pt;
                font-weight: bold;
                color: #6366F1;
                padding: 1px 0;
            }}
            .path-mastered-table {{
                width: 100%;
                background-color: #ECFDF5;
                border: 1.5px solid #10B981;
                border-radius: 5px;
                padding: 5px 10px;
            }}
            .path-mastered-cell {{
                border: none;
                text-align: center;
                font-size: 8.5pt;
                color: #065F46;
            }}
            /* ── Concept Architecture & Flowchart Cards (Mirrors HTML Mermaid Card) ── */
            .diagram-card-pdf {{
                width: 100%;
                border: 1px solid #CBD5E1;
                background-color: #FFFFFF;
                border-radius: 6px;
                margin: 10px 0;
                page-break-inside: avoid;
            }}
            .diagram-header-cell {{
                background-color: #F8FAFC;
                border: none;
                border-bottom: 1px solid #E2E8F0;
                padding: 6px 10px;
            }}
            .diagram-badge {{
                font-size: 7pt;
                background-color: #EEF2FF;
                color: #4F46E5;
                font-weight: bold;
                padding: 2px 5px;
                border-radius: 3px;
                margin-right: 6px;
            }}
            .diagram-heading {{
                font-size: 8.5pt;
                font-weight: bold;
                color: #0F172A;
            }}
            .diagram-body-cell {{
                border: none;
                padding: 8px 10px;
                background-color: #F8FAFC;
            }}
            .flow-sequence-table {{
                width: 80%;
                border: none;
                margin: 4px auto;
            }}
            .flow-node-cell {{
                background-color: #EEF2FF;
                border: 1.5px solid #6366F1;
                border-radius: 6px;
                padding: 7px 12px;
                font-size: 8.5pt;
                color: #1E1B4B;
                text-align: center;
            }}
            .flow-arrow-cell {{
                border: none;
                text-align: center;
                font-size: 9pt;
                font-weight: bold;
                color: #4F46E5;
                padding: 3px 0;
            }}
            .diagram-code-box {{
                background-color: #0F172A;
                color: #38BDF8;
                padding: 8px 10px;
                border-radius: 4px;
                font-family: monospace;
                font-size: 7.5pt;
            }}
            .mermaid-image {{
                max-width: 100%;
                width: auto;
                height: auto;
                display: block;
                margin: 0 auto;
            }}
            /* ── Inline Math ── */
            .math-inline-pdf {{
                font-family: 'Times-Italic', 'Times-Roman', 'Times', serif;
                font-style: italic;
                font-size: 9.5pt;
                color: #0F172A;
            }}
            .math-inline-pdf sub, .math-inline-pdf sup {{
                font-size: 7pt;
                font-style: normal;
            }}
            .math-cal {{
                font-family: 'Times-Italic', serif;
                font-weight: bold;
                font-style: italic;
            }}
            /* ── Math Fallback (when image rendering fails) ── */
            .math-fallback-box {{
                background-color: #F8FAFC;
                border: 1px solid #CBD5E1;
                border-left: 3px solid #8B5CF6;
                border-radius: 4px;
                padding: 8px 12px;
                margin: 6px 0;
                text-align: center;
                font-family: 'Courier New', Courier, monospace;
                font-size: 8.5pt;
                color: #334155;
                line-height: 1.5;
            }}
            /* ── Section Title ── */
            .section-title {{
                color: #0F172A;
                font-size: 13pt;
                font-weight: bold;
                margin-top: 14px;
                margin-bottom: 10px;
                border-bottom: 2px solid #4F46E5;
                padding-bottom: 4px;
                page-break-after: avoid;
            }}
            /* ── Milestone Cards (Mirrors HTML milestone-card) ── */
            .milestone-block {{
                border: 1px solid #E2E8F0;
                background-color: #FFFFFF;
                border-radius: 6px;
                padding: 10px 12px;
                margin-bottom: 12px;
                page-break-inside: avoid;
            }}
            .milestone-header-table {{
                width: 100%;
                border: none;
                margin: 0 0 6px 0;
            }}
            .milestone-header-left {{
                border: none;
                padding: 0;
            }}
            .milestone-header-right {{
                border: none;
                padding: 0;
                text-align: right;
                width: 100px;
            }}
            .milestone-badge {{
                font-size: 7.5pt;
                background-color: #EEF2FF;
                color: #4F46E5;
                font-weight: bold;
                border: 1px solid #C7D2FE;
                padding: 2px 6px;
                border-radius: 3px;
                margin-right: 6px;
            }}
            .milestone-heading {{
                font-size: 11pt;
                font-weight: bold;
                color: #0F172A;
            }}
            .subhead {{
                color: #334155;
                font-size: 9pt;
                font-weight: bold;
                margin-top: 8px;
                margin-bottom: 3px;
                page-break-after: avoid;
            }}
            .objective-box {{
                background-color: #F8FAFC;
                border-left: 3px solid #6366F1;
                padding: 6px 10px;
                font-size: 8.5pt;
                color: #475569;
                margin-bottom: 8px;
                border-radius: 3px;
            }}
            /* ── Badges ── */
            .badge-success {{
                font-size: 7.5pt;
                background-color: #ECFDF5;
                color: #059669;
                border: 1px solid #A7F3D0;
                padding: 2px 6px;
                border-radius: 3px;
                font-weight: bold;
            }}
            .badge-danger {{
                font-size: 7.5pt;
                background-color: #FEF2F2;
                color: #DC2626;
                border: 1px solid #FECACA;
                padding: 2px 6px;
                border-radius: 3px;
                font-weight: bold;
            }}
            .badge-muted {{
                font-size: 7.5pt;
                background-color: #F1F5F9;
                color: #64748B;
                padding: 2px 6px;
                border-radius: 3px;
            }}
            /* ── Code Blocks ── */
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
            /* ── Quiz Card (Mirrors HTML interactive-quiz-item) ── */
            .quiz-card {{
                border: 1px solid #CBD5E1;
                border-left: 4px solid #4F46E5;
                background-color: #F8FAFC;
                padding: 8px 10px;
                margin-bottom: 6px;
                border-radius: 4px;
                page-break-inside: avoid;
            }}
            .quiz-title-table {{
                width: 100%;
                border: none;
                margin: 0 0 4px 0;
            }}
            .q-title-left {{
                border: none;
                padding: 0;
                font-size: 8.5pt;
                color: #0F172A;
            }}
            .q-title-right {{
                border: none;
                padding: 0;
                text-align: right;
                width: 70px;
            }}
            .q-num {{
                font-weight: bold;
                color: #4F46E5;
                margin-right: 4px;
            }}
            .quiz-ans-table {{
                margin: 0;
                background-color: #FFFFFF;
                border: 1px solid #E2E8F0;
            }}
            .quiz-ans-table td {{
                border: 1px solid #E2E8F0;
                padding: 3px 6px;
                font-size: 8pt;
            }}
            .quiz-exp-cell {{
                background-color: #F8FAFC;
            }}
            /* ── Videos & Papers ── */
            .video-table {{
                width: 100%;
                border: none;
                margin-bottom: 6px;
            }}
            .video-cell {{
                background-color: #F8FAFC;
                border: 1px solid #E2E8F0;
                padding: 5px 8px;
                font-size: 8pt;
            }}
            .video-tag {{
                background-color: #EF4444;
                color: #FFFFFF;
                font-size: 6.5pt;
                font-weight: bold;
                padding: 1px 4px;
                border-radius: 2px;
                margin-right: 4px;
            }}
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
                margin: 10px 0;
            }}
            /* ── Summary Card Table (Mirrors HTML summary-card) ── */
            .summary-card-table {{
                width: 100%;
                border: 1px solid #CBD5E1;
                background-color: #0F172A;
                border-radius: 6px;
                margin-top: 14px;
                margin-bottom: 8px;
                page-break-inside: avoid;
            }}
            .summary-card-header {{
                border: none;
                padding: 8px 12px;
                border-bottom: 1px solid #334155;
            }}
            .summary-card-header h3 {{
                color: #FFFFFF;
                margin: 0;
                font-size: 11pt;
            }}
            .summary-metric-col {{
                border: none;
                background-color: #1E293B;
                padding: 10px;
                text-align: center;
                border-right: 1px solid #334155;
            }}
            .summary-metric-label {{
                font-size: 7.5pt;
                color: #94A3B8;
                text-transform: uppercase;
                margin-bottom: 3px;
                font-weight: 600;
            }}
            .summary-metric-val {{
                font-size: 13pt;
                font-weight: bold;
                color: #38BDF8;
            }}
            .footer-note {{
                font-size: 8pt;
                color: #94A3B8;
                text-align: center;
                margin-top: 12px;
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

    # Calculate Level & Grade achieved
    level_grade_data = _calculate_level_and_grade(xp_earned, quiz_scores_map)
    level_title_esc = html.escape(level_grade_data["title"])
    level_display_esc = html.escape(level_grade_data["display"])
    level_badge_esc = html.escape(level_grade_data["badge"])

    # Generate Journey Roadmap Flowchart
    roadmap_html = ""
    if len(steps) >= 2:
        roadmap_nodes = []
        roadmap_edges = []
        for si, st in enumerate(steps):
            s_title = _get_attr(st, "title", f"Step {si + 1}")
            clean_title = html.escape(str(s_title)).replace('"', "'").replace("\n", " ")
            nid = f"M{si + 1}"
            roadmap_nodes.append(f'        {nid}["{si + 1}. {clean_title} ✅"]:::stepNode')
            if si > 0:
                roadmap_edges.append(f"        M{si} --> {nid}")
        roadmap_edges.append(f'        M{len(steps)} --> FIN(["🏆 Journey Mastered"]):::finishNode')
        roadmap_mermaid_code = (
            "flowchart TD\n"
            "        classDef stepNode fill:#EFF6FF,stroke:#3B82F6,stroke-width:1.5px,color:#1E3A8A,font-weight:600;\n"
            "        classDef finishNode fill:#ECFDF5,stroke:#10B981,stroke-width:2px,color:#065F46,font-weight:700;\n"
            + "\n".join(roadmap_nodes + roadmap_edges)
        )
        roadmap_html = f"""
        <div class="content-block roadmap-block">
            <div class="mermaid-canvas-card">
                <div class="mermaid-header-bar">
                    <span class="mermaid-label">🗺️ Learning Journey Milestone Path</span>
                </div>
                <div class="mermaid-body">
                    <pre class="mermaid">{roadmap_mermaid_code}</pre>
                </div>
            </div>
        </div>
        """

    # Render milestones
    milestones_html = ""
    for step in steps:
        step_idx = _get_attr(step, "index", 0)
        title = html.escape(str(_get_attr(step, "title", f"Step {step_idx + 1}")))
        description = html.escape(str(_get_attr(step, "description", "")))
        est_min = _get_attr(step, "estimated_minutes", 5)

        milestones_html += f"""
        <article class="milestone-card" id="milestone-{step_idx + 1}">
            <div class="milestone-header">
                <span class="milestone-tag">STEP {step_idx + 1}</span>
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
            explanation = _sanitize_math_blocks(explanation)
            # Safely extract Mermaid diagrams before Markdown processing so they are preserved
            mermaid_blocks = []

            def _extract_mermaid(match):
                idx = len(mermaid_blocks)
                mermaid_blocks.append(match.group(1).strip())
                return f"\n\n<!--MERMAID_PLACEHOLDER_{idx}-->\n\n"

            explanation_clean = re.sub(
                r"```(?:mermaid|flowchart)[^\n]*\n(.*?)```",
                _extract_mermaid,
                explanation,
                flags=re.DOTALL,
            )

            # ── Protect ALL math from python-markdown mangling ──
            # python-markdown treats backslashes as escape chars and underscores
            # as emphasis markers — both destroy LaTeX formulas.
            # Strategy: extract all math blocks/inline into placeholders,
            # run markdown, then re-inject the original LaTeX.
            math_placeholders = []

            def _protect_math(match):
                idx = len(math_placeholders)
                raw = match.group(0)
                # If it's a fenced block ```math or ```latex, convert to display math
                if raw.startswith("```"):
                    inner = re.sub(r"^```(?:math|latex)?\s*\n?", "", raw)
                    inner = re.sub(r"\n?```$", "", inner).strip()
                    if inner.startswith(r"\[") and inner.endswith(r"\]"):
                        inner = inner[2:-2].strip()
                    elif inner.startswith("$$") and inner.endswith("$$"):
                        inner = inner[2:-2].strip()
                    formatted = f"\\[{inner}\\]"
                    math_placeholders.append(html.escape(formatted, quote=False))
                else:
                    # Escape < and > so math like w_{<t} is not parsed by the browser as an unclosed HTML tag <t>
                    math_placeholders.append(html.escape(raw, quote=False))
                return f"@@MATH_PH_{idx}@@"

            # 1. Protect ```math / ```latex fenced blocks
            explanation_clean = re.sub(
                r'```(?:math|latex)\s*\n[\s\S]+?```',
                _protect_math, explanation_clean
            )
            # 2. Protect \begin{...} ... \end{...} environments
            explanation_clean = re.sub(
                r'\\begin\{[a-zA-Z0-9_\*]+\}[\s\S]+?\\end\{[a-zA-Z0-9_\*]+\}',
                _protect_math, explanation_clean
            )
            # 3. Protect $$ ... $$ (display math)
            explanation_clean = re.sub(
                r'\$\$[\s\S]+?\$\$',
                _protect_math, explanation_clean
            )
            # 4. Protect \[ ... \] (display math)
            explanation_clean = re.sub(
                r'\\\[[\s\S]+?\\\]',
                _protect_math, explanation_clean
            )
            # 5. Protect \( ... \) (inline math)
            explanation_clean = re.sub(
                r'\\\([\s\S]+?\\\)',
                _protect_math, explanation_clean
            )
            # 6. Protect $...$ (inline math) — single-line only, avoid false positives on currency
            explanation_clean = re.sub(
                r'(?<![\$\\0-9])\$(?!\s)(.+?)(?<!\s)\$(?![0-9\$])',
                _protect_math, explanation_clean
            )

            exp_html = markdown.markdown(explanation_clean, extensions=["tables", "fenced_code"])

            # Restore all math placeholders back into the HTML
            for idx, original_math in enumerate(math_placeholders):
                exp_html = exp_html.replace(f"@@MATH_PH_{idx}@@", original_math)
            # Format code blocks with language badge
            exp_html = re.sub(
                r"<p><code>(?:([a-zA-Z0-9_\-]+)\n)?(.*?)</code></p>",
                r'<div class="code-wrapper"><span class="code-badge">\1</span><pre><code>\2</code></pre></div>',
                exp_html,
                flags=re.DOTALL,
            )

            # Re-inject Mermaid diagrams as interactive cards
            for idx, m_code in enumerate(mermaid_blocks):
                m_code = _sanitize_mermaid_syntax(m_code)
                m_escaped = html.escape(m_code)
                mermaid_card = f"""
                <div class="mermaid-canvas-card">
                    <div class="mermaid-header-bar">
                        <span class="mermaid-label">📐 Concept Architecture &amp; Flowchart</span>
                    </div>
                    <div class="mermaid-body">
                        <pre class="mermaid">{m_escaped}</pre>
                    </div>
                </div>
                """
                exp_html = re.sub(
                    rf"(?:<p>)?<!--MERMAID_PLACEHOLDER_{idx}-->(?:</p>)?",
                    lambda _, card=mermaid_card: card,
                    exp_html,
                )

            milestones_html += f"""
            <div class="content-block">
                <h4>🎓 Key Conceptual Takeaways</h4>
                <div class="explanation-body">{exp_html}</div>
            </div>
            """


        videos = _get_attr(step, "videos", []) or []
        if videos:
            milestones_html += """
            <div class="content-block">
                <h4>🎬 Recommended Video Clips</h4>
                <div class="video-grid">
            """
            for vid in videos:
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
                            <div class="video-channel">{v_channel} <span class="video-url-print">({v_url_esc})</span></div>
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
    <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
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
        .metric-card.highlight-level {{
            background: linear-gradient(135deg, #EEF2FF 0%, #F5F3FF 100%);
            border: 1px solid #C7D2FE;
        }}
        .metric-card.highlight-level .metric-title {{
            color: #4F46E5;
        }}
        .metric-card.highlight-level .metric-value {{
            color: #1E1B4B;
        }}
        .metric-sub {{
            font-size: 0.75rem;
            font-weight: 600;
            color: #4F46E5;
            margin-top: 3px;
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
            .metric-card.highlight-level {{
                background: #F8FAFC !important;
                border: 1px solid #CBD5E1 !important;
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
            .mermaid-canvas-card {{
                page-break-inside: avoid !important;
                break-inside: avoid !important;
                border: 1px solid #CBD5E1 !important;
                background: #FFFFFF !important;
                box-shadow: none !important;
                margin: 14px 0 !important;
            }}
            .mermaid-canvas-card svg {{
                max-width: 100% !important;
                height: auto !important;
            }}
            .video-url-print {{
                display: inline !important;
                font-size: 0.72rem;
                color: #64748B;
                word-break: break-all;
            }}
            mjx-container {{
                page-break-inside: avoid !important;
                break-inside: avoid !important;
                max-width: 100% !important;
            }}
            mjx-container[display="true"] {{
                margin: 14px 0 !important;
                overflow-x: visible !important;
            }}
            @page {{
                size: A4;
                margin: 15mm 12mm 15mm 12mm;
            }}
        }}
        /* ── Mermaid Diagrams ── */
        .mermaid-canvas-card {{
            margin: 18px 0;
            border-radius: 12px;
            background: #FFFFFF;
            border: 1px solid var(--slate-200);
            overflow: hidden;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.03);
            page-break-inside: avoid;
            break-inside: avoid;
        }}
        .mermaid-header-bar {{
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 8px 16px;
            background: #F8FAFC;
            border-bottom: 1px solid var(--slate-200);
        }}
        .mermaid-label {{
            font-size: 0.8rem;
            font-weight: 700;
            color: var(--slate-700);
            display: flex;
            align-items: center;
            gap: 6px;
        }}
        .mermaid-body {{
            padding: 20px;
            display: flex;
            justify-content: center;
            align-items: center;
            overflow-x: auto;
            background: #FFFFFF;
        }}
        .mermaid-body svg {{
            max-width: 100%;
            height: auto !important;
            display: block;
            margin: 0 auto;
        }}
        .video-url-print {{
            display: none;
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
            <button class="btn btn-print" onclick="printDocument()">
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
                <div class="metric-card highlight-level">
                    <div class="metric-title">Level Grade</div>
                    <div class="metric-value">{level_display_esc}</div>
                    <div class="metric-sub">{level_badge_esc}</div>
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
            {roadmap_html}
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
      window.MathJax = {{
        tex: {{
          inlineMath: [['$', '$'], ['\\\\(', '\\\\)']],
          displayMath: [['$$', '$$'], ['\\\\[', '\\\\]']],
          processEscapes: true,
          processEnvironments: true,
          tags: 'ams'
        }},
        options: {{
          skipHtmlTags: ['script', 'noscript', 'style', 'textarea', 'pre', 'code'],
          ignoreHtmlClass: 'mermaid'
        }},
        chtml: {{
          scale: 1
        }}
      }};
    </script>
    <script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
    <script>
        if (window.mermaid) {{
            mermaid.initialize({{
                startOnLoad: true,
                theme: 'neutral',
                securityLevel: 'loose',
                themeVariables: {{
                    fontFamily: 'Plus Jakarta Sans, system-ui, sans-serif',
                    fontSize: '13px',
                    primaryColor: '#EEF2FF',
                    primaryBorderColor: '#6366F1',
                    primaryTextColor: '#1E1B4B'
                }},
                flowchart: {{
                    useMaxWidth: false,
                    htmlLabels: true,
                    curve: 'basis'
                }}
            }});
        }}

        async function printDocument() {{
            if (window.MathJax && MathJax.typesetPromise) {{
                try {{
                    await MathJax.typesetPromise();
                }} catch (e) {{
                    console.warn('MathJax typesetting error before print:', e);
                }}
            }}
            window.print();
        }}

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
        pdf_bytes = await generate_pdf(memory)
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

    check_session_completed(memory)

    html_content = generate_html(memory)
    return HTMLResponse(
        content=html_content,
        headers={"Content-Disposition": f'inline; filename="session_{session_id}.html"'},
    )
