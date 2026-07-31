class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // admin, doctor, receptionist, patient
  final String hospitalId;
  final String? token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.hospitalId,
    this.token,
  });

  // تحويل JSON القادم من Backend Node.js إلى Object في Flutter
  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    final metadata = json['user_metadata'] is Map
        ? Map<String, dynamic>.from(json['user_metadata'])
        : <String, dynamic>{};
    final appMetadata = json['app_metadata'] is Map
        ? Map<String, dynamic>.from(json['app_metadata'])
        : <String, dynamic>{};

    final hospitalId = json['hospital_id']?.toString() ??
        json['hospitalId']?.toString() ??
        metadata['hospital_id']?.toString() ??
        metadata['hospitalId']?.toString() ??
        appMetadata['hospital_id']?.toString() ??
        (json['hospital'] is Map ? json['hospital']['id']?.toString() : null) ??
        '';

    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ??
          metadata['name']?.toString() ??
          json['full_name']?.toString() ??
          metadata['full_name']?.toString() ??
          '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ??
          metadata['role']?.toString() ??
          appMetadata['role']?.toString() ??
          'patient',
      hospitalId: hospitalId,
      token:
          token ?? json['token']?.toString() ?? json['access_token']?.toString(),
    );
  }

  // تحويل الـ Object إلى JSON (في حال الاحتياج لتخزينه)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'hospital_id': hospitalId,
      'token': token,
    };
  }
}
