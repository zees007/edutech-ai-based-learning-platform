import 'package:flutter/material.dart';
import 'theme_palette.dart';

/// Central color registry for EduTech AI.
/// Provides dynamic semantic color resolution based on the active theme,
/// ensuring full backwards compatibility with existing UI components while
/// supporting both Light and Dark theme modes.
class AppColors {
  static AppThemeColors _current = AppThemeColors.dark;

  /// Returns the current active theme palette.
  static AppThemeColors get current => _current;

  /// Returns whether dark mode is currently active.
  static bool get isDark => _current.scaffoldBackground == AppThemeColors.dark.scaffoldBackground;

  /// Updates the active theme palette.
  static void setThemeColors(AppThemeColors colors) {
    _current = colors;
  }

  /// Sets the active theme by brightness.
  static void setBrightness(Brightness brightness) {
    _current = brightness == Brightness.light ? AppThemeColors.light : AppThemeColors.dark;
  }

  // ─── Base Backgrounds & Surfaces (Dynamic) ───
  static Color get background => _current.scaffoldBackground;
  static Color get secondaryBackground => isDark ? const Color(0xFF151624) : _current.surfaceSubtle;
  static Color get surfaceDark => _current.surface;
  static Color get surfaceMid => isDark ? const Color(0xFF141523) : const Color(0xFFF8F9FA);
  static Color get surfaceDeep => isDark ? const Color(0xFF0B0C14) : _current.surface;
  static Color get surfaceSolidHeader => isDark ? const Color(0xCC11121D) : const Color(0xF2FFFFFF);
  static Color get sidebarBackground => isDark ? const Color(0xFF0E0F18) : _current.surface;
  static Color get canvasBackground => _current.scaffoldBackground;
  static Color get popoverBackground => isDark ? const Color(0xFF11121D) : _current.surface;
  static Color get surfaceIndigo => isDark ? const Color(0xFF1A1B2D) : _current.surfaceSubtle;

  static Color get surface => _current.surface;
  static Color get surfaceSubtle => _current.surfaceSubtle;
  static Color get border => _current.border;

  // ─── Core Brand & Accents ───
  static const Color primary = Color(0xFF2B68F6); // Accent Solid Blue
  static const Color primaryViolet = Color(0xFF6B47EB); // Accent Solid Violet
  static const Color primaryPink = Color(0xFFB838EE); // Accent Solid Magenta / Pink

  static Color get textPrimary => _current.textPrimary;
  static Color get textSecondary => _current.textSecondary;
  static Color get textMuted => isDark ? const Color(0xFF8F94A6) : const Color(0xFF8E92A4);
  static Color get textSubtle => isDark ? const Color(0xFF94A3B8) : const Color(0xFF8E92A4);
  static Color get textSlate => isDark ? const Color(0xFFE2E8F0) : const Color(0xFF475569);

  // ─── Neutral Tracks ───
  static Color get trackNeutral => _current.trackNeutral;

  // ─── Glassmorphism & Borders (Dynamic) ───
  static Color get glassBase => isDark ? const Color(0x08FFFFFF) : const Color(0x08000000);
  static Color get glassHover => isDark ? const Color(0x0DFFFFFF) : const Color(0x0D000000);
  static Color get glassBorder => _current.border;
  static Color get cardGlowBorder => isDark ? const Color(0x73A855F7) : _current.border;
  static Color get cardGlowBorderHover => isDark ? const Color(0xD9A855F7) : _current.accentViolet;

  // ─── Static Brand Accent Tokens ───
  static const Color accentBlue = Color(0xFF2B68F6); // Accent Solid Blue
  static const Color accentViolet = Color(0xFF6B47EB); // Accent Solid Violet
  static const Color accentPink = Color(0xFFB838EE); // Accent Solid Magenta / Pink
  static const Color accentMagenta = Color(0xFFB838EE);

  static const Color purple = Color(0xFF6B47EB); // Purple / Violet
  static const Color accentPurple = Color(0xFF6B47EB);
  static const Color purpleLight = Color(0xFFC084FC); // Purple 400
  static const Color purpleDeep = Color(0xFF7C3AED); // Violet 600
  static const Color lavender = Color(0xFFE9D5FF); // Purple 100
  static const Color fuchsia = Color(0xFFE879F9); // Fuchsia 400
  static const Color accentCyan = Color(0xFF06B6D4); // Cyan 500
  static const Color accentGreen = Color(0xFF10B981); // Emerald 500
  static const Color emerald = Color(0xFF10B981); // Emerald 500
  static const Color accentAmber = Color(0xFFF59E0B); // Amber 500
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color accentRose = Color(0xFFF43F5E);
  static const Color rose = Color(0xFFF43F5E);
  static const Color roseLight = Color(0xFFFDA4AF);
  static const Color blueLight = Color(0xFF60A5FA);
  static const Color blueSoft = Color(0xFF93C5FD);
  static const Color blueRoyal = Color(0xFF2563EB);
  static const Color indigo = Color(0xFF6366F1);
  static const Color cyanLight = Color(0xFF22D3EE);
  static const Color greenMint = Color(0xFF34D399);
  static const Color greenDeep = Color(0xFF059669);
  static const Color greenDark = Color(0xFF047857);
  static const Color greenSoft = Color(0xFFD1FAE5);
  static const Color greenSage = Color(0xFFA7F3D0);
  static const Color amberDeep = Color(0xFFD97706);

  // ─── Adaptive Accent Getters (high-contrast in Light Mode) ───
  static Color get adaptiveLavender => isDark ? lavender : primaryViolet;
  static Color get adaptivePurpleLight => isDark ? purpleLight : purpleDeep;
  static Color get adaptiveBlueLight => isDark ? blueLight : blueRoyal;
  static Color get adaptiveBlueSoft => isDark ? blueSoft : const Color(0xFF1D4ED8);
  static Color get adaptiveRoseLight => isDark ? roseLight : const Color(0xFFE11D48);
  static Color get adaptiveCyanLight => isDark ? cyanLight : const Color(0xFF0891B2);

  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);

  static Color get glassSurface => isDark ? const Color(0x08FFFFFF) : const Color(0x08000000);
  static Color get glassBorderSubtle => isDark ? const Color(0x0DFFFFFF) : const Color(0x0F000000);

  // ─── Shimmer & Skeleton Tokens (Dynamic) ───
  static Color get shimmerBase => isDark ? const Color(0xFF11121D) : const Color(0xFFE5E7EB);
  static Color get shimmerHighlight => isDark ? const Color(0xFF151624) : const Color(0xFFF3F3F5);
  static Color get shimmerBox => isDark ? const Color(0xFF1A1B2D) : const Color(0xFFEDE9F2);
  static Color get shimmerBoxDark => isDark ? const Color(0xFF151624) : const Color(0xFFE5E0EE);
  static Color get shimmerBoxMid => isDark ? const Color(0xFF1A1B2D) : const Color(0xFFEAE4F0);
  static Color get shimmerBoxLight => isDark ? const Color(0xFF212338) : const Color(0xFFF0EBF5);

  // ─── Centralized Gradients ───
  // Primary Gradient: 135deg, #1F6CFA 0%, #C839F6 100%
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1F6CFA), // Vibrant Royal Blue
      Color(0xFFC839F6), // Electric Fuchsia / Magenta
    ],
  );

  static LinearGradient get cardGradient => isDark
      ? const LinearGradient(
          colors: [Color(0xFF11121D), Color(0xFF0E0F18)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      : const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFFDFCFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

  static LinearGradient get cardGradientOpaque => isDark
      ? const LinearGradient(
          colors: [Color(0xF511121D), Color(0xEE0E0F18)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      : const LinearGradient(
          colors: [Color(0xFAFFFFFF), Color(0xF5F9F9FB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

  static LinearGradient get commandHubGradient => isDark
      ? const LinearGradient(
          colors: [Color(0xCC11121D), Color(0xE60B0C13)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      : const LinearGradient(
          colors: [Color(0xFAFFFFFF), Color(0xF5F3F3F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

  static LinearGradient get socraticTutorGradient => isDark
      ? const LinearGradient(
          colors: [Color(0xD911121D), Color(0xF20B0C13)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      : const LinearGradient(
          colors: [Color(0xFAFFFFFF), Color(0xF5F3F3F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

  // Solid color equivalents for mobile to prevent color banding
  static Color get mobileCardSolid => _current.surface;
  static Color get mobileCommandHubSolid => isDark ? const Color(0xFF11121D) : const Color(0xFFFFFFFF);
  static Color get mobileSocraticTutorSolid => isDark ? const Color(0xFF0E0F18) : const Color(0xFFFFFFFF);

  static const LinearGradient pinkPurpleGradient = LinearGradient(
    colors: [Color(0xFFC839F6), Color(0xFF6B47EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkPurpleCyanGradient = LinearGradient(
    colors: [Color(0xFFC839F6), Color(0xFF6B47EB), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient royalBlueIndigoGradient = LinearGradient(
    colors: [Color(0xFF1F6CFA), Color(0xFF6B47EB), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static RadialGradient get workspaceBackgroundRadial => isDark
      ? const RadialGradient(
          center: Alignment(0.0, -0.3),
          radius: 1.2,
          colors: [Color(0xFF151624), Color(0xFF0E0F18), Color(0xFF0B0C13)],
          stops: [0.0, 0.5, 1.0],
        )
      : const RadialGradient(
          center: Alignment(0.0, -0.3),
          radius: 1.2,
          colors: [Color(0xFFF8F7F7), Color(0xFFF1EDED), Color(0xFFECE8E8)],
          stops: [0.0, 0.5, 1.0],
        );

  // ─── Mobile Specific Colors ───
  static Color get mobileBackground => _current.scaffoldBackground;
  static Color get mobileSurfaceDeep => isDark ? const Color(0xFF0B0C14) : const Color(0xFFFFFFFF);

  static LinearGradient get mobileWorkspaceBackgroundGradient => isDark
      ? const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF11121D),
            Color(0xFF0E0F18),
            Color(0xFF0B0C13),
          ],
          stops: [0.0, 0.5, 1.0],
        )
      : const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF5F3F3),
            Color(0xFFECE8E8),
          ],
          stops: [0.0, 0.5, 1.0],
        );
}
