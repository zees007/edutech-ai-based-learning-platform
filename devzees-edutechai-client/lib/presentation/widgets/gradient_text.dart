import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;
  final TextAlign? textAlign;

  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.gradient = AppColors.primaryGradient,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        if (bounds.width <= 0 || bounds.height <= 0) {
          return const LinearGradient(colors: [Colors.transparent, Colors.transparent])
              .createShader(const Rect.fromLTWH(0, 0, 1, 1));
        }
        return gradient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        );
      },
      child: Text(
        text,
        textAlign: textAlign,
        style: (style ?? const TextStyle()).copyWith(color: Colors.white),
      ),
    );
  }
}
