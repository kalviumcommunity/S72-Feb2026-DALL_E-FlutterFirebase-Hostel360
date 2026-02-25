import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  String? _deviceToken;
  bool _isInitialized = false;

  String? get deviceToken => _deviceToken;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    await _notificationService.initialize();
    _deviceToken = await _notificationService.getDeviceToken();
    _isInitialized = true;
    notifyListeners();
  }
}
