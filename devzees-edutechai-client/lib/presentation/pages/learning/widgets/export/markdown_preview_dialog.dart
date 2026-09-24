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
                        codeblockDecoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        codeblockPadding: EdgeInsets.zero,
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
  // Normalize Windows CRLF to standard LF so regexes match reliably
  var processed = text.replaceAll('\r\n', '\n');

  // 1. Standardize existing code fences: ```flowchart -> ```mermaid, and bare ``` followed by diagram
  processed = processed.replaceAllMapped(
    RegExp(
      r'```(?:flowchart)?\s*\n\s*(graph\s+[A-Za-z]{2}|flowchart\s+[A-Za-z]{2}|sequenceDiagram|classDiagram|stateDiagram)',
      caseSensitive: false,
    ),
    (m) => '```mermaid\n${m.group(1)}',
  );

  // 2. Protect existing fenced code blocks (```...```) so we don't double-process them
  final codeBlocks = <String>[];
  processed = processed.replaceAllMapped(RegExp(r'```[\s\S]*?```'), (m) {
    codeBlocks.add(m.group(0)!);
    return '@@PREVIEW_CODEBLOCK_${codeBlocks.length - 1}@@';
  });

  // 3. Wrap unfenced mermaid diagrams (e.g. lines starting with graph TD / flowchart / sequenceDiagram etc.)
  processed = processed.replaceAllMapped(
    RegExp(
      r'(?:^|\n\n)(graph\s+[A-Za-z]{2}|flowchart\s+[A-Za-z]{2}|sequenceDiagram|classDiagram|stateDiagram(?:-v2)?|erDiagram|gantt|pie|mindmap|gitGraph)([\s\S]*?)(?=(?:\n\s*\n\S)|(?:\n\s*\n#)|$)',
      caseSensitive: false,
    ),
    (match) => '\n\n```mermaid\n${match.group(1)}${match.group(2)}\n```\n\n',
  );

  // 4. Block math: \begin{...} ... \end{...} (with optional enclosing [ ... ] or \[ ... \])
  processed = processed.replaceAllMapped(
    RegExp(
      r'(?:\\\[|\[)?\s*(\\begin\{(?:aligned|matrix|bmatrix|pmatrix|vmatrix|Vmatrix|cases|gather|gather\*|equation|equation\*|align|align\*|alignat|alignat\*|split|multline|multline*)\b[\s\S]+?\\end\{(?:aligned|matrix|bmatrix|pmatrix|vmatrix|Vmatrix|cases|gather|gather\*|equation|equation\*|align|align\*|alignat|alignat\*|split|multline|multline*)\})\s*(?:\\\]|\])?',
      multiLine: true,
    ),
    (match) => '\n\n```latex\n${match.group(1)!.trim()}\n```\n\n',
  );

  // 5. Block math: \[ ... \]
  processed = processed.replaceAllMapped(
    RegExp(r'\\\[([\s\S]+?)\\\]'),
    (match) => '\n\n```latex\n${match.group(1)!.trim()}\n```\n\n',
  );

  // 6. Block math: $$ ... $$
  processed = processed.replaceAllMapped(
    RegExp(r'\$\$([\s\S]+?)\$\$'),
    (match) => '\n\n```latex\n${match.group(1)!.trim()}\n```\n\n',
  );

  // 7. Inline math: \( ... \)
  processed = processed.replaceAllMapped(
    RegExp(r'\\\(([\s\S]+?)\\\)'),
    (match) => '`math:${match.group(1)!.trim()}`',
  );

  // 8. Inline math with single $ (excluding currency like $50 or $$)
  processed = processed.replaceAllMapped(
    RegExp(r'(?<![\$\\0-9])\$(?!\s)(.+?)(?<!\s)\$(?![0-9\$])'),
    (match) => '`math:${match.group(1)!.trim()}`',
  );

  // 9. Parenthesized equation fallback from LLMs: ( \mathbf{...} ) or ( L=T-V )
  processed = processed.replaceAllMapped(
    RegExp(
      r'(?<!\S)\(\s*(\\[a-zA-Z]+[\s\S]*?|[a-zA-Z0-9_]+=[a-zA-Z0-9_+-]+)\s*\)(?=[,\.;:!?]|\s|$)',
    ),
    (match) => '`math:${match.group(1)!.trim()}`',
  );

  // 10. Restore protected code blocks
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
      final cleanTex = _sanitizeMathTex(mathTex);
      return Math.tex(
        cleanTex,
        mathStyle: MathStyle.text,
        textStyle: preferredStyle?.copyWith(color: Colors.white, fontSize: 14),
        onErrorFallback: (err) => Text(
          cleanTex,
          style: preferredStyle?.copyWith(color: AppColors.lavender),
        ),
      );
    }

    // 2. Block Math
    final className = element.attributes['class'] ?? '';
    final isLatexBlock = className.contains('language-latex') ||
        className.contains('language-math') ||
        className.contains('language-tex') ||
        className.contains('language-katex');

    if (isLatexBlock) {
      return _buildMathCard(textContent);
    }

    // 3. Mermaid Diagrams (guaranteed untouched and prioritized for any mermaid code block)
    final isMermaidBlock = className.contains('language-mermaid') ||
        className.contains('language-flowchart');
    final trimmed = textContent.trimLeft();
    final lowerTrimmed = trimmed.toLowerCase();

    if (isMermaidBlock ||
        lowerTrimmed.startsWith('graph ') ||
        lowerTrimmed.startsWith('graph\n') ||
        lowerTrimmed.startsWith('flowchart ') ||
        lowerTrimmed.startsWith('flowchart\n') ||
        lowerTrimmed.startsWith('sequencediagram') ||
        lowerTrimmed.startsWith('classdiagram') ||
        lowerTrimmed.startsWith('statediagram') ||
        lowerTrimmed.startsWith('erdiagram') ||
        lowerTrimmed.startsWith('gantt') ||
        lowerTrimmed.startsWith('pie') ||
        lowerTrimmed.startsWith('mindmap') ||
        lowerTrimmed.startsWith('gitgraph') ||
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

  // Strip wrapping block delimiters if present (e.g. from code blocks or legacy format)
  if (clean.startsWith(r'\[') && clean.endsWith(r'\]')) {
    clean = clean.substring(2, clean.length - 2).trim();
  } else if (clean.startsWith(r'$$') && clean.endsWith(r'$$') && clean.length >= 4) {
    clean = clean.substring(2, clean.length - 2).trim();
  } else if (clean.startsWith(r'\(') && clean.endsWith(r'\)')) {
    clean = clean.substring(2, clean.length - 2).trim();
  } else if (clean.startsWith(r'$') && clean.endsWith(r'$') && clean.length >= 2) {
    clean = clean.substring(1, clean.length - 1).trim();
  }

  // Strip outer [ ... ] wrapper around \begin{...}...\end{...} blocks
  if (clean.startsWith('[') && clean.endsWith(']') && clean.contains(r'\begin{')) {
    clean = clean.substring(1, clean.length - 1).trim();
  }

  // Normalize 3+ consecutive backslashes down to \\
  clean = clean.replaceAll(RegExp(r'\\{3,}'), r'\\');

  // Fix spurious \\ right before \end{...}
  clean = clean.replaceAll(RegExp(r'\\{2,}\s*(?=\\end\{)'), '\n');

  // Replace commas followed by escaped newline or ampersand if LLM hallucinated
  clean = clean.replaceAll(RegExp(r',\s*(?:\\\s+|\\\\)'), r' \\ ');
  clean = clean.replaceAll(RegExp(r',\s*&\s*'), r' \\ ');

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
