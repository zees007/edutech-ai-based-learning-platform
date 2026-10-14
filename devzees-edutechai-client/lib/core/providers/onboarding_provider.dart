import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Overridden in main.dart ProviderScope with the pre-initialized SharedPreferences instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main() ProviderScope');
});

/// Manages whether the user has completed (or skipped) the onboarding flow.
/// Persists the flag via SharedPreferences so onboarding only shows once.
class OnboardingNotifier extends Notifier<bool> {
  static const _key = 'hasSeenOnboarding';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_key) ?? false;
  }

  /// Marks onboarding as completed and persists the flag.
  /// Called when the user taps "Get Started", "Skip", or "I already have an account".
  Future<void> completeOnboarding() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_key, true);
    state = true;
  }

  /// Resets onboarding state (useful for testing/debugging).
  Future<void> resetOnboarding() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_key);
    state = false;
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, bool>(() => OnboardingNotifier());
