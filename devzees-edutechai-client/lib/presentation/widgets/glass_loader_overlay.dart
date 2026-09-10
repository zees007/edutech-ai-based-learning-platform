import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';

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
                    child: _buildGlassLoaderBox(),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGlassLoaderBox() {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.purple.withValues(alpha: 0.45),
          width: 1.5,
        ),
        gradient: AppColors.cardGradientOpaque,
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.3),
            blurRadius: 40,
            spreadRadius: -10,
          ),
          BoxShadow(
            color: AppColors.accentPink.withValues(alpha: 0.2),
            blurRadius: 30,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Spinning loader with glowing gradient ring
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Inner icon
                const CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.purple),
                ),
                Icon(
                  Icons.auto_awesome,
                  color: AppColors.lavender.withValues(alpha: 0.8),
                  size: 24,
                ),
              ],
            ),
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
              color: AppColors.lavender.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
