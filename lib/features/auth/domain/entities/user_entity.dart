enum UserRole { admin, receptionist, guest }

class UserEntity {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isReceptionist => role == UserRole.receptionist;
}
