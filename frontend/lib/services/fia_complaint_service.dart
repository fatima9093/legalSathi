import 'package:supabase_flutter/supabase_flutter.dart';

class FIAComplaintService {
  SupabaseClient get _client => Supabase.instance.client;

  String? get _userId =>
      _client.auth.currentSession?.user.id ?? _client.auth.currentUser?.id;

  bool _isMissingTableError(Object e) {
    final err = e.toString();
    return err.contains('Could not find the table') ||
        err.contains('schema cache') ||
        err.contains('42P01') ||
        (err.contains('fia_complaints') &&
            (err.contains('not find') || err.contains('does not exist')));
  }

  Future<Map<String, dynamic>> saveComplaint({
    required String fullName,
    required String cnic,
    required String phone,
    required String email,
    required String address,
    required String dateOfIncident,
    required String incidentDescription,
    required String suspectInfo,
    required String evidenceAvailable,
  }) async {
    final userId = _userId;
    if (userId == null) {
      return {
        'success': false,
        'needAuth': true,
        'message': 'Sign in to save this complaint to your account.',
      };
    }

    try {
      final row = {
        'user_id': userId,
        'full_name': fullName,
        'cnic': cnic,
        'phone': phone,
        'email': email,
        'address': address.isEmpty ? null : address,
        'date_of_incident': dateOfIncident,
        'incident_description': incidentDescription,
        'suspect_info': suspectInfo.isEmpty ? null : suspectInfo,
        'evidence_available': evidenceAvailable.isEmpty ? null : evidenceAvailable,
      };

      final res = await _client
          .from('fia_complaints')
          .insert(row)
          .select('id')
          .single();

      return {
        'success': true,
        'cloudSaved': true,
        'id': res['id']?.toString(),
      };
    } catch (e) {
      if (_isMissingTableError(e)) {
        return {
          'success': true,
          'cloudSaved': false,
          'missingTable': true,
          'message': 'Complaint generated, but database table is missing.',
        };
      }
      return {
        'success': false,
        'message': 'Could not save: $e',
      };
    }
  }
}

