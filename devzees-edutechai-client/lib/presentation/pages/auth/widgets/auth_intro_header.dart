import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';

class AuthIntroHeader extends StatelessWidget {
  final bool isMobile;

  const AuthIntroHeader({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Text(
            "EduTech AI is an autonomous, multi-agent learning ecosystem. Sign in or create a free account to launch your personal AI tutor squad.",
            style: AppTextStyles.bodyPrimary.copyWith(
              fontSize: isMobile ? 14 : 15,
              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF334155),
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
