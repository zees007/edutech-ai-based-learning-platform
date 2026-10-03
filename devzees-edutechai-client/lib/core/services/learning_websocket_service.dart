import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../constants/api_constants.dart';
import 'api_client.dart';

class LearningWebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  
  final StreamController<Map<String, dynamic>> _eventController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get events => _eventController.stream;

  bool get isConnected => _channel != null;

  Future<void> connect(String sessionId) async {
    if (_channel != null) {
      disconnect();
    }
    
    String? token;
    final cookies = await ApiClient.instance.cookieJar?.loadForRequest(Uri.parse(ApiConstants.baseUrl));
    if (cookies != null) {
      for (var cookie in cookies) {
        if (cookie.name == 'access_token') {
          token = cookie.value;
          break;
        }
      }
    }

    // Replace http/https with ws/wss and remove the API prefix for WebSockets
    String wsBaseUrl = ApiConstants.baseUrl.replaceAll('http', 'ws').replaceAll('/api/v1', '');
    String url = '$wsBaseUrl/ws/learn/$sessionId';
    if (token != null) {
      url += '?token=$token';
    }
    final uri = Uri.parse(url);
    
    _channel = WebSocketChannel.connect(uri);
    
    _subscription = _channel?.stream.listen(
      (message) {
        try {
          final decoded = jsonDecode(message as String) as Map<String, dynamic>;
          _eventController.add(decoded);
        } catch (e) {
          debugPrint('Error decoding websocket message: $e');
        }
      },
      onError: (error) {
        debugPrint('WebSocket error: $error');
        _eventController.add({'event_type': 'error', 'message': error.toString()});
      },
      onDone: () {
        debugPrint('WebSocket connection closed.');
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
