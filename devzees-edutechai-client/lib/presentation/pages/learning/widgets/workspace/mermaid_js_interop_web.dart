import 'dart:js_interop';

@JS('eval')
external JSAny? _jsEval(JSString code);

void evalJs(String code) {
  _jsEval(code.toJS);
}
