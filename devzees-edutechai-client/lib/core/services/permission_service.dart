// EduTechAI — Privilege Code Constants & Permission Checker
//
// Single source of truth for all privilege codes used in the Flutter client.
// Replaces raw `privilegeCodes.contains('ET_...')` calls across the codebase
// with a strongly-typed, testable, super-admin-aware permission layer.
//
// Usage:
//   final perms = ref.watch(permissionProvider);
//   if (perms.canExportPdf) { /* show PDF button */ }
//   if (perms.has(PrivilegeCodes.etAccessDeepDiveMode)) { /* unlock deep dive */ }

import '../constants/app_config.dart';

// ─── Privilege Code Constants ───────────────────────────────────────
/// All EduTechAI privilege codes as compile-time constants.
/// Matches the codes seeded in `02_seed_privileges_and_roles.py`.
abstract class PrivilegeCodes {
  // Root
  static const etAll = 'ET_ALL';

  // Admin & System
  static const etFullAccessAdmin = 'ET_FULL_ACCESS_ADMIN';
  static const etViewAnalytics = 'ET_VIEW_ANALYTICS';
  static const etManageSystemSettings = 'ET_MANAGE_SYSTEM_SETTINGS';

  // User Management
  static const etFullAccessUser = 'ET_FULL_ACCESS_USER';
  static const etCreateUser = 'ET_CREATE_USER';
  static const etViewUser = 'ET_VIEW_USER';
  static const etEditUser = 'ET_EDIT_USER';
  static const etRetireUser = 'ET_RETIRE_USER';
  static const etAssignUserRole = 'ET_ASSIGN_USER_ROLE';

  // Role & Privilege
  static const etFullAccessRole = 'ET_FULL_ACCESS_ROLE';
  static const etCreateRole = 'ET_CREATE_ROLE';
  static const etViewRole = 'ET_VIEW_ROLE';
  static const etEditRole = 'ET_EDIT_ROLE';
  static const etRetireRole = 'ET_RETIRE_ROLE';
  static const etViewPrivilege = 'ET_VIEW_PRIVILEGE';

  // Subscription
  static const etFullAccessSubscription = 'ET_FULL_ACCESS_SUBSCRIPTION';
  static const etViewSubscription = 'ET_VIEW_SUBSCRIPTION';
  static const etUpgradeSubscription = 'ET_UPGRADE_SUBSCRIPTION';
  static const etDowngradeSubscription = 'ET_DOWNGRADE_SUBSCRIPTION';
  static const etManageBilling = 'ET_MANAGE_BILLING';

  // Learning
  static const etFullAccessLearning = 'ET_FULL_ACCESS_LEARNING';
  static const etStartLearningSession = 'ET_START_LEARNING_SESSION';
  static const etInteractLearningSession = 'ET_INTERACT_LEARNING_SESSION';
  static const etViewLearningHistory = 'ET_VIEW_LEARNING_HISTORY';
  static const etManageKnowledgeBase = 'ET_MANAGE_KNOWLEDGE_BASE';
  static const etAccessVisualMode = 'ET_ACCESS_VISUAL_MODE';
  static const etAccessDeepDiveMode = 'ET_ACCESS_DEEP_DIVE_MODE';
  static const etRegenerateStep = 'ET_REGENERATE_STEP';
  static const etAccessAcademicSearch = 'ET_ACCESS_ACADEMIC_SEARCH';
  static const etAccessFullTextResearch = 'ET_ACCESS_FULL_TEXT_RESEARCH';
  static const etUnlimitedFollowUps = 'ET_UNLIMITED_FOLLOW_UPS';

  // Video
  static const etFullAccessVideo = 'ET_FULL_ACCESS_VIDEO';
  static const etAccessYoutubeBasic = 'ET_ACCESS_YOUTUBE_BASIC';
  static const etAccessYoutubeAdvanced = 'ET_ACCESS_YOUTUBE_ADVANCED';

  // Export
  static const etFullAccessExport = 'ET_FULL_ACCESS_EXPORT';
  static const etExportMarkdown = 'ET_EXPORT_MARKDOWN';
  static const etExportHtml = 'ET_EXPORT_HTML';
  static const etExportPdf = 'ET_EXPORT_PDF';

  // Quiz
  static const etFullAccessQuiz = 'ET_FULL_ACCESS_QUIZ';
  static const etGenerateQuiz = 'ET_GENERATE_QUIZ';
  static const etSubmitQuiz = 'ET_SUBMIT_QUIZ';
}

// ─── Permission Checker ─────────────────────────────────────────────
/// Immutable checker built from the user's `privilegeCodes` list.
///
/// Every check automatically cascades through `ET_ALL` (super-admin bypass),
/// so widgets never need to manually check for super-admin status.
class PermissionChecker {
  final Set<String> _codes;

  PermissionChecker(List<String> privilegeCodes)
      : _codes = Set<String>.from(privilegeCodes);

  /// Returns `true` if the user has the given privilege code, or is a super-admin.
  bool has(String code) => _codes.contains(PrivilegeCodes.etAll) || _codes.contains(code);

  // ─── Admin ─────────────────────────────────────────────────────
  bool get isSuperAdmin => _codes.contains(PrivilegeCodes.etAll);
  bool get isAdmin => has(PrivilegeCodes.etFullAccessAdmin);

  // ─── Learning Modes ────────────────────────────────────────────
  bool get canAccessVisualMode => has(PrivilegeCodes.etAccessVisualMode);
  bool get canAccessDeepDiveMode => has(PrivilegeCodes.etAccessDeepDiveMode);

  // ─── Learning Features ─────────────────────────────────────────
  bool get canRegenerateStep => has(PrivilegeCodes.etRegenerateStep);
  bool get canAccessAcademicSearch => has(PrivilegeCodes.etAccessAcademicSearch);
  bool get canAccessFullTextResearch => has(PrivilegeCodes.etAccessFullTextResearch);
  bool get canUnlimitedFollowUps => has(PrivilegeCodes.etUnlimitedFollowUps);

  // ─── Export ────────────────────────────────────────────────────
  bool get canExportMarkdown => has(PrivilegeCodes.etExportMarkdown);
  bool get canExportHtml => has(PrivilegeCodes.etExportHtml);
  bool get canExportPdf => has(PrivilegeCodes.etExportPdf);

  // ─── Subscription ──────────────────────────────────────────────
  bool get canViewSubscription => has(PrivilegeCodes.etViewSubscription);
  bool get canUpgradeSubscription => has(PrivilegeCodes.etUpgradeSubscription);
  bool get canDowngradeSubscription => has(PrivilegeCodes.etDowngradeSubscription);

  // ─── Follow-Up Limit ───────────────────────────────────────────
  /// Returns the maximum follow-up questions allowed per step for this user.
  /// Ultra users (with `ET_UNLIMITED_FOLLOW_UPS`) get `null` (no limit).
  /// Pro users (with `ET_ACCESS_DEEP_DIVE_MODE`) get the Pro limit.
  /// Free users get the Free limit.
  /// Values are sourced from [AppConfig] (configurable via `--dart-define`).
  int? get followUpLimitPerStep {
    if (canUnlimitedFollowUps) return null; // Unlimited
    if (canAccessDeepDiveMode) return AppConfig.proFollowUpLimit;
    return AppConfig.freeFollowUpLimit;
  }

  /// Whether the user has reached their follow-up limit for a given step.
  bool isFollowUpLimitReached(int currentFollowUpCount) {
    final limit = followUpLimitPerStep;
    if (limit == null) return false; // Unlimited
    return currentFollowUpCount >= limit;
  }
}
