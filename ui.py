"""
EduTechAI — Interactive Learning Workspace (Streamlit Frontend)

An adaptive, interactive educational workspace powered by autonomous AI agents.
Features:
- Real-time Socratic Tutoring with age-appropriate explanations & analogies
- Dynamic YouTube video search with precise timestamp deep-linking
- Open-access academic paper curation (OpenAlex, Semantic Scholar, arXiv)
- Interactive comprehension quizzes with instant grading & XP rewards
- Gamified leveling system & progress tracking
- Configurable Learning Modes (Visual, Deep Dive, Bite-Sized)
"""

from __future__ import annotations

import asyncio
import logging
import time

import streamlit as st

# ─── Page Configuration ──────────────────────────────────────────
st.set_page_config(
    page_title="EduTechAI — Learning Workspace",
    page_icon="🎓",
    layout="wide",
    initial_sidebar_state="expanded",
)

# Suppress background logs in Streamlit
logging.getLogger("httpx").setLevel(logging.WARNING)

# Import backend modules
from agents.academic_researcher import AcademicResearcherAgent
from agents.orchestrator import OrchestratorAgent
from agents.quiz_agent import QuizAgent
from agents.socratic_tutor import SocraticTutorAgent
from agents.youtube_curator import YouTubeCuratorAgent
from config import get_settings
from models.schemas import LearningMode, StepStatus
from models.shared_memory import SharedMemory
from services.gamification import calculate_level, calculate_quiz_xp, calculate_step_xp

# ─── Custom CSS Styling ──────────────────────────────────────────
CUSTOM_CSS = """
<style>
    /* Dark Theme Customization */    
    /* Header styling */
    .main-title {
        font-size: 2.2rem;
        font-weight: 800;
        background: linear-gradient(135deg, #A855F7 0%, #3B82F6 50%, #06B6D4 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        margin-bottom: 0.2rem;
    }
    
    .sub-title {
        color: #94A3B8;
        font-size: 1.0rem;
        margin-bottom: 1.5rem;
    }

    /* Glassmorphism Cards */
    .glass-card {
        background: rgba(30, 41, 59, 0.7);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 12px;
        padding: 1.2rem;
        margin-bottom: 1rem;
        backdrop-filter: blur(10px);
    }
    
    .tutor-card {
        border-left: 4px solid #A855F7;
        background: rgba(24, 24, 37, 0.8);
    }
    
    .prereq-badge {
        background-color: #FEF08A;
        color: #854D0E;
        font-size: 0.75rem;
        font-weight: 700;
        padding: 3px 8px;
        border-radius: 6px;
        text-transform: uppercase;
        margin-left: 8px;
    }

    /* XP Level Badge */
    .level-badge {
        background: linear-gradient(135deg, #7C3AED 0%, #C084FC 100%);
        color: white;
        border-radius: 10px;
        padding: 12px 16px;
        text-align: center;
        margin-bottom: 1rem;
        box-shadow: 0 4px 12px rgba(124, 58, 237, 0.3);
    }

    .level-number {
        font-size: 1.8rem;
        font-weight: 900;
        line-height: 1;
    }

    .level-title {
        font-size: 0.85rem;
        text-transform: uppercase;
        letter-spacing: 1px;
        opacity: 0.9;
    }

    /* Quiz Card */
    .quiz-card {
        border-left: 4px solid #06B6D4;
        background: rgba(15, 23, 42, 0.9);
    }
    
    /* Paper Item */
    .paper-card {
        border: 1px solid rgba(59, 130, 246, 0.2);
        border-radius: 8px;
        padding: 10px 14px;
        margin-bottom: 8px;
        background: rgba(15, 23, 42, 0.5);
    }

    .paper-card:hover {
        border-color: rgba(59, 130, 246, 0.5);
    }

    /* Top Progress Banner */
    .top-progress-card {
        background: linear-gradient(135deg, rgba(30, 41, 59, 0.85) 0%, rgba(15, 23, 42, 0.95) 100%);
        border: 1px solid rgba(168, 85, 247, 0.35);
        border-radius: 12px;
        padding: 0.9rem 1.2rem;
        margin-bottom: 1.2rem;
        box-shadow: 0 4px 16px rgba(124, 58, 237, 0.15);
    }
    
    .top-progress-stat {
        font-size: 1.4rem;
        font-weight: 800;
        background: linear-gradient(135deg, #A855F7 0%, #3B82F6 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        line-height: 1.2;
    }
    
    .top-progress-label {
        color: #94A3B8;
        font-size: 0.78rem;
        text-transform: uppercase;
        letter-spacing: 0.8px;
        font-weight: 700;
        margin-bottom: 4px;
    }
</style>
"""
st.markdown(CUSTOM_CSS, unsafe_allow_html=True)


# ─── Helper Functions ────────────────────────────────────────────
def run_async(coro):
    """Run an async coroutine inside Streamlit's sync execution model."""
    try:
        loop = asyncio.get_event_loop()
    except RuntimeError:
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
    return loop.run_until_complete(coro)


# ─── One-Time DB Initialization (at Streamlit app startup) ───────
# @st.cache_resource ensures this runs only once per server lifecycle,
# so switching to the Admin Console later is instant (DB already warmed up).
@st.cache_resource
def _init_db_once():
    """Warm up DB schema, migrations, and seeds at app start — not on first admin switch."""
    from services.database import init_db
    from config import get_settings
    run_async(init_db(get_settings()))


_init_db_once()  # Triggered once on first Streamlit page load


def get_or_create_memory() -> SharedMemory | None:
    """Retrieve active session from session state."""
    return st.session_state.get("memory")


def render_learning_workspace():
    """Renders the student learning workspace."""
    # ─── Sidebar Controls & Gamification ─────────────────────────────
    with st.sidebar:
        st.image("https://img.icons8.com/isometric/96/graduation-cap.png", width=64)
        
        # Navigation Switcher
        st.markdown("### **Portal Navigation**")
        if st.button("🛡️ **Open Admin Console**", use_container_width=True, help="Manage users, roles & subscriptions"):
            st.session_state["view"] = "admin"
            st.rerun()

        st.markdown("---")
        st.markdown("### **EduTechAI Settings**")
        
        # Topic Input
        topic_input = st.text_input(
            "🎯 **What do you want to learn?**",
            value=st.session_state.get("last_topic", "How does photosynthesis work?"),
            placeholder="e.g. Quantum Computing, Photosynthesis...",
        )
        
        # Topic Suggestions
        st.markdown("<small>💡 **Try asking:**</small>", unsafe_allow_html=True)
        cols = st.columns(2)
        if cols[0].button("🌱 Photosynthesis", key="sug1"):
            topic_input = "How does photosynthesis work?"
        if cols[1].button("⚛️ Quantum Physics", key="sug2"):
            topic_input = "Explain quantum entanglement"
        if cols[0].button("🧠 Neural Networks", key="sug3"):
            topic_input = "How do neural networks learn?"
        if cols[1].button("🌊 Ocean Tides", key="sug4"):
            topic_input = "What causes ocean tides?"

        st.markdown("---")

        # Learning Mode Selection
        mode_option = st.selectbox(
            "🎨 **Learning Mode**",
            options=["Visual 🎬", "Deep Dive 🔬", "Bite-Sized ⚡"],
            index=0,
            help="Visual: video & diagrams | Deep Dive: papers & proofs | Bite-Sized: quick summaries",
        )
        mode_map = {
            "Visual 🎬": LearningMode.VISUAL,
            "Deep Dive 🔬": LearningMode.DEEP_DIVE,
            "Bite-Sized ⚡": LearningMode.BITE_SIZED,
        }
        selected_mode = mode_map[mode_option]

        # Student Level Selection
        level_option = st.selectbox(
            "🎓 **Education Level**",
            options=["Middle School 🏫", "High School 🎒", "Undergraduate 🏛️", "Graduate 🎓", "General Curious 💡"],
            index=0,
        )
        level_map = {
            "Middle School 🏫": "middle_school",
            "High School 🎒": "high_school",
            "Undergraduate 🏛️": "undergraduate",
            "Graduate 🎓": "graduate",
            "General Curious 💡": "general",
        }
        selected_level = level_map[level_option]

        st.markdown("---")

        # Start Learning Journey Button
        start_clicked = st.button("🚀 **Start Learning Journey**", type="primary", use_container_width=True)


    # ─── Session Initialization Logic ────────────────────────────────
    if start_clicked and topic_input:
        st.session_state["last_topic"] = topic_input
        
        with st.spinner("🧠 Orchestrator Agent is decomposing topic into milestone steps..."):
            # Initialize SharedMemory
            new_memory = SharedMemory(
                topic=topic_input,
                learning_mode=selected_mode,
                student_level=selected_level,
            )
            
            # Run Orchestrator Agent
            orchestrator = OrchestratorAgent()
            run_async(orchestrator.execute(new_memory))
            
            # Persist session to PostgreSQL database in Supabase
            try:
                from services.session_manager import SessionManager
                run_async(SessionManager().create_session(new_memory))
            except Exception as e:
                logging.warning(f"Could not persist session to database: {e}")

            st.session_state["memory"] = new_memory
            st.session_state["active_step_index"] = 0
            st.session_state["submitted_quizzes"] = {}
            st.rerun()

    memory = get_or_create_memory()

    # ─── Main Content Workspace ──────────────────────────────────────
    if not memory or not memory.steps:
        # Landing Page State with Header & Admin Button
        header_col1, header_col2 = st.columns([4, 1])
        with header_col1:
            st.markdown('<div class="main-title">EduTechAI Learning Workspace</div>', unsafe_allow_html=True)
            st.markdown('<div class="sub-title">An adaptive educational workspace where autonomous AI agents collaborate in real-time.</div>', unsafe_allow_html=True)
        with header_col2:
            st.write("")
            if st.button("🛡️ Admin Portal", key="top_admin_btn", help="Switch to Admin Console"):
                st.session_state["view"] = "admin"
                st.rerun()

        st.info("👈 Enter a topic in the sidebar and click **Start Learning Journey** to begin!")
        
        # Feature Grid
        col1, col2, col3 = st.columns(3)
        with col1:
            st.markdown(
                """
                <div class="glass-card">
                    <h3>🧩 Socratic Tutor Agent</h3>
                    <p>Explains complex concepts using simple everyday analogies and guiding questions — no raw text dumps!</p>
                </div>
                """,
                unsafe_allow_html=True,
            )
        with col2:
            st.markdown(
                """
                <div class="glass-card">
                    <h3>🎬 YouTube Curator</h3>
                    <p>Extracts transcripts and pinpoints exact timestamp clips to jump straight to the explanation moment.</p>
                </div>
                """,
                unsafe_allow_html=True,
            )
        with col3:
            st.markdown(
                """
                <div class="glass-card">
                    <h3>📚 Academic Researcher</h3>
                    <p>Searches OpenAlex, Semantic Scholar, and arXiv for open-access papers and AI-generated summaries.</p>
                </div>
                """,
                unsafe_allow_html=True,
            )

    else:
        # Active Session Workspace
        act_col1, act_col2 = st.columns([4, 1])
        with act_col1:
            st.markdown(f'<div class="main-title">📖 Learning: {memory.topic}</div>', unsafe_allow_html=True)
        with act_col2:
            st.write("")
            if st.button("🛡️ Admin Portal", key="act_admin_btn", help="Switch to Admin Console"):
                st.session_state["view"] = "admin"
                st.rerun()
        
        # ─── Top Progress & Gamification Header Dashboard ──────────────
        total_xp = memory.xp_earned if memory else 0
        level_data = calculate_level(total_xp)
        completed_steps = sum(1 for s in memory.steps if s.status == StepStatus.COMPLETE)
        total_steps = len(memory.steps)

        st.markdown(
            f"""
            <div class="top-progress-card">
                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <span style="font-weight: 800; font-size: 1.05rem; color: #F1F5F9;">🏆 <b>Your Progress Header</b></span>
                    <span style="font-size: 0.85rem; color: #94A3B8; font-weight: 600;">Mode: <b style="color:#A855F7;">{memory.learning_mode.value.title()}</b> | Audience: <b style="color:#3B82F6;">{memory.student_level.title()}</b></span>
                </div>
            </div>
            """,
            unsafe_allow_html=True,
        )

        prog_col1, prog_col2, prog_col3, prog_col4 = st.columns([1.2, 1.2, 1.8, 1.8])
        with prog_col1:
            st.markdown(
                f"""
                <div class="glass-card" style="margin-bottom:0; text-align:center; padding: 0.75rem 0.5rem;">
                    <div class="top-progress-label">Current Level</div>
                    <div class="top-progress-stat">Lvl {level_data['level']}</div>
                    <div style="font-size:0.75rem; color:#A855F7; font-weight:700;">{level_data['title']}</div>
                </div>
                """,
                unsafe_allow_html=True,
            )

        with prog_col2:
            st.markdown(
                f"""
                <div class="glass-card" style="margin-bottom:0; text-align:center; padding: 0.75rem 0.5rem;">
                    <div class="top-progress-label">Total XP Earned</div>
                    <div class="top-progress-stat">⭐ {total_xp}</div>
                    <div style="font-size:0.75rem; color:#38BDF8; font-weight:700;">Streak: {memory.streak_count} 🔥</div>
                </div>
                """,
                unsafe_allow_html=True,
            )

        with prog_col3:
            st.markdown(
                f"""
                <div class="glass-card" style="margin-bottom:0; padding: 0.75rem 0.8rem;">
                    <div class="top-progress-label">Level Progress</div>
                    <div style="font-size:0.85rem; color:#F1F5F9; font-weight:700; margin-bottom:4px;">{level_data['xp_in_level']} / {level_data['xp_needed_for_next']} XP</div>
                </div>
                """,
                unsafe_allow_html=True,
            )
            st.progress(level_data["progress"])

        with prog_col4:
            st.markdown(
                f"""
                <div class="glass-card" style="margin-bottom:0; padding: 0.75rem 0.8rem;">
                    <div class="top-progress-label">Topic Completion</div>
                    <div style="font-size:0.85rem; color:#F1F5F9; font-weight:700; margin-bottom:4px;">{completed_steps} of {total_steps} Steps ({completed_steps/total_steps if total_steps else 0:.0%})</div>
                </div>
                """,
                unsafe_allow_html=True,
            )
            st.progress(completed_steps / total_steps if total_steps else 0.0)

        st.markdown("<br>", unsafe_allow_html=True)

        # ─── Milestone Navigation Tabs ─────────────────────────────
        step_titles = [f"Step {i+1}: {step.title}" for i, step in enumerate(memory.steps)]
        
        # Check active index
        active_idx = st.session_state.get("active_step_index", 0)
        if active_idx >= len(memory.steps):
            active_idx = 0
            
        selected_step_title = st.selectbox(
            "📌 **Milestone Learning Roadmap:**",
            options=step_titles,
            index=active_idx,
            key="step_selector",
        )
        active_idx = step_titles.index(selected_step_title)
        st.session_state["active_step_index"] = active_idx

        current_step = memory.steps[active_idx]

        # Display Step Details Header
        col_s1, col_s2 = st.columns([3, 1])
        with col_s1:
            st.markdown(f"### Milestone {active_idx+1}: {current_step.title}")
            st.markdown(f"*{current_step.description}*")
            if current_step.prerequisite:
                st.markdown(f'<span class="prereq-badge">Prereq: {current_step.prerequisite}</span>', unsafe_allow_html=True)
        with col_s2:
            status_color = "#10B981" if current_step.status == StepStatus.COMPLETE else ("#3B82F6" if current_step.status == StepStatus.IN_PROGRESS else "#6B7280")
            st.markdown(f'<div style="text-align:right; font-weight:700; color:{status_color}; font-size:1.1rem;">Status: {current_step.status.value.upper()}</div>', unsafe_allow_html=True)

        st.markdown("---")

        # Tabbed Output Interface for Active Step
        tab_tutor, tab_video, tab_papers, tab_quiz = st.tabs([
            "🧩 Socratic Explanation",
            "🎬 Video Clip & Transcript",
            "📚 Academic Papers",
            "📝 Quiz & Knowledge Check",
        ])

        # TAB 1: Socratic Explanation
        with tab_tutor:
            if current_step.tutor_explanation:
                st.markdown(f'<div class="glass-card tutor-card">{current_step.tutor_explanation}</div>', unsafe_allow_html=True)
            else:
                if st.button("🤖 **Generate Socratic Explanation**", type="primary", key=f"tutor_btn_{active_idx}"):
                    with st.spinner("Socratic Tutor Agent is crafting explanation..."):
                        tutor = SocraticTutorAgent()
                        explanation = run_async(tutor.explain_step(current_step, memory.topic, memory.learning_mode, memory.student_level))
                        current_step.tutor_explanation = explanation
                        
                        # Persist to database
                        try:
                            from services.session_manager import SessionManager
                            run_async(SessionManager().update_session(memory))
                        except Exception as e:
                            logging.warning(f"Could not persist session update to database: {e}")

                        st.rerun()

        # TAB 2: YouTube Videos
        with tab_video:
            if current_step.videos:
                for idx, vid in enumerate(current_step.videos):
                    st.subheader(f"🎬 Video: {vid.title}")
                    st.write(f"**Channel:** {vid.channel} | **Relevance:** {vid.relevance_score:.0%}")
                    
                    # Video Embed
                    if vid.embed_url:
                        st.components.v1.iframe(vid.embed_url, height=400)
                    
                    # Timestamp Deep Link
                    if vid.timestamp_seconds:
                        timestamp_mins = vid.timestamp_seconds // 60
                        timestamp_secs = vid.timestamp_seconds % 60
                        st.markdown(
                            f"📌 **Key Explanation Segment:** [{timestamp_mins:02d}:{timestamp_secs:02d}]({vid.timestamp_url}) "
                            f"— *\"{vid.timestamp_explanation}\"*"
                        )
                    
                    # Relevant Snippet
                    if vid.relevant_snippet:
                        st.caption(f"**Transcript Snippet:** {vid.relevant_snippet}")
                    
                    if idx < len(current_step.videos) - 1:
                        st.markdown("---")
            else:
                if st.button("🎬 **Curate Relevant YouTube Clips**", key=f"yt_btn_{active_idx}"):
                    with st.spinner("YouTube Curator Agent searching transcripts..."):
                        curator = YouTubeCuratorAgent()
                        videos = run_async(curator.curate_videos(current_step, memory.topic, memory.student_level))
                        current_step.videos = videos
                        
                        try:
                            from services.session_manager import SessionManager
                            run_async(SessionManager().update_session(memory))
                        except Exception as e:
                            logging.warning(f"Could not persist session update to database: {e}")

                        st.rerun()

        # TAB 3: Academic Papers
        with tab_papers:
            if current_step.papers:
                st.markdown("### 📚 Curated Academic Papers & Preprints")
                for paper in current_step.papers:
                    st.markdown(
                        f"""
                        <div class="paper-card">
                            <h4 style="margin-bottom:4px; color:#60A5FA;"><a href="{paper.url}" target="_blank" style="color:#60A5FA; text-decoration:none;">📄 {paper.title}</a></h4>
                            <p style="font-size:0.85rem; color:#94A3B8; margin-bottom:6px;"><b>Authors:</b> {', '.join(paper.authors[:3])} | <b>Year:</b> {paper.year or 'N/A'} | <b>Source:</b> {paper.source.title()}</p>
                            <p style="font-size:0.9rem; color:#E2E8F0;"><b>AI Key Insight:</b> {paper.ai_summary or paper.abstract[:250] + '...'}</p>
                        </div>
                        """,
                        unsafe_allow_html=True,
                    )
            else:
                if st.button("📚 **Curate Academic Papers**", key=f"paper_btn_{active_idx}"):
                    with st.spinner("Academic Researcher Agent querying OpenAlex & arXiv..."):
                        researcher = AcademicResearcherAgent()
                        papers = run_async(researcher.curate_papers(current_step, memory.topic))
                        current_step.papers = papers
                        
                        try:
                            from services.session_manager import SessionManager
                            run_async(SessionManager().update_session(memory))
                        except Exception as e:
                            logging.warning(f"Could not persist session update to database: {e}")

                        st.rerun()

        # TAB 4: Comprehension Quiz
        with tab_quiz:
            if not current_step.quiz:
                if st.button("📝 **Generate Step Quiz**", type="primary", key=f"quiz_gen_{active_idx}"):
                    with st.spinner("Quiz Agent generating interactive questions..."):
                        quiz_agent = QuizAgent()
                        quiz_questions = run_async(quiz_agent.generate_quiz(current_step, memory.topic, memory.student_level))
                        current_step.quiz = quiz_questions
                        
                        try:
                            from services.session_manager import SessionManager
                            run_async(SessionManager().update_session(memory))
                        except Exception as e:
                            logging.warning(f"Could not persist session update to database: {e}")

                        st.rerun()
            else:
                st.markdown("### 📝 Milestone Knowledge Check")
                quiz_key = f"quiz_form_{active_idx}"
                
                with st.form(quiz_key):
                    user_answers = {}
                    for q_idx, q in enumerate(current_step.quiz):
                        st.markdown(f"**Q{q_idx+1}: {q.question}**")
                        opts = [f"{k}: {v}" for k, v in q.options.items()]
                        user_ans = st.radio(f"Select answer for Q{q_idx+1}:", opts, key=f"q_{active_idx}_{q_idx}", index=0)
                        user_answers[q_idx] = user_ans.split(":")[0].strip()
                        st.markdown("---")
                    
                    submit_quiz = st.form_submit_button("Submit Quiz Answers")

                if submit_quiz or f"quiz_submitted_{active_idx}" in st.session_state:
                    st.session_state[f"quiz_submitted_{active_idx}"] = True
                    correct_count = 0
                    total_q = len(current_step.quiz)

                    st.markdown("### 📊 Quiz Results & Grading")
                    for q_idx, q in enumerate(current_step.quiz):
                        selected = user_answers.get(q_idx, "A")
                        is_correct = selected == q.correct_option
                        if is_correct:
                            correct_count += 1
                            st.success(f"**Q{q_idx+1}: Correct!** ✅ — {q.explanation}")
                        else:
                            st.error(f"**Q{q_idx+1}: Incorrect** ❌ — You selected ({selected}). Correct: ({q.correct_option}). {q.explanation}")

                    score = correct_count / total_q if total_q > 0 else 0
                    current_step.quiz_score = score
                    earned_xp = calculate_quiz_xp(score)

                    if f"xp_awarded_{active_idx}" not in st.session_state:
                        st.session_state[f"xp_awarded_{active_idx}"] = True
                        memory.xp_earned += earned_xp + calculate_step_xp(memory.streak_count)
                        memory.mark_step_complete(active_idx)

                        # Update next step to in_progress if exists
                        if active_idx + 1 < len(memory.steps):
                            if memory.steps[active_idx + 1].status == StepStatus.PENDING:
                                memory.steps[active_idx + 1].status = StepStatus.IN_PROGRESS

                        # Persist progress & gamification XP to PostgreSQL database in Supabase
                        try:
                            from services.session_manager import SessionManager
                            sm = SessionManager()
                            run_async(sm.update_session(memory))
                            run_async(sm.save_step_progress(
                                session_id=memory.session_id,
                                step_index=active_idx,
                                status="complete",
                                quiz_score=score,
                            ))
                            if active_idx + 1 < len(memory.steps):
                                run_async(sm.save_step_progress(
                                    session_id=memory.session_id,
                                    step_index=active_idx + 1,
                                    status="in_progress",
                                ))
                        except Exception as e:
                            logging.warning(f"Could not persist step progress to database: {e}")

                        st.toast(f"🎉 Quiz Submitted! Earned +{earned_xp} XP!", icon="⭐")
                        time.sleep(1)
                        st.rerun()

                    st.info(f"📊 **Score: {score:.0%}** ({correct_count}/{total_q} correct) | Earned +{earned_xp} XP")

                    # Next Step Button
                    if active_idx + 1 < len(memory.steps):
                        if st.button("➡️ **Advance to Next Step**", type="primary", use_container_width=True):
                            # Ensure current step is marked complete
                            if memory.steps[active_idx].status != StepStatus.COMPLETE:
                                memory.mark_step_complete(active_idx)

                            next_idx = active_idx + 1
                            st.session_state["active_step_index"] = next_idx
                            if memory.steps[next_idx].status == StepStatus.PENDING:
                                memory.steps[next_idx].status = StepStatus.IN_PROGRESS

                            try:
                                from services.session_manager import SessionManager
                                sm = SessionManager()
                                run_async(sm.update_session(memory))
                                run_async(sm.save_step_progress(memory.session_id, active_idx, "complete", quiz_score=score))
                                run_async(sm.save_step_progress(memory.session_id, next_idx, "in_progress"))
                            except Exception as e:
                                logging.warning(f"Could not update step progress in DB: {e}")

                            st.rerun()
                    else:
                        # Final step completed! Update session completion state
                        if not memory.is_complete:
                            memory.mark_step_complete(active_idx)
                            try:
                                from services.session_manager import SessionManager
                                run_async(SessionManager().update_session(memory))
                                run_async(SessionManager().save_step_progress(memory.session_id, active_idx, "complete", quiz_score=score))
                            except Exception as e:
                                logging.warning(f"Could not save final session state: {e}")
                        st.balloons()
                        st.success("🎉 **Congratulations! You have completed the entire learning journey for this topic!**")


# ─── Main View Switcher Execution ─────────────────────────────────
if "view" not in st.session_state:
    st.session_state["view"] = "learning"

if st.session_state.get("view") == "admin":
    from admin_ui import render_admin_panel
    render_admin_panel()
else:
    render_learning_workspace()
