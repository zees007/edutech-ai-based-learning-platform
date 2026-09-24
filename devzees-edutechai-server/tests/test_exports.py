"""
EduTechAI — Tests for Learning Session Export (Markdown, PDF, HTML)
"""

import pytest
from uuid import uuid4

from app.exceptions import BadRequestException
from app.routers.exports import check_session_completed, generate_html, generate_markdown, generate_pdf
from models.schemas import AcademicPaper, LearningMode, MilestoneStep, QuizQuestion, QuestionType, StepStatus, YouTubeClip
from models.shared_memory import SharedMemory


def create_sample_session(is_completed: bool = True) -> SharedMemory:
    status = StepStatus.COMPLETE if is_completed else StepStatus.IN_PROGRESS
    memory = SharedMemory(
        session_id=f"sess_{uuid4().hex[:8]}",
        user_id="user_test_123",
        topic="Quantum Computing Fundamentals",
        learning_mode=LearningMode.VISUAL,
        student_level="undergraduate",
        xp_earned=350,
        streak_count=5,
    )
    memory.academic_papers = [
        AcademicPaper(
            title="Quantum Supremacy using a Programmable Superconducting Processor",
            authors=["John Martinis", "Hartmut Neven"],
            year=2019,
            source="arxiv",
            url="https://arxiv.org/abs/1910.11333",
            tldr="Demonstration of quantum supremacy using 53 qubits.",
        )
    ]
    memory.steps = [
        MilestoneStep(
            index=0,
            title="Qubits and Superposition",
            description="Understand basic quantum state representations.",
            status=StepStatus.COMPLETE,
            estimated_minutes=8,
            tutor_explanation="A qubit can exist in a linear combination of states |0> and |1>.\n\n```mermaid\ngraph TD\n    A[Classical: 0 or 1] --> B[Quantum: |0> + |1>]\n```\n\n```python\nimport qiskit\nqc = QuantumCircuit(1)\n```\n",
            socratic_questions=["What distinguishes a qubit from a classical bit?"],
            videos=[
                YouTubeClip(
                    video_id="F_Riqjdh2oM",
                    title="Quantum Computing in 10 Minutes",
                    channel="Science Channel",
                    start_time=30,
                    end_time=120,
                    relevance_snippet="Superposition creates exponential state spaces.",
                )
            ],
            quiz=[
                QuizQuestion(
                    index=0,
                    question="Can a qubit be both 0 and 1 simultaneously?",
                    question_type=QuestionType.TRUE_FALSE,
                    options=["True", "False"],
                    correct_answer="True",
                    explanation="Superposition allows simultaneous linear combinations.",
                )
            ],
            quiz_score=1.0,
            user_answers={"0": "True"},
            user_full_answers={"0": "True"},
        ),
        MilestoneStep(
            index=1,
            title="Quantum Entanglement and Bell States",
            description="Explore non-local quantum correlations.",
            status=status,
            estimated_minutes=10,
            tutor_explanation="Entangled pairs cannot be described independently of each other.",
            socratic_questions=["Why does measurement collapse both entangled particles?"],
        ),
    ]
    memory.current_step_index = 2 if is_completed else 1
    memory.steps_completed = 2 if is_completed else 1
    memory.quiz_scores = {0: 1.0}
    return memory


def test_completion_guard():
    """Verify that incomplete sessions are rejected and completed sessions pass."""
    incomplete_mem = create_sample_session(is_completed=False)
    with pytest.raises(BadRequestException) as exc_info:
        check_session_completed(incomplete_mem)
    assert exc_info.value.error_code == "SESSION_INCOMPLETE"

    completed_mem = create_sample_session(is_completed=True)
    check_session_completed(completed_mem)


def test_generate_markdown_content():
    """Verify generated markdown structure, logo header, and state_json compatibility."""
    memory = create_sample_session(is_completed=True)
    md = generate_markdown(memory)

    assert "# ⚡ EduTechAI — Learning Journey Summary" in md
    assert "Quantum Computing Fundamentals" in md
    assert "Qubits and Superposition" in md
    assert "Quantum Entanglement and Bell States" in md
    assert "Quantum Supremacy using a Programmable Superconducting Processor" in md
    assert "Science Channel" in md
    assert "Can a qubit be both 0 and 1 simultaneously?" in md
    assert "**Your Answer:** True ✅" in md
    assert "100%" in md
    assert "Reflection & Socratic Prompts" not in md


@pytest.mark.asyncio
async def test_generate_pdf_content():
    """Verify PDF byte generation, clean formatting, and pre/code block inclusion."""
    memory = create_sample_session(is_completed=True)
    pdf_bytes = await generate_pdf(memory)

    assert isinstance(pdf_bytes, bytes)
    assert len(pdf_bytes) > 1000
    assert pdf_bytes[:4] == b"%PDF"
    assert "Reflection & Socratic Prompts" not in str(pdf_bytes)


def test_generate_html_content():
    """Verify standalone HTML generation with fonts, interactive cards, Mermaid diagrams, and print styles."""
    memory = create_sample_session(is_completed=True)
    html_content = generate_html(memory)

    assert "<!DOCTYPE html>" in html_content
    assert "EduTechAI" in html_content
    assert "Quantum Computing Fundamentals" in html_content
    assert "window.print()" in html_content
    assert "@media print" in html_content
    assert "Plus Jakarta Sans" in html_content
    assert "interactive-quiz-item" in html_content
    assert "https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js" in html_content
    assert "mermaid.initialize" in html_content
    assert "Concept Architecture &amp; Flowchart" in html_content
    assert "Learning Journey Milestone Path" in html_content
    assert "video-url-print" in html_content
    assert "Reflection & Socratic Prompts" not in html_content


@pytest.mark.asyncio
async def test_export_endpoints_completion_and_auth():
    """Verify that export endpoints reject incomplete sessions with 400 and succeed on complete sessions."""
    from httpx import ASGITransport, AsyncClient
    from app.main import create_app
    from services.database import get_db_session, init_db
    from services.session_manager import SessionManager
    from models.db_models import Privilege, Role, User
    from models.user_schemas import UserCreateRequest
    from services.user_service import UserService
    from sqlalchemy import select

    await init_db()
    app = create_app()
    sm = SessionManager()

    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://testserver") as client:
        # 1. Create a user
        test_email = f"exporter_{uuid4().hex[:8]}@example.com"
        async with get_db_session() as db:
            user = await UserService.create_user(
                db,
                UserCreateRequest(
                    first_name="Export",
                    last_name="Tester",
                    email=test_email,
                    password="Password123!",
                ),
            )
            user_id = user.id

            # Add Admin role (has ET_ALL) for privilege access
            admin_role = (await db.execute(select(Role).where(Role.name == "Admin"))).scalar_one_or_none()
            if not admin_role:
                p_all = (await db.execute(select(Privilege).where(Privilege.code == "ET_ALL"))).scalar_one_or_none()
                if not p_all:
                    p_all = Privilege(name="All", code="ET_ALL")
                    db.add(p_all)
                    await db.commit()
                    await db.refresh(p_all)
                admin_role = Role(name="Admin", privileges=[p_all])
                db.add(admin_role)
                await db.commit()
                await db.refresh(admin_role)
            user.roles.append(admin_role)
            await db.commit()

        # Login
        login_res = await client.post("/api/v1/auth/login", json={"email": test_email, "password": "Password123!"})
        assert login_res.status_code == 200

        # 2. Create an incomplete session
        incomplete_mem = create_sample_session(is_completed=False)
        incomplete_mem.user_id = user_id
        await sm.create_session(incomplete_mem, user_id=user_id)

        # Attempt export on incomplete session -> Expect HTTP 400 SESSION_INCOMPLETE
        md_incomplete_res = await client.get(f"/api/v1/export/{incomplete_mem.session_id}/md")
        assert md_incomplete_res.status_code == 400
        assert md_incomplete_res.json()["error_code"] == "SESSION_INCOMPLETE"

        pdf_incomplete_res = await client.get(f"/api/v1/export/{incomplete_mem.session_id}/pdf")
        assert pdf_incomplete_res.status_code == 400
        assert pdf_incomplete_res.json()["error_code"] == "SESSION_INCOMPLETE"

        html_incomplete_res = await client.get(f"/api/v1/export/{incomplete_mem.session_id}/html")
        assert html_incomplete_res.status_code == 400
        assert html_incomplete_res.json()["error_code"] == "SESSION_INCOMPLETE"

        # 3. Create a completed session
        complete_mem = create_sample_session(is_completed=True)
        complete_mem.user_id = user_id
        await sm.create_session(complete_mem, user_id=user_id)

        # Attempt export on complete session -> Expect 200
        md_res = await client.get(f"/api/v1/export/{complete_mem.session_id}/md")
        assert md_res.status_code == 200
        assert "# ⚡ EduTechAI" in md_res.text
        assert "Content-Disposition" in md_res.headers

        pdf_res = await client.get(f"/api/v1/export/{complete_mem.session_id}/pdf")
        assert pdf_res.status_code == 200
        assert pdf_res.headers["content-type"] == "application/pdf"
        assert len(pdf_res.content) > 1000

        html_res = await client.get(f"/api/v1/export/{complete_mem.session_id}/html")
        assert html_res.status_code == 200
        assert "text/html" in html_res.headers["content-type"]
        assert "EduTechAI" in html_res.text
        assert "window.print()" in html_res.text


@pytest.mark.asyncio
async def test_export_roles_and_privileges_matrix():
    """
    Verify RBAC access matrix across subscription roles:
    1. Free user (no export privileges) -> 403 on MD, HTML, and PDF
    2. Pro user (ET_EXPORT_MARKDOWN, ET_EXPORT_HTML) -> 200 on MD & HTML, 403 on PDF
    3. Ultra user (ET_EXPORT_MARKDOWN, ET_EXPORT_HTML, ET_EXPORT_PDF) -> 200 on all
    """
    from httpx import ASGITransport, AsyncClient
    from app.main import create_app
    from services.database import get_db_session, init_db
    from services.session_manager import SessionManager
    from models.db_models import Privilege, Role, User
    from models.user_schemas import UserCreateRequest
    from services.user_service import UserService
    from sqlalchemy import select

    await init_db()
    app = create_app()
    sm = SessionManager()

    free_email = f"free_{uuid4().hex[:8]}@example.com"
    pro_email = f"pro_{uuid4().hex[:8]}@example.com"
    ultra_email = f"ultra_{uuid4().hex[:8]}@example.com"

    async with get_db_session() as db:
        async def get_or_create_priv(name: str, code: str):
            p = (await db.execute(select(Privilege).where(Privilege.code == code))).scalar_one_or_none()
            if not p:
                p = Privilege(name=name, code=code)
                db.add(p)
                await db.commit()
                await db.refresh(p)
            return p

        p_md = await get_or_create_priv("Export Markdown", "ET_EXPORT_MARKDOWN")
        p_html = await get_or_create_priv("Export Html", "ET_EXPORT_HTML")
        p_pdf = await get_or_create_priv("Export Pdf", "ET_EXPORT_PDF")

        # Create isolated test roles
        role_free = Role(name=f"TFree_{uuid4().hex[:6]}", privileges=[])
        role_pro = Role(name=f"TPro_{uuid4().hex[:6]}", privileges=[p_md, p_html])
        role_ultra = Role(name=f"TUltra_{uuid4().hex[:6]}", privileges=[p_md, p_html, p_pdf])
        db.add_all([role_free, role_pro, role_ultra])
        await db.commit()

        async def create_user_with_role(email: str, role: Role):
            u = await UserService.create_user(
                db,
                UserCreateRequest(
                    first_name="Test",
                    last_name="User",
                    email=email,
                    password="Password123!",
                ),
            )
            u.roles = [role]
            await db.commit()
            return u.id

        free_uid = await create_user_with_role(free_email, role_free)
        pro_uid = await create_user_with_role(pro_email, role_pro)
        ultra_uid = await create_user_with_role(ultra_email, role_ultra)

    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://testserver") as client:
        async def check_user_exports(email: str, uid: str):
            login_res = await client.post("/api/v1/auth/login", json={"email": email, "password": "Password123!"})
            assert login_res.status_code == 200

            mem = create_sample_session(is_completed=True)
            mem.user_id = uid
            await sm.create_session(mem, user_id=uid)

            res_md = await client.get(f"/api/v1/export/{mem.session_id}/md")
            res_html = await client.get(f"/api/v1/export/{mem.session_id}/html")
            res_pdf = await client.get(f"/api/v1/export/{mem.session_id}/pdf")

            await client.post("/api/v1/auth/logout")
            return res_md.status_code, res_html.status_code, res_pdf.status_code

        # 1. Free User: 403 on MD, HTML, and PDF
        f_md, f_html, f_pdf = await check_user_exports(free_email, free_uid)
        assert f_md == 403
        assert f_html == 403
        assert f_pdf == 403

        # 2. Pro User: 200 on MD & HTML, 403 on PDF
        p_md, p_html, p_pdf = await check_user_exports(pro_email, pro_uid)
        assert p_md == 200
        assert p_html == 200
        assert p_pdf == 403

        # 3. Ultra User: 200 on MD, HTML, and PDF
        u_md, u_html, u_pdf = await check_user_exports(ultra_email, ultra_uid)
        assert u_md == 200
        assert u_html == 200
        assert u_pdf == 200


@pytest.mark.asyncio
async def test_inline_math_rendering_in_pdf():
    from app.routers.exports import latex_inline_to_html, format_inline_math_for_pdf

    # 1. Verify individual LaTeX conversions produce valid HTML math typography
    s1 = latex_inline_to_html(r"(\mathcal{S}, \mathcal{A}, T, \gamma)")
    assert '<span class="math-cal">S</span>' in s1
    assert '<span class="math-cal">A</span>' in s1
    assert "&gamma;" in s1

    s2 = latex_inline_to_html(r"\{(x_i, y_i)\}")
    assert "x<sub>i</sub>" in s2
    assert "y<sub>i</sub>" in s2

    s3 = latex_inline_to_html(r"R_\theta : \mathcal{S} \times \mathcal{A} \rightarrow \mathbb{R}")
    assert "R<sub>&theta;</sub>" in s3
    assert "&times;" in s3
    assert "&rarr;" in s3
    assert "<b>R</b>" in s3

    s4 = latex_inline_to_html(r"\sigma")
    assert "&sigma;" in s4

    s5 = latex_inline_to_html(r"\pi_\phi")
    assert "&pi;<sub>&phi;</sub>" in s5

    # 2. Verify format_inline_math_for_pdf converts embedded \(...\) and $...$
    text = (
        r"Formally, let MDP be \((\mathcal{S}, \mathcal{A}, T, \gamma)\). "
        r"Feedback provides pairs \(\{(x_i, y_i)\}\) where $x_i, y_i$ are trajectories. "
        r"A reward model \(R_\theta : \mathcal{S} \times \mathcal{A} \rightarrow \mathbb{R}\) is trained. "
        r"Where $\sigma$ is the sigmoid function. Once \(R_\theta\) is learned, a policy \(\pi_\phi\) is optimized."
    )
    formatted = format_inline_math_for_pdf(text)
    assert r"\(" not in formatted
    assert r"\mathcal{S}" not in formatted
    assert "&gamma;" in formatted
    assert "&sigma;" in formatted
    assert "&rarr;" in formatted
    assert '<span class="math-inline-pdf">' in formatted

    # 3. Verify generate_pdf generates valid PDF with inline math
    mem = create_sample_session(is_completed=True)
    mem.steps[0].tutor_explanation = text
    pdf_bytes = await generate_pdf(mem)
    assert isinstance(pdf_bytes, bytes)
    assert len(pdf_bytes) > 1000
    assert pdf_bytes.startswith(b"%PDF")

