import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

const String _themePrefKey = 'edutech_theme_mode';

/// Riverpod notifier managing active [ThemeMode] with local storage persistence.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Default to dark theme as base
    _loadPersistedTheme();
    return ThemeMode.dark;
  }

  Future<void> _loadPersistedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themePrefKey);
      if (savedTheme != null) {
        switch (savedTheme) {
          case 'light':
            setThemeMode(ThemeMode.light);
            break;
          case 'dark':
            setThemeMode(ThemeMode.dark);
            break;
          case 'system':
            setThemeMode(ThemeMode.system);
            break;
        }
      }
    } catch (_) {
      // Graceful fallback to memory state
    }
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
    }
  }

  Future<void> _persistTheme(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
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
