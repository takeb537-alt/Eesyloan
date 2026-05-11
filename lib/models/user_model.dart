class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  // Empty user for guest mode
  factory UserModel.empty() {
    return UserModel(id: '', name: 'Guest User', email: '', phone: '');
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'email': email, 'phone': phone};
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? 'User',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
}
