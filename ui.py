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


def get_or_create_memory() -> SharedMemory | None:
    """Retrieve active session from session state."""
    return st.session_state.get("memory")


# ─── Sidebar Controls & Gamification ─────────────────────────────
with st.sidebar:
    st.image("https://img.icons8.com/isometric/96/graduation-cap.png", width=64)
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

    # Gamification Sidebar Card
    st.markdown("---")
    st.markdown("### 🏆 **Your Progress**")
    
    memory = get_or_create_memory()
    total_xp = memory.xp_earned if memory else 0
    level_data = calculate_level(total_xp)

    st.markdown(
        f"""
        <div class="level-badge">
            <div class="level-number">Level {level_data['level']}</div>
            <div class="level-title">{level_data['title']}</div>
        </div>
        """,
        unsafe_allow_html=True,
    )
    
    st.metric("Total XP", f"{total_xp} XP", delta=f"+{memory.xp_earned} XP" if memory and memory.xp_earned > 0 else None)
    if level_data["xp_for_next_level"]:
        st.progress(level_data["progress_to_next"] / 100.0, text=f"Progress to Level {level_data['level']+1}: {level_data['progress_to_next']}%")


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
        
        st.session_state["memory"] = new_memory
        st.session_state["active_step_index"] = 0
        st.session_state["submitted_quizzes"] = {}
        st.rerun()

memory = get_or_create_memory()

# ─── Main Content Workspace ──────────────────────────────────────
if not memory or not memory.steps:
    # Landing Page State
    st.markdown('<div class="main-title">EduTechAI Learning Workspace</div>', unsafe_allow_html=True)
    st.markdown('<div class="sub-title">An adaptive educational workspace where autonomous AI agents collaborate in real-time.</div>', unsafe_allow_html=True)
    
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
    st.markdown(f'<div class="main-title">📖 Learning: {memory.topic}</div>', unsafe_allow_html=True)
    
    # Milestone Step Navigation Bar
    st.markdown("##### 📍 **Milestone Steps**")
    step_cols = st.columns(len(memory.steps))
    
    active_idx = st.session_state.get("active_step_index", 0)

    for i, step in enumerate(memory.steps):
        status_icon = "✅" if step.status == StepStatus.COMPLETE else ("🟡" if i == active_idx else "⚪")
        prereq_label = " (Warmup)" if step.is_prerequisite else ""
        btn_label = f"{status_icon} Step {i+1}: {step.title[:18]}...{prereq_label}"
        
        btn_type = "primary" if i == active_idx else "secondary"
        if step_cols[i].button(btn_label, key=f"step_btn_{i}", type=btn_type, use_container_width=True):
            st.session_state["active_step_index"] = i
            st.rerun()

    # Progress bar
    st.progress(memory.progress_percentage / 100.0, text=f"Overall Journey Progress: {memory.progress_percentage:.0f}%")

    st.markdown("---")

    # Current Step Execution
    current_step = memory.steps[active_idx]
    
    # Prerequisite Warmup Alert
    if current_step.is_prerequisite:
        st.warning("⚠️ **Foundational Warmup:** The Orchestrator detected a prerequisite concept needed before tackling advanced details.")

    # Execute Workers for Current Step if not already executed
    step_result = memory.get_step_result(active_idx)
    
    if not step_result.explanation:
        with st.status(f"🤖 Autonomous AI Agents Collaborating on Step {active_idx+1}: {current_step.title}...", expanded=True) as status:
            st.write("🧑‍🏫 **Socratic Tutor Agent** is writing personalized explanation...")
            tutor = SocraticTutorAgent()
            run_async(tutor.execute(memory, active_idx))
            
            st.write("🎬 **YouTube Curator Agent** is searching videos and extracting timestamp clips...")
            youtube_agent = YouTubeCuratorAgent()
            run_async(youtube_agent.execute(memory, active_idx))
            
            if memory.learning_mode != LearningMode.BITE_SIZED:
                st.write("📚 **Academic Researcher Agent** is querying OpenAlex, Semantic Scholar & arXiv...")
                academic_agent = AcademicResearcherAgent()
                run_async(academic_agent.execute(memory, active_idx))
                
            st.write("📝 **Quiz Agent** is generating contextual comprehension check...")
            quiz_agent = QuizAgent()
            run_async(quiz_agent.execute(memory, active_idx))

            status.update(label=f"✅ All Agents Completed Step {active_idx+1}!", state="complete", expanded=False)
            st.rerun()

    # Two Column Main Layout (Left: Tutor & Chat | Right: Video, Papers, Quiz)
    col_left, col_right = st.columns([1.1, 0.9])

    # ─── LEFT COLUMN: Socratic Tutor & Chat Drawer ────────────────
    with col_left:
        st.markdown(f"### 🧑‍🏫 **Step {active_idx+1}: {current_step.title}**")
        st.caption(f"🎯 Objective: {current_step.description}")

        # Socratic Tutor Explanation Card
        st.markdown(
            f"""
            <div class="glass-card tutor-card">
                {step_result.explanation}
            </div>
            """,
            unsafe_allow_html=True,
        )

        # Socratic Questions
        if step_result.socratic_questions:
            st.markdown("#### 🤔 **Socratic Questions to Consider:**")
            for q in step_result.socratic_questions:
                st.info(f"👉 **{q}**")

        # Chat / Follow-up Input
        st.markdown("#### 💬 **Ask the Socratic Tutor a Follow-up Question:**")
        user_chat = st.chat_input("Ask for clarification, another analogy, or deeper detail...")
        
        if user_chat:
            memory.add_conversation_turn("student", user_chat)
            with st.spinner("🧑‍🏫 Tutor is thinking..."):
                tutor = SocraticTutorAgent()
                run_async(tutor.execute(memory, active_idx))
                st.rerun()

    # ─── RIGHT COLUMN: Video, Papers & Quiz ────────────────────────
    with col_right:
        # 1. YouTube Clip Section
        st.markdown("### 🎬 **Timestamped YouTube Clip**")
        if step_result.youtube_clips:
            clip = step_result.youtube_clips[0]
            st.markdown(f"**{clip.title}** (`{clip.channel}`)")
            st.caption(f"⏱️ Auto-jumping to relevant clip moment: **{clip.start_time}s – {clip.end_time}s**")
            
            # Embed Video
            st.video(clip.url, start_time=clip.start_time)
            st.caption(f"📝 *Transcript Context:* \"{clip.relevance_snippet}\"")
        else:
            st.info("ℹ️ No exact video clip matching this specific sub-step. Enjoy the Socratic explanation!")

        st.markdown("---")

        # 2. Academic Papers Section
        st.markdown("### 📚 **Academic Papers & Resources**")
        if step_result.academic_papers:
            for paper in step_result.academic_papers:
                authors_str = ", ".join(paper.authors[:3]) if paper.authors else "Unknown Authors"
                year_str = f"({paper.year})" if paper.year else ""
                tldr_str = f"<p><b>TLDR:</b> <i>{paper.tldr}</i></p>" if paper.tldr else ""
                pdf_link = f'<a href="{paper.pdf_url}" target="_blank">📄 Read Open-Access PDF</a>' if paper.pdf_url else ""
                
                st.markdown(
                    f"""<div class="paper-card">
<h4 style="margin:0; font-size:1.0rem;">{paper.title}</h4>
<p style="margin:0; color:#94A3B8; font-size:0.85rem;">{authors_str} {year_str} | Source: {paper.source.upper()}</p>
{tldr_str}
{pdf_link}
</div>""",
                    unsafe_allow_html=True,
                )
        else:
            st.caption("No papers loaded for this step (or Bite-Sized mode active).")

        st.markdown("---")

        # 3. Interactive Quiz Card
        st.markdown("### 📝 **Milestone Comprehension Check**")
        if step_result.quiz and step_result.quiz.questions:
            quiz_submitted_key = f"quiz_sub_{active_idx}"
            
            with st.form(key=f"quiz_form_{active_idx}"):
                user_answers = {}
                for q in step_result.quiz.questions:
                    st.markdown(f"**Q{q.index+1}: {q.question}**")
                    if q.options:
                        user_answers[q.index] = st.radio(
                            "Select answer:",
                            options=q.options,
                            key=f"q_{active_idx}_{q.index}",
                            label_visibility="collapsed",
                        )
                    else:
                        user_answers[q.index] = st.text_input(
                            "Fill in blank:",
                            key=f"q_{active_idx}_{q.index}",
                        )
                
                submit_quiz_btn = st.form_submit_button("✅ **Submit Answers & Earn XP**", type="primary", use_container_width=True)

            if submit_quiz_btn or st.session_state.get(quiz_submitted_key):
                st.session_state[quiz_submitted_key] = True
                
                correct_count = 0
                total_q = len(step_result.quiz.questions)
                
                for q in step_result.quiz.questions:
                    ans = user_answers.get(q.index, "")
                    is_correct = ans.strip().lower() == q.correct_answer.strip().lower()
                    if is_correct:
                        correct_count += 1
                        st.success(f"✅ **Q{q.index+1}: Correct!** {q.explanation}")
                    else:
                        st.error(f"❌ **Q{q.index+1}: Incorrect.** Correct answer: **{q.correct_answer}**. {q.explanation}")
                
                score = correct_count / total_q if total_q > 0 else 0
                earned_xp = calculate_quiz_xp(correct_count, total_q)
                
                # Award XP if first time submitting
                if f"xp_awarded_{active_idx}" not in st.session_state:
                    st.session_state[f"xp_awarded_{active_idx}"] = True
                    memory.xp_earned += earned_xp + calculate_step_xp(memory.streak_count)
                    memory.mark_step_complete(active_idx)
                    st.toast(f"🎉 Quiz Submitted! Earned +{earned_xp} XP!", icon="⭐")
                    time.sleep(1)
                    st.rerun()

                st.info(f"📊 **Score: {score:.0%}** ({correct_count}/{total_q} correct) | Earned +{earned_xp} XP")

                # Next Step Button
                if active_idx + 1 < len(memory.steps):
                    if st.button("➡️ **Advance to Next Step**", type="primary", use_container_width=True):
                        st.session_state["active_step_index"] = active_idx + 1
                        st.rerun()
                else:
                    st.balloons()
                    st.success("🎉 **Congratulations! You have completed the entire learning journey for this topic!**")
        else:
            st.info("No quiz available for this step.")
