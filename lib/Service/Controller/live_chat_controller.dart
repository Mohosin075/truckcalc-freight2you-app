import 'package:flutter/material.dart';

import 'package:gathering_app/Service/Api%20service/network_caller.dart';
import 'package:gathering_app/Service/urls.dart';
import 'package:gathering_app/Model/live_chat_message_model.dart';
import 'package:gathering_app/Service/Socket/socket_service.dart';
import 'package:gathering_app/Service/Controller/auth_controller.dart';

class LiveChatController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<LiveChatMessageModel> _messages = [];
  List<LiveChatMessageModel> get messages => _messages;

  final SocketService _socketService = SocketService();
  String? _currentRoomId;

  // Pagination
  int _page = 1;
  bool _hasMore = true;
  bool _isFetchingMore = false;

  void joinRoom(String roomId) {
    if (_currentRoomId == roomId) return;

    _currentRoomId = roomId;
    final token = AuthController().accessToken;

    if (token != null) {
      final userId = AuthController().userId;
      if (userId != null) {
        _socketService.connect(token, userId);
        _socketService.emit('join-room', roomId);
        debugPrint("🚀 Joined room: $roomId");

        _listenToEvents(roomId);
      }
    }
  }

  void leaveRoom() {
    if (_currentRoomId != null) {
      _socketService.emit('leave-room', _currentRoomId);
      _stopListening(_currentRoomId!);
      debugPrint("👋 Left room: $_currentRoomId");
      _currentRoomId = null;
      _messages.clear();
    }
  }

  void _listenToEvents(String roomId) {
    // New Message
    _socketService.on('new-message', (data) {
      if (data != null) {
        debugPrint("📩 New Socket Message: $data");
        // Avoid duplicates if any
        final newMessage = LiveChatMessageModel.fromJson(data);
        if (!_messages.any((m) => m.id == newMessage.id)) {
          _messages.insert(0, newMessage);
          notifyListeners();
        }
      }
    });

    // Message Liked
    _socketService.on('message-liked', (data) {
      if (data != null) {
        debugPrint("❤️ Message Liked Event: $data");
        final String? msgId = data['messageId'];
        final String? userId = data['userId'];

        // Optimistic update if needed, or just find and update
        final index = _messages.indexWhere((m) => m.id == msgId);
        if (index != -1) {
          // We might need to fetch the message again or just toggle manually if we know the state
          // But usually socket sends the updated count or we just re-fetch specific message?
          // The payload definition says { messageId, userId }.
          // We can increment/decrement count locally.

          // For now, let's just trigger a re-fetch of that specific message context or ignore
          // actually better to update locally.
          // If we are the one who liked, we already updated locally in likeMessage().
          // If someone else liked, we increment.

          if (userId != AuthController().userId) {
            // Someone else liked
            _messages[index].likes =
                (_messages[index].likes ?? 0) + 1; // Simplistic
            notifyListeners();
          }
        }
      }
    });

    // Message Deleted
    _socketService.on('message-deleted', (data) {
      if (data != null) {
        debugPrint("🗑️ Message Deleted Event: $data");
        final String? msgId = data['messageId'];
        _messages.removeWhere((m) => m.id == msgId);
        notifyListeners();
      }
    });
  }

  void _stopListening(String roomId) {
    _socketService.off('new-message');
    _socketService.off('message-liked');
    _socketService.off('message-deleted');
  }

  Future<void> fetchMessages(String roomId, {bool refresh = true}) async {
    if (refresh) {
      _isLoading = true;
      _page = 1;
      _hasMore = true;
      _messages.clear();
      notifyListeners();
    } else {
      if (!_hasMore || _isFetchingMore) return;
      _isFetchingMore = true;
      notifyListeners();
    }

    _errorMessage = null;

    try {
      final response = await NetworkCaller.getRequest(
        url: Urls.getLiveMessageUrl(roomId, page: _page, limit: 50),
        requireAuth: true,
      );

      if (response.isSuccess && response.body != null) {
        final Map<String, dynamic> body = response.body!;
        final List<dynamic> data = body['data'] ?? [];

        final List<LiveChatMessageModel> newMessages = data
            .map((e) => LiveChatMessageModel.fromJson(e))
            .toList();

        if (refresh) {
          _messages = newMessages;
        } else {
          _messages.addAll(newMessages);
        }

        // Check pagination meta
        if (body['meta'] != null) {
          final int totalPages = body['meta']['totalPages'] ?? 1;
          if (_page >= totalPages) {
            _hasMore = false;
          } else {
            _page++;
          }
        } else {
          if (newMessages.isEmpty) _hasMore = false;
        }
      } else {
        _errorMessage = response.errorMessage ?? 'Failed to fetch messages';
      }
    } catch (e) {
      _errorMessage = 'Exception: $e';
    } finally {
      _isLoading = false;
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(String roomId, String message) async {
    // Optimistic UI update could happen here, but better to wait for socket/API
    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.sentMessageUrl(roomId),
        body: {'message': message, 'messageType': 'text'},
        requireAuth: true,
      );

      if (response.isSuccess) {
        // Try to add the message locally from response
        if (response.body != null && response.body!['data'] != null) {
          try {
            final newMessage = LiveChatMessageModel.fromJson(
              response.body!['data'],
            );
            // Check if it already exists (from socket?)
            if (!_messages.any((m) => m.id == newMessage.id)) {
              _messages.insert(0, newMessage);
              notifyListeners();
            }
          } catch (e) {
            debugPrint("⚠️ Failed to parse sent message response: $e");
          }
        }
        return true;
      } else {
        _errorMessage = response.errorMessage ?? 'Failed to send message';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Exception: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> likeMessage(String messageId) async {
    // Optimistic Update
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final bool wasLiked = _messages[index].hasLiked ?? false;

      _messages[index].hasLiked = !wasLiked;
      _messages[index].likes =
          (_messages[index].likes ?? 0) + (wasLiked ? -1 : 1);
      notifyListeners();
    }

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.likeMessageUrl(messageId),
        body: {},
        requireAuth: true,
      );

      if (!response.isSuccess) {
        // Revert on failure
        if (index != -1) {
          final msg = _messages[index];
          _messages[index].hasLiked = !msg.hasLiked!; // specific toggle back
          _messages[index].likes = (msg.likes ?? 0) + (msg.hasLiked! ? 1 : -1);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Error liking message: $e");
    }
  }

  Future<bool> deleteMessage(String messageId) async {
    try {
      final response = await NetworkCaller.deleteRequest(
        Urls.deleteMessageUrl(messageId),
        requireAuth: true,
      );

      if (response.isSuccess) {
        // Socket should handle the removal, but we can do it optimistically/immediately
        _messages.removeWhere((m) => m.id == messageId);
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.errorMessage ?? 'Failed to delete message';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Exception: $e';
      notifyListeners();
      return false;
    }
  }
}
