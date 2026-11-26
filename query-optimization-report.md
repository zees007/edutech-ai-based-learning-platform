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

### M1. `search_user_sessions()` — Count Query Uses Subquery

**File:** [session_manager.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/session_manager.py#L314-L316)

```python
count_query = select(func.count()).select_from(query.subquery())
```

This wraps the entire filtered query as a subquery to count. At 100M rows, the planner may not push predicates efficiently.

**Fix:** Use a parallel count query with the same WHERE conditions:
```python
count_query = select(func.count(SessionRecord.id)).where(
    SessionRecord.user_id == user_id,
    # ... same filters ...
)
```

### M2. `search_users()` and `search_roles()` — ILIKE on Multiple Unindexed Columns

**File:** [user_service.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/user_service.py#L211-L219)

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

**Fix options (pick one):**
1. **PostgreSQL `pg_trgm` trigram index** — best for ILIKE with leading wildcards:
   ```sql
   CREATE EXTENSION IF NOT EXISTS pg_trgm;
   CREATE INDEX ix_users_name_trgm ON users USING gin (first_name gin_trgm_ops, last_name gin_trgm_ops);
   CREATE INDEX ix_users_email_trgm ON users USING gin (email gin_trgm_ops);
   ```
2. **PostgreSQL full-text search** with `tsvector` column + GIN index (best for natural language search)
3. **If only prefix matching needed:** use `LIKE 'term%'` (no leading wildcard) which B-tree can serve

### M3. `ilike` Search on `sessions.topic` (Text Column)

**File:** [session_manager.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/session_manager.py#L306-L311)

Same issue as M2 but on the `sessions` table with 100M rows — `topic.ilike('%term%')` is a full scan.

**Fix:** Add a GIN trigram index on `sessions.topic`:
```sql
CREATE INDEX ix_sessions_topic_trgm ON sessions USING gin (topic gin_trgm_ops);
```

### M4. `get_user_standing()` — Multiple Separate Queries Per Dashboard Load

**File:** [analytics_service.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/analytics_service.py#L94-L234)

Runs **5 separate queries** sequentially:
1. XP sum query (JOIN gamification → sessions)
2. Session aggregates (3 COUNTs with CASE)
3. Step aggregates (2 COUNTs with CASE + JOIN)
4. Step dates query (for streak calculation)
5. User trophies query

**Fix:** Merge queries 2 and 3 into a single CTE-based query. Merge 1 into query 2. This reduces 5 round trips to 2-3.

### M5. Missing Index: `feedbacks(status)` for Public Featured Query

**Current state:** `FeedbackRecord.status` already has `index=True` ✅. But the public query filters on `status = 'featured' AND is_public_consent = True AND User.retired = False` with a JOIN.

**Fix:** Composite partial index:
```sql
CREATE INDEX ix_feedbacks_featured ON feedbacks (updated_at DESC)
    WHERE status = 'featured' AND is_public_consent = true;
```

### M6. `payment_transactions` Missing Index on `(user_id, created_at)`

**File:** [subscription_service.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/subscription_service.py#L399-L405)

```python
select(PaymentTransaction)
    .where(PaymentTransaction.user_id == user_id)
    .order_by(PaymentTransaction.created_at.desc())
```

Has `user_id` index but not `(user_id, created_at DESC)` covering index for the ORDER BY.

**Fix:**
```sql
CREATE INDEX ix_payment_txn_user_created ON payment_transactions (user_id, created_at DESC);
```

### M7. `subscription_service._sync_user_role()` — Runs 4-5 Queries Per Role Sync

**File:** [subscription_service.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/subscription_service.py#L408-L442)

Each subscription upgrade calls `_sync_user_role()` which runs:
1. `SELECT subscription_tiers WHERE slug = ?`
2. `SELECT roles WHERE id = ?`
3. Fallback: `SELECT roles WHERE name = ?`
4. `SELECT subscription_tiers.role_id WHERE retired = false` (all tiers)

**Fix:** Cache the tier-role mapping in memory (with TTL). Tiers rarely change.

---

## 🔵 LOWER PRIORITY — Good Practices

### L1. `delete_session()` Manually Deletes Related Records Despite CASCADE

**File:** [session_manager.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/session_manager.py#L372-L377)

```python
await db.execute(delete(StepProgress).where(StepProgress.session_id == session_id))
await db.execute(delete(GamificationRecord).where(GamificationRecord.session_id == session_id))
```

This is redundant if proper ForeignKey CASCADE is added (see H5). After adding FKs, just deleting the `SessionRecord` will cascade-delete the children.

### L2. `echo=settings.debug` in Production

**File:** [database.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/database.py#L65)

If `DEBUG=true` is accidentally set in production, every SQL query gets printed to stdout — massive I/O overhead at 1L users.

### L3. `_sessions` In-Memory Dict Grows Unbounded

**File:** [learning.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/app/routers/learning.py#L74)

```python
_sessions: dict[str, SharedMemory] = {}
```

With 1L users × active sessions, this dict grows unbounded in the Python process. Each `SharedMemory` object contains serialized steps, conversation history, etc. — potentially hundreds of MB.

**Fix:** Use an LRU cache with TTL (e.g., `cachetools.TTLCache`) or Redis for session caching. Evict sessions after 30 minutes of inactivity.

### L4. `standing_cache` Is Process-Local

**File:** [analytics_service.py](file:///c:/Users/mhmdz/IdeaProjects/Python%20Projects/edutech-ai-based-learning-platform/devzees-edutechai-server/services/analytics_service.py#L39)

```python
_standing_cache: dict[str, tuple[datetime, LearnerStandingResponse]] = {}
```

If you scale to multiple server instances (which you must for 1L users), each process has its own cache → stale data, inconsistent UX. Also unbounded growth (1L entries × ~2KB each = ~200MB).

**Fix:** Use Redis or a shared cache with TTL and max size.

---

## 📊 Recommended Index Summary (Alembic Migration)

```python
"""Add composite indexes for 1L user scale"""

from alembic import op

def upgrade():
    # Sessions
    op.create_index("ix_sessions_user_created", "sessions", ["user_id", "created_at"])
    op.create_index("ix_sessions_user_complete_updated", "sessions", ["user_id", "is_complete", "updated_at"])

    # Session Usage Logs
    op.create_index("ix_session_usage_user_created", "session_usage_logs", ["user_id", "created_at"])

    # Step Progress (composite unique)
    op.create_index("ix_step_progress_session_step", "step_progress", ["session_id", "step_index"], unique=True)

    # Refresh Tokens
    op.create_index("ix_refresh_token_user_active", "refresh_tokens", ["user_id", "revoked_at"])
    op.create_index("ix_refresh_token_family_active", "refresh_tokens", ["family_id", "revoked_at"])

    # Payment Transactions
    op.create_index("ix_payment_txn_user_created", "payment_transactions", ["user_id", "created_at"])

    # Subscriptions — covering index for tier counts
    op.create_index("ix_subscriptions_tier_status", "subscriptions", ["tier", "status"])

    # Trigram indexes for ILIKE search (requires pg_trgm extension)
    op.execute("CREATE EXTENSION IF NOT EXISTS pg_trgm")
    op.execute("CREATE INDEX ix_users_fname_trgm ON users USING gin (first_name gin_trgm_ops)")
    op.execute("CREATE INDEX ix_users_lname_trgm ON users USING gin (last_name gin_trgm_ops)")
    op.execute("CREATE INDEX ix_users_email_trgm ON users USING gin (email gin_trgm_ops)")
    op.execute("CREATE INDEX ix_sessions_topic_trgm ON sessions USING gin (topic gin_trgm_ops)")

def downgrade():
    op.drop_index("ix_sessions_user_created")
    op.drop_index("ix_sessions_user_complete_updated")
    op.drop_index("ix_session_usage_user_created")
    op.drop_index("ix_step_progress_session_step")
    op.drop_index("ix_refresh_token_user_active")
    op.drop_index("ix_refresh_token_family_active")
    op.drop_index("ix_payment_txn_user_created")
    op.drop_index("ix_subscriptions_tier_status")
    op.execute("DROP INDEX IF EXISTS ix_users_fname_trgm")
    op.execute("DROP INDEX IF EXISTS ix_users_lname_trgm")
    op.execute("DROP INDEX IF EXISTS ix_users_email_trgm")
    op.execute("DROP INDEX IF EXISTS ix_sessions_topic_trgm")
```

---

## 🏗️ Architecture Recommendations for 1L Scale

### 1. Add `pool_size` and `max_overflow` to Engine Config
```python
create_async_engine(
    url,
    pool_size=20,
    max_overflow=30,
    pool_timeout=30,
    pool_pre_ping=True,
    pool_recycle=300,
    echo=False,          # Never True in production
)
```

### 2. Replace In-Memory Session Cache with Redis/LRU
Replace the unbounded `_sessions` dict with `cachetools.TTLCache(maxsize=5000, ttl=1800)` or Redis.

### 3. Push Analytics Aggregations to SQL
Rewrite `get_user_performance()` to use SQL `GROUP BY`, `SUM`, `COUNT` with CTEs instead of loading all rows into Python.

### 4. Add Read Replicas for Analytics
Dashboard/analytics queries are heavy reads. Route them to read replicas via a separate engine.

### 5. Paginate StepProgress in Analytics
Instead of loading ALL step records for a user, filter by time window in SQL and paginate.

### 6. Consider Partitioning `sessions` and `step_progress` Tables
At 100M+ rows, consider range partitioning by `created_at` (monthly/quarterly). PostgreSQL declarative partitioning would keep query performance consistent as data grows.

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
