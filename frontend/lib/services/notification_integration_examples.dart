import 'package:front_end/services/notification_service.dart';
import 'package:front_end/models/notification_model.dart';

/// Example integration patterns for notifications system
class NotificationIntegrationExamples {
  final NotificationService _notificationService = NotificationService();

  /// Example 1: Create notification after complaint submission
  Future<void> notifyComplaintSubmitted(
    String userId,
    String complaintId,
  ) async {
    await _notificationService.createNotification(
      userId: userId,
      title: 'Complaint Submitted',
      message: 'Your complaint has been successfully submitted.',
      actionType: 'complaint',
      actionId: complaintId,
    );
  }

  /// Example 2: Create notification when document is ready
  Future<void> notifyDocumentReady(
    String userId,
    String documentId,
    String documentType,
  ) async {
    await _notificationService.createNotification(
      userId: userId,
      title: 'Document Ready',
      message:
          'Your $documentType has been generated and is ready to download.',
      actionType: 'document',
      actionId: documentId,
    );
  }

  /// Example 3: Fetch notifications for display
  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    final result = await _notificationService.getNotifications();
    return result.isSuccess ? result.data ?? [] : [];
  }

  /// Example 4: Get unread count
  Future<int> getUnreadNotificationCount() async {
    final result = await _notificationService.getUnreadCount();
    return result.isSuccess ? result.data ?? 0 : 0;
  }

  /// Example 5: Mark notification as read when user clicks it
  Future<void> openNotification(String notificationId) async {
    await _notificationService.markAsRead(notificationId);
  }

  /// Example 6: Real-time subscription (optional)
  void setupRealtimeNotifications(
    String userId,
    Function(NotificationModel) onNewNotification,
  ) {
    _notificationService.subscribeToNotifications(
      userId: userId,
      onNotification: onNewNotification,
      onError: (error) {
        print('Real-time error: $error');
      },
    );
  }

  /// Example 7: Mark all as read (bulk operation)
  Future<void> clearAllNotifications() async {
    await _notificationService.markAllAsRead();
  }
}

/// Usage in screens:
/// 
/// // In any screen, inject the NotificationService
/// final notificationService = NotificationService();
/// 
/// // Load notifications
/// final result = await notificationService.getNotifications();
/// if (result.isSuccess) {
///   final notifications = result.data ?? [];
///   // Use notifications
/// }
/// 
/// // Mark as read
/// await notificationService.markAsRead(notificationId);
/// 
/// // Delete notification
/// await notificationService.deleteNotification(notificationId);
