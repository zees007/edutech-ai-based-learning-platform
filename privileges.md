# EduTechAI Privileges & Roles Reference

This document maps all privileges across the system, explains their functionality, and details exactly what each role (Free, Pro, Ultra, Admin) has access to.

## Role Definitions

- **Free**: Base tier. Access to standard learning sessions (10/month), Bite-Sized & Visual modes, 1 YouTube video per step, 1 follow-up question per step, academic paper summaries, and full quizzes & gamification.
- **Pro**: Intermediate tier. Unlocks Deep Dive learning mode, step regeneration, up to 3 YouTube videos per step, 5 follow-up questions, and Markdown/HTML note exports.
- **Ultra**: Premium tier. Unlocks unlimited follow-up questions, up to 5 YouTube videos, full-text academic research, and premium PDF note exports.
- **Admin**: Internal users and system administrators. Has unrestricted access to the entire system via the `ET_ALL` bypass.

---

## 1. Root & System Module

| Code | Name & Explanation | Free | Pro | Ultra | Admin |
| :--- | :--- | :---: | :---: | :---: | :---: |
| `ET_ALL` | **Super Admin Bypass**. Grants unrestricted access to all endpoints. | - | - | - | ✅ |
| `ET_FULL_ACCESS_ADMIN` | **Admin & System Management**. Parent node for system configurations. | - | - | - | ✅ |
| `ET_VIEW_ANALYTICS` | **View Analytics**. Access to global system metrics and revenue dashboards. | - | - | - | ✅ |
| `ET_MANAGE_SYSTEM_SETTINGS` | **Manage System Settings**. Ability to configure global API keys, LLMs, and rate limits. | - | - | - | ✅ |

## 2. User Module

| Code | Name & Explanation | Free | Pro | Ultra | Admin |
| :--- | :--- | :---: | :---: | :---: | :---: |
| `ET_FULL_ACCESS_USER` | **User Management**. Parent node for all user operations. | - | - | - | ✅ |
| `ET_CREATE_USER` | **Create User**. Ability to manually provision user accounts. | - | - | - | ✅ |
| `ET_VIEW_USER` | **View & Search User**. View user profiles and search across the user directory. | - | - | - | ✅ |
| `ET_EDIT_USER` | **Edit User**. Modify user profile details and password. | - | - | - | ✅ |
| `ET_RETIRE_USER` | **Retire User**. Soft-delete user accounts from the platform. | - | - | - | ✅ |
| `ET_ASSIGN_USER_ROLE` | **Assign Role to User**. Change a user's assigned RBAC roles. | - | - | - | ✅ |

## 3. Role & Privilege Module

| Code | Name & Explanation | Free | Pro | Ultra | Admin |
| :--- | :--- | :---: | :---: | :---: | :---: |
| `ET_FULL_ACCESS_ROLE` | **Role Management**. Parent node for role administration. | - | - | - | ✅ |
| `ET_CREATE_ROLE` | **Create Role**. Create custom RBAC roles. | - | - | - | ✅ |
| `ET_VIEW_ROLE` | **View & Search Role**. View and search existing roles. | - | - | - | ✅ |
| `ET_EDIT_ROLE` | **Edit Role**. Modify role names and assignments. | - | - | - | ✅ |
| `ET_RETIRE_ROLE` | **Retire Role**. Soft-delete a role. | - | - | - | ✅ |
| `ET_VIEW_PRIVILEGE` | **View Privileges**. View the system privilege tree. | - | - | - | ✅ |

## 4. Subscription Module

| Code | Name & Explanation | Free | Pro | Ultra | Admin |
| :--- | :--- | :---: | :---: | :---: | :---: |
| `ET_FULL_ACCESS_SUBSCRIPTION` | **Subscription Management**. Parent node for subscriptions. | - | - | - | ✅ |
| `ET_VIEW_SUBSCRIPTION` | **View Subscription**. View own active subscription tier. | ✅ | ✅ | ✅ | ✅ |
| `ET_UPGRADE_SUBSCRIPTION` | **Upgrade Subscription**. Process a tier upgrade checkout. | ✅ | ✅ | ✅ | ✅ |
| `ET_DOWNGRADE_SUBSCRIPTION` | **Downgrade Subscription**. Process a tier downgrade. | - | ✅ | ✅ | ✅ |
| `ET_MANAGE_BILLING` | **Manage Global Billing**. View system-wide transactions and process refunds. | - | - | - | ✅ |

## 5. Learning Module

| Code | Name & Explanation | Free | Pro | Ultra | Admin |
| :--- | :--- | :---: | :---: | :---: | :---: |
| `ET_FULL_ACCESS_LEARNING` | **Learning Management**. Parent node for AI sessions. | - | - | - | ✅ |
| `ET_START_LEARNING_SESSION` | **Start Learning Session**. Initiate a new topic session. | ✅ | ✅ | ✅ | ✅ |
| `ET_INTERACT_LEARNING_SESSION` | **Interact Learning Session**. Stream agent responses and chat. | ✅ | ✅ | ✅ | ✅ |
| `ET_VIEW_LEARNING_HISTORY` | **View Learning History**. Access past saved sessions. | ✅ | ✅ | ✅ | ✅ |
| `ET_ACCESS_VISUAL_MODE` | **Visual Learning Mode**. Unlock the Visual 🎬 mode with rich media-first explanations. | ✅ | ✅ | ✅ | ✅ |
| `ET_ACCESS_DEEP_DIVE_MODE` | **Deep Dive Learning Mode**. Unlock the Deep Dive 🔬 mode with rigorous, research-level depth. | - | ✅ | ✅ | ✅ |
| `ET_REGENERATE_STEP` | **Regenerate Step**. Re-generate a step's Socratic explanation, questions, and quiz with a fresh perspective. | - | ✅ | ✅ | ✅ |
| `ET_ACCESS_ACADEMIC_SEARCH` | **Academic Search**. Search OpenAlex, ArXiv, and Semantic Scholar for curated paper summaries. | ✅ | ✅ | ✅ | ✅ |
| `ET_ACCESS_FULL_TEXT_RESEARCH` | **Full Text Research**. Extract and read full PDF text from academic papers. | - | - | ✅ | ✅ |
| `ET_UNLIMITED_FOLLOW_UPS` | **Unlimited Follow Ups**. Bypass the chat message cap. | - | - | ✅ | ✅ |
| `ET_MANAGE_KNOWLEDGE_BASE` | **Manage Knowledge Base**. Manually curate vector DB documents. | - | - | - | ✅ |


## 5.1 Video Module

| Code | Name & Explanation | Free | Pro | Ultra | Admin |
| :--- | :--- | :---: | :---: | :---: | :---: |
| `ET_FULL_ACCESS_VIDEO` | **Video Management**. Parent node for video integrations. | - | - | - | ✅ |
| `ET_ACCESS_YOUTUBE_BASIC` | **Basic YouTube Search**. 1 curated video clip per learning step. | ✅ | ✅ | ✅ | ✅ |
| `ET_ACCESS_YOUTUBE_ADVANCED` | **Advanced YouTube Search**. Up to 5 curated video clips per step (3 for Pro, 5 for Ultra). | - | ✅ | ✅ | ✅ |

## 5.2 Export Module

| Code | Name & Explanation | Free | Pro | Ultra | Admin |
| :--- | :--- | :---: | :---: | :---: | :---: |
| `ET_FULL_ACCESS_EXPORT` | **Export Management**. Parent node for document exports. | - | - | - | ✅ |
| `ET_EXPORT_MARKDOWN` | **Export to Markdown**. Download notes. | - | ✅ | ✅ | ✅ |
| `ET_EXPORT_HTML` | **Export to HTML**. Download notes. | - | ✅ | ✅ | ✅ |
| `ET_EXPORT_PDF` | **Export to PDF**. Download styled PDF notes. | - | - | ✅ | ✅ |

## 6. Quiz Module

| Code | Name & Explanation | Free | Pro | Ultra | Admin |
| :--- | :--- | :---: | :---: | :---: | :---: |
| `ET_FULL_ACCESS_QUIZ` | **Quiz Management**. Parent node for quizzes. | - | - | - | ✅ |
| `ET_GENERATE_QUIZ` | **Generate Quiz**. Have AI create tests based on current session context. | ✅ | ✅ | ✅ | ✅ |
| `ET_SUBMIT_QUIZ` | **Submit Quiz**. Grade and track quiz XP. | ✅ | ✅ | ✅ | ✅ |
