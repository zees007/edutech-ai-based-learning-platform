import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/providers/auth_provider.dart';
import '../../../../../core/providers/user_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../subscription/subscription_modal.dart';

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

    final userAsync = ref.read(userProvider);
    final tier = userAsync.value?.subscription?.tier.toLowerCase() ?? 'free';
    
    Widget? upgradeButton;
    if (tier == 'free') {
      upgradeButton = _buildMenuItem(
        context, 
        'Upgrade to PRO', 
        Icons.bolt, 
        AppColors.purple,
        onTap: () {
          showDialog(context: context, builder: (_) => const SubscriptionModal());
        },
      );
    } else if (tier == 'pro') {
      upgradeButton = _buildMenuItem(
        context, 
        'Upgrade to Ultra', 
        Icons.bolt, 
        AppColors.purple,
        onTap: () {
          showDialog(context: context, builder: (_) => const SubscriptionModal());
        },
      );
    }

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
                    ?upgradeButton,
                    _buildMenuItem(
                      context, 
                      'Manage Subscription', 
                      Icons.credit_card, 
                      AppColors.textSecondary,
                      onTap: () {
                        showDialog(context: context, builder: (_) => const SubscriptionModal());
                      },
                    ),
                    _buildMenuItem(
                      context, 
                      'Admin Console', 
                      Icons.admin_panel_settings, 
                      AppColors.textSecondary,
                      onTap: () {
                        context.go('/admin');
                      },
                    ),
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
    final userAsync = ref.watch(userProvider);
    
    if (userAsync.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.purple),
        ),
      );
    }
    
    final user = userAsync.value;
    if (user == null) {
      return const SizedBox.shrink();
    }
    
    final initials = user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '';
    final name = '${user.firstName} ${user.lastName}'.trim();
    final email = user.email;
    final plan = user.subscription?.tier != null ? '${user.subscription!.tier.toUpperCase()} MEMBER' : 'FREE MEMBER';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.purple.withValues(alpha: 0.2),
            child: Text(
              initials,
              style: AppTextStyles.h4.copyWith(
                color: AppColors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: AppTextStyles.subtitle1,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withValues(alpha: 0.1),
              border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
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
                const SizedBox(width: 6),
                Text(
                  plan,
                  style: AppTextStyles.badge.copyWith(
                    color: AppColors.accentGreen,
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
    final userAsync = ref.watch(userProvider);
    
    if (userAsync.isLoading || userAsync.value == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
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
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  color: AppColors.purple,
                  strokeWidth: 2,
                ),
              ),
            if (!widget.expanded)
              Container(
                key: _settingsIconKey,
                child: IconButton(
                  icon: const Icon(Icons.settings, color: AppColors.textMuted, size: 20),
                  onPressed: () => _showSettingsPopover(context),
                ),
              ),
          ],
        ),
      );
    }

    final user = userAsync.value!;
    final initials = user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '';
    final name = '${user.firstName} ${user.lastName}'.trim();
    final plan = user.subscription?.tier ?? 'Free';
    final planCapitalized = plan.isNotEmpty ? '${plan[0].toUpperCase()}${plan.substring(1).toLowerCase()} Plan' : 'Free Plan';

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
                initials,
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
                    name,
                    style: AppTextStyles.subtitle2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    planCapitalized,
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
