import 'package:front_end/services/http_client_wrapper.dart';
import 'package:front_end/models/error_models.dart';

/// Models for documents API

class Document {
  final String id;
  final String title;
  final String type; // "link", "pdf", "text"
  final String? description;
  final String url;
  final String? size; // Only for files
  final String icon;
  final String module;

  Document({
    required this.id,
    required this.title,
    required this.type,
    this.description,
    required this.url,
    this.size,
    required this.icon,
    required this.module,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      url: json['url'] as String,
      size: json['size'] as String?,
      icon: json['icon'] as String? ?? '📄',
      module: json['module'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'description': description,
      'url': url,
      'size': size,
      'icon': icon,
      'module': module,
    };
  }
}

class DocumentCategory {
  final String categoryName;
  final String? description;
  final List<Document> documents;

  DocumentCategory({
    required this.categoryName,
    this.description,
    required this.documents,
  });

  factory DocumentCategory.fromJson(Map<String, dynamic> json) {
    final docsList = json['documents'] as List? ?? [];
    return DocumentCategory(
      categoryName: json['category_name'] as String,
      description: json['description'] as String?,
      documents: docsList
          .map((doc) => Document.fromJson(doc as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_name': categoryName,
      'description': description,
      'documents': documents.map((doc) => doc.toJson()).toList(),
    };
  }
}

class ModuleDocuments {
  final String moduleId;
  final String moduleName;
  final List<DocumentCategory> categories;
  final int totalCount;

  ModuleDocuments({
    required this.moduleId,
    required this.moduleName,
    required this.categories,
    required this.totalCount,
  });

  factory ModuleDocuments.fromJson(Map<String, dynamic> json) {
    final catList = json['categories'] as List? ?? [];
    return ModuleDocuments(
      moduleId: json['module_id'] as String,
      moduleName: json['module_name'] as String,
      categories: catList
          .map((cat) => DocumentCategory.fromJson(cat as Map<String, dynamic>))
          .toList(),
      totalCount: json['total_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'module_id': moduleId,
      'module_name': moduleName,
      'categories': categories.map((cat) => cat.toJson()).toList(),
      'total_count': totalCount,
    };
  }
}

class AllDocuments {
  final List<ModuleDocuments> modules;
  final int totalCount;

  AllDocuments({required this.modules, required this.totalCount});

  factory AllDocuments.fromJson(Map<String, dynamic> json) {
    final modList = json['modules'] as List? ?? [];
    return AllDocuments(
      modules: modList
          .map((mod) => ModuleDocuments.fromJson(mod as Map<String, dynamic>))
          .toList(),
      totalCount: json['total_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'modules': modules.map((mod) => mod.toJson()).toList(),
      'total_count': totalCount,
    };
  }
}

/// Documents Service for API calls

class DocumentsService {
  final HttpClientWrapper _httpClient;
  final String _baseUrl = 'http://localhost:8000';

  DocumentsService(this._httpClient);

  /// Get all documents across all modules
  Future<ApiResult<AllDocuments>> getAllDocuments() {
    return _httpClient.get(
      '$_baseUrl/api/documents',
      deserialize: (json) =>
          AllDocuments.fromJson(json as Map<String, dynamic>),
      errorMessage: 'Failed to load documents.',
    );
  }

  /// Get documents for a specific module
  /// moduleId: women_harassment, cyber_law, labour_rights, road_laws
  Future<ApiResult<ModuleDocuments>> getModuleDocuments(String moduleId) {
    return _httpClient.get(
      '$_baseUrl/api/documents/$moduleId',
      deserialize: (json) =>
          ModuleDocuments.fromJson(json as Map<String, dynamic>),
      errorMessage: 'Failed to load documents for module $moduleId.',
    );
  }

  /// Add a new document to a module (admin)
  Future<ApiResult<Map<String, dynamic>>> addDocument({
    required String moduleId,
    required String id,
    required String title,
    required String type,
    required String url,
    required String category,
    String? size,
    String? description,
    String? icon,
  }) {
    return _httpClient.post(
      '$_baseUrl/api/documents/$moduleId/add',
      body: {
        'id': id,
        'title': title,
        'type': type,
        'url': url,
        'category': category,
        'size': size,
        'description': description,
        'icon': icon,
      },
      deserialize: (json) => Map<String, dynamic>.from(json as Map),
      errorMessage: 'Failed to add document.',
    );
  }

  /// Remove a document from a module (admin)
  Future<ApiResult<Map<String, dynamic>>> removeDocument({
    required String moduleId,
    required String documentId,
  }) {
    return _httpClient.delete(
      '$_baseUrl/api/documents/$moduleId/$documentId',
      deserialize: (json) => Map<String, dynamic>.from(json as Map),
      errorMessage: 'Failed to remove document.',
    );
  }

  // ========================================================================
  // USER DOCUMENTS METHODS
  // ========================================================================

  /// Get all documents for a specific user
  Future<ApiResult<UserDocumentsResponse>> getUserDocuments(String userId) {
    return _httpClient.get(
      '$_baseUrl/api/user/$userId/documents',
      deserialize: (json) =>
          UserDocumentsResponse.fromJson(json as Map<String, dynamic>),
      errorMessage: 'Failed to load your documents.',
    );
  }

  /// Save a new document for user
  Future<ApiResult<Map<String, dynamic>>> saveUserDocument({
    required String userId,
    required String filename,
    required String documentType,
    required int fileSize,
    required String mimeType,
    String? title,
    String? description,
    String? sourceModule,
    String? relatedComplaintId,
    List<String>? tags,
  }) {
    final request = DocumentUploadRequest(
      filename: filename,
      title: title,
      description: description,
      documentType: documentType,
      fileSize: fileSize,
      mimeType: mimeType,
      sourceModule: sourceModule,
      relatedComplaintId: relatedComplaintId,
      tags: tags,
    );

    return _httpClient.post(
      '$_baseUrl/api/user/$userId/documents',
      body: request.toJson(),
      deserialize: (json) => Map<String, dynamic>.from(json as Map),
      errorMessage: 'Failed to save document.',
    );
  }

  /// Delete a user's document
  Future<ApiResult<Map<String, dynamic>>> deleteUserDocument({
    required String userId,
    required String documentId,
  }) {
    return _httpClient.delete(
      '$_baseUrl/api/user/$userId/documents/$documentId',
      deserialize: (json) => Map<String, dynamic>.from(json as Map),
      errorMessage: 'Failed to delete document.',
    );
  }

  /// Get storage statistics for user
  Future<ApiResult<Map<String, dynamic>>> getUserDocumentsStats(String userId) {
    return _httpClient.get(
      '$_baseUrl/api/user/$userId/documents/stats',
      deserialize: (json) => Map<String, dynamic>.from(json as Map),
      errorMessage: 'Failed to load storage stats.',
    );
  }
}

// ============================================================================
// USER DOCUMENTS MODELS
// ============================================================================

class UserDocument {
  final String id;
  final String userId;
  final String filename;
  final String? title;
  final String? description;
  final String
  documentType; // complaint, template, generated_pdf, uploaded, evidence
  final String fileUrl;
  final int? fileSize;
  final String? mimeType;
  final String? sourceModule; // which module created it
  final String? relatedComplaintId;
  final List<String>? tags;
  final String createdAt;
  final String? updatedAt;
  final bool isDeleted;

  UserDocument({
    required this.id,
    required this.userId,
    required this.filename,
    this.title,
    this.description,
    required this.documentType,
    required this.fileUrl,
    this.fileSize,
    this.mimeType,
    this.sourceModule,
    this.relatedComplaintId,
    this.tags,
    required this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  factory UserDocument.fromJson(Map<String, dynamic> json) {
    return UserDocument(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      filename: json['filename'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      documentType: json['document_type'] as String,
      fileUrl: json['file_url'] as String,
      fileSize: json['file_size'] as int?,
      mimeType: json['mime_type'] as String?,
      sourceModule: json['source_module'] as String?,
      relatedComplaintId: json['related_complaint_id'] as String?,
      tags: (json['tags'] as List?)?.cast<String>(),
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'filename': filename,
      'title': title,
      'description': description,
      'document_type': documentType,
      'file_url': fileUrl,
      'file_size': fileSize,
      'mime_type': mimeType,
      'source_module': sourceModule,
      'related_complaint_id': relatedComplaintId,
      'tags': tags,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_deleted': isDeleted,
    };
  }

  String get displayTitle => title ?? filename;

  String get displayType {
    switch (documentType) {
      case 'complaint':
        return 'Complaint';
      case 'template':
        return 'Template';
      case 'generated_pdf':
        return 'Generated PDF';
      case 'uploaded':
        return 'Uploaded File';
      case 'evidence':
        return 'Evidence';
      default:
        return documentType;
    }
  }

  String get icon {
    switch (documentType) {
      case 'complaint':
        return '📋';
      case 'template':
        return '📑';
      case 'generated_pdf':
        return '📄';
      case 'uploaded':
        return '📤';
      case 'evidence':
        return '🔍';
      default:
        return '📄';
    }
  }

  String get badgeColor {
    switch (documentType) {
      case 'complaint':
        return 'red';
      case 'template':
        return 'blue';
      case 'generated_pdf':
        return 'purple';
      case 'uploaded':
        return 'green';
      case 'evidence':
        return 'orange';
      default:
        return 'gray';
    }
  }
}

class UserDocumentsResponse {
  final String userId;
  final List<UserDocument> documents;
  final int totalCount;
  final int storageQuotaBytes;
  final int usedBytes;

  UserDocumentsResponse({
    required this.userId,
    required this.documents,
    required this.totalCount,
    this.storageQuotaBytes = 104857600, // 100 MB default
    this.usedBytes = 0,
  });

  factory UserDocumentsResponse.fromJson(Map<String, dynamic> json) {
    final docsList = json['documents'] as List? ?? [];
    return UserDocumentsResponse(
      userId: json['user_id'] as String,
      documents: docsList
          .map((doc) => UserDocument.fromJson(doc as Map<String, dynamic>))
          .toList(),
      totalCount: json['total_count'] as int? ?? 0,
      storageQuotaBytes: json['storage_quota_bytes'] as int? ?? 104857600,
      usedBytes: json['used_bytes'] as int? ?? 0,
    );
  }

  double get usagePercentage {
    if (storageQuotaBytes == 0) return 0;
    return (usedBytes / storageQuotaBytes * 100);
  }
}

class DocumentUploadRequest {
  final String filename;
  final String? title;
  final String? description;
  final String documentType;
  final int fileSize;
  final String mimeType;
  final String? sourceModule;
  final String? relatedComplaintId;
  final List<String>? tags;

  DocumentUploadRequest({
    required this.filename,
    this.title,
    this.description,
    required this.documentType,
    required this.fileSize,
    required this.mimeType,
    this.sourceModule,
    this.relatedComplaintId,
    this.tags,
  });

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'title': title,
      'description': description,
      'document_type': documentType,
      'file_size': fileSize,
      'mime_type': mimeType,
      'source_module': sourceModule,
      'related_complaint_id': relatedComplaintId,
      'tags': tags,
    };
  }
}
