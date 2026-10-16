import 'package:flutter/material.dart';

/// A 3D perspective tilt container inspired by modern cinematic web design (GetLayers.ai).
///
/// Features:
/// - Real-time 3D perspective rotation using [Matrix4] towards the cursor.
/// - Dynamic specular light reflection/glare following the cursor position.
/// - Smooth spring dampening back to neutral when the cursor exits.
/// - Touch-safe, constraint-safe (no LayoutBuilder), zero intrinsic measurement conflicts.
class Interactive3DCard extends StatefulWidget {
  final Widget child;
  final double maxTiltAngle;
  final double perspective;
  final double hoverScale;
  final bool enableGlare;
  final Color? glareColor;
  final double maxGlareOpacity;
  final BorderRadiusGeometry? borderRadius;
  final Duration springDuration;
  final Curve springCurve;
  final VoidCallback? onTap;

  const Interactive3DCard({
    super.key,
    required this.child,
    this.maxTiltAngle = 0.12, // ~7 degrees
    this.perspective = 0.0012,
    this.hoverScale = 1.02,
    this.enableGlare = true,
    this.glareColor,
    this.maxGlareOpacity = 0.15,
    this.borderRadius,
    this.springDuration = const Duration(milliseconds: 350),
    this.springCurve = Curves.easeOutCubic,
    this.onTap,
  });

  @override
  State<Interactive3DCard> createState() => _Interactive3DCardState();
}

class _Interactive3DCardState extends State<Interactive3DCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _springController;
  late Animation<double> _rotXAnimation;
  late Animation<double> _rotYAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glareOpacityAnimation;

  double _targetRotX = 0.0;
  double _targetRotY = 0.0;
  double _currentRotX = 0.0;
  double _currentRotY = 0.0;
  double _currentScale = 1.0;
  double _glareX = 0.5;
  double _glareY = 0.5;
  double _glareOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: widget.springDuration,
    )..addListener(() {
        setState(() {
          _currentRotX = _rotXAnimation.value;
          _currentRotY = _rotYAnimation.value;
          _currentScale = _scaleAnimation.value;
          _glareOpacity = _glareOpacityAnimation.value;
        });
      });

    _rotXAnimation = const AlwaysStoppedAnimation(0.0);
    _rotYAnimation = const AlwaysStoppedAnimation(0.0);
    _scaleAnimation = const AlwaysStoppedAnimation(1.0);
    _glareOpacityAnimation = const AlwaysStoppedAnimation(0.0);
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  void _onHover(PointerEvent details) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final Size size = box.size;
    if (size.width <= 0 || size.height <= 0) return;

    final double x = details.localPosition.dx.clamp(0.0, size.width);
    final double y = details.localPosition.dy.clamp(0.0, size.height);

    // Normalize from -1.0 to 1.0
    final double normalizedX = (x / size.width) * 2 - 1;
    final double normalizedY = (y / size.height) * 2 - 1;

    _targetRotX = -normalizedY * widget.maxTiltAngle;
    _targetRotY = normalizedX * widget.maxTiltAngle;

    setState(() {
      _currentRotX = _targetRotX;
      _currentRotY = _targetRotY;
      _currentScale = widget.hoverScale;
      _glareX = (x / size.width);
      _glareY = (y / size.height);
      _glareOpacity = widget.maxGlareOpacity;
    });
  }

  void _onExit(PointerEvent details) {
    _springController.stop();

    _rotXAnimation = Tween<double>(
      begin: _currentRotX,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _springController,
      curve: widget.springCurve,
    ));

    _rotYAnimation = Tween<double>(
      begin: _currentRotY,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _springController,
      curve: widget.springCurve,
    ));

    _scaleAnimation = Tween<double>(
      begin: _currentScale,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _springController,
      curve: widget.springCurve,
    ));

    _glareOpacityAnimation = Tween<double>(
      begin: _glareOpacity,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _springController,
      curve: widget.springCurve,
    ));

    _springController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final BorderRadius effectiveBorderRadius =
        (widget.borderRadius as BorderRadius?) ?? BorderRadius.circular(20);

    // Compute 3D Perspective Matrix
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, widget.perspective)
      ..rotateX(_currentRotX)
      ..rotateY(_currentRotY);

    return MouseRegion(
      onHover: _onHover,
      onExit: _onExit,
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Transform.scale(
          scale: _currentScale,
          alignment: Alignment.center,
          child: Transform(
            alignment: FractionalOffset.center,
            transform: matrix,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Main Content
                widget.child,

                // Specular Glare Overlay
                if (widget.enableGlare && _glareOpacity > 0.001)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ClipRRect(
                        borderRadius: effectiveBorderRadius,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment(
                                _glareX * 2 - 1,
                                _glareY * 2 - 1,
                              ),
                              radius: 0.85,
                              colors: [
                                (widget.glareColor ?? Colors.white)
                                    .withValues(alpha: _glareOpacity),
                                (widget.glareColor ?? Colors.white)
                                    .withValues(alpha: _glareOpacity * 0.35),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.45, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
