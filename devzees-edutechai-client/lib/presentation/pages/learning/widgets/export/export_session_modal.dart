import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/user_provider.dart';
import '../../../../../core/services/export_helper.dart';
import '../../../../../core/services/export_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import 'markdown_preview_dialog.dart';

class ExportSessionModal extends ConsumerStatefulWidget {
  final String sessionId;
  final String topic;
  final int totalSteps;
  final int stepsCompleted;
  final int xpEarned;
  final bool isCompleted;

  const ExportSessionModal({
    super.key,
    required this.sessionId,
    required this.topic,
    required this.totalSteps,
    required this.stepsCompleted,
    required this.xpEarned,
    this.isCompleted = false,
  });

  static void show(
    BuildContext context, {
    required String sessionId,
    required String topic,
    required int totalSteps,
    required int stepsCompleted,
    required int xpEarned,
    bool isCompleted = false,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (context) => ExportSessionModal(
        sessionId: sessionId,
        topic: topic,
        totalSteps: totalSteps,
        stepsCompleted: stepsCompleted,
        xpEarned: xpEarned,
        isCompleted: isCompleted,
      ),
    );
  }

  @override
  ConsumerState<ExportSessionModal> createState() => _ExportSessionModalState();
}

class _ExportSessionModalState extends ConsumerState<ExportSessionModal> {
  bool _isLoadingMd = false;
  bool _isLoadingPdf = false;
  String? _loadedMarkdown;

  bool get _isJourneyComplete =>
      widget.isCompleted ||
      (widget.totalSteps > 0 && widget.stepsCompleted >= widget.totalSteps);

  Future<void> _handlePreviewMarkdown() async {
    if (_isLoadingMd) return;
    setState(() => _isLoadingMd = true);
    try {
      final exportService = ref.read(exportServiceProvider);
      _loadedMarkdown ??= await exportService.fetchMarkdown(widget.sessionId);
      if (!mounted) return;
      MarkdownPreviewDialog.show(
        context,
        topic: widget.topic,
        markdownContent: _loadedMarkdown!,
        sessionId: widget.sessionId,
      );
    } catch (e) {
      if (!mounted) return;
      ExportHelper.showToast(
        context,
        message: e.toString().replaceAll('Exception: ', ''),
        icon: Icons.error_outline_rounded,
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoadingMd = false);
    }
  }

  Future<void> _handleCopyMarkdown() async {
    if (_isLoadingMd) return;
    setState(() => _isLoadingMd = true);
    try {
      final exportService = ref.read(exportServiceProvider);
      _loadedMarkdown ??= await exportService.fetchMarkdown(widget.sessionId);
      if (!mounted) return;
      await ExportHelper.copyToClipboard(
        context,
        text: _loadedMarkdown!,
        message: 'Markdown notes copied to clipboard!',
      );
    } catch (e) {
      if (!mounted) return;
      ExportHelper.showToast(
        context,
        message: e.toString().replaceAll('Exception: ', ''),
        icon: Icons.error_outline_rounded,
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoadingMd = false);
    }
  }

  Future<void> _handleDownloadMarkdown() async {
    if (_isLoadingMd) return;
    setState(() => _isLoadingMd = true);
    try {
      final exportService = ref.read(exportServiceProvider);
      _loadedMarkdown ??= await exportService.fetchMarkdown(widget.sessionId);
      if (!mounted) return;
      await ExportHelper.saveOrShareText(
        content: _loadedMarkdown!,
        filename: 'session_${widget.sessionId}.md',
        context: context,
      );
    } catch (e) {
      if (!mounted) return;
      ExportHelper.showToast(
        context,
        message: e.toString().replaceAll('Exception: ', ''),
        icon: Icons.error_outline_rounded,
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoadingMd = false);
    }
  }

  Future<void> _handleDownloadPdf() async {
    if (_isLoadingPdf) return;
    setState(() => _isLoadingPdf = true);
    try {
      final exportService = ref.read(exportServiceProvider);
      final bytes = await exportService.fetchPdf(widget.sessionId);
      if (!mounted) return;
      await ExportHelper.saveOrShareFile(
        bytes: bytes,
        filename: 'session_${widget.sessionId}.pdf',
        mimeType: 'application/pdf',
        context: context,
        successMessage: 'PDF Study Guide ready to open or share!',
      );
    } catch (e) {
      if (!mounted) return;
      ExportHelper.showToast(
        context,
        message: e.toString().replaceAll('Exception: ', ''),
        icon: Icons.error_outline_rounded,
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoadingPdf = false);
    }
  }

  void _showUpgradeInfo(BuildContext ctx, String format, String requiredTier) {
    showDialog(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_rounded, color: AppColors.accentAmber, size: 22),
            ),
            const SizedBox(width: 12),
            Text('Unlock $format Export', style: AppTextStyles.h3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exporting $format is an exclusive feature available on the $requiredTier tier.',
              style: AppTextStyles.body2.copyWith(color: AppColors.textSlate),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Upgrade to $requiredTier for unlimited exports, deep-dive academic search, and advanced AI models.',
                      style: AppTextStyles.caption.copyWith(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dCtx).pop(),
            child: const Text('Got it', style: TextStyle(color: AppColors.textMuted)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProvider).asData?.value;
    final privs = userProfile?.privilegeCodes ?? [];
    final bool isSuperAdmin = privs.contains('ET_ALL');
    final bool canExportMd = isSuperAdmin || privs.contains('ET_EXPORT_MARKDOWN');
    final bool canExportPdf = isSuperAdmin || privs.contains('ET_EXPORT_PDF');

    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 650;
    final isComplete = _isJourneyComplete;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 14 : 32,
          vertical: 24,
        ),
        child: Container(
          width: isMobile ? double.infinity : 600,
          decoration: BoxDecoration(
            gradient: AppColors.commandHubGradient,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isComplete
                  ? AppColors.cardGlowBorder
                  : AppColors.accentAmber.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 36,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: isComplete
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.accentAmber.withValues(alpha: 0.08),
                blurRadius: 24,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Top Header ──
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 18, 16),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceSolidHeader,
                    border: Border(
                      bottom: BorderSide(color: AppColors.glassBorder, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.25),
                              AppColors.indigo.withValues(alpha: 0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                        ),
                        child: const Icon(
                          Icons.ios_share_rounded,
                          color: AppColors.purpleLight,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Export Learning Journey',
                                  style: AppTextStyles.h3.copyWith(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                const Text('⚡', style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.topic,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // ── Modal Body ──
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Milestone Completion Badge / Warning ──
                      if (!isComplete)
                        _buildIncompleteWarning()
                      else
                        _buildCompletionSuccessBanner(),

                      const SizedBox(height: 18),

                      // ── Option 1: Markdown (.md) ──
                      _buildExportOptionCard(
                        icon: Icons.article_rounded,
                        iconColor: AppColors.cyanLight,
                        title: 'Markdown Notes (.md)',
                        description:
                            'Compact, structured study notes. Ideal for Obsidian, Notion, Typora, and GitHub.',
                        tierBadge: 'PRO / ULTRA',
                        isUnlocked: canExportMd,
                        isEnabled: isComplete,
                        isLoading: _isLoadingMd,
                        onPreview: _handlePreviewMarkdown,
                        onCopy: _handleCopyMarkdown,
                        onDownload: _handleDownloadMarkdown,
                        onLockedTap: () => _showUpgradeInfo(context, 'Markdown', 'Pro or Ultra'),
                      ),

                      const SizedBox(height: 14),

                      // ── Option 2: PDF Document (.pdf) ──
                      _buildExportOptionCard(
                        icon: Icons.picture_as_pdf_rounded,
                        iconColor: AppColors.rose,
                        title: 'PDF Study Guide (.pdf)',
                        description:
                            'Official executive study report with EduTechAI logo, quiz tables, and curated sources.',
                        tierBadge: 'ULTRA',
                        isUnlocked: canExportPdf,
                        isEnabled: isComplete,
                        isLoading: _isLoadingPdf,
                        isPdf: true,
                        onDownload: _handleDownloadPdf,
                        onLockedTap: () => _showUpgradeInfo(context, 'PDF', 'Ultra'),
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

  Widget _buildIncompleteWarning() {
    final pct = widget.totalSteps > 0
        ? (widget.stepsCompleted / widget.totalSteps * 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentAmber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentAmber.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.accentAmber, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Journey In Progress ($pct% Completed)',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.accentAmber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Export is only available once all milestone steps in your journey are completed. Please finish remaining steps (${widget.stepsCompleted}/${widget.totalSteps}) to generate your study guide.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSlate,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: widget.totalSteps > 0 ? widget.stepsCompleted / widget.totalSteps : 0.0,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentAmber),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionSuccessBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.emerald.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.emerald.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.emerald.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events_rounded, color: AppColors.emerald, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Journey 100% Mastered! 🎉',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.emerald,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'All ${widget.totalSteps} milestones finished • +${widget.xpEarned} XP earned',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOptionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String tierBadge,
    required bool isUnlocked,
    required bool isEnabled,
    required bool isLoading,
    bool isPdf = false,
    VoidCallback? onPreview,
    VoidCallback? onCopy,
    VoidCallback? onDownload,
    VoidCallback? onLockedTap,
  }) {
    final bool interactive = isUnlocked && isEnabled && !isLoading;

    return InkWell(
      onTap: !isEnabled
          ? null
          : !isUnlocked
              ? onLockedTap
              : null,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isUnlocked && isEnabled
                ? iconColor.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.1),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.label.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.5,
                            ),
                          ),
                          const Spacer(),
                          // Tier Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: isUnlocked
                                  ? AppColors.emerald.withValues(alpha: 0.15)
                                  : Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isUnlocked
                                    ? AppColors.emerald.withValues(alpha: 0.35)
                                    : Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!isUnlocked) ...[
                                  const Icon(Icons.lock_rounded, size: 10, color: AppColors.accentAmber),
                                  const SizedBox(width: 3),
                                ],
                                Text(
                                  tierBadge,
                                  style: AppTextStyles.badge.copyWith(
                                    fontSize: 9.5,
                                    color: isUnlocked ? AppColors.emerald : AppColors.textSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (isLoading) ...[
              const SizedBox(height: 14),
              const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            ] else if (isUnlocked && isEnabled) ...[
              const SizedBox(height: 12),
              const Divider(color: AppColors.glassBorder, height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isPdf && onPreview != null) ...[
                    OutlinedButton.icon(
                      onPressed: interactive ? onPreview : null,
                      icon: const Icon(Icons.visibility_rounded, size: 14),
                      label: const Text('Preview'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSlate,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (!isPdf && onCopy != null) ...[
                    OutlinedButton.icon(
                      onPressed: interactive ? onCopy : null,
                      icon: const Icon(Icons.copy_rounded, size: 14),
                      label: const Text('Copy'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accentCyan,
                        side: BorderSide(color: AppColors.accentCyan.withValues(alpha: 0.3)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  ElevatedButton.icon(
                    onPressed: interactive ? onDownload : null,
                    icon: const Icon(Icons.download_rounded, size: 14),
                    label: Text(isPdf ? 'Download PDF' : 'Download .md'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPdf ? AppColors.rose : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ] else if (!isUnlocked && isEnabled) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: onLockedTap,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Upgrade to $tierBadge to Unlock',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accentAmber,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.accentAmber),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
