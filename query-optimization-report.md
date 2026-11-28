# EduTechAI — Query, Indexing & Scalability Audit Report

**Target Scale:** 1,00,000 users × 1,000 sessions/user = **10 Crore (100M) session rows**

> [!IMPORTANT]
> This audit covers every database query across all 12 service/router files, every ORM model's indexing, relationship loading strategy, connection pooling, and architectural patterns. Issues are ranked by severity for the 1-lakh-user scale.

---

## Executive Summary

| Category | Critical | High | Medium | Low |
|---|---|---|---|---|
| **Lazy-Loading / N+1 Bombs** | 2 | — | — | — |
| **Missing Indexes** | — | 6 | 3 | — |
| **Full-Table Scans** | 1 | 2 | — | — |
| **Connection Pool** | 1 | — | — | — |
| **Architectural** | 1 | 1 | 2 | — |
| **Query Refactoring** | — | 3 | 2 | 1 |

---

## 🔴 CRITICAL — Must Fix Before Production

### C1. ✅ FIXED — User Model: `lazy="selectin"` on `sessions`, `feedbacks`, `refresh_tokens` (and `SessionRecord.feedback`)

**File:** [db_models.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/models/db_models.py#L85-L105) & [db_models.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/models/db_models.py#L319-L327)

```python
# Before:
sessions: Mapped[list[SessionRecord]] = relationship(
    "SessionRecord", back_populates="user", cascade="all, delete-orphan",
    lazy="selectin",   # ← CATASTROPHIC at scale
)
feedbacks: Mapped[list[FeedbackRecord]] = relationship(
    "FeedbackRecord", back_populates="user", cascade="all, delete-orphan",
    lazy="selectin",   # ← CATASTROPHIC at scale
)
refresh_tokens: Mapped[list[RefreshToken]] = relationship(
    "RefreshToken", back_populates="user", cascade="all, delete-orphan",
    lazy="selectin",   # ← Also problematic
)
```

**Impact at 1L users × 1K sessions:**
- **Every `select(User)` query automatically loads ALL 1,000 sessions + ALL feedbacks + ALL refresh tokens** per user into memory.
- `get_current_user()` is called on **every authenticated request** — meaning every API call pulls 1,000+ session rows with their JSON `state_json` blobs (each can be 50KB–200KB).
- For a user with 1,000 sessions: a single login/auth check would transfer ~100MB+ from PostgreSQL.
- Admin endpoints like `search_users` (paginated 20 users) would load 20 × 1,000 = **20,000 session rows** per page load.
- Additionally, `SessionRecord.feedback` also used `lazy="selectin"`, causing every `User` and `SessionRecord` query (`search_user_sessions`, `get_user_performance`) to fire an extra `JOIN feedbacks` query.

**Fix Applied:**
1. Updated `User.sessions`, `User.feedbacks`, and `User.refresh_tokens` in [db_models.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/models/db_models.py#L85-L105) to `lazy="noload"` with `passive_deletes=True` (relying on existing `ON DELETE CASCADE` foreign keys).
2. Updated `SessionRecord.feedback` in [db_models.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/models/db_models.py#L319-L327) to `lazy="noload"` with `passive_deletes=True`.
3. Kept `User.roles`, `User.subscription`, `Role.privileges`, `Subscription.tier_ref`, and `SubscriptionTier.role` as `lazy="selectin"` so `get_current_user()`, `require_privilege()`, `/auth/me`, and `UserResponse` remain unaffected.
4. **Client Impact:** None — verified across server and `devzees-edutechai-client` that `.sessions`, `.feedbacks`, `.refresh_tokens`, and `SessionRecord.feedback` are never accessed or serialized in API responses.
5. **Verified (`pro@gmail.com`):** Single `User` fetch dropped from **11 SQL queries (2583 ms)** to **7 SQL queries (1719 ms)** with zero queries against `sessions`, `feedbacks`, or `refresh_tokens`, and **0 diffs** across `AuthService.get_user_current_profile`, `UserResponse`, and `UserService.get_user_with_roles_and_privileges`.

```python
sessions: Mapped[list[SessionRecord]] = relationship(
    "SessionRecord",
    back_populates="user",
    cascade="all, delete-orphan",
    passive_deletes=True,
    lazy="noload",
)
feedbacks: Mapped[list[FeedbackRecord]] = relationship(
    "FeedbackRecord",
    back_populates="user",
    cascade="all, delete-orphan",
    passive_deletes=True,
    lazy="noload",
)
refresh_tokens: Mapped[list[RefreshToken]] = relationship(
    "RefreshToken",
    back_populates="user",
    cascade="all, delete-orphan",
    passive_deletes=True,
    lazy="noload",
)
# And on SessionRecord:
feedback: Mapped[FeedbackRecord | None] = relationship(
    "FeedbackRecord",
    back_populates="session",
    uselist=False,
    cascade="all, delete-orphan",
    passive_deletes=True,
    lazy="noload",
)
```

---

### C2. ✅ FIXED — `get_user_performance()` Loads ALL User Sessions + ALL StepProgress Into Memory

**File:** [analytics_service.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/analytics_service.py#L328-L845)

```python
# Before:
# Fetches ALL sessions for user (up to 1,000 rows with state_json blobs)
sessions_query = (
    select(SessionRecord)
    .where(SessionRecord.user_id == user_id)
    .order_by(SessionRecord.created_at.desc())
)
all_user_sessions = list(sessions_res.scalars().all())

# Then fetches ALL StepProgress for ALL sessions (1,000 sessions × ~5 steps = 5,000+ rows)
sp_query = (
    select(StepProgress)
    .join(SessionRecord, ...)
    .where(SessionRecord.user_id == user_id)
)
all_step_records = list(sp_res.scalars().all())
```

**Impact:** For a user with 1,000 sessions averaging 5 steps each:
- Loads **1,000 SessionRecord rows** (each containing a large `state_json` JSON blob)
- Loads **5,000 StepProgress rows**
- All into Python memory, then iterated in Python loops
- With time range filtering done **in Python**, not SQL

**Fix Applied:**
1. **Eliminated `state_json` bulk transfer:** Replaced `select(SessionRecord)` with scalar column projection (`session_id`, `topic`, `learning_mode`, `total_steps`, `is_complete`, `created_at`, `updated_at`), completely avoiding loading `state_json` blobs and ORM relationship joins.
2. **Pushed time-window filtering into SQL `WHERE` clauses:**
   - For `StepProgress` (projected to 6 scalar columns): when `window_start` is set (`7d`, `30d`, `90d`, `1y`, `custom`), SQL filters `completed_at` to `[window_start - 30 min, window_end]` (30-min lookback preserves exact predecessor step clamping) plus `quiz_score IS NOT NULL AND completed_at IS NULL`.
   - For `SessionRecord`: when `window_start` is set, SQL fetches only sessions created in window, completed & updated in window, or referenced by filtered `StepProgress` rows.
3. **Added SQL `GROUP BY` step-summary aggregation for window-scoped runs:** Computes `total_rows`, `completed_rows`, and `last_completed_at` per candidate session in SQL so `topic_breakdown` completion percentages and `completed_session_ids` remain exact even for sessions spanning window boundaries.
4. **Added `_fetch_step_titles()` SQL JSONB extraction:** Queries `(session_id, step_index, title)` via PostgreSQL `CROSS JOIN LATERAL jsonb_array_elements((state_json::jsonb) -> 'steps') WITH ORDINALITY` solely for `quiz_session_ids` present in the window (with a non-PostgreSQL fallback), avoiding transferring `tutor_explanation`, `quiz`, `videos`, `academic_papers`, and `conversation_history`.
5. **Client Impact:** None — `PeriodPerformanceResponse` and `LearningDashboardResponse` payloads, rounding, sorting, and edge cases are 100% preserved.
6. **Verified (`pro@gmail.com`):** Diffed pre-fix vs post-fix across `7d`, `30d`, `90d`, `1y`, `all`, `custom`, and `get_user_dashboard("30d")` — **0 data diffs**, and query latency improved across every range (`90d`: 1099 ms → 446 ms; `1y`: 1061 ms → 413 ms; `all`: 636 ms → 310 ms).

---

## 🟠 HIGH — Significant Performance Issues

### H1. ✅ FIXED — Missing Composite Index: `sessions(user_id, created_at)` & `sessions(user_id, is_complete, updated_at)`

**Affected queries (run on every session listing + quota check):**
- `search_user_sessions()` — filters by `user_id`, orders by `is_complete`, `updated_at`
- `get_monthly_session_count()` — filters by `user_id` + `created_at >= start_of_month`
- `get_user_performance()` — filters by `user_id`, orders by `created_at`

**Current state:** Only a single-column index on `sessions.user_id`. At 100M session rows, sorting and date-range filtering requires expensive filesorts.

**Fix Applied:**
- Added `__table_args__` to `SessionRecord` in [db_models.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/models/db_models.py#L329-L332) with `Index("ix_sessions_user_created", "user_id", "created_at")` and `Index("ix_sessions_user_complete_updated", "user_id", "is_complete", "updated_at")`.
- Created and applied both indexes in Alembic migration [0014_add_scale_indexes_and_session_fks.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/alembic/versions/0014_add_scale_indexes_and_session_fks.py) (verified present in `edutechAI` schema).
- **Client Impact:** None.

### H2. ✅ FIXED — Missing Composite Index: `session_usage_logs(user_id, created_at)`

**File:** [db_models.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/models/db_models.py#L532-L537)

**Affected query:** `get_monthly_session_count()` runs `SELECT COUNT(*) FROM session_usage_logs WHERE user_id = ? AND created_at >= ?` on every session start.

**Fix Applied:**
- Added `Index("ix_session_usage_user_created", "user_id", "created_at")` to `SessionUsageLog.__table_args__` in [db_models.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/models/db_models.py#L535-L537).
- Created and applied in [0014_add_scale_indexes_and_session_fks.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/alembic/versions/0014_add_scale_indexes_and_session_fks.py) (verified present in `edutechAI` schema).
- **Client Impact:** None.

### H3. ✅ FIXED — Missing Composite Index: `step_progress(session_id, step_index)`

**Affected queries:**
- `save_step_progress()` — `WHERE session_id = ? AND step_index = ?`
- Bulk fetch in `update_session()` — `WHERE session_id = ?` (covered by existing single index)

**Currently have:** `ix_step_progress_session_status` on `(session_id, status)` — but `save_step_progress` filters by `(session_id, step_index)`.

**Fix Applied:**
- Added `Index("ix_step_progress_session_step", "session_id", "step_index", unique=True)` alongside `ix_step_progress_session_status` in `StepProgress.__table_args__` in [db_models.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/models/db_models.py#L357-L360).
- Verified `0` duplicate `(session_id, step_index)` rows in Supabase and applied the unique composite index via [0014_add_scale_indexes_and_session_fks.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/alembic/versions/0014_add_scale_indexes_and_session_fks.py).
- **Client Impact:** None.

### H4. ✅ FIXED — Missing Composite Index: `refresh_tokens(user_id, revoked_at)` & `(family_id, revoked_at)`

**Affected query:** `change_password()` and `logout_all()` run:
```python
select(RefreshToken).where(
    RefreshToken.user_id == user.id,
    RefreshToken.revoked_at.is_(None),
)
```
Also `rotate_refresh_token()` does family-scoped revocation.

**Fix Applied:**
- Added `Index("ix_refresh_token_user_active", "user_id", "revoked_at")` and `Index("ix_refresh_token_family_active", "family_id", "revoked_at")` to `RefreshToken.__table_args__` in [db_models.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/models/db_models.py#L440-L443).
- Created and applied both indexes in [0014_add_scale_indexes_and_session_fks.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/alembic/versions/0014_add_scale_indexes_and_session_fks.py) (verified present in `edutechAI` schema).
- **Client Impact:** None.

### H5. ✅ FIXED — `StepProgress` & `GamificationRecord` Joined with `SessionRecord` via String Column (Not FK)

**File:** [db_models.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/models/db_models.py#L345-L386)

```python
# Before:
session_id: Mapped[str] = mapped_column(String(24), index=True, nullable=False)
# No ForeignKey constraint!
```

**Impact:** At 100M sessions × 5 steps = 500M step_progress rows:
- JOINs between `step_progress.session_id` and `sessions.session_id` are string comparisons without referential integrity enforcement
- No CASCADE deletes — orphaned step_progress rows accumulate
- The JOIN in `analytics_service.py` (runs on every dashboard load) is expensive without FK-backed index alignment

**Fix Applied:**
1. Added `ForeignKey("sessions.session_id", ondelete="CASCADE")` to both `StepProgress.session_id` and `GamificationRecord.session_id`, along with `session = relationship("SessionRecord", lazy="noload")` in [db_models.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/models/db_models.py#L345-L386).
2. In [0014_add_scale_indexes_and_session_fks.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/alembic/versions/0014_add_scale_indexes_and_session_fks.py), cleaned up orphaned rows (found and removed 1 orphaned `gamification` row, 0 in `step_progress`) before adding `fk_step_progress_session_id` and `fk_gamification_session_id` with `ON DELETE CASCADE`.
3. Updated seeder [06_seed_trophies.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/scripts/seeder/06_seed_trophies.py#L248-L355) to insert and flush the parent `SessionRecord` before adding child `StepProgress` and `GamificationRecord` rows so FK constraints are always respected.
- **Client Impact:** None.

### H6. ✅ FIXED — Connection Pool is Undersized for 1L Concurrent Users

**File:** [database.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/database.py#L63-L78) & [config.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/config.py#L131-L138)

```python
# Before:
_engine = create_async_engine(
    settings.database_url,
    echo=settings.debug,       # ← echo=True in production kills perf
    connect_args=connect_args,
    pool_pre_ping=True,
    pool_recycle=300,
    # Missing: pool_size, max_overflow, pool_timeout
)
```

**Default SQLAlchemy pool:** `pool_size=5, max_overflow=10` → max 15 concurrent DB connections.

**Fix Applied:**
1. Added configurable settings in [config.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/config.py#L135-L138): `db_pool_size = 20`, `db_max_overflow = 30`, `db_pool_timeout = 30`, `db_echo = False` (decoupled from `settings.debug` so `DEBUG=true` no longer logs every SQL statement to stdout).
2. Updated `_get_engine()` in [database.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/database.py#L63-L78) to pass `echo=settings.db_echo` and, for PostgreSQL URLs, `pool_size=settings.db_pool_size`, `max_overflow=settings.db_max_overflow`, and `pool_timeout=settings.db_pool_timeout` (verified `pool_size=20, max_overflow=30, timeout=30, echo=False`).
3. **Concurrency note (500 concurrent users & Supabase Pooler):** One user does **not** hold a permanent DB connection — connections are shared across requests and checked out per transaction (~10–30 ms for indexed queries), so 50 pooled connections/worker easily serves 500 concurrent REST users (~1,500–2,500 tx/s). However, `get_current_user` uses `Depends(get_db)`, which keeps the `AsyncSession` open until long LLM endpoints (`/learn`, `/followup`) finish if a query runs on it, and multi-worker deployments must ensure `(workers × (db_pool_size + db_max_overflow))` stays within Supabase Supavisor's pooler client limit.
- **Client Impact:** None.

---

## 🟡 MEDIUM — Optimization Opportunities

### M1. ✅ FIXED — `search_user_sessions()` — Count Query Uses Subquery

**File:** [session_manager.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/session_manager.py#L292-L330) (also applied to [user_service.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/user_service.py#L205-L243) and [role_service.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/role_service.py#L147-L176))

```python
# Before:
count_query = select(func.count()).select_from(query.subquery())
```

This wraps the entire filtered query as a subquery to count. At 100M rows, the planner may not push predicates efficiently.

**Fix Applied:**
- Refactored `SessionManager.search_user_sessions()`, `UserService.search_users()`, and `RoleService.search_roles()` to collect shared `filters = [...]` and issue a direct `select(func.count(<Model>.id)).where(*filters)` without wrapping in a subquery.
- **Client Impact:** None.

### M2. ✅ FIXED — `search_users()` and `search_roles()` — ILIKE on Multiple Unindexed Columns

**File:** [user_service.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/user_service.py#L209-L219), [db_models.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/models/db_models.py#L106-L111), & [0015_add_medium_scale_indexes.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/alembic/versions/0015_add_medium_scale_indexes.py)

```python
query = query.where(
    or_(
        User.first_name.ilike(term),
        User.last_name.ilike(term),
        User.email.ilike(term),
        User.mobile.ilike(term),
    )
)
```

**Impact:** `ILIKE '%term%'` with leading wildcard cannot use B-tree indexes → full sequential scan of 1L user rows.

**Fix Applied:**
- Enabled `pg_trgm` extension (`CREATE EXTENSION IF NOT EXISTS pg_trgm`) and added GIN trigram indexes on all 4 searched columns (`ix_users_fname_trgm`, `ix_users_lname_trgm`, `ix_users_email_trgm`, `ix_users_mobile_trgm`) in [db_models.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/models/db_models.py#L106-L111) and applied via Alembic migration [0015_add_medium_scale_indexes.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/alembic/versions/0015_add_medium_scale_indexes.py).
- *(Note: `roles` is a tiny lookup table of ~4 rows, so `search_roles` only needed the M1 direct count fix.)*
- **Client Impact:** None.

### M3. ✅ FIXED — `ilike` Search on `sessions.topic` (Text Column)

**File:** [session_manager.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/session_manager.py#L306-L311), [db_models.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/models/db_models.py#L343-L347), & [0015_add_medium_scale_indexes.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/alembic/versions/0015_add_medium_scale_indexes.py)

Same issue as M2 but on the `sessions` table with 100M rows — `topic.ilike('%term%')` is a full scan.

**Fix Applied:**
- Added GIN trigram index `ix_sessions_topic_trgm` on `sessions(topic gin_trgm_ops)` in [db_models.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/models/db_models.py#L346) and applied via [0015_add_medium_scale_indexes.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/alembic/versions/0015_add_medium_scale_indexes.py) (verified present in `edutechAI` schema).
- **Client Impact:** None.

### M4. ✅ FIXED — `get_user_standing()` — Multiple Separate Queries Per Dashboard Load

**File:** [analytics_service.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/analytics_service.py#L109-L176)

Runs **5 separate queries** sequentially:
1. XP sum query (JOIN gamification → sessions)
2. Session aggregates (3 COUNTs with CASE)
3. Step aggregates (2 COUNTs with CASE + JOIN)
4. Step dates query (for streak calculation)
5. User trophies query

**Fix Applied:**
1. Merged queries 1, 2, and 3 (`xp_cte`, `session_cte`, `step_cte`) into a **single CTE query** joined with `true()` (no Cartesian-product `SAWarning`, zero `state_json` columns touched).
2. Optimized query 4 to `SELECT DISTINCT DATE(completed_at)` instead of fetching all historical `StepProgress.completed_at` timestamps into Python.
3. Reduced `get_user_standing()` from **5 sequential DB round trips → 3**, with **0 data diffs** verified on `pro@gmail.com`.
- **Client Impact:** None.

### M5. ✅ FIXED — Missing Index: `feedbacks(status)` for Public Featured Query

**File:** [db_models.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/models/db_models.py#L499-L506) & [0015_add_medium_scale_indexes.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/alembic/versions/0015_add_medium_scale_indexes.py)

**Current state:** `FeedbackRecord.status` already has `index=True` ✅. But the public query filters on `status = 'featured' AND is_public_consent = True AND User.retired = False` with a JOIN.

**Fix Applied:**
- Added partial covering index `ix_feedbacks_featured` on `feedbacks (updated_at DESC) WHERE status = 'featured' AND is_public_consent = true` in [db_models.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/models/db_models.py#L501-L505) and applied via [0015_add_medium_scale_indexes.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/alembic/versions/0015_add_medium_scale_indexes.py).
- **Client Impact:** None (`/feedback/public` verified returning 200 OK).

### M6. ✅ FIXED — `payment_transactions` Missing Index on `(user_id, created_at)` (and `subscriptions(tier, status)`)

**File:** [subscription_service.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/subscription_service.py#L399-L405), [db_models.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/models/db_models.py#L261-L296), & [0015_add_medium_scale_indexes.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/alembic/versions/0015_add_medium_scale_indexes.py)

```python
select(PaymentTransaction)
    .where(PaymentTransaction.user_id == user_id)
    .order_by(PaymentTransaction.created_at.desc())
```

Has `user_id` index but not `(user_id, created_at DESC)` covering index for the ORDER BY.

**Fix Applied:**
- Added `ix_payment_txn_user_created` on `payment_transactions (user_id, created_at DESC)` and covering index `ix_subscriptions_tier_status` on `subscriptions (tier, status)` in [db_models.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/models/db_models.py#L261-L296) and applied via [0015_add_medium_scale_indexes.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/alembic/versions/0015_add_medium_scale_indexes.py).
- **Client Impact:** None.

### M7. ✅ FIXED — `subscription_service._sync_user_role()` — Runs 4-5 Queries Per Role Sync

**File:** [subscription_service.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/subscription_service.py#L44-L97), [subscription_service.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/subscription_service.py#L462-L540), & [admin_service.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/admin_service.py#L191-L316)

Each subscription upgrade calls `_sync_user_role()` which runs:
1. `SELECT subscription_tiers WHERE slug = ?`
2. `SELECT roles WHERE id = ?`
3. Fallback: `SELECT roles WHERE name = ?`
4. `SELECT subscription_tiers.role_id WHERE retired = false` (all tiers)

**Fix Applied:**
1. Added an in-memory 5-minute TTL cache (`SubscriptionService._get_tier_cache()` / `invalidate_tier_cache()`) storing `{slug -> role_id}`, `all_tier_role_ids`, `{slug -> streak_multiplier}`, and `{role_id -> streak_multiplier}` in plain Python types (1 query on cold cache, 0 tier queries on warm cache).
2. Refactored `_sync_user_role()` to resolve `role_id` and `all_tier_role_ids` from the cache and execute only the single `Role` fetch needed for ORM assignment.
3. Also updated `get_user_streak_multiplier()` to reuse preloaded `user.subscription` and the cached tier multipliers (verified on `pro@gmail.com`: `1.5`, cold queries `1` → warm queries `0`).
4. Wired `SubscriptionService.invalidate_tier_cache()` into `AdminService.create_tier()`, `update_tier()`, and `retire_tier()`.
- **Client Impact:** None.

---

## 🔵 LOWER PRIORITY — Good Practices

### L1. ✅ FIXED — `delete_session()` Manually Deletes Related Records Despite CASCADE

**File:** [session_manager.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/session_manager.py#L364-L386)

```python
# Before:
await db.execute(delete(StepProgress).where(StepProgress.session_id == session_id))
await db.execute(delete(GamificationRecord).where(GamificationRecord.session_id == session_id))
```

This is redundant if proper ForeignKey CASCADE is added (see H5). After adding FKs, just deleting the `SessionRecord` will cascade-delete the children.

**Fix Applied:**
- Removed the redundant manual `delete(StepProgress)` and `delete(GamificationRecord)` queries from `SessionManager.delete_session()`, relying on the H5 `ON DELETE CASCADE` foreign keys (`fk_step_progress_session_id`, `fk_gamification_session_id`, and `feedbacks.session_id`).
- Also fixed the authorization order: ownership (`record.user_id != user_id`) is now verified **before** any deletion occurs (previously child rows were purged even when unauthorized).
- **Client Impact:** None.

### L2. ✅ FIXED (via H6) — `echo=settings.debug` in Production

**File:** [database.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/database.py#L63-L78) & [config.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/config.py#L138)

If `DEBUG=true` is accidentally set in production, every SQL query gets printed to stdout — massive I/O overhead at 1L users.

**Fix Applied:**
- Decoupled SQLAlchemy SQL logging from `settings.debug` by introducing `db_echo: bool = False` in `Settings` and passing `echo=settings.db_echo` in `_get_engine()` (completed in H6).
- **Client Impact:** None.

### L3. ✅ FIXED — `_sessions` In-Memory Dict Grows Unbounded (No Redis)

**File:** [learning.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/app/routers/learning.py#L74-L82), [cache.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/cache.py), & [session_manager.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/session_manager.py#L42)

```python
# Before:
_sessions: dict[str, SharedMemory] = {}
```

With 1L users × active sessions, this dict grows unbounded in the Python process. Each `SharedMemory` object contains serialized steps, conversation history, etc. — potentially hundreds of MB.

**Fix Applied:**
- Added a zero-dependency `OrderedDict`-based `BoundedTTLCache` and `BoundedTTLSet` in [cache.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/cache.py) (no Redis or extra package required).
- Replaced `_sessions` in [learning.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/app/routers/learning.py#L75-L78) with `BoundedTTLCache[SharedMemory](maxsize=5000, ttl_seconds=1800.0, sliding=True)` (30-minute inactivity eviction, LRU cap of 5,000 sessions; evicted sessions transparently reload from PostgreSQL via `session_manager.get_session()`).
- Bounded `_cancelled_session_ids` in both [learning.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/app/routers/learning.py#L78) and [session_manager.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/session_manager.py#L42) using `BoundedTTLSet(maxsize=5000, ttl_seconds=3600.0)`.
- **Client Impact:** None.

### L4. ✅ FIXED (Process-Bounded, No Redis) — `standing_cache` Is Process-Local & Unbounded

**File:** [analytics_service.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/analytics_service.py#L38-L45) & [cache.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/cache.py)

```python
# Before:
_standing_cache: dict[str, tuple[datetime, LearnerStandingResponse]] = {}
```

If you scale to multiple server instances (which you must for 1L users), each process has its own cache → stale data, inconsistent UX. Also unbounded growth (1L entries × ~2KB each = ~200MB).

**Fix Applied (without Redis):**
- Replaced the unbounded `_standing_cache` dict with `BoundedTTLCache[LearnerStandingResponse](maxsize=10000, ttl_seconds=300.0, sliding=False)` in [analytics_service.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/analytics_service.py#L39-L45).
- Bounds memory to at most 10,000 entries (~20 MB) with automatic 5-minute TTL expiration and LRU eviction while preserving `AnalyticsService.invalidate_standing_cache()`.
- *(Architectural note: Because Redis is intentionally not used, `_standing_cache` remains process-local; if deploying multiple workers/instances later, entries in other workers will refresh within the 5-minute TTL or can be reduced via `CACHE_TTL_SECONDS`.)*
- **Client Impact:** None.

---

## 📊 Applied Index & FK Migrations Summary

> [!NOTE]
> All indexes and foreign keys below have been created and verified in the `edutechAI` schema via two Alembic migrations.

**Migration 1 — [0014_add_scale_indexes_and_session_fks.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/alembic/versions/0014_add_scale_indexes_and_session_fks.py)** (Critical + High):
| Index / Constraint | Table | Columns | Type |
|---|---|---|---|
| `ix_sessions_user_created` | sessions | `(user_id, created_at)` | B-tree |
| `ix_sessions_user_complete_updated` | sessions | `(user_id, is_complete, updated_at)` | B-tree |
| `ix_session_usage_user_created` | session_usage_logs | `(user_id, created_at)` | B-tree |
| `ix_step_progress_session_step` | step_progress | `(session_id, step_index)` | B-tree UNIQUE |
| `ix_refresh_token_user_active` | refresh_tokens | `(user_id, revoked_at)` | B-tree |
| `ix_refresh_token_family_active` | refresh_tokens | `(family_id, revoked_at)` | B-tree |
| `fk_step_progress_session_id` | step_progress → sessions | `session_id` | FK CASCADE |
| `fk_gamification_session_id` | gamification → sessions | `session_id` | FK CASCADE |

**Migration 2 — [0015_add_medium_scale_indexes.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/alembic/versions/0015_add_medium_scale_indexes.py)** (Medium):
| Index | Table | Columns | Type |
|---|---|---|---|
| `ix_users_fname_trgm` | users | `first_name` | GIN pg_trgm |
| `ix_users_lname_trgm` | users | `last_name` | GIN pg_trgm |
| `ix_users_email_trgm` | users | `email` | GIN pg_trgm |
| `ix_users_mobile_trgm` | users | `mobile` | GIN pg_trgm |
| `ix_sessions_topic_trgm` | sessions | `topic` | GIN pg_trgm |
| `ix_feedbacks_featured` | feedbacks | `updated_at DESC` | Partial (`status='featured' AND is_public_consent=true`) |
| `ix_payment_txn_user_created` | payment_transactions | `(user_id, created_at DESC)` | B-tree |
| `ix_subscriptions_tier_status` | subscriptions | `(tier, status)` | B-tree |

---

## 🏗️ Architecture Recommendations for 1L Scale

### 1. ✅ DONE — Add `pool_size` and `max_overflow` to Engine Config
Implemented in H6 — [config.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/config.py#L135-L138) and [database.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/database.py#L63-L77): `pool_size=20`, `max_overflow=30`, `pool_timeout=30`, `echo=False`.

### 2. ✅ DONE — Replace In-Memory Session Cache with Bounded LRU+TTL
Implemented in L3 — [cache.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/cache.py): `BoundedTTLCache(maxsize=5000, ttl=1800, sliding=True)` replaces the unbounded dict.

### 3. ✅ DONE — Push Analytics Aggregations to SQL
Implemented in C2 + M4 — [analytics_service.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/analytics_service.py): scalar column projection, SQL `GROUP BY` aggregation, CTE-merged queries, JSONB title extraction, and SQL-scoped window filtering.

### 4. Add Read Replicas for Analytics
Dashboard/analytics queries are heavy reads. Route them to read replicas via a separate engine.

### 5. ✅ DONE — Filter StepProgress by Time Window in SQL
Implemented in C2 — [analytics_service.py L402-435](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/analytics_service.py#L402-L435): SQL `WHERE` filters `completed_at` within window (with 30-min lookback for clamping accuracy) instead of fetching all historical rows.

### 6. Consider Partitioning `sessions` and `step_progress` Tables
At 100M+ rows, consider range partitioning by `created_at` (monthly/quarterly). PostgreSQL declarative partitioning would keep query performance consistent as data grows.

### 7. Connection Pool & Session Hold-Time Caveats (500+ Concurrent Users & Multi-Worker)
Two architectural caveats apply when scaling beyond ~500 concurrent users or multiple Uvicorn/Gunicorn workers:

1. **Long-running LLM endpoints holding `get_current_user`'s DB session open:**
   - **Where:** [dependencies.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/app/dependencies.py#L50-L53), [learning.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/app/routers/learning.py#L162-L166) (`/learn`, `/step/{step_index}/followup`), and any authenticated route calling slow external/LLM APIs.
   - **Issue:** `get_current_user` injects `db: AsyncSession = Depends(get_db)`. Because FastAPI keeps generator dependencies open until the route handler returns, the checked-out DB connection remains held (idle) for the entire 5–15 second LLM call. If 500 users invoke `/learn` simultaneously, they will exhaust a 50-connection pool and hit `pool_timeout=30` even though no SQL is running during LLM inference.
   - **Recommended Future Fix:** Refactor `get_current_user` to use a short-lived `async with get_db_session() as db:` block (or `expunge` / detach the `User` object after loading roles & subscription) so the DB connection is released in ~10–20 ms before the route body executes. *(Note: audit callers like `logout_all` in [auth.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/app/routers/auth.py#L140-L161) that currently mutate `current_user` via a separate `Depends(get_db)` session — switch those to explicit `UPDATE` statements or `db.merge(current_user)`.)*

2. **Supabase Supavisor Pooler (`port 6543`) client-connection budget across multiple workers:**
   - **Where:** `.env` (`aws-0-ap-south-1.pooler.supabase.com:6543`), [config.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/config.py#L135-L138), and [database.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/database.py#L63-L78).
   - **Issue:** `db_pool_size=20` and `db_max_overflow=30` (50 max connections) is **per backend worker process**. Running `N` workers/containers multiplies total client connections to Supabase's pooler (`N × 50` — e.g., 4 workers = 200 connections, 10 workers = 500 connections), which can exceed Supabase's `max_client_conn` limit on smaller compute tiers.
   - **Recommended Future Fix:** Tune `DB_POOL_SIZE` and `DB_MAX_OVERFLOW` in `.env` per deployment topology so `workers × (DB_POOL_SIZE + DB_MAX_OVERFLOW)` stays safely below your Supabase pooler client limit (e.g., for 4 workers with a 200-client cap, set `DB_POOL_SIZE=15` and `DB_MAX_OVERFLOW=25`, or use `NullPool` only when delegating pooling 100% to PgBouncer/Supavisor after benchmarking latency).

---

## ✅ What's Already Well Done

| Area | Status |
|---|---|
| `session_id` unique index on `sessions` | ✅ Good |
| `email` unique + indexed on `users` | ✅ Good |
| `user_id` indexed on `sessions`, `subscriptions`, `payment_transactions`, `feedbacks`, `user_trophies`, `refresh_tokens`, `session_usage_logs` | ✅ Good |
| Composite `(session_id, status)` index on `step_progress` | ✅ Good |
| Unique constraint `(user_id, trophy_id)` on `user_trophies` | ✅ Good |
| Unique constraint `(session_id, user_id)` on feedbacks | ✅ Good |
| `token_hash` unique + indexed on `refresh_tokens` | ✅ Good |
| Bulk fetch for `StepProgress` in `update_session()` (N+1 fix) | ✅ Good |
| `selectinload` for roles + privileges in `authenticate_user()` | ✅ Good |
| `expire_on_commit=False` on session factory | ✅ Good |
| `pool_pre_ping=True` for connection health checks | ✅ Good |
| Standing cache with TTL eviction | ✅ Good (needs Redis for multi-instance) |
