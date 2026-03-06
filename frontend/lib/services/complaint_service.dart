import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:front_end/models/complaint_model.dart';

class ComplaintService {
  SupabaseClient get _client => Supabase.instance.client;

  String? get currentUserId =>
      _client.auth.currentSession?.user.id ?? _client.auth.currentUser?.id;

  Future<Map<String, dynamic>> saveComplaint(ComplaintModel complaint) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      final complaintId = complaint.complaintId ?? _generateId();
      final updatedComplaint = complaint.copyWith(
        complaintId: complaintId,
        userId: userId,
        updatedAt: DateTime.now(),
        createdAt: complaint.createdAt ?? DateTime.now(),
      );

      final row = _complaintToRow(updatedComplaint);
      await _client.from('complaints').upsert(row, onConflict: 'complaint_id');

      return {
        'success': true,
        'message': 'Complaint saved successfully',
        'complaintId': complaintId,
        'complaint': updatedComplaint,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error saving complaint: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getComplaint(String complaintId) async {
    try {
      final res = await _client
          .from('complaints')
          .select()
          .eq('complaint_id', complaintId)
          .maybeSingle();
      if (res != null) {
        final complaint = _rowToComplaint(Map<String, dynamic>.from(res as Map));
        return {'success': true, 'complaint': complaint};
      }
      return {'success': false, 'message': 'Complaint not found'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching complaint: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getUserComplaints() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      final list = await _client
          .from('complaints')
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      final complaints = (list as List)
          .map((e) => _rowToComplaint(Map<String, dynamic>.from(e as Map)))
          .toList();
      return {'success': true, 'complaints': complaints};
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching complaints: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> addEvidenceMetadata({
    required String complaintId,
    required String fileName,
    required String fileType,
    required String localPath,
    required int fileSize,
  }) async {
    try {
      final result = await getComplaint(complaintId);
      if (!result['success']) return result;

      final complaint = result['complaint'] as ComplaintModel;
      final evidenceFiles = List<EvidenceFile>.from(complaint.evidenceFiles ?? []);
      evidenceFiles.add(EvidenceFile(
        fileName: fileName,
        fileType: fileType,
        localPath: localPath,
        fileSize: fileSize,
        uploadedAt: DateTime.now(),
      ));

      final updatedComplaint = complaint.copyWith(
        evidenceFiles: evidenceFiles,
        updatedAt: DateTime.now(),
      );
      await _client.from('complaints').update(_complaintToRow(updatedComplaint)).eq('complaint_id', complaintId);

      return {
        'success': true,
        'message': 'Evidence added successfully',
        'complaint': updatedComplaint,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error adding evidence: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> removeEvidenceFile({
    required String complaintId,
    required String fileName,
  }) async {
    try {
      final result = await getComplaint(complaintId);
      if (!result['success']) return result;

      final complaint = result['complaint'] as ComplaintModel;
      final evidenceFiles = List<EvidenceFile>.from(complaint.evidenceFiles ?? []);
      evidenceFiles.removeWhere((file) => file.fileName == fileName);

      final updatedComplaint = complaint.copyWith(
        evidenceFiles: evidenceFiles,
        updatedAt: DateTime.now(),
      );
      await _client.from('complaints').update(_complaintToRow(updatedComplaint)).eq('complaint_id', complaintId);

      return {'success': true, 'message': 'Evidence removed successfully'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Error removing evidence: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> submitComplaint(String complaintId) async {
    try {
      await _client.from('complaints').update({
        'status': 'submitted',
        'submitted_at': DateTime.now().toIso8601String(),
      }).eq('complaint_id', complaintId);

      return {'success': true, 'message': 'Complaint submitted successfully'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Error submitting complaint: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> deleteComplaint(String complaintId) async {
    try {
      await _client.from('complaints').delete().eq('complaint_id', complaintId);
      return {'success': true, 'message': 'Complaint deleted successfully'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Error deleting complaint: ${e.toString()}',
      };
    }
  }

  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 1000 + (timestamp % 1000)).toString();
    return 'complaint_$random';
  }

  Map<String, dynamic> _complaintToRow(ComplaintModel c) {
    return {
      'complaint_id': c.complaintId,
      'user_id': c.userId,
      'full_name': c.fullName,
      'cnic': c.cnic,
      'phone': c.phone,
      'email': c.email,
      'workplace': c.workplace,
      'designation': c.designation,
      'city': c.city,
      'incident_date': c.incidentDate,
      'harassment_type': c.harassmentType,
      'description': c.description,
      'accused_name': c.accusedName,
      'accused_designation': c.accusedDesignation,
      'evidence_files': c.evidenceFiles?.map((e) => e.toMap()).toList() ?? [],
      'created_at': c.createdAt?.toIso8601String(),
      'updated_at': c.updatedAt?.toIso8601String(),
      'status': c.status ?? 'draft',
    };
  }

  ComplaintModel _rowToComplaint(Map<String, dynamic> row) {
    final evidence = row['evidence_files'];
    final list = evidence is List
        ? (evidence)
            .map((e) => EvidenceFile.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList()
        : <EvidenceFile>[];
    final createdAt = row['created_at'];
    final updatedAt = row['updated_at'];
    return ComplaintModel(
      complaintId: row['complaint_id'] as String?,
      userId: row['user_id']?.toString(),
      fullName: row['full_name'] as String?,
      cnic: row['cnic'] as String?,
      phone: row['phone'] as String?,
      email: row['email'] as String?,
      workplace: row['workplace'] as String?,
      designation: row['designation'] as String?,
      city: row['city'] as String?,
      incidentDate: row['incident_date'] as String?,
      harassmentType: row['harassment_type'] as String?,
      description: row['description'] as String?,
      accusedName: row['accused_name'] as String?,
      accusedDesignation: row['accused_designation'] as String?,
      evidenceFiles: list.isEmpty ? null : list,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt.toString()) : null,
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt.toString()) : null,
      status: row['status'] as String?,
    );
  }
}
