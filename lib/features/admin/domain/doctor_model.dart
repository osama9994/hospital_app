class DoctorModel {
  final String id;
  final String name;
  final String email;
  final String specialization;
  final String departmentId;
  final String hospitalId;

  DoctorModel({
    required this.id,
    required this.name,
    required this.email,
    required this.specialization,
    required this.departmentId,
    required this.hospitalId,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      specialization: json['specialization'] ?? '',
      departmentId: json['department_id'] ?? '',
      hospitalId: json['hospital_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'specialization': specialization,
      'department_id': departmentId,
      'hospital_id': hospitalId,
    };
  }
}