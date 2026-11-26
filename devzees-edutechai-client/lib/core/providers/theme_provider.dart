import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import 'onboarding_provider.dart';

const String _themePrefKey = 'edutech_theme_mode';

/// Riverpod notifier managing active [ThemeMode] with synchronous initial load
/// from [sharedPreferencesProvider] so cold boots / refreshes never flash.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final initialMode = _readPersistedThemeSync();
    _syncAppColors(initialMode);
    return initialMode;
  }

  ThemeMode _readPersistedThemeSync() {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final savedTheme = prefs.getString(_themePrefKey);
      switch (savedTheme) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        case 'system':
          return ThemeMode.system;
      }
    } catch (_) {
      // Fallback when sharedPreferencesProvider is not overridden (e.g. isolated widget tests)
    }
    return ThemeMode.dark;
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    _syncAppColors(mode);
    _persistTheme(mode);
  }

  void toggleTheme() {
    final nextMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setThemeMode(nextMode);
  }

  void _syncAppColors(ThemeMode mode) {
    if (mode == ThemeMode.light) {
      AppColors.setBrightness(Brightness.light);
    } else if (mode == ThemeMode.dark) {
      AppColors.setBrightness(Brightness.dark);
    } else {
      final platformBrightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      AppColors.setBrightness(platformBrightness);
    }
  }

  Future<void> _persistTheme(ThemeMode mode) async {
    try {
      SharedPreferences prefs;
      try {
        prefs = ref.read(sharedPreferencesProvider);
      } catch (_) {
        prefs = await SharedPreferences.getInstance();
      }
      final modeStr = mode == ThemeMode.light
          ? 'light'
          : mode == ThemeMode.dark
              ? 'dark'
              : 'system';
      await prefs.setString(_themePrefKey, modeStr);
    } catch (_) {
      // Storage unavailable fallback
    }
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});
