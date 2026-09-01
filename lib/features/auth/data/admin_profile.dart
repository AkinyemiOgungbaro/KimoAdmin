/// The signed-in administrator, as returned by `/admin/auth/login` and
/// `/admin/auth/me`.
class AdminProfile {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? lastLoginAt;

  const AdminProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.lastLoginAt,
  });

  factory AdminProfile.fromJson(Map<String, dynamic> j) => AdminProfile(
        id: j['id']?.toString() ?? '',
        name: (j['name'] as String?)?.trim().isNotEmpty == true
            ? j['name'] as String
            : (j['email'] as String? ?? 'Admin'),
        email: j['email'] as String? ?? '',
        role: j['role'] as String? ?? 'admin',
        lastLoginAt: j['last_login_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'last_login_at': lastLoginAt,
      };

  /// Best-effort initials for the sidebar avatar.
  String get initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'A';
    String first(String s) => s.substring(0, 1).toUpperCase();
    if (parts.length == 1) return first(parts.first);
    return first(parts.first) + first(parts.last);
  }
}
