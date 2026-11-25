import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/active_session_provider.dart';
import '../../../../../core/providers/learning_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../data/models/learning/session_model.dart';
import '../../../../widgets/center_toast.dart';
import 'package:devzees_edutechai_client/core/theme/theme_palette.dart';

/// Confirmation dialog shown before permanently deleting a learning session.
/// Informs the student of permanent data loss (lessons, notes, milestones, exports, scores).
class DeleteSessionConfirmationDialog extends ConsumerStatefulWidget {
  final SessionModel session;

  const DeleteSessionConfirmationDialog({super.key, required this.session});

  /// Static helper to display the modal dialog.
  static Future<bool?> show(
    BuildContext context, {
    required SessionModel session,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      barrierDismissible: true,
      builder: (ctx) => DeleteSessionConfirmationDialog(session: session),
    );

    if (result == true && context.mounted) {
      CenterToast.showSuccess(
        context,
        'Session "${session.topic}" deleted successfully.',
        title: 'Session Deleted',
      );
    }
    return result;
  }

  @override
  ConsumerState<DeleteSessionConfirmationDialog> createState() =>
      _DeleteSessionConfirmationDialogState();
}

class _DeleteSessionConfirmationDialogState
    extends ConsumerState<DeleteSessionConfirmationDialog> {
  bool _isDeleting = false;

  Future<void> _handleDelete() async {
    if (_isDeleting) return;

    setState(() => _isDeleting = true);

    final sessionId = widget.session.sessionId;

    try {
      final activeSessionId = ref
          .read(activeSessionProvider)
          .session
          ?.sessionId;
      final bool wasActive = activeSessionId == sessionId;

      final success = await ref
          .read(sessionsProvider.notifier)
          .deleteSession(sessionId);

      if (!mounted) return;

      if (!success) {
        setState(() => _isDeleting = false);
        CenterToast.showError(
          context,
          'Failed to delete session. Please try again.',
          title: 'Delete Failed',
        );
        return;
      }

      if (wasActive) {
        ref.read(activeSessionProvider.notifier).clearSession();
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      CenterToast.showError(
        context,
        'Failed to delete session: ${e.toString().replaceAll('Exception: ', '')}',
        title: 'Delete Failed',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.isDarkMode;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 550;

    final totalSteps =
        widget.session.totalSteps ?? widget.session.stepsCompleted;
    final completedSteps = widget.session.stepsCompleted;
    final formattedMode = widget.session.learningMode
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (w) => w.isNotEmpty
              ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}'
              : '',
        )
        .join(' ');

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 28,
          vertical: 24,
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131525) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.rose.withValues(alpha: isDark ? 0.35 : 0.28),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.rose.withValues(alpha: isDark ? 0.14 : 0.08),
                blurRadius: 36,
                spreadRadius: -4,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.55 : 0.14),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──
                Container(
                  padding: const EdgeInsets.fromLTRB(22, 20, 14, 18),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0x33F43F5E)
                        : const Color(0x0DF43F5E),
                    border: Border(
                      bottom: BorderSide(
                        color: isDark
                            ? context.appColors.border
                            : const Color(0xFFF1F5F9),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.rose.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.rose.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.delete_forever_rounded,
                          color: AppColors.rose,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delete Learning Session?',
                              style: AppTextStyles.subtitle1.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                color: context.appColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'This action is permanent and cannot be undone.',
                              style: AppTextStyles.caption.copyWith(
                                color: context.appColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        color: context.appColors.textSecondary,
                        onPressed: _isDeleting
                            ? null
                            : () => Navigator.of(context).pop(false),
                        tooltip: 'Cancel',
                      ),
                    ],
                  ),
                ),

                // ── Body ──
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Target Session Snapshot Card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1B1E34)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? context.appColors.border
                                  : const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Icon(
                                      Icons.school_outlined,
                                      size: 18,
                                      color: isDark
                                          ? AppColors.primary
                                          : const Color(0xFF1D4ED8),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      widget.session.topic,
                                      style: AppTextStyles.label.copyWith(
                                        color: context.appColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  if (formattedMode.isNotEmpty)
                                    _buildPill(
                                      icon: Icons.tune_rounded,
                                      label: formattedMode,
                                      color: isDark
                                          ? AppColors.purpleLight
                                          : AppColors.purpleDeep,
                                    ),
                                  _buildPill(
                                    icon: Icons.check_circle_outline_rounded,
                                    label: '$completedSteps/$totalSteps Steps',
                                    color: AppColors.accentGreen,
                                  ),
                                  _buildPill(
                                    icon: Icons.star_outline_rounded,
                                    label: '+${widget.session.xpEarned} XP',
                                    color: AppColors.accentAmber,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Impact Notice
                        Text(
                          'You will permanently lose:',
                          style: AppTextStyles.label.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: context.appColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),

                        _buildLossItem(
                          icon: Icons.route_rounded,
                          title: 'Milestone Steps & Lessons',
                          subtitle:
                              'All roadmap steps, AI discussions, and lesson interactions.',
                        ),
                        const SizedBox(height: 8),

                        _buildLossItem(
                          icon: Icons.sticky_note_2_outlined,
                          title: 'Study Notes & AI Explanations',
                          subtitle:
                              'Captured notes, summaries, and deep-dive concept explanations.',
                        ),
                        const SizedBox(height: 8),

                        _buildLossItem(
                          icon: Icons.quiz_outlined,
                          title: 'Quiz Scores & Session XP',
                          subtitle:
                              'Knowledge check assessments, submitted answers, and XP points.',
                        ),
                        const SizedBox(height: 8),

                        _buildLossItem(
                          icon: Icons.ios_share_rounded,
                          title: 'Export Documents',
                          subtitle:
                              'Access to download Markdown, PDF, or HTML exports for this topic.',
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Footer Action Buttons ──
                Container(
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF101220)
                        : const Color(0xFFFAFAFA),
                    border: Border(
                      top: BorderSide(
                        color: isDark
                            ? context.appColors.border
                            : const Color(0xFFF1F5F9),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Cancel Button
                      OutlinedButton(
                        onPressed: _isDeleting
                            ? null
                            : () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.appColors.textSecondary,
                          side: BorderSide(
                            color: isDark
                                ? context.appColors.border
                                : const Color(0xFFCBD5E1),
                            width: 1,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Keep Session',
                          style: AppTextStyles.button.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.appColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Delete Confirm Button
                      ElevatedButton(
                        onPressed: _isDeleting ? null : _handleDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.rose,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          disabledBackgroundColor: AppColors.rose.withValues(
                            alpha: 0.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isDeleting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Delete Session',
                                    style: AppTextStyles.button.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
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
          ),
        ),
      ),
    );
  }

  Widget _buildPill({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.badge.copyWith(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLossItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final bool isDark = context.isDarkMode;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.rose.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: AppColors.rose),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11.5,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
