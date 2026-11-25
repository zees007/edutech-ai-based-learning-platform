import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/theme_palette.dart';
import '../../core/constants/responsive.dart';
import 'app_gradient_spinner.dart';

class GlassLoaderOverlay extends StatelessWidget {
  final bool isLoading;
  final String title;
  final String subtitle;
  final Widget child;

  const GlassLoaderOverlay({
    super.key,
    required this.isLoading,
    this.title = 'Authenticating',
    this.subtitle = 'Please wait...',
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: AppColors.surfaceDark.withValues(alpha: 0.6),
                  child: Center(
                    child: _buildGlassLoaderBox(context),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGlassLoaderBox(BuildContext context) {
    final isDark = context.isDarkMode;
    final colors = context.appColors;
    return Container(
      width: 320,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (isDark ? AppColors.primary : AppColors.purple).withValues(alpha: 0.45),
          width: 1.5,
        ),
        color: Responsive.isMobile(context)
            ? colors.surface
            : null,
        gradient: Responsive.isMobile(context)
            ? null
            : (isDark
                ? const LinearGradient(
                    colors: [Color(0xF511121D), Color(0xEE0E0F18)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFAFFFFFF), Color(0xF5F9F9FB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )),
        boxShadow: [
          if (!Responsive.isMobile(context)) ...[
            BoxShadow(
              color: (isDark ? AppColors.primary : AppColors.purple).withValues(alpha: 0.3),
              blurRadius: 40,
              spreadRadius: -10,
            ),
            BoxShadow(
              color: (isDark ? AppColors.primary.withValues(alpha: 0.2) : AppColors.accentPink.withValues(alpha: 0.2)),
              blurRadius: 30,
              spreadRadius: -5,
            ),
          ]
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Spinning loader with glowing gradient ring
          const AppGradientSpinner(
            size: 64,
            strokeWidth: 4.0,
            showSparkle: true,
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            title,
            style: AppTextStyles.h4.copyWith(
              letterSpacing: 0.5,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Subtitle
          Text(
            subtitle,
            style: AppTextStyles.body2.copyWith(
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
