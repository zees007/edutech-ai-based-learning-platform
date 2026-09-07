import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../constants/api_constants.dart';

class LearningWebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  
  final StreamController<Map<String, dynamic>> _eventController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get events => _eventController.stream;

  bool get isConnected => _channel != null;

  void connect(String sessionId) {
    if (_channel != null) {
      disconnect();
    }
    
    // Replace http/https with ws/wss from ApiConstants.baseUrl
    String wsBaseUrl = ApiConstants.baseUrl.replaceAll('http', 'ws');
    final uri = Uri.parse('$wsBaseUrl/ws/learn/$sessionId');
    
    _channel = WebSocketChannel.connect(uri);
    
    _subscription = _channel?.stream.listen(
      (message) {
        try {
          final decoded = jsonDecode(message as String) as Map<String, dynamic>;
          _eventController.add(decoded);
        } catch (e) {
          print('Error decoding websocket message: $e');
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
        _eventController.add({'event_type': 'error', 'message': error.toString()});
      },
      onDone: () {
        print('WebSocket connection closed.');
      },
    );
  }

  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    _subscription = null;
  }

  void sendStartStep(int stepIndex) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        'action': 'start_step',
        'step_index': stepIndex,
      }));
    }
  }

  void sendNextStep() {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        'action': 'next_step',
      }));
    }
  }

  void sendChat(String content) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        'action': 'chat',
        'content': content,
      }));
    }
  }
}
