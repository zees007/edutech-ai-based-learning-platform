import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../../../core/services/export_helper.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';

class MarkdownPreviewDialog extends StatelessWidget {
  final String topic;
  final String markdownContent;
  final String sessionId;

  const MarkdownPreviewDialog({
    super.key,
    required this.topic,
    required this.markdownContent,
    required this.sessionId,
  });

  static void show(BuildContext context, {
    required String topic,
    required String markdownContent,
    required String sessionId,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (context) => MarkdownPreviewDialog(
        topic: topic,
        markdownContent: markdownContent,
        sessionId: sessionId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 36,
          vertical: isMobile ? 16 : 32,
        ),
        child: Container(
          width: isMobile ? double.infinity : 820,
          height: isMobile ? size.height * 0.85 : size.height * 0.82,
          decoration: BoxDecoration(
            gradient: AppColors.commandHubGradient,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.cardGlowBorder,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 36,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 24,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              children: [
                // ── Header Bar ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceSolidHeader,
                    border: Border(
                      bottom: BorderSide(color: AppColors.glassBorder, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.article_rounded,
                          color: AppColors.purpleLight,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Markdown Notes Preview',
                              style: AppTextStyles.h3.copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              topic,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Copy Button
                      IconButton(
                        tooltip: 'Copy all to clipboard',
                        icon: const Icon(Icons.copy_all_rounded, color: AppColors.accentCyan),
                        onPressed: () {
                          ExportHelper.copyToClipboard(
                            context,
                            text: markdownContent,
                            message: 'Markdown notes copied to clipboard!',
                          );
                        },
                      ),
                      // Download / Share
                      IconButton(
                        tooltip: 'Save / Share file',
                        icon: const Icon(Icons.ios_share_rounded, color: AppColors.primary),
                        onPressed: () {
                          ExportHelper.saveOrShareText(
                            content: markdownContent,
                            filename: 'session_${sessionId}_notes.md',
                            context: context,
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      // Close
                      IconButton(
                        tooltip: 'Close',
                        icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // ── Rendered Markdown Body ──
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    child: Markdown(
                      data: markdownContent,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: AppTextStyles.bodyPrimary.copyWith(
                          fontSize: 13.5,
                          height: 1.6,
                          color: AppColors.textSlate,
                        ),
                        h1: AppTextStyles.h1.copyWith(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                        h2: AppTextStyles.h2.copyWith(
                          fontSize: 17,
                          color: AppColors.purpleLight,
                          fontWeight: FontWeight.bold,
                        ),
                        h3: AppTextStyles.h3.copyWith(
                          fontSize: 15,
                          color: AppColors.cyanLight,
                          fontWeight: FontWeight.w700,
                        ),
                        h4: AppTextStyles.label.copyWith(
                          fontSize: 13.5,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        blockquote: AppTextStyles.body2.copyWith(
                          color: AppColors.lavender,
                          fontStyle: FontStyle.italic,
                        ),
                        blockquoteDecoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border(
                            left: BorderSide(
                              color: AppColors.primary,
                              width: 3.5,
                            ),
                          ),
                        ),
                        code: const TextStyle(
                          color: AppColors.cyanLight,
                          backgroundColor: Color(0x33000000),
                          fontFamily: 'monospace',
                          fontSize: 12.5,
                        ),
                        tableBorder: TableBorder.all(
                          color: AppColors.glassBorder,
                          width: 1,
                        ),
                        tableHead: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        tableBody: AppTextStyles.body2.copyWith(
                          fontSize: 12.5,
                          color: AppColors.textSlate,
                        ),
                        horizontalRuleDecoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: AppColors.glassBorder,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Footer Bar ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceSolidHeader,
                    border: Border(
                      top: BorderSide(color: AppColors.glassBorder, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '⚡ Compatible with Obsidian, Notion & GitHub',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11.5,
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.download_rounded, size: 16),
                        label: const Text('Download .md'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          ExportHelper.saveOrShareText(
                            content: markdownContent,
                            filename: 'session_${sessionId}_notes.md',
                            context: context,
                          );
                        },
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
}
