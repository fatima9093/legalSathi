import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAccountReportService {
  SupabaseClient get _client => Supabase.instance.client;

  String? get currentUserId =>
      _client.auth.currentSession?.user.id ?? _client.auth.currentUser?.id;

  Future<Map<String, dynamic>> saveReport({
    required String platform,
    required String profileUrl,
    required String username,
    required List<PlatformFile> evidenceFiles,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return {
          'success': false,
          'message': 'Sign in to save this report to your account.',
        };
      }

      final reportId = 'fake_account_${DateTime.now().millisecondsSinceEpoch}';
      final row = {
        'report_id': reportId,
        'user_id': userId,
        'platform': platform,
        'profile_url': profileUrl.isEmpty ? null : profileUrl,
        'username': username.isEmpty ? null : username,
        'evidence_files': evidenceFiles
            .map((f) => {
                  'fileName': f.name,
                  'fileSize': f.size,
                  'extension': f.extension,
                })
            .toList(),
        'status': 'draft',
      };

      await _client.from('fake_account_reports').insert(row);

      return {
        'success': true,
        'message': 'Report saved successfully.',
        'reportId': reportId,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Could not save report: $e',
      };
    }
  }
}

