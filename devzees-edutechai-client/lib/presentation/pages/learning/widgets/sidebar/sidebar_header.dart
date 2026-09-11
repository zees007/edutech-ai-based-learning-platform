import 'package:flutter/material.dart';
import '../../../../../presentation/widgets/gradient_text.dart';
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
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: expanded
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.center,
        children: [
          if (expanded)
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
              icon: const Icon(Icons.menu_open, color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }
}
