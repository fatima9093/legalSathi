import 'package:intl/intl.dart';

/// Document type enumeration
enum UnifiedDocumentType {
  complaintPdf,
  evidenceFile,
  wageRecord,
  calculation,
  template,
  personalDocument,
  other,
}

enum DocumentSourceModule {
  womenHarassment,
  cyberLaw,
  labourRights,
  trafficLaws,
  personalDocuments,
  other,
}

/// Unified document model that represents all documents in the app
class UnifiedDocument {
  final String id;
  final String title;
  final String? description;
  final UnifiedDocumentType documentType;
  final DocumentSourceModule sourceModule;
  final String fileUrl;
  final String? localPath;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? fileSize;
  final String? mimeType;
  final Map<String, dynamic>? metadata; // Module-specific data
  final List<String> tags;
  final String? relatedComplaintId;
  final String? relatedUserId;
  final bool isDownloadable;
  final bool isDeleteable;

  UnifiedDocument({
    required this.id,
    required this.title,
    this.description,
    required this.documentType,
    required this.sourceModule,
    required this.fileUrl,
    this.localPath,
    required this.createdAt,
    this.updatedAt,
    this.fileSize,
    this.mimeType,
    this.metadata,
    this.tags = const [],
    this.relatedComplaintId,
    this.relatedUserId,
    this.isDownloadable = true,
    this.isDeleteable = true,
  });

  /// Get icon based on document type
  String getIcon() {
    switch (documentType) {
      case UnifiedDocumentType.complaintPdf:
        return '📋';
      case UnifiedDocumentType.evidenceFile:
        return '📎';
      case UnifiedDocumentType.wageRecord:
        return '💰';
      case UnifiedDocumentType.calculation:
        return '🧮';
      case UnifiedDocumentType.template:
        return '📝';
      case UnifiedDocumentType.personalDocument:
        return '📄';
      default:
        return '📁';
    }
  }

  /// Get formatted display name for source module
  String getModuleName() {
    switch (sourceModule) {
      case DocumentSourceModule.womenHarassment:
        return 'Women Harassment';
      case DocumentSourceModule.cyberLaw:
        return 'Cyber Law';
      case DocumentSourceModule.labourRights:
        return 'Labour Rights';
      case DocumentSourceModule.trafficLaws:
        return 'Traffic Laws';
      case DocumentSourceModule.personalDocuments:
        return 'Personal Documents';
      default:
        return 'Other';
    }
  }

  /// Get document type label
  String getTypeLabel() {
    switch (documentType) {
      case UnifiedDocumentType.complaintPdf:
        return 'Complaint PDF';
      case UnifiedDocumentType.evidenceFile:
        return 'Evidence';
      case UnifiedDocumentType.wageRecord:
        return 'Wage Record';
      case UnifiedDocumentType.calculation:
        return 'Calculation';
      case UnifiedDocumentType.template:
        return 'Template';
      case UnifiedDocumentType.personalDocument:
        return 'Personal';
      default:
        return 'Document';
    }
  }

  /// Get color for display
  int getColorValue() {
    switch (sourceModule) {
      case DocumentSourceModule.womenHarassment:
        return 0xFFFFA726; // Orange
      case DocumentSourceModule.cyberLaw:
        return 0xFFEF5350; // Red
      case DocumentSourceModule.labourRights:
        return 0xFF66BB6A; // Green
      case DocumentSourceModule.trafficLaws:
        return 0xFF29B6F6; // Blue
      case DocumentSourceModule.personalDocuments:
        return 0xFFAB47BC; // Purple
      default:
        return 0xFF757575; // Grey
    }
  }

  /// Get formatted date
  String getFormattedDate() {
    return DateFormat('MMM dd, yyyy').format(createdAt);
  }

  /// Get relative time (e.g., "2 days ago")
  String getRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return getFormattedDate();
    }
  }

  /// Get formatted file size
  String getFormattedSize() {
    if (fileSize == null) return 'Unknown';
    if (fileSize! < 1024) return '$fileSize B';
    if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Check if document is recent (created in last 7 days)
  bool isRecent() {
    return DateTime.now().difference(createdAt).inDays < 7;
  }

  /// Check if document is older than 30 days
  bool isOld() {
    return DateTime.now().difference(createdAt).inDays > 30;
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'documentType': documentType.toString(),
      'sourceModule': sourceModule.toString(),
      'fileUrl': fileUrl,
      'localPath': localPath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'fileSize': fileSize,
      'mimeType': mimeType,
      'metadata': metadata,
      'tags': tags,
      'relatedComplaintId': relatedComplaintId,
      'relatedUserId': relatedUserId,
    };
  }

  /// Create from JSON
  factory UnifiedDocument.fromJson(Map<String, dynamic> json) {
    return UnifiedDocument(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      documentType: UnifiedDocumentType.values.firstWhere(
        (e) => e.toString() == json['documentType'],
        orElse: () => UnifiedDocumentType.other,
      ),
      sourceModule: DocumentSourceModule.values.firstWhere(
        (e) => e.toString() == json['sourceModule'],
        orElse: () => DocumentSourceModule.other,
      ),
      fileUrl: json['fileUrl'] as String,
      localPath: json['localPath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      fileSize: json['fileSize'] as int?,
      mimeType: json['mimeType'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      tags: List<String>.from(json['tags'] as List? ?? []),
      relatedComplaintId: json['relatedComplaintId'] as String?,
      relatedUserId: json['relatedUserId'] as String?,
    );
  }

  /// Create copy with modifications
  UnifiedDocument copyWith({
    String? id,
    String? title,
    String? description,
    UnifiedDocumentType? documentType,
    DocumentSourceModule? sourceModule,
    String? fileUrl,
    String? localPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? fileSize,
    String? mimeType,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    String? relatedComplaintId,
    String? relatedUserId,
    bool? isDownloadable,
    bool? isDeleteable,
  }) {
    return UnifiedDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      documentType: documentType ?? this.documentType,
      sourceModule: sourceModule ?? this.sourceModule,
      fileUrl: fileUrl ?? this.fileUrl,
      localPath: localPath ?? this.localPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
      relatedComplaintId: relatedComplaintId ?? this.relatedComplaintId,
      relatedUserId: relatedUserId ?? this.relatedUserId,
      isDownloadable: isDownloadable ?? this.isDownloadable,
      isDeleteable: isDeleteable ?? this.isDeleteable,
    );
  }
}

/// Document category with documents
class DocumentCategory {
  final String name;
  final String? description;
  final List<UnifiedDocument> documents;
  final UnifiedDocumentType? typeFilter;

  DocumentCategory({
    required this.name,
    this.description,
    required this.documents,
    this.typeFilter,
  });

  /// Sort documents by creation date (newest first)
  List<UnifiedDocument> getSorted() {
    final sorted = List<UnifiedDocument>.from(documents);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  /// Get recent documents (last 7 days)
  List<UnifiedDocument> getRecent() {
    return documents.where((doc) => doc.isRecent()).toList();
  }
}

/// Aggregated documents response
class AggregatedDocumentsResponse {
  final List<UnifiedDocument> allDocuments;
  final List<DocumentCategory> categories;
  final int totalCount;
  final DateTime lastFetched;

  AggregatedDocumentsResponse({
    required this.allDocuments,
    required this.categories,
    required this.totalCount,
    required this.lastFetched,
  });

  /// Get documents by type
  List<UnifiedDocument> getByType(UnifiedDocumentType type) {
    return allDocuments.where((doc) => doc.documentType == type).toList();
  }

  /// Get documents by module
  List<UnifiedDocument> getByModule(DocumentSourceModule module) {
    return allDocuments.where((doc) => doc.sourceModule == module).toList();
  }

  /// Get recent documents (last 7 days)
  List<UnifiedDocument> getRecent() {
    return allDocuments.where((doc) => doc.isRecent()).toList();
  }

  /// Search documents by title or tags
  List<UnifiedDocument> search(String query) {
    final lowerQuery = query.toLowerCase();
    return allDocuments.where((doc) {
      final titleMatch = doc.title.toLowerCase().contains(lowerQuery);
      final tagMatch = doc.tags.any(
        (tag) => tag.toLowerCase().contains(lowerQuery),
      );
      final descriptionMatch =
          doc.description?.toLowerCase().contains(lowerQuery) ?? false;
      return titleMatch || tagMatch || descriptionMatch;
    }).toList();
  }
}
