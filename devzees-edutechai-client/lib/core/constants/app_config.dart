/// EduTechAI — App Configuration
///
/// Centralised, environment-aware configuration constants.
/// Values that vary between dev / staging / production or between
/// tier-based feature limits belong here — NOT hard-coded in widgets.
///
/// Override at build time with `--dart-define`:
///   flutter run --dart-define=FREE_FOLLOW_UP_LIMIT=2
///   flutter build web --dart-define=PRO_FOLLOW_UP_LIMIT=10
class AppConfig {
  AppConfig._();

  // ─── Follow-Up Limits (per step) ─────────────────────────────────
  /// Maximum follow-up questions a **Free** user can ask per learning step.
  static const int freeFollowUpLimit = int.fromEnvironment(
    'FREE_FOLLOW_UP_LIMIT',
    defaultValue: 1,
  );

  /// Maximum follow-up questions a **Pro** user can ask per learning step.
  static const int proFollowUpLimit = int.fromEnvironment(
    'PRO_FOLLOW_UP_LIMIT',
    defaultValue: 5,
  );

  // ─── Monthly Session Quota ───────────────────────────────────────
  /// Maximum learning sessions a **Free** user can start per calendar month.
  static const int freeMonthlySessionLimit = int.fromEnvironment(
    'FREE_MONTHLY_SESSION_LIMIT',
    defaultValue: 10,
  );
}
