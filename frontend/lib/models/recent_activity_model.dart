/// Model for recent activities shown on the home screen
class RecentActivityModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String
  type; // 'draft_complaint', 'document_upload', 'complaint_filed', 'chat_query', etc.
  final String? icon; // icon name or identifier
  final DateTime timestamp;
  final String? relatedId; // ID of the related document/complaint/etc.

  RecentActivityModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    this.icon,
    required this.timestamp,
    this.relatedId,
  });

  /// Parse from Supabase row (draft_complaints table)
  factory RecentActivityModel.fromDraftComplaint(Map<String, dynamic> row) {
    return RecentActivityModel(
      id: row['id']?.toString() ?? 'unknown',
      userId: row['user_id']?.toString() ?? 'unknown',
      title: 'Draft Complaint',
      description: row['full_name'] != null
          ? 'Complaint draft by ${row['full_name']}'
          : 'Draft complaint created',
      type: 'draft_complaint',
      icon: 'description',
      timestamp: _parseDateTime(row['created_at']),
      relatedId: row['id']?.toString(),
    );
  }

  /// Parse from generic activity log (if you have an activity_log table)
  factory RecentActivityModel.fromJson(Map<String, dynamic> json) {
    return RecentActivityModel(
      id: json['id']?.toString() ?? 'unknown',
      userId: json['user_id']?.toString() ?? 'unknown',
      title: json['title'] as String? ?? 'Activity',
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? 'other',
      icon: json['icon'] as String?,
      timestamp: _parseDateTime(json['timestamp'] ?? json['created_at']),
      relatedId: json['related_id']?.toString(),
    );
  }

  static DateTime _parseDateTime(dynamic dateStr) {
    if (dateStr == null) return DateTime.now();
    if (dateStr is DateTime) return dateStr;
    if (dateStr is String) {
      return DateTime.tryParse(dateStr) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'type': type,
      'icon': icon,
      'timestamp': timestamp.toIso8601String(),
      'related_id': relatedId,
    };
  }
}
