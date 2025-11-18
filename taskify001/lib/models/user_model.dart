class User {
  final String id;
  final String name;
  final String email;

  /// For employees: this holds the manager's ID.
  /// For managers: this is null.
  final String? managerId;

  /// "manager" or "employee"
  final String role;

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
    String? role,
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
      'role': role,
      'createdAt': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      managerId: map['managerId'],
      role: map['role'],
      createdAt: map['createdAt'],
    );
  }
}
