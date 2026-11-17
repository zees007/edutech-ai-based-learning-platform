import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';

/// A modern kinetic CTA button with magnetic cursor pull and specular shimmer sweep.
class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool iconFirst;
  final double? width;
  final double height;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final Color? glowColor;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.iconFirst = false,
    this.width,
    this.height = 48.0,
    this.gradient,
    this.borderRadius,
    this.textStyle,
    this.padding,
    this.glowColor,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  double _magneticX = 0.0;
  double _magneticY = 0.0;

  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _onHover(PointerEvent event) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final Size size = box.size;
    if (size.width <= 0 || size.height <= 0) return;

    final double relX = (event.localPosition.dx / size.width) - 0.5;
    final double relY = (event.localPosition.dy / size.height) - 0.5;

    setState(() {
      _isHovered = true;
      _magneticX = relX * 10.0;
      _magneticY = relY * 6.0;
    });

    if (!_shimmerController.isAnimating) {
      _shimmerController.repeat();
    }
  }

  void _onExit(PointerEvent event) {
    setState(() {
      _isHovered = false;
      _magneticX = 0.0;
      _magneticY = 0.0;
    });
    _shimmerController.stop();
    _shimmerController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.isLoading || widget.onPressed == null;
    final BorderRadius effectiveRadius =
        widget.borderRadius ?? BorderRadius.circular(24);
    final Gradient effectiveGradient =
        widget.gradient ?? AppColors.primaryGradient;

    final Widget buttonContent = Padding(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
      child: widget.isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null && widget.iconFirst) ...[
                  Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 16,
                    shadows: [
                      Shadow(
                        color: Colors.white.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    widget.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        widget.textStyle ??
                        AppTextStyles.button.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                  ),
                ),
                if (widget.icon != null && !widget.iconFirst) ...[
                  const SizedBox(width: 8),
                  Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 16,
                    shadows: [
                      Shadow(
                        color: Colors.white.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ],
              ],
            ),
    );

    return MouseRegion(
      onHover: isDisabled ? null : _onHover,
      onExit: isDisabled ? null : _onExit,
      hitTestBehavior: HitTestBehavior.opaque,
      cursor: isDisabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(
          isDisabled ? 0.0 : _magneticX,
          isDisabled ? 0.0 : _magneticY,
          0.0,
        ),
        child: AnimatedScale(
          scale: _isHovered && !isDisabled ? 1.025 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: effectiveRadius,
              gradient: effectiveGradient,
              boxShadow: [
                BoxShadow(
                  color: (widget.glowColor ?? AppColors.accentPink).withValues(
                    alpha: _isHovered && !isDisabled ? 0.65 : 0.35,
                  ),
                  blurRadius: _isHovered && !isDisabled ? 32 : 20,
                  spreadRadius: _isHovered && !isDisabled ? 2 : 0,
                  offset: Offset(0, _isHovered && !isDisabled ? 6 : 4),
                ),
                if (_isHovered && !isDisabled)
                  BoxShadow(
                    color: AppColors.accentCyan.withValues(alpha: 0.45),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: effectiveRadius,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Button Clickable Material
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: effectiveRadius,
                      mouseCursor: isDisabled
                          ? SystemMouseCursors.basic
                          : SystemMouseCursors.click,
                      onTap: isDisabled ? null : widget.onPressed,
                      child: SizedBox(
                        width: widget.width,
                        height: widget.height,
                        child: Center(
                          widthFactor: widget.width == null ? 1.0 : null,
                          child: SelectionContainer.disabled(
                            child: buttonContent,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Specular Shimmer Sweep
                  if (_isHovered && !isDisabled)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (context, _) {
                            final double value = _shimmerController.value;
                            return FractionallySizedBox(
                              widthFactor: 0.5,
                              alignment: Alignment(-2.0 + (value * 4.0), 0.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withValues(alpha: 0.22),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
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
