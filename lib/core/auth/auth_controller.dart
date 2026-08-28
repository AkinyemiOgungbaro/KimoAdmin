import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../api/token_store.dart';
import '../../features/auth/data/admin_profile.dart';
import '../../features/auth/data/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Holds the session state and drives the router's redirect guard via
/// [refreshListenable]. Kept deliberately small — a single [ChangeNotifier].
class AuthController extends ChangeNotifier {
  final AuthRepository _repo;
  final TokenStore _tokenStore;

  AuthController(this._repo, this._tokenStore, ApiClient api) {
    // When a refresh ultimately fails, the client forces us to signed-out.
    api.onSessionExpired = _onSessionExpired;
  }

  AuthStatus _status = AuthStatus.unknown;
  AuthStatus get status => _status;

  AdminProfile? _admin;
  AdminProfile? get admin => _admin;

  /// Called once at startup. Restores a cached session and verifies it.
  Future<void> bootstrap() async {
    if (!_tokenStore.hasTokens) {
      _set(AuthStatus.unauthenticated, null);
      return;
    }
    // Paint instantly from cache, then verify against the server.
    final cached = _tokenStore.admin;
    if (cached != null) _admin = AdminProfile.fromJson(cached);

    try {
      final profile = await _repo.me();
      await _tokenStore.saveAdmin(profile.toJson());
      _set(AuthStatus.authenticated, profile);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await _tokenStore.clear();
        _set(AuthStatus.unauthenticated, null);
      } else if (_admin != null) {
        // Transient/network error but we have a cached session — stay in.
        _set(AuthStatus.authenticated, _admin);
      } else {
        _set(AuthStatus.unauthenticated, null);
      }
    }
  }

  Future<void> login(String email, String password) async {
    final result = await _repo.login(email.trim(), password);
    await _tokenStore.saveTokens(access: result.accessToken, refresh: result.refreshToken);
    await _tokenStore.saveAdmin(result.admin.toJson());
    _set(AuthStatus.authenticated, result.admin);
  }

  Future<void> logout() async {
    await _repo.logout();
    await _tokenStore.clear();
    _set(AuthStatus.unauthenticated, null);
  }

  void _onSessionExpired() {
    // Fire-and-forget; interceptor already cleared tokens.
    _set(AuthStatus.unauthenticated, null);
  }

  void _set(AuthStatus status, AdminProfile? admin) {
    _status = status;
    _admin = admin;
    notifyListeners();
  }
}
