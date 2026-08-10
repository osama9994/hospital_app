class DepartmentModel {
  final String id;
  final String name;
  final String description;
  final String hospitalId;

  DepartmentModel({
    required this.id,
    required this.name,
    required this.description,
    required this.hospitalId,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      hospitalId: json['hospital_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'hospital_id': hospitalId,
    };
  }
}