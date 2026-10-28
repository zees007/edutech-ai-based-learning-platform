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
    final isGlow = widget.isGlowing || _isHovered;

    final border = isDark
        ? Border.all(
            color: Colors.white.withValues(alpha: isGlow ? 0.22 : 0.09),
            width: 1.0,
          )
        : Border.all(
            color: isGlow
                ? AppColors.accentBlue.withValues(alpha: 0.50)
                : AppColors.glassBorder,
            width: 1.0,
          );

    final shadows = isDark
        ? [
            // Deep Luxury SaaS Drop Shadow
            BoxShadow(
              color: Colors.black.withValues(alpha: isGlow ? 0.65 : 0.45),
              blurRadius: isGlow ? 40 : 26,
              offset: Offset(0, isGlow ? 14 : 8),
            ),
            // Soft atmospheric ambient light
            if (isGlow)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.18),
                blurRadius: 32,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
          ]
        : [
            // Light Mode Drop Shadow
            BoxShadow(
              color: const Color(0x14000000),
              blurRadius: isGlow ? 28 : 20,
              spreadRadius: 0,
              offset: Offset(0, isGlow ? 10 : 6),
            ),
            if (isGlow)
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
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: widget.width,
          height: widget.height,
          transform: Matrix4.translationValues(0, _isHovered ? -3.0 : 0, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: border,
            boxShadow: shadows,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Stack(
                children: [
                  // Background Glass Tint
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xE0090A14)
                            : Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  // Top Specular Light Catcher Line
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.75,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: 1.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withValues(
                                  alpha: isDark
                                      ? (isGlow ? 0.45 : 0.18)
                                      : (isGlow ? 0.35 : 0.12),
                                ),
                                if (isGlow) const Color(0xFF00F5D4).withValues(alpha: 0.4),
                                Colors.transparent,
                              ],
                              stops: isGlow ? const [0.0, 0.4, 0.6, 1.0] : const [0.0, 0.5, 1.0],
                            ),
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
