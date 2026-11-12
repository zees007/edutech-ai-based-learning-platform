import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/providers/auth_provider.dart';
import '../../../../../core/providers/permission_provider.dart';
import '../../../../../core/providers/user_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/theme_palette.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/providers/theme_provider.dart';
import '../../../../widgets/account_settings_dialog.dart';

class SidebarFooter extends ConsumerStatefulWidget {
  final bool expanded;

  const SidebarFooter({super.key, required this.expanded});

  @override
  ConsumerState<SidebarFooter> createState() => _SidebarFooterState();
}

class _SidebarFooterState extends ConsumerState<SidebarFooter> {
  final GlobalKey _settingsIconKey = GlobalKey();

  void _showSettingsPopover(BuildContext context) {
    final RenderBox renderBox =
        _settingsIconKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final bool isDark = AppColors.isDark;

    final perms = ref.read(permissionProvider);
    final user = ref.read(authProvider).user ?? ref.read(userProvider).asData?.value;
    final sub = user?.subscription;
    final bool isSubActive = sub != null && sub.status.toLowerCase() == 'active';
    final roles = (user?.roles ?? []).map((r) => r.toLowerCase()).toList();

    final bool isAdmin = roles.contains('admin') || perms.isSuperAdmin;
    final bool isUltra = (isSubActive && sub.tier.toLowerCase() == 'ultra') || roles.contains('ultra');
    final bool isPro = (isSubActive && sub.tier.toLowerCase() == 'pro') || roles.contains('pro');

    Widget? upgradeButton;
    if (perms.canUpgradeSubscription && !isAdmin && !isUltra) {
      final label = isPro ? 'Upgrade to Ultra' : 'Upgrade to PRO';
      upgradeButton = _buildMenuItem(
        context,
        label,
        Icons.bolt_rounded,
        AppColors.accentAmber,
        onTap: () {
          context.push('/subscription');
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
        math.max(16.0, offset.dy - 400),
        MediaQuery.of(context).size.width - offset.dx - size.width,
        0,
      ),
      items: [
        PopupMenuItem<String>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: IconTheme(
            data: const IconThemeData(opacity: 1.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                width: 240,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.popoverBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.glassBorder,
                    width: 1.0,
                  ),
                  boxShadow: context.appColors.cardShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildUserInfo(context),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Divider(
                        color: AppColors.glassBorder,
                        height: 12,
                      ),
                    ),
                    _buildMenuItem(
                      context,
                      'Account Settings',
                      Icons.person_outline_rounded,
                      isDark ? AppColors.blueSoft : AppColors.primary,
                      onTap: () {
                        AccountSettingsDialog.show(context, initialTab: 0);
                      },
                    ),
                    _buildMenuItem(
                      context,
                      'Change Password',
                      Icons.lock_reset_rounded,
                      isDark ? AppColors.blueSoft : AppColors.primary,
                      onTap: () {
                        AccountSettingsDialog.show(context, initialTab: 1);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Divider(
                        color: AppColors.glassBorder,
                        height: 12,
                      ),
                    ),
                    ?upgradeButton,
                    _buildMenuItem(
                      context,
                      'Manage Subscription',
                      Icons.credit_card_rounded,
                      isDark ? AppColors.blueSoft : AppColors.primary,
                      onTap: () {
                        context.push('/subscription');
                      },
                    ),
                    if (perms.isAdmin)
                      _buildMenuItem(
                        context,
                        'Admin Console',
                        Icons.admin_panel_settings_rounded,
                        isDark ? AppColors.blueSoft : AppColors.primary,
                        onTap: () {
                          context.go('/admin');
                        },
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Divider(
                        color: AppColors.glassBorder,
                        height: 12,
                      ),
                    ),
                    _buildMenuItem(
                      context,
                      isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme',
                      isDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      isDark ? AppColors.accentAmber : AppColors.accentViolet,
                      onTap: () {
                        ref.read(themeModeProvider.notifier).toggleTheme();
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Divider(
                        color: AppColors.glassBorder,
                        height: 12,
                      ),
                    ),
                    _buildMenuItem(
                      context,
                      'Sign Out',
                      Icons.logout_rounded,
                      AppColors.rose,
                      textColor: AppColors.rose,
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
      ),
    ],
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final bool isDark = AppColors.isDark;

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

    final initials = user.firstName.isNotEmpty
        ? user.firstName[0].toUpperCase()
        : '';
    final name = '${user.firstName} ${user.lastName}'.trim();
    final email = user.email;
    final plan = user.subscription?.tier != null
        ? '${user.subscription!.tier.toUpperCase()} MEMBER'
        : 'FREE MEMBER';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
          AccountSettingsDialog.show(context, initialTab: 0);
        },
        child: Tooltip(
          message: 'Edit Profile & Settings',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
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
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceSubtle : AppColors.cardBackground,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.glassBorder,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          size: 11,
                          color: isDark ? AppColors.blueSoft : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
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
                    border: Border.all(
                      color: AppColors.accentGreen.withValues(alpha: 0.3),
                    ),
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
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String label,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
    Color? textColor,
  }) {
    bool isHovered = false;
    final bool isDark = AppColors.isDark;

    return StatefulBuilder(
      builder: (context, setItemState) {
        final Color hoverBg = isDark
            ? Colors.white.withValues(alpha: 0.08)
            : AppColors.primary.withValues(alpha: 0.08);

        // Dark primary blue in light mode for crisp contrast against light blue hover background
        final Color darkPrimary =
            isDark ? AppColors.textPrimary : AppColors.blueRoyal;

        final Color activeHoverColor = textColor ?? darkPrimary;

        final Color targetIconColor = isHovered ? activeHoverColor : color;

        final Color targetTextColor = isHovered
            ? activeHoverColor
            : (textColor ??
                (isDark ? AppColors.slate200 : AppColors.slate700));

        return MouseRegion(
          onEnter: (_) => setItemState(() => isHovered = true),
          onExit: (_) => setItemState(() => isHovered = false),
          child: InkWell(
            onTap: () {
              Navigator.of(context).pop();
              if (onTap != null) onTap();
            },
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isHovered ? hoverBg : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconTheme(
                    data: const IconThemeData(opacity: 1.0),
                    child: Icon(
                      icon,
                      color: targetIconColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOut,
                      style: AppTextStyles.label.copyWith(
                        color: targetTextColor,
                        fontWeight: isHovered ? FontWeight.w600 : FontWeight.w500,
                      ),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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

  Widget _buildSettingsButton(BuildContext context) {
    bool isHovered = false;
    final bool isDark = AppColors.isDark;

    return StatefulBuilder(
      builder: (context, setBtnState) {
        return MouseRegion(
          onEnter: (_) => setBtnState(() => isHovered = true),
          onExit: (_) => setBtnState(() => isHovered = false),
          child: Tooltip(
            message: 'Settings & Profile',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                key: _settingsIconKey,
                onTap: () => _showSettingsPopover(context),
                customBorder: const CircleBorder(),
                hoverColor: Colors.transparent,
                splashColor: (isDark ? Colors.white : AppColors.primary)
                    .withValues(alpha: 0.12),
                highlightColor: Colors.transparent,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isHovered
                        ? (isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : AppColors.primary.withValues(alpha: 0.08))
                        : Colors.transparent,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.settings_rounded,
                      color: isHovered
                          ? (isDark ? AppColors.textPrimary : AppColors.blueRoyal)
                          : (isDark
                              ? AppColors.textSecondary
                              : AppColors.slate600),
                      size: 20,
                    ),
                  ),
                ),
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
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.glassBorder, width: 1),
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
            if (!widget.expanded) _buildSettingsButton(context),
          ],
        ),
      );
    }

    final user = userAsync.value!;
    final initials = user.firstName.isNotEmpty
        ? user.firstName[0].toUpperCase()
        : '';
    final name = '${user.firstName} ${user.lastName}'.trim();
    final plan = user.subscription?.tier ?? 'Free';
    final planCapitalized = plan.isNotEmpty
        ? '${plan[0].toUpperCase()}${plan.substring(1).toLowerCase()} Plan'
        : 'Free Plan';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.glassBorder, width: 1)),
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
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
          _buildSettingsButton(context),
        ],
      ),
    );
  }
}
