import 'package:flutter/material.dart';
import 'text_styles.dart';
import 'theme_palette.dart';

class AppTheme {
  /// The Light Theme specification for EduTech AI.
  static ThemeData get lightTheme {
    final colors = AppThemeColors.light;

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.scaffoldBackground,
      canvasColor: colors.scaffoldBackground,
      cardColor: colors.surface,
      dividerColor: colors.border,
      primaryColor: colors.accentBlue,
      extensions: [colors],
      colorScheme: ColorScheme.light(
        primary: colors.accentBlue,
        secondary: colors.accentMagenta,
        tertiary: colors.accentViolet,
        surface: colors.surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: colors.textPrimary,
        outline: colors.border,
      ),
      fontFamily: AppTextStyles.fontFamily,
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.dragged) ||
              states.contains(WidgetState.hovered)) {
            return const Color(0xFF94A3B8).withValues(alpha: 0.90);
          }
          return const Color(0xFFCBD5E1).withValues(alpha: 0.75);
        }),
        trackColor: WidgetStateProperty.all(
          colors.surfaceSubtle.withValues(alpha: 0.50),
        ),
        trackBorderColor: WidgetStateProperty.all(Colors.transparent),
        radius: const Radius.circular(6),
        thickness: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.dragged)) {
            return 6.0;
          }
          return 5.0;
        }),
        crossAxisMargin: 2.0,
        mainAxisMargin: 4.0,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1.copyWith(color: colors.textPrimary),
        displayMedium: AppTextStyles.h2.copyWith(color: colors.textPrimary),
        displaySmall: AppTextStyles.h3.copyWith(color: colors.textPrimary),
        headlineMedium: AppTextStyles.h4.copyWith(color: colors.textPrimary),
        titleLarge: AppTextStyles.subtitle1.copyWith(color: colors.textPrimary),
        titleMedium: AppTextStyles.subtitle2.copyWith(color: colors.textPrimary),
        bodyLarge: AppTextStyles.body1.copyWith(color: colors.textSecondary),
        bodyMedium: AppTextStyles.body2.copyWith(color: colors.textSecondary),
        labelLarge: AppTextStyles.button.copyWith(color: colors.textPrimary),
        labelMedium: AppTextStyles.label.copyWith(color: colors.textPrimary),
        labelSmall: AppTextStyles.labelSmall,
        bodySmall: AppTextStyles.caption.copyWith(color: colors.textSecondary),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.border),
          boxShadow: colors.cardShadow,
        ),
        textStyle: AppTextStyles.caption.copyWith(
          color: colors.textPrimary,
          height: 1.35,
          letterSpacing: 0.2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        waitDuration: const Duration(milliseconds: 300),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.accentBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: AppTextStyles.button,
          elevation: 0,
        ),
      ),
      iconTheme: IconThemeData(
        color: colors.textPrimary,
        size: 20,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.border),
        ),
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceSubtle,
        hintStyle: AppTextStyles.body2.copyWith(color: colors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.accentBlue, width: 1.5),
        ),
      ),
    );
  }

  /// The Dark Theme specification for EduTech AI.
  static ThemeData get darkTheme {
    final colors = AppThemeColors.dark;

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.scaffoldBackground,
      canvasColor: colors.scaffoldBackground,
      cardColor: colors.surface,
      dividerColor: colors.border,
      primaryColor: colors.accentBlue,
      extensions: [colors],
      colorScheme: ColorScheme.dark(
        primary: colors.accentBlue,
        secondary: colors.accentMagenta,
        tertiary: colors.accentViolet,
        surface: colors.surface,
        onPrimary: colors.textPrimary,
        onSecondary: colors.textPrimary,
        onSurface: colors.textPrimary,
        outline: colors.border,
      ),
      fontFamily: AppTextStyles.fontFamily,
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.dragged) ||
              states.contains(WidgetState.hovered)) {
            return const Color(0xFF475569).withValues(alpha: 0.90);
          }
          return const Color(0xFF334155).withValues(alpha: 0.65);
        }),
        trackColor: WidgetStateProperty.all(
          colors.surface.withValues(alpha: 0.40),
        ),
        trackBorderColor: WidgetStateProperty.all(Colors.transparent),
        radius: const Radius.circular(6),
        thickness: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.dragged)) {
            return 6.0;
          }
          return 5.0;
        }),
        crossAxisMargin: 2.0,
        mainAxisMargin: 4.0,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1.copyWith(color: colors.textPrimary),
        displayMedium: AppTextStyles.h2.copyWith(color: colors.textPrimary),
        displaySmall: AppTextStyles.h3.copyWith(color: colors.textPrimary),
        headlineMedium: AppTextStyles.h4.copyWith(color: colors.textPrimary),
        titleLarge: AppTextStyles.subtitle1.copyWith(color: colors.textPrimary),
        titleMedium: AppTextStyles.subtitle2.copyWith(color: colors.textPrimary),
        bodyLarge: AppTextStyles.body1.copyWith(color: colors.textSecondary),
        bodyMedium: AppTextStyles.body2.copyWith(color: colors.textSecondary),
        labelLarge: AppTextStyles.button.copyWith(color: colors.textPrimary),
        labelMedium: AppTextStyles.label.copyWith(color: colors.textPrimary),
        labelSmall: AppTextStyles.labelSmall,
        bodySmall: AppTextStyles.caption.copyWith(color: colors.textSecondary),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        textStyle: AppTextStyles.caption.copyWith(
          color: colors.textPrimary,
          height: 1.35,
          letterSpacing: 0.2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        waitDuration: const Duration(milliseconds: 300),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.accentBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: AppTextStyles.button,
          elevation: 0,
        ),
      ),
      iconTheme: IconThemeData(
        color: colors.textPrimary,
        size: 20,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.border),
        ),
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceSubtle,
        hintStyle: AppTextStyles.body2.copyWith(color: colors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.accentBlue, width: 1.5),
        ),
      ),
    );
  }
}
