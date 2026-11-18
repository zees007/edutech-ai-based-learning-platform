import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.gradient = AppColors.primaryGradient,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        final rect = (bounds.width <= 0 || bounds.height <= 0)
            ? const Rect.fromLTWH(0, 0, 500, 50)
            : Rect.fromLTWH(0, 0, bounds.width, bounds.height);
        return gradient.createShader(rect);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6.0, right: 4.0),
        child: Text(
          text,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          style: (style ?? const TextStyle()).copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
