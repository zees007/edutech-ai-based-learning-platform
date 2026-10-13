import 'package:flutter/material.dart';

/// Onboarding-specific color constants.
/// Uses the deep dark palette from the reference designs, aligned with
/// the app's existing dark theme tokens where possible.
class OnboardingColors {
  OnboardingColors._();

  // ─── Backgrounds ───
  static const Color scaffoldBg = Color(0xFF060814);
  static const Color surfaceGlow = Color(0xBF111830); // rgba(17, 24, 48, 0.75)

  // ─── Feature Card Glass ───
  static const Color glassCardBg = Color(0xAD12162C); // rgba(18, 22, 44, 0.68)
  static const Color glassCardBorder = Color(0x388B5CF6); // rgba(139, 92, 246, 0.22)
  static const Color glassCardInnerGlow = Color(0x14FFFFFF); // rgba(255, 255, 255, 0.08)

  // ─── Brand Accents ───
  static const Color vividPurple = Color(0xFF9D4EDD);
  static const Color purpleLight = Color(0xFFC084FC);
  static const Color indigo = Color(0xFF6366F1);

  // ─── Gradient Colors ───
  static const Color gradientCyan = Color(0xFF38BDF8);
  static const Color gradientCyanAlt = Color(0xFF00D2FF);
  static const Color gradientIndigo = Color(0xFF818CF8);
  static const Color gradientPurple = Color(0xFFA855F7);
  static const Color gradientViolet = Color(0xFF8B5CF6);

  // ─── Text Colors ───
  static const Color textPrimary = Colors.white;
  static const Color textSubtle = Color(0xCC94A3B8); // slate-300/80
  static const Color textMuted = Color(0xFF94A3B8); // slate-400

  // ─── Dot Indicator ───
  static const Color dotInactive = Color(0xCC334155); // slate-700/80

  // ─── Button ───
  static const Color buttonShadowPurple = Color(0x8C8B5CF6); // rgba(139, 92, 246, 0.55)
  static const Color buttonShadowCyan = Color(0x6638BDF8); // rgba(56, 189, 248, 0.4)

  // ─── Gradients ───
  static const LinearGradient textGradient = LinearGradient(
    colors: [gradientCyan, gradientIndigo, purpleLight],
  );

  static const LinearGradient textGradientCyanPurple = LinearGradient(
    colors: [gradientCyanAlt, Color(0xFF7065F0), gradientPurple],
  );

  static const LinearGradient actionButtonGradient = LinearGradient(
    begin: Alignment(-0.7, -0.7),
    end: Alignment(0.7, 0.7),
    colors: [gradientCyan, gradientViolet, gradientPurple],
  );

  static const LinearGradient getStartedButtonGradient = LinearGradient(
    colors: [vividPurple, Color(0xFF3B82F6), gradientCyanAlt],
  );

  static const LinearGradient activeDotGradient = LinearGradient(
    colors: [Color(0xFFA855F7), indigo],
  );

  // ─── Icon Container ───
  static const Color iconContainerBg = Color(0xE61E1B4B); // #1e1b4b/90
  static const Color iconContainerBorder = Color(0x66A855F7); // purple-500/40
}
