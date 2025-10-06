class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? dob;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.dob,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? dob,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'dob': dob,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      dob: map['dob'],
    );
  }
}
