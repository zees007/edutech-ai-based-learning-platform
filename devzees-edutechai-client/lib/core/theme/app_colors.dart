import 'package:flutter/material.dart';

class AppColors {
  // Base Colors
  static const Color background = Color(0xFF0E0918); // Deep midnight navy
  static const Color secondaryBackground = Color(0xFF1B1728);
  
  static const Color primary = Color(0xFF8B5CF6); // Violet
  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xB3FFFFFF); // 70% white
  
  // Glassmorphism
  static const Color glassBase = Color(0x08FFFFFF); // ~3% white
  static const Color glassHover = Color(0x0DFFFFFF); // ~5% white
  static const Color glassBorder = Color(0x14FFFFFF); // ~8% white
  
  // Accents / Features
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentAmber = Color(0xFFF59E0B);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFFEC4899),
      Color(0xFFA855F7),
      Color(0xFF3B82F6),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
