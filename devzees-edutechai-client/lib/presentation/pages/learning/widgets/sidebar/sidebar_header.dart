import 'package:flutter/material.dart';
import '../../../../../presentation/widgets/gradient_text.dart';
import '../../../../../presentation/widgets/theme_toggle_button.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';

class SidebarHeader extends StatelessWidget {
  final bool expanded;
  final bool isMobile;
  final VoidCallback onToggle;
  final VoidCallback onClose;

  const SidebarHeader({
    super.key,
    required this.expanded,
    required this.isMobile,
    required this.onToggle,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (!expanded && !isMobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onToggle,
              icon: Icon(Icons.menu, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            const ThemeToggleButton(size: 32),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                '⚡ ',
                style: AppTextStyles.h4.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              GradientText(
                'EduTech',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'AI',
                  style: AppTextStyles.labelSmall,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ThemeToggleButton(size: 32),
              const SizedBox(width: 4),
              if (!isMobile)
                IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    expanded ? Icons.menu_open : Icons.menu,
                    color: AppColors.textSecondary,
                  ),
                )
              else
                IconButton(
                  onPressed: onClose,
                  icon: Icon(Icons.menu_open, color: AppColors.textSecondary),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
