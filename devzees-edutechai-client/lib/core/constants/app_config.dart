/// EduTechAI — App Configuration
///
/// Centralised, environment-aware configuration constants.
/// Values that vary between dev / staging / production or between
/// tier-based feature limits belong here — NOT hard-coded in widgets.
///
/// Override at build time with `--dart-define`:
///   flutter run --dart-define=DEFAULT_FOLLOW_UP_LIMIT=2
///   flutter build web --dart-define=DEFAULT_MONTHLY_SESSION_LIMIT=15
class AppConfig {
  AppConfig._();

  // ─── Follow-Up Limits (per step) ─────────────────────────────────
  /// Conservative fallback follow-up limit used ONLY when the backend
  /// quota API hasn't responded yet. Once the backend quota loads,
  /// the dynamic value from SubscriptionTier takes precedence.
  static const int freeFollowUpLimit = int.fromEnvironment(
    'DEFAULT_FOLLOW_UP_LIMIT',
    defaultValue: 1,
  );

  /// @deprecated No longer used — follow-up limits are resolved dynamically
  /// from the backend quota. Kept for backward compatibility with
  /// `--dart-define=PRO_FOLLOW_UP_LIMIT=N` build overrides.
  static const int proFollowUpLimit = int.fromEnvironment(
    'PRO_FOLLOW_UP_LIMIT',
    defaultValue: 5,
  );

  // ─── Monthly Session Quota ───────────────────────────────────────
  /// Conservative fallback session limit used ONLY when the backend
  /// quota API hasn't responded yet.
  static const int freeMonthlySessionLimit = int.fromEnvironment(
    'DEFAULT_MONTHLY_SESSION_LIMIT',
    defaultValue: 10,
  );
}
