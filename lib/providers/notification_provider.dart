import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  bool _isInitialized = false;
  List<Map<String, dynamic>> _notifications = [];
  bool _notificationsEnabled = true;

  bool get isInitialized => _isInitialized;
  List<Map<String, dynamic>> get notifications => _notifications;
  bool get notificationsEnabled => _notificationsEnabled;

  /// Initialize notification service
  Future<void> initializeNotifications() async {
    try {
      await _notificationService.initialize();
      _isInitialized = true;

      // Subscribe to notification stream
      _notificationService.notificationStream.listen((notification) {
        _addNotification(notification);
      });

      notifyListeners();
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  /// Add notification to list
  void _addNotification(Map<String, dynamic> notification) {
    _notifications.insert(0, {
      ...notification,
      'timestamp': DateTime.now(),
    });
    notifyListeners();
  }

  /// Clear all notifications
  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  /// Remove specific notification
  void removeNotification(int index) {
    if (index < _notifications.length) {
      _notifications.removeAt(index);
      notifyListeners();
    }
  }

  /// Toggle notifications on/off
  void toggleNotifications(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _notificationService.subscribeToTopic(topic);
      notifyListeners();
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _notificationService.unsubscribeFromTopic(topic);
      notifyListeners();
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  /// Get FCM token
  Future<String?> getFCMToken() async {
    try {
      return await _notificationService.getFCMToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _notificationService.dispose();
    super.dispose();
  }
}
