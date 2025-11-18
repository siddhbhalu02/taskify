enum UserRole {
  manager,
  employee,
}

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.manager:
        return 'manager';
      case UserRole.employee:
        return 'employee';
    }
  }

  static UserRole fromString(String role) {
    switch (role) {
      case 'manager':
        return UserRole.manager;
      case 'employee':
        return UserRole.employee;
      default:
        throw Exception("Invalid role value: $role");
    }
  }
}
