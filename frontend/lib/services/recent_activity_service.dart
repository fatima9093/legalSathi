import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recent_activity_model.dart';

/// Service to fetch recent activities for the home screen
class RecentActivityService {
  final SupabaseClient _client = Supabase.instance.client;

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
        // ignore: avoid_print
        print('Error fetching draft complaints: $e');
      }

      // Fetch from activity_log table if it exists
      try {
        final activityLogs = await _client
            .from('activity_log')
            .select()
            .eq('user_id', uid)
            .order('created_at', ascending: false)
            .limit(limit);

        for (var log in activityLogs) {
          activities.add(RecentActivityModel.fromJson(log));
        }
      } catch (e) {
        // activity_log table might not exist yet, that's ok
        // ignore: avoid_print
        print('Activity log table not found: $e');
      }

      // Sort all activities by timestamp and take top limit
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return activities.take(limit).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching recent activities: $e');
      return [];
    }
  }

  /// Get a single activity by ID
  Future<RecentActivityModel?> getActivityById(String id) async {
    try {
      final result = await _client
          .from('activity_log')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (result != null) {
        return RecentActivityModel.fromJson(result);
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching activity: $e');
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
          .from('activity_log')
          .insert({
            'user_id': userId,
            'title': title,
            'description': description,
            'type': type,
            'icon': icon,
            'timestamp': now.toIso8601String(),
            'related_id': relatedId,
          })
          .select()
          .single();

      return RecentActivityModel.fromJson(result);
    } catch (e) {
      // ignore: avoid_print
      print('Error logging activity: $e');
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
          .from('draft_complaints')
          .stream(primaryKey: ['id'])
          .eq('user_id', uid)
          .order('created_at')
          .map((List<Map<String, dynamic>> data) {
            return data
                .map((e) => RecentActivityModel.fromDraftComplaint(e))
                .take(limit)
                .toList();
          });
    } catch (e) {
      // ignore: avoid_print
      print('Error watching activities: $e');
      return Stream.value([]);
    }
  }
}
