import 'package:flutter/material.dart';
import 'package:front_end/models/notification_model.dart';
import 'package:front_end/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _userId;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> initialize(String userId) async {
    _userId = userId;
    await loadNotifications();
    _startPolling();
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    final result = await _notificationService.getNotifications();
    if (result.isSuccess) {
      _notifications = result.data ?? [];
      _updateUnreadCount();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    await _notificationService.markAsRead(notificationId);
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _updateUnreadCount();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    await _notificationService.markAllAsRead();
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _updateUnreadCount();
    notifyListeners();
  }

  Future<void> deleteNotification(String notificationId) async {
    await _notificationService.deleteNotification(notificationId);
    _notifications.removeWhere((n) => n.id == notificationId);
    _updateUnreadCount();
    notifyListeners();
  }

  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  void _startPolling() {
    Future.delayed(const Duration(seconds: 30), () {
      if (_userId != null) {
        loadNotifications();
        _startPolling();
      }
    });
  }

  @override
  void dispose() {
    if (_userId != null) {
      _notificationService.unsubscribeFromNotifications(_userId!);
    }
    super.dispose();
  }
}
