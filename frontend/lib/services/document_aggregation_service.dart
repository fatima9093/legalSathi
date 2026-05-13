import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:front_end/models/unified_document_model.dart';
import 'package:front_end/services/http_client_wrapper.dart';
import 'package:front_end/models/error_models.dart';

/// Service to aggregate documents from all sources across the app
class DocumentAggregationService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  DocumentAggregationService(HttpClientWrapper _);
  String? get _currentUserId =>
      _supabaseClient.auth.currentSession?.user.id ??
      _supabaseClient.auth.currentUser?.id;

  /// Main method to fetch all documents from all sources
  Future<ApiResult<AggregatedDocumentsResponse>> getAllDocuments() async {
    try {
      if (_currentUserId == null) {
        return ApiResult<AggregatedDocumentsResponse>.failure(
          AppError(
            type: ErrorType.unauthorized,
            message: 'User not authenticated',
          ),
        );
      }

      final allDocuments = <UnifiedDocument>[];

      // 1. Fetch personal uploaded documents from Supabase
      try {
        final personalDocs = await _fetchPersonalDocuments();
        allDocuments.addAll(personalDocs);
      } catch (e) {
        // Error fetching personal documents, continue with other sources
      }

      // 2. Fetch complaints as PDFs (Women Harassment)
      try {
        final complaints = await _fetchComplaintDocuments();
        allDocuments.addAll(complaints);
      } catch (e) {
        // Error fetching complaint documents, continue with other sources
      }

      // 3. Fetch evidence files attached to complaints
      try {
        final evidenceFiles = await _fetchEvidenceFiles();
        allDocuments.addAll(evidenceFiles);
      } catch (e) {
        // Error fetching evidence files, continue with other sources
      }

      // 4. Fetch wage records and calculations (Labour module)
      try {
        final wageRecords = await _fetchWageRecords();
        allDocuments.addAll(wageRecords);
      } catch (e) {
        // Error fetching wage records, continue with other sources
      }

      // 5. Fetch FIA complaint documents (Cyber Law)
      try {
        final fiaDocuments = await _fetchFIAComplaintDocuments();
        allDocuments.addAll(fiaDocuments);
      } catch (e) {
        // Error fetching FIA complaint documents, continue with other sources
      }

      // 6. Fetch traffic police complaint documents
      try {
        final trafficDocuments = await _fetchTrafficComplaintDocuments();
        allDocuments.addAll(trafficDocuments);
      } catch (e) {
        // Error fetching traffic complaint documents, continue with other sources
      }

      // Remove duplicates and sort by creation date (newest first)
      final uniqueDocs = _removeDuplicates(allDocuments);
      uniqueDocs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Organize into categories
      final categories = _organizeIntoCategories(uniqueDocs);

      return ApiResult<AggregatedDocumentsResponse>.success(
        AggregatedDocumentsResponse(
          allDocuments: uniqueDocs,
          categories: categories,
          totalCount: uniqueDocs.length,
          lastFetched: DateTime.now(),
        ),
      );
    } catch (e, st) {
      return ApiResult<AggregatedDocumentsResponse>.failure(
        AppError(
          type: ErrorType.unknown,
          message: 'Failed to aggregate documents: ${e.toString()}',
          originalError: e,
          stackTrace: st,
        ),
      );
    }
  }

  /// Fetch personal uploaded documents from Supabase
  Future<List<UnifiedDocument>> _fetchPersonalDocuments() async {
    final response = await _supabaseClient
        .from('user_documents')
        .select()
        .eq('user_id', _currentUserId!)
        .eq('is_deleted', false)
        .order('created_at', ascending: false)
        .limit(500);

    return (response as List).map((doc) {
      return UnifiedDocument(
        id: doc['id'] as String,
        title: doc['title'] ?? doc['filename'] ?? 'Untitled',
        description: doc['description'],
        documentType: _parseDocumentType(doc['document_type']),
        sourceModule: DocumentSourceModule.personalDocuments,
        fileUrl: doc['file_url'] as String,
        localPath: null,
        createdAt: DateTime.parse(doc['created_at'] as String),
        updatedAt: doc['updated_at'] != null
            ? DateTime.parse(doc['updated_at'] as String)
            : null,
        fileSize: doc['file_size'] as int?,
        mimeType: doc['mime_type'],
        tags: List<String>.from(doc['tags'] as List? ?? []),
        metadata: {
          'sourceModule': doc['source_module'],
          'relatedComplaintId': doc['related_complaint_id'],
        },
      );
    }).toList();
  }

  /// Fetch complaints and generate their PDF representation
  Future<List<UnifiedDocument>> _fetchComplaintDocuments() async {
    final response = await _supabaseClient
        .from('complaints')
        .select()
        .eq('user_id', _currentUserId!)
        .order('created_at', ascending: false)
        .limit(500);

    return (response as List).map((complaint) {
      final status = complaint['status'] ?? 'draft';
      return UnifiedDocument(
        id: 'complaint_${complaint['complaint_id']}',
        title:
            '${complaint['harassment_type'] ?? 'Complaint'} - ${complaint['full_name'] ?? 'User'}',
        description:
            'Harassment complaint filed on ${complaint['incident_date'] ?? 'Unknown date'}\nStatus: ${status.toUpperCase()}',
        documentType: UnifiedDocumentType.complaintPdf,
        sourceModule: DocumentSourceModule.womenHarassment,
        fileUrl: '', // Will be generated on-demand
        createdAt: DateTime.parse(complaint['created_at'] as String),
        updatedAt: complaint['updated_at'] != null
            ? DateTime.parse(complaint['updated_at'] as String)
            : null,
        metadata: {
          'complaintId': complaint['complaint_id'],
          'harassmentType': complaint['harassment_type'],
          'incidentDate': complaint['incident_date'],
          'status': status,
          'workplace': complaint['workplace'],
          'accused': complaint['accused_name'],
        },
        tags: ['harassment', 'complaint', status],
        relatedComplaintId: complaint['complaint_id'] as String,
      );
    }).toList();
  }

  /// Fetch evidence files from complaints
  Future<List<UnifiedDocument>> _fetchEvidenceFiles() async {
    final response = await _supabaseClient
        .from('complaints')
        .select()
        .eq('user_id', _currentUserId!)
        .order('created_at', ascending: false)
        .limit(500);

    final evidenceFiles = <UnifiedDocument>[];

    for (final complaint in response as List) {
      final evidenceList = complaint['evidence_files'] as List? ?? [];
      for (int i = 0; i < evidenceList.length; i++) {
        final evidence = evidenceList[i];
        evidenceFiles.add(
          UnifiedDocument(
            id: 'evidence_${complaint['complaint_id']}_$i',
            title: evidence['fileName'] ?? 'Evidence File',
            description:
                'Evidence file attached to harassment complaint\nType: ${evidence['fileType'] ?? 'Unknown'}',
            documentType: UnifiedDocumentType.evidenceFile,
            sourceModule: DocumentSourceModule.womenHarassment,
            fileUrl: evidence['fileUrl'] ?? '',
            localPath: evidence['localPath'],
            createdAt: evidence['uploadedAt'] != null
                ? DateTime.fromMillisecondsSinceEpoch(evidence['uploadedAt'])
                : DateTime.now(),
            fileSize: evidence['fileSize'] as int?,
            tags: ['evidence', evidence['fileType'] ?? 'file'],
            relatedComplaintId: complaint['complaint_id'] as String,
            metadata: {
              'fileType': evidence['fileType'],
              'complaintId': complaint['complaint_id'],
            },
          ),
        );
      }
    }

    return evidenceFiles;
  }

  /// Fetch wage records and calculations from labour module
  Future<List<UnifiedDocument>> _fetchWageRecords() async {
    try {
      final response = await _supabaseClient
          .from('labour_wage_records')
          .select()
          .eq('user_id', _currentUserId!)
          .order('created_at', ascending: false)
          .limit(500);

      return (response as List).map((record) {
        final recordType = record['record_type'] ?? 'calculation';
        String title = 'Wage Record';
        String description = '';

        switch (recordType) {
          case 'back_pay':
            title = 'Back Pay Calculation';
            description =
                'Total Back Pay: PKR ${record['total_back_pay']?.toString() ?? 'N/A'}\nMonths Owed: ${record['months_owed'] ?? 0}';
            break;
          case 'overtime_calc':
            title = 'Overtime Calculation';
            description =
                'Total Overtime Pay: PKR ${record['overtime_pay_total']?.toString() ?? 'N/A'}\nOvertime Hours: ${record['overtime_hours'] ?? 0}';
            break;
          case 'wage_complaint':
            title = 'Wage Complaint';
            description =
                'Employer: ${record['employer_name'] ?? 'Unknown'}\nComplaint: ${record['complaint_issue'] ?? 'N/A'}';
            break;
          case 'overtime_complaint':
            title = 'Overtime Complaint';
            description =
                'Employer: ${record['employer_name'] ?? 'Unknown'}\nComplaint: ${record['complaint_issue'] ?? 'N/A'}';
            break;
          default:
            description = 'Labour record - Type: $recordType';
        }

        return UnifiedDocument(
          id: 'wage_${record['id']}',
          title: title,
          description: description,
          documentType: _wageRecordToDocumentType(recordType),
          sourceModule: DocumentSourceModule.labourRights,
          fileUrl: '', // Will be generated on-demand
          createdAt: DateTime.parse(record['created_at'] as String),
          metadata: record,
          tags: [recordType, 'labour', 'wage'],
        );
      }).toList();
    } catch (e) {
      // Error fetching wage records, continue with other sources
      return [];
    }
  }

  /// Fetch FIA complaint documents (Cyber Law)
  Future<List<UnifiedDocument>> _fetchFIAComplaintDocuments() async {
    try {
      final response = await _supabaseClient
          .from('fia_complaints')
          .select()
          .eq('user_id', _currentUserId!)
          .order('created_at', ascending: false)
          .limit(500);

      return (response as List).map((complaint) {
        final status = complaint['status'] ?? 'draft';
        return UnifiedDocument(
          id: 'fia_${complaint['complaint_id']}',
          title:
              'FIA Cyber Crime Complaint - ${complaint['full_name'] ?? 'User'}',
          description:
              'Cyber crime complaint filed\nStatus: ${status.toUpperCase()}\nType: ${complaint['complaint_type'] ?? 'Unknown'}',
          documentType: UnifiedDocumentType.complaintPdf,
          sourceModule: DocumentSourceModule.cyberLaw,
          fileUrl: '', // Will be generated on-demand
          createdAt: DateTime.parse(complaint['created_at'] as String),
          updatedAt: complaint['updated_at'] != null
              ? DateTime.parse(complaint['updated_at'] as String)
              : null,
          metadata: {
            'complaintId': complaint['complaint_id'],
            'complaintType': complaint['complaint_type'],
            'status': status,
          },
          tags: ['cyber', 'fia', 'complaint', status],
          relatedComplaintId: complaint['complaint_id'] as String,
        );
      }).toList();
    } catch (e) {
      // Error fetching FIA complaints, continue with other sources
      return [];
    }
  }

  /// Fetch traffic police complaint documents
  Future<List<UnifiedDocument>> _fetchTrafficComplaintDocuments() async {
    try {
      final response = await _supabaseClient
          .from('traffic_complaints')
          .select()
          .eq('user_id', _currentUserId!)
          .order('created_at', ascending: false)
          .limit(500);

      return (response as List).map((complaint) {
        final status = complaint['status'] ?? 'draft';
        return UnifiedDocument(
          id: 'traffic_${complaint['complaint_id']}',
          title:
              'Traffic Police Complaint - ${complaint['full_name'] ?? 'User'}',
          description:
              'Traffic violation complaint filed\nStatus: ${status.toUpperCase()}\nViolation: ${complaint['violation_type'] ?? 'Unknown'}',
          documentType: UnifiedDocumentType.complaintPdf,
          sourceModule: DocumentSourceModule.trafficLaws,
          fileUrl: '', // Will be generated on-demand
          createdAt: DateTime.parse(complaint['created_at'] as String),
          updatedAt: complaint['updated_at'] != null
              ? DateTime.parse(complaint['updated_at'] as String)
              : null,
          metadata: {
            'complaintId': complaint['complaint_id'],
            'violationType': complaint['violation_type'],
            'status': status,
          },
          tags: ['traffic', 'police', 'complaint', status],
          relatedComplaintId: complaint['complaint_id'] as String,
        );
      }).toList();
    } catch (e) {
      // Error fetching traffic complaints, continue with other sources
      return [];
    }
  }

  /// Parse document type from string
  UnifiedDocumentType _parseDocumentType(String? type) {
    switch (type?.toLowerCase()) {
      case 'complaint':
        return UnifiedDocumentType.complaintPdf;
      case 'evidence':
        return UnifiedDocumentType.evidenceFile;
      case 'wage':
        return UnifiedDocumentType.wageRecord;
      case 'calculation':
        return UnifiedDocumentType.calculation;
      case 'template':
        return UnifiedDocumentType.template;
      default:
        return UnifiedDocumentType.personalDocument;
    }
  }

  /// Convert wage record type to document type
  UnifiedDocumentType _wageRecordToDocumentType(String recordType) {
    if (recordType.contains('calc')) {
      return UnifiedDocumentType.calculation;
    }
    return UnifiedDocumentType.wageRecord;
  }

  /// Remove duplicate documents by ID
  List<UnifiedDocument> _removeDuplicates(List<UnifiedDocument> documents) {
    final seen = <String>{};
    return documents.where((doc) => seen.add(doc.id)).toList();
  }

  /// Organize documents into categories
  List<DocumentCategory> _organizeIntoCategories(
    List<UnifiedDocument> documents,
  ) {
    final categories = <DocumentCategory>[];

    // Recent documents (last 7 days)
    final recent = documents.where((doc) => doc.isRecent()).toList();
    if (recent.isNotEmpty) {
      categories.add(
        DocumentCategory(
          name: 'Recent',
          description: 'Documents created in the last 7 days',
          documents: recent,
        ),
      );
    }

    // By Module
    for (final module in DocumentSourceModule.values) {
      final docs = documents
          .where((doc) => doc.sourceModule == module)
          .toList();
      if (docs.isNotEmpty) {
        categories.add(
          DocumentCategory(
            name: _getModuleCategoryName(module),
            description: _getModuleCategoryDescription(module),
            documents: docs,
          ),
        );
      }
    }

    // By Type
    for (final type in UnifiedDocumentType.values) {
      final docs = documents.where((doc) => doc.documentType == type).toList();
      if (docs.isNotEmpty && docs.length > 2) {
        // Only show if more than 2 documents
        categories.add(
          DocumentCategory(
            name: _getTypeCategoryName(type),
            documents: docs,
            typeFilter: type,
          ),
        );
      }
    }

    return categories;
  }

  /// Get category name for module
  String _getModuleCategoryName(DocumentSourceModule module) {
    switch (module) {
      case DocumentSourceModule.womenHarassment:
        return 'Women Harassment Complaints';
      case DocumentSourceModule.cyberLaw:
        return 'Cyber Law Complaints';
      case DocumentSourceModule.labourRights:
        return 'Labour Rights Records';
      case DocumentSourceModule.trafficLaws:
        return 'Traffic Complaints';
      case DocumentSourceModule.personalDocuments:
        return 'Personal Documents';
      default:
        return 'Other Documents';
    }
  }

  /// Get category description for module
  String? _getModuleCategoryDescription(DocumentSourceModule module) {
    switch (module) {
      case DocumentSourceModule.womenHarassment:
        return 'Complaints and evidence files related to workplace harassment';
      case DocumentSourceModule.cyberLaw:
        return 'FIA cyber crime complaints and related documents';
      case DocumentSourceModule.labourRights:
        return 'Wage calculations, overtime records, and labour complaints';
      case DocumentSourceModule.trafficLaws:
        return 'Traffic violation complaints filed with police';
      case DocumentSourceModule.personalDocuments:
        return 'Documents uploaded by you';
      default:
        return null;
    }
  }

  /// Get category name for type
  String _getTypeCategoryName(UnifiedDocumentType type) {
    switch (type) {
      case UnifiedDocumentType.complaintPdf:
        return 'Complaint PDFs';
      case UnifiedDocumentType.evidenceFile:
        return 'Evidence Files';
      case UnifiedDocumentType.wageRecord:
        return 'Wage Records';
      case UnifiedDocumentType.calculation:
        return 'Calculations';
      case UnifiedDocumentType.template:
        return 'Templates';
      default:
        return 'Other Documents';
    }
  }
}
