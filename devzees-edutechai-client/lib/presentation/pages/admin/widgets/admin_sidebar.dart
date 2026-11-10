import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';

enum AdminSection { users, roles, subscriptions, settings, analytics, feedbacks }

/// Admin sidebar navigation with glassmorphic styling.
class AdminSidebar extends StatelessWidget {
  final AdminSection selected;
  final ValueChanged<AdminSection> onSectionChanged;
  final bool expanded;

  const AdminSidebar({
    super.key,
    required this.selected,
    required this.onSectionChanged,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: expanded
                ? Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin Console',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.subtitle2.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Manage your platform',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 24),
          // Navigation Items
          _buildNavItem(
            context,
            icon: Icons.people_outline,
            label: 'User Directory',
            section: AdminSection.users,
          ),
          _buildNavItem(
            context,
            icon: Icons.shield_outlined,
            label: 'Roles & Privileges',
            section: AdminSection.roles,
          ),
          _buildNavItem(
            context,
            icon: Icons.credit_card_outlined,
            label: 'Subscriptions',
            section: AdminSection.subscriptions,
          ),
          _buildNavItem(
            context,
            icon: Icons.tune_outlined,
            label: 'System Settings',
            section: AdminSection.settings,
          ),
          _buildNavItem(
            context,
            icon: Icons.bar_chart_outlined,
            label: 'Analytics',
            section: AdminSection.analytics,
          ),
          _buildNavItem(
            context,
            icon: Icons.rate_review_outlined,
            label: 'Feedbacks & Reviews',
            section: AdminSection.feedbacks,
          ),
          const Spacer(),
          // Back to Learning
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: _BackToLearningButton(expanded: expanded),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required AdminSection section,
  }) {
    final isSelected = selected == section;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: _NavItemTile(
        icon: icon,
        label: label,
        isSelected: isSelected,
        expanded: expanded,
        onTap: () => onSectionChanged(section),
      ),
    );
  }
}

class _NavItemTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool expanded;
  final VoidCallback onTap;

  const _NavItemTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.expanded,
    required this.onTap,
  });

  @override
  State<_NavItemTile> createState() => _NavItemTileState();
}

class _NavItemTileState extends State<_NavItemTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minHeight: 46),
          padding: EdgeInsets.symmetric(
            horizontal: widget.expanded ? 14 : 10,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: widget.isSelected
                ? AppColors.purple.withValues(alpha: 0.16)
                : _isHovered
                    ? AppColors.glassHover
                    : Colors.transparent,
            border: widget.isSelected
                ? Border.all(
                    color: AppColors.purple.withValues(alpha: 0.45),
                    width: 1.2,
                  )
                : null,
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.purple.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: widget.expanded
              ? Row(
                  children: [
                    Icon(
                      widget.icon,
                      color: widget.isSelected
                          ? AppColors.purple
                          : _isHovered
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.label.copyWith(
                          color: widget.isSelected
                              ? AppColors.textPrimary
                              : _isHovered
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                          fontWeight: widget.isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (widget.isSelected) ...[
                      const SizedBox(width: 8),
                      // Prominent, glowing active vertical indicator
                      Container(
                        width: 5.5,
                        height: 26,
                        decoration: BoxDecoration(
                          gradient: AppColors.pinkPurpleGradient,
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.purple.withValues(alpha: 0.65),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                            BoxShadow(
                              color: const Color(0xFFC839F6).withValues(alpha: 0.45),
                              blurRadius: 6,
                              spreadRadius: 0.5,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                )
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Tooltip(
                        message: widget.label,
                        child: Icon(
                          widget.icon,
                          color: widget.isSelected
                              ? AppColors.purple
                              : _isHovered
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted,
                          size: 22,
                        ),
                      ),
                    ),
                    if (widget.isSelected)
                      Positioned(
                        right: 0,
                        child: Container(
                          width: 4.5,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: AppColors.pinkPurpleGradient,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.purple.withValues(alpha: 0.65),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _BackToLearningButton extends StatefulWidget {
  final bool expanded;

  const _BackToLearningButton({required this.expanded});

  @override
  State<_BackToLearningButton> createState() => _BackToLearningButtonState();
}

class _BackToLearningButtonState extends State<_BackToLearningButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.go('/learning'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minHeight: 46),
          padding: EdgeInsets.symmetric(
            horizontal: widget.expanded ? 14 : 10,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: _isHovered
                ? AppColors.accentGreen.withValues(alpha: 0.1)
                : Colors.transparent,
            border: Border.all(
              color: _isHovered
                  ? AppColors.accentGreen.withValues(alpha: 0.3)
                  : AppColors.glassBorder,
              width: 1,
            ),
          ),
          child: widget.expanded
              ? Row(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      color: _isHovered ? AppColors.accentGreen : AppColors.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Learning Workspace',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.label.copyWith(
                          color: _isHovered ? AppColors.accentGreen : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                )
              : Tooltip(
                  message: 'Learning Workspace',
                  child: Icon(
                    Icons.school_outlined,
                    color: _isHovered ? AppColors.accentGreen : AppColors.textMuted,
                    size: 22,
                  ),
                ),
        ),
      ),
    );
  }
}
