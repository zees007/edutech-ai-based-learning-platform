import 'package:flutter/material.dart';

/// Staggered word-by-word spring reveal widget inspired by modern 3D motion SaaS landing pages.
///
/// Splitting headings and subtitles into staggered inline word units that slide up
/// from a subtle vertical translation and fade in with an [easeOutCubic] spring curve.
class WordByWordReveal extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final List<String> gradientWords;
  final Gradient? gradient;
  final int initialDelayMs;
  final int staggerMs;
  final int wordDurationMs;
  final double initialTranslateY;
  final WrapAlignment alignment;
  final TextAlign textAlign;

  const WordByWordReveal({
    super.key,
    required this.text,
    this.style,
    this.gradientWords = const [],
    this.gradient,
    this.initialDelayMs = 450,
    this.staggerMs = 85,
    this.wordDurationMs = 700,
    this.initialTranslateY = 26.0,
    this.alignment = WrapAlignment.center,
    this.textAlign = TextAlign.center,
  });

  @override
  State<WordByWordReveal> createState() => _WordByWordRevealState();
}

class _WordByWordRevealState extends State<WordByWordReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<String> _words;
  late final int _totalDurationMs;

  @override
  void initState() {
    super.initState();
    _words = widget.text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    _totalDurationMs = widget.initialDelayMs +
        (_words.length * widget.staggerMs) +
        widget.wordDurationMs;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _totalDurationMs),
    );

    // Kick off animation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isGradientWord(String word) {
    if (widget.gradientWords.isEmpty) return false;
    final cleanWord = word.replaceAll(RegExp(r'[^\w\s]'), '').toLowerCase();
    for (final phrase in widget.gradientWords) {
      final phraseWords = phrase.toLowerCase().split(' ');
      if (phraseWords.contains(cleanWord)) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = widget.style ?? const TextStyle(color: Colors.white);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final currentMs = _controller.value * _totalDurationMs;

        return Wrap(
          alignment: widget.alignment,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6.0,
          runSpacing: 4.0,
          children: List.generate(_words.length, (index) {
            final word = _words[index];
            final wordStartMs = widget.initialDelayMs + (index * widget.staggerMs);

            final double progress = ((currentMs - wordStartMs) / widget.wordDurationMs)
                .clamp(0.0, 1.0);

            // Easing: easeOutCubic (1 - (1-t)^3)
            final double eased = Curves.easeOutCubic.transform(progress);

            final double opacity = eased;
            final double translateY = widget.initialTranslateY * (1.0 - eased);

            final bool isGrad = _isGradientWord(word);

            Widget wordWidget = Text(
              word,
              style: isGrad && widget.gradient != null
                  ? effectiveStyle.copyWith(color: Colors.white)
                  : effectiveStyle,
              textAlign: widget.textAlign,
            );

            if (isGrad && widget.gradient != null) {
              wordWidget = ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) {
                  return widget.gradient!.createShader(
                    Rect.fromLTWH(0, 0, bounds.width > 0 ? bounds.width : 100, bounds.height > 0 ? bounds.height : 40),
                  );
                },
                child: wordWidget,
              );
            }

            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(0, translateY),
                child: wordWidget,
              ),
            );
          }),
        );
      },
    );
  }
}

/// A soft spring entrance wrapper for whole blocks (nav bar, pill badge, CTA bar, footer).
class SpringEntranceBlock extends StatefulWidget {
  final Widget child;
  final int delayMs;
  final int durationMs;
  final Offset fromOffset;

  const SpringEntranceBlock({
    super.key,
    required this.child,
    this.delayMs = 150,
    this.durationMs = 750,
    this.fromOffset = const Offset(0, 24),
  });

  @override
  State<SpringEntranceBlock> createState() => _SpringEntranceBlockState();
}

class _SpringEntranceBlockState extends State<SpringEntranceBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationMs),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final t = _animation.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(
              widget.fromOffset.dx * (1.0 - t),
              widget.fromOffset.dy * (1.0 - t),
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}
