import 'package:flutter/material.dart';
import 'package:front_end/models/error_models.dart';
import 'package:front_end/models/notification_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _tableName = 'notifications';

  /// Fetch all notifications for the current user
  Future<ApiResult<List<NotificationModel>>> getNotifications({
    bool unreadOnly = false,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return ApiResult<List<NotificationModel>>.failure(
          AppError(
            type: ErrorType.unauthorized,
            message: 'User not authenticated',
          ),
        );
      }

      final matchMap = <String, Object>{'user_id': userId};
      if (unreadOnly) matchMap['is_read'] = false;

      final response = await _supabase
          .from(_tableName)
          .select()
          .match(matchMap)
          .order('created_at', ascending: false);

      final notifications = (response as List)
          .map(
            (json) => NotificationModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      return ApiResult<List<NotificationModel>>.success(notifications);
    } catch (e, st) {
      debugPrint('Error fetching notifications: $e\n$st');
      return ApiResult<List<NotificationModel>>.failure(
        AppError(
          type: ErrorType.unknown,
          message: 'Failed to fetch notifications',
          originalError: e,
          stackTrace: st,
        ),
      );
    }
  }

  /// Get count of unread notifications
  Future<ApiResult<int>> getUnreadCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return ApiResult<int>.failure(
          AppError(
            type: ErrorType.unauthorized,
            message: 'User not authenticated',
          ),
        );
      }

      final response = await _supabase
          .from(_tableName)
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);

      final count = (response as List).length;
      return ApiResult<int>.success(count);
    } catch (e, st) {
      debugPrint('Error fetching unread count: $e\n$st');
      return ApiResult<int>.failure(
        AppError(
          type: ErrorType.unknown,
          message: 'Failed to fetch unread count',
          originalError: e,
          stackTrace: st,
        ),
      );
    }
  }

  /// Mark notification as read
  Future<ApiResult<void>> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from(_tableName)
          .update({'is_read': true})
          .eq('id', notificationId);

      return ApiResult<void>.success(null);
    } catch (e, st) {
      debugPrint('Error marking notification as read: $e\n$st');
      return ApiResult<void>.failure(
        AppError(
          type: ErrorType.unknown,
          message: 'Failed to mark notification as read',
          originalError: e,
          stackTrace: st,
        ),
      );
    }
  }

  /// Mark all notifications as read
  Future<ApiResult<void>> markAllAsRead() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return ApiResult<void>.failure(
          AppError(
            type: ErrorType.unauthorized,
            message: 'User not authenticated',
          ),
        );
      }

      await _supabase
          .from(_tableName)
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);

      return ApiResult<void>.success(null);
    } catch (e, st) {
      debugPrint('Error marking all notifications as read: $e\n$st');
      return ApiResult<void>.failure(
        AppError(
          type: ErrorType.unknown,
          message: 'Failed to mark all notifications as read',
          originalError: e,
          stackTrace: st,
        ),
      );
    }
  }

  /// Delete a notification
  Future<ApiResult<void>> deleteNotification(String notificationId) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', notificationId);

      return ApiResult<void>.success(null);
    } catch (e, st) {
      debugPrint('Error deleting notification: $e\n$st');
      return ApiResult<void>.failure(
        AppError(
          type: ErrorType.unknown,
          message: 'Failed to delete notification',
          originalError: e,
          stackTrace: st,
        ),
      );
    }
  }

  /// Create a new notification (for backend use)
  Future<ApiResult<NotificationModel>> createNotification({
    required String userId,
    required String title,
    required String message,
    String? actionType,
    String? actionId,
  }) async {
    try {
      final response = await _supabase.from(_tableName).insert({
        'user_id': userId,
        'title': title,
        'message': message,
        'is_read': false,
        'action_type': actionType,
        'action_id': actionId,
        'created_at': DateTime.now().toIso8601String(),
      }).select();

      final notification = NotificationModel.fromJson(
        (response as List)[0] as Map<String, dynamic>,
      );
      return ApiResult<NotificationModel>.success(notification);
    } catch (e, st) {
      debugPrint('Error creating notification: $e\n$st');
      return ApiResult<NotificationModel>.failure(
        AppError(
          type: ErrorType.unknown,
          message: 'Failed to create notification',
          originalError: e,
          stackTrace: st,
        ),
      );
    }
  }

  /// Setup real-time subscription for new notifications
  void subscribeToNotifications({
    required String userId,
    required Function(NotificationModel) onNotification,
    required Function(dynamic error) onError,
  }) {
    // Realtime API surface varies between supabase client versions.
    // To keep analyzer happy and avoid runtime errors, provide a no-op
    // placeholder here. Callers can implement polling or a platform
    // specific realtime integration if needed.
    debugPrint('subscribeToNotifications: realtime not enabled in this build');
  }

  /// Unsubscribe from real-time notifications (no-op placeholder)
  Future<void> unsubscribeFromNotifications(String userId) async {
    debugPrint('unsubscribeFromNotifications: noop');
    return;
  }
}
