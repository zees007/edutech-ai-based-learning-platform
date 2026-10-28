import 'dart:async';
import 'package:flutter/material.dart';

/// Real-time ticking digital countdown clock for promotional campaigns and flash sales.
///
/// Features:
/// - 1-second interval live countdown timer.
/// - Segmented digital display showing Days, Hours, Minutes, and Seconds.
/// - Urgency mode: when under 24 hours, automatically emphasizes Hours, Minutes, and Seconds.
/// - Compact mode optimized for mobile screens.
/// - Automatic [onExpired] callback when the countdown hits zero.
/// - Safe lifecycle handling with timer cleanup on dispose.
class PromoCountdownClock extends StatefulWidget {
  /// The future UTC expiration timestamp.
  final DateTime targetDate;

  /// Optional callback invoked once when the clock reaches zero.
  final VoidCallback? onExpired;

  /// Whether to render a compact layout suitable for mobile or tight spaces.
  final bool isCompact;

  /// Whether to show the seconds segment when days > 0 (defaults to true on desktop).
  final bool? showSeconds;

  /// Leading label, e.g. "Ends in". Defaults to "Ends in".
  final String label;

  /// Custom background color override.
  final Color? backgroundColor;

  /// Custom border color override.
  final Color? borderColor;

  const PromoCountdownClock({
    super.key,
    required this.targetDate,
    this.onExpired,
    this.isCompact = false,
    this.showSeconds,
    this.label = 'Ends in',
    this.backgroundColor,
    this.borderColor,
  });

  @override
  State<PromoCountdownClock> createState() => _PromoCountdownClockState();
}

class _PromoCountdownClockState extends State<PromoCountdownClock> {
  Timer? _timer;
  late Duration _remaining;
  bool _expiredNotified = false;

  @override
  void initState() {
    super.initState();
    _computeRemaining();
    _startTimer();
  }

  @override
  void didUpdateWidget(PromoCountdownClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetDate != widget.targetDate) {
      _expiredNotified = false;
      _computeRemaining();
      _startTimer();
    }
  }

  void _computeRemaining() {
    final now = DateTime.now().toUtc();
    final diff = widget.targetDate.toUtc().difference(now);
    if (diff.isNegative || diff.inSeconds <= 0) {
      _remaining = Duration.zero;
      _handleExpiration();
    } else {
      _remaining = diff;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (_remaining == Duration.zero) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final now = DateTime.now().toUtc();
      final diff = widget.targetDate.toUtc().difference(now);
      if (diff.isNegative || diff.inSeconds <= 0) {
        _timer?.cancel();
        setState(() {
          _remaining = Duration.zero;
        });
        _handleExpiration();
      } else {
        setState(() {
          _remaining = diff;
        });
      }
    });
  }

  void _handleExpiration() {
    if (!_expiredNotified) {
      _expiredNotified = true;
      widget.onExpired?.call();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final isCompact = widget.isCompact;
    final isExpired = _remaining == Duration.zero;

    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    // Show seconds if explicitly requested or if under 24 hours or if desktop
    final shouldShowSeconds = widget.showSeconds ?? (!isCompact || days == 0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 7 : 9,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.black.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
        border: Border.all(
          color: widget.borderColor ?? const Color(0xFFFBBF24).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Clock Icon
          Icon(
            Icons.timer_outlined,
            size: isCompact ? 10 : 13,
            color: const Color(0xFFFBBF24),
          ),
          const SizedBox(width: 4),

          // "Ends in" label
          if (widget.label.isNotEmpty) ...[
            Text(
              '${widget.label} ',
              style: TextStyle(
                fontSize: isCompact ? 9 : 11,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFDE68A),
                letterSpacing: 0.3,
              ),
            ),
          ],

          // Clock Digits Display
          if (isExpired)
            Text(
              'Expired',
              style: TextStyle(
                fontSize: isCompact ? 9 : 11,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFF87171),
                letterSpacing: 0.3,
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Days (only shown if > 0)
                if (days > 0) ...[
                  _buildUnitBox(_twoDigits(days), 'd', isCompact),
                  _buildSeparator(isCompact),
                ],

                // Hours
                _buildUnitBox(_twoDigits(hours), 'h', isCompact),
                _buildSeparator(isCompact),

                // Minutes
                _buildUnitBox(_twoDigits(minutes), 'm', isCompact),

                // Seconds
                if (shouldShowSeconds) ...[
                  _buildSeparator(isCompact),
                  _buildUnitBox(_twoDigits(seconds), 's', isCompact),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildUnitBox(String value, String unit, bool isCompact) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: isCompact ? 10 : 12,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFFBBF24),
            letterSpacing: 0.5,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: isCompact ? 8 : 10,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFDE68A),
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator(bool isCompact) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 1.5 : 2.5),
      child: Text(
        ':',
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: isCompact ? 9 : 11,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFFCD34D).withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

