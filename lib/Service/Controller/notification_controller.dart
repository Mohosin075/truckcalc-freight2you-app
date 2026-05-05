import 'package:flutter/material.dart';
import 'package:gathering_app/Model/notification_model.dart';
import 'package:gathering_app/Service/Api%20service/network_caller.dart';
import 'package:gathering_app/Service/urls.dart';
import 'package:gathering_app/Service/Socket/socket_service.dart';

class NotificationController extends ChangeNotifier {
  bool _inProgress = false;
  String? _errorMessage;
  NotificationModel? _notificationModel;
  List<NotificationData> _notifications = [];

  NotificationController() {
    _initSocketListener();
  }

  void _initSocketListener() {
    SocketService().eventStream.listen((eventData) {
      if (eventData['event'] == 'notification') {
        final data = eventData['data'];
        if (data != null) {
          debugPrint("🔔 Real-time notification received in Controller: $data");
          try {
            // Adjust parsing based on the actual notification payload structure
            // Usually, data contains the notification object or is the notification object
            final newNotification = NotificationData.fromJson(data);
            
            // Insert at the beginning of the list
            _notifications.insert(0, newNotification);
            notifyListeners();
          } catch (e) {
            debugPrint("⚠️ Failed to parse real-time notification: $e");
            // If parsing fails, we could just refresh the list from API
            fetchNotifications();
          }
        }
      }
    });
  }

  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;
  NotificationModel? get notificationModel => _notificationModel;
  List<NotificationData> get notifications =>
      _notifications.where((n) => n.isRead == false).toList();

  int get unreadCount => _notifications.where((n) => n.isRead == false).length;

  Future<void> fetchNotifications() async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    final response = await NetworkCaller.getRequest(
      url: Urls.getAllNotificationUrl,
    );

    _inProgress = false;

    if (response.isSuccess) {
      if (response.body != null) {
        _notificationModel = NotificationModel.fromJson(response.body!);
        _notifications = _notificationModel?.data ?? [];
      }
    } else {
      _errorMessage = response.errorMessage ?? 'Failed to load notifications';
    }

    notifyListeners();
  }

  Future<void> fetchNotificationById(String id) async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    final response = await NetworkCaller.getRequest(
      url: Urls.getNotificationByIdUrl(id),
    );

    _inProgress = false;

    if (response.isSuccess) {
      if (response.body != null) {
        final singleModel = SingleNotificationModel.fromJson(response.body!);
        if (singleModel.data != null) {
          // Update the notification in the list if it exists
          int index = _notifications.indexWhere((n) => n.sId == id);
          if (index != -1) {
            _notifications[index] = singleModel.data!;
          }
        }
      }
    } else {
      _errorMessage =
          response.errorMessage ?? 'Failed to load individual notification';
    }

    notifyListeners();
  }

  // Method to mark all notifications as read
  Future<bool> markAllAsRead() async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    final response = await NetworkCaller.patchRequest(
      url: Urls.readAllNotificationUrl,
    );

    _inProgress = false;

    if (response.isSuccess) {
      // Clear the list locally since all are read and we only show unread
      _notifications.clear();
      await fetchNotifications();
      return true;
    } else {
      _errorMessage = response.errorMessage ?? 'Failed to mark all as read';
      notifyListeners();
      return false;
    }
  }

  // Method to mark a single notification as read
  Future<bool> markAsRead(String id) async {
    // We don't necessarily need a full page loader for this, maybe just local update
    final response = await NetworkCaller.patchRequest(
      url: Urls.readNotificationUrl(id),
    );

    if (response.isSuccess) {
      // Find and update locally for immediate feedback
      int index = _notifications.indexWhere((n) => n.sId == id);
      if (index != -1) {
        _notifications[index].isRead = true;
        // Since the getter filters out read items, notifyListeners will refresh the UI to remove it
        notifyListeners();
      }
      return true;
    }
    return false;
  }
}
