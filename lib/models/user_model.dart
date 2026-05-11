class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;

  UserModel({required this.id, required this.name, required this.email, required this.phone});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'email': email, 'phone': phone};

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Smart User',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
}
