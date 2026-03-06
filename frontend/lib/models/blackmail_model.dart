import 'dart:typed_data';

class EvidenceFile {
  final String fileName;
  final String fileType; // 'screenshot' or 'message'
  final String localPath;
  final int fileSize;
  final Uint8List? fileBytes; // For web/memory storage

  EvidenceFile({
    required this.fileName,
    required this.fileType,
    required this.localPath,
    required this.fileSize,
    this.fileBytes,
  });

  Map<String, dynamic> toMap() {
    return {
      'fileName': fileName,
      'fileType': fileType,
      'localPath': localPath,
      'fileSize': fileSize,
    };
  }

  factory EvidenceFile.fromMap(Map<String, dynamic> map) {
    return EvidenceFile(
      fileName: map['fileName'] ?? '',
      fileType: map['fileType'] ?? '',
      localPath: map['localPath'] ?? '',
      fileSize: map['fileSize'] ?? 0,
    );
  }
}

class BlackmailModel {
  final String? blackmailId;
  final String? userId;
  final String? userEmail;
  final String? situation;
  final List<EvidenceFile>? evidenceFiles;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BlackmailModel({
    this.blackmailId,
    this.userId,
    this.userEmail,
    this.situation,
    this.evidenceFiles,
    this.createdAt,
    this.updatedAt,
  });

  BlackmailModel copyWith({
    String? blackmailId,
    String? userId,
    String? userEmail,
    String? situation,
    List<EvidenceFile>? evidenceFiles,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BlackmailModel(
      blackmailId: blackmailId ?? this.blackmailId,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      situation: situation ?? this.situation,
      evidenceFiles: evidenceFiles ?? this.evidenceFiles,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'blackmailId': blackmailId,
      'userId': userId,
      'userEmail': userEmail,
      'situation': situation,
      'evidenceFiles': evidenceFiles?.map((e) => e.toMap()).toList(),
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory BlackmailModel.fromMap(Map<dynamic, dynamic> map) {
    return BlackmailModel(
      blackmailId: map['blackmailId'],
      userId: map['userId'],
      userEmail: map['userEmail'],
      situation: map['situation'],
      evidenceFiles: (map['evidenceFiles'] as List<dynamic>?)
          ?.map((e) => EvidenceFile.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : null,
    );
  }
}

