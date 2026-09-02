import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../../../core/theme/app_colors.dart';

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
    final html = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes">
  <style>
    body {
      margin: 0;
      padding: 16px;
      background-color: transparent;
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      color: #F8FAFC;
    }
    #graphDiv {
      width: 100%;
      display: flex;
      justify-content: center;
      overflow: auto;
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

    // Extract SVG after render and send to Flutter
    setTimeout(() => {
      try {
        const svgElement = document.querySelector('.mermaid svg');
        if (svgElement) {
          window.renderedSvgString = svgElement.outerHTML;
          if (window.SvgChannel) {
            window.SvgChannel.postMessage(svgElement.outerHTML);
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

  Future<void> _downloadSvg() async {
    String? finalSvg = _renderedSvg;

    // Fallback: If channel didn't work (like on Web), try fetching directly
    if (finalSvg == null || finalSvg.isEmpty) {
      try {
        final result = await _controller.runJavaScriptReturningResult(
          "window.renderedSvgString || ''"
        );
        final raw = result.toString();
        if (raw.isNotEmpty && raw != "''") {
          // runJavaScriptReturningResult returns a JSON-encoded string, so we decode it
          if (raw.startsWith('"') && raw.endsWith('"')) {
            finalSvg = jsonDecode(raw) as String;
          } else {
            finalSvg = raw;
          }
        }
      } catch (e) {
        debugPrint("Failed to fetch SVG via JS: \$e");
      }
    }

    if (finalSvg == null || finalSvg.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('SVG not ready yet.', style: GoogleFonts.inter())),
        );
      }
      return;
    }

    try {
      if (kIsWeb) {
        // On Web, iframe sandbox blocks JS downloads. Use url_launcher data URI.
        final bytes = utf8.encode(finalSvg);
        final base64String = base64Encode(bytes);
        final uri = Uri.parse("data:image/svg+xml;base64,\$base64String");
        
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          throw Exception("Could not launch SVG data URI");
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download started', style: GoogleFonts.inter(fontSize: 13)),
              backgroundColor: const Color(0xFF1E293B),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      // Mobile / Desktop implementation
      Directory? dir;
      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        dir = await getApplicationDocumentsDirectory();
      } else {
        dir = await getDownloadsDirectory();
      }

      if (dir == null) throw Exception("Could not access storage directory.");

      final file = File('\${dir.path}/mermaid_diagram_\${DateTime.now().millisecondsSinceEpoch}.svg');
      await file.writeAsString(finalSvg);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to \${file.path}', style: GoogleFonts.inter(fontSize: 13)),
            backgroundColor: const Color(0xFF1E293B),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save SVG: \$e', style: GoogleFonts.inter(fontSize: 13, color: Colors.redAccent)),
            backgroundColor: const Color(0xFF1E293B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: widget.code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Mermaid code copied to clipboard!',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openFullscreen() {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.accentCyan.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
              gradient: LinearGradient(
                colors: [
                  AppColors.accentCyan.withValues(alpha: 0.12),
                  AppColors.accentBlue.withValues(alpha: 0.08),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.accentCyan.withValues(alpha: 0.15),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_tree_rounded,
                  color: AppColors.accentCyan.withValues(alpha: 0.8),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '📊 Flow Diagram',
                  style: GoogleFonts.inter(
                    color: AppColors.accentCyan,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                
                // Toolbar Actions
                _ToolbarButton(
                  icon: Icons.fullscreen_rounded,
                  label: 'Expand',
                  onTap: _openFullscreen,
                ),
                const SizedBox(width: 8),
                _ToolbarButton(
                  icon: Icons.copy_rounded,
                  label: 'Code',
                  onTap: _copyCode,
                ),
                const SizedBox(width: 8),
                _ToolbarButton(
                  icon: Icons.download_rounded,
                  label: 'SVG',
                  onTap: _downloadSvg,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
          
          // WebView Container
          SizedBox(
            height: 280, // Fixed height for inline view, user can expand for more
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
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(6),
        hoverColor: Colors.white.withValues(alpha: 0.1),
        splashColor: Colors.white.withValues(alpha: 0.2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.white.withValues(alpha: 0.06),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 13,
                  height: 13,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                )
              else
                Icon(
                  icon,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 13,
                ),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Fullscreen View Mode
// ═══════════════════════════════════════════════════════════════════
class _MermaidFullscreenView extends StatefulWidget {
  final String code;
  final String htmlContent;

  const _MermaidFullscreenView({
    required this.code,
    required this.htmlContent,
  });

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
      ..setBackgroundColor(const Color(0xFF0F172A)) // Dark background
      ..loadHtmlString(widget.htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Diagram Viewer',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded, color: Colors.white70),
            tooltip: 'Copy Code',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.code));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard!')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
