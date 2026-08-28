import '../../../core/api/api_client.dart';
import 'admin_profile.dart';

/// Result of a successful login: the profile plus the token pair.
class LoginResult {
  final AdminProfile admin;
  final String accessToken;
  final String refreshToken;
  const LoginResult(this.admin, this.accessToken, this.refreshToken);
}

class AuthRepository {
  final ApiClient _api;
  AuthRepository(this._api);

  Future<LoginResult> login(String email, String password) async {
    final data = await _api.post('/admin/auth/login', data: {
      'email': email,
      'password': password,
    }) as Map<String, dynamic>;
    return LoginResult(
      AdminProfile.fromJson(data['admin'] as Map<String, dynamic>),
      data['access_token'] as String,
      data['refresh_token'] as String,
    );
  }

  Future<AdminProfile> me() async {
    final data = await _api.get('/admin/auth/me');
    final json = (data is Map && data['admin'] is Map)
        ? data['admin'] as Map<String, dynamic>
        : data as Map<String, dynamic>;
    return AdminProfile.fromJson(json);
  }

  Future<void> logout() async {
    try {
      await _api.post('/admin/auth/logout');
    } catch (_) {
      // Logout is best-effort; local tokens are cleared regardless.
    }
  }
}
