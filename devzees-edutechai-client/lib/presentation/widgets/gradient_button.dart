import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';

/// A modern kinetic CTA button with ripple feedback and specular shimmer sweep.
class GradientButton extends StatefulWidget {
  final String? text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double iconSize;
  final bool iconFirst;
  final double? width;
  final double? height;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final BoxBorder? border;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final bool showShadow;
  final bool enableHoverEffects;
  final double loadingIndicatorSize;

  const GradientButton({
    super.key,
    required String this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.iconSize = 16.0,
    this.iconFirst = false,
    this.width,
    this.height = 48.0,
    this.gradient,
    this.borderRadius,
    this.border,
    this.textStyle,
    this.padding,
    this.showShadow = true,
    this.enableHoverEffects = true,
    this.loadingIndicatorSize = 20.0,
  }) : shape = BoxShape.rectangle;

  /// Compact icon-only gradient button with Material ripple and no colored glow.
  const GradientButton.icon({
    super.key,
    required IconData this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.iconSize = 18.0,
    this.width,
    this.height = 40.0,
    this.gradient,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.border,
    this.padding,
    this.showShadow = false,
    this.enableHoverEffects = false,
    this.loadingIndicatorSize = 16.0,
  })  : text = null,
        iconFirst = true,
        textStyle = null;

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
    if (!widget.enableHoverEffects) {
      if (!_isHovered) setState(() => _isHovered = true);
      return;
    }

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
    final bool isCircle = widget.shape == BoxShape.circle;
    final BorderRadius effectiveRadius =
        widget.borderRadius ?? BorderRadius.circular(24);
    final Gradient effectiveGradient =
        widget.gradient ?? AppColors.primaryGradient;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isIconOnly = widget.text == null;

    final EdgeInsetsGeometry effectivePadding =
        widget.padding ??
        (isIconOnly
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 16.0));

    final Widget buttonContent = Padding(
      padding: effectivePadding,
      child: widget.isLoading
          ? SizedBox(
              width: widget.loadingIndicatorSize,
              height: widget.loadingIndicatorSize,
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : isIconOnly
          ? Icon(
              widget.icon,
              color: Colors.white,
              size: widget.iconSize,
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null && widget.iconFirst) ...[
                  Icon(
                    widget.icon,
                    color: Colors.white,
                    size: widget.iconSize,
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    widget.text!,
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
                    size: widget.iconSize,
                  ),
                ],
              ],
            ),
    );

    final Widget interactiveStack = Stack(
      alignment: Alignment.center,
      children: [
        // Button Clickable Material (preserves native InkWell ripple)
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: isCircle ? null : effectiveRadius,
            customBorder: isCircle ? const CircleBorder() : null,
            mouseCursor: isDisabled
                ? SystemMouseCursors.basic
                : SystemMouseCursors.click,
            onTap: isDisabled ? null : widget.onPressed,
            child: SizedBox(
              width: widget.width,
              height: widget.height,
              child: Center(
                widthFactor: widget.width == null ? 1.0 : null,
                heightFactor: widget.height == null ? 1.0 : null,
                child: SelectionContainer.disabled(child: buttonContent),
              ),
            ),
          ),
        ),

        // Specular Shimmer Sweep
        if (widget.enableHoverEffects && _isHovered && !isDisabled)
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
          !widget.enableHoverEffects || isDisabled ? 0.0 : _magneticX,
          !widget.enableHoverEffects || isDisabled ? 0.0 : _magneticY,
          0.0,
        ),
        child: AnimatedScale(
          scale: widget.enableHoverEffects && _isHovered && !isDisabled
              ? 1.025
              : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              shape: widget.shape,
              borderRadius: isCircle ? null : effectiveRadius,
              gradient: effectiveGradient,
              border: widget.border,
              boxShadow: widget.showShadow && !isDisabled
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark
                              ? (_isHovered ? 0.38 : 0.28)
                              : (_isHovered ? 0.16 : 0.10),
                        ),
                        blurRadius: isDark
                            ? (_isHovered ? 16 : 12)
                            : (_isHovered ? 14 : 10),
                        offset: Offset(0, isDark ? 4 : 3),
                      ),
                    ]
                  : null,
            ),
            child: isCircle
                ? ClipOval(child: interactiveStack)
                : ClipRRect(
                    borderRadius: effectiveRadius,
                    child: interactiveStack,
                  ),
          ),
        ),
      ),
    );
  }
}
