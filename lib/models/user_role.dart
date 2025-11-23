class UserRole {
  final String userId;
  final String refugioId;
  final String role;

  UserRole({required this.userId, required this.refugioId, required this.role});

  bool get isAdmin => role == 'admin';
  bool get isCollaborator => role == 'collaborator';

  // Permisos
  bool get canManageRefugio => isAdmin;
  bool get canDeleteRefugio => isAdmin;
  bool get canManageCollaborators => isAdmin;

  // Todos pueden gestionar animales
  bool get canManageAnimals => true;
  bool get canManageMedicalRecords => true;

  factory UserRole.fromMap(String userId, String refugioId, String role) {
    return UserRole(userId: userId, refugioId: refugioId, role: role);
  }

  Map<String, dynamic> toMap() {
    return {'userId': userId, 'refugioId': refugioId, 'role': role};
  }
}
