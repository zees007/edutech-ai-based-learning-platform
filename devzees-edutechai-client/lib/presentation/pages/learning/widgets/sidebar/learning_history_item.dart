import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../data/models/learning/session_model.dart';
import '../../../../../core/providers/learning_provider.dart';
import '../../../../../core/providers/active_session_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../export/export_session_modal.dart';

class LearningHistoryItem extends ConsumerStatefulWidget {
  final SessionModel session;
  final int index;
  final bool expanded;

  const LearningHistoryItem({
    super.key,
    required this.session,
    required this.index,
    required this.expanded,
  });

  @override
  ConsumerState<LearningHistoryItem> createState() => _LearningHistoryItemState();
}

class _LearningHistoryItemState extends ConsumerState<LearningHistoryItem> {
  bool _isHovered = false;
  bool _isDotsHovered = false;
  final GlobalKey _menuKey = GlobalKey();

  Widget _buildPopoverAction({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    bool isHovered = false;
    final bool isDark = AppColors.isDark;

    return StatefulBuilder(
      builder: (context, setActionState) {
        final Color hoverBg = isDark
            ? Colors.white.withValues(alpha: 0.08)
            : AppColors.primary.withValues(alpha: 0.08);

        final Color targetIconColor = isHovered
            ? (isDark ? AppColors.textPrimary : iconColor)
            : iconColor;

        final Color targetTextColor = isHovered
            ? (isDark ? AppColors.textPrimary : textColor)
            : textColor;

        return MouseRegion(
          onEnter: (_) => setActionState(() => isHovered = true),
          onExit: (_) => setActionState(() => isHovered = false),
          child: InkWell(
            onTap: () {
              Navigator.of(context).pop();
              onTap();
            },
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: isHovered ? hoverBg : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconTheme(
                    data: const IconThemeData(opacity: 1.0),
                    child: Icon(icon, color: targetIconColor, size: 18),
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

  void _showActionMenu() {
    final RenderBox renderBox = _menuKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final bool isDark = AppColors.isDark;

    showMenu<String>(
      context: context,
      color: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide.none,
      ),
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height + 4,
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
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                width: 145,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.popoverBackground.withValues(alpha: 0.85)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isDark
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : const [
                          BoxShadow(
                            color: Color(0x18000000),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                            spreadRadius: 0,
                          ),
                        ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPopoverAction(
                      context: context,
                      label: 'Export',
                      icon: Icons.ios_share_rounded,
                      iconColor: isDark ? AppColors.purpleLight : AppColors.adaptivePurpleLight,
                      textColor: isDark ? AppColors.textPrimary : const Color(0xFF1E293B),
                      onTap: () {
                        final total = widget.session.totalSteps ?? widget.session.stepsCompleted;
                        final bool isCompleted = total > 0 && widget.session.stepsCompleted >= total;
                        ExportSessionModal.show(
                          context,
                          sessionId: widget.session.sessionId,
                          topic: widget.session.topic,
                          totalSteps: total,
                          stepsCompleted: widget.session.stepsCompleted,
                          xpEarned: widget.session.xpEarned,
                          isCompleted: isCompleted,
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Divider(
                        color: isDark
                            ? AppColors.glassBorder
                            : const Color(0xFFF1F5F9),
                        height: 1,
                        thickness: 1,
                      ),
                    ),
                    _buildPopoverAction(
                      context: context,
                      label: 'Delete',
                      icon: Icons.delete_outline_rounded,
                      iconColor: AppColors.rose,
                      textColor: AppColors.rose,
                      onTap: () {
                        ref.read(sessionsProvider.notifier).deleteSession(widget.session.sessionId);
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

  @override
  Widget build(BuildContext context) {
    final activeSessionId = ref.watch(activeSessionProvider).session?.sessionId;
    final bool isActive = activeSessionId != null && activeSessionId == widget.session.sessionId;

    if (!widget.expanded) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: InkWell(
          onTap: () {
            ref.read(activeSessionProvider.notifier).loadSession(widget.session.sessionId);
            // Close drawer if on mobile
            if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
              Scaffold.of(context).closeDrawer();
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.20)
                  : AppColors.glassSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.45)
                    : Colors.transparent,
                width: 1,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              Icons.history,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              size: 18,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          onTap: () {
            ref.read(activeSessionProvider.notifier).loadSession(widget.session.sessionId);
            // Close drawer if on mobile
            if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
              Scaffold.of(context).closeDrawer();
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.14)
                  : (_isHovered ? AppColors.primary.withValues(alpha: 0.05) : Colors.transparent),
              border: Border.all(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.38)
                    : (_isHovered ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent),
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  isActive ? Icons.chat_bubble : Icons.chat_bubble_outline,
                  color: isActive
                      ? AppColors.primary
                      : (_isHovered ? AppColors.primary.withValues(alpha: 0.8) : AppColors.textMuted.withValues(alpha: 0.6)),
                  size: 16,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.session.topic,
                        style: AppTextStyles.label.copyWith(
                          color: (isActive || _isHovered) ? AppColors.textPrimary : AppColors.textSecondary,
                          fontWeight: (isActive || _isHovered) ? FontWeight.w600 : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildBadge(
                              Icons.check_circle_outline,
                              '${widget.session.stepsCompleted}/${widget.session.totalSteps ?? widget.session.stepsCompleted} Steps',
                              AppColors.accentGreen),
                          const SizedBox(width: 8),
                          _buildBadge(Icons.star_outline, '${widget.session.xpEarned} XP', AppColors.accentAmber),
                        ],
                      ),
                    ],
                  ),
                ),
                MouseRegion(
                  onEnter: (_) => setState(() => _isDotsHovered = true),
                  onExit: (_) => setState(() => _isDotsHovered = false),
                  child: Container(
                    key: _menuKey,
                    child: InkWell(
                      onTap: _showActionMenu,
                      borderRadius: BorderRadius.circular(6),
                      hoverColor: Colors.transparent,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: _isDotsHovered
                              ? (AppColors.isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : AppColors.primary.withValues(alpha: 0.1))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.more_vert_rounded,
                          color: _isDotsHovered
                              ? (AppColors.isDark ? AppColors.textPrimary : AppColors.primary)
                              : ((isActive || _isHovered)
                                  ? AppColors.textSecondary
                                  : AppColors.textMuted.withValues(alpha: 0.4)),
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.badge.copyWith(
              color: color,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
