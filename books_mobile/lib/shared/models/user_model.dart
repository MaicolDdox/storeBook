class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
  });

  final int id;
  final String name;
  final String email;
  final List<String> roles;

  bool get isAdmin => roles.contains('admin');

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      roles: (json['roles'] as List<dynamic>? ?? [])
          .map((role) => role.toString())
          .toList(),
    );
  }
}
