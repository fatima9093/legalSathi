import 'package:supabase_flutter/supabase_flutter.dart';

/// Persists traffic police misbehaviour complaint drafts from the AI generator.
class TrafficPoliceComplaintService {
  SupabaseClient get _client => Supabase.instance.client;

  String? get _userId =>
      _client.auth.currentSession?.user.id ?? _client.auth.currentUser?.id;

  bool _isMissingTableError(Object e) {
    final err = e.toString();
    return err.contains('Could not find the table') ||
        err.contains('schema cache') ||
        err.contains('42P01') ||
        (err.contains('traffic_police_complaints') &&
            (err.contains('not find') || err.contains('does not exist')));
  }

  /// Inserts a new row, or updates [existingComplaintId] when the user edits an existing draft.
  Future<Map<String, dynamic>> saveSubmission({
    String? existingComplaintId,
    required String whatHappened,
    required String incidentLocation,
    required String incidentDate,
    required String incidentTime,
    required String officerId,
    required String witnesses,
    required String complainantName,
    required String contactNumber,
    required String cnic,
  }) async {
    final userId = _userId;
    if (userId == null) {
      return {
        'success': false,
        'needAuth': true,
        'message': 'Sign in to save this complaint to your account.',
      };
    }

    final contentRow = <String, dynamic>{
      'what_happened': whatHappened,
      'incident_location': incidentLocation,
      'incident_date': incidentDate,
      'incident_time': incidentTime,
      'officer_id': officerId.isEmpty ? null : officerId,
      'witnesses': witnesses.isEmpty ? null : witnesses,
      'complainant_name': complainantName,
      'contact_number': contactNumber,
      'cnic': cnic,
    };

    final updateId = existingComplaintId?.trim();
    final isUpdate = updateId != null && updateId.isNotEmpty;

    try {
      if (isUpdate) {
        final res = await _client
            .from('traffic_police_complaints')
            .update(contentRow)
            .eq('id', updateId)
            .eq('user_id', userId)
            .select('id')
            .single();

        return {
          'success': true,
          'cloudSaved': true,
          'message': 'Complaint updated in your account.',
          'id': res['id']?.toString(),
        };
      }

      final row = <String, dynamic>{
        'user_id': userId,
        ...contentRow,
      };

      final res = await _client
          .from('traffic_police_complaints')
          .insert(row)
          .select('id')
          .single();

      return {
        'success': true,
        'cloudSaved': true,
        'message': 'Complaint details saved to your account.',
        'id': res['id']?.toString(),
      };
    } catch (e) {
      if (_isMissingTableError(e)) {
        return {
          'success': true,
          'cloudSaved': false,
          'message': 'Your complaint letter is ready.',
          if (isUpdate) 'id': updateId,
        };
      }
      return {
        'success': false,
        'needAuth': false,
        'message': 'Could not save: $e',
      };
    }
  }
}
