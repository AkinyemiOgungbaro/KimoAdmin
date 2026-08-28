/// Models for `GET /admin/users`.

class UserListItem {
  final String id;
  final String name;
  final String username;
  final String email;
  final String? phoneNumber;
  final String? avatarUrl;
  final num coins;
  final num cashKobo;
  final num gamesPlayed;
  final String status;
  final String? createdAt;
  final String? lastLoginAt;

  const UserListItem({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.phoneNumber,
    this.avatarUrl,
    required this.coins,
    required this.cashKobo,
    required this.gamesPlayed,
    required this.status,
    this.createdAt,
    this.lastLoginAt,
  });

  factory UserListItem.fromJson(Map<String, dynamic> j) => UserListItem(
        id: j['id']?.toString() ?? '',
        name: j['name'] as String? ?? '',
        username: j['username'] as String? ?? '',
        email: j['email'] as String? ?? '',
        phoneNumber: j['phone_number'] as String?,
        avatarUrl: j['avatar_url'] as String?,
        coins: (j['coins'] as num?) ?? 0,
        cashKobo: (j['cash_kobo'] as num?) ?? 0,
        gamesPlayed: (j['games_played'] as num?) ?? 0,
        status: j['status'] as String? ?? 'active',
        createdAt: j['created_at'] as String?,
        lastLoginAt: j['last_login_at'] as String?,
      );

  String get displayName => name.trim().isNotEmpty ? name : username;
}

class UsersPageData {
  final List<UserListItem> items;
  final int total;
  final int totalUsers;
  final int page;
  final int limit;

  const UsersPageData({
    required this.items,
    required this.total,
    required this.totalUsers,
    required this.page,
    required this.limit,
  });

  int get pageCount => limit <= 0 ? 1 : ((total + limit - 1) ~/ limit).clamp(1, 1 << 30);

  factory UsersPageData.fromJson(Map<String, dynamic> j) => UsersPageData(
        items: ((j['items'] as List?) ?? const [])
            .map((e) => UserListItem.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        total: (j['total'] as num?)?.toInt() ?? 0,
        totalUsers: (j['total_users'] as num?)?.toInt() ?? (j['total'] as num?)?.toInt() ?? 0,
        page: (j['page'] as num?)?.toInt() ?? 1,
        limit: (j['limit'] as num?)?.toInt() ?? 10,
      );
}

/// Payload for `POST /admin/users`.
class NewUser {
  final String firstName;
  final String surname;
  final String email;
  final String phoneNumber;
  final String username;
  final String password;

  const NewUser({
    required this.firstName,
    required this.surname,
    required this.email,
    required this.phoneNumber,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'surname': surname,
        'email': email,
        'phone_number': phoneNumber,
        'username': username,
        'password': password,
      };
}
