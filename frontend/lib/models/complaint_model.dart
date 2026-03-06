class ComplaintModel {
  // Unique complaint ID
  final String? complaintId;
  final String? userId;
  
  // Step 1: Applicant Information
  final String? fullName;
  final String? cnic;
  final String? phone;
  final String? email;
  final String? workplace;
  final String? designation;
  final String? city;
  
  // Step 2: Incident Details
  final String? incidentDate;
  final String? harassmentType;
  final String? description;
  final String? accusedName;
  final String? accusedDesignation;
  
  // Step 3: Evidence
  final List<EvidenceFile>? evidenceFiles;
  
  // Metadata
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? status; // draft, submitted, completed

  ComplaintModel({
    this.complaintId,
    this.userId,
    this.fullName,
    this.cnic,
    this.phone,
    this.email,
    this.workplace,
    this.designation,
    this.city,
    this.incidentDate,
    this.harassmentType,
    this.description,
    this.accusedName,
    this.accusedDesignation,
    this.evidenceFiles,
    this.createdAt,
    this.updatedAt,
    this.status,
  });

  // Convert to Firebase Database
  Map<String, dynamic> toDatabase() {
    return {
      'complaintId': complaintId,
      'userId': userId,
      'fullName': fullName,
      'cnic': cnic,
      'phone': phone,
      'email': email,
      'workplace': workplace,
      'designation': designation,
      'city': city,
      'incidentDate': incidentDate,
      'harassmentType': harassmentType,
      'description': description,
      'accusedName': accusedName,
      'accusedDesignation': accusedDesignation,
      'evidenceFiles': evidenceFiles?.map((e) => e.toMap()).toList(),
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'status': status ?? 'draft',
    };
  }

  // Convert from Firebase Database
  factory ComplaintModel.fromDatabase(Map<String, dynamic> data) {
    return ComplaintModel(
      complaintId: data['complaintId'],
      userId: data['userId'],
      fullName: data['fullName'],
      cnic: data['cnic'],
      phone: data['phone'],
      email: data['email'],
      workplace: data['workplace'],
      designation: data['designation'],
      city: data['city'],
      incidentDate: data['incidentDate'],
      harassmentType: data['harassmentType'],
      description: data['description'],
      accusedName: data['accusedName'],
      accusedDesignation: data['accusedDesignation'],
      evidenceFiles: data['evidenceFiles'] != null
          ? (data['evidenceFiles'] as List)
              .map((e) => EvidenceFile.fromMap(Map<String, dynamic>.from(e)))
              .toList()
          : null,
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int)
          : null,
      updatedAt: data['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] as int)
          : null,
      status: data['status'],
    );
  }

  // Copy with method
  ComplaintModel copyWith({
    String? complaintId,
    String? userId,
    String? fullName,
    String? cnic,
    String? phone,
    String? email,
    String? workplace,
    String? designation,
    String? city,
    String? incidentDate,
    String? harassmentType,
    String? description,
    String? accusedName,
    String? accusedDesignation,
    List<EvidenceFile>? evidenceFiles,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
  }) {
    return ComplaintModel(
      complaintId: complaintId ?? this.complaintId,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      cnic: cnic ?? this.cnic,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      workplace: workplace ?? this.workplace,
      designation: designation ?? this.designation,
      city: city ?? this.city,
      incidentDate: incidentDate ?? this.incidentDate,
      harassmentType: harassmentType ?? this.harassmentType,
      description: description ?? this.description,
      accusedName: accusedName ?? this.accusedName,
      accusedDesignation: accusedDesignation ?? this.accusedDesignation,
      evidenceFiles: evidenceFiles ?? this.evidenceFiles,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }
}

// Evidence File Model
class EvidenceFile {
  final String fileName;
  final String fileType; // screenshot, chat, email, audio, video
  final String? fileUrl; // Firebase Storage URL
  final String? localPath; // Local file path
  final int? fileSize;
  final DateTime? uploadedAt;

  EvidenceFile({
    required this.fileName,
    required this.fileType,
    this.fileUrl,
    this.localPath,
    this.fileSize,
    this.uploadedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'fileName': fileName,
      'fileType': fileType,
      'fileUrl': fileUrl,
      'localPath': localPath,
      'fileSize': fileSize,
      'uploadedAt': uploadedAt?.millisecondsSinceEpoch,
    };
  }

  factory EvidenceFile.fromMap(Map<String, dynamic> map) {
    return EvidenceFile(
      fileName: map['fileName'],
      fileType: map['fileType'],
      fileUrl: map['fileUrl'],
      localPath: map['localPath'],
      fileSize: map['fileSize'],
      uploadedAt: map['uploadedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['uploadedAt'] as int)
          : null,
    );
  }
}

