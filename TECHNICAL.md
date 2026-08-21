# 🏗️ EduTechAI — Deep Technical Architecture & Multi-Agent Specification

This document provides comprehensive technical documentation for the EduTechAI autonomous multi-agent educational platform. It details the underlying architectural patterns, agent specifications, state management, prompt engineering frameworks, and data flows.

---

## 📑 Table of Contents

1. [Architectural Overview](#1-architectural-overview)
   - [The Blackboard Design Pattern](#the-blackboard-design-pattern)
   - [State Flow Lifecycle](#state-flow-lifecycle)
2. [SharedMemory State Machine](#2-sharedmemory-state-machine)
   - [Schema & Slot Allocation](#schema--slot-allocation)
   - [Agent Read / Write Matrix](#agent-read--write-matrix)
3. [Agent Deep Dives](#3-agent-deep-dives)
   - [1. Orchestrator Agent (Supervisor)](#1-orchestrator-agent-supervisor)
   - [2. Socratic Tutor Agent (Pedagogical Engine)](#2-socratic-tutor-agent-pedagogical-engine)
   - [3. YouTube Curator Agent (Semantic Video Deep-Linking)](#3-youtube-curator-agent-semantic-video-deep-linking)
   - [4. Academic Researcher Agent (Scholarly Curation)](#4-academic-researcher-agent-scholarly-curation)
   - [5. Quiz Agent (Grounded Assessment)](#5-quiz-agent-grounded-assessment)
   - [6. Synthesizer Agent (Event Assembly Layer)](#6-synthesizer-agent-event-assembly-layer)
4. [Prompt Engineering & In-Context Calibration](#4-prompt-engineering--in-context-calibration)
   - [Pedagogical Calibration Rules](#pedagogical-calibration-rules)
   - [Mermaid Diagram Generation Rules](#mermaid-diagram-generation-rules)
5. [End-to-End Sequence Diagrams](#5-end-to-end-sequence-diagrams)
   - [Session Initialization Sequence](#session-initialization-sequence)
   - [Step Execution Sequence](#step-execution-sequence)
   - [Follow-up Socratic Chat Sequence](#follow-up-socratic-chat-sequence)
6. [Data Persistence & Session Recovery](#6-data-persistence--session-recovery)
7. [Configuration & Model Routing](#7-configuration--model-routing)

---

## 1. Architectural Overview

### The Blackboard Design Pattern
EduTechAI implements the **Blackboard Architectural Pattern** for autonomous multi-agent coordination. In traditional agent swarms, direct agent-to-agent communication creates $O(N^2)$ network dependencies and complex message-passing topologies. 

In EduTechAI:
- **No agent communicates directly with another agent.**
- All agents read from and write to a centralized, validated state object (`SharedMemory`).
- Agents inherit from `BaseAgent` (`agents/base.py`) which enforces the contract: receive `SharedMemory` reference $\rightarrow$ inspect required slots $\rightarrow$ execute task $\rightarrow$ write results directly to designated slots.

```
                         ┌───────────────────────┐
                         │   Streamlit / Client  │
                         └───────────┬───────────┘
                                     │
                                     ▼
                         ┌───────────────────────┐
                         │      SharedMemory     │
                         └───────────┬───────────┘
                                     │
       ┌─────────────────────────────┼─────────────────────────────┐
       ▼                             ▼                             ▼
[Orchestrator]             [Socratic Tutor]              [Academic Researcher]
(Decomposes Topic)        (Generates Lessons)            (Curates Literature)
       │                             │                             │
       │                   ┌─────────┴─────────┐                   │
       │                   ▼                   ▼                   │
       │          [YouTube Curator]       [Quiz Agent]             │
       │         (Semantic Search)     (Grounded Quizzes)          │
       │                   │                   │                   │
       └───────────────────┴─────────┬─────────┴───────────────────┘
                                     ▼
                            [Synthesizer Agent]
                       (WebSocket Event Streaming)
```

---

## 2. SharedMemory State Machine

The central state object is defined in `models/shared_memory.py` as a Pydantic `BaseModel`.

### Schema & Slot Allocation

```python
class SharedMemory(BaseModel):
    # Session Identity & Calibration
    session_id: str
    user_id: str | None
    topic: str
    learning_mode: LearningMode      # visual | deep_dive | bite_sized
    student_level: str              # middle_school | high_school | undergraduate | graduate | general
    created_at: datetime

    # Curriculum & Milestone Plan (Written by Orchestrator)
    has_prerequisite_gap: bool
    prerequisite_summary: str | None
    steps: list[MilestoneStep]
    current_step_index: int

    # Session-Level Literature (Written by Academic Researcher)
    academic_papers: list[AcademicPaper]

    # Per-Step Agent Outputs (Keyed by step index)
    step_results: dict[int, StepResult]

    # Conversation History (Append-only)
    conversation_history: list[ConversationTurn]

    # Gamification State
    xp_earned: int
    steps_completed: int
    quiz_scores: dict[int, float]
    streak_count: int
```

### Agent Read / Write Matrix

| Agent | Reads from `SharedMemory` | Writes to `SharedMemory` | Execution Trigger |
| :--- | :--- | :--- | :--- |
| **Orchestrator** | `topic`, `student_level`, `learning_mode`, `conversation_history` | `steps`, `has_prerequisite_gap`, `prerequisite_summary` | Session Creation / Plan Update |
| **Academic Researcher** | `topic`, `student_level`, `learning_mode` | `academic_papers` | Session Creation (Once per Topic) |
| **Socratic Tutor** | `topic`, `steps[i]`, `student_level`, `learning_mode`, `conversation_history` | `step_results[i].explanation`, `step_results[i].socratic_questions` | Step Execution & Follow-up Chat |
| **YouTube Curator** | `topic`, `steps[i]`, `student_level`, `learning_mode` | `step_results[i].youtube_clips` | Concurrent Step Execution |
| **Quiz Agent** | `topic`, `steps[i]`, `step_results[i].explanation`, `student_level` | `step_results[i].quiz` | Post-Tutor Step Execution |
| **Synthesizer** | `steps`, `step_results[i]`, `academic_papers`, `xp_earned` | *None (Read-Only Event Streamer)* | WebSocket / Client Dispatch |

---

## 3. Agent Deep Dives

### 1. Orchestrator Agent (Supervisor)
- **Module:** `agents/orchestrator.py`
- **Prompt Template:** `prompts/orchestrator.md`
- **Model Role:** Curriculum Decomposition & Prerequisite Detection
- **Temperature:** `0.3` (deterministic structured output)
- **Mechanism:**
  1. Formats `{topic}`, `{student_level}`, and `{learning_mode}` into the prompt template.
  2. Injects up to the last 5 conversation turns for context continuity.
  3. Dispatches via `llm.chat_json()` requesting strict JSON response format:
     ```json
     {
       "has_prerequisite_gap": true,
       "prerequisite_summary": "Explanation of required baseline knowledge",
       "steps": [
         {
           "index": 0,
           "title": "Step title",
           "description": "Learning objective",
           "is_prerequisite": true,
           "estimated_minutes": 5
         }
       ]
     }
     ```
  4. Parses results into `MilestoneStep` Pydantic models.
  5. Implements graceful fallback to a default foundational step if LLM generation encounters an exception.

---

### 2. Socratic Tutor Agent (Pedagogical Engine)
- **Module:** `agents/socratic_tutor.py`
- **Prompt Template:** `prompts/socratic_tutor.md`
- **Model Role:** Interactive, Analogy-Driven Socratic Instruction
- **Temperature:** `0.7` (empathetic, creative pedagogical delivery)
- **Key Pedagogical Features:**
  - **Progressive Analogy Strategy:**
    - `is_first_step == True`: Introduces a **Core Anchor Analogy** based on `student_level`.
    - `is_first_step == False`: Focuses on **direct mechanics, code/equations, and industry applications**, referencing the Step 1 anchor without inventing repetitive metaphors.
  - **Automated Mermaid Visuals:**
    - In `visual` and `deep_dive` modes, automatically outputs ```` ```mermaid graph TD ... ``` ```` architecture diagrams.
    - In `bite_sized` mode, strictly avoids diagrams for ultra-fast scanning.
  - **Streaming & Delimiter Parsing:**
    - Generates token-by-token streams using `llm.chat_stream()`.
    - Automatically parses and separates explanation prose from interactive guiding questions using the `**Socratic Questions:**` boundary.

---

### 3. YouTube Curator Agent (Semantic Video Deep-Linking)
- **Module:** `agents/youtube_curator.py`
- **Services:** `services/youtube_client.py`, ChromaDB
- **Model Role:** Video Discovery & Transcript Semantic Timestamp Search
- **Search Pipeline:**
  1. **Query Construction:** Formats clean search string: `{Topic} {Cleaned Step Title}`.
  2. **API Search:** Queries YouTube Data API v3 for top relevant educational videos.
  3. **Transcript Extraction:** Uses `youtube-transcript-api` to extract timestamped subtitle text.
  4. **Vector Embedding & Semantic Search:** Embeds transcript segments in **ChromaDB** using vector embeddings. Matches `{Step Title} {Step Description}` against transcript chunks to identify the exact seconds (`start_seconds`, `end_seconds`) where the concept is explained.
  5. Returns structured `YouTubeClip` objects with deep links (e.g. `https://youtube.com/watch?v=...&t=145`).

---

### 4. Academic Researcher Agent (Scholarly Curation)
- **Module:** `agents/academic_researcher.py`
- **Services:** `services/academic_client.py`
- **Model Role:** Pre-print & Peer-Reviewed Literature Curation
- **Architecture:** **Session-Level Landmark Curation (Search Once per Session)**
- **Gating & Optimization:**
  - `student_level in ["middle_school", "high_school"]`: Automatically **skipped (0 API calls)**.
  - `learning_mode == "bite_sized"`: Automatically **skipped (0 API calls)**.
  - `undergraduate`, `graduate`, `general`: Executes 3-way parallel search across:
    - **OpenAlex API:** Queries multidisciplinary works, ranking by citation count (`cited_by_count`) and inverted-index abstract reconstruction.
    - **Semantic Scholar API:** Queries AI-indexed literature with native extractive **TLDR** summaries.
    - **arXiv API:** Fetches STEM preprints with direct open-access PDF links.
  - **Deduplication Engine:** Merges duplicate DOIs and normalized titles, sorting by weighted relevance score.
  - **0ms Step Latency:** Results are cached in `memory.academic_papers` and instantly linked across all steps.

---

### 5. Quiz Agent (Grounded Assessment)
- **Module:** `agents/quiz_agent.py`
- **Prompt Template:** `prompts/quiz_agent.md`
- **Model Role:** Context-Grounded Comprehension Evaluation
- **Temperature:** `0.4`
- **Execution Constraint:** Runs **after** the Socratic Tutor completes to ingest `step_results[i].explanation`.
- **Question Types (Fixed 3-Question Battery):**
  1. `multiple_choice`: 4 options (A, B, C, D) with 1 correct answer and distractor rationale.
  2. `true_false`: Nuanced statement based strictly on the explanation text.
  3. `fill_in_blank`: Text with missing key term designated by `___`.
- **Strict Grounding Rule:** Questions must be 100% answerable from the tutor's explanation alone without requiring external knowledge.
- **Fallback Generator:** Generates structured template questions if LLM call fails.

---

### 6. Synthesizer Agent (Event Assembly Layer)
- **Module:** `agents/synthesizer.py`
- **Model Role:** Read-Only WebSocket Event Serializer
- **Event Lifecycle:**
  Converts SharedMemory contents into typed WebSocket event payloads in standard presentation order:
  1. `YouTubeClipEvent`
  2. `AcademicPaperEvent`
  3. `SocraticQuestionsEvent`
  4. `QuizEvent`
  5. `StepCompleteEvent`

---

## 4. Prompt Engineering & In-Context Calibration

### Pedagogical Calibration Rules

```
┌─────────────────┬───────────────────────────────┬───────────────────────────────┐
│ Education Level │ Anchor Analogy Domain (Step 1)│ Technical Depth (Steps 2+)   │
├─────────────────┼───────────────────────────────┼───────────────────────────────┤
│ Middle School   │ Video Games, Sports, Kitchen  │ 0 Jargon, Everyday Mechanics  │
│ High School     │ Cars, Smartphones, Social App │ Core Terminology Introduced   │
│ Undergraduate   │ Logistics, City Infrastructure│ Full Technical & Equation Form│
│ Graduate        │ Theoretical / Microservice    │ Edge-Cases & Formal Open Probs│
│ General Curious │ Accessible Adult Everyday Life│ Concrete Systems Thinking     │
└─────────────────┴───────────────────────────────┴───────────────────────────────┘
```

### Mermaid Diagram Generation Rules
- Required syntax: ```` ```mermaid graph TD ... ``` ```` or `graph LR`.
- All node text enclosed in double quotes: `A["Step A"] --> B["Step B"]`.
- Omitted entirely when `learning_mode == "bite_sized"`.

---

## 5. End-to-End Sequence Diagrams

### Session Initialization Sequence

```
User (UI)             Orchestrator         AcademicResearcher      SharedMemory
   │                       │                       │                    │
   ├── Start Session ─────►│                       │                    │
   │   (Topic, Mode, Lvl)  ├── Create Plan ───────┼───────────────────►│ (steps[])
   │                       │                       ├── Search Once ────►│ (academic_papers[])
   │                       │                       │   (OpenAlex/arXiv) │
   │◄── Render Workspace ──┴───────────────────────┴────────────────────┤
```

### Step Execution Sequence

```
User (UI)          SocraticTutor         YouTubeCurator         QuizAgent         SharedMemory
   │                     │                      │                   │                  │
   ├── Start Step(i) ───►│                      │                   │                  │
   │                     ├── Stream Expl. ──────┼───────────────────┼─────────────────►│ (explanation)
   │◄── Typing Stream ───┤                      ├── Find Clips ─────┼─────────────────►│ (youtube_clips)
   │                     │                      │                   ├── Gen Quiz ─────►│ (quiz)
   │◄── Render Content ──┴──────────────────────┴───────────────────┴──────────────────┤
```

---

## 6. Data Persistence & Session Recovery

Session persistence is handled by `services/session_manager.py`:
- Active sessions are stored in memory (`_sessions` dict) for real-time WebSocket communication.
- Full session snapshots are serialized to the database upon every milestone completion and mode toggle.
- When a user refreshes or returns to a session URL (`?session_id=...`), `sync_session_with_url()` restores the full state and agent outputs from PostgreSQL without re-running agents.

---

## 7. Configuration & Model Routing

Model assignments are centrally managed in `config.py` and configurable via `.env`:

```env
# Default Provider & Model Routing
LLM_PROVIDER=groq
ORCHESTRATOR_MODEL=llama-3.1-8b-instant
SOCRATIC_TUTOR_MODEL=llama-3.1-8b-instant
QUIZ_AGENT_MODEL=llama-3.1-8b-instant

# External Knowledge Services
YOUTUBE_DAILY_SEARCH_LIMIT=100
SEMANTIC_SCHOLAR_API_KEY=
OPENALEX_EMAIL=your-email@domain.com
```
