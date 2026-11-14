# EduTechAI Documentation

**Version:** 0.1.0  
Adaptive AI-powered learning platform with multi-agent Socratic tutoring, YouTube clips, academic resources, and quizzes.

> [!IMPORTANT]
> **Authentication Cookie:** The `access_token` JWT is set as an HTTP-only cookie automatically upon a successful `/login`. For clients like Dio in Flutter, ensure you have a Cookie Manager (like `dio_cookie_manager`) configured. Once configured, the cookie will automatically be stored and passed in all subsequent requests. Because it is essential for protected routes, it is marked as **(Required)** in the documentation below.

---

## Flutter Client Integration Status

**Currently Integrated APIs (in `devzees-edutechai-client`):**

*   **Auth & Users** (`auth_service.dart`):
    *   `POST /api/v1/auth/login`
    *   `POST /api/v1/auth/logout`
    *   `GET /api/v1/auth/me`
    *   `POST /api/v1/users/create`
*   **Sessions & Learning** (`learning_service.dart`):
    *   `POST /api/v1/learn`
    *   `GET /api/v1/sessions/quota`
    *   `GET /api/v1/sessions`
    *   `GET /api/v1/sessions/{session_id}`
    *   `DELETE /api/v1/sessions/{session_id}`
    *   `POST /api/v1/sessions/{session_id}/step/{step_index}/complete`
    *   `POST /api/v1/sessions/{session_id}/step/{step_index}/followup`
    *   `POST /api/v1/sessions/{session_id}/step/{step_index}/regenerate`
*   **Session Exports** (`export_service.dart`):
    *   `GET /api/v1/export/{session_id}/md` (Export Markdown)
    *   `GET /api/v1/export/{session_id}/pdf` (Export PDF)
    *   `GET /api/v1/export/{session_id}/html` (Export Interactive HTML)
*   **Academic Search** (`academic_service.dart`):
    *   `GET /api/v1/academic/search`
*   **Quiz** (`learning_service.dart`):
    *   `POST /api/v1/quiz/submit`
*   **Admin & Subscription Tiers** (`admin_service.dart`):
    *   `GET /api/v1/admin/metrics`
    *   `GET /api/v1/admin/tiers`
    *   `POST /api/v1/admin/tiers`
    *   `PUT /api/v1/admin/tiers/{tier_id}`
    *   `DELETE /api/v1/admin/tiers/{tier_id}`

**Pending / Not Integrated APIs:**

*   `POST /api/v1/sessions/{session_id}/mode` (Change Learning Mode)
*   `GET /api/v1/quiz/{session_id}/{step_index}` (Get Quiz)
*   `GET /api/v1/users/search` (Search Users)
*   `GET /api/v1/users/{user_id}` (Get User By Id)
*   `PUT /api/v1/users/{user_id}/edit` (Edit User)
*   `PATCH /api/v1/users/{user_id}/change-password` (Change Password)

---

## Login
**Endpoint:** `POST /api/v1/auth/login`

Authenticate user with email and password.

On successful authentication, creates a 60-minute JWT access token
and sets an HTTP `access_token` cookie (`httponly=True`, `SameSite=Lax`).

### Request

**Body (application/json):**
```json
{
  "email": "user@example.com",
  "password": "string"
}
```

### Response

**200 Successful Response**

```json
"any"
```

---

## Logout
**Endpoint:** `POST /api/v1/auth/logout`

Log out current user by clearing the `access_token` HTTP cookie.

### Request

### Response

**200 Successful Response**

```json
"any"
```

---

## Get Current User Profile
**Endpoint:** `GET /api/v1/auth/me`

Retrieve profile details, assigned roles, subscription status, and
flat list of active privilege codes for the currently authenticated user.

### Request

**Parameters:**
- `access_token` (cookie) *(Required)*

### Response

**200 Successful Response**

```json
{
  "id": "string",
  "first_name": "string",
  "last_name": "string",
  "email": "string",
  "mobile": "string",
  "country": "string",
  "created_at": "2023-10-12T10:00:00Z",
  "roles": [
    "string"
  ],
  "subscription": {
    "id": 0,
    "user_id": "string",
    "tier": "string",
    "status": "string",
    "billing_cycle": "string",
    "price_amount": 0.0,
    "current_period_start": "2023-10-12T10:00:00Z",
    "current_period_end": "{...}",
    "gateway_provider": "string",
    "gateway_subscription_id": "{...}",
    "gateway_customer_id": "{...}",
    "payment_gateway_ref": "{...}",
    "cancel_at_period_end": true,
    "auto_renew": true
  },
  "privilege_codes": [
    "string"
  ]
}
```

---

## Start Learning Session
**Endpoint:** `POST /api/v1/learn`

Start a new learning session for a topic.

The Orchestrator agent will decompose the topic into milestone steps.
Returns the session ID and the learning plan.

### Request

**Parameters:**
- `access_token` (cookie) *(Required)*

**Body (application/json):**
```json
{
  "topic": "string",
  "learning_mode": "string",
  "student_level": "string"
}
```

### Response

**200 Successful Response**

```json
{
  "session_id": "string",
  "topic": "string",
  "learning_mode": "string",
  "student_level": "string",
  "created_at": "2023-10-12T10:00:00Z",
  "steps": [
    {
      "index": 0,
      "title": "string",
      "description": "string",
      "is_prerequisite": true,
      "prerequisite": "{...}",
      "status": "string",
      "estimated_minutes": 0,
      "tutor_explanation": "{...}",
      "socratic_questions": [
        "{...}"
      ],
      "videos": [
        "{...}"
      ],
      "papers": [
        "{...}"
      ],
      "quiz": "{...}",
      "quiz_score": "{...}",
      "user_answers": {},
      "user_full_answers": {},
      "follow_up_count": 0
    }
  ],
  "current_step_index": 0,
  "xp_earned": 0,
  "steps_completed": 0,
  "conversation_history": [
    {
      "role": "string",
      "content": "string",
      "timestamp": "2023-10-12T10:00:00Z",
      "step_index": "{...}"
    }
  ]
}
```

---

## Get Session State
**Endpoint:** `GET /api/v1/sessions/{session_id}`

Retrieve the current state of a learning session.

### Request

**Parameters:**
- `session_id` (path) *(Required)*
- `access_token` (cookie) *(Required)*

### Response

**200 Successful Response**

```json
{
  "session_id": "string",
  "topic": "string",
  "learning_mode": "string",
  "student_level": "string",
  "created_at": "2023-10-12T10:00:00Z",
  "steps": [
    {
      "index": 0,
      "title": "string",
      "description": "string",
      "is_prerequisite": true,
      "prerequisite": "{...}",
      "status": "string",
      "estimated_minutes": 0,
      "tutor_explanation": "{...}",
      "socratic_questions": [
        "{...}"
      ],
      "videos": [
        "{...}"
      ],
      "papers": [
        "{...}"
      ],
      "quiz": "{...}",
      "quiz_score": "{...}",
      "user_answers": {},
      "user_full_answers": {},
      "follow_up_count": 0
    }
  ],
  "current_step_index": 0,
  "xp_earned": 0,
  "steps_completed": 0,
  "conversation_history": [
    {
      "role": "string",
      "content": "string",
      "timestamp": "2023-10-12T10:00:00Z",
      "step_index": "{...}"
    }
  ]
}
```

---

## Delete User Session
**Endpoint:** `DELETE /api/v1/sessions/{session_id}`

Delete a learning session and associated progress records belonging to the current user.

### Request

**Parameters:**
- `session_id` (path) *(Required)*
- `access_token` (cookie) *(Required)*

### Response

**200 Successful Response**

```json
"any"
```

---

## Complete Step
**Endpoint:** `POST /api/v1/sessions/{session_id}/step/{step_index}/complete`

Mark a step as complete and advance the session progress.
Awards XP via Gamification service.

### Request

**Parameters:**
- `session_id` (path) *(Required)*
- `step_index` (path) *(Required)*
- `access_token` (cookie) *(Required)*

### Response

**200 Successful Response**

```json
"any"
```

---

## Answer Followup
**Endpoint:** `POST /api/v1/sessions/{session_id}/step/{step_index}/followup`

Answer a follow up question from the student on a specific step.

### Request

**Parameters:**
- `session_id` (path) *(Required)*
- `step_index` (path) *(Required)*
- `access_token` (cookie) *(Required)*

**Body (application/json):**
```json
{
  "question": "string"
}
```

### Response

**200 Successful Response**

```json
"any"
```

---

## Regenerate Step
**Endpoint:** `POST /api/v1/sessions/{session_id}/step/{step_index}/regenerate`

Regenerate the content and results for a specific step.
Requires ET_REGENERATE_STEP privilege (Pro/Ultra feature).

### Request

**Parameters:**
- `session_id` (path) *(Required)*
- `step_index` (path) *(Required)*
- `access_token` (cookie) *(Required)*

### Response

**200 Successful Response**

```json
"any"
```

---

## Change Learning Mode
**Endpoint:** `POST /api/v1/sessions/{session_id}/mode`

Switch the learning mode for an active session.
Affects how subsequent steps are generated (content depth, media emphasis).

### Request

**Parameters:**
- `session_id` (path) *(Required)*
- `access_token` (cookie) *(Required)*

**Body (application/json):**
```json
{
  "learning_mode": "string"
}
```

### Response

**200 Successful Response**

```json
"any"
```

---

## Get Monthly Session Quota
**Endpoint:** `GET /api/v1/sessions/quota`

Retrieve the current monthly AI learning session quota status for the authenticated user.
Protected by `ET_VIEW_QUOTA` privilege.
- **Free Tier:** Limited to 10 AI sessions per calendar month. Returns current usage count, limit (`10`), and remaining count (`max(0, 10 - used)`).
- **Pro / Ultra Tier:** Unlimited sessions. Returns `is_unlimited: true`, `limit: null`, `remaining: null`.

### Request

**Parameters:**
- `access_token` (cookie) *(Required)*

### Response

**200 Successful Response**

Free Tier User Example:
```json
{
  "tier": "free",
  "is_unlimited": false,
  "used": 3,
  "limit": 10,
  "remaining": 7
}
```

Pro / Ultra User Example:
```json
{
  "tier": "pro",
  "is_unlimited": true,
  "used": 15,
  "limit": null,
  "remaining": null
}
```

---

## List User Sessions
**Endpoint:** `GET /api/v1/sessions`

Search & paginate learning sessions for the currently authenticated user.
Incomplete sessions are sorted to the top, followed by completed sessions.

### Request

**Parameters:**
- `page` (query) *(Optional)* - 0-indexed page number
- `size` (query) *(Optional)* - Page size limit
- `lookup_text` (query) *(Optional)* - Search term for topic, mode, level
- `status_filter` (query) *(Optional)* - Status filter: all, in_progress, completed
- `access_token` (cookie) *(Required)*

### Response

**200 Successful Response**

```json
"any"
```

---

## Search Academic Papers
**Endpoint:** `GET /api/v1/academic/search`

Search across OpenAlex, Semantic Scholar, and arXiv in parallel.
Returns deduplicated, relevance-ranked papers with AI TLDR summaries & open-access links.
Protected by ET_ACCESS_ACADEMIC_SEARCH privilege.

### Request

**Parameters:**
- `query` (query) *(Required)* - Topic or query keywords for scholarly research
- `max_results` (query) *(Optional)* - Maximum number of papers to return
- `access_token` (cookie) *(Required)*

### Response

**200 Successful Response**

```json
[
  {
    "title": "string",
    "authors": [
      "string"
    ],
    "year": 0,
    "abstract": "string",
    "tldr": "string",
    "pdf_url": "string",
    "source": "string",
    "relevance_score": 0.0,
    "doi": "string",
    "url": "string"
  }
]
```

---

## Export Session Markdown
**Endpoint:** `GET /api/v1/export/{session_id}/md`

Export the learning session as a structured Markdown study notes file.
Requires `ET_EXPORT_MARKDOWN` privilege (Pro/Ultra).
**Note:** Only available once the learning journey is 100% completed (all steps completed).

### Request

**Parameters:**
- `session_id` (path) *(Required)*
- `access_token` (cookie) *(Required)*

### Response

**200 Successful Response**

Returns plain text Markdown (`text/plain; charset=utf-8`) with `Content-Disposition: attachment; filename="session_{session_id}.md"`.

**400 Bad Request**

Returned if the session journey is not yet completed (`SESSION_INCOMPLETE`).

**403 Forbidden**

Returned if the user lacks the `ET_EXPORT_MARKDOWN` privilege (e.g. Free tier).

---

## Export Session Pdf
**Endpoint:** `GET /api/v1/export/{session_id}/pdf`

Export the learning session as an executive-grade PDF study guide with EduTechAI branding.
Requires `ET_EXPORT_PDF` privilege (Ultra).
**Note:** Only available once the learning journey is 100% completed (all steps completed).

### Request

**Parameters:**
- `session_id` (path) *(Required)*
- `access_token` (cookie) *(Required)*

### Response

**200 Successful Response**

Returns binary PDF stream (`application/pdf`) with `Content-Disposition: attachment; filename="session_{session_id}.pdf"`.

**400 Bad Request**

Returned if the session journey is not yet completed (`SESSION_INCOMPLETE`).

**403 Forbidden**

Returned if the user lacks the `ET_EXPORT_PDF` privilege (e.g. Free or Pro tier).

---

## Export Session HTML
**Endpoint:** `GET /api/v1/export/{session_id}/html`

Export the learning session as a modern, responsive, standalone interactive HTML study report.
Features Google Fonts (`Plus Jakarta Sans`, `JetBrains Mono`), syntax-highlighted code blocks, interactive quiz cards, and a sticky action bar with built-in **Print / Save as PDF** (`window.print()`).
Requires `ET_EXPORT_MARKDOWN` or `ET_EXPORT_PDF` privilege (Pro/Ultra).
**Note:** Only available once the learning journey is 100% completed (all steps completed).

### Request

**Parameters:**
- `session_id` (path) *(Required)*
- `access_token` (cookie) *(Required)*

### Response

**200 Successful Response**

Returns standalone HTML page (`text/html; charset=utf-8`) with `Content-Disposition: inline; filename="session_{session_id}.html"`.

**400 Bad Request**

Returned if the session journey is not yet completed (`SESSION_INCOMPLETE`).

**403 Forbidden**

Returned if the user lacks both `ET_EXPORT_MARKDOWN` and `ET_EXPORT_PDF` privileges (e.g. Free tier).

---

## Submit Quiz
**Endpoint:** `POST /api/v1/quiz/submit`

Submit quiz answers and get grading results with XP.

The quiz must have been generated for the specified step.

### Request

**Parameters:**
- `access_token` (cookie) *(Required)*

**Body (application/json):**
```json
{
  "session_id": "string",
  "step_index": 0,
  "answers": {}
}
```

### Response

**200 Successful Response**

```json
{
  "step_index": 0,
  "total_questions": 0,
  "correct_count": 0,
  "score": 0.0,
  "xp_earned": 0,
  "feedback": [
    {
      "question_index": 0,
      "is_correct": true,
      "student_answer": "string",
      "correct_answer": "string",
      "explanation": "string"
    }
  ]
}
```

---

## Get Quiz
**Endpoint:** `GET /api/v1/quiz/{session_id}/{step_index}`

Get the quiz for a specific step (if generated).

### Request

**Parameters:**
- `session_id` (path) *(Required)*
- `step_index` (path) *(Required)*
- `access_token` (cookie) *(Required)*

### Response

**200 Successful Response**

```json
"any"
```

---

## Create User
**Endpoint:** `POST /api/v1/users/create`

Create a new user profile (Public API).

### Request

**Body (application/json):**
```json
{
  "first_name": "string",
  "last_name": "string",
  "email": "user@example.com",
  "password": "string",
  "mobile": "string",
  "country": "string"
}
```

### Response

**201 Successful Response**

```json
{
  "id": "string",
  "first_name": "string",
  "last_name": "string",
  "email": "string",
  "mobile": "string",
  "country": "string",
  "roles": [
    {
      "id": "string",
      "name": "string",
      "privileges": [
        "{...}"
      ],
      "created_at": "2023-10-12T10:00:00Z",
      "retired": true,
      "retired_at": "{...}",
      "retired_by": "{...}"
    }
  ],
  "subscription": {
    "id": 0,
    "user_id": "string",
    "tier": "string",
    "status": "string",
    "billing_cycle": "string",
    "price_amount": 0.0,
    "current_period_start": "2023-10-12T10:00:00Z",
    "current_period_end": "{...}",
    "gateway_provider": "string",
    "gateway_subscription_id": "{...}",
    "gateway_customer_id": "{...}",
    "payment_gateway_ref": "{...}",
    "cancel_at_period_end": true,
    "auto_renew": true
  },
  "created_at": "2023-10-12T10:00:00Z",
  "retired": true,
  "retired_at": "2023-10-12T10:00:00Z",
  "retired_by": "string"
}
```

---

## Search Users
**Endpoint:** `GET /api/v1/users/search`

Search active users (retired=False) with 0-indexed pagination, sorting, and lookupText.
If lookupText is null or blank, returns all active users.

### Request

**Parameters:**
- `page` (query) *(Optional)* - Page number (0-indexed)
- `size` (query) *(Optional)* - Page size
- `sortBy` (query) *(Optional)* - Sort field name
- `sort_by` (query) *(Optional)*
- `isDesc` (query) *(Optional)* - Sort descending
- `is_desc` (query) *(Optional)*
- `lookupText` (query) *(Optional)* - Search term
- `lookup_text` (query) *(Optional)*
- `access_token` (cookie) *(Required)*

### Response

**200 Successful Response**

```json
{
  "items": [
    {
      "id": "string",
      "first_name": "string",
      "last_name": "string",
      "email": "string",
      "mobile": "{...}",
      "country": "{...}",
      "roles": [
        "{...}"
      ],
      "subscription": "{...}",
      "created_at": "2023-10-12T10:00:00Z",
      "retired": true,
      "retired_at": "{...}",
      "retired_by": "{...}"
    }
  ],
  "total": 0,
  "page": 0,
  "size": 0,
  "total_pages": 0
}
```

---

## Get User By Id
**Endpoint:** `GET /api/v1/users/{user_id}`

Retrieve user details by UUID.

### Request

**Parameters:**
- `user_id` (path) *(Required)*
- `access_token` (cookie) *(Required)*

### Response

**200 Successful Response**

```json
{
  "id": "string",
  "first_name": "string",
  "last_name": "string",
  "email": "string",
  "mobile": "string",
  "country": "string",
  "roles": [
    {
      "id": "string",
      "name": "string",
      "privileges": [
        "{...}"
      ],
      "created_at": "2023-10-12T10:00:00Z",
      "retired": true,
      "retired_at": "{...}",
      "retired_by": "{...}"
    }
  ],
  "subscription": {
    "id": 0,
    "user_id": "string",
    "tier": "string",
    "status": "string",
    "billing_cycle": "string",
    "price_amount": 0.0,
    "current_period_start": "2023-10-12T10:00:00Z",
    "current_period_end": "{...}",
    "gateway_provider": "string",
    "gateway_subscription_id": "{...}",
    "gateway_customer_id": "{...}",
    "payment_gateway_ref": "{...}",
    "cancel_at_period_end": true,
    "auto_renew": true
  },
  "created_at": "2023-10-12T10:00:00Z",
  "retired": true,
  "retired_at": "2023-10-12T10:00:00Z",
  "retired_by": "string"
}
```

---

## Edit User
**Endpoint:** `PUT /api/v1/users/{user_id}/edit`

Edit user profile details (password excluded).

### Request

**Parameters:**
- `user_id` (path) *(Required)*
- `access_token` (cookie) *(Required)*

**Body (application/json):**
```json
{
  "first_name": "string",
  "last_name": "string",
  "email": "user@example.com",
  "mobile": "string",
  "country": "string"
}
```

### Response

**200 Successful Response**

```json
{
  "id": "string",
  "first_name": "string",
  "last_name": "string",
  "email": "string",
  "mobile": "string",
  "country": "string",
  "roles": [
    {
      "id": "string",
      "name": "string",
      "privileges": [
        "{...}"
      ],
      "created_at": "2023-10-12T10:00:00Z",
      "retired": true,
      "retired_at": "{...}",
      "retired_by": "{...}"
    }
  ],
  "subscription": {
    "id": 0,
    "user_id": "string",
    "tier": "string",
    "status": "string",
    "billing_cycle": "string",
    "price_amount": 0.0,
    "current_period_start": "2023-10-12T10:00:00Z",
    "current_period_end": "{...}",
    "gateway_provider": "string",
    "gateway_subscription_id": "{...}",
    "gateway_customer_id": "{...}",
    "payment_gateway_ref": "{...}",
    "cancel_at_period_end": true,
    "auto_renew": true
  },
  "created_at": "2023-10-12T10:00:00Z",
  "retired": true,
  "retired_at": "2023-10-12T10:00:00Z",
  "retired_by": "string"
}
```

---

## Change Password
**Endpoint:** `PATCH /api/v1/users/{user_id}/change-password`

Change user password after verifying old password and confirm password matching.

### Request

**Parameters:**
- `user_id` (path) *(Required)*
- `access_token` (cookie) *(Required)*

**Body (application/json):**
```json
{
  "old_password": "string",
  "new_password": "string",
  "confirm_password": "string"
}
```

### Response

**200 Successful Response**

```json
"any"
```

---

## Retire User
**Endpoint:** `DELETE /api/v1/users/{user_id}/retire`

Soft-retire a user account using DELETE method.

### Request

**Parameters:**
- `user_id` (path) *(Required)*
- `access_token` (cookie) *(Required)*

### Response

**200 Successful Response**

```json
"any"
```

---

## Assign User Roles
**Endpoint:** `PUT /api/v1/users/{user_id}/roles`

Assign or update roles for a specific user.

### Request

**Parameters:**
- `user_id` (path) *(Required)*
- `access_token` (cookie) *(Required)*

**Body (application/json):**
```json
{
  "roleIds": [
    "string"
  ]
}
```

### Response

**200 Successful Response**

```json
{
  "id": "string",
  "first_name": "string",
  "last_name": "string",
  "email": "string",
  "mobile": "string",
  "country": "string",
  "roles": [
    {
      "id": "string",
      "name": "string",
      "privileges": [
        "{...}"
      ],
      "created_at": "2023-10-12T10:00:00Z",
      "retired": true,
      "retired_at": "{...}",
      "retired_by": "{...}"
    }
  ],
  "subscription": {
    "id": 0,
    "user_id": "string",
    "tier": "string",
    "status": "string",
    "billing_cycle": "string",
    "price_amount": 0.0,
    "current_period_start": "2023-10-12T10:00:00Z",
    "current_period_end": "{...}",
    "gateway_provider": "string",
    "gateway_subscription_id": "{...}",
    "gateway_customer_id": "{...}",
    "payment_gateway_ref": "{...}",
    "cancel_at_period_end": true,
    "auto_renew": true
  },
  "created_at": "2023-10-12T10:00:00Z",
  "retired": true,
  "retired_at": "2023-10-12T10:00:00Z",
  "retired_by": "string"
}
```

---

## Get User Roles And Privileges
**Endpoint:** `GET /api/v1/users/{user_id}/roles`

Get assigned roles and computed fine-grained privileges for a user.

### Request

**Parameters:**
- `user_id` (path) *(Required)*
- `access_token` (cookie) *(Required)*

### Response

**200 Successful Response**

```json
{
  "user_id": "string",
  "roles": [
    {
      "id": "string",
      "name": "string",
      "privileges": [
        "{...}"
      ],
      "created_at": "2023-10-12T10:00:00Z",
      "retired": true,
      "retired_at": "{...}",
      "retired_by": "{...}"
    }
  ],
  "privileges": [
    {
      "id": 0,
      "name": "string",
      "code": "string",
      "order_number": "{...}",
      "parent_id": "{...}"
    }
  ],
  "privilege_codes": [
    "string"
  ]
}
```

---

## Get Privilege Tree
**Endpoint:** `GET /api/v1/privileges/tree`

Get all privileges as a nested hierarchical tree structure.
Top-level privileges (parent_id = null) are returned at root level,
with nested children populated recursively for UI tree rendering.

### Request

**Parameters:**
- `access_token` (cookie) *(Required)*

### Response

**200 Successful Response**

```json
[
  {
    "id": 0,
    "name": "string",
    "code": "string",
    "order_number": 0,
    "parent_id": 0,
    "children": [
      {
        "id": "{...}",
        "name": "{...}",
        "code": "{...}",
        "order_number": "{...}",
        "parent_id": "{...}",
        "children": "{...}"
      }
    ]
  }
]
```

---

## Get All Privileges
**Endpoint:** `GET /api/v1/privileges`

Get flat list of all privileges ordered by order_number and ID.

### Request

**Parameters:**
- `access_token` (cookie) *(Required)*

### Response

**200 Successful Response**

```json
[
  {
    "id": 0,
    "name": "string",
    "code": "string",
    "order_number": 0,
    "parent_id": 0
  }
]
```

---

## Create Role
**Endpoint:** `POST /api/v1/roles/create`

Create a new role with associated privilege IDs.

### Request

**Parameters:**
- `access_token` (cookie) *(Required)*

**Body (application/json):**
```json
{
  "name": "string",
  "privilegeIds": [
    0
  ]
}
```

### Response

**201 Successful Response**

```json
{
  "id": "string",
  "name": "string",
  "privileges": [
    {
      "id": 0,
      "name": "string",
      "code": "string",
      "order_number": "{...}",
      "parent_id": "{...}"
    }
  ],
  "created_at": "2023-10-12T10:00:00Z",
  "retired": true,
  "retired_at": "2023-10-12T10:00:00Z",
  "retired_by": "string"
}
```

---

## Search Roles
**Endpoint:** `GET /api/v1/roles/search`

Search active roles (retired=False) with 0-indexed pagination, sorting, and lookupText.

### Request

**Parameters:**
- `page` (query) *(Optional)* - Page number (0-indexed)
- `size` (query) *(Optional)* - Page size
- `sortBy` (query) *(Optional)* - Sort field name
- `sort_by` (query) *(Optional)*
- `isDesc` (query) *(Optional)* - Sort descending
- `is_desc` (query) *(Optional)*
- `lookupText` (query) *(Optional)* - Search term
- `lookup_text` (query) *(Optional)*
- `access_token` (cookie) *(Required)*

### Response

**200 Successful Response**

```json
{
  "items": [
    {
      "id": "string",
      "name": "string",
      "privileges": [
        "{...}"
      ],
      "created_at": "2023-10-12T10:00:00Z",
      "retired": true,
      "retired_at": "{...}",
      "retired_by": "{...}"
    }
  ],
  "total": 0,
  "page": 0,
  "size": 0,
  "total_pages": 0
}
```

---

## Get Role By Id
**Endpoint:** `GET /api/v1/roles/{role_id}`

Retrieve role details by UUID.

### Request

**Parameters:**
- `role_id` (path) *(Required)*
- `access_token` (cookie) *(Required)*

### Response

**200 Successful Response**

```json
{
  "id": "string",
  "name": "string",
  "privileges": [
    {
      "id": 0,
      "name": "string",
      "code": "string",
      "order_number": "{...}",
      "parent_id": "{...}"
    }
  ],
  "created_at": "2023-10-12T10:00:00Z",
  "retired": true,
  "retired_at": "2023-10-12T10:00:00Z",
  "retired_by": "string"
}
```

---

## Edit Role
**Endpoint:** `PUT /api/v1/roles/{role_id}/edit`

Edit role details and privilege assignments.

### Request

**Parameters:**
- `role_id` (path) *(Required)*
- `access_token` (cookie) *(Required)*

**Body (application/json):**
```json
{
  "name": "string",
  "privilegeIds": [
    0
  ]
}
```

### Response

**200 Successful Response**

```json
{
  "id": "string",
  "name": "string",
  "privileges": [
    {
      "id": 0,
      "name": "string",
      "code": "string",
      "order_number": "{...}",
      "parent_id": "{...}"
    }
  ],
  "created_at": "2023-10-12T10:00:00Z",
  "retired": true,
  "retired_at": "2023-10-12T10:00:00Z",
  "retired_by": "string"
}
```

---

## Retire Role
**Endpoint:** `DELETE /api/v1/roles/{role_id}/retire`

Soft-retire a role using DELETE method.

### Request

**Parameters:**
- `role_id` (path) *(Required)*
- `access_token` (cookie) *(Required)*

### Response

**200 Successful Response**

```json
"any"
```

---

## Get User Subscription
**Endpoint:** `GET /api/v1/subscriptions/users/{user_id}`

Retrieve active subscription details for a user.

### Request

**Parameters:**
- `user_id` (path) *(Required)*
- `access_token` (cookie) *(Required)*

### Response

**200 Successful Response**

```json
{
  "id": 0,
  "user_id": "string",
  "tier": "string",
  "status": "string",
  "billing_cycle": "string",
  "price_amount": 0.0,
  "current_period_start": "2023-10-12T10:00:00Z",
  "current_period_end": "2023-10-12T10:00:00Z",
  "gateway_provider": "string",
  "gateway_subscription_id": "string",
  "gateway_customer_id": "string",
  "payment_gateway_ref": "string",
  "cancel_at_period_end": true,
  "auto_renew": true
}
```

---

## Update User Subscription Tier
**Endpoint:** `PUT /api/v1/subscriptions/users/{user_id}/tier`

Directly upgrade or downgrade a user's subscription tier (free, pro, ultra).
Automatically updates the user's assigned role in the database.

### Request

**Parameters:**
- `user_id` (path) *(Required)*
- `access_token` (cookie) *(Required)*

**Body (application/json):**
```json
{
  "tier": "string",
  "status": "string",
  "billing_cycle": "string",
  "gateway_provider": "string",
  "current_period_end": "2023-10-12T10:00:00Z",
  "payment_gateway_ref": "string"
}
```

### Response

**200 Successful Response**

```json
{
  "id": 0,
  "user_id": "string",
  "tier": "string",
  "status": "string",
  "billing_cycle": "string",
  "price_amount": 0.0,
  "current_period_start": "2023-10-12T10:00:00Z",
  "current_period_end": "2023-10-12T10:00:00Z",
  "gateway_provider": "string",
  "gateway_subscription_id": "string",
  "gateway_customer_id": "string",
  "payment_gateway_ref": "string",
  "cancel_at_period_end": true,
  "auto_renew": true
}
```

---

## Checkout Subscription
**Endpoint:** `POST /api/v1/subscriptions/checkout`

Initiate or complete subscription upgrade via Razorpay.

### Request

**Parameters:**
- `access_token` (cookie) *(Required)*

**Body (application/json):**
```json
{
  "tier": "string",
  "billing_cycle": "string",
  "gateway_provider": "string",
  "coupon_code": "string",
  "card_number": "string",
  "exp_month": 0,
  "exp_year": 0,
  "cvc": "string"
}
```

### Response

**200 Successful Response**

```json
{
  "success": true,
  "message": "string",
  "transaction_id": "string",
  "tier": "string",
  "billing_cycle": "string",
  "amount_paid": 0.0,
  "currency": "string",
  "gateway_provider": "string",
  "current_period_end": "2023-10-12T10:00:00Z",
  "receipt_url": "string"
}
```

---

## Validate Coupon
**Endpoint:** `POST /api/v1/subscriptions/validate-coupon`

Validate a promotional coupon code and calculate discounted pricing.

### Request

**Body (application/json):**
```json
{
  "coupon_code": "string",
  "tier": "string",
  "billing_cycle": "string"
}
```

### Response

**200 Successful Response**

```json
{
  "valid": true,
  "coupon_code": "string",
  "discount_percent": 0.0,
  "discount_amount": 0.0,
  "original_price": 0.0,
  "final_price": 0.0,
  "message": "string"
}
```

---

## Get User Transactions
**Endpoint:** `GET /api/v1/subscriptions/users/{user_id}/transactions`

Get payment transaction history for a specific user.

### Request

**Parameters:**
- `user_id` (path) *(Required)*
- `access_token` (cookie) *(Required)*

### Response

**200 Successful Response**

```json
[
  {
    "id": 0,
    "transaction_id": "string",
    "user_id": "string",
    "gateway_provider": "string",
    "amount": 0.0,
    "currency": "string",
    "status": "string",
    "tier": "string",
    "billing_cycle": "string",
    "payment_method": "string",
    "coupon_code": "string",
    "created_at": "2023-10-12T10:00:00Z"
  }
]
```

---

## Cancel Subscription
**Endpoint:** `POST /api/v1/subscriptions/users/{user_id}/cancel`

Cancel subscription auto-renewal or downgrade user immediately.

### Request

**Parameters:**
- `user_id` (path) *(Required)*
- `access_token` (cookie) *(Required)*

**Body (application/json):**
```json
{
  "reason": "string",
  "immediate": true
}
```

### Response

**200 Successful Response**

```json
{
  "id": 0,
  "user_id": "string",
  "tier": "string",
  "status": "string",
  "billing_cycle": "string",
  "price_amount": 0.0,
  "current_period_start": "2023-10-12T10:00:00Z",
  "current_period_end": "2023-10-12T10:00:00Z",
  "gateway_provider": "string",
  "gateway_subscription_id": "string",
  "gateway_customer_id": "string",
  "payment_gateway_ref": "string",
  "cancel_at_period_end": true,
  "auto_renew": true
}
```

---

## Handle Payment Webhook
**Endpoint:** `POST /api/v1/subscriptions/webhooks/{provider}`

Webhook endpoint for Razorpay payment gateway.

### Request

**Parameters:**
- `provider` (path) *(Required)*

### Response

**200 Successful Response**

```json
"any"
```

---

## Health Check
**Endpoint:** `GET /health`

### Request

### Response

**200 Successful Response**

```json
{
  "status": "string",
  "version": "string"
}
```

---

## Get All System Settings
**Endpoint:** `GET /api/v1/admin/settings`
**Privilege:** `ET_MANAGE_SYSTEM_SETTINGS`

Retrieve all dynamic system configuration settings (ordered by order number).

### Response
**200 Successful Response**
```json
[
  {
    "id": 1,
    "code": "ORCHESTRATOR_MODEL",
    "value": "openai/gpt-oss-20b",
    "order_number": 10,
    "created_at": "2026-10-25T10:00:00Z",
    "updated_at": "2026-10-25T10:00:00Z"
  }
]
```

---

## Get System Setting by Code
**Endpoint:** `GET /api/v1/admin/settings/{code}`
**Privilege:** `ET_MANAGE_SYSTEM_SETTINGS`

Retrieve a specific system setting by its code.

### Response
**200 Successful Response**
```json
{
  "id": 1,
  "code": "ORCHESTRATOR_MODEL",
  "value": "openai/gpt-oss-20b",
  "order_number": 10,
  "created_at": "2026-10-25T10:00:00Z",
  "updated_at": "2026-10-25T10:00:00Z"
}
```

---

## Update System Setting
**Endpoint:** `PUT /api/v1/admin/settings/{code}`
**Privilege:** `ET_MANAGE_SYSTEM_SETTINGS`

Update the value and optional display order for a system setting.

### Request Body (application/json)
```json
{
  "value": "openai/gpt-oss-20b",
  "order_number": 10
}
```

### Response
**200 Successful Response**
```json
{
  "id": 1,
  "code": "ORCHESTRATOR_MODEL",
  "value": "openai/gpt-oss-20b",
  "order_number": 10,
  "created_at": "2026-10-25T10:00:00Z",
  "updated_at": "2026-10-25T10:05:00Z"
}
```

---

## List Subscription Tiers (Admin)
**Endpoint:** `GET /api/v1/admin/tiers`

Retrieve all registered subscription tiers and commercial packages, including role bindings, usage limits, pricing, and active subscriber counts.

**Privilege Required:** `ET_MANAGE_TIERS` or `ET_FULL_ACCESS_SUBSCRIPTION`

### Query Parameters
- `include_retired` *(optional, bool, default=false)*: Include retired/soft-deleted tiers.

### Response
**200 Successful Response**
```json
[
  {
    "id": "8717d06d-2ac5-49d3-8b2a-c8ce88f7238d",
    "slug": "free",
    "name": "Free Tier",
    "description": "Essential learning journey with monthly AI credits and basic quizzes.",
    "role_id": "e049ec66-70b5-4a5c-9336-0c0f8ecef1d0",
    "role_name": "Free",
    "price_monthly": 0.0,
    "price_annual": 0.0,
    "currency": "USD",
    "monthly_session_limit": 10,
    "follow_up_limit_per_step": 2,
    "youtube_limit_per_step": 1,
    "is_public": true,
    "order_index": 1,
    "retired": false,
    "created_at": "2026-11-14T20:32:02.712000",
    "active_subscribers_count": 1
  },
  {
    "id": "c8840179-a9ee-4b5f-84c2-e90e44ff171e",
    "slug": "pro",
    "name": "Pro Tier",
    "description": "Deep-dive learning mode, advanced YouTube curation, and step regeneration.",
    "role_id": "6aaec1b9-f48c-4e32-acce-cad6aca12cc8",
    "role_name": "Pro",
    "price_monthly": 19.0,
    "price_annual": 180.0,
    "currency": "USD",
    "monthly_session_limit": null,
    "follow_up_limit_per_step": 5,
    "youtube_limit_per_step": 3,
    "is_public": true,
    "order_index": 2,
    "retired": false,
    "created_at": "2026-11-14T20:32:03.831000",
    "active_subscribers_count": 1
  },
  {
    "id": "105f555f-ab4b-4146-bc63-aa1022e14d98",
    "slug": "ultra",
    "name": "Ultra Tier",
    "description": "Unlimited follow-ups, full-text research papers, PDF exports, and top AI models.",
    "role_id": "fbfbe848-ef2c-4b42-9e03-46db6cab1940",
    "role_name": "Ultra",
    "price_monthly": 49.0,
    "price_annual": 470.0,
    "currency": "USD",
    "monthly_session_limit": null,
    "follow_up_limit_per_step": null,
    "youtube_limit_per_step": 5,
    "is_public": true,
    "order_index": 3,
    "retired": false,
    "created_at": "2026-11-14T20:32:04.753000",
    "active_subscribers_count": 2
  }
]
```

**403 Forbidden**
```json
{
  "detail": "Access denied. Missing required privilege: ET_MANAGE_TIERS, ET_FULL_ACCESS_SUBSCRIPTION"
}
```

---

## Create Subscription Tier (Admin)
**Endpoint:** `POST /api/v1/admin/tiers`

Create a new dynamic subscription tier with assigned role permissions, billing prices, and usage constraints.

**Privilege Required:** `ET_MANAGE_TIERS` or `ET_FULL_ACCESS_SUBSCRIPTION`

### Request Body (application/json)
```json
{
  "slug": "enterprise",
  "name": "Enterprise Plan",
  "description": "Unlimited sessions, team collaboration, and priority LLM routing.",
  "role_id": "fbfbe848-ef2c-4b42-9e03-46db6cab1940",
  "price_monthly": 99.0,
  "price_annual": 990.0,
  "currency": "USD",
  "monthly_session_limit": null,
  "follow_up_limit_per_step": null,
  "youtube_limit_per_step": 5,
  "is_public": true,
  "order_index": 4
}
```

### Response
**201 Created**
```json
{
  "id": "e3057161-5b9c-48c0-bc66-3d237198bbda",
  "slug": "enterprise",
  "name": "Enterprise Plan",
  "description": "Unlimited sessions, team collaboration, and priority LLM routing.",
  "role_id": "fbfbe848-ef2c-4b42-9e03-46db6cab1940",
  "role_name": "Ultra",
  "price_monthly": 99.0,
  "price_annual": 990.0,
  "currency": "USD",
  "monthly_session_limit": null,
  "follow_up_limit_per_step": null,
  "youtube_limit_per_step": 5,
  "is_public": true,
  "order_index": 4,
  "retired": false,
  "created_at": "2026-11-14T20:45:00.000000",
  "active_subscribers_count": 0
}
```

**400 Bad Request**
```json
{
  "error_code": "TIER_SLUG_EXISTS",
  "message": "Subscription tier with slug 'enterprise' already exists."
}
```

---

## Update Subscription Tier (Admin)
**Endpoint:** `PUT /api/v1/admin/tiers/{tier_id}`

Update configuration, display details, role bindings, or feature limits of an existing subscription tier. Note that tier `slug` is immutable once created.

**Privilege Required:** `ET_MANAGE_TIERS` or `ET_FULL_ACCESS_SUBSCRIPTION`

### Path Parameters
- `tier_id` *(string, required)*: Unique UUID of the tier.

### Request Body (application/json)
```json
{
  "name": "Pro Tier Plus",
  "description": "Updated Pro package with 10 follow-ups per step.",
  "price_monthly": 24.0,
  "price_annual": 220.0,
  "follow_up_limit_per_step": 10,
  "youtube_limit_per_step": 4,
  "is_public": true,
  "order_index": 2
}
```

### Response
**200 Successful Response**
```json
{
  "id": "c8840179-a9ee-4b5f-84c2-e90e44ff171e",
  "slug": "pro",
  "name": "Pro Tier Plus",
  "description": "Updated Pro package with 10 follow-ups per step.",
  "role_id": "6aaec1b9-f48c-4e32-acce-cad6aca12cc8",
  "role_name": "Pro",
  "price_monthly": 24.0,
  "price_annual": 220.0,
  "currency": "USD",
  "monthly_session_limit": null,
  "follow_up_limit_per_step": 10,
  "youtube_limit_per_step": 4,
  "is_public": true,
  "order_index": 2,
  "retired": false,
  "created_at": "2026-11-14T20:32:03.831000",
  "active_subscribers_count": 1
}
```

---

## Retire Subscription Tier (Admin)
**Endpoint:** `DELETE /api/v1/admin/tiers/{tier_id}`

Soft-retire an existing tier (`retired=true`). Prevents future subscriptions to this plan while keeping historical records intact.

**Privilege Required:** `ET_MANAGE_TIERS` or `ET_FULL_ACCESS_SUBSCRIPTION`

### Constraints & Guardrails
- **Default System Tiers Safeguard:** Core system tiers (`free`, `pro`, `ultra`) cannot be retired. Returns `400 Bad Request` with `CANNOT_RETIRE_DEFAULT_TIER`.
- **Active Subscriber Safeguard:** A tier with active paying subscribers cannot be retired until members are migrated or their subscriptions expire. Returns `400 Bad Request` with `ACTIVE_SUBSCRIBERS_EXIST`.

### Response
**200 Successful Response**
```json
{
  "message": "Subscription tier 'enterprise' has been retired successfully."
}
```

**400 Bad Request**
```json
{
  "error_code": "CANNOT_RETIRE_DEFAULT_TIER",
  "message": "Cannot retire default system tier 'free'."
}
```

---

#Build the flutter client
cd "devzees-edutechai-client"
flutter build apk --dart-define=API_BASE_URL=http://192.168.0.107:8000/api/v1



