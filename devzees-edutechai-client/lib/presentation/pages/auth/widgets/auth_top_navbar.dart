import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/presentation/widgets/theme_toggle_button.dart';

class AuthTopNavbar extends StatelessWidget {
  final bool isMobile;

  const AuthTopNavbar({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: isMobile ? 12 : 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brand Logo (Preserved)
          Row(
            children: [
              Text(
                '⚡ ',
                style: AppTextStyles.h3.copyWith(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              GradientText(
                'EduTech',
                style: AppTextStyles.h2.copyWith(
                  fontSize: isMobile ? 20 : 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'AI',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isDark ? AppColors.lavender : AppColors.primaryViolet,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          // Top Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ThemeToggleButton(size: 34),
              const SizedBox(width: 10),
              // Back to Home Button
              OutlinedButton.icon(
                onPressed: () => context.go('/'),
                icon: Icon(
                  Icons.arrow_back,
                  size: 16,
                  color: isDark ? AppColors.textPrimary : const Color(0xFF475569),
                ),
                label: Text(
                  isMobile ? 'Back' : 'Back to Home',
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimary : const Color(0xFF475569),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: isDark ? Colors.transparent : Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: isMobile ? 8 : 10,
                  ),
                  side: BorderSide(
                    color: isDark ? AppColors.border : const Color(0xFFE2E8F0),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: isDark ? 0 : 1,
                  shadowColor: const Color(0x0A0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
