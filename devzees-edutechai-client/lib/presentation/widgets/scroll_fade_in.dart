import 'package:flutter/material.dart';

/// A premium scroll-triggered entrance animation widget.
///
/// Wraps any child with a configurable fade + slide animation that triggers
/// when the widget scrolls into the visible viewport. Designed for use on
/// marketing / landing pages to create a staggered reveal cascade.
///
/// Features:
/// - Configurable slide direction & distance via [offset].
/// - Adjustable [delay] for staggering sibling elements.
/// - Customisable [duration] and [curve].
/// - Fires only once — stays visible after the first reveal.
/// - Uses [Scrollable.of] to listen for ancestor scroll changes.
class ScrollFadeIn extends StatefulWidget {
  final Widget child;

  /// The initial translation offset before the animation plays.
  /// Defaults to sliding up 30 pixels.
  final Offset offset;

  /// Extra delay before starting the animation once the widget is visible.
  final Duration delay;

  /// Duration of the fade + slide transition.
  final Duration duration;

  /// Easing curve for the animation.
  final Curve curve;

  const ScrollFadeIn({
    super.key,
    required this.child,
    this.offset = const Offset(0, 30),
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 700),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<ScrollFadeIn> createState() => _ScrollFadeInState();
}

class _ScrollFadeInState extends State<ScrollFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  bool _hasTriggered = false;
  ScrollPosition? _scrollPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _slide = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Detach from previous scroll position if any
    _scrollPosition?.removeListener(_onScroll);

    // Attach to the nearest ancestor Scrollable's ScrollPosition
    final scrollable = Scrollable.maybeOf(context);
    _scrollPosition = scrollable?.position;
    _scrollPosition?.addListener(_onScroll);

    // Check visibility after this frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkVisibility();
    });
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    _checkVisibility();
  }

  void _checkVisibility() {
    if (_hasTriggered || !mounted) return;

    final renderObject = context.findRenderObject();
    if (renderObject == null || !renderObject.attached) return;

    final renderBox = renderObject as RenderBox;
    if (!renderBox.hasSize) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;

    // Trigger when top of widget enters the bottom 92% of the screen (or is already above)
    if (position.dy < screenHeight * 0.92) {
      _hasTriggered = true;
      if (widget.delay == Duration.zero) {
        _controller.forward();
      } else {
        Future.delayed(widget.delay, () {
          if (mounted) {
            _controller.forward();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: _slide.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
