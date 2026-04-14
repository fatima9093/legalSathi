/// Model for draft complaints from the Draft Complaint Generator flow.
/// Stored in Supabase table `draft_complaints`.
class DraftComplaintModel {
  final String? id;
  final String? userId;
  final String? fullName;
  final String? cnic;
  final String? phone;
  final String? email;
  final String? designation;
  final String? workplace;
  final String? address;
  final String? dateOfIncident;
  final String? description;
  final String? evidence;
  final String? witnesses;
  final String? mentalImpact;
  final String? emotionalImpact;
  final String? safetyConcerns;
  final List<String> reliefSought;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DraftComplaintModel({
    this.id,
    this.userId,
    this.fullName,
    this.cnic,
    this.phone,
    this.email,
    this.designation,
    this.workplace,
    this.address,
    this.dateOfIncident,
    this.description,
    this.evidence,
    this.witnesses,
    this.mentalImpact,
    this.emotionalImpact,
    this.safetyConcerns,
    List<String>? reliefSought,
    this.createdAt,
    this.updatedAt,
  }) : reliefSought = reliefSought ?? [];

  Map<String, dynamic> toRow() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'full_name': fullName,
      'cnic': cnic,
      'phone': phone,
      'email': email,
      'designation': designation,
      'workplace': workplace,
      'address': address,
      'date_of_incident': dateOfIncident,
      'description': description,
      'evidence': evidence,
      'witnesses': witnesses,
      'mental_impact': mentalImpact,
      'emotional_impact': emotionalImpact,
      'safety_concerns': safetyConcerns,
      'relief_sought': reliefSought,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static DraftComplaintModel fromRow(Map<String, dynamic> row) {
    final relief = row['relief_sought'];
    final reliefList = relief is List
        ? (relief).map((e) => e.toString()).toList()
        : <String>[];
    final createdAt = row['created_at'];
    final updatedAt = row['updated_at'];
    return DraftComplaintModel(
      id: row['id']?.toString(),
      userId: row['user_id']?.toString(),
      fullName: row['full_name'] as String?,
      cnic: row['cnic'] as String?,
      phone: row['phone'] as String?,
      email: row['email'] as String?,
      designation: row['designation'] as String?,
      workplace: row['workplace'] as String?,
      address: row['address'] as String?,
      dateOfIncident: row['date_of_incident'] as String?,
      description: row['description'] as String?,
      evidence: row['evidence'] as String?,
      witnesses: row['witnesses'] as String?,
      mentalImpact: row['mental_impact'] as String?,
      emotionalImpact: row['emotional_impact'] as String?,
      safetyConcerns: row['safety_concerns'] as String?,
      reliefSought: reliefList,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt.toString()) : null,
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt.toString()) : null,
    );
  }

  DraftComplaintModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? cnic,
    String? phone,
    String? email,
    String? designation,
    String? workplace,
    String? address,
    String? dateOfIncident,
    String? description,
    String? evidence,
    String? witnesses,
    String? mentalImpact,
    String? emotionalImpact,
    String? safetyConcerns,
    List<String>? reliefSought,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DraftComplaintModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      cnic: cnic ?? this.cnic,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      designation: designation ?? this.designation,
      workplace: workplace ?? this.workplace,
      address: address ?? this.address,
      dateOfIncident: dateOfIncident ?? this.dateOfIncident,
      description: description ?? this.description,
      evidence: evidence ?? this.evidence,
      witnesses: witnesses ?? this.witnesses,
      mentalImpact: mentalImpact ?? this.mentalImpact,
      emotionalImpact: emotionalImpact ?? this.emotionalImpact,
      safetyConcerns: safetyConcerns ?? this.safetyConcerns,
      reliefSought: reliefSought ?? this.reliefSought,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
