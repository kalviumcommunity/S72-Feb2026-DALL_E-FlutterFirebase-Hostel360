import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/app_notification_service.dart';

class AppNotificationProvider with ChangeNotifier {
  final AppNotificationService _service;

  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  StreamSubscription<List<AppNotification>>? _notificationsSubscription;
  StreamSubscription<int>? _unreadCountSubscription;

  AppNotificationProvider({AppNotificationService? service})
      : _service = service ?? AppNotificationService();

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  /// Start watching notifications for a user
  void watchNotifications(String userId) {
    _notificationsSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _notificationsSubscription =
        _service.getNotificationsForUser(userId).listen(
      (notifications) {
        _notifications = notifications;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        notifyListeners();
      },
    );

    _unreadCountSubscription = _service.getUnreadCount(userId).listen(
      (count) {
        _unreadCount = count;
        notifyListeners();
      },
    );
  }

  /// Mark a single notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _service.markAsRead(notificationId);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      await _service.markAllAsRead(userId);
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  /// Send a reply notification to a student
  Future<bool> sendReplyNotification({
    required String studentUserId,
    required String complaintId,
    required String complaintCategory,
    required String replyMessage,
    required String adminEmail,
  }) async {
    try {
      final notification = AppNotification(
        id: '',
        userId: studentUserId,
        complaintId: complaintId,
        title: 'Admin Reply on "$complaintCategory"',
        message: replyMessage,
        type: 'reply',
        timestamp: DateTime.now(),
        adminEmail: adminEmail,
      );
      await _service.createNotification(notification);
      return true;
    } catch (e) {
      debugPrint('Error sending reply notification: $e');
      return false;
    }
  }

  /// Send a status change notification to a student
  Future<bool> sendStatusChangeNotification({
    required String studentUserId,
    required String complaintId,
    required String complaintCategory,
    required String oldStatus,
    required String newStatus,
    required String adminEmail,
  }) async {
    try {
      final notification = AppNotification(
        id: '',
        userId: studentUserId,
        complaintId: complaintId,
        title: 'Status Updated: "$complaintCategory"',
        message: 'Your complaint status changed from $oldStatus to $newStatus.',
        type: 'status_change',
        timestamp: DateTime.now(),
        adminEmail: adminEmail,
      );
      await _service.createNotification(notification);
      return true;
    } catch (e) {
      debugPrint('Error sending status change notification: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    super.dispose();
  }
}
