import 'package:flutter/material.dart';
import 'package:front_end/models/error_models.dart';
import 'package:front_end/models/complaint_status_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ComplaintStatusService {
  static final ComplaintStatusService _instance =
      ComplaintStatusService._internal();

  factory ComplaintStatusService() {
    return _instance;
  }

  ComplaintStatusService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get current status of a complaint
  Future<ApiResult<ComplaintStatus>> getComplaintStatus(
    String complaintId,
  ) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return ApiResult<ComplaintStatus>.failure(
          AppError(
            type: ErrorType.unauthorized,
            message: 'User not authenticated',
          ),
        );
      }

      final response = await _supabase
          .from('complaints')
          .select('status')
          .match({'complaint_id': complaintId})
          .single();

      final status = ComplaintStatus.fromString(response['status'] as String?);
      return ApiResult<ComplaintStatus>.success(status);
    } catch (e, st) {
      debugPrint('Error fetching complaint status: $e\n$st');
      return ApiResult<ComplaintStatus>.failure(
        AppError(
          type: ErrorType.unknown,
          message: 'Failed to fetch complaint status',
          originalError: e,
          stackTrace: st,
        ),
      );
    }
  }

  /// Get status history for a complaint
  Future<ApiResult<List<ComplaintStatusHistory>>> getStatusHistory(
    String complaintId,
  ) async {
    try {
      final response = await _supabase
          .from('complaint_status_history')
          .select()
          .match({'complaint_id': complaintId})
          .order('changed_at', ascending: false);

      final history = (response as List)
          .map(
            (json) =>
                ComplaintStatusHistory.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      return ApiResult<List<ComplaintStatusHistory>>.success(history);
    } catch (e, st) {
      debugPrint('Error fetching status history: $e\n$st');
      return ApiResult<List<ComplaintStatusHistory>>.failure(
        AppError(
          type: ErrorType.unknown,
          message: 'Failed to fetch status history',
          originalError: e,
          stackTrace: st,
        ),
      );
    }
  }

  /// Update complaint status (admin/system only)
  Future<ApiResult<void>> updateComplaintStatus({
    required String complaintId,
    required ComplaintStatus newStatus,
    String? notes,
  }) async {
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

      // Update complaint status
      await _supabase
          .from('complaints')
          .update({'status': newStatus.value})
          .eq('complaint_id', complaintId);

      // Add to history
      await _supabase.from('complaint_status_history').insert({
        'complaint_id': complaintId,
        'status': newStatus.value,
        'changed_by': userId,
        'notes': notes,
        'changed_at': DateTime.now().toIso8601String(),
      });

      return ApiResult<void>.success(null);
    } catch (e, st) {
      debugPrint('Error updating complaint status: $e\n$st');
      return ApiResult<void>.failure(
        AppError(
          type: ErrorType.unknown,
          message: 'Failed to update complaint status',
          originalError: e,
          stackTrace: st,
        ),
      );
    }
  }

  /// Get all complaints with a specific status for a user
  Future<ApiResult<List<Map<String, dynamic>>>> getComplaintsByStatus({
    required String userId,
    required ComplaintStatus status,
  }) async {
    try {
      final response = await _supabase
          .from('complaints')
          .select()
          .match({'user_id': userId, 'status': status.value})
          .order('created_at', ascending: false);

      return ApiResult<List<Map<String, dynamic>>>.success(response);
    } catch (e, st) {
      debugPrint('Error fetching complaints by status: $e\n$st');
      return ApiResult<List<Map<String, dynamic>>>.failure(
        AppError(
          type: ErrorType.unknown,
          message: 'Failed to fetch complaints',
          originalError: e,
          stackTrace: st,
        ),
      );
    }
  }

  /// Get status statistics for a user
  Future<ApiResult<Map<String, int>>> getStatusStatistics(String userId) async {
    try {
      final stats = <String, int>{};

      for (final status in ComplaintStatus.values) {
        final response = await _supabase
            .from('complaints')
            .select('complaint_id')
            .match({'user_id': userId, 'status': status.value});

        stats[status.displayName] = (response as List).length;
      }

      return ApiResult<Map<String, int>>.success(stats);
    } catch (e, st) {
      debugPrint('Error fetching status statistics: $e\n$st');
      return ApiResult<Map<String, int>>.failure(
        AppError(
          type: ErrorType.unknown,
          message: 'Failed to fetch statistics',
          originalError: e,
          stackTrace: st,
        ),
      );
    }
  }

  /// Subscribe to status changes (real-time)
  void subscribeToStatusChanges({
    required String complaintId,
    required Function(ComplaintStatus) onStatusChange,
    required Function(dynamic error) onError,
  }) {
    // Realtime API is disabled in this build to avoid analyzer/runtime issues.
    debugPrint('subscribeToStatusChanges: realtime not enabled in this build');
  }

  /// Unsubscribe from status changes
  Future<void> unsubscribeFromStatusChanges(String complaintId) async {
    debugPrint('unsubscribeFromStatusChanges: noop');
    return;
  }
}
