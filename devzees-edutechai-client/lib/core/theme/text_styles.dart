import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';

class AppTextStyles {
  // We no longer strictly need the fontFamily string, but we can keep it if needed.
  static final String? fontFamily = GoogleFonts.inter().fontFamily;

  static final TextStyle h1 = GoogleFonts.inter(
    fontSize: 56, // ~3.6rem
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static final TextStyle h2 = GoogleFonts.inter(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static final TextStyle h3 = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static final TextStyle h4 = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static final TextStyle body1 = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
  );

  static final TextStyle body2 = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static final TextStyle button = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );
}
