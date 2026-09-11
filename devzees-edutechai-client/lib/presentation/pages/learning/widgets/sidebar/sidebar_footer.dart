import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/providers/auth_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';

class SidebarFooter extends ConsumerStatefulWidget {
  final bool expanded;

  const SidebarFooter({
    super.key,
    required this.expanded,
  });

  @override
  ConsumerState<SidebarFooter> createState() => _SidebarFooterState();
}

class _SidebarFooterState extends ConsumerState<SidebarFooter> {
  final GlobalKey _settingsIconKey = GlobalKey();

  void _showSettingsPopover(BuildContext context) {
    final RenderBox renderBox = _settingsIconKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    showMenu<String>(
      context: context,
      color: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide.none,
      ),
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy - 280,
        MediaQuery.of(context).size.width - offset.dx - size.width,
        0,
      ),
      items: [
        PopupMenuItem<String>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                width: 220,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.popoverBackground.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildUserInfo(),
                    Divider(color: AppColors.glassBorder, height: 16),
                    _buildMenuItem(context, 'Upgrade to PRO', Icons.bolt, AppColors.purple),
                    _buildMenuItem(context, 'Billing & Plan', Icons.credit_card, AppColors.textSecondary),
                    _buildMenuItem(context, 'Admin Console', Icons.admin_panel_settings, AppColors.textSecondary),
                    Divider(color: AppColors.glassBorder, height: 16),
                    _buildMenuItem(
                      context, 
                      'Sign Out', 
                      Icons.logout, 
                      AppColors.rose.withValues(alpha: 0.8),
                      onTap: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          context.go('/auth');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.purple.withValues(alpha: 0.2),
            child: Text(
              'Z',
              style: AppTextStyles.label.copyWith(
                color: AppColors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Zeeshan',
                  style: AppTextStyles.subtitle2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withValues(alpha: 0.1),
                    border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'FREE MEMBER',
                        style: AppTextStyles.badge.copyWith(
                          color: AppColors.accentGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String label, IconData icon, Color color, {VoidCallback? onTap}) {
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: InkWell(
            onTap: () {
              Navigator.of(context).pop();
              if (onTap != null) onTap();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isHovered
                    ? AppColors.glassSurface.withValues(alpha: 0.05)
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: isHovered
                          ? AppTextStyles.label.copyWith(color: AppColors.textPrimary)
                          : AppTextStyles.label.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.glassBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: widget.expanded
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          if (widget.expanded)
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.purple.withValues(alpha: 0.2),
              child: Text(
                'Z',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (widget.expanded) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Zeeshan',
                    style: AppTextStyles.subtitle2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Free Plan',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
          Container(
            key: _settingsIconKey,
            child: IconButton(
              icon: Icon(Icons.settings, color: AppColors.textMuted, size: 20),
              onPressed: () => _showSettingsPopover(context),
            ),
          ),
        ],
      ),
    );
  }
}
