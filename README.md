<![CDATA[# 🎓 EduTechAI — AI-Based Adaptive Learning Platform

An adaptive, interactive educational workspace powered by **autonomous AI agents** that collaborate in real-time to deliver personalized learning experiences. EduTechAI breaks down any topic into progressive milestone steps and uses Socratic teaching, curated YouTube videos, academic research, and gamified quizzes to guide students from curiosity to comprehension.

---

## 📑 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [System Architecture](#system-architecture)
  - [Multi-Agent Design](#multi-agent-design)
  - [SharedMemory (Central State)](#sharedmemory-central-state)
  - [Agent Read/Write Map](#agent-readwrite-map)
- [AI Agents — In Detail](#ai-agents--in-detail)
  - [1. Orchestrator Agent (Supervisor)](#1-orchestrator-agent-supervisor)
  - [2. Socratic Tutor Agent](#2-socratic-tutor-agent)
  - [3. YouTube Curator Agent](#3-youtube-curator-agent)
  - [4. Academic Researcher Agent](#4-academic-researcher-agent)
  - [5. Quiz Agent](#5-quiz-agent)
  - [6. Synthesizer Agent](#6-synthesizer-agent)
- [Learning Modes](#learning-modes)
- [Education Levels](#education-levels)
- [Gamification & XP System](#gamification--xp-system)
- [How a Learning Session Works (End-to-End)](#how-a-learning-session-works-end-to-end)
- [Session Persistence & History](#session-persistence--history)
- [Step Navigation (Go Back / Forward)](#step-navigation-go-back--forward)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Configuration](#configuration)
  - [Running the Application](#running-the-application)
- [API Endpoints](#api-endpoints)
- [Configurable LLM Providers](#configurable-llm-providers)
- [Database](#database)
- [Future Roadmap](#future-roadmap)

---

## Overview

EduTechAI is not a simple chatbot. It is a **multi-agent system** where six specialized AI agents collaborate — each with a distinct responsibility — orchestrated around a shared memory architecture. When a student enters a topic (e.g., "How does photosynthesis work?"), the system:

1. **Decomposes** the topic into 4–7 progressive milestone steps (detecting prerequisite gaps automatically).
2. **Teaches** each step using the Socratic method — warm analogies and guided questioning, never raw text dumps.
3. **Curates** timestamped YouTube video clips that jump directly to the exact explanation moment.
4. **Searches** open-access academic papers across OpenAlex, Semantic Scholar, and arXiv.
5. **Generates** contextual comprehension quizzes with instant grading.
6. **Rewards** students with XP, streaks, and level-ups to keep them engaged.

All content adapts dynamically based on the selected **Learning Mode** and **Education Level**.

---

## Key Features

| Feature | Description |
|---------|-------------|
| 🧩 **Socratic Tutoring** | Explains concepts through guiding questions and everyday analogies — never gives direct answers |
| 🎬 **YouTube Deep-Linking** | Finds videos and pinpoints the exact timestamp clip relevant to each step |
| 📚 **Academic Research** | Searches OpenAlex, Semantic Scholar, and arXiv for open-access papers with AI-generated summaries |
| 📝 **Dynamic Quizzes** | Generates 2–3 contextual comprehension questions per step with instant grading |
| 🏆 **Gamification** | XP rewards, streak tracking, and a 10-level progression system |
| 🎨 **Three Learning Modes** | Visual, Deep Dive, and Bite-Sized — each adapts all agent outputs |
| 🎓 **Five Education Levels** | Middle School through Graduate — language and complexity calibrate automatically |
| 💬 **Follow-up Chat** | Ask the Socratic Tutor follow-up questions at any step |
| 📍 **Step Navigation** | Navigate freely between completed steps without re-running agents |
| 💾 **Session Persistence** | Full session state persisted to database for recovery and history |

---

## System Architecture

### Multi-Agent Design

EduTechAI uses a **supervisor–worker** agent pattern. There is **no direct agent-to-agent communication**. All agents read from and write to a central **SharedMemory** object.

```
┌─────────────────────────────────────────────────────────────────┐
│                         STUDENT                                 │
│              (Streamlit UI / WebSocket Client)                  │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
              ┌─────────────────────┐
              │   Orchestrator      │ ◄── Supervisor Agent
              │   (Plans Journey)   │     Decomposes topic → milestone steps
              └─────────┬───────────┘
                        │
         ┌──────────────┼──────────────┐
         ▼              ▼              ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│  Socratic    │ │   YouTube    │ │  Academic    │
│  Tutor       │ │   Curator    │ │  Researcher  │
│ (Explains)   │ │ (Finds Clips)│ │ (Papers)     │
└──────┬───────┘ └──────┬───────┘ └──────┬───────┘
       │                │                │
       ▼                ▼                ▼
              ┌─────────────────────┐
              │    SharedMemory     │ ◄── Central State Object
              │  (All agent I/O)    │
              └─────────┬───────────┘
                        │
                        ▼
              ┌─────────────────────┐
              │    Quiz Agent       │ ◄── Runs AFTER Socratic Tutor
              │ (Generates Quiz)    │     (needs the explanation as input)
              └─────────┬───────────┘
                        │
                        ▼
              ┌─────────────────────┐
              │   Synthesizer       │ ◄── Read-Only Agent
              │ (Assembles Events)  │     Converts outputs → WebSocket events
              └─────────────────────┘
```

### SharedMemory (Central State)

The `SharedMemory` object is the **single source of truth** for an entire learning session. It holds:

| Section | Contents |
|---------|----------|
| **Session Info** | Topic, learning mode, student level, session ID, creation time |
| **Learning Plan** | List of milestone steps, prerequisite detection flags |
| **Step Results** | Per-step agent outputs — explanations, YouTube clips, papers, quizzes |
| **Conversation History** | Append-only log of all student ↔ tutor exchanges |
| **Gamification State** | XP earned, streak count, quiz scores |

### Agent Read/Write Map

Each agent has clearly defined read and write permissions:

| Agent | Reads | Writes |
|-------|-------|--------|
| **Orchestrator** | Session Info, Conversation History | Learning Plan (steps) |
| **Socratic Tutor** | Session Info, Learning Plan, Conversation History | Step Results (explanation, questions) |
| **YouTube Curator** | Session Info, Learning Plan | Step Results (YouTube clips) |
| **Academic Researcher** | Session Info, Learning Plan | Step Results (papers) |
| **Quiz Agent** | Session Info, Step Results (explanation) | Step Results (quiz) |
| **Synthesizer** | Learning Plan, Step Results, Gamification State | Nothing (read-only) |

---

## AI Agents — In Detail

### 1. Orchestrator Agent (Supervisor)

**Role:** The brain of the system. Decomposes any topic into a structured, progressive sequence of milestone steps.

**What it does:**
- Analyzes the topic and determines if prerequisite knowledge is needed
- **Detects prerequisite gaps** — if the topic is advanced (e.g., "Quantum Entanglement"), it automatically prepends a foundational warmup step (e.g., "What is Superposition?")
- Creates **4–7 milestone steps** that build progressively from basic to advanced understanding
- Adapts the number and depth of steps based on Learning Mode and Education Level

**Model:** Configurable via `ORCHESTRATOR_MODEL` in `.env` (default: `llama-3.1-8b-instant`)  
**Temperature:** `0.3` (low — for deterministic structured planning)

**Example output for "How does photosynthesis work?":**
```
Step 0: "Why Plants Need Energy" (Prerequisite Warmup)
Step 1: "Capturing Sunlight — The Role of Chlorophyll"
Step 2: "Light Reactions — Splitting Water Molecules"
Step 3: "The Calvin Cycle — Turning CO₂ into Sugar"
Step 4: "Photosynthesis in the Bigger Picture"
```

---

### 2. Socratic Tutor Agent

**Role:** The teaching voice. Generates warm, engaging explanations using the Socratic method — guiding students to discover understanding through questions and analogies.

**What it does:**
- Writes a **personalized explanation** for each milestone step
- Uses **everyday analogies** to make abstract concepts tangible (e.g., explaining electron flow as "water flowing through a garden hose")
- Generates **1–2 guiding Socratic questions** at the end of each explanation to encourage deeper thinking
- Adapts vocabulary, depth, and style based on both Education Level and Learning Mode
- Maintains **conversation continuity** — uses the last 6 conversation turns as context for follow-up questions
- Supports **token-by-token streaming** for real-time UI rendering via WebSocket

**Model:** Configurable via `SOCRATIC_TUTOR_MODEL` in `.env` (default: `llama-3.1-8b-instant`)  
**Temperature:** `0.7` (slightly creative — for engaging explanations)

**Key behavior:** The tutor **never mentions it is an AI**. It writes as a knowledgeable, friendly human teacher would speak.

---

### 3. YouTube Curator Agent

**Role:** Finds relevant educational YouTube videos and pinpoints the **exact timestamp range** that matches the current learning step.

**Pipeline:**
1. **YouTube Data API v3** — Searches for educational videos matching the topic + step title
2. **youtube-transcript-api** — Fetches the full transcript of each video
3. **ChromaDB** — Embeds transcript chunks with timestamp metadata into a vector store
4. **Semantic Search** — Finds the best-matching transcript chunk and extracts its start/end timestamps
5. Returns structured `YouTubeClip` objects with deep-linked URLs (e.g., `youtube.com/watch?v=...&t=127`)

**Mode adaptations:**
- **Visual mode:** Returns up to 3 video clips per step
- **Bite-Sized mode:** Returns only the single best clip per step
- **Deep Dive mode:** Returns up to 3 clips

**Daily quota:** 100 YouTube API search calls/day (configurable via `YOUTUBE_DAILY_SEARCH_LIMIT`)

---

### 4. Academic Researcher Agent

**Role:** Searches open-access scholarly repositories for papers and articles relevant to each learning step.

**Sources searched in parallel:**
| Source | Coverage | Special Feature |
|--------|----------|-----------------|
| **OpenAlex** | Broad multidisciplinary (250M+ works) | Free, open metadata |
| **Semantic Scholar** | Computer science, biomedical, and more | AI-generated TLDR summaries |
| **arXiv** | STEM preprints | Free full-text PDFs |

**Mode adaptations:**
- **Deep Dive mode:** Returns up to 3 papers per step — full depth
- **Visual mode:** Returns up to 2 papers per step — lighter academic load
- **Bite-Sized mode:** **Skips academic search entirely** — focuses on quick understanding

---

### 5. Quiz Agent

**Role:** Dynamically generates 2–3 comprehension check questions based on the Socratic Tutor's explanation.

**What it does:**
- Reads the tutor's explanation (up to 3000 characters of context)
- Generates a mix of question types for variety:

| Question Type | Description |
|---------------|-------------|
| **Multiple Choice** | 4 options (A, B, C, D), one correct, with plausible distractors |
| **True/False** | A nuanced statement — avoids being trivially obvious |
| **Fill in the Blank** | A sentence with a key term blanked out (`___`) |

- Each question includes an **explanation** of why the correct answer is correct
- Difficulty calibrates to the student's Education Level
- Questions are **always derived from the explanation content** — never test external knowledge

**Execution order:** The Quiz Agent runs **after** the Socratic Tutor completes because it needs the explanation as input context.

**Model:** Configurable via `QUIZ_AGENT_MODEL` in `.env` (default: `llama-3.1-8b-instant`)  
**Temperature:** `0.4` (moderate — balanced between variety and accuracy)

---

### 6. Synthesizer Agent

**Role:** A **read-only** agent that assembles outputs from all worker agents into structured WebSocket events for the client.

**What it does:**
- Collects all agent outputs from SharedMemory after a step is processed
- Converts them into typed WebSocket events in a specific delivery order:
  1. YouTube Clip events (show media first)
  2. Academic Paper events
  3. Socratic Questions event
  4. Quiz event
  5. Step Complete event
- Does **not** write to SharedMemory — purely an output assembly layer

---

## Learning Modes

Learning Modes control how all agents adapt their output style, depth, and content selection. Students choose a mode in the sidebar before starting a session.

### 🎬 Visual Mode
> Best for: Students who learn by seeing and watching

| Agent | Adaptation |
|-------|------------|
| **Orchestrator** | Focuses on concepts that can be demonstrated visually. Concise step descriptions. |
| **Socratic Tutor** | Shorter explanations (3–5 paragraphs). Uses vivid, descriptive language. References accompanying video clips. |
| **YouTube Curator** | Returns up to **3 video clips** per step — emphasizes visual learning. |
| **Academic Researcher** | Returns up to **2 papers** per step — lighter reading load. |
| **Quiz Agent** | Standard 2–3 questions per step. |

### 🔬 Deep Dive Mode
> Best for: Students who want thorough, rigorous understanding

| Agent | Adaptation |
|-------|------------|
| **Orchestrator** | Includes theoretical foundations, proofs, and research-level depth in step descriptions. |
| **Socratic Tutor** | Thorough, rigorous explanations (5–8 paragraphs). Includes mathematical notation where relevant. References academic sources. |
| **YouTube Curator** | Returns up to **3 video clips** per step. |
| **Academic Researcher** | Returns up to **3 papers** per step — maximum depth. |
| **Quiz Agent** | Standard 2–3 questions, calibrated to higher difficulty. |

### ⚡ Bite-Sized Mode
> Best for: Quick revision or time-constrained learning

| Agent | Adaptation |
|-------|------------|
| **Orchestrator** | Maximum **4 steps**. Each should take 2–3 minutes. Ultra-concise descriptions. |
| **Socratic Tutor** | Ultra-concise explanations (2–3 paragraphs max). Uses bullet points. Gets straight to the core insight. |
| **YouTube Curator** | Returns only the **1 best clip** per step. |
| **Academic Researcher** | **Completely skipped** — no academic papers in this mode. |
| **Quiz Agent** | Standard 2–3 questions, kept simple and fast. |

---

## Education Levels

Education Levels control how all agents calibrate **language complexity, vocabulary, and analogy style**. The student selects their level in the sidebar before starting.

| Level | Target Audience | Adaptation |
|-------|-----------------|------------|
| 🏫 **Middle School** | Ages 11–14 | Simple vocabulary. Analogies from daily life, sports, games. No jargon. |
| 🎒 **High School** | Ages 15–18 | Introduces some technical terms with definitions. Science-fair level depth. |
| 🏛️ **Undergraduate** | College students | Full technical vocabulary. Can reference textbook-level concepts and equations. |
| 🎓 **Graduate** | Master's / PhD students | Research-level depth. Discusses edge cases, open problems, and current literature. |
| 💡 **General Curious** | Any curious adult | Assumes no specific background. Clear but not condescending. Accessible yet substantive. |

Both the **Socratic Tutor** and **Quiz Agent** adapt their language, examples, and difficulty based on the selected education level.

---

## Gamification & XP System

EduTechAI includes a full gamification layer to keep students motivated and engaged.

### XP Rewards

| Action | XP Earned |
|--------|-----------|
| Completing a milestone step | **50 XP** base (+ streak bonus) |
| Each correct quiz answer | **20 XP** per question |
| 100% quiz accuracy bonus | **+30 XP** extra |
| Completing an entire session | **+100 XP** bonus |
| Streak multiplier | **+10%** per consecutive day (capped at 10 days) |

### Leveling System

The system has **10 levels** with escalating XP thresholds:

| Level | Title | XP Required |
|-------|-------|-------------|
| 1 | Curious Explorer | 0 |
| 2 | Knowledge Seeker | 100 |
| 3 | Quick Learner | 300 |
| 4 | Deep Thinker | 600 |
| 5 | Rising Scholar | 1,000 |
| 6 | Concept Master | 1,500 |
| 7 | Wisdom Weaver | 2,200 |
| 8 | Knowledge Architect | 3,000 |
| 9 | Enlightened Mind | 4,000 |
| 10 | Grand Sage | 5,500 |

The **Progress Header** in the UI displays:
- Current level and title
- Total XP earned
- Streak count
- Progress bar to next level
- Journey progress (steps completed out of total)

---

## How a Learning Session Works (End-to-End)

Here is the complete flow from when a student enters a topic to when they complete a step:

```
1. Student enters topic → Selects Learning Mode & Education Level → Clicks "Start Learning Journey"
                                        │
                                        ▼
2. Orchestrator Agent runs:
   • Analyzes the topic
   • Detects prerequisite gaps (if any)
   • Produces 4–7 milestone steps
   • Writes the learning plan to SharedMemory
                                        │
                                        ▼
3. UI displays the milestone step navigation bar
   Student lands on Step 1 (or Step 0 if prerequisite warmup exists)
                                        │
                                        ▼
4. Worker agents execute IN SEQUENCE for the active step:
   a) Socratic Tutor Agent   → Writes explanation + Socratic questions
   b) YouTube Curator Agent  → Writes timestamped video clips
   c) Academic Researcher    → Writes papers (skipped in Bite-Sized mode)
   d) Quiz Agent             → Writes quiz questions (uses tutor's explanation)
                                        │
                                        ▼
5. UI renders the step workspace:
   LEFT COLUMN:                         RIGHT COLUMN:
   ┌─────────────────────┐              ┌─────────────────────┐
   │ Step title & desc   │              │ 🎬 YouTube Clip     │
   │                     │              │ (auto-jumps to      │
   │ Socratic Explanation│              │  relevant timestamp) │
   │ (glassmorphism card)│              ├─────────────────────┤
   │                     │              │ 📚 Academic Papers  │
   │ 🤔 Socratic Qs     │              │ (with TLDR & PDF)   │
   │                     │              ├─────────────────────┤
   │ 💬 Follow-up Chat   │              │ 📝 Quiz             │
   │ (ask the tutor)     │              │ (submit → earn XP)  │
   └─────────────────────┘              └─────────────────────┘
                                        │
                                        ▼
6. Student submits quiz answers:
   • Instant grading with per-question feedback
   • XP calculated and awarded
   • Step marked as complete
   • "Advance to Next Step" button appears
                                        │
                                        ▼
7. Student advances → Step repeats from (4) for next milestone
   OR completes all steps → 🎉 Celebration with balloons!
```

---

## Session Persistence & History

### What Gets Persisted

The entire `SharedMemory` state is serialized to JSON and stored in the database after every significant action. This means:

| Data | Stored? | Location |
|------|---------|----------|
| Learning plan (all steps) | ✅ | `SessionRecord.state_json` |
| Socratic explanations | ✅ | Inside `state_json` → `step_results` |
| YouTube clips (with timestamps) | ✅ | Inside `state_json` → `step_results` |
| Academic papers | ✅ | Inside `state_json` → `step_results` |
| Quiz questions & correct answers | ✅ | Inside `state_json` → `step_results` |
| Conversation history (all turns) | ✅ | Inside `state_json` → `conversation_history` |
| Quiz scores per step | ✅ | `StepProgress.quiz_score` |
| XP earned | ✅ | `GamificationRecord.xp_earned` |
| Streak count | ✅ | `GamificationRecord.streak_count` |
| Step completion status | ✅ | `StepProgress.status` + `completed_at` |

### Database Tables

| Table | Purpose |
|-------|---------|
| `sessions` | Session metadata + full `SharedMemory` serialized as JSON |
| `step_progress` | Per-step completion status and quiz scores |
| `gamification` | XP, streak count, level, and level title |

---

## Step Navigation (Go Back / Forward)

EduTechAI supports **free navigation between steps** via the Milestone Step Navigation Bar at the top of the workspace.

### How It Works

- All milestone steps are displayed as interactive buttons: `✅ Step 1` `🟡 Step 2` `⚪ Step 3` ...
- **Status icons:**
  - `✅` — Completed step
  - `🟡` — Currently active step
  - `⚪` — Not yet started
- Clicking any step button **instantly navigates** to that step
- **Going back to a completed step** re-displays all cached outputs (explanation, videos, papers, quiz) **without re-running the AI agents**
- This is possible because all outputs are stored in `SharedMemory.step_results` and remain in memory throughout the session
- Step results are also **persisted to the database** via `SessionRecord.state_json`, enabling session recovery

---

## Technology Stack

| Component | Technology |
|-----------|------------|
| **Frontend** | Streamlit (interactive Python UI) |
| **Backend API** | FastAPI (async REST + WebSocket) |
| **LLM Inference** | Groq Cloud (default) / Ollama (local) / Any OpenAI-compatible API |
| **Default Model** | Llama 3.1 8B Instant (configurable per agent) |
| **YouTube Search** | YouTube Data API v3 |
| **Transcript Extraction** | youtube-transcript-api |
| **Vector Store** | ChromaDB (for transcript semantic search) |
| **Academic Search** | OpenAlex API, Semantic Scholar API, arXiv API |
| **Database** | SQLite (default) / PostgreSQL (production) via SQLAlchemy async ORM |
| **Data Validation** | Pydantic v2 |
| **Real-time Streaming** | WebSocket (FastAPI + Streamlit) |
| **Python Version** | 3.12+ |

---

## Project Structure

```
EduTechAI/
├── main.py                     # Entry point — starts uvicorn server
├── ui.py                       # Streamlit frontend (552 lines)
├── config.py                   # Pydantic settings (reads from .env)
├── .env.example                # Environment variable template
├── pyproject.toml              # Project metadata & dependencies
├── requirements.txt            # Pip dependencies
│
├── agents/                     # AI Agent implementations
│   ├── base.py                 # Abstract base class for all agents
│   ├── orchestrator.py         # Supervisor — decomposes topic into steps
│   ├── socratic_tutor.py       # Teaching agent — Socratic explanations
│   ├── youtube_curator.py      # Finds timestamped YouTube clips
│   ├── academic_researcher.py  # Searches academic paper repositories
│   ├── quiz_agent.py           # Generates comprehension quizzes
│   └── synthesizer.py          # Assembles outputs into WebSocket events
│
├── models/                     # Data models
│   ├── schemas.py              # Pydantic schemas (API + domain models)
│   ├── shared_memory.py        # SharedMemory — central agent state
│   └── db_models.py            # SQLAlchemy ORM models (persistence)
│
├── services/                   # External service integrations
│   ├── llm_client.py           # Provider-agnostic LLM client (Groq/Ollama)
│   ├── youtube_client.py       # YouTube API + transcript + ChromaDB
│   ├── academic_client.py      # OpenAlex, Semantic Scholar, arXiv
│   ├── database.py             # SQLAlchemy async engine & sessions
│   ├── session_manager.py      # Session CRUD (serialize/deserialize)
│   ├── gamification.py         # XP, levels, and streak calculations
│   ├── vector_store.py         # ChromaDB vector store for transcripts
│   └── web_search.py           # Web search utility
│
├── prompts/                    # LLM prompt templates (Markdown)
│   ├── orchestrator.md         # Orchestrator system prompt
│   ├── socratic_tutor.md       # Socratic Tutor system prompt
│   └── quiz_agent.md           # Quiz Agent system prompt
│
├── app/                        # FastAPI application
│   ├── main.py                 # App factory, CORS, lifespan handlers
│   └── routers/
│       ├── learning.py         # REST endpoints for learning sessions
│       ├── quiz.py             # REST endpoints for quiz submission
│       └── websocket.py        # WebSocket endpoint for real-time streaming
│
└── data/                       # Runtime data (auto-created)
    ├── edutechai.db            # SQLite database
    └── chroma_db/              # ChromaDB vector store
```

---

## Getting Started

### Prerequisites

- **Python 3.12+** (check with `python --version`)
- **Groq API Key** — Get one free at [console.groq.com](https://console.groq.com)
- **YouTube Data API Key** — Get one from [Google Cloud Console](https://console.cloud.google.com/apis/library/youtube.googleapis.com)
- *(Optional)* OpenAlex email, Semantic Scholar API key

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/zees007/edutech-ai-based-learning-platform.git
   cd edutech-ai-based-learning-platform
   ```

2. **Create a virtual environment:**
   ```bash
   python -m venv .venv
   # Windows
   .venv\Scripts\activate
   # macOS/Linux
   source .venv/bin/activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```
   Or using the project directly:
   ```bash
   pip install -e .
   ```

4. **Install development dependencies (optional):**
   ```bash
   pip install -e ".[dev]"
   ```

### Configuration

1. **Copy the example environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env` and fill in your API keys:**
   ```env
   # Required
   GROQ_API_KEY=gsk_your_key_here
   YOUTUBE_API_KEY=your_youtube_api_key_here

   # Optional (improves academic search)
   OPENALEX_EMAIL=your_email@example.com
   SEMANTIC_SCHOLAR_API_KEY=your_key_here
   ```

3. **Model configuration (optional):** You can assign different models to different agents:
   ```env
   ORCHESTRATOR_MODEL=llama-3.1-8b-instant
   SOCRATIC_TUTOR_MODEL=llama-3.1-8b-instant
   QUIZ_AGENT_MODEL=llama-3.1-8b-instant
   ```

### Running the Application

**Option 1 — Streamlit Frontend (recommended for interactive use):**
```bash
streamlit run ui.py
```
Opens at `http://localhost:8501`

**Option 2 — FastAPI Backend (for API/WebSocket access):**
```bash
python main.py
```
Server starts at `http://127.0.0.1:8000`  
API docs at `http://127.0.0.1:8000/docs`

**Option 3 — Using the project script:**
```bash
edutechai
```

---

## API Endpoints

### REST API

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/health` | Health check — returns `{ "status": "healthy", "version": "0.1.0" }` |
| `POST` | `/api/learn` | Start a new learning session (topic, mode, level) |
| `GET` | `/api/sessions/{session_id}` | Retrieve an existing session |
| `POST` | `/api/quiz/submit` | Submit quiz answers and get grading results |

### WebSocket

| Endpoint | Description |
|----------|-------------|
| `ws://localhost:8000/ws/{session_id}` | Real-time streaming of agent outputs |

**WebSocket Event Types:**
- `plan` — Learning plan created (steps list)
- `explanation_chunk` — Streamed token from Socratic Tutor
- `socratic_questions` — Guiding questions for a step
- `youtube_clip` — Video clip found with timestamp
- `academic_paper` — Paper found from scholarly sources
- `quiz` — Quiz questions ready
- `step_complete` — All agents finished for a step
- `xp_update` — Student earned XP
- `error` — An error occurred (with recovery flag)

---

## Configurable LLM Providers

EduTechAI uses a **provider-agnostic LLM client** that works with any OpenAI-compatible API. Switch providers by editing `.env` — zero code changes needed.

### Groq Cloud (Default — Fast Inference)
```env
LLM_PROVIDER=groq
LLM_BASE_URL=https://api.groq.com/openai/v1
GROQ_API_KEY=gsk_your_key_here
ORCHESTRATOR_MODEL=llama-3.1-8b-instant
```

### Ollama (Local — No API Key Needed)
```env
LLM_PROVIDER=ollama
LLM_BASE_URL=http://localhost:11434/v1
ORCHESTRATOR_MODEL=llama3.1:8b
```

### Any OpenAI-Compatible API
```env
LLM_PROVIDER=openai_compatible
LLM_BASE_URL=https://your-provider.com/v1
GROQ_API_KEY=your_api_key
ORCHESTRATOR_MODEL=your-model-name
```

The client includes **automatic retry with exponential backoff** for rate limit errors (configurable via `GROQ_MAX_RETRIES` and `GROQ_RETRY_DELAY`).

---

## Database

### Default: SQLite (Zero Configuration)
```env
DATABASE_URL=sqlite+aiosqlite:///./data/edutechai.db
```
The SQLite database is created automatically in the `data/` directory on first run.

### Production: PostgreSQL
```env
DATABASE_URL=postgresql+asyncpg://user:password@localhost:5432/edutechai
```
Install the PostgreSQL driver:
```bash
pip install asyncpg
# or
pip install -e ".[postgres]"
```

The database uses **SQLAlchemy async ORM**, so switching between SQLite and PostgreSQL requires only changing the `DATABASE_URL` — no code changes.

---

## Future Roadmap

- **User authentication** — User accounts, login, and personal dashboards
- **Achievement badges** — Unlock achievements for learning milestones
- **Spaced repetition** — Revisit topics at scientifically optimal intervals
- **Collaborative learning** — Study groups and peer discussions
- **Mobile responsive** — Optimized mobile frontend
- **Export notes** — Download learning summaries as PDF

---

<p align="center">
  Built with ❤️ by <strong>EduTechAI</strong> — Making learning adaptive, engaging, and fun.
</p>
]]>
