import 'package:flutter/material.dart';

/// Defines the unified semantic color tokens for EduTech AI.
/// Implemented as a [ThemeExtension] for clean Flutter [ThemeData] integration,
/// with full support for [ThemeExtension.lerp] transitions.
@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  // ─── Theme Specific Canvas & Surfaces ───
  final Color scaffoldBackground;
  final Color surface;
  final Color surfaceSubtle;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color trackNeutral;

  // ─── Semantic Surface Elevations (Mobile & Core) ───
  final Color sidebarBackground;
  final Color topBarBackground;
  final Color cardBackground;
  final Color chipBackground;

  // ─── Elevation & Shadows ───
  final List<BoxShadow> cardShadow;
  final Color shadowColor;

  // ─── Shared Brand Accents & Gradients ───
  final LinearGradient primaryGradient;
  final Color accentBlue;
  final Color accentViolet;
  final Color accentMagenta;
  final Color accentGreen;
  final Color accentAmber;
  final Color accentRose;

  const AppThemeColors({
    required this.scaffoldBackground,
    required this.surface,
    required this.surfaceSubtle,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.trackNeutral,
    required this.sidebarBackground,
    required this.topBarBackground,
    required this.cardBackground,
    required this.chipBackground,
    required this.cardShadow,
    required this.shadowColor,
    required this.primaryGradient,
    required this.accentBlue,
    required this.accentViolet,
    required this.accentMagenta,
    required this.accentGreen,
    required this.accentAmber,
    required this.accentRose,
  });

  // ─── Shared Primary Gradient (135deg, #1F6CFA 0%, #C839F6 100%) ───
  static const LinearGradient sharedPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1F6CFA), // Vibrant Royal Blue
      Color(0xFFC839F6), // Electric Fuchsia / Magenta
    ],
  );

  // ─── Light Theme Palette ───
  static const AppThemeColors light = AppThemeColors(
    scaffoldBackground: Color(0xFFECE8E8),
    surface: Color(0xFFFFFFFF),
    surfaceSubtle: Color(0xFFF3F3F5),
    border: Color(0xFFE5E7EB),
    textPrimary: Color(0xFF2B2D42),
    textSecondary: Color(0xFF8E92A4),
    trackNeutral: Color(0xFFD9DBE9),
    sidebarBackground: Color(0xFFFFFFFF),
    topBarBackground: Color(0xFFFFFFFF),
    cardBackground: Color(0xFFF8FAFC),
    chipBackground: Color(0xFFF1F5F9),
    shadowColor: Color(0x14000000), // rgba(0, 0, 0, 0.08)
    cardShadow: [
      BoxShadow(
        color: Color(0x14000000), // 0.08 opacity
        blurRadius: 24,
        spreadRadius: 0,
        offset: Offset(0, 8),
      ),
      BoxShadow(
        color: Color(0x0A000000), // 0.04 subtle ground
        blurRadius: 6,
        spreadRadius: 0,
        offset: Offset(0, 2),
      ),
    ],
    primaryGradient: sharedPrimaryGradient,
    accentBlue: Color(0xFF2B68F6),
    accentViolet: Color(0xFF6B47EB),
    accentMagenta: Color(0xFFB838EE),
    accentGreen: Color(0xFF10B981),
    accentAmber: Color(0xFFF59E0B),
    accentRose: Color(0xFFF43F5E),
  );

  // ─── Dark Theme Palette ───
  static const AppThemeColors dark = AppThemeColors(
    scaffoldBackground: Color(0xFF0B0C13), // Unified Deep Canvas Base #0B0C13
    surface: Color(0xFF11121D),            // Desktop Panel Surface #11121d
    surfaceSubtle: Color(0xFF11121D),      // Unified with surface #11121d
    border: Color(0x0DFFFFFF),             // Feathered Hairline Border rgba(255, 255, 255, 0.045)
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF94A3B8),      // Slate 400
    trackNeutral: Color(0xFF1A1B2D),
    sidebarBackground: Color(0xFF0B0C13), // Unified Sidebar Base #0B0C13
    topBarBackground: Color(0xFF0B0C13),  // Unified Mobile Top Bar Base #0B0C13
    cardBackground: Color(0xFF11121D),    // Unified Elevated Card Surface #11121D
    chipBackground: Color(0xFF151726),    // Step-up Interactive Chip Surface #151726
    shadowColor: Color(0x73000000),        // rgba(0, 0, 0, 0.45)
    cardShadow: [
      BoxShadow(
        color: Color(0x40000000), // 0.25 opacity
        blurRadius: 20,
        spreadRadius: 0,
        offset: Offset(0, 8),
      ),
      BoxShadow(
        color: Color(0x261F6CFA), // 0.15 subtle blue/violet ambient glow
        blurRadius: 15,
        spreadRadius: -2,
        offset: Offset(0, 2),
      ),
    ],
    primaryGradient: sharedPrimaryGradient,
    accentBlue: Color(0xFF2B68F6),
    accentViolet: Color(0xFF6B47EB),
    accentMagenta: Color(0xFFB838EE),
    accentGreen: Color(0xFF10B981),
    accentAmber: Color(0xFFF59E0B),
    accentRose: Color(0xFFF43F5E),
  );

  @override
  AppThemeColors copyWith({
    Color? scaffoldBackground,
    Color? surface,
    Color? surfaceSubtle,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? trackNeutral,
    Color? sidebarBackground,
    Color? topBarBackground,
    Color? cardBackground,
    Color? chipBackground,
    List<BoxShadow>? cardShadow,
    Color? shadowColor,
    LinearGradient? primaryGradient,
    Color? accentBlue,
    Color? accentViolet,
    Color? accentMagenta,
    Color? accentGreen,
    Color? accentAmber,
    Color? accentRose,
  }) {
    return AppThemeColors(
      scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
      surface: surface ?? this.surface,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      trackNeutral: trackNeutral ?? this.trackNeutral,
      sidebarBackground: sidebarBackground ?? this.sidebarBackground,
      topBarBackground: topBarBackground ?? this.topBarBackground,
      cardBackground: cardBackground ?? this.cardBackground,
      chipBackground: chipBackground ?? this.chipBackground,
      cardShadow: cardShadow ?? this.cardShadow,
      shadowColor: shadowColor ?? this.shadowColor,
      primaryGradient: primaryGradient ?? this.primaryGradient,
      accentBlue: accentBlue ?? this.accentBlue,
      accentViolet: accentViolet ?? this.accentViolet,
      accentMagenta: accentMagenta ?? this.accentMagenta,
      accentGreen: accentGreen ?? this.accentGreen,
      accentAmber: accentAmber ?? this.accentAmber,
      accentRose: accentRose ?? this.accentRose,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) {
      return this;
    }
    return AppThemeColors(
      scaffoldBackground:
          Color.lerp(scaffoldBackground, other.scaffoldBackground, t) ??
          scaffoldBackground,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceSubtle:
          Color.lerp(surfaceSubtle, other.surfaceSubtle, t) ?? surfaceSubtle,
      border: Color.lerp(border, other.border, t) ?? border,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      trackNeutral:
          Color.lerp(trackNeutral, other.trackNeutral, t) ?? trackNeutral,
      sidebarBackground:
          Color.lerp(sidebarBackground, other.sidebarBackground, t) ??
          sidebarBackground,
      topBarBackground:
          Color.lerp(topBarBackground, other.topBarBackground, t) ??
          topBarBackground,
      cardBackground:
          Color.lerp(cardBackground, other.cardBackground, t) ??
          cardBackground,
      chipBackground:
          Color.lerp(chipBackground, other.chipBackground, t) ??
          chipBackground,
      cardShadow: t < 0.5 ? cardShadow : other.cardShadow,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t) ?? shadowColor,
      primaryGradient: LinearGradient.lerp(
            primaryGradient,
            other.primaryGradient,
            t,
          ) ??
          primaryGradient,
      accentBlue: Color.lerp(accentBlue, other.accentBlue, t) ?? accentBlue,
      accentViolet:
          Color.lerp(accentViolet, other.accentViolet, t) ?? accentViolet,
      accentMagenta:
          Color.lerp(accentMagenta, other.accentMagenta, t) ?? accentMagenta,
      accentGreen: Color.lerp(accentGreen, other.accentGreen, t) ?? accentGreen,
      accentAmber: Color.lerp(accentAmber, other.accentAmber, t) ?? accentAmber,
      accentRose: Color.lerp(accentRose, other.accentRose, t) ?? accentRose,
    );
  }
}

/// Convenience extension on [BuildContext] to access semantic colors with reactive updates.
extension ThemeContextExtension on BuildContext {
  AppThemeColors get appColors =>
      Theme.of(this).extension<AppThemeColors>() ??
      (Theme.of(this).brightness == Brightness.light
          ? AppThemeColors.light
          : AppThemeColors.dark);

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
