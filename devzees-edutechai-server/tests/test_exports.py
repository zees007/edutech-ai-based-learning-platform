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
            tutor_explanation="A qubit can exist in a linear combination of states |0> and |1>.\n\n```python\nimport qiskit\nqc = QuantumCircuit(1)\n```\n",
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


def test_generate_pdf_content():
    """Verify PDF byte generation, clean formatting, and pre/code block inclusion."""
    memory = create_sample_session(is_completed=True)
    pdf_bytes = generate_pdf(memory)

    assert isinstance(pdf_bytes, bytes)
    assert len(pdf_bytes) > 1000
    assert pdf_bytes[:4] == b"%PDF"


def test_generate_html_content():
    """Verify standalone HTML generation with fonts, interactive cards, and print styles."""
    memory = create_sample_session(is_completed=True)
    html_content = generate_html(memory)

    assert "<!DOCTYPE html>" in html_content
    assert "EduTechAI" in html_content
    assert "Quantum Computing Fundamentals" in html_content
    assert "window.print()" in html_content
    assert "@media print" in html_content
    assert "Plus Jakarta Sans" in html_content
    assert "interactive-quiz-item" in html_content


@pytest.mark.asyncio
async def test_export_endpoints_completion_and_auth():
    """Verify that export endpoints reject incomplete sessions with 400 and succeed on complete sessions."""
    from httpx import ASGITransport, AsyncClient
    from app.main import create_app
    from services.database import get_db_session, init_db
    from services.session_manager import SessionManager
    from models.db_models import Role
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
            if admin_role:
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
