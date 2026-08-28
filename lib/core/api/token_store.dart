import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists auth tokens and the cached admin profile. On Flutter web this is
/// backed by `localStorage`, so a signed-in admin survives page reloads.
class TokenStore {
  static const _kAccess = 'kimo_access_token';
  static const _kRefresh = 'kimo_refresh_token';
  static const _kAdmin = 'kimo_admin_profile';

  SharedPreferences? _prefs;
  SharedPreferences get _p {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError('TokenStore.init() must be awaited before use.');
    }
    return prefs;
  }

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  String? get accessToken => _p.getString(_kAccess);
  String? get refreshToken => _p.getString(_kRefresh);

  bool get hasTokens =>
      (accessToken?.isNotEmpty ?? false) && (refreshToken?.isNotEmpty ?? false);

  Map<String, dynamic>? get admin {
    final raw = _p.getString(_kAdmin);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveTokens({required String access, required String refresh}) async {
    await _p.setString(_kAccess, access);
    await _p.setString(_kRefresh, refresh);
  }

  Future<void> saveAccess(String access) => _p.setString(_kAccess, access);

  Future<void> saveAdmin(Map<String, dynamic> json) =>
      _p.setString(_kAdmin, jsonEncode(json));

  Future<void> clear() async {
    await _p.remove(_kAccess);
    await _p.remove(_kRefresh);
    await _p.remove(_kAdmin);
  }
}
