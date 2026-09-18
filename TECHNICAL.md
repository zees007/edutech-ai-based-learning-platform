# 🏗️ EduTechAI — Deep Technical Architecture & Multi-Agent Specification

This document provides comprehensive technical documentation for the EduTechAI autonomous multi-agent educational platform. It details the underlying architectural patterns, agent specifications, state management, prompt engineering frameworks, and data flows.

---

## 📑 Table of Contents

1. [Architectural Overview](#1-architectural-overview)
   - [The Blackboard Design Pattern](#the-blackboard-design-pattern)
   - [Unified MilestoneStep Schema Architecture](#unified-milestonestep-schema-architecture)
2. [SharedMemory State Machine](#2-sharedmemory-state-machine)
   - [Schema & Slot Allocation](#schema--slot-allocation)
   - [Unified MilestoneStep Domain Model](#unified-milestonestep-domain-model)
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
   - [Gamification, Journey Completion & Review Flow](#gamification-journey-completion--review-flow)
6. [Data Persistence & Session Recovery](#6-data-persistence--session-recovery)
7. [Configuration & Model Routing](#7-configuration--model-routing)
8. [Role-Based Access Control (RBAC) & Subscription Tiers](#8-role-based-access-control-rbac--subscription-tiers)
   - [Privilege Catalog & Domain Grouping](#privilege-catalog--domain-grouping)
   - [Role-to-Privilege Matrix](#role-to-privilege-matrix)
   - [Runtime Limit Resolution](#runtime-limit-resolution)
   - [Dual-Layer Enforcement Architecture](#dual-layer-enforcement-architecture)
9. [Session Export Engine](#9-session-export-engine)
   - [Document Generation Pipeline](#document-generation-pipeline)
   - [Mermaid Diagram Handling](#mermaid-diagram-handling)
10. [Scholarly Research & Academic Preprints Engine (Client & Server)](#10-scholarly-research--academic-preprints-engine-client--server)
    - [Dual-Mode Execution Architecture](#dual-mode-execution-architecture)
    - [Smart Download & Action URL Construction Engine](#smart-download--action-url-construction-engine)
    - [AI Key Insight Extraction & Fallback Hierarchy](#ai-key-insight-extraction--fallback-hierarchy)
    - [Client Presentation & Micro-Interactions](#client-presentation--micro-interactions)
    - [Backend REST API & Privilege Gating](#backend-rest-api--privilege-gating)
11. [Flutter Client Architecture, Interactive Workspace & Gamification](#11-flutter-client-architecture-interactive-workspace--gamification)
    - [Dual-Panel Split Learning Workspace](#dual-panel-split-learning-workspace)
    - [State Management & Provider Architecture](#state-management--provider-architecture)
    - [WebSocket Event Streaming Lifecycle](#websocket-event-streaming-lifecycle)
    - [Real-Time Gamification, XP Rewards & Leveling](#real-time-gamification-xp-rewards--leveling)
    - [Sequenced Level-Up & Journey Complete Celebrations](#sequenced-level-up--journey-complete-celebrations)
    - [Optimistic State & Silent Background Synchronization](#optimistic-state--silent-background-synchronization)
    - [Formative Knowledge Check Quiz Engine](#formative-knowledge-check-quiz-engine)
    - [UI Performance & 60FPS Rendering Optimizations](#ui-performance--60fps-rendering-optimizations)

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
                         │   Flutter UI Client   │
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

### Unified MilestoneStep Schema Architecture
Historically, multi-agent frameworks decoupled agent outputs into fragmented structures (such as a separate `step_results: dict[int, StepResult]` map). In EduTechAI, this schema was modernized into a **single-source-of-truth model**:
- **All agent outputs are consolidated directly onto `MilestoneStep`** inside `SharedMemory.steps: list[MilestoneStep]`.
- The Tutor's pedagogical explanation, Socratic questions, curated YouTube clips, academic papers, generated quizzes, student submitted answers, and calculated scores live on the step itself.
- This eliminates state drift between worker agent outputs, database persistence (Supabase / PostgreSQL), and client-side reactive rendering.

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

    # Curriculum & Milestone Plan (Written by Orchestrator & updated by worker agents)
    has_prerequisite_gap: bool
    prerequisite_summary: str | None
    steps: list[MilestoneStep]
    current_step_index: int

    # Session-Level Literature (Curated once per session by Academic Researcher)
    academic_papers: list[AcademicPaper]

    # Conversation History (Append-only dialogue turns)
    conversation_history: list[ConversationTurn]

    # Gamification State
    xp_earned: int
    steps_completed: int
    quiz_scores: dict[int, float]
    streak_count: int
```

### Unified MilestoneStep Domain Model

Defined in `models/schemas.py`, the `MilestoneStep` encapsulates all curricular, multimedia, pedagogical, and evaluation data for a single step:

```python
class MilestoneStep(BaseModel):
    index: int
    title: str
    description: str
    is_prerequisite: bool = False
    prerequisite: str | None = None
    status: StepStatus = StepStatus.PENDING
    estimated_minutes: int = 5

    # Pedagogical Content (Written by Socratic Tutor Agent)
    tutor_explanation: str | None = None
    socratic_questions: list[str] = Field(default_factory=list)
    follow_up_count: int = 0

    # Curated Resources (Written by YouTube Curator & Academic Researcher)
    videos: list[YouTubeClip] = Field(default_factory=list)
    papers: list[AcademicPaper] = Field(default_factory=list)

    # Formative Assessment & Student Answers (Written by Quiz Agent & Submit API)
    quiz: list[QuizQuestion] | None = None
    quiz_score: float | None = None
    user_answers: dict[int, str] = Field(default_factory=dict)
    user_full_answers: dict[int, str] = Field(default_factory=dict)
```

> **Note on Gamification Architecture:** Currently, progression data (`GamificationRecord`) is bound directly to a `session_id`. This means XP, Leveling, and Streaks are calculated per-topic journey. A future roadmap enhancement will migrate these isolated records to a unified global User Profile.

### Agent Read / Write Matrix

| Agent | Reads from `SharedMemory` | Writes to `SharedMemory` | Execution Trigger |
| :--- | :--- | :--- | :--- |
| **Orchestrator** | `topic`, `student_level`, `learning_mode`, `conversation_history` | `steps`, `has_prerequisite_gap`, `prerequisite_summary` | Session Creation / Plan Update |
| **Academic Researcher** | `topic`, `student_level`, `learning_mode` | `academic_papers` (session), `steps[i].papers` (step) | Session Creation (Once per Topic) |
| **Socratic Tutor** | `topic`, `steps[i]`, `student_level`, `learning_mode`, `conversation_history` | `steps[i].tutor_explanation`, `steps[i].socratic_questions` | Step Execution & Follow-up Chat |
| **YouTube Curator** | `topic`, `steps[i]`, `student_level`, `learning_mode` | `steps[i].videos` | Concurrent Step Execution |
| **Quiz Agent** | `topic`, `steps[i]`, `steps[i].tutor_explanation`, `student_level` | `steps[i].quiz` | Post-Tutor Step Execution |
| **Quiz Evaluator API** | `steps[i].quiz`, student answers | `steps[i].quiz_score`, `steps[i].user_answers`, `xp_earned` | Quiz Submission (`POST /api/v1/quiz/submit`) |
| **Synthesizer** | `steps[i]`, `academic_papers`, `xp_earned` | *None (Read-Only Event Streamer)* | WebSocket / Client Dispatch |

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
- **Tri-Repository Parallel Ingestion:**
  Executes concurrent non-blocking API queries via `asyncio.gather()` across three open scholarly engines:
  1. **OpenAlex API (`https://api.openalex.org/works`):**
     - Queries multidisciplinary works, ranked by `relevance_score:desc` and filtered by `cited_by_count`.
     - **Inverted Index Abstract Reconstruction:** OpenAlex stores abstracts as inverted position maps (`abstract_inverted_index: {"word": [0, 4, ...], ...}`) due to publisher constraints. The agent reconstructs readable prose by mapping token positions to an integer-keyed dictionary, sorting positions in ascending order, and joining the reassembled text tokens.
     - Selects primary Open Access URLs (`work['open_access']['oa_url']`) and canonical DOIs.
  2. **Semantic Scholar API (`https://api.semanticscholar.org/graph/v1/paper/search`):**
     - Requests fields: `title,authors,year,abstract,tldr,openAccessPdf,externalIds,url`.
     - **AllenAI SciTLDR Extraction:** Ingests machine learning-generated 1-sentence scientific summaries (`tldr.text`) produced by the Allen Institute for AI's TLDR model, providing high-density conceptual overviews.
     - Resolves direct open-access PDF links (`openAccessPdf.url`).
  3. **arXiv API (`http://export.arxiv.org/api/query`):**
     - Queries cutting-edge STEM preprints in XML format, parsing entry metadata, authors, abstracts, and direct PDF links (`https://arxiv.org/pdf/{arxiv_id}`).
- **Deduplication & Relevance Ranking:**
  - Normalizes paper titles by stripping non-alphanumeric characters and lowercasing.
  - De-duplicates DOIs and normalized titles across the 3 repositories.
  - Sorts remaining candidates by descending weighted `relevance_score`.
- **Pedagogical Level & Mode Gating:**
  - `student_level in ["middle_school", "high_school"]`: Automatically **skipped (0 API calls)** to prevent cognitive overload.
  - `learning_mode == "bite_sized"`: Automatically **skipped (0 API calls)** to preserve rapid scanning speed.
  - `undergraduate`, `graduate`, `general`: Fetches 3 landmark papers (scaled to 4 in `deep_dive` mode).
- **0ms Step Latency & Event Streaming:**
  - Literature is curated once during session initialization and cached in `memory.academic_papers`.
  - In WebSocket step progression, cached papers are instantly bound to `memory.steps[i].papers` without repeated network hops, and emitted to clients as `AcademicPaperEvent` payloads via the Synthesizer Agent.

---

### 5. Quiz Agent (Grounded Assessment)
- **Module:** `agents/quiz_agent.py`
- **Prompt Template:** `prompts/quiz_agent.md`
- **Model Role:** Context-Grounded Comprehension Evaluation
- **Temperature:** `0.4`
- **Execution Constraint:** Runs **after** the Socratic Tutor completes to ingest `memory.steps[i].tutor_explanation`.
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
   │                     ├── Stream Expl. ──────┼───────────────────┼─────────────────►│ (steps[i].tutor_explanation)
   │◄── Typing Stream ───┤                      ├── Find Clips ─────┼─────────────────►│ (steps[i].videos)
   │                     │                      │                   ├── Gen Quiz ─────►│ (steps[i].quiz)
   │◄── Render Content ──┴──────────────────────┴───────────────────┴──────────────────┤
```

### Follow-up Socratic Chat Sequence

```
User (UI)                  Learning Router                 SocraticTutor           SharedMemory
   │                             │                               │                      │
   ├── Ask Follow-up ───────────►│                               │                      │
   │   (question, step_index)    ├── Read Step & History ────────┼─────────────────────►│ (step.tutor_explanation)
   │                             ├── Dispatch Socratic Followup ─►│                      │
   │                             │   (step title, expl, turns)   ├── Generate Answer ───┤
   │                             │◄── Return Socratic Response ──┤                      │
   │                             ├── Append Dialogue Turn ───────┼─────────────────────►│ (conversation_history)
   │◄── Render Tutor Reply ──────┴───────────────────────────────┴──────────────────────┤
```

### Gamification, Journey Completion & Review Flow

```
User (UI)             Quiz/Step Route        Gamification Engine      Celebration Modal      SharedMemory / DB
   │                         │                       │                       │                       │
   ├── Submit Quiz ─────────►│                       │                       │                       │
   │   (answers)             ├── Grade & Save ───────┼───────────────────────┼──────────────────────►│ (steps[i].quiz_score)
   │                         ├── Calculate XP/Streak►│                       │                       │
   │◄── QuizResult (+XP) ────┤                       │                       │                       │
   │                         ├── XPUpdateEvent (WS) ─┼──────────────────────►│ (Level Up? Trigger)   │
   │◄── LevelUp Modal ───────┴───────────────────────┴───────────────────────┤                       │
   │    (pauses advance until dismissed)                                     │                       │
   │                                                                         │                       │
   ├── [Complete Journey 🏆]─►POST /step/N/complete                          │                       │
   │                         ├── Mark Complete & +Bonus ─────────────────────┼──────────────────────►│ (steps[N].status = 'complete')
   │                         │                       │                       │                       │
   │◄── Optimistic Local Lock(All steps marked 'complete' in memory @ 0ms)───┼───────────────────────┤
   │◄── Journey Complete Modal (Trophy, Confetti, XP Bonus, Stats) ──────────┤                       │
   │    │                                                                    │                       │
   │    ├── (In Parallel: Silent Background Sync via loadSession(silent=true))──────────────────────►│ Reconcile DB Snapshot
   │    │                                                                    │                       │
   ├── Tap "Review Steps" (Any time: 50ms or 5s)                             │                       │
   │   ├── Failsafe ensureJourneyCompleted()                                 │                       │
   │   └── Modal Fades Out ──────────────────────────────────────────────────┴───────────────────────┤
   │◄── ⚡ Zero-Flicker Completed Review Workspace (Quizzes answered, Socratic Tutor review ready)──┤
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

---

## 8. Role-Based Access Control (RBAC) & Subscription Tiers

EduTechAI employs a fine-grained RBAC architecture defining **33 privilege constants** grouped into 6 system domains (`app/privileges_config.py`).

### Privilege Catalog & Domain Grouping

1. **Root / SuperAdmin (`ET_ALL`)**: System-wide bypass granting access to all API routes and UI actions.
2. **User Administration (`ET_FULL_ACCESS_USER`, `ET_CREATE_USER`, `ET_VIEW_USER`, `ET_EDIT_USER`, `ET_RETIRE_USER`, `ET_SEARCH_USER`, `ET_ASSIGN_USER_ROLE`)**: Manages identity and user status.
3. **Role & Privilege Administration (`ET_FULL_ACCESS_ROLE`, `ET_CREATE_ROLE`, `ET_VIEW_ROLE`, `ET_EDIT_ROLE`, `ET_RETIRE_ROLE`, `ET_SEARCH_ROLE`, `ET_VIEW_PRIVILEGE`)**: Dynamic custom role creation and privilege assignment.
4. **Subscription Management (`ET_FULL_ACCESS_SUBSCRIPTION`, `ET_VIEW_SUBSCRIPTION`, `ET_UPGRADE_SUBSCRIPTION`, `ET_DOWNGRADE_SUBSCRIPTION`)**: Plan lifecycle control.
5. **Learning & Agent Gating**:
   - `ET_START_LEARNING_SESSION`: Initiate topic journeys
   - `ET_INTERACT_LEARNING_SESSION`: Step progression & quiz interaction
   - `ET_VIEW_LEARNING_HISTORY`: Historical session retrieval
   - `ET_ACCESS_ADVANCED_MODES`: Unlocks **Visual** & **Deep Dive** modes
   - `ET_ACCESS_YOUTUBE_BASIC` & `ET_ACCESS_YOUTUBE_ADVANCED`: Tier-based YouTube video curation limits
   - `ET_ACCESS_ACADEMIC_SEARCH`: Access open-access research papers & TL;DRs
   - `ET_ACCESS_FULL_TEXT_RESEARCH`: Deep scholarly text analysis
   - `ET_REGENERATE_STEP`: Trigger alternative analogy generation
   - `ET_UNLIMITED_FOLLOW_UPS`: Bypass follow-up chat caps
   - `ET_EXPORT_MARKDOWN`: Export learning sessions to `.md`
   - `ET_EXPORT_PDF`: Export learning sessions to `.pdf`
6. **Assessment & Quizzes (`ET_FULL_ACCESS_QUIZ`, `ET_GENERATE_QUIZ`, `ET_SUBMIT_QUIZ`)**: Formative assessment execution.

### Role-to-Privilege Matrix

```
┌───────────────────────────────┬──────┬─────┬───────┬───────┐
│ Privilege Code                │ Free │ Pro │ Ultra │ Admin │
├───────────────────────────────┼──────┼─────┼───────┼───────┤
│ ET_START_LEARNING_SESSION     │ Yes  │ Yes │ Yes   │ All   │
│ ET_INTERACT_LEARNING_SESSION  │ Yes  │ Yes │ Yes   │ All   │
│ ET_VIEW_LEARNING_HISTORY      │ Yes  │ Yes │ Yes   │ All   │
│ ET_GENERATE_QUIZ              │ Yes  │ Yes │ Yes   │ All   │
│ ET_SUBMIT_QUIZ                │ Yes  │ Yes │ Yes   │ All   │
│ ET_VIEW_SUBSCRIPTION          │ Yes  │ Yes │ Yes   │ All   │
│ ET_UPGRADE_SUBSCRIPTION       │ Yes  │ Yes │ Yes   │ All   │
│ ET_ACCESS_YOUTUBE_BASIC       │ Yes  │ Yes │ Yes   │ All   │
│ ET_DOWNGRADE_SUBSCRIPTION     │ -    │ Yes │ Yes   │ All   │
│ ET_ACCESS_ADVANCED_MODES      │ -    │ Yes │ Yes   │ All   │
│ ET_ACCESS_YOUTUBE_ADVANCED    │ -    │ Yes │ Yes   │ All   │
│ ET_ACCESS_ACADEMIC_SEARCH     │ -    │ Yes │ Yes   │ All   │
│ ET_REGENERATE_STEP            │ -    │ Yes │ Yes   │ All   │
│ ET_EXPORT_MARKDOWN            │ -    │ Yes │ Yes   │ All   │
│ ET_ACCESS_FULL_TEXT_RESEARCH  │ -    │ -   │ Yes   │ All   │
│ ET_UNLIMITED_FOLLOW_UPS       │ -    │ -   │ Yes   │ All   │
│ ET_EXPORT_PDF                 │ -    │ -   │ Yes   │ All   │
│ ET_ALL (SuperAdmin Bypass)    │ -    │ -   │ -     │ Yes   │
└───────────────────────────────┴──────┴─────┴───────┴───────┘
```

### Runtime Limit Resolution

Limits are parameterized in `config.py` and dynamically evaluated based on the active user's role hierarchy and privilege set:

```python
# 1. Monthly Learning Session Quotas (app/routers/learning.py)
is_premium = has_privilege(current_user, ET_ACCESS_ADVANCED_MODES)
if not is_premium:
    monthly_sessions = await session_manager.get_monthly_session_count(current_user.id)
    if monthly_sessions >= 10:  # Free Tier capped at 10 sessions/mo
        raise ForbiddenException(error_code="SESSION_QUOTA_EXCEEDED", errors="Monthly limit reached.")

# 2. Video Curation Capacity per Step
limit = settings.free_youtube_limit          # Default: 1
if "Ultra" in roles or "Admin" in roles:
    limit = settings.ultra_youtube_limit     # Default: 5
elif "Pro" in roles:
    limit = settings.pro_youtube_limit       # Default: 3

# 3. Socratic Follow-Up Chat Limits
followup_limit = settings.free_followup_limit   # Default: 1
if "Pro" in roles:
    followup_limit = settings.pro_followup_limit # Default: 5
if "ET_UNLIMITED_FOLLOW_UPS" in privilege_codes:
    is_unlimited = True
```

### Dual-Layer Enforcement Architecture

1. **FastAPI Route Layer**: Enforces permissions and quotas at the API perimeter using dependency injection:
   ```python
   @router.get("/{session_id}/pdf", dependencies=[Depends(require_privilege(ET_EXPORT_PDF))])
   ```
2. **Flutter UI Client Presentation Layer**: Performs reactive UI element gating:
   - Evaluates monthly session counts and prevents journey initialization when quotas are exceeded.
   - Disables suggested question chips and shows warning banners when follow-up limits are met.
   - Renders contextual upgrade messaging (`Upgrade to Pro` vs `Upgrade to Ultra`).
   - Slices agent outputs (`step.videos[:limit]`) to guarantee tier compliance.

---

## 9. Session Export Engine

The export system converts learning sessions stored in `SharedMemory` into portable study artifacts (`app/routers/exports.py`).

### Document Generation Pipeline

```
┌─────────────────────┐
│    SharedMemory     │ (Extracts: metadata, step explanations, YouTube
└──────────┬──────────┘  timestamps, academic papers, quiz feedback)
           │
           ▼
┌─────────────────────┐
│ generate_markdown() │ ──► Outputs: Rich Markdown (.md) document
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Regex Sanitization  │ (Substitutes JS-dependent ```mermaid blocks with
└──────────┬──────────┘  callout guidance for compatible .md readers)
           │
           ▼
┌─────────────────────┐
│ markdown.markdown() │ (Parses Markdown → HTML with tables extension)
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  xhtml2pdf (pisa)   │ ──► Outputs: A4 PDF byte stream with styled
└─────────────────────┘     typography, blue headers, and data tables
```

### Mermaid Diagram Handling
- **Markdown Export**: Fenced ` ```mermaid ` code blocks are preserved verbatim, rendering interactively in modern Markdown editors (Obsidian, GitHub, Typora).
- **PDF Export**: Since headless PDF generation does not execute browser JavaScript, raw Mermaid text is stripped and replaced with a clean instructional callout pointing to the Markdown file.

---

## 10. Scholarly Research & Academic Preprints Engine (Client & Server)

EduTechAI integrates a multi-tier academic literature engine designed to connect students with landmark open-access preprints, peer-reviewed articles, and research insights. The architecture operates symmetrically across both the **Flutter Workspace Client** and the **FastAPI Multi-Agent Server**.

```
                           ┌──────────────────────────────────────────────┐
                           │            Flutter Workspace UI             │
                           │       (academic_papers.dart Widget)          │
                           └──────────────┬───────────────────────────────┘
                                          │
                   ┌──────────────────────┴──────────────────────┐
                   │                                             │
      [1. Pre-curated Mode]                            [2. Live Search Mode]
                   │                                             │
                   ▼                                             ▼
       SharedMemory State / WebSocket               Riverpod AcademicService
       (memory.academic_papers)                  (lib/core/services/academic_service.dart)
                   │                                             │
                   │                                  ┌──────────┴──────────┐
                   ▼                                  ▼                     ▼
        FastAPI Backend Proxy                 Semantic Scholar          OpenAlex
     (GET /api/v1/academic/search)               Graph API              Works API
                   │                                  │                     │
    ┌──────────────┼──────────────┐                   │                     │
    ▼              ▼              ▼                   │                     │
OpenAlex    Semantic Scholar    arXiv                 │                     │
  API             API            API                  │                     │
    │              │              │                   │                     │
    └──────────────┴──────┬───────┴───────────────────┴─────────────────────┘
                          │
                          ▼
            [4-Tier Smart Action URL Engine]
            [7-Tier AI Key Insight Pipeline]
```

### Dual-Mode Execution Architecture

The presentation component (`lib/presentation/pages/learning/widgets/workspace/academic_papers.dart`) operates in two distinct operational modes:

1. **Pre-curated Session Mode (Zero Latency):**
   - When a user enters a milestone step, `ActiveLearningWorkspace` passes `currentStep.papers` into `AcademicPapers(papers: currentStep.papers)`.
   - These papers are pre-fetched during session initialization by the `AcademicResearcherAgent` and cached in `SharedMemory.academic_papers`.
   - The UI renders instantly without issuing network requests.

2. **On-Demand Live Search Mode:**
   - If a step lacks pre-curated papers or if the student triggers a query from the live search bar, the widget executes `_searchLive(query)`.
   - This invokes `ref.read(academicServiceProvider).searchAll(cleanQuery, maxResults: 5)` via `lib/core/services/academic_service.dart`.
   - Searches are executed in parallel across external APIs (`Semantic Scholar` and `OpenAlex`), deduplicated client-side, and dynamically bound to the view.

---

### Smart Download & Action URL Construction Engine

Scholarly preprints often suffer from broken links, paywalls, or missing full-text files. `_PaperCardState` in `academic_papers.dart` eliminates dead links through a **4-tier URL resolution engine**:

```dart
// Resolution logic in _PaperCardState
final String rawPdf = (paper is Map ? paper['pdf_url'] : null)?.toString().trim() ?? '';
final String rawDoi = (paper is Map ? paper['doi'] : null)?.toString().trim() ?? '';
final String rawUrl = (paper is Map ? paper['url'] : null)?.toString().trim() ?? '';
```

#### Tier 1: Direct Open-Access PDF (`rawPdf`)
- Evaluates `paper['pdf_url']`.
- If the URL ends with `.pdf` or contains `arxiv.org/pdf`:
  - **Action Type:** Direct PDF Download / Viewer
  - **Visual Icon:** `Icons.picture_as_pdf_rounded` (Distinct red/blue PDF badge)
  - **Tooltip:** `"Download / Read PDF"`
- If `rawPdf` is present but is an open-access repository landing page:
  - **Visual Icon:** `Icons.open_in_new_rounded`
  - **Tooltip:** `"Open Full Paper"`

#### Tier 2: Canonical DOI Resolver (`rawDoi`)
- When no direct PDF URL is available, checks `paper['doi']`.
- Automatically prepends the international DOI resolver if not already formatted as an HTTP URI:
  ```dart
  actionUrl = rawDoi.startsWith('http') ? rawDoi : 'https://doi.org/$rawDoi';
  ```
- **Tooltip:** `"Read Paper via DOI"`
- **Visual Icon:** `Icons.open_in_new_rounded`

#### Tier 3: Repository / Publisher Direct URL (`rawUrl`)
- If DOI is unavailable, falls back to `paper['url']` (e.g., Semantic Scholar paper page or OpenAlex canonical ID).
- **Tooltip:** `"Open Paper on $source"`

#### Tier 4: Dynamic Query-Search Fallback (Zero Dead Links)
- If the paper metadata contains no valid URL, DOI, or PDF target, the engine generates an on-the-fly scholarly search URL using the paper's title:
  1. Sanitizes punctuation (`?`, `*`, `"`, regex whitespace).
  2. Encodes the title via `Uri.encodeComponent(sanitizedTitle)`.
  3. Generates targeted query routes based on source:
     - **arXiv:** `https://arxiv.org/search/?query={title}&searchtype=all`
     - **OpenAlex:** `https://openalex.org/works?search={title}`
     - **Semantic Scholar (Default):** `https://www.semanticscholar.org/search?q={title}`
- **Guarantee:** 100% of rendered cards possess a functional, login-free destination.

All links are dispatched using Flutter's `url_launcher`:
```dart
await launchUrl(Uri.parse(actionUrl), mode: LaunchMode.externalApplication);
```

---

### AI Key Insight Extraction & Fallback Hierarchy

To maximize comprehension without cognitive fatigue, each paper card renders an **AI Key Insight** capsule.

#### Sources of Intelligence:
1. **AllenAI SciTLDR (Semantic Scholar):**
   - Semantic Scholar runs the Allen Institute for AI's SciTLDR deep learning model over scholarly texts to generate single-sentence extreme summaries.
   - Extracted directly from `item['tldr']['text']`.
2. **Inverted Index Abstract Reconstruction (OpenAlex):**
   - OpenAlex stores abstracts as inverted position indices (`abstract_inverted_index`).
   - Both the backend `AcademicClient` and client `AcademicService` reconstruct continuous prose by sorting integer position keys and concatenating the token stream.

#### 7-Tier Fallback Resolution Chain:
In `academic_papers.dart`, the insight text is parsed through an exhaustive fallback chain to guarantee meaningful context is always displayed:

```dart
final candidates = [
  paper['tldr'],               // 1. AllenAI SciTLDR Machine-Learning Summary
  paper['ai_summary'],         // 2. Client/Server AI Synthesized Summary
  paper['abstract'],           // 3. Complete Author Abstract
  paper['summary'],            // 4. Pre-print Abstract (arXiv)
  paper['description'],        // 5. Repository Description
  paper['snippet'],            // 6. Search Snippet
  paper['relevance_snippet'],  // 7. Context Relevance Match
];
```
- **Synthesized Fallback:** If all metadata keys are empty, it dynamically synthesizes a fallback statement:
  `"Seminal scholarly paper exploring key concepts of $title. Published in $year via $source."`

#### Dynamic UX Expander:
- Renders via `RichText` with bold blue `💡 AI Key Insight:` heading.
- Collapsed by default to `maxLines: 2` with ellipsis overflow.
- If summary length exceeds 110 characters, an interactive toggle (`Read more...` / `Show less`) allows seamless in-place expansion without breaking the card grid.

---

### Client Presentation & Micro-Interactions

- **Glassmorphic Surface:** Cards use a subtle translucent background (`Colors.white.withValues(alpha: 0.02)`) with a fine outline border (`Color(0xFF60A5FA).withValues(alpha: 0.2)`).
- **Hover Micro-Animations:** Built with `MouseRegion` and `AnimatedContainer` (220ms transition). On pointer hover:
  - Background opacity increases to `0.05`.
  - Border illumination increases to `0.5` opacity.
  - Generates a blue elevation glow (`BoxShadow(color: Color(0xFF60A5FA).withValues(alpha: 0.12), blurRadius: 16, offset: Offset(0, 4))`).
- **Metadata Badging:** Dynamic source chip (`SEMANTIC SCHOLAR`, `OPENALEX`, `ARXIV`) and publication year badge.

---

### Backend REST API & Privilege Gating

In addition to WebSocket streaming during session milestones, the backend exposes a dedicated REST endpoint for direct academic searches:

```http
GET /api/v1/academic/search?query={topic}&max_results={limit}
```

- **Module:** `devzees-edutechai-server/app/routers/learning.py`
- **Security Dependency:** `require_privilege(ET_ACCESS_ACADEMIC_SEARCH)`
- **Response Schema:** `list[AcademicPaper]`
- **Execution:** Invokes `AcademicClient.search_all()` to query OpenAlex, Semantic Scholar, and arXiv concurrently with server-side deduplication and relevance scoring.

---

## 11. Flutter Client Architecture, Interactive Workspace & Gamification

The Flutter client replaces the original Streamlit interface with a fully reactive, high-performance web/desktop/mobile frontend. It introduces a modular architecture handling real-time streaming AI generation, resilient WebSocket connections, formative quiz evaluation, gamification rewards, and a dual-panel split workspace.

### Dual-Panel Split Learning Workspace

The core learning interface is built around `SplitLearningWorkspace` (`lib/presentation/pages/learning/widgets/workspace/split_learning_workspace.dart`), implementing an interactive split layout designed for maximum cognitive engagement:

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                  UnifiedLearningCommandHub (Topic & XP Bar)                  │
├──────────────────────────────────────┬───────────────────────────────────────┤
│           Left Panel (55%)           │           Right Panel (45%)           │
│        [Socratic Tutor Chat]         │       [Learning Resources Panel]      │
│  - Formatted LaTeX & Markdown prose  │  - Segmented Tab 1: Recommended Videos│
│  - Architecture Mermaid Diagrams     │  - Segmented Tab 2: Academic Papers   │
│  - Suggested Socratic Question Chips │  - Segmented Tab 3: Knowledge Quiz    │
│  - Conversational Follow-Up Input    │  - Pinned Knowledge Check Gating Bar  │
│  - Fullscreen Maximization Overlay   │  - Fullscreen Maximization Overlay    │
└──────────────────────────────────────┴───────────────────────────────────────┘
```

1. **Fluid Draggable Splitter:**
   - Left-to-right split ratio defaults to `0.55`, bounded between `0.30` and `0.70` via `_buildDraggableDivider()`.
   - Listens to horizontal drag deltas, dynamically updating layout constraints without rebuilding subtrees.
2. **Fullscreen Maximization Overlays:**
   - Both panels feature expand/restore toggle controls (`_toggleFullscreen`).
   - Uses Flutter `OverlayEntry` with `ClipRRect` and backdrop filters (`ImageFilter.blur(sigmaX: 16, sigmaY: 16)`) to maximize either the Socratic dialogue or resource exploration into an immersive distraction-free view.
3. **Adaptive Mobile Workspace:**
   - On viewports narrower than 800px, dynamically switches from the dual-pane desktop row to `_MobileTabbedWorkspace`, providing a bottom tabbed experience (Tutor, Videos, Papers, Quiz) with safe area insets.

---

### State Management & Provider Architecture

The client utilizes **Riverpod** for robust, reactive state management. The core component is `ActiveSessionNotifier` (`lib/core/providers/active_session_provider.dart`), which coordinates the session lifecycle:

- **State Container (`ActiveSessionState`)**: Holds the full `SessionResponse` payload, the active step index, UI loading states (`isLoading`, `isSynthesizing`), and error contexts.
- **REST API + WebSocket Hybrid Model**:
  - Initial session creation (`startNewSession()`) uses REST to trigger the Orchestrator agent to generate the milestone plan.
  - Upon receiving the `SessionResponse`, the client establishes a WebSocket connection (`LearningWebSocketService`) linked to the `sessionId`.
  - Step execution is triggered via the WebSocket using `sendStartStep()`.
  - When the final `step_complete` event is received via WebSocket, the client makes a single REST HTTP GET (`loadSession()`) to fetch the fully completed, structured payload from the database to guarantee state consistency.

---

### WebSocket Event Streaming Lifecycle

Unlike blocking batch execution, the Flutter client processes real-time streamed chunks to provide immediate user feedback.

```
Client (Riverpod)                   WebSocket Server                      Agents
       │                                  │                                  │
       ├── connect(sessionId) ───────────►│                                  │
       │                                  ├── "plan" event ─────────────────►│
       │◄── "plan" event ─────────────────┤                                  │
       │                                  │                                  │
       ├── sendStartStep(index) ─────────►│                                  │
       │                                  ├── Start Step Execution ─────────►│
       │                                  │                                  │
       │◄── "explanation_chunk" ──────────┼── stream_explanation() ◄─────────┤ (Socratic Tutor)
       │◄── "youtube_clip" ───────────────┼── gather() ◄─────────────────────┤ (YouTube Curator)
       │◄── "academic_paper" ─────────────┼── gather() ◄─────────────────────┤ (Academic Researcher)
       │◄── "quiz" ───────────────────────┼── execute() ◄────────────────────┤ (Quiz Agent)
       │◄── "socratic_questions" ─────────┼── create_event() ◄───────────────┤ (Synthesizer)
       │◄── "step_complete" ──────────────┼── create_event() ◄───────────────┤ (Synthesizer)
       │                                  │                                  │
       ├── HTTP GET /api/sessions/{id} ──►│                                  │
       │◄── Full Session Payload ─────────┤                                  │
       │                                  │                                  │
```

---

### Real-Time Gamification, XP Rewards & Leveling

EduTechAI integrates a comprehensive gamification framework motivating students through immediate positive reinforcement:

1. **Standardized Level Progression:**
   Managed by `GamificationUtils` (`lib/core/providers/gamification_provider.dart`), calculating levels from cumulative XP:
   - **Level 1 (0–99 XP):** Novice
   - **Level 2 (100–249 XP):** Explorer
   - **Level 3 (250–499 XP):** Practitioner
   - **Level 4 (500–999 XP):** Specialist
   - **Level 5 (1000+ XP):** Master
2. **Real-Time Event Broadcasting:**
   - Completing a step emits an `XPUpdateEvent` (+50 base XP, multiplied by streak bonuses).
   - Submitting a quiz emits an `XPUpdateEvent` (+20 XP per correct question + accuracy bonus).
   - Completing a journey awards a +100 XP completion bonus (subject to role multipliers: 2.0x for Ultra/Admin, 1.5x for Pro).
3. **Animated Command Hub:**
   `UnifiedLearningCommandHub` binds the XP count and level progress bar using `TweenAnimationBuilder`, animating smoothly between values upon every backend event.

---

### Sequenced Level-Up & Journey Complete Celebrations

To prevent visual conflicts when multiple celebrations or loading states trigger simultaneously, the platform enforces strict lifecycle sequencing:

1. **Level-Up Celebration Modal (`LevelUpCelebration`):**
   - Renders a glowing glassmorphic dialog with animated trophy, pulsing rings, particle systems, level titles, and XP earned counters.
   - Built with an internal double-fire guard so tapping the modal or allowing the 4-second auto-timer to expire invokes `onComplete()` exactly once.
2. **Sequenced Step Advancement:**
   - In `completeAndAdvanceStep(stepIndex)`, if a level-up occurred, step transition pauses until the user dismisses the celebration.
   - Only upon modal dismissal does the client transition to the next step, ensuring the user is never rushed and the `NeuralInferenceLoader` never clashes with the celebration.
3. **Dynamic Final Milestone Button States:**
   - On the final milestone step before completion: The primary button updates from *"Next Step"* to **"Complete Journey 🏆"** with an amber/gold gradient.
   - After journey completion: The button transitions into a celebratory badge: **`[ 🏆 Journey Completed 🎉 ]`**.
4. **Grand Journey Completion Celebration (`JourneyCompleteCelebration`):**
   - Displays a 3-metric summary card (Total XP earned, Quiz accuracy percentage, Milestones mastered) alongside the +100 XP completion bonus.
   - Offers two distinct actions:
     - **"Review Steps"**: Dismisses the celebration and lets the student review all unlocked milestones, diagrams, quizzes, and chat with the Socratic AI tutor.
     - **"New Journey"**: Resets active session state and redirects to create a new topic.
5. **Multi-Celebration Pipeline:**
   - When finishing the final step triggers a level up, the Level-Up celebration displays first. Once dismissed, the Journey Complete celebration opens immediately.

---

### Optimistic State & Silent Background Synchronization

To eliminate visual lag and loading spinners when transitioning from celebrations to the review workspace, the client implements the **Stale-While-Revalidate (SWR) / Optimistic Background Sync** pattern:

1. **Synchronous Local Completion (0ms):**
   - The moment the final step is completed in `completeAndAdvanceStep()`, the client immediately sets `status: 'complete'` across all steps, sets `stepsCompleted: session.steps.length`, and updates learning history in memory.
   - Before the celebration modal finishes animating onto the screen, the workspace underneath is already 100% completed.
2. **Silent Background Revalidation:**
   - `loadSession(sessionId, silent: true)` is dispatched in parallel without setting `isLoading: true` or `isSynthesizing: true`.
   - While the student views their completion bonus and stats (typically 2–5 seconds), the client silently fetches the authoritative database state from Supabase without UI flicker.
3. **Dismissal Failsafe (`ensureJourneyCompleted`):**
   - Wired into `onReview` in `LearningPage`. Whether the user spends 5 seconds on the celebration or dismisses it in **0.05 seconds** (or hits `Esc`), `ensureJourneyCompleted()` guarantees all steps remain unlocked, marked complete, and that quiz answers remain visible.
4. **Boundary Clamping:**
   - In `loadSession`, if `stepIndex >= response.steps.length`, it clamps to `response.steps.length - 1` rather than resetting to `0`, ensuring the view stays on the completed final milestone rather than jumping back to Step 1.
5. **Review Mode Awareness:**
   - In `SplitLearningWorkspace`, `isReviewing` evaluates `widget.status == 'complete'`, ensuring the final milestone step displays the "Review" badge and hides forward navigation buttons.

---

### Formative Knowledge Check Quiz Engine

The `KnowledgeCheckQuiz` widget (`lib/presentation/pages/learning/widgets/workspace/knowledge_check_quiz.dart`) provides grounded formative assessment:

1. **Multi-Question Formats:** Supports multiple-choice, true/false, and fill-in-the-blank questions.
2. **Answer Persistence:**
   - Preserves user answers and scores across step transitions.
   - Auto-restores submitted answers from local step state (`userAnswers`, `userFullAnswers`) upon revisiting completed milestones.
3. **Interactive Step Gating:**
   - Forward navigation is gated until the quiz is completed.
   - Passing the quiz unlocks the step transition bar and awards gamification XP.

---

### UI Performance & 60FPS Rendering Optimizations

1. **Lazy Reconnection Avoidance**: `loadSession(sessionId, fromStepComplete: true, silent: true)` prevents redundant WebSocket disconnections/reconnections when refreshing data after completed steps, eliminating duplicate `plan` executions.
2. **Event Guarding (`isLoading` Barrier)**: `SocraticTutorChat` ignores high-frequency `explanation_chunk` events while the global provider is in an `isLoading` state, preventing wasteful `setState()` triggers and animation controller allocations behind the loader.
3. **Optimized Concurrent Backend Execution**: The WebSocket backend executes the `QuizAgent`, `YouTubeCuratorAgent`, and `AcademicResearcherAgent` concurrently via `asyncio.gather()`, maintaining the token-by-token streaming experience of the `SocraticTutorAgent` while accelerating milestone readiness.

---

### Smart Step Regeneration Engine

To balance flexibility with API cost-efficiency, the client features a highly optimized Step Regeneration pipeline:
1. **Targeted State Clearing**: `regenerateCurrentStep()` optimistically wipes `tutorExplanation`, `socraticQuestions`, and `quiz` from the local `MilestoneStep`, but intentionally preserves `videos` and `papers`. 
2. **Seamless Inline Loaders**: Instead of invoking the massive full-screen `NeuralInferenceLoader` (which is reserved exclusively for Step 0 of a new journey), regeneration uses the inline `Socratic Tutor is preparing...` skeleton loader to maintain visual context.
3. **Idempotent Agent Execution**: On the backend, `websocket.py` checks `if step and not step.videos` before dispatching the `YouTubeCuratorAgent` and `AcademicResearcherAgent`. Because the `topic` and step `title` do not change during regeneration, the pre-existing curated resources remain highly relevant. Bypassing these agents saves tokens, avoids rate limits (YouTube Data API), and dramatically accelerates regeneration latency.
