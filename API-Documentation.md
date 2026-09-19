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
    *   `GET /api/v1/sessions`
    *   `GET /api/v1/sessions/{session_id}`
    *   `DELETE /api/v1/sessions/{session_id}`
    *   `POST /api/v1/sessions/{session_id}/step/{step_index}/complete`
    *   `POST /api/v1/sessions/{session_id}/step/{step_index}/followup`
    *   `POST /api/v1/sessions/{session_id}/step/{step_index}/regenerate`
*   **Academic Search** (`academic_service.dart`):
    *   `GET /api/v1/academic/search`
*   **Quiz** (`learning_service.dart`):
    *   `POST /api/v1/quiz/submit`

**Pending / Not Integrated APIs:**

*   `POST /api/v1/sessions/{session_id}/mode` (Change Learning Mode)
*   `GET /api/v1/export/{session_id}/md` (Export Markdown)
*   `GET /api/v1/export/{session_id}/pdf` (Export PDF)
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

Initiate or complete subscription upgrade via requested gateway (Paddle, Sandbox, Razorpay).

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

Webhook endpoint for payment gateways (Paddle, Razorpay, etc.).

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

