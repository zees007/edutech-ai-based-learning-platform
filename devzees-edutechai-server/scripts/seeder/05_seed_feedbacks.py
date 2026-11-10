import asyncio
import os
import sys
from datetime import datetime, timezone, timedelta

# Add server root directory to sys.path
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from sqlalchemy import select
from sqlalchemy.orm import selectinload
from models.db_models import User, Role, SessionRecord, FeedbackRecord
from services.user_service import UserService
from services.database import get_db_session

PASSWORD = "Test2day@"

FEEDBACK_SEEDS = [
    # ─── FEATURED TESTIMONIALS (6) — Displayed on Homepage Wall of Love ───
    {
        "feedback_id": "fb_seed_001",
        "session_id": "sess_seed_fb_001",
        "email": "marcus.chen@example.com",
        "first_name": "Marcus",
        "last_name": "Chen",
        "role_name": "Free",
        "education_level": "Undergraduate",
        "country": "United States",
        "topic": "Quantum Mechanics & Schrodinger Equation",
        "rating": 5,
        "quote": "ChatGPT gave me text walls until I tried the problem set. EduTech AI's Socratic Tutor broke the Hamiltonian into progressive hints that forced me to derive the proof myself.",
        "status": "featured",
        "admin_notes": "Verified MIT undergraduate. Highlighted for exceptional Socratic tutor testimony.",
    },
    {
        "feedback_id": "fb_seed_002",
        "session_id": "sess_seed_fb_002",
        "email": "elena.rostova@example.com",
        "first_name": "Dr. Elena",
        "last_name": "Rostova",
        "role_name": "Ultra",
        "education_level": "Postdoctoral",
        "country": "Germany",
        "topic": "CRISPR-Cas9 Gene Editing Mechanisms",
        "rating": 5,
        "quote": "The video vector deep-linking and arXiv citations save me 15+ hours weekly. Instead of scrubbing lectures, it drops me at the exact 90-second segment explaining the animated mechanism.",
        "status": "featured",
        "admin_notes": "Postdoc researcher at Max Planck. High technical credibility.",
    },
    {
        "feedback_id": "fb_seed_003",
        "session_id": "sess_seed_fb_003",
        "email": "priya.sharma@example.com",
        "first_name": "Priya",
        "last_name": "Sharma",
        "role_name": "Pro",
        "education_level": "Graduate",
        "country": "United Kingdom",
        "topic": "Organic Chemistry Reaction Mechanisms",
        "rating": 5,
        "quote": "Exporting masterclasses into Obsidian with native Mermaid flowcharts and LaTeX formulas is game-changing. My entire second brain is structured with zero manual copy-pasting.",
        "status": "featured",
        "admin_notes": "Cambridge scholar. Promotes note export & Obsidian workflow.",
    },
    {
        "feedback_id": "fb_seed_004",
        "session_id": "sess_seed_fb_004",
        "email": "david.kim@example.com",
        "first_name": "David",
        "last_name": "Kim",
        "role_name": "Pro",
        "education_level": "Graduate",
        "country": "Canada",
        "topic": "Distributed Systems & Raft Consensus Algorithm",
        "rating": 5,
        "quote": "Bite-Sized mode is my secret weapon. In 10 minutes over coffee, I get a clear mental model of complex distributed consensus algorithms like Raft and Paxos without fluffy jargon.",
        "status": "featured",
        "admin_notes": "Staff systems engineer testimonial. Featured on homepage.",
    },
    {
        "feedback_id": "fb_seed_005",
        "session_id": "sess_seed_fb_005",
        "email": "sofia.mansoor@example.com",
        "first_name": "Sofia",
        "last_name": "Al-Mansoor",
        "role_name": "Free",
        "education_level": "High School",
        "country": "United Arab Emirates",
        "topic": "Linear Algebra & Matrix Transformations",
        "rating": 5,
        "quote": "Switching from High School to Undergraduate level on the fly is incredible. Whenever a concept feels too simple, I bump the cognitive slider and immediately get deeper mathematical rigor.",
        "status": "featured",
        "admin_notes": "Featured for showcasing dynamic cognitive level switching.",
    },
    {
        "feedback_id": "fb_seed_006",
        "session_id": "sess_seed_fb_006",
        "email": "lucas.vance@example.com",
        "first_name": "Lucas",
        "last_name": "Vance",
        "role_name": "Pro",
        "education_level": "Undergraduate",
        "country": "Australia",
        "topic": "Causal Inference & Econometrics",
        "rating": 5,
        "quote": "The formative quizzes are actually grounded in what I just learned—zero hallucinations, no irrelevant trivia. And the streak tracking genuinely keeps me accountable every single day.",
        "status": "featured",
        "admin_notes": "Featured on homepage Wall of Love.",
    },

    # ─── PENDING MODERATION (8) — To Review in Admin Panel ───
    {
        "feedback_id": "fb_seed_007",
        "session_id": "sess_seed_fb_007",
        "email": "amina.diallo@example.com",
        "first_name": "Amina",
        "last_name": "Diallo",
        "role_name": "Free",
        "education_level": "Graduate",
        "country": "France",
        "topic": "I want to learn spring boot from begining to advanace level step by step. How create a microservice in spring boot?",
        "rating": 5,
        "quote": "Building a reactive microservice from scratch with progressive step validation made difficult enterprise architecture click faster than any boot camp.",
        "status": "pending",
        "admin_notes": None,
    },
    {
        "feedback_id": "fb_seed_008",
        "session_id": "sess_seed_fb_008",
        "email": "liam.oconnor@example.com",
        "first_name": "Liam",
        "last_name": "O'Connor",
        "role_name": "Free",
        "education_level": "Undergraduate",
        "country": "Ireland",
        "topic": "Deep Learning & Convolutional Neural Networks",
        "rating": 4,
        "quote": "The visual diagrams of backpropagation and convolutional kernels were top notch. Would love even more practice coding quizzes in future updates.",
        "status": "pending",
        "admin_notes": None,
    },
    {
        "feedback_id": "fb_seed_009",
        "session_id": "sess_seed_fb_009",
        "email": "meiling.zhou@example.com",
        "first_name": "Mei-Ling",
        "last_name": "Zhou",
        "role_name": "Ultra",
        "education_level": "Postdoctoral",
        "country": "Singapore",
        "topic": "CRISPR Off-Target Analysis & Prime Editing",
        "rating": 5,
        "quote": "Having peer-reviewed preprints mapped directly to my session curriculum allowed our lab to design our primer sequences with complete confidence.",
        "status": "pending",
        "admin_notes": None,
    },
    {
        "feedback_id": "fb_seed_010",
        "session_id": "sess_seed_fb_010",
        "email": "mateo.hernandez@example.com",
        "first_name": "Mateo",
        "last_name": "Hernandez",
        "role_name": "Free",
        "education_level": "High School",
        "country": "Mexico",
        "topic": "AP Physics C Mechanics: Rotational Dynamics",
        "rating": 5,
        "quote": "I used to dread moment of inertia calculations. The step-by-step Socratic hints helped me ace my midterm without feeling overwhelmed.",
        "status": "pending",
        "admin_notes": None,
    },
    {
        "feedback_id": "fb_seed_011",
        "session_id": "sess_seed_fb_011",
        "email": "fatima.alzahra@example.com",
        "first_name": "Fatima",
        "last_name": "Al-Zahra",
        "role_name": "Pro",
        "education_level": "Graduate",
        "country": "Egypt",
        "topic": "Bioinformatics Algorithms: Sequence Alignment",
        "rating": 4,
        "quote": "Smith-Waterman dynamic programming matrices were explained better than my university professor did. The interactive quiz checkpoints were invaluable.",
        "status": "pending",
        "admin_notes": None,
    },
    {
        "feedback_id": "fb_seed_012",
        "session_id": "sess_seed_fb_012",
        "email": "johannes.becker@example.com",
        "first_name": "Johannes",
        "last_name": "Becker",
        "role_name": "Free",
        "education_level": "Undergraduate",
        "country": "Switzerland",
        "topic": "Compiler Design: Abstract Syntax Trees & LLVM IR",
        "rating": 5,
        "quote": "Walking through lexing, recursive descent parsing, and LLVM intermediate representation gave me the best intuition for compiler construction.",
        "status": "pending",
        "admin_notes": None,
    },
    {
        "feedback_id": "fb_seed_013",
        "session_id": "sess_seed_fb_013",
        "email": "ananya.patel@example.com",
        "first_name": "Ananya",
        "last_name": "Patel",
        "role_name": "Free",
        "education_level": "Undergraduate",
        "country": "India",
        "topic": "Data Structures: Self-Balancing Red-Black Trees",
        "rating": 5,
        "quote": "Tree rotations and color flip rules finally made sense visually. Gaining +30 XP bonus after finishing the session was an awesome surprise!",
        "status": "pending",
        "admin_notes": None,
    },
    {
        "feedback_id": "fb_seed_014",
        "session_id": "sess_seed_fb_014",
        "email": "taro.takahashi@example.com",
        "first_name": "Taro",
        "last_name": "Takahashi",
        "role_name": "Pro",
        "education_level": "Graduate",
        "country": "Japan",
        "topic": "Kubernetes Cluster Architecture & Operator SDK",
        "rating": 4,
        "quote": "Clear explanation of control planes, etcd reconciliation loops, and custom resource definitions. Saved my team days of trial and error.",
        "status": "pending",
        "admin_notes": None,
    },

    # ─── ARCHIVED REVIEWS (4) — Moderated / Inactive ───
    {
        "feedback_id": "fb_seed_015",
        "session_id": "sess_seed_fb_015",
        "email": "carlos.silva@example.com",
        "first_name": "Carlos",
        "last_name": "Silva",
        "role_name": "Free",
        "education_level": "Undergraduate",
        "country": "Brazil",
        "topic": "Introduction to Python Programming Basics",
        "rating": 3,
        "quote": "Good introduction to basic syntax and loops, but I was hoping for more advanced object-oriented design patterns earlier on.",
        "status": "archived",
        "admin_notes": "Archived: Beginner python feedback is too generic for homepage showcase.",
    },
    {
        "feedback_id": "fb_seed_016",
        "session_id": "sess_seed_fb_016",
        "email": "chloe.dupont@example.com",
        "first_name": "Chloe",
        "last_name": "Dupont",
        "role_name": "Free",
        "education_level": "High School",
        "country": "Canada",
        "topic": "Photosynthesis & Cellular Respiration Energy Cycles",
        "rating": 4,
        "quote": "The light-dependent reactions breakdown was very clear and helped me prepare for my high school biology test.",
        "status": "archived",
        "admin_notes": "Archived: Duplicate biology domain, superseded by CRISPR testimonial.",
    },
    {
        "feedback_id": "fb_seed_017",
        "session_id": "sess_seed_fb_017",
        "email": "alexander.novak@example.com",
        "first_name": "Alexander",
        "last_name": "Novak",
        "role_name": "Ultra",
        "education_level": "Graduate",
        "country": "Poland",
        "topic": "Applied Cryptography: Zero-Knowledge Proofs",
        "rating": 5,
        "quote": "zk-SNARKs and polynomial commitments were deconstructed with exceptional mathematical elegance. Truly university-grade material.",
        "status": "archived",
        "admin_notes": "Archived: Saved for upcoming advanced crypto feature release.",
    },
    {
        "feedback_id": "fb_seed_018",
        "session_id": "sess_seed_fb_018",
        "email": "sara.lindqvist@example.com",
        "first_name": "Sara",
        "last_name": "Lindqvist",
        "role_name": "Pro",
        "education_level": "Postdoctoral",
        "country": "Sweden",
        "topic": "Single-Cell RNA Sequencing Analysis Pipelines",
        "rating": 4,
        "quote": "Solid overview of Seurat normalization, clustering, and dimensional reduction techniques for single-cell genomics workflows.",
        "status": "archived",
        "admin_notes": "Archived: Niche subject, kept in reserve.",
    },
]


ROLE_USER_MAP = {
    "Admin": "admin@gmail.com",
    "Free": "free@gmail.com",
    "Pro": "pro@gmail.com",
    "Ultra": "ultra@gmail.com",
}


async def seed_feedbacks():
    print("Starting feedbacks seeding (18 records mapped to 4 core users)...")

    async with get_db_session() as db:
        # Load the 4 core users seeded by 03_seed_users_and_subscriptions.py
        user_res = await db.execute(
            select(User).where(User.email.in_(list(ROLE_USER_MAP.values())))
        )
        users_map = {u.email: u for u in user_res.scalars().all()}

        if not users_map:
            raise RuntimeError(
                "Core users not found! Please run '03_seed_users_and_subscriptions.py' first."
            )

        seeded_count = 0
        for data in FEEDBACK_SEEDS:
            # Map feedback to corresponding core user based on role
            target_email = ROLE_USER_MAP.get(data.get("role_name", "Free"), "free@gmail.com")
            user = users_map.get(target_email)
            if not user:
                user = next(iter(users_map.values()))

            # 1. Create or get completed session linked to core user
            session_res = await db.execute(
                select(SessionRecord).where(SessionRecord.session_id == data["session_id"])
            )
            session = session_res.scalar_one_or_none()

            if not session:
                session = SessionRecord(
                    session_id=data["session_id"],
                    user_id=user.id,
                    topic=data["topic"],
                    learning_mode="visual",
                    student_level=data["education_level"],
                    total_steps=3,
                    current_step_index=3,
                    is_complete=True,
                )
                db.add(session)
                await db.flush()
            else:
                session.user_id = user.id
                session.topic = data["topic"]
                session.student_level = data["education_level"]
                session.is_complete = True

            # 2. Create or update feedback record linked to core user
            fb_res = await db.execute(
                select(FeedbackRecord).where(FeedbackRecord.feedback_id == data["feedback_id"])
            )
            feedback = fb_res.scalar_one_or_none()

            if not feedback:
                feedback = FeedbackRecord(
                    feedback_id=data["feedback_id"],
                    session_id=session.session_id,
                    user_id=user.id,
                    rating=data["rating"],
                    quote=data["quote"],
                    education_level=data["education_level"],
                    user_country=data["country"],
                    topic_tag=data["topic"],
                    is_public_consent=True,
                    status=data["status"],
                    admin_notes=data["admin_notes"],
                )
                db.add(feedback)
            else:
                feedback.user_id = user.id
                feedback.session_id = session.session_id
                feedback.rating = data["rating"]
                feedback.quote = data["quote"]
                feedback.education_level = data["education_level"]
                feedback.user_country = data["country"]
                feedback.topic_tag = data["topic"]
                feedback.status = data["status"]
                feedback.admin_notes = data["admin_notes"]

            seeded_count += 1

        await db.flush()

        # 3. Clean up any previously created mock users (@example.com)
        cleanup_res = await db.execute(
            select(User).where(User.email.like("%@example.com"))
        )
        old_mock_users = cleanup_res.scalars().all()
        if old_mock_users:
            print(f"Cleaning up {len(old_mock_users)} legacy mock user accounts...")
            for old_u in old_mock_users:
                await db.delete(old_u)

        await db.commit()
        print(
            f"Successfully seeded {seeded_count} feedbacks mapped to {len(users_map)} core user(s). "
            f"No extra user accounts were created."
        )


if __name__ == "__main__":
    asyncio.run(seed_feedbacks())

