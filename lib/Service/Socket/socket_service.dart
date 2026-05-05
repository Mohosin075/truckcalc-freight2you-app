import 'dart:async';
import 'package:gathering_app/Service/urls.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? socket;
  String? _currentUserId;

  // Stream for broadcasting socket events
  final StreamController<Map<String, dynamic>> _eventStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get eventStream => _eventStreamController.stream;

  bool get isConnected => socket != null && socket!.connected;

  void connect(String token, String userId) {
    if (isConnected && _currentUserId == userId) {
      debugPrint("🔌 Socket already connected for user $userId.");
      return;
    }

    if (socket != null) {
      debugPrint("🔌 Reconnecting socket for new user...");
      disconnect();
    }

    _currentUserId = userId;

    debugPrint(
      "🔌 Connecting to socket... URL: ${Urls.baseUrl}, User: $userId",
    );

    socket = IO.io(
      Urls.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableAutoConnect()
          .build(),
    );

    // Standard Listeners
    socket!.onConnect((_) {
      debugPrint('✅ Connected to Real-time Server');
      // Join user-specific room for private notifications
      if (_currentUserId != null) {
        debugPrint('🏠 Joining room: $_currentUserId');
        socket!.emit('join-room', _currentUserId);
      }
    });

    socket!.onDisconnect((_) {
      debugPrint('❌ Disconnected from Real-time Server');
    });

    socket!.onConnectError((data) {
      debugPrint('⚠️ Connection Error: $data');
      _eventStreamController.add({'event': 'socket_error', 'data': data});
    });

    socket!.onError((data) {
      debugPrint('🚨 Error: $data');
      _eventStreamController.add({'event': 'socket_error', 'data': data});
    });

    // --- Developer Guide Listeners ---

    socket!.on('notification', (data) {
      debugPrint('🔔 Notification received: $data');
      _eventStreamController.add({'event': 'notification', 'data': data});
    });

    socket!.on('new-message', (data) {
      debugPrint('💬 New message received: $data');
      _eventStreamController.add({'event': 'new-message', 'data': data});
    });

    socket!.on('message-liked', (data) {
      debugPrint('👍 Message liked: $data');
      _eventStreamController.add({'event': 'message-liked', 'data': data});
    });

    socket!.on('message-deleted', (data) {
      debugPrint('🗑️ Message deleted: $data');
      _eventStreamController.add({'event': 'message-deleted', 'data': data});
    });

    socket!.on('socket_error', (data) {
      debugPrint('⚠️ Socket error event: $data');
      _eventStreamController.add({'event': 'socket_error', 'data': data});
    });
  }

  void emit(String event, dynamic data) {
    if (socket != null && socket!.connected) {
      socket!.emit(event, data);
    } else {
      debugPrint('⚠️ Socket not connected. Cannot emit $event');
    }
  }

  void on(String event, Function(dynamic) handler) {
    socket?.on(event, handler);
  }

  void off(String event) {
    socket?.off(event);
  }

  void disconnect() {
    socket?.disconnect();
    socket = null;
    _currentUserId = null;
  }

  void dispose() {
    _eventStreamController.close();
  }
}
