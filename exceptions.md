# EduTechAI — Master Exception & Error Code Reference

> Comprehensive architectural catalog of all exceptions, error codes, HTTP status codes, and exact error messages produced across the **EduTechAI** ecosystem (`devzees-edutechai-server` and `devzees-edutechai-client`).

---

## 1. System Architecture & Standard Error Envelope

All REST API endpoints in EduTechAI return a standardized JSON error envelope defined by the Pydantic `APIError` schema whenever an error occurs (handled via custom application exception handlers in `app/main.py`).

### 1.1 API Error JSON Structure

```json
{
  "http_status": 401,
  "error_code": "INVALID_CREDENTIALS",
  "errors": [
    "Invalid email address or password."
  ],
  "timestamp": "2026-11-08T12:00:00Z",
  "path_uri": "/api/v1/auth/login"
}
```

### 1.2 Envelope Fields Definition

| Field | Type | Description |
| :--- | :--- | :--- |
| `http_status` | `integer` | Standard RFC 7231 HTTP status code (e.g., `400`, `401`, `403`, `404`, `409`, `422`, `500`). |
| `error_code` | `string` | Machine-readable domain-specific uppercase error identifier (e.g., `TOKEN_EXPIRED`, `EMAIL_ALREADY_EXISTS`). |
| `errors` | `array[string]` | Human-readable list of exact error descriptions presented directly to clients/users. |
| `timestamp` | `string (ISO-8601)` | Precise UTC timestamp recording when the exception was trapped. |
| `path_uri` | `string` | The exact HTTP request endpoint path that triggered the exception. |

---

## 2. Master Quick-Reference Matrix

| Error Code | HTTP Status | Originating Component | Exact Error Message / Template |
| :--- | :---: | :--- | :--- |
| **`UNAUTHORIZED`** | `401` | `dependencies.py` | `"Authentication required. Please log in."` |
| **`INVALID_TOKEN`** | `401` | `dependencies.py`, `auth_service.py` | `"Token payload is invalid or missing subject."`<br>`"Invalid authentication token provided."` |
| **`TOKEN_EXPIRED`** | `401` | `auth_service.py` | `"Session expired. Please login again."` |
| **`TOKEN_REVOKED`** | `401` | `dependencies.py` | `"Session has been terminated. Please log in again."` |
| **`TOKEN_REUSE_DETECTED`** | `401` | `auth_service.py` | `"Compromised session detected. Please log in again."` |
| **`REFRESH_TOKEN_EXPIRED`** | `401` | `auth_service.py` | `"Refresh token has expired. Please log in again."` |
| **`INVALID_REFRESH_TOKEN`** | `401` | `auth_service.py` | `"Refresh token is invalid or does not exist."` |
| **`TOKEN_MISSING`** | `401` | `routers/auth.py` | `"Refresh token is missing."` |
| **`INVALID_CREDENTIALS`** | `401` | `auth_service.py` | `"Invalid email address or password."` |
| **`USER_RETIRED`** | `401` | `auth_service.py` | `"Your account has been retired. Please contact support."` |
| **`USER_NOT_FOUND`** | `401` | `dependencies.py`, `auth_service.py` | `"Authenticated user not found or account is retired."`<br>`"User account not found or retired."` |
| **`PERMISSION_DENIED`** | `403` | `dependencies.py`, `routers/users.py` | `"Access denied. You do not have permission to perform this action."`<br>`"Access denied. You can only change your own password."` |
| **`ROLE_REQUIRED`** | `403` | `dependencies.py` | `"Access denied. You do not have permission to perform this action."` |
| **`MODE_UPGRADE_REQUIRED`** | `403` | `routers/learning.py` | `"Upgrade to Pro or Ultra to access Deep Dive mode."` |
| **`SESSION_QUOTA_EXCEEDED`** | `403` | `routers/learning.py` | `"You have reached your limit of 10 free AI sessions this month. Upgrade to Pro for unlimited sessions."` |
| **`SESSION_FORBIDDEN`** | `403` | `routers/feedback.py` | `"You can only submit feedback for your own learning sessions."` |
| **`INVALID_STEP_INDEX`** | `400` | `routers/learning.py` | `"Step index {step_index} out of range [0, {max_index}]"` |
| **`QUIZ_NOT_FOUND`** | `400` | `routers/quiz.py` | `"No quiz found for step {step_index}."` |
| **`SESSION_INCOMPLETE`** | `400` | `services/export_service.py` | `"Export is only available when the learning journey is completed. Session has no steps."`<br>`"Export is only available when the learning journey is completed. All steps must be finished."` |
| **`FEEDBACK_ALREADY_SUBMITTED`** | `400` | `routers/feedback.py` | `"Feedback has already been submitted for this session."` |
| **`INVALID_STATUS`** | `400` | `routers/feedback.py` | `"Status must be one of: {valid_statuses}."` |
| **`INVALID_OLD_PASSWORD`** | `400` | `services/user_service.py` | `"Old password is incorrect."` |
| **`SAME_PASSWORD`** | `400` | `services/user_service.py` | `"New password must be different from current password."` |
| **`USER_ALREADY_RETIRED`** | `400` | `services/user_service.py` | `"User with ID '{user_id}' is already retired."` |
| **`INVALID_ROLE_ID`** | `400` | `services/user_service.py` | `"Role ID(s) {missing_ids} do not exist or are retired."` |
| **`INVALID_PRIVILEGE_ID`** | `400` | `services/role_service.py` | `"Privilege ID(s) {missing_ids} do not exist."` |
| **`ROLE_ALREADY_RETIRED`** | `400` | `services/role_service.py` | `"Role with ID '{role_id}' is already retired."` |
| **`INVALID_TIER`** | `400` | `services/payment_service.py`, `services/subscription_service.py` | `"Invalid target tier '{tier}'. Must be 'pro' or 'ultra'."`<br>`"Invalid tier '{tier}'. Must be one of {catalog_keys}."` |
| **`INVALID_COUPON`** | `400` | `services/subscription_service.py` | Dynamic coupon failure message (e.g. `"Coupon code 'XYZ' is invalid or expired."`) |
| **`PAYMENT_VERIFICATION_FAILED`** | `400` | `services/subscription_service.py` | `"Razorpay payment verification failed: Invalid cryptographic signature."` |
| **`PAYMENT_FAILED`** | `400` | `services/subscription_service.py` | Dynamic error from payment gateway. |
| **`GATEWAY_ERROR`** | `400` | `services/payment_service.py` | `"Razorpay order creation failed: {err_msg}"` |
| **`GATEWAY_TIMEOUT`** | `400` | `services/payment_service.py` | `"Could not connect to Razorpay payment gateway: {exc}"` |
| **`INVALID_SUBSCRIPTION_TIER`** | `400` | `services/subscription_service.py` | `"Invalid tier '{tier}'. Must be one of {tier_keys}."` |
| **`CANNOT_CANCEL_FREE`** | `400` | `services/subscription_service.py` | `"User is already on the Free tier."` |
| **`SESSION_NOT_FOUND`** | `404` | `routers/learning.py`, `routers/exports.py`, `routers/feedback.py` | `"Session not found."`<br>`"Session '{session_id}' not found."`<br>`"Session '{session_id}' not found or not owned by user."` |
| **`QUIZ_NOT_AVAILABLE`** | `404` | `routers/quiz.py` | `"No quiz available for step {step_index}."` |
| **`FEEDBACK_NOT_FOUND`** | `404` | `routers/feedback.py` | `"Feedback '{feedback_id}' not found."` |
| **`USER_NOT_FOUND`** | `404` | `services/user_service.py` | `"User with ID '{user_id}' was not found."` |
| **`ROLE_NOT_FOUND`** | `404` | `services/role_service.py` | `"Role with ID '{role_id}' was not found."` |
| **`SETTING_NOT_FOUND`** | `404` | `services/setting_service.py` | `"System setting with code '{code}' not found."` |
| **`EMAIL_ALREADY_EXISTS`** | `409` | `services/user_service.py` | `"A user with email '{email}' already exists."` |
| **`ROLE_NAME_ALREADY_EXISTS`** | `409` | `services/role_service.py` | `"A role with name '{name}' already exists."` |
| **`VALIDATION_ERROR`** | `422` | FastAPI `RequestValidationError` | Pydantic validation errors (length, format, regex, value checks). |
| **`INTERNAL_SERVER_ERROR`** | `500` | `app/main.py` unhandled catch-all | `"Something went wrong. Please try again or contact support."` |

---

## 3. Server Exception Details by Module

### 3.1 Authentication & Token Lifecycle (`app/dependencies.py` & `services/auth_service.py`)

#### HTTP 401 — Unauthorized
1. **`UNAUTHORIZED`**
   - **Exact Message:** `"Authentication required. Please log in."`
   - **Trigger:** Endpoint requires an authenticated session, but neither `access_token` HTTP cookie nor `Authorization: Bearer <token>` header was provided.
   - **File:** `app/dependencies.py:44`

2. **`INVALID_TOKEN`**
   - **Exact Messages:**
     - `"Token payload is invalid or missing subject."` (`app/dependencies.py:63`)
     - `"Invalid authentication token provided."` (`services/auth_service.py:86`)
   - **Trigger:** JWT signature verification failed, header is malformed, or the JWT `sub` (user ID) claim is missing or null.

3. **`TOKEN_EXPIRED`**
   - **Exact Message:** `"Session expired. Please login again."`
   - **Trigger:** Access token expiration timestamp (`exp`) has elapsed. Client triggers transparent refresh or re-login.
   - **File:** `services/auth_service.py:81`

4. **`TOKEN_REVOKED`**
   - **Exact Message:** `"Session has been terminated. Please log in again."`
   - **Trigger:** The user logged out or changed their password, updating `tokens_invalidated_before`. All tokens issued prior to that timestamp are revoked.
   - **File:** `app/dependencies.py:81`

5. **`TOKEN_REUSE_DETECTED`**
   - **Exact Message:** `"Compromised session detected. Please log in again."`
   - **Trigger:** An already revoked refresh token was submitted to `/api/v1/auth/refresh`. The security engine immediately revokes **all** active tokens for this user as a session hijacking safeguard.
   - **File:** `services/auth_service.py:234`

6. **`REFRESH_TOKEN_EXPIRED`**
   - **Exact Message:** `"Refresh token has expired. Please log in again."`
   - **Trigger:** Refresh token exceeded its maximum lifespan (default: 30 days).
   - **File:** `services/auth_service.py:240`

7. **`INVALID_REFRESH_TOKEN`**
   - **Exact Message:** `"Refresh token is invalid or does not exist."`
   - **Trigger:** Refresh token string does not match any record in `refresh_tokens` database table.
   - **File:** `services/auth_service.py:214`

8. **`TOKEN_MISSING`**
   - **Exact Message:** `"Refresh token is missing."`
   - **Trigger:** POST `/api/v1/auth/refresh` called without cookie or body refresh token.
   - **File:** `app/routers/auth.py:85`

9. **`INVALID_CREDENTIALS`**
   - **Exact Message:** `"Invalid email address or password."`
   - **Trigger:** Login attempt with unknown email or incorrect bcrypt password hash.
   - **File:** `services/auth_service.py:115`, `services/auth_service.py:127`

10. **`USER_RETIRED`**
    - **Exact Message:** `"Your account has been retired. Please contact support."`
    - **Trigger:** Login attempted by a soft-deleted (`retired = True`) user.
    - **File:** `services/auth_service.py:121`

11. **`USER_NOT_FOUND`**
    - **Exact Messages:**
      - `"Authenticated user not found or account is retired."` (`app/dependencies.py:73`)
      - `"User account not found or retired."` (`services/auth_service.py:252`)
    - **Trigger:** Token references a user ID that no longer exists in PostgreSQL or is retired.

---

### 3.2 Authorization & Access Control (`app/dependencies.py` & `app/routers/`)

#### HTTP 403 — Forbidden
1. **`PERMISSION_DENIED`**
   - **Exact Messages:**
     - `"Access denied. You do not have permission to perform this action."` (`app/dependencies.py:161` — missing privilege code is recorded in server security logs)
     - `"Access denied. You can only change your own password."` (`app/routers/users.py:147`)
   - **Trigger:** User lacks the required RBAC privilege code (e.g. `ET_ACCESS_ADMIN_PORTAL`, `ET_MANAGE_USERS`), or attempted to modify another user's password without administrative override.

2. **`ROLE_REQUIRED`**
   - **Exact Message:** `"Access denied. You do not have permission to perform this action."` (`app/dependencies.py:186` — missing role is recorded in server security logs)
   - **Trigger:** User is missing a specifically required role (e.g. `Admin`, `Super Admin`).
   - **File:** `app/dependencies.py:186`

3. **`MODE_UPGRADE_REQUIRED`**
   - **Exact Message:** `"Upgrade to Pro or Ultra to access Deep Dive mode."`
   - **Trigger:** Free tier user attempted to start or change a learning journey with `learning_mode="deep_dive"`.
   - **File:** `app/routers/learning.py:125`, `app/routers/learning.py:384`

4. **`SESSION_QUOTA_EXCEEDED`**
   - **Exact Message:** `"You have reached your limit of 10 free AI sessions this month. Upgrade to Pro for unlimited sessions."`
   - **Trigger:** Free tier account has initiated 10 or more AI learning sessions within the current calendar month.
   - **File:** `app/routers/learning.py:136`

5. **`SESSION_FORBIDDEN`**
   - **Exact Message:** `"You can only submit feedback for your own learning sessions."`
   - **Trigger:** A user attempted to submit a feedback rating or testimonial for a session owned by another student.
   - **File:** `app/routers/feedback.py:82`

---

### 3.3 Learning Journey & Tutoring (`app/routers/learning.py` & `app/routers/quiz.py`)

#### HTTP 400 — Bad Request
1. **`INVALID_STEP_INDEX`**
   - **Exact Message:** `"Step index {step_index} out of range [0, {len(memory.steps) - 1}]"`
   - **Trigger:** Request to mark complete, tutor chat, or regenerate step with a negative index or an index exceeding total milestone steps.
   - **File:** `app/routers/learning.py:192, 283, 333`

2. **`QUIZ_NOT_FOUND`**
   - **Exact Message:** `"No quiz found for step {submission.step_index}."`
   - **Trigger:** Quiz submission received for a step where no quiz questions were generated.
   - **File:** `app/routers/quiz.py:49`

#### HTTP 404 — Not Found
1. **`SESSION_NOT_FOUND`**
   - **Exact Messages:**
     - `"Session '{session_id}' not found."` (`app/routers/learning.py:67`)
     - `"Session '{session_id}' not found or not owned by user."` (`app/routers/learning.py:455`)
   - **Trigger:** Session ID does not exist in memory or database, or belongs to another user during deletion.

2. **`QUIZ_NOT_AVAILABLE`**
   - **Exact Message:** `"No quiz available for step {step_index}."`
   - **Trigger:** GET quiz for a milestone step where quiz questions are null/empty.
   - **File:** `app/routers/quiz.py:164`

---

### 3.4 Exports & Document Generation (`app/routers/exports.py` & `services/export_service.py`)

#### HTTP 400 — Bad Request
1. **`SESSION_INCOMPLETE`**
   - **Exact Messages:**
     - `"Export is only available when the learning journey is completed. Session has no steps."` (`services/export_service.py:35`)
     - `"Export is only available when the learning journey is completed. All steps must be finished."` (`services/export_service.py:54`)
   - **Trigger:** Student attempted to export Markdown, PDF, or HTML before 100% of milestones were completed.

#### HTTP 404 — Not Found
1. **`SESSION_NOT_FOUND`**
   - **Exact Message:** `"Session not found."`
   - **Trigger:** Session requested for export does not exist.
   - **File:** `app/routers/exports.py:55, 82, 117`

#### HTTP 500 — Server Error
1. **`INTERNAL_SERVER_ERROR`**
   - **Exact Message:** `"Failed to generate PDF"`
   - **Trigger:** ReportLab or WeasyPrint document compilation exception occurred during binary generation.
   - **File:** `services/export_service.py:1897`

---

### 3.5 Feedback & Testimonials (`app/routers/feedback.py`)

#### HTTP 400 — Bad Request
1. **`FEEDBACK_ALREADY_SUBMITTED`**
   - **Exact Message:** `"Feedback has already been submitted for this session."`
   - **Trigger:** Attempted to submit a duplicate feedback record for a learning session that already has feedback recorded.
   - **File:** `app/routers/feedback.py:94`

2. **`INVALID_STATUS`**
   - **Exact Message:** `"Status must be one of: {', '.join(valid_statuses)}."`
   - **Valid Values:** `pending`, `approved`, `rejected`
   - **Trigger:** Admin status update request supplied an unrecognized status enum.
   - **File:** `app/routers/feedback.py:328`

#### HTTP 404 — Not Found
1. **`SESSION_NOT_FOUND`**
   - **Exact Message:** `"Session '{request.session_id}' not found."`
   - **File:** `app/routers/feedback.py:76`

2. **`FEEDBACK_NOT_FOUND`**
   - **Exact Message:** `"Feedback '{feedback_id}' not found."`
   - **File:** `app/routers/feedback.py:340`

---

### 3.6 User Management (`services/user_service.py` & `app/routers/users.py`)

#### HTTP 400 — Bad Request
1. **`INVALID_OLD_PASSWORD`**
   - **Exact Message:** `"Old password is incorrect."`
   - **Trigger:** Changing password with an incorrect verification password.
   - **File:** `services/user_service.py:148`

2. **`SAME_PASSWORD`**
   - **Exact Message:** `"New password must be different from current password."`
   - **Trigger:** New password matches the existing password.
   - **File:** `services/user_service.py:154`

3. **`USER_ALREADY_RETIRED`**
   - **Exact Message:** `"User with ID '{user_id}' is already retired."`
   - **Trigger:** Attempted to soft-delete an account that was already retired.
   - **File:** `services/user_service.py:185`

4. **`INVALID_ROLE_ID`**
   - **Exact Message:** `"Role ID(s) {missing_ids} do not exist or are retired."`
   - **Trigger:** Admin role assignment payload references non-existent role IDs.
   - **File:** `services/user_service.py:270`

#### HTTP 404 — Not Found
1. **`USER_NOT_FOUND`**
   - **Exact Message:** `"User with ID '{user_id}' was not found."`
   - **File:** `services/user_service.py:100`

#### HTTP 409 — Conflict
1. **`EMAIL_ALREADY_EXISTS`**
   - **Exact Message:** `"A user with email '{email}' already exists."`
   - **Trigger:** Registration or profile update with an email address already registered.
   - **File:** `services/user_service.py:52, 118`

---

### 3.7 Roles & Privileges (`services/role_service.py`)

#### HTTP 400 — Bad Request
1. **`INVALID_PRIVILEGE_ID`**
   - **Exact Message:** `"Privilege ID(s) {missing_ids} do not exist."`
   - **File:** `services/role_service.py:51, 106`

2. **`ROLE_ALREADY_RETIRED`**
   - **Exact Message:** `"Role with ID '{role_id}' is already retired."`
   - **File:** `services/role_service.py:127`

#### HTTP 404 — Not Found
1. **`ROLE_NOT_FOUND`**
   - **Exact Message:** `"Role with ID '{role_id}' was not found."`
   - **File:** `services/role_service.py:72`

#### HTTP 409 — Conflict
1. **`ROLE_NAME_ALREADY_EXISTS`**
   - **Exact Message:** `"A role with name '{dto.name}' already exists."`
   - **File:** `services/role_service.py:36, 91`

---

### 3.8 Subscriptions, Pricing & Razorpay Payments (`services/subscription_service.py` & `services/payment_service.py`)

#### HTTP 400 — Bad Request
1. **`INVALID_TIER`**
   - **Exact Messages:**
     - `"Invalid target tier '{dto.tier}'. Must be 'pro' or 'ultra'."` (`services/subscription_service.py:55, 143`)
     - `"Invalid tier '{tier}'. Must be one of {list(catalog.keys())}."` (`services/payment_service.py:68`)
   - **Trigger:** Subscription request specifies an uncataloged tier string.

2. **`INVALID_COUPON`**
   - **Exact Message:** Dynamic message returned from coupon validator (e.g., `"Coupon code 'SAVE20' is invalid or expired."`, `"Coupon not applicable to selected billing cycle."`).
   - **File:** `services/subscription_service.py:62, 151`

3. **`PAYMENT_VERIFICATION_FAILED`**
   - **Exact Message:** `"Razorpay payment verification failed: Invalid cryptographic signature."`
   - **Trigger:** Razorpay HMAC-SHA256 signature verification failed for `razorpay_order_id + '|' + razorpay_payment_id`.
   - **File:** `services/subscription_service.py:170`

4. **`PAYMENT_FAILED`**
   - **Exact Message:** Dynamic gateway error message returned during capture or checkout.
   - **File:** `services/subscription_service.py:195`

5. **`GATEWAY_ERROR`**
   - **Exact Message:** `"Razorpay order creation failed: {err_msg}"`
   - **Trigger:** Razorpay API responded with a 4xx/5xx status during order creation.
   - **File:** `services/payment_service.py:225`

6. **`GATEWAY_TIMEOUT`**
   - **Exact Message:** `"Could not connect to Razorpay payment gateway: {str(exc)}"`
   - **Trigger:** Network connection timeout or failure reaching `api.razorpay.com`.
   - **File:** `services/payment_service.py:231`

7. **`INVALID_SUBSCRIPTION_TIER`**
   - **Exact Message:** `"Invalid tier '{dto.tier}'. Must be one of {list(TIER_ROLE_NAME_MAP.keys())}."`
   - **File:** `services/subscription_service.py:299`

8. **`CANNOT_CANCEL_FREE`**
   - **Exact Message:** `"User is already on the Free tier."`
   - **File:** `services/subscription_service.py:345`

---

### 3.9 System Settings (`services/setting_service.py`)

#### HTTP 404 — Not Found
1. **`SETTING_NOT_FOUND`**
   - **Exact Message:** `"System setting with code '{code_clean}' not found."`
   - **File:** `services/setting_service.py:141`

---

### 3.10 Uncaught & Internal Server Exceptions (`app/main.py`)

#### HTTP 500 — Internal Server Error
1. **`INTERNAL_SERVER_ERROR`**
   - **Exact Message:** `"Something went wrong. Please try again or contact support."`
   - **Trigger:** Any uncaught runtime exception caught by the global `@app.exception_handler(Exception)`.
   - **Server Logging:** The full stack trace and exception message are logged via `logger.error(..., exc_info=True)` for engineering diagnostics, while shielding internal details from the client.
   - **File:** `app/main.py:118`

---

## 4. Request Validation Errors (HTTP 422 — `VALIDATION_ERROR`)

FastAPI intercepts request body, path, and query parameter parsing issues through `RequestValidationError`. The global exception handler formats them into `APIError(http_status=422, error_code="VALIDATION_ERROR", errors=[...])`.

### 4.1 Custom Pydantic Model Validators (`models/user_schemas.py`)

| Field | Error Message String | Trigger Condition |
| :--- | :--- | :--- |
| `mobile` | `"Invalid international phone number format. Please check the country code."` | Failed `phonenumbers.is_valid_number()` check. |
| `mobile` | `"Invalid phone number length (must be between 7 and 15 digits)."` | Digit count is fewer than 7 or greater than 15 digits. |
| `mobile` | `"Could not parse phone number. Please include a valid country dial code (e.g. +1...)."` | Non-parseable phone string missing leading dial code. |
| `confirm_password` | `"new_password and confirm_password do not match."` | Password confirmation mismatch on `UserPasswordChangeRequest`. |

### 4.2 Standard Built-in Pydantic Validation Constraints

| Field Target | Example Error Message | Trigger Condition |
| :--- | :--- | :--- |
| `email` | `"value is not a valid email address: The email address is not valid."` | Malformed email string. |
| `password` | `"String should have at least 8 characters"` | `min_length=8` violated on registration or password change. |
| `first_name` / `last_name` | `"String should have at least 1 characters"` | Empty string passed to required field. |
| `rating` | `"Input should be greater than or equal to 1"` / `"Input should be less than or equal to 5"` | Star rating out of `1..5` range. |
| `quote` | `"String should have at least 5 characters"` | Testimonial quote under 5 characters. |

---

## 5. WebSocket Real-time Errors (`/ws/learn/{session_id}`)

Real-time learning and agent orchestration over WebSockets communicate errors via structured JSON frames with `"event_type": "error"`.

### 5.1 WebSocket Error Frame Schema

```json
{
  "event_type": "error",
  "message": "Authentication token missing. Please pass ?token=YOUR_JWT_TOKEN or set access_token cookie."
}
```

### 5.2 Exact WebSocket Error Messages

| Step / Action | Exact Message String | WebSocket Action Taken |
| :--- | :--- | :--- |
| **Handshake Auth** | `"Authentication token missing. Please pass ?token=YOUR_JWT_TOKEN or set access_token cookie."` | Closes socket |
| **Token Decode** | `"Invalid token."` | Closes socket |
| **User Verification** | `"User not found or retired."` | Closes socket |
| **Privilege Check** | `"Access denied. You do not have permission to perform this action."` | Closes socket |
| **Session Lookup** | `"Session '{session_id}' not found. Create one first via POST /api/learn."` | Closes socket |
| **Session Ownership** | `"You do not own this session."` | Closes socket |
| **Invalid Action** | `"Unknown action: '{action}'. Use 'start_step', 'next_step', or 'chat'."` | Keeps socket alive |
| **Malformed JSON** | `"Invalid JSON. Send: {\"action\": \"start_step\", \"step_index\": 0}"` | Keeps socket alive |
| **Step Out of Bounds** | `"Step {step_index} does not exist."` | Keeps socket alive |

---

## 6. Client-Side Errors & Validation (`devzees-edutechai-client`)

### 6.1 Authentication & Form-Level Inline Validation (`auth_form_card.dart`)

Field-level validation rules run interactively on the client. When validation fails, the input field is highlighted with a red outline (`errorBorder: BorderSide(color: AppColors.rose, width: 1.6)`), and the red error text appears directly underneath the input field.

| Form | Input Field | Trigger Condition | Exact Error Message Displayed |
| :--- | :--- | :--- | :--- |
| **Sign In** | Email Address | Field left blank / empty | `"Email address is required"` |
| **Sign In** | Email Address | Does not match RFC email regex | `"Please enter a valid email address"` |
| **Sign In** | Password | Field left blank / empty | `"Password is required"` |
| **Sign Up** | First Name | Field left blank / empty | `"First name is required"` |
| **Sign Up** | Last Name | Field left blank / empty | `"Last name is required"` |
| **Sign Up** | Email Address | Field left blank / empty | `"Email address is required"` |
| **Sign Up** | Email Address | Does not match RFC email regex | `"Please enter a valid email address"` |
| **Sign Up** | Password | Field left blank / empty | `"Password is required"` |
| **Sign Up** | Password | Length is strictly less than 8 characters | `"Password must be at least 8 characters"` |
| **Sign Up** | Mobile Number | Field left blank / empty | `"Mobile number is required"` |
| **Sign Up** | Mobile Number | Cleaned digits count is less than 7 | `"Enter a valid mobile number"` |

---

### 6.2 Client Service Network & Runtime Exceptions

When network failures or backend errors occur, services trap `DioException` and extract the server's `errors[0]` message or throw custom fallback exceptions.

#### 1. General Network Connectivity (`auth_service.dart`, `user_service.dart`, `api_client.dart`)
- **Offline / Server Unreachable:**
  `"Unable to connect to the server. Please check your internet connection and try again."`
- **Session Revoked / Refresh Expired:**
  `"Session expired. Please log in again."` (Triggers `ApiClient.onSessionExpired` -> `forceLogout()`)

#### 2. Export Service Client Exceptions (`export_service.dart`)
- **Compilation Timeout (Status 504 / Connection Timeout):**
  `"{format} generation timed out while compiling. Please try again."`
- **Incomplete Journey (HTTP 400 + `SESSION_INCOMPLETE`):**
  `"Export is only available when the learning journey is 100% completed. All steps must be finished first."`
- **Generic 400 Bad Request:**
  `"Journey incomplete: please complete all milestones to export."`
- **Privilege Forbidden (HTTP 403):**
  - PDF: `"PDF Study Guide export requires an active Ultra subscription."`
  - HTML: `"Interactive HTML report requires an active Pro or Ultra subscription."`
  - Markdown: `"Markdown export requires an active Pro or Ultra subscription."`
- **Session Not Found (HTTP 404):**
  `"Session not found or unavailable."`
- **Generic Catch-all:**
  `"Failed to generate {format}: {message}"`

#### 3. Client Service Default Fallback Messages (`_parseError`)

| Service File | Default Message (Used if server body is missing/malformed) |
| :--- | :--- |
| `auth_service.dart` | `"Login failed"`<br>`"Registration failed"` |
| `user_service.dart` | `"Failed to update profile"`<br>`"Failed to change password"` |
| `learning_service.dart` | `"Failed to fetch learning sessions: {e}"`<br>`"Failed to fetch learning session details: {e}"`<br>`"Failed to delete learning session: {e}"`<br>`"Failed to send follow-up question: {e}"`<br>`"Failed to start journey: {e}"`<br>`"Failed to submit quiz: {e}"`<br>`"Failed to complete step: {e}"`<br>`"Failed to regenerate step: {e}"` |
| `subscription_service.dart`| `"Failed to create payment order."`<br>`"Failed to validate coupon."`<br>`"Payment verification failed."`<br>`"Failed to load transaction history."`<br>`"Failed to cancel subscription."` |
| `admin_service.dart` | `"Failed to fetch admin metrics"`<br>`"Failed to fetch users"`<br>`"Failed to fetch user"`<br>`"Failed to assign roles"`<br>`"Failed to fetch roles"`<br>`"Failed to create role"`<br>`"Failed to edit role"`<br>`"Failed to fetch privileges"`<br>`"Failed to update subscription"`<br>`"Failed to fetch system settings"`<br>`"Failed to update system setting"` |
| `feedback_service.dart` | `"Failed to submit feedback"`<br>`"Failed to fetch public testimonials"`<br>`"Failed to fetch admin feedback"`<br>`"Failed to update feedback status"` |

---

## 7. Presentation Layer Error Handling (UI Feedback)

EduTechAI employs a distinct two-tier error display policy to maximize user clarity:

```
┌────────────────────────────────────────────────────────┐
│                   User Error Event                     │
└──────────────────────────┬─────────────────────────────┘
                           │
             Is it a field-level form validation?
             (e.g., blank input, short password)
                           │
             ┌─────────────┴─────────────┐
            YES                          NO
             │                           │
  ┌───────────────────────┐   ┌───────────────────────────┐
  │ Inline Field Border   │   │ CenterToast Notification   │
  │ • Red border outline  │   │ • Bottom-center docking   │
  │ • Red error text below│   │ • Glassmorphic styling    │
  │ • Retains user focus  │   │ • Auto-elevates for OS KB │
  └───────────────────────┘   │ • Swipable dismissal      │
                              └───────────────────────────┘
```

1. **Inline Field Highlight (`auth_form_card.dart`):**
   - Applies to user inputs (Email, Password, First/Last Name, Phone).
   - Validates live upon user interaction (`AutovalidateMode.onUserInteraction`).
   - Keeps the user focused directly on the offending field.

2. **Luxury Glassmorphic Center-Bottom Toast (`center_toast.dart`):**
   - Reserved for server responses, authentication failures, network issues, and permission alerts.
   - Positioned at `Alignment.bottomCenter` with dynamic elevation above mobile on-screen keyboards (`bottom: keyboardHeight + 16.0px`).
   - Displays colored badge tags (`ERROR`, `WARNING`, `SUCCESS`, `INFO`), an animated countdown timer line, and swipe-to-dismiss gesture support.

