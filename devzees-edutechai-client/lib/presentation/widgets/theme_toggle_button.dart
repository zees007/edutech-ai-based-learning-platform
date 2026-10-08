import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/theme_palette.dart';

/// An animated, interactive icon button for toggling between Light and Dark themes.
/// Includes smooth rotation and scale micro-animations, hover effects, and accessible tooltips.
class ThemeToggleButton extends ConsumerStatefulWidget {
  final double size;
  final EdgeInsetsGeometry padding;

  const ThemeToggleButton({
    super.key,
    this.size = 36.0,
    this.padding = const EdgeInsets.all(6.0),
  });

  @override
  ConsumerState<ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends ConsumerState<ThemeToggleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _rotationAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    final colors = context.appColors;

    if (isDark && _controller.status != AnimationStatus.forward && _controller.value == 0.0) {
      _controller.forward();
    } else if (!isDark && _controller.status != AnimationStatus.reverse && _controller.value == 1.0) {
      _controller.reverse();
    }

    final tooltip = isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(widget.size / 2),
            onTap: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
              if (isDark) {
                _controller.reverse();
              } else {
                _controller.forward();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.size,
              height: widget.size,
              padding: widget.padding,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isHovered
                    ? (isDark
                        ? colors.surfaceSubtle.withValues(alpha: 0.8)
                        : colors.surfaceSubtle)
                    : Colors.transparent,
                border: Border.all(
                  color: _isHovered ? colors.border : Colors.transparent,
                  width: 1,
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: (isDark ? colors.accentViolet : colors.accentAmber)
                              .withValues(alpha: 0.20),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: RotationTransition(
                  turns: _rotationAnimation,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                    child: isDark
                        ? Icon(
                            Icons.dark_mode_rounded,
                            key: const ValueKey('dark_icon'),
                            color: colors.accentViolet,
                            size: widget.size * 0.55,
                          )
                        : Icon(
                            Icons.light_mode_rounded,
                            key: const ValueKey('light_icon'),
                            color: colors.accentAmber,
                            size: widget.size * 0.55,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
