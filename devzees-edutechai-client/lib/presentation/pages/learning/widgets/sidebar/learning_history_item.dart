import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../data/models/learning/session_model.dart';
import '../../../../../core/providers/learning_provider.dart';
import '../../../../../core/providers/active_session_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';

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
  final GlobalKey _menuKey = GlobalKey();

  void _showActionMenu() {
    final RenderBox renderBox = _menuKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

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
        offset.dy + size.height,
        MediaQuery.of(context).size.width - offset.dx - size.width,
        0,
      ),
      items: [
        PopupMenuItem<String>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                width: 140,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.popoverBackground.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        ref.read(sessionsProvider.notifier).deleteSession(widget.session.sessionId);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: AppColors.rose, size: 18),
                            const SizedBox(width: 12),
                            Text(
                              'Delete',
                              style: AppTextStyles.label.copyWith(color: AppColors.rose),
                            ),
                          ],
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
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
              color: AppColors.glassSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.history,
              color: AppColors.textSecondary,
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
              color: _isHovered ? AppColors.primary.withValues(alpha: 0.05) : Colors.transparent,
              border: Border.all(
                color: _isHovered ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: _isHovered ? AppColors.primary.withValues(alpha: 0.8) : AppColors.textMuted.withValues(alpha: 0.6),
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
                          color: _isHovered ? AppColors.textPrimary : AppColors.textSecondary,
                          fontWeight: _isHovered ? FontWeight.w600 : FontWeight.normal,
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
                Container(
                  key: _menuKey,
                  child: InkWell(
                    onTap: _showActionMenu,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.more_vert, 
                        color: _isHovered ? AppColors.textSecondary : AppColors.textMuted.withValues(alpha: 0.4), 
                        size: 16,
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
