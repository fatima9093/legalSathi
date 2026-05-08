enum ComplaintStatus {
  submitted,
  underReview,
  inProgress,
  resolved;

  String get displayName {
    switch (this) {
      case ComplaintStatus.submitted:
        return 'Submitted';
      case ComplaintStatus.underReview:
        return 'Under Review';
      case ComplaintStatus.inProgress:
        return 'In Progress';
      case ComplaintStatus.resolved:
        return 'Resolved';
    }
  }

  String get value {
    switch (this) {
      case ComplaintStatus.submitted:
        return 'submitted';
      case ComplaintStatus.underReview:
        return 'under_review';
      case ComplaintStatus.inProgress:
        return 'in_progress';
      case ComplaintStatus.resolved:
        return 'resolved';
    }
  }

  static ComplaintStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'under_review':
        return ComplaintStatus.underReview;
      case 'in_progress':
        return ComplaintStatus.inProgress;
      case 'resolved':
        return ComplaintStatus.resolved;
      case 'submitted':
      default:
        return ComplaintStatus.submitted;
    }
  }
}

class ComplaintStatusHistory {
  final String id;
  final String complaintId;
  final ComplaintStatus status;
  final String? changedBy;
  final String? notes;
  final DateTime changedAt;

  ComplaintStatusHistory({
    required this.id,
    required this.complaintId,
    required this.status,
    this.changedBy,
    this.notes,
    required this.changedAt,
  });

  factory ComplaintStatusHistory.fromJson(Map<String, dynamic> json) {
    return ComplaintStatusHistory(
      id: json['id'] as String,
      complaintId: json['complaint_id'] as String,
      status: ComplaintStatus.fromString(json['status'] as String?),
      changedBy: json['changed_by'] as String?,
      notes: json['notes'] as String?,
      changedAt: DateTime.parse(json['changed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'complaint_id': complaintId,
      'status': status.value,
      'changed_by': changedBy,
      'notes': notes,
      'changed_at': changedAt.toIso8601String(),
    };
  }
}
