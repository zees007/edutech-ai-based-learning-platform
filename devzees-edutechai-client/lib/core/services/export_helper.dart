import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../presentation/widgets/center_toast.dart';
import 'export_web_stub.dart'
    if (dart.library.js_interop) 'export_web_interop.dart';

class ExportHelper {
  /// Save or share file bytes across Web and Native platforms.
  static Future<void> saveOrShareFile({
    required List<int> bytes,
    required String filename,
    required String mimeType,
    required BuildContext context,
    String successMessage = 'Export ready!',
  }) async {
    try {
      if (kIsWeb) {
        downloadFileWeb(
          bytes: bytes,
          filename: filename,
          mimeType: mimeType,
        );
        if (context.mounted) {
          showToast(
            context,
            message: 'Download started for $filename',
            icon: Icons.download_done_rounded,
          );
        }
      } else {
        // Calculate bounding box for iPad/tablets popup anchor synchronously before async gap
        final box = context.findRenderObject() as RenderBox?;
        final origin = box != null && box.hasSize
            ? box.localToGlobal(Offset.zero) & box.size
            : null;

        // Native: save to application documents or temp directory
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/$filename';
        final file = File(filePath);
        await file.writeAsBytes(bytes, flush: true);

        await Share.shareXFiles(
          [XFile(filePath, mimeType: mimeType, name: filename)],
          text: filename,
          sharePositionOrigin: origin,
        );

        if (context.mounted) {
          showToast(
            context,
            message: successMessage,
            icon: Icons.check_circle_rounded,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        showToast(
          context,
          message: 'Export failed: $e',
          icon: Icons.error_outline_rounded,
          isError: true,
        );
      }
    }
  }

  /// Save or share text content (e.g. Markdown).
  static Future<void> saveOrShareText({
    required String content,
    required String filename,
    required BuildContext context,
    String mimeType = 'text/markdown',
  }) async {
    final bytes = utf8.encode(content);
    await saveOrShareFile(
      bytes: bytes,
      filename: filename,
      mimeType: mimeType,
      context: context,
      successMessage: 'Markdown file ready to save or share!',
    );
  }

  /// Open HTML content in browser (or share file on native platforms).
  static Future<void> openHtmlInBrowser({
    required String htmlContent,
    required String sessionId,
    required BuildContext context,
  }) async {
    if (kIsWeb) {
      openHtmlInNewTabWeb(htmlContent);
      if (context.mounted) {
        showToast(
          context,
          message: 'Interactive report opened in a new tab!',
          icon: Icons.open_in_new_rounded,
        );
      }
    } else {
      try {
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/session_$sessionId.html';
        final file = File(filePath);
        await file.writeAsString(htmlContent, flush: true);
        final fileUri = Uri.file(filePath);
        if (await canLaunchUrl(fileUri)) {
          await launchUrl(fileUri);
          if (context.mounted) {
            showToast(
              context,
              message: 'Interactive report opened in browser for View & Print!',
              icon: Icons.open_in_new_rounded,
            );
          }
          return;
        }
      } catch (_) {}

      if (context.mounted) {
        await saveOrShareText(
          content: htmlContent,
          filename: 'session_$sessionId.html',
          context: context,
          mimeType: 'text/html',
        );
      }
    }
  }

  /// Copy text to system clipboard and display quick toast.
  static Future<void> copyToClipboard(
    BuildContext context, {
    required String text,
    String message = 'Markdown copied to clipboard!',
  }) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      showToast(
        context,
        message: message,
        icon: Icons.copy_all_rounded,
      );
    }
  }

  /// Clean, responsive glassmorphic notification banner in center of screen.
  static void showToast(
    BuildContext context, {
    required String message,
    required IconData icon,
    bool isError = false,
  }) {
    if (isError) {
      CenterToast.showError(
        context,
        message,
        icon: icon,
      );
    } else {
      CenterToast.showSuccess(
        context,
        message,
        icon: icon,
      );
    }
  }
}
