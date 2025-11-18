import 'user_role.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? managerId;
  final UserRole role;
  final String createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.managerId,
    required this.role,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? managerId,
    UserRole? role,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      managerId: managerId ?? this.managerId,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'managerId': managerId,
      'role': role.value, // Save enum as string
      'createdAt': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      managerId: map['managerId'],
      role: UserRoleExtension.fromString(map['role']),
      createdAt: map['createdAt'],
    );
  }
}
