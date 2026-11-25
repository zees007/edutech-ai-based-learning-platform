import 'package:flutter/material.dart';

/// Shared normalization and icon mapping helpers for learning modes and education levels.
class LearningMetadataUtils {
  LearningMetadataUtils._();

  static const Map<String, IconData> _modeIcons = {
    'VISUAL': Icons.smart_display_rounded,
    'DEEP DIVE': Icons.biotech_rounded,
    'BITE-SIZED': Icons.bolt_rounded,
  };

  static const Map<String, IconData> _levelIcons = {
    'MIDDLE SCHOOL': Icons.apartment_rounded,
    'HIGH SCHOOL': Icons.backpack_rounded,
    'UNDERGRADUATE': Icons.account_balance_rounded,
    'GRADUATE': Icons.school_rounded,
    'GENERAL CURIOUS': Icons.lightbulb_rounded,
  };

  /// Strips surrounding underscores, emojis, and punctuation, returning an uppercase label.
  static String formatBadgeLabel(String raw) {
    final stripped = raw
        .replaceAll(RegExp(r'^_+|_+$'), '')
        .replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true), '')
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .trim();
    final spaced = stripped.replaceAll('_', ' ').trim();
    if (spaced.isEmpty) return raw.toUpperCase();
    return spaced.toUpperCase();
  }

  /// Returns the Material icon assigned to [rawMode].
  static IconData getModeIcon(String rawMode) {
    final normalized = formatBadgeLabel(rawMode);
    return _modeIcons[normalized] ?? Icons.psychology_rounded;
  }

  /// Returns the Material icon assigned to [rawLevel].
  static IconData getLevelIcon(String rawLevel) {
    final normalized = formatBadgeLabel(rawLevel);
    return _levelIcons[normalized] ?? Icons.school_rounded;
  }
}
