import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_palette.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool isGlowing;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24.0,
    this.padding = const EdgeInsets.all(24.0),
    this.onTap,
    this.isGlowing = false,
    this.width,
    this.height,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    final border = isDark
        ? Border.all(
            color: AppColors.purple.withValues(alpha: _isHovered ? 0.85 : 0.45),
            width: 1.5,
          )
        : Border.all(
            color: _isHovered
                ? AppColors.accentBlue.withValues(alpha: 0.60)
                : AppColors.glassBorder,
            width: 1.0,
          );

    final shadows = isDark
        ? [
            // Dark Mode Drop Shadow
            BoxShadow(
              color: AppColors.purple.withValues(alpha: _isHovered ? 0.55 : 0.35),
              blurRadius: _isHovered ? 75 : 65,
              spreadRadius: _isHovered ? -10 : -15,
              offset: Offset(0, _isHovered ? 30 : 25),
            ),
            // Dark Mode Inner / Neumorphic shadow (rgba(0,0,0,0.45))
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.45 : 0.30),
              blurRadius: _isHovered ? 45 : 35,
              spreadRadius: 0,
              blurStyle: BlurStyle.inner,
            ),
          ]
        : [
            // Light Mode Drop Shadow: box-shadow: 0 8px 24px rgba(0,0,0,0.08)
            BoxShadow(
              color: const Color(0x14000000), // 0.08 opacity
              blurRadius: _isHovered ? 28 : 24,
              spreadRadius: 0,
              offset: Offset(0, _isHovered ? 12 : 8),
            ),
            if (_isHovered)
              BoxShadow(
                color: AppColors.accentBlue.withValues(alpha: 0.12),
                blurRadius: 18,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
          ];

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: widget.width,
          height: widget.height,
          transform: Matrix4.translationValues(0, _isHovered ? -2.0 : 0, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: border,
            boxShadow: shadows,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Stack(
                children: [
                  // Background Gradient
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.cardGradientOpaque,
                      ),
                    ),
                  ),
                  // Top Glowing Accent Line
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.8,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.accentBlue,
                                AppColors.accentMagenta,
                                AppColors.accentBlue,
                                Colors.transparent,
                              ],
                              stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentMagenta.withValues(
                                  alpha: isDark ? (_isHovered ? 0.8 : 0.5) : (_isHovered ? 0.5 : 0.3),
                                ),
                                blurRadius: _isHovered ? 22 : 15,
                              ),
                              BoxShadow(
                                color: AppColors.accentBlue.withValues(
                                  alpha: isDark ? (_isHovered ? 0.7 : 0.4) : (_isHovered ? 0.4 : 0.2),
                                ),
                                blurRadius: _isHovered ? 30 : 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Container(
                    width: double.infinity,
                    padding: widget.padding,
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
