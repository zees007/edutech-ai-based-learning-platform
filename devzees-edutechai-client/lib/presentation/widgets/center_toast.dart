import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';

/// Semantic toast alert types.
enum CenterToastType {
  error,
  warning,
  success,
  info,
}

/// Global, high-visibility, responsive toast notification positioned at bottom-center.
///
/// Designed with luxury glassmorphic SaaS styling matching the EduTech AI brand:
/// - Horizontally centered and docked to the bottom center of the viewport
/// - Keyboard-aware (smoothly elevates above the mobile virtual keyboard)
/// - Responsive screen-width clamping for mobile phones, tablets, and desktops
/// - Touch-dismissible, horizontal swipe-to-dismiss, and animated countdown progress bar
/// - Feathered hairline borders, atmospheric glowing auras, and dark/light mode fidelity
class CenterToast {
  static OverlayEntry? _activeEntry;
  static String? _lastMessage;
  static DateTime? _lastDisplayTime;

  /// Shows an error toast (e.g. invalid credentials, authentication failures).
  static void showError(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(milliseconds: 3500),
    IconData? icon,
  }) {
    show(
      context,
      message: message,
      title: title ?? 'Authentication Error',
      type: CenterToastType.error,
      duration: duration,
      icon: icon ?? Icons.error_outline_rounded,
    );
  }

  /// Shows a warning toast (e.g. validation errors, missing inputs).
  static void showWarning(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(milliseconds: 3500),
    IconData? icon,
  }) {
    show(
      context,
      message: message,
      title: title ?? 'Attention',
      type: CenterToastType.warning,
      duration: duration,
      icon: icon ?? Icons.warning_amber_rounded,
    );
  }

  /// Shows a success toast (e.g. registration successful).
  static void showSuccess(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(milliseconds: 3500),
    IconData? icon,
  }) {
    show(
      context,
      message: message,
      title: title ?? 'Success',
      type: CenterToastType.success,
      duration: duration,
      icon: icon ?? Icons.check_circle_outline_rounded,
    );
  }

  /// Shows an informational toast.
  static void showInfo(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(milliseconds: 3500),
    IconData? icon,
  }) {
    show(
      context,
      message: message,
      title: title ?? 'Notice',
      type: CenterToastType.info,
      duration: duration,
      icon: icon ?? Icons.info_outline_rounded,
    );
  }

  /// Shows a custom centered-bottom toast alert.
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    CenterToastType type = CenterToastType.error,
    Duration duration = const Duration(milliseconds: 3500),
    IconData? icon,
  }) {
    final now = DateTime.now();
    if (_lastMessage == message &&
        _lastDisplayTime != null &&
        now.difference(_lastDisplayTime!) < const Duration(milliseconds: 1200)) {
      return; // Deduplicate rapid repeated calls
    }
    _lastMessage = message;
    _lastDisplayTime = now;

    // Clean up any existing active toast
    dismiss();

    final overlayState = Overlay.maybeOf(context, rootOverlay: true) ?? Overlay.maybeOf(context);
    if (overlayState == null) return;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (BuildContext overlayContext) {
        return _CenterToastOverlayHost(
          message: message,
          title: title,
          type: type,
          duration: duration,
          icon: icon,
          onDismiss: () {
            _removeEntry(entry);
          },
        );
      },
    );

    _activeEntry = entry;
    overlayState.insert(entry);
  }

  /// Immediately dismisses the currently active toast.
  static void dismiss() {
    if (_activeEntry != null) {
      final entry = _activeEntry!;
      _activeEntry = null;
      try {
        if (entry.mounted) {
          entry.remove();
        }
      } catch (_) {}
    }
  }

  static void _removeEntry(OverlayEntry entry) {
    if (_activeEntry == entry) {
      _activeEntry = null;
    }
    try {
      if (entry.mounted) {
        entry.remove();
      }
    } catch (_) {}
  }
}

class _CenterToastOverlayHost extends StatefulWidget {
  final String message;
  final String? title;
  final CenterToastType type;
  final Duration duration;
  final IconData? icon;
  final VoidCallback onDismiss;

  const _CenterToastOverlayHost({
    required this.message,
    this.title,
    required this.type,
    required this.duration,
    this.icon,
    required this.onDismiss,
  });

  @override
  State<_CenterToastOverlayHost> createState() => _CenterToastOverlayHostState();
}

class _CenterToastOverlayHostState extends State<_CenterToastOverlayHost>
    with TickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  late final AnimationController _progressController;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _dismissWithAnimation();
      }
    });

    _animController.forward();
    _progressController.forward();
  }

  void _dismissWithAnimation() {
    if (_isDismissing || !mounted) return;
    _isDismissing = true;
    _animController.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final isMobile = screenWidth < 768;
    final isSmallScreen = screenWidth < 380;

    final horizontalMargin = isSmallScreen ? 16.0 : 24.0;
    final toastWidth = (screenWidth - (horizontalMargin * 2)).clamp(280.0, 430.0);

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.only(
              bottom: keyboardHeight > 0
                  ? (keyboardHeight + 16.0)
                  : (isMobile ? 24.0 : 32.0),
              left: horizontalMargin,
              right: horizontalMargin,
            ),
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: child,
                    ),
                  ),
                );
              },
              child: SizedBox(
                width: toastWidth,
                child: Dismissible(
                  key: const ValueKey('center_bottom_toast_dismissible'),
                  direction: DismissDirection.horizontal,
                  onDismissed: (_) {
                    widget.onDismiss();
                  },
                  child: GestureDetector(
                    onTap: _dismissWithAnimation,
                    child: _buildToastCard(context, isSmallScreen),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToastCard(BuildContext context, bool isSmallScreen) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color primaryColor;
    Color secondaryColor;
    Color glowColor;
    IconData defaultIcon;
    String defaultTitle;
    String badgeTag;

    switch (widget.type) {
      case CenterToastType.error:
        primaryColor = AppColors.rose;
        secondaryColor = const Color(0xFFE11D48); // Deep crimson
        glowColor = AppColors.rose.withValues(alpha: 0.28);
        defaultIcon = Icons.error_outline_rounded;
        defaultTitle = 'Authentication Error';
        badgeTag = 'ERROR';
        break;

      case CenterToastType.warning:
        primaryColor = AppColors.accentAmber;
        secondaryColor = const Color(0xFFD97706); // Deep amber
        glowColor = AppColors.accentAmber.withValues(alpha: 0.25);
        defaultIcon = Icons.warning_amber_rounded;
        defaultTitle = 'Attention';
        badgeTag = 'WARNING';
        break;

      case CenterToastType.success:
        primaryColor = AppColors.emerald;
        secondaryColor = const Color(0xFF059669); // Deep emerald
        glowColor = AppColors.emerald.withValues(alpha: 0.25);
        defaultIcon = Icons.check_circle_outline_rounded;
        defaultTitle = 'Success';
        badgeTag = 'SUCCESS';
        break;

      case CenterToastType.info:
        primaryColor = AppColors.primary;
        secondaryColor = AppColors.primaryPink; // Brand blue-to-pink gradient
        glowColor = AppColors.primary.withValues(alpha: 0.25);
        defaultIcon = Icons.info_outline_rounded;
        defaultTitle = 'Notice';
        badgeTag = 'INFO';
        break;
    }

    final displayTitle = widget.title ?? defaultTitle;
    final iconData = widget.icon ?? defaultIcon;

    // Premium luxury dark SaaS container decoration
    final cardDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: isDark
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xF2161726), // Elevated chip background (#151726)
                const Color(0xF20F101B), // Unified dark panel surface
              ],
            )
          : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFAFFFFFF),
                Color(0xF5F8FAFC),
              ],
            ),
      border: Border.all(
        color: isDark
            ? primaryColor.withValues(alpha: 0.38)
            : primaryColor.withValues(alpha: 0.30),
        width: 1.2,
      ),
      boxShadow: [
        // Colored atmospheric brand glow
        BoxShadow(
          color: glowColor,
          blurRadius: isDark ? 28 : 20,
          spreadRadius: -2,
          offset: const Offset(0, 6),
        ),
        // Deep SaaS drop elevation
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.65)
              : const Color(0x16000000),
          blurRadius: isDark ? 36 : 24,
          spreadRadius: 0,
          offset: const Offset(0, 14),
        ),
      ],
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: cardDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Subtle top glass bevel highlight
              Container(
                height: 1.0,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      (isDark ? Colors.white : primaryColor).withValues(alpha: 0.20),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Content Body
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 14 : 16,
                  vertical: isSmallScreen ? 12 : 14,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Glowing Icon Badge
                    Container(
                      width: isSmallScreen ? 36 : 40,
                      height: isSmallScreen ? 36 : 40,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.25),
                          width: 1.0,
                        ),
                        boxShadow: [
                          if (isDark)
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.20),
                              blurRadius: 10,
                              spreadRadius: -1,
                            ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          color: primaryColor,
                          size: isSmallScreen ? 20 : 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title, Semantic Tag & Message
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  displayTitle,
                                  style: AppTextStyles.subtitle2.copyWith(
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    fontWeight: FontWeight.w700,
                                    fontSize: isSmallScreen ? 13.5 : 14.5,
                                    letterSpacing: -0.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Sleek Micro Pill Tag
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: isDark ? 0.16 : 0.10),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: primaryColor.withValues(alpha: isDark ? 0.30 : 0.22),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  badgeTag,
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.message,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body2.copyWith(
                              color: isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF334155),
                              fontWeight: FontWeight.w400,
                              fontSize: isSmallScreen ? 12 : 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Subtle Close Button
                    GestureDetector(
                      onTap: _dismissWithAnimation,
                      behavior: HitTestBehavior.opaque,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.07)
                                : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.black.withValues(alpha: 0.03),
                            ),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 15,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Animated Duration Countdown Progress Bar
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, _) {
                  return Container(
                    height: 2.5,
                    width: double.infinity,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.04),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: (1.0 - _progressController.value).clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryColor,
                                secondaryColor,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
