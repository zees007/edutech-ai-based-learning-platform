import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/text_styles.dart';
import 'mermaid_js_interop_stub.dart' if (dart.library.js_interop) 'mermaid_js_interop_web.dart';

class MermaidWebView extends StatefulWidget {
  final String code;

  const MermaidWebView({super.key, required this.code});

  @override
  State<MermaidWebView> createState() => _MermaidWebViewState();
}

class _MermaidWebViewState extends State<MermaidWebView> {
  late final WebViewController _controller;
  String? _renderedSvg;
  bool _isLoading = true;
  double _webViewHeight = 280;
  bool _isIframeHovered = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'SvgChannel',
        onMessageReceived: (JavaScriptMessage message) {
          setState(() {
            _renderedSvg = message.message;
            _isLoading = false;
          });
        },
      )
      ..addJavaScriptChannel(
        'HeightChannel',
        onMessageReceived: (JavaScriptMessage message) {
          final height = double.tryParse(message.message);
          if (height != null && height > 100) {
            setState(() {
              _webViewHeight = height;
            });
          }
        },
      )
      ..addJavaScriptChannel(
        'HoverChannel',
        onMessageReceived: (JavaScriptMessage message) {
          setState(() {
            _isIframeHovered = message.message == 'enter';
          });
        },
      )
      ..loadHtmlString(_buildHtml());

    // Fallback for platforms where SvgChannel isn't fully supported (like Web)
    // webview_flutter_web also doesn't support NavigationDelegate, so we just use a timer.
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  String _buildHtml() {
    final safeCode = jsonEncode(widget.code);

    // We use a dark theme configuration for Mermaid to match the app
    final html =
        '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes">
  <style>
    html, body {
      margin: 0;
      padding: 0;
      width: 100%;
      height: 100%;
      overflow: auto;
      background-color: transparent;
    }
    body {
      display: block;
      color: #F8FAFC;
    }
    #graphDiv {
      display: inline-block;
      min-width: 100%;
      text-align: center;
    }
    
    /* Custom Scrollbar matching card background (#1E293B / #0F172A) */
    ::-webkit-scrollbar {
      width: 6px;
      height: 6px;
    }
    ::-webkit-scrollbar-track {
      background: rgba(15, 23, 42, 0.4); 
      border-radius: 6px;
    }
    ::-webkit-scrollbar-thumb {
      background: rgba(51, 65, 85, 0.65); 
      border-radius: 6px;
      border: 1px solid rgba(255, 255, 255, 0.05);
    }
    ::-webkit-scrollbar-thumb:hover {
      background: rgba(71, 85, 105, 0.9); 
    }
    .error-msg {
      color: #EF4444;
      font-family: monospace;
      white-space: pre-wrap;
    }
  </style>
</head>
<body>
  <div id="graphDiv">
    <div class="mermaid" id="mermaid-container"></div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
  <script>
    // Safely inject the code using jsonEncode from Dart
    const code = $safeCode;
    document.getElementById('mermaid-container').textContent = code;

    // Hover detection for Flutter overlay
    document.body.addEventListener('mouseenter', () => {
      if (window.HoverChannel) window.HoverChannel.postMessage('enter');
    });
    document.body.addEventListener('mouseleave', () => {
      if (window.HoverChannel) window.HoverChannel.postMessage('leave');
    });

    mermaid.initialize({
      startOnLoad: true,
      theme: 'dark',
      themeVariables: {
        primaryColor: '#1E293B',
        primaryTextColor: '#F8FAFC',
        primaryBorderColor: '#3B82F6',
        lineColor: '#94A3B8',
        secondaryColor: '#0F172A',
        tertiaryColor: '#C084FC'
      },
      securityLevel: 'loose'
    });

    // Helper: always get fresh SVG from the DOM
    function getSvgString() {
      const el = document.querySelector('.mermaid svg');
      return el ? el.outerHTML : '';
    }

    // Extract SVG after render and send to Flutter
    setTimeout(() => {
      try {
        const svg = getSvgString();
        if (svg) {
          window.renderedSvgString = svg;
          if (window.SvgChannel) {
            window.SvgChannel.postMessage(svg);
          }
          const svgElement = document.querySelector('.mermaid svg');
          if (svgElement && window.HeightChannel) {
            const rect = svgElement.getBoundingClientRect();
            // Add some padding to prevent cut-off
            window.HeightChannel.postMessage(Math.ceil(rect.height + 40).toString());
          }
        }
      } catch (e) {
        console.error(e);
      }
    }, 1000);
  </script>
</body>
</html>
''';
    return html;
  }

  void _showToast(String message, IconData icon, [bool isError = false]) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    final bottomMargin = kIsWeb ? screenHeight - 120 : 24.0;
    final leftMargin = kIsWeb ? screenWidth - 320 : 24.0;
    const rightMargin = 24.0;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: isError ? AppColors.accentPink : AppColors.accentCyan, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.secondaryBackground,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: bottomMargin > 0 ? bottomMargin : 24.0,
          left: leftMargin > 0 ? leftMargin : 24.0,
          right: rightMargin,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        duration: const Duration(seconds: 3),
        elevation: 0,
      ),
    );
  }

  /// Extracts the SVG string from the WebView, trying multiple strategies.
  Future<String> _extractSvgFromWebView() async {
    // Strategy 1: Use the cached SVG from the SvgChannel
    if (_renderedSvg != null && _renderedSvg!.trim().isNotEmpty) {
      debugPrint('SVG source: SvgChannel cache');
      return _renderedSvg!;
    }

    // Strategy 2: Re-read directly from the DOM via JS
    debugPrint('SVG source: Falling back to JS extraction...');
    final result = await _controller.runJavaScriptReturningResult(
      '''(function() {
        var el = document.querySelector('.mermaid svg');
        if (el) return el.outerHTML;
        var container = document.getElementById('graphDiv');
        if (container) return container.innerHTML;
        return '';
      })()''',
    );

    final raw = result.toString();
    debugPrint('JS extraction raw length: ${raw.length}, starts: ${raw.substring(0, raw.length.clamp(0, 50))}');

    // The WebView wraps string results in quotes — unwrap them
    if (raw.startsWith('"') && raw.endsWith('"')) {
      try {
        final decoded = jsonDecode(raw) as String;
        if (decoded.isNotEmpty) return decoded;
      } catch (_) {}
    }

    // Some platforms return without quotes
    if (raw.isNotEmpty && raw != "''" && raw != 'null') {
      return raw;
    }

    throw Exception('SVG content is empty — the diagram may not have rendered yet.');
  }

  Future<void> _downloadSvg() async {
    try {
      if (kIsWeb) {
        _showToast('Downloading SVG diagram...', Icons.downloading_rounded);

        // On Flutter Web, the WebView is a sandboxed iframe — all direct download
        // attempts from inside the iframe are blocked by Chrome/Safari.
        // Solution: Trigger the download in the TOP-LEVEL page context (outside the iframe)
        // using the mermaid library loaded in index.html (with dynamic script fallback).
        final safeCode = jsonEncode(widget.code);
        evalJs('''
          (function() {
            var code = $safeCode;
            if (window.downloadMermaidDiagram) {
              window.downloadMermaidDiagram(code, 'svg');
            } else {
              function doExport() {
                var renderId = 'mermaid_dl_' + Math.random().toString(36).substring(2, 9);
                window.mermaid.render(renderId, code).then(function(res) {
                  var el = document.getElementById(renderId);
                  if (el) el.remove();
                  var blob = new Blob([res.svg], { type: 'image/svg+xml;charset=utf-8' });
                  var url = URL.createObjectURL(blob);
                  var a = document.createElement('a');
                  a.href = url;
                  a.download = 'mermaid_diagram_' + Date.now() + '.svg';
                  document.body.appendChild(a);
                  a.click();
                  document.body.removeChild(a);
                  setTimeout(function() { URL.revokeObjectURL(url); }, 1000);
                }).catch(function(e) {
                  console.error("Fallback render error:", e);
                });
              }
              if (window.mermaid) {
                doExport();
              } else {
                var s = document.createElement('script');
                s.src = 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js';
                s.onload = function() {
                  window.mermaid.initialize({ startOnLoad: false, theme: 'dark' });
                  doExport();
                };
                document.head.appendChild(s);
              }
            }
          })();
        ''');

        if (mounted) {
          _showToast('SVG diagram download started!', Icons.check_circle_rounded);
        }
      } else {
        // Get bounding box for iPad/tablets popup anchor synchronously before async gaps
        final box = context.findRenderObject() as RenderBox?;
        final origin = box != null && box.hasSize
            ? box.localToGlobal(Offset.zero) & box.size
            : null;

        _showToast('Preparing diagram...', Icons.downloading_rounded);

        // On mobile/desktop: extract SVG from native WebView, then open system share sheet
        final svgContent = await _extractSvgFromWebView();

        final tempDir = await getTemporaryDirectory();
        final fileName =
            'mermaid_diagram_${DateTime.now().millisecondsSinceEpoch}.svg';
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsString(svgContent);
        debugPrint('SVG saved for sharing at: ${file.path}');

        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'image/svg+xml', name: fileName)],
          text: 'Mermaid Diagram',
          sharePositionOrigin: origin,
        );

        if (mounted) {
          _showToast('Share options opened!', Icons.share_rounded);
        }
      }
    } catch (e, stack) {
      debugPrint("Download SVG Error: $e\n$stack");
      if (mounted) {
        _showToast('Action failed: $e', Icons.error_outline_rounded, true);
      }
    }
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: widget.code));
    _showToast('Mermaid code copied to clipboard!', Icons.copy_all_rounded);
  }

  void _openFullscreen() {
    _showToast('Opening diagram in zoom view...', Icons.fullscreen_rounded);
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => _MermaidFullscreenView(
          code: widget.code,
          htmlContent: _buildHtml(),
        ),
      ),
    );
  }

  bool _isCardHovered = false;
  bool get _isHovered => _isCardHovered || _isIframeHovered;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isCardHovered = true),
      onExit: (_) => setState(() => _isCardHovered = false),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Toolbar at the top (with hover visibility effect like Streamlit)
            AnimatedOpacity(
              opacity: (!kIsWeb || _isHovered) ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.glassBorderSubtle),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _HoverIconButton(
                      icon: kIsWeb ? Icons.download_rounded : Icons.share_rounded,
                      tooltip: kIsWeb ? 'Download SVG' : 'Save / Share SVG',
                      onTap: _downloadSvg,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(width: 4),
                    _HoverIconButton(
                      icon: Icons.copy_rounded,
                      tooltip: 'Copy Mermaid Code',
                      onTap: _copyCode,
                    ),
                    const SizedBox(width: 4),
                    _HoverIconButton(
                      icon: Icons.fullscreen_rounded,
                      tooltip: 'Fullscreen / Zoom',
                      onTap: _openFullscreen,
                    ),
                  ],
                ),
              ),
            ),

            // WebView Container
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _webViewHeight, // Dynamic height based on SVG
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_isLoading)
                    Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentCyan.withValues(alpha: 0.5),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoverIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isLoading;
  final String? tooltip;

  const _HoverIconButton({
    required this.icon,
    required this.onTap,
    this.isLoading = false,
    this.tooltip,
  });

  @override
  State<_HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<_HoverIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Widget button = GestureDetector(
      onTap: widget.isLoading ? null : widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.glassHover : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered ? AppColors.glassBorder : Colors.transparent,
            ),
          ),
          child: widget.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textSecondary,
                  ),
                )
              : Icon(
                  widget.icon,
                  color: _isHovered ? AppColors.textPrimary : AppColors.textSecondary,
                  size: 18,
                ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        waitDuration: const Duration(milliseconds: 400),
        child: button,
      );
    }
    return button;
  }
}

// ═══════════════════════════════════════════════════════════════════
// Fullscreen View Mode
// ═══════════════════════════════════════════════════════════════════
class _MermaidFullscreenView extends StatefulWidget {
  final String code;
  final String htmlContent;

  const _MermaidFullscreenView({required this.code, required this.htmlContent});

  @override
  State<_MermaidFullscreenView> createState() => _MermaidFullscreenViewState();
}

class _MermaidFullscreenViewState extends State<_MermaidFullscreenView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.surfaceDark) // Dark background
      ..loadHtmlString(widget.htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceMid,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Diagram Viewer',
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded, color: Colors.white70),
            tooltip: 'Copy Code',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.code));
              
              final screenWidth = MediaQuery.of(context).size.width;
              final screenHeight = MediaQuery.of(context).size.height;
              
              final bottomMargin = kIsWeb ? screenHeight - 120 : 24.0;
              final leftMargin = kIsWeb ? screenWidth - 320 : 24.0;
              const rightMargin = 24.0;

              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.copy_all_rounded, color: AppColors.accentCyan, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Copied to clipboard!',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.secondaryBackground,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.only(
                    bottom: bottomMargin > 0 ? bottomMargin : 24.0,
                    left: leftMargin > 0 ? leftMargin : 24.0,
                    right: rightMargin,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppColors.glassBorder),
                  ),
                  duration: const Duration(seconds: 3),
                  elevation: 0,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(child: WebViewWidget(controller: _controller)),
    );
  }
}
