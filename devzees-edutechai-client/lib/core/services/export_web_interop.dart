import 'dart:convert';
import 'dart:js_interop';

@JS('eval')
external JSAny? _jsEval(JSString code);

void downloadFileWeb({
  required List<int> bytes,
  required String filename,
  required String mimeType,
}) {
  final base64Str = base64Encode(bytes);
  final safeName = jsonEncode(filename);
  final safeMime = jsonEncode(mimeType);

  _jsEval('''
    (function() {
      try {
        var binary = atob('$base64Str');
        var len = binary.length;
        var buffer = new Uint8Array(len);
        for (var i = 0; i < len; i++) {
          buffer[i] = binary.charCodeAt(i);
        }
        var blob = new Blob([buffer], {type: $safeMime});
        var url = URL.createObjectURL(blob);
        var a = document.createElement('a');
        a.href = url;
        a.download = $safeName;
        document.body.appendChild(a);
        a.click();
        setTimeout(function() {
          document.body.removeChild(a);
          URL.revokeObjectURL(url);
        }, 2000);
      } catch(e) {
        console.error('Download error:', e);
      }
    })();
  '''.toJS);
}

void openHtmlInNewTabWeb(String htmlContent) {
  final base64Str = base64Encode(utf8.encode(htmlContent));
  _jsEval('''
    (function() {
      try {
        var binary = atob('$base64Str');
        var len = binary.length;
        var bytes = new Uint8Array(len);
        for (var i = 0; i < len; i++) {
          bytes[i] = binary.charCodeAt(i);
        }
        var blob = new Blob([bytes], {type: 'text/html;charset=utf-8'});
        var url = URL.createObjectURL(blob);
        var win = window.open(url, '_blank');
        if (win && !win.closed) {
          win.focus();
        } else {
          // If window.open was intercepted by popup blocker, fall back to anchor click
          var a = document.createElement('a');
          a.href = url;
          a.target = '_blank';
          a.rel = 'noopener';
          document.body.appendChild(a);
          a.click();
          setTimeout(function() {
            document.body.removeChild(a);
          }, 1000);
        }
      } catch(e) {
        console.error('Open HTML in new tab error:', e);
      }
    })();
  '''.toJS);
}
