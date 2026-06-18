import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const String _tableName = 'notifications';
  RealtimeChannel? _realtimeChannel;

  /// Initialize local notifications
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  /// Show a local notification
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'legal_sathi_channel',
          'Legal Sathi Notifications',
          channelDescription: 'Notifications from Legal Sathi app',
          importance: Importance.max,
          priority: Priority.high,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }

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
          message: 'Error fetching notifications',
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
          message: 'Error fetching unread count',
          originalError: e,
          stackTrace: st,
        ),
      );
    }
  }

  /// Mark notification as read
  Future<ApiResult<void>> markAsRead(String notificationId) async {
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
          .eq('id', notificationId);

      return ApiResult<void>.success(null);
    } catch (e, st) {
      debugPrint('Error marking notification as read: $e\n$st');
      return ApiResult<void>.failure(
        AppError(
          type: ErrorType.unknown,
          message: 'Error marking notification as read',
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
          message: 'Error marking all notifications as read',
          originalError: e,
          stackTrace: st,
        ),
      );
    }
  }

  /// Delete a notification
  Future<ApiResult<void>> deleteNotification(String notificationId) async {
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

      await _supabase.from(_tableName).delete().eq('id', notificationId);

      return ApiResult<void>.success(null);
    } catch (e, st) {
      debugPrint('Error deleting notification: $e\n$st');
      return ApiResult<void>.failure(
        AppError(
          type: ErrorType.unknown,
          message: 'Error deleting notification',
          originalError: e,
          stackTrace: st,
        ),
      );
    }
  }

  /// Create a new notification for current user (for client-side use)
  Future<ApiResult<NotificationModel>> createNotificationForCurrentUser({
    required String title,
    required String message,
    String? actionType,
    String? actionId,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return ApiResult<NotificationModel>.failure(
        AppError(
          type: ErrorType.unauthorized,
          message: 'User not authenticated',
        ),
      );
    }
    return createNotification(
      userId: userId,
      title: title,
      message: message,
      actionType: actionType,
      actionId: actionId,
    );
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
      await showLocalNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: message,
      );
      return ApiResult<NotificationModel>.success(notification);
    } catch (e, st) {
      debugPrint('Error creating notification: $e\n$st');
      await showLocalNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: message,
      );
      return ApiResult<NotificationModel>.failure(
        AppError(
          type: ErrorType.unknown,
          message: 'Error creating notification',
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
    _realtimeChannel = _supabase.channel('notifications:$userId');
    _realtimeChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final newNotification = NotificationModel.fromJson(
              payload.newRecord,
            );
            onNotification(newNotification);
          },
        )
        .subscribe();
  }

  /// Unsubscribe from real-time notifications
  Future<void> unsubscribeFromNotifications(String userId) async {
    if (_realtimeChannel != null) {
      await _supabase.removeChannel(_realtimeChannel!);
      _realtimeChannel = null;
    }
  }
}
