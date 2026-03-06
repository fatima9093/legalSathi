import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:front_end/models/blackmail_model.dart';
import 'package:front_end/services/auth_service.dart';

class BlackmailService {
  SupabaseClient get _client => Supabase.instance.client;

  AppUser? get currentUser {
    final user = _client.auth.currentSession?.user ?? _client.auth.currentUser;
    if (user == null) return null;
    final meta = user.userMetadata;
    final name = meta?['full_name'] as String? ?? meta?['full_name']?.toString();
    return AppUser(
      id: user.id,
      email: user.email,
      displayName: name?.isNotEmpty == true ? name : null,
    );
  }

  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 1000 + (timestamp % 1000)).toString();
    return 'blackmail_$random';
  }

  Future<Map<String, dynamic>> saveBlackmailCase(BlackmailModel blackmail) async {
    try {
      final user = currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      String blackmailId = blackmail.blackmailId ?? _generateId();
      DateTime now = DateTime.now();

      BlackmailModel blackmailToSave = blackmail.copyWith(
        blackmailId: blackmailId,
        userId: user.id,
        userEmail: user.email,
        createdAt: blackmail.createdAt ?? now,
        updatedAt: now,
      );

      final row = _blackmailToRow(blackmailToSave);
      await _client.from('blackmail_cases').upsert(row, onConflict: 'blackmail_id');

      return {
        'success': true,
        'message': 'Blackmail case saved successfully!',
        'blackmailId': blackmailId,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error saving blackmail case: $e'};
    }
  }

  Future<Map<String, dynamic>> getBlackmailCase(String blackmailId) async {
    try {
      final res = await _client
          .from('blackmail_cases')
          .select()
          .eq('blackmail_id', blackmailId)
          .maybeSingle();
      if (res != null) {
        final model = _rowToBlackmail(Map<String, dynamic>.from(res as Map));
        return {'success': true, 'blackmail': model};
      }
      return {'success': false, 'message': 'Blackmail case not found'};
    } catch (e) {
      return {'success': false, 'message': 'Error fetching blackmail case: $e'};
    }
  }

  Future<Map<String, dynamic>> getUserBlackmailCases() async {
    try {
      final user = currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      final list = await _client
          .from('blackmail_cases')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final cases = (list as List)
          .map((e) => _rowToBlackmail(Map<String, dynamic>.from(e as Map)))
          .toList();
      return {'success': true, 'cases': cases};
    } catch (e) {
      return {'success': false, 'message': 'Error fetching blackmail cases: $e'};
    }
  }

  Map<String, dynamic> _blackmailToRow(BlackmailModel b) {
    return {
      'blackmail_id': b.blackmailId,
      'user_id': b.userId,
      'user_email': b.userEmail,
      'situation': b.situation,
      'evidence_files': b.evidenceFiles?.map((e) => e.toMap()).toList() ?? [],
      'created_at': b.createdAt?.toIso8601String(),
      'updated_at': b.updatedAt?.toIso8601String(),
    };
  }

  BlackmailModel _rowToBlackmail(Map<String, dynamic> row) {
    final createdAt = row['created_at'];
    final updatedAt = row['updated_at'];
    return BlackmailModel(
      blackmailId: row['blackmail_id'] as String?,
      userId: row['user_id']?.toString(),
      userEmail: row['user_email'] as String?,
      situation: row['situation'] as String?,
      evidenceFiles: (row['evidence_files'] as List<dynamic>?)
          ?.map((e) => EvidenceFile.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      createdAt: createdAt != null ? DateTime.tryParse(createdAt.toString()) : null,
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt.toString()) : null,
    );
  }
}
