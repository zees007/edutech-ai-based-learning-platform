import 'package:flutter/material.dart';

class AppColors {
  // ─── Base Backgrounds & Surfaces ───
  static const Color background = Color(0xFF0E0918); // Deep midnight navy
  static const Color secondaryBackground = Color(0xFF1B1728);
  static const Color surfaceDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceMid = Color(0xFF1E293B); // Slate 800
  static const Color surfaceDeep = Color(0xFF1A112E); // Deep purple-navy
  static const Color surfaceSolidHeader = Color(0xCC140D21); // Solid header matching toolbar
  static const Color sidebarBackground = Color(0xFF130D21);
  static const Color canvasBackground = Color(0xFF0B0813);
  static const Color popoverBackground = Color(0xFF1A132C);
  static const Color surfaceIndigo = Color(0xFF1E1B4B);

  // ─── Core Brand & Accents ───
  static const Color primary = Color(0xFF8B5CF6); // Violet
  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xB3FFFFFF); // 70% white
  static const Color textMuted = Color(0xFF9CA3AF); // Gray 400
  static const Color textSubtle = Color(0xFF94A3B8); // Slate 400
  static const Color textSlate = Color(0xFFE2E8F0); // Slate 200

  // ─── Glassmorphism & Borders ───
  static const Color glassBase = Color(0x08FFFFFF); // ~3% white
  static const Color glassHover = Color(0x0DFFFFFF); // ~5% white
  static const Color glassBorder = Color(0x14FFFFFF); // ~8% white
  static const Color cardGlowBorder = Color(0x73A855F7); // 45% purple border
  static const Color cardGlowBorderHover = Color(0xD9A855F7); // 85% purple border

  // ─── Glowing Palette & Accents ───
  static const Color purple = Color(0xFFA855F7); // Purple 500 (glows, borders, rings)
  static const Color accentPurple = Color(0xFFA855F7); // Alias for purple
  static const Color purpleLight = Color(0xFFC084FC); // Purple 400
  static const Color purpleDeep = Color(0xFF7C3AED); // Violet 600
  static const Color lavender = Color(0xFFE9D5FF); // Purple 100
  static const Color fuchsia = Color(0xFFE879F9); // Fuchsia 400
  static const Color accentPink = Color(0xFFEC4899); // Pink 500
  static const Color accentBlue = Color(0xFF3B82F6); // Blue 500
  static const Color accentCyan = Color(0xFF06B6D4); // Cyan 500
  static const Color accentGreen = Color(0xFF10B981); // Emerald 500
  static const Color emerald = Color(0xFF10B981); // Emerald 500
  static const Color accentAmber = Color(0xFFF59E0B); // Amber 500
  static const Color glassSurface = Color(0x08FFFFFF); // Glass container surface
  static const Color glassBorderSubtle = Color(0x0DFFFFFF); // ~5% white subtle border
  static const Color slate200 = Color(0xFFE2E8F0); // Slate 200
  static const Color slate400 = Color(0xFF94A3B8); // Slate 400
  static const Color accentRose = Color(0xFFF43F5E); // Alias for rose

  // ─── Extended Feature & Badge Colors ───
  static const Color rose = Color(0xFFF43F5E); // Rose 500 (quiz accent)
  static const Color roseLight = Color(0xFFFDA4AF); // Rose 300
  static const Color blueLight = Color(0xFF60A5FA); // Blue 400 (academic papers)
  static const Color blueSoft = Color(0xFF93C5FD); // Blue 300
  static const Color blueRoyal = Color(0xFF2563EB); // Blue 600
  static const Color indigo = Color(0xFF6366F1); // Indigo 500
  static const Color cyanLight = Color(0xFF22D3EE); // Cyan 400
  static const Color greenMint = Color(0xFF34D399); // Mint Emerald 400
  static const Color greenDeep = Color(0xFF059669); // Emerald 600
  static const Color greenDark = Color(0xFF047857); // Emerald 700
  static const Color greenSoft = Color(0xFFD1FAE5); // Emerald 100
  static const Color greenSage = Color(0xFFA7F3D0); // Emerald 200
  static const Color amberDeep = Color(0xFFD97706); // Amber 600

  // ─── Slates ───
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);

  // ─── Shimmer & Skeleton Tokens ───
  static const Color shimmerBase = Color(0xFF1E1633);
  static const Color shimmerHighlight = Color(0xFF38275C);
  static const Color shimmerBox = Color(0xFF261D3D);
  static const Color shimmerBoxDark = Color(0xFF2E2248);
  static const Color shimmerBoxMid = Color(0xFF281D40);
  static const Color shimmerBoxLight = Color(0xFF332750);

  // ─── Centralized Gradients ───
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFFEC4899),
      Color(0xFFA855F7),
      Color(0xFF3B82F6),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [
      Color(0xFF0F172A),
      Color(0xFF1A112E),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradientOpaque = LinearGradient(
    colors: [
      Color(0xF00F172A), // ~94% slate
      Color(0xE61A112E), // ~90% purple-navy
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient commandHubGradient = LinearGradient(
    colors: [
      Color(0xB31E293B), // rgba(30, 41, 59, 0.7)
      Color(0xCC0F172A), // rgba(15, 23, 42, 0.8)
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient socraticTutorGradient = LinearGradient(
    colors: [
      Color(0xBF1E293B), // rgba(30, 41, 59, 0.75)
      Color(0xD90F172A), // rgba(15, 23, 42, 0.85)
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkPurpleGradient = LinearGradient(
    colors: [
      Color(0xFFEC4899),
      Color(0xFFA855F7),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkPurpleCyanGradient = LinearGradient(
    colors: [
      Color(0xFFEC4899),
      Color(0xFFA855F7),
      Color(0xFF06B6D4),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient royalBlueIndigoGradient = LinearGradient(
    colors: [
      Color(0xFF2563EB),
      Color(0xFF6366F1),
      Color(0xFF7C3AED),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [
      Color(0xFF059669),
      Color(0xFF10B981),
      Color(0xFF34D399),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: [
      Color(0xFFF59E0B),
      Color(0xFFD97706),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const RadialGradient workspaceBackgroundRadial = RadialGradient(
    center: Alignment(0.0, -0.3),
    radius: 1.2,
    colors: [
      Color(0xFF1A112E),
      Color(0xFF110C1D),
      Color(0xFF0E0918),
    ],
    stops: [0.0, 0.5, 1.0],
  );
}
