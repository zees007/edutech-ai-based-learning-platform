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
        var a = document.createElement('a');
        a.href = 'data:' + $safeMime + ';base64,' + '$base64Str';
        a.download = $safeName;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
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
        var win = window.open('data:text/html;charset=utf-8;base64,' + '$base64Str', '_blank');
        if (win) {
          win.focus();
        }
      } catch(e) {
        console.error('Open error:', e);
      }
    })();
  '''.toJS);
}
