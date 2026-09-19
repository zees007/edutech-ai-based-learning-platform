import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
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

  /// Clean, dark-mode glassmorphic notification banner.
  static void showToast(
    BuildContext context, {
    required String message,
    required IconData icon,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        duration: const Duration(seconds: 3),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isError
                ? const Color(0xFF4C0519).withValues(alpha: 0.95)
                : AppColors.surfaceDark.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isError
                  ? AppColors.rose.withValues(alpha: 0.5)
                  : AppColors.primary.withValues(alpha: 0.4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
              if (!isError)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 12,
                ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isError ? AppColors.rose : AppColors.accentCyan,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.body2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
