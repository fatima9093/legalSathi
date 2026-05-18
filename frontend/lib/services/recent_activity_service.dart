import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recent_activity_model.dart';

/// Service to fetch recent activities for the home screen
class RecentActivityService {
  final SupabaseClient _client = Supabase.instance.client;
  static final Set<String> _loggedQueryErrors = <String>{};

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(value);
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  void _logQueryErrorOnce(String key, Object error) {
    if (_loggedQueryErrors.add(key)) {
      debugPrint('Supabase query error [$key]: $error');
    }
  }

  RecentActivityModel _fromConversationSession(Map<String, dynamic> row) {
    final metadata = _asMap(row['metadata']);
    final preview = (metadata['preview_text'] as String?)?.trim();
    final summary = (row['summary'] as String?)?.trim();
    return RecentActivityModel.fromJson({
      'id': row['id'],
      'title': 'Chat Session',
      'description': (preview != null && preview.isNotEmpty)
          ? preview
          : (summary != null && summary.isNotEmpty)
          ? summary
          : 'Saved chat history',
      'type': 'chat_session',
      'icon': 'chat',
      'timestamp': row['updated_at'] ?? row['created_at'],
      'related_id': row['id'],
    });
  }

  RecentActivityModel _fromActivityLog(Map<String, dynamic> row) {
    final activityType = (row['activity_type'] as String?)?.trim();
    final description = (row['description'] as String?)?.trim();
    return RecentActivityModel.fromJson({
      'id': row['id'],
      'title': activityType != null && activityType.isNotEmpty
          ? activityType
                .replaceAll('_', ' ')
                .split(' ')
                .map(
                  (part) => part.isEmpty
                      ? part
                      : '${part[0].toUpperCase()}${part.substring(1)}',
                )
                .join(' ')
          : 'Activity',
      'description': description ?? '',
      'type': activityType ?? 'activity',
      'icon': row['icon'] ?? 'history',
      'timestamp': row['created_at'] ?? row['timestamp'],
      'related_id': row['resource_id'] ?? row['related_id'],
    });
  }

  /// Get recent activities for the current user
  /// Fetches from draft_complaints and other activity sources
  Future<List<RecentActivityModel>> getRecentActivities({
    String? userId,
    int limit = 5,
  }) async {
    try {
      // If no userId provided, use current user
      final uid = userId ?? _client.auth.currentUser?.id;
      if (uid == null) return [];

      final activities = <RecentActivityModel>[];

      // Fetch recent chat sessions
      try {
        final sessions = await _client
            .from('conversation_sessions')
            .select()
            .eq('user_id', uid)
            .order('updated_at', ascending: false)
            .limit(limit);

        for (final session in sessions) {
          activities.add(_fromConversationSession(_asMap(session)));
        }
      } catch (e) {
        _logQueryErrorOnce('recentActivities.conversationSessions', e);
      }

      // Fetch recent draft complaints
      try {
        final draftComplaints = await _client
            .from('draft_complaints')
            .select()
            .eq('user_id', uid)
            .order('created_at', ascending: false)
            .limit(limit);

        for (var complaint in draftComplaints) {
          activities.add(RecentActivityModel.fromDraftComplaint(complaint));
        }
      } catch (e) {
        _logQueryErrorOnce('recentActivities.draftComplaints', e);
      }

      // Fetch from activity_logs table if it exists
      try {
        final activityLogs = await _client
            .from('activity_logs')
            .select()
            .eq('user_id', uid)
            .order('created_at', ascending: false)
            .limit(limit);

        for (var log in activityLogs) {
          activities.add(_fromActivityLog(_asMap(log)));
        }
      } catch (e) {
        _logQueryErrorOnce('recentActivities.activityLogs', e);
      }

      // Sort all activities by timestamp and take top limit
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return activities.take(limit).toList();
    } catch (e) {
      _logQueryErrorOnce('recentActivities.root', e);
      return [];
    }
  }

  /// Get a single activity by ID
  Future<RecentActivityModel?> getActivityById(String id) async {
    try {
      final result = await _client
          .from('activity_logs')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (result != null) {
        return _fromActivityLog(_asMap(result));
      }
      return null;
    } catch (e) {
      _logQueryErrorOnce('recentActivities.activityById', e);
      return null;
    }
  }

  /// Log a new activity
  Future<RecentActivityModel?> logActivity({
    required String title,
    required String description,
    required String type,
    String? icon,
    String? relatedId,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      final now = DateTime.now();
      final result = await _client
          .from('activity_logs')
          .insert({
            'user_id': userId,
            'activity_type': type,
            'description': description,
            'icon': icon,
            'resource_id': relatedId,
            'created_at': now.toIso8601String(),
            'metadata': {'title': title, 'type': type},
          })
          .select()
          .single();

      return _fromActivityLog(_asMap(result));
    } catch (e) {
      _logQueryErrorOnce('recentActivities.logActivity', e);
      return null;
    }
  }

  /// Stream recent activities for real-time updates
  Stream<List<RecentActivityModel>> watchRecentActivities({
    String? userId,
    int limit = 5,
  }) {
    try {
      final uid = userId ?? _client.auth.currentUser?.id;
      if (uid == null) {
        return Stream.value([]);
      }

      return _client
          .from('conversation_sessions')
          .stream(primaryKey: ['id'])
          .eq('user_id', uid)
          .order('updated_at')
          .map((List<Map<String, dynamic>> data) {
            return data
                .map((e) => _fromConversationSession(_asMap(e)))
                .take(limit)
                .toList();
          });
    } catch (e) {
      _logQueryErrorOnce('recentActivities.watch', e);
      return Stream.value([]);
    }
  }
}
