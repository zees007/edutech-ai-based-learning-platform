import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool isGlowing;
  final double? width;
  final double? height;

  const GlassCard({
    Key? key,
    required this.child,
    this.borderRadius = 24.0, // Matches Streamlit CSS border-radius
    this.padding = const EdgeInsets.all(24.0),
    this.onTap,
    this.isGlowing = false,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
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
            border: Border.all(
              color: const Color(0xFFA855F7).withValues(alpha: _isHovered ? 0.85 : 0.45),
              width: 1.5,
            ),
            boxShadow: [
              // Outer drop shadow (matches Streamlit CSS 0 25px 65px -15px)
              BoxShadow(
                color: const Color(0xFFA855F7).withValues(alpha: _isHovered ? 0.55 : 0.35),
                blurRadius: _isHovered ? 75 : 65,
                spreadRadius: _isHovered ? -10 : -15,
                offset: Offset(0, _isHovered ? 30 : 25),
              ),
              // Inner shadow (matches Streamlit CSS inset 0 0 35px)
              BoxShadow(
                color: const Color(0xFFA855F7).withValues(alpha: _isHovered ? 0.20 : 0.12),
                blurRadius: _isHovered ? 45 : 35,
                spreadRadius: 0,
                blurStyle: BlurStyle.inner,
              ),
            ],
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
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF0F172A).withValues(alpha: 0.94),
                            const Color(0xFF1A112E).withValues(alpha: 0.90),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Top Glowing Accent Line (::before in Streamlit CSS)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.8, // equivalent to left/right 10%
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                Color(0xFFEC4899),
                                Color(0xFFA855F7),
                                Color(0xFF3B82F6),
                                Colors.transparent,
                              ],
                              stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEC4899),
                                blurRadius: _isHovered ? 22 : 15,
                              ),
                              BoxShadow(
                                color: const Color(0xFFA855F7),
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
