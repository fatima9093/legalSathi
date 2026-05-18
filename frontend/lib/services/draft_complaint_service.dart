import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:front_end/models/draft_complaint_model.dart';

class DraftComplaintService {
  SupabaseClient get _client => Supabase.instance.client;

  bool _isMissingTableError(Object e) {
    final err = e.toString();
    return err.contains('Could not find the table') ||
        err.contains('schema cache') ||
        err.contains('42P01') ||
        (err.contains('draft_complaints') && (err.contains('not find') || err.contains('does not exist')));
  }

  String? get currentUserId =>
      _client.auth.currentSession?.user.id ?? _client.auth.currentUser?.id;

  /// Saves a draft complaint to the draft_complaints table.
  Future<Map<String, dynamic>> saveDraft(DraftComplaintModel draft) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return {'success': false, 'message': 'Please sign in to save your draft.'};
      }

      final now = DateTime.now();
      final toSave = DraftComplaintModel(
        id: draft.id,
        userId: userId,
        fullName: draft.fullName,
        cnic: draft.cnic,
        phone: draft.phone,
        email: draft.email,
        designation: draft.designation,
        workplace: draft.workplace,
        address: draft.address,
        dateOfIncident: draft.dateOfIncident,
        description: draft.description,
        evidence: draft.evidence,
        witnesses: draft.witnesses,
        mentalImpact: draft.mentalImpact,
        emotionalImpact: draft.emotionalImpact,
        safetyConcerns: draft.safetyConcerns,
        reliefSought: draft.reliefSought,
        createdAt: draft.createdAt ?? now,
        updatedAt: now,
      );

      final row = toSave.toRow();
      row.remove('id'); // let DB generate on insert
      row['updated_at'] = now.toIso8601String();

      final res = await _client.from('draft_complaints').insert(row).select('id').single();
      final id = res['id']?.toString();

      return {
        'success': true,
        'message': 'Draft saved successfully',
        'id': id,
      };
    } catch (e) {
      if (_isMissingTableError(e)) {
        return {
          'success': true,
          'cloudSaved': false,
          'message': 'Draft generated, but database table is missing.',
        };
      }
      return {
        'success': false,
        'message': 'Error saving draft: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getDraft(String id) async {
    try {
      final res = await _client
          .from('draft_complaints')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (res != null) {
        final draft = DraftComplaintModel.fromRow(Map<String, dynamic>.from(res as Map));
        return {'success': true, 'draft': draft};
      }
      return {'success': false, 'message': 'Draft not found'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching draft: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getUserDrafts() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      final list = await _client
          .from('draft_complaints')
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      final drafts = (list as List)
          .map((e) => DraftComplaintModel.fromRow(Map<String, dynamic>.from(e as Map)))
          .toList();
      return {'success': true, 'drafts': drafts};
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching drafts: ${e.toString()}',
      };
    }
  }
}
