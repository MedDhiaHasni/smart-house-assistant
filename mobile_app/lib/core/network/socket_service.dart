import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as socket_io;

import 'api_client.dart';

class SocketMessage {
  const SocketMessage({required this.event, required this.payload});

  final String event;
  final Object? payload;
}

class SocketService {
  SocketService({String baseUrl = apiBaseUrl})
    : _socket = socket_io.io(_socketUrl(baseUrl), <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'reconnection': true,
        'reconnectionDelay': 1000,
        'reconnectionDelayMax': 30000,
        'randomizationFactor': 0.5,
      }) {
    _socket.onConnect((_) => _setStatus('connected'));
    _socket.onDisconnect((_) => _setStatus('disconnected'));
    _socket.onConnectError((error) => _setStatus('error: $error'));
    _socket.onError((error) => _setStatus('error: $error'));
    _socket.onAny(
      (event, payload) =>
          _messages.add(SocketMessage(event: event, payload: payload)),
    );
  }

  final socket_io.Socket _socket;
  final StreamController<SocketMessage> _messages =
      StreamController<SocketMessage>.broadcast();
  final StreamController<String> _status = StreamController<String>.broadcast();
  String _currentStatus = 'disconnected';

  Stream<SocketMessage> get messages => _messages.stream;
  Stream<String> get status async* {
    yield _currentStatus;
    yield* _status.stream;
  }

  void connect(String token) {
    if (token.isEmpty) throw ArgumentError.value(token, 'token');
    _socket.auth = {'token': token};
    _socket.connect();
  }

  void sendCommandResult(Map<String, Object?> result) {
    if (!_socket.connected) {
      throw StateError('Socket.IO is not connected.');
    }
    _socket.emit('command:result', result);
  }

  void reportError(Object error) => _setStatus('error: $error');

  void _setStatus(String status) {
    _currentStatus = status;
    _status.add(status);
  }

  Future<void> dispose() async {
    _socket.dispose();
    await _messages.close();
    await _status.close();
  }

  static String _socketUrl(String baseUrl) {
    final uri = Uri.parse(baseUrl);
    final path = uri.path.replaceFirst(RegExp(r'/api/?$'), '');
    return uri.replace(path: path, query: null, fragment: null).toString();
  }
}
