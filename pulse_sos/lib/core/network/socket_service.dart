import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';

/// Socket.IO client for real-time SOS events
class SocketService {
  IO.Socket? _socket;
  final FlutterSecureStorage _storage;
  final Logger _logger = Logger();
  bool _isConnected = false;

  SocketService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  bool get isConnected => _isConnected;
  IO.Socket? get socket => _socket;

  Future<void> connect() async {
    if (_isConnected) return;

    final token = await _storage.read(key: 'auth_token');

    _socket = IO.io(
      ApiConstants.wsUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token ?? ''})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      _logger.i('Socket connected: ${_socket!.id}');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      _logger.w('Socket disconnected');
    });

    _socket!.onConnectError((data) {
      _logger.e('Socket connection error: $data');
    });

    _socket!.onError((data) {
      _logger.e('Socket error: $data');
    });
  }

  void emit(String event, dynamic data) {
    if (_isConnected && _socket != null) {
      _socket!.emit(event, data);
      _logger.d('Socket emit: $event');
    }
  }

  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _isConnected = false;
    _logger.i('Socket disposed');
  }
}
