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
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      hospitalId: json['hospital_id'] ?? '',
      token: token,
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