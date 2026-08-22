"""
EduTechAI — System Privileges Configuration & Endpoint Reference

Defines privilege constants for all 24 system privileges across modules:
- Root SuperAdmin
- User Module
- Role Module
- Subscription Module
- Learning Module
- Quiz Module
"""

from __future__ import annotations

# ─── 1. ROOT SUPERADMIN PRIVILEGE ──────────────────────────────
ET_ALL = "ET_ALL"

# ─── 2. USER MODULE PRIVILEGES ──────────────────────────────────
ET_FULL_ACCESS_USER = "ET_FULL_ACCESS_USER"
ET_CREATE_USER = "ET_CREATE_USER"
ET_VIEW_USER = "ET_VIEW_USER"
ET_EDIT_USER = "ET_EDIT_USER"
ET_RETIRE_USER = "ET_RETIRE_USER"
ET_SEARCH_USER = "ET_SEARCH_USER"
ET_ASSIGN_USER_ROLE = "ET_ASSIGN_USER_ROLE"

# ─── 3. ROLE & PRIVILEGE MODULE PRIVILEGES ──────────────────────
ET_FULL_ACCESS_ROLE = "ET_FULL_ACCESS_ROLE"
ET_CREATE_ROLE = "ET_CREATE_ROLE"
ET_VIEW_ROLE = "ET_VIEW_ROLE"
ET_EDIT_ROLE = "ET_EDIT_ROLE"
ET_RETIRE_ROLE = "ET_RETIRE_ROLE"
ET_SEARCH_ROLE = "ET_SEARCH_ROLE"
ET_VIEW_PRIVILEGE = "ET_VIEW_PRIVILEGE"

# ─── 4. SUBSCRIPTION MODULE PRIVILEGES ──────────────────────────
ET_FULL_ACCESS_SUBSCRIPTION = "ET_FULL_ACCESS_SUBSCRIPTION"
ET_VIEW_SUBSCRIPTION = "ET_VIEW_SUBSCRIPTION"
ET_UPGRADE_SUBSCRIPTION = "ET_UPGRADE_SUBSCRIPTION"
ET_DOWNGRADE_SUBSCRIPTION = "ET_DOWNGRADE_SUBSCRIPTION"

# ─── 5. LEARNING MODULE PRIVILEGES ──────────────────────────────
ET_FULL_ACCESS_LEARNING = "ET_FULL_ACCESS_LEARNING"
ET_START_LEARNING_SESSION = "ET_START_LEARNING_SESSION"
ET_INTERACT_LEARNING_SESSION = "ET_INTERACT_LEARNING_SESSION"
ET_VIEW_LEARNING_HISTORY = "ET_VIEW_LEARNING_HISTORY"

# Feature Restrictions
ET_ACCESS_ADVANCED_MODES = "ET_ACCESS_ADVANCED_MODES"
ET_ACCESS_YOUTUBE_BASIC = "ET_ACCESS_YOUTUBE_BASIC"
ET_ACCESS_YOUTUBE_ADVANCED = "ET_ACCESS_YOUTUBE_ADVANCED"
ET_ACCESS_ACADEMIC_SEARCH = "ET_ACCESS_ACADEMIC_SEARCH"
ET_ACCESS_FULL_TEXT_RESEARCH = "ET_ACCESS_FULL_TEXT_RESEARCH"
ET_REGENERATE_STEP = "ET_REGENERATE_STEP"
ET_UNLIMITED_FOLLOW_UPS = "ET_UNLIMITED_FOLLOW_UPS"
ET_EXPORT_MARKDOWN = "ET_EXPORT_MARKDOWN"
ET_EXPORT_PDF = "ET_EXPORT_PDF"

# ─── 6. QUIZ MODULE PRIVILEGES ──────────────────────────────────
ET_FULL_ACCESS_QUIZ = "ET_FULL_ACCESS_QUIZ"
ET_GENERATE_QUIZ = "ET_GENERATE_QUIZ"
ET_SUBMIT_QUIZ = "ET_SUBMIT_QUIZ"

# ─── ALL 33 PRIVILEGES LIST ─────────────────────────────────────
ALL_PRIVILEGE_CODES = [
    ET_ALL,
    # User Module
    ET_FULL_ACCESS_USER,
    ET_CREATE_USER,
    ET_VIEW_USER,
    ET_EDIT_USER,
    ET_RETIRE_USER,
    ET_SEARCH_USER,
    ET_ASSIGN_USER_ROLE,
    # Role Module
    ET_FULL_ACCESS_ROLE,
    ET_CREATE_ROLE,
    ET_VIEW_ROLE,
    ET_EDIT_ROLE,
    ET_RETIRE_ROLE,
    ET_SEARCH_ROLE,
    ET_VIEW_PRIVILEGE,
    # Subscription Module
    ET_FULL_ACCESS_SUBSCRIPTION,
    ET_VIEW_SUBSCRIPTION,
    ET_UPGRADE_SUBSCRIPTION,
    ET_DOWNGRADE_SUBSCRIPTION,
    # Learning Module
    ET_FULL_ACCESS_LEARNING,
    ET_START_LEARNING_SESSION,
    ET_INTERACT_LEARNING_SESSION,
    ET_VIEW_LEARNING_HISTORY,
    ET_ACCESS_ADVANCED_MODES,
    ET_ACCESS_YOUTUBE_BASIC,
    ET_ACCESS_YOUTUBE_ADVANCED,
    ET_ACCESS_ACADEMIC_SEARCH,
    ET_ACCESS_FULL_TEXT_RESEARCH,
    ET_REGENERATE_STEP,
    ET_UNLIMITED_FOLLOW_UPS,
    ET_EXPORT_MARKDOWN,
    ET_EXPORT_PDF,
    # Quiz Module
    ET_FULL_ACCESS_QUIZ,
    ET_GENERATE_QUIZ,
    ET_SUBMIT_QUIZ,
]

# ─── ENDPOINT REFERENCE MAP ──────────────────────────────────────
ENDPOINT_PRIVILEGE_MAP = {
    # Auth Endpoints
    "POST /api/v1/auth/login": None,  # Public
    "POST /api/v1/auth/logout": None,  # Authenticated
    "GET /api/v1/auth/me": None,  # Authenticated
    # User Endpoints
    "POST /api/v1/users/create": None,  # Public (Registration)
    "GET /api/v1/users/search": ET_SEARCH_USER,
    "GET /api/v1/users/{user_id}": ET_VIEW_USER,
    "PUT /api/v1/users/{user_id}/edit": ET_EDIT_USER,
    "PATCH /api/v1/users/{user_id}/change-password": ET_EDIT_USER,
    "DELETE /api/v1/users/{user_id}/retire": ET_RETIRE_USER,
    "PUT /api/v1/users/{user_id}/roles": ET_ASSIGN_USER_ROLE,
    "GET /api/v1/users/{user_id}/roles": ET_VIEW_USER,
    # Privilege & Role Endpoints
    "GET /api/v1/privileges/tree": ET_VIEW_PRIVILEGE,
    "GET /api/v1/privileges": ET_VIEW_PRIVILEGE,
    "POST /api/v1/roles/create": ET_CREATE_ROLE,
    "GET /api/v1/roles/search": ET_SEARCH_ROLE,
    "GET /api/v1/roles/{role_id}": ET_VIEW_ROLE,
    "PUT /api/v1/roles/{role_id}/edit": ET_EDIT_ROLE,
    "DELETE /api/v1/roles/{role_id}/retire": ET_RETIRE_ROLE,
    # Subscription Endpoints
    "GET /api/v1/subscriptions/users/{user_id}": ET_VIEW_SUBSCRIPTION,
    "PUT /api/v1/subscriptions/users/{user_id}/tier": (ET_UPGRADE_SUBSCRIPTION, ET_DOWNGRADE_SUBSCRIPTION),
    # Learning Endpoints
    "POST /api/learn": ET_START_LEARNING_SESSION,
    "GET /api/sessions/{session_id}": ET_INTERACT_LEARNING_SESSION,
    "POST /api/sessions/{session_id}/step/{step_index}/complete": ET_INTERACT_LEARNING_SESSION,
    "POST /api/sessions/{session_id}/mode": ET_INTERACT_LEARNING_SESSION,
    "GET /api/sessions": ET_VIEW_LEARNING_HISTORY,
    # Quiz Endpoints
    "GET /api/quiz/{session_id}/{step_index}": ET_GENERATE_QUIZ,
    "POST /api/quiz/submit": ET_SUBMIT_QUIZ,
}
