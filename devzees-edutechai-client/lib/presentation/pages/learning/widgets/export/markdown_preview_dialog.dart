import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/services/export_helper.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../workspace/keep_alive_wrapper.dart';
import '../workspace/mermaid_web_view.dart';

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

  static void show(
    BuildContext context, {
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
    final processedContent = _preprocessMarkdownForPreview(markdownContent);

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
          height: isMobile ? size.height * 0.88 : size.height * 0.82,
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
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 14 : 20,
                    vertical: isMobile ? 10 : 14,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceSolidHeader,
                    border: Border(
                      bottom: BorderSide(color: AppColors.glassBorder, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isMobile ? 6 : 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Icon(
                          Icons.article_rounded,
                          color: AppColors.purpleLight,
                          size: isMobile ? 18 : 20,
                        ),
                      ),
                      SizedBox(width: isMobile ? 8 : 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Markdown Notes Preview',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.h3.copyWith(
                                fontSize: isMobile ? 15 : 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              topic,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: isMobile ? 11.5 : 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Copy Button
                      IconButton(
                        tooltip: 'Copy all to clipboard',
                        padding: isMobile ? const EdgeInsets.all(4) : const EdgeInsets.all(8),
                        constraints: isMobile ? const BoxConstraints(minWidth: 32, minHeight: 32) : null,
                        visualDensity: isMobile ? VisualDensity.compact : VisualDensity.standard,
                        icon: Icon(
                          Icons.copy_all_rounded,
                          color: AppColors.accentCyan,
                          size: isMobile ? 18 : 20,
                        ),
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
                        padding: isMobile ? const EdgeInsets.all(4) : const EdgeInsets.all(8),
                        constraints: isMobile ? const BoxConstraints(minWidth: 32, minHeight: 32) : null,
                        visualDensity: isMobile ? VisualDensity.compact : VisualDensity.standard,
                        icon: Icon(
                          Icons.ios_share_rounded,
                          color: AppColors.primary,
                          size: isMobile ? 18 : 20,
                        ),
                        onPressed: () {
                          ExportHelper.saveOrShareText(
                            content: markdownContent,
                            filename: 'session_${sessionId}_notes.md',
                            context: context,
                          );
                        },
                      ),
                      if (!isMobile) const SizedBox(width: 4),
                      // Close
                      IconButton(
                        tooltip: 'Close',
                        padding: isMobile ? const EdgeInsets.all(4) : const EdgeInsets.all(8),
                        constraints: isMobile ? const BoxConstraints(minWidth: 32, minHeight: 32) : null,
                        visualDensity: isMobile ? VisualDensity.compact : VisualDensity.standard,
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppColors.textMuted,
                          size: isMobile ? 18 : 20,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // ── Rendered Markdown Body ──
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(isMobile ? 14 : 24),
                    child: Markdown(
                      data: processedContent,
                      selectable: true,
                      onTapLink: (text, href, title) {
                        if (href != null) launchUrl(Uri.parse(href));
                      },
                      builders: {'code': _MarkdownPreviewCodeBuilder()},
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
                        h1Padding: const EdgeInsets.only(bottom: 12, top: 8),
                        h2: AppTextStyles.h2.copyWith(
                          fontSize: 17,
                          color: AppColors.purpleLight,
                          fontWeight: FontWeight.bold,
                        ),
                        h2Padding: const EdgeInsets.only(bottom: 10, top: 12),
                        h3: AppTextStyles.h3.copyWith(
                          fontSize: 15,
                          color: AppColors.cyanLight,
                          fontWeight: FontWeight.w700,
                        ),
                        h3Padding: const EdgeInsets.only(bottom: 8, top: 10),
                        h4: AppTextStyles.label.copyWith(
                          fontSize: 13.5,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        h4Padding: const EdgeInsets.only(bottom: 6, top: 8),
                        blockquote: AppTextStyles.body2.copyWith(
                          color: AppColors.lavender,
                          fontStyle: FontStyle.italic,
                        ),
                        blockquoteDecoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: const Border(
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
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 14 : 20,
                    vertical: isMobile ? 10 : 12,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceSolidHeader,
                    border: Border(
                      top: BorderSide(color: AppColors.glassBorder, width: 1),
                    ),
                  ),
                  child: isMobile
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.download_rounded, size: 16),
                              label: const Text('Download .md'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 11,
                                ),
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
                            const SizedBox(height: 6),
                            Center(
                              child: Text(
                                '⚡ Compatible with Obsidian, Notion & GitHub',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 10.5,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '⚡ Compatible with Obsidian, Notion & GitHub',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.download_rounded, size: 16),
                              label: const Text('Download .md'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
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

// ═══════════════════════════════════════════════════════════════════
// Markdown Preprocessing for Preview
// ═══════════════════════════════════════════════════════════════════

String _preprocessMarkdownForPreview(String text) {
  // 1. Protect existing fenced code blocks (```...```) so we don't double-process them
  final codeBlocks = <String>[];
  var processed = text.replaceAllMapped(RegExp(r'```[\s\S]*?```'), (m) {
    codeBlocks.add(m.group(0)!);
    return '@@PREVIEW_CODEBLOCK_${codeBlocks.length - 1}@@';
  });

  // 2. Wrap unfenced mermaid diagrams (e.g. lines starting with graph TD / flowchart / sequenceDiagram etc.)
  processed = processed.replaceAllMapped(
    RegExp(
      r'(?:^|\n\n)(graph\s+[A-Z]{2}|flowchart\s+[A-Z]{2}|sequenceDiagram|classDiagram|stateDiagram(?:-v2)?|erDiagram|gantt|pie|mindmap|gitGraph)([\s\S]*?)(?=(?:\r?\n\s*\r?\n\S)|(?:\r?\n\s*\r?\n#)|$)',
      caseSensitive: false,
    ),
    (match) => '\n\n```mermaid\n${match.group(1)}${match.group(2)}\n```\n\n',
  );

  // 3. Block math: \begin{...} ... \end{...}
  processed = processed.replaceAllMapped(
    RegExp(
      r'(?:\\\[|\[)?\s*(\\begin\{(?:aligned|matrix|bmatrix|pmatrix|vmatrix|cases|gather|equation)\b[\s\S]+?\\end\{(?:aligned|matrix|bmatrix|pmatrix|vmatrix|cases|gather|equation)\})\s*(?:\\\]|\])?',
      multiLine: true,
    ),
    (match) => '\n```latex\n${match.group(1)}\n```\n',
  );

  // 4. Block math: \[ ... \]
  processed = processed.replaceAllMapped(
    RegExp(r'\\\[([\s\S]+?)\\\]'),
    (match) => '\n```latex\n${match.group(1)}\n```\n',
  );

  // 5. Block math: $$ ... $$
  processed = processed.replaceAllMapped(
    RegExp(r'\$\$([\s\S]+?)\$\$'),
    (match) => '\n```latex\n${match.group(1)}\n```\n',
  );

  // 6. Inline math: \( ... \)
  processed = processed.replaceAllMapped(
    RegExp(r'\\\(([\s\S]+?)\\\)'),
    (match) => '`math:${match.group(1)}`',
  );

  // 7. Inline math with single $
  processed = processed.replaceAllMapped(
    RegExp(r'(?<!\$)\$(?!\$)([\s\S]+?)(?<!\$)\$(?!\$)'),
    (match) => '`math:${match.group(1)}`',
  );

  // 8. Restore protected code blocks
  for (int i = 0; i < codeBlocks.length; i++) {
    processed = processed.replaceAll('@@PREVIEW_CODEBLOCK_$i@@', codeBlocks[i]);
  }

  return processed;
}

// ═══════════════════════════════════════════════════════════════════
// Custom Code Block Builder — Intercepts mermaid and math blocks
// ═══════════════════════════════════════════════════════════════════

class _MarkdownPreviewCodeBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(element, preferredStyle) {
    final textContent = element.textContent;

    // 1. Inline Math
    if (textContent.startsWith('math:')) {
      final mathTex = textContent.substring(5).trim();
      return Math.tex(
        _sanitizeMathTex(mathTex),
        mathStyle: MathStyle.text,
        textStyle: preferredStyle?.copyWith(color: Colors.white, fontSize: 14),
        onErrorFallback: (err) => Text(
          mathTex,
          style: preferredStyle?.copyWith(color: AppColors.lavender),
        ),
      );
    }

    // 2. Block Math
    final className = element.attributes['class'] ?? '';
    final isLatexBlock = className.contains('language-latex') ||
        className.contains('language-math');

    if (isLatexBlock) {
      return _buildMathCard(textContent);
    }

    // 3. Mermaid Diagrams (guaranteed untouched and prioritized for any mermaid code block)
    final isMermaidBlock = className.contains('language-mermaid') ||
        className.contains('language-flowchart');
    final trimmed = textContent.trimLeft();

    if (isMermaidBlock ||
        trimmed.startsWith('graph ') ||
        trimmed.startsWith('graph\n') ||
        trimmed.startsWith('flowchart ') ||
        trimmed.startsWith('flowchart\n') ||
        trimmed.startsWith('sequenceDiagram') ||
        trimmed.startsWith('classDiagram') ||
        trimmed.startsWith('stateDiagram') ||
        trimmed.startsWith('erDiagram') ||
        trimmed.startsWith('gantt') ||
        trimmed.startsWith('pie') ||
        trimmed.startsWith('mindmap') ||
        trimmed.startsWith('gitGraph') ||
        ((trimmed.contains('-->') || trimmed.contains('---')) &&
            trimmed.contains('['))) {
      return KeepAliveWrapper(
        child: MermaidWebView(code: textContent.trim()),
      );
    }

    // 4. Code Snippet Blocks with Copy Icon
    final hasLanguage = className.contains('language-');
    final isMultiLine = textContent.contains('\n');

    if (hasLanguage || isMultiLine) {
      var code = textContent;
      if (code.endsWith('\n')) {
        code = code.substring(0, code.length - 1);
      }
      return _CodeSnippetCard(code: code);
    }

    return null;
  }
}

// ═══════════════════════════════════════════════════════════════════
// Math Sanitization & Card Widget
// ═══════════════════════════════════════════════════════════════════

String _sanitizeMathTex(String rawTex) {
  var clean = rawTex.trim();
  clean = clean.replaceAll(r'\!', '');
  clean = clean.replaceAll(RegExp(r',\s*\\+'), r' \\ ');
  clean = clean.replaceAll(RegExp(r',\s*&\s*'), r' \\ ');
  clean = clean.replaceAll(RegExp(r'\\{2,}(?:\s*\\+)*'), r'\\');
  clean = clean.replaceAll(RegExp(r'\\+\s*(?=\\end\{)'), '\n');
  clean = clean.replaceAll(RegExp(r'(?<!\\)\\\s*(?=\r?\n|$)'), '');
  return clean.trim();
}

Widget _buildMathCard(String tex) {
  final cleanTex = _sanitizeMathTex(tex);
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: AppColors.surfaceDark.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.glassBorderSubtle),
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Math.tex(
        cleanTex,
        mathStyle: MathStyle.display,
        textStyle: const TextStyle(color: Colors.white, fontSize: 15),
        onErrorFallback: (err) => Text(
          cleanTex,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontFamily: 'monospace',
            fontSize: 13,
          ),
        ),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════
// Code Snippet Card with Copy Action
// ═══════════════════════════════════════════════════════════════════

class _CodeSnippetCard extends StatefulWidget {
  final String code;

  const _CodeSnippetCard({required this.code});

  @override
  State<_CodeSnippetCard> createState() => _CodeSnippetCardState();
}

class _CodeSnippetCardState extends State<_CodeSnippetCard> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  bool _copied = false;
  Timer? _copyTimer;

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    _copyTimer?.cancel();
    super.dispose();
  }

  void _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    setState(() => _copied = true);
    _copyTimer?.cancel();
    _copyTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _copied = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      constraints: const BoxConstraints(maxHeight: 380),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          ScrollbarTheme(
            data: ScrollbarThemeData(
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.dragged) ||
                    states.contains(WidgetState.hovered)) {
                  return const Color(0xFF475569).withValues(alpha: 0.90);
                }
                return const Color(0xFF334155).withValues(alpha: 0.55);
              }),
              thickness: const WidgetStatePropertyAll(4),
              radius: const Radius.circular(3),
            ),
            child: Scrollbar(
              controller: _verticalController,
              thumbVisibility: false,
              child: Scrollbar(
                controller: _horizontalController,
                notificationPredicate: (notif) => notif.depth == 1,
                thumbVisibility: false,
                child: SingleChildScrollView(
                  controller: _verticalController,
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 48, 14),
                  child: SingleChildScrollView(
                    controller: _horizontalController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: SelectableText(
                      widget.code,
                      style: const TextStyle(
                        color: AppColors.cyanLight,
                        fontFamily: 'monospace',
                        fontSize: 12.5,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: Tooltip(
              message: _copied ? 'Copied!' : 'Copy Code',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _copy,
                  borderRadius: BorderRadius.circular(6),
                  hoverColor: Colors.white.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      _copied ? Icons.check_rounded : Icons.copy_rounded,
                      size: 16,
                      color: _copied ? AppColors.emerald : AppColors.textSlate,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
