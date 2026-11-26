import 'package:flutter/material.dart';

/// A smooth, overflow-free collapsible desktop sidebar shell.
///
/// Animates container width between [collapsedWidth] and [expandedWidth] using a
/// single [AnimationController] while cross-fading an anchored collapsed rail
/// and a fixed-width expanded panel via [FadeTransition] + [OverflowBox] +
/// hard clipping. This avoids mid-animation layout overflows, horizontal icon
/// jumps, abrupt content pops, and per-frame child widget rebuilds.
class SmoothCollapsibleSidebar extends StatefulWidget {
  final bool expanded;
  final double expandedWidth;
  final double collapsedWidth;
  final Duration duration;
  final Curve curve;
  final Color backgroundColor;
  final Color borderColor;
  final WidgetBuilder expandedBuilder;
  final WidgetBuilder collapsedBuilder;

  const SmoothCollapsibleSidebar({
    super.key,
    required this.expanded,
    required this.expandedWidth,
    this.collapsedWidth = 80,
    this.duration = const Duration(milliseconds: 260),
    this.curve = Curves.easeInOutCubic,
    required this.backgroundColor,
    required this.borderColor,
    required this.expandedBuilder,
    required this.collapsedBuilder,
  });

  @override
  State<SmoothCollapsibleSidebar> createState() =>
      _SmoothCollapsibleSidebarState();
}

class _SmoothCollapsibleSidebarState extends State<SmoothCollapsibleSidebar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late CurvedAnimation _curvedAnimation;
  late CurvedAnimation _collapsedCurved;
  late CurvedAnimation _expandedCurved;
  late Animation<double> _widthAnimation;
  late Animation<double> _expandedOpacity;
  late Animation<double> _collapsedOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.expanded ? 1.0 : 0.0,
    );
    _controller.addStatusListener(_handleStatusChanged);
    _setupAnimations();
  }

  void _setupAnimations() {
    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    _widthAnimation = Tween<double>(
      begin: widget.collapsedWidth,
      end: widget.expandedWidth,
    ).animate(_curvedAnimation);

    // Fade the collapsed rail out early while expanding, and back in late while
    // collapsing, keeping icons anchored to the 80px rail throughout.
    _collapsedCurved = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _collapsedOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(_collapsedCurved);

    // Fade the expanded panel in only once the drawer widens past the rail,
    // and fade it out smoothly before the drawer collapses to the rail.
    _expandedCurved = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.20, 0.90, curve: Curves.easeOut),
    );
    _expandedOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(_expandedCurved);
  }

  void _disposeCurves() {
    _curvedAnimation.dispose();
    _collapsedCurved.dispose();
    _expandedCurved.dispose();
  }

  void _handleStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void didUpdateWidget(covariant SmoothCollapsibleSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }

    if (oldWidget.collapsedWidth != widget.collapsedWidth ||
        oldWidget.expandedWidth != widget.expandedWidth ||
        oldWidget.curve != widget.curve) {
      _disposeCurves();
      _setupAnimations();
    }

    if (widget.expanded != oldWidget.expanded) {
      if (widget.expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleStatusChanged);
    _disposeCurves();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAnimating = _controller.isAnimating;
    final bool showExpanded =
        widget.expanded || isAnimating || _controller.value > 0.0;
    final bool showCollapsed =
        !widget.expanded || isAnimating || _controller.value < 1.0;

    // Account for the 1px right border so inner content lays out at exact resting width.
    final double innerExpandedWidth = (widget.expandedWidth - 1).clamp(0.0, double.infinity);
    final double innerCollapsedWidth = (widget.collapsedWidth - 1).clamp(0.0, double.infinity);

    final Widget contentStack = Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        border: Border(
          right: BorderSide(color: widget.borderColor, width: 1),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (showCollapsed)
            IgnorePointer(
              ignoring: widget.expanded,
              child: FadeTransition(
                opacity: _collapsedOpacity,
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  minWidth: innerCollapsedWidth,
                  maxWidth: innerCollapsedWidth,
                  child: widget.collapsedBuilder(context),
                ),
              ),
            ),
          if (showExpanded)
            IgnorePointer(
              ignoring: !widget.expanded,
              child: FadeTransition(
                opacity: _expandedOpacity,
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  minWidth: innerExpandedWidth,
                  maxWidth: innerExpandedWidth,
                  child: widget.expandedBuilder(context),
                ),
              ),
            ),
        ],
      ),
    );

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _widthAnimation,
        child: contentStack,
        builder: (context, child) {
          return SizedBox(
            width: _widthAnimation.value,
            child: child,
          );
        },
      ),
    );
  }
}
