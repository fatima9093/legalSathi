class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.createdAt,
    this.lastLogin,
  });

  // Convert from Realtime Database
  factory UserModel.fromDatabase(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      createdAt: data['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int)
          : null,
      lastLogin: data['lastLogin'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastLogin'] as int)
          : null,
    );
  }

  // Convert to Realtime Database
  Map<String, dynamic> toDatabase() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'lastLogin': lastLogin?.millisecondsSinceEpoch,
    };
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'createdAt': createdAt?.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  // Copy with method for updates
  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

