import '../../../core/api/api_client.dart';
import 'user_models.dart';

class UsersRepository {
  final ApiClient _api;
  UsersRepository(this._api);

  Future<UsersPageData> list({String? search, int page = 1, int limit = 10}) async {
    final data = await _api.get('/admin/users', query: {
      if (search != null && search.isNotEmpty) 'search': search,
      'page': page,
      'limit': limit,
    });
    return UsersPageData.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<UserListItem> get(String id) async {
    final data = await _api.get('/admin/users/$id');
    final json = (data is Map && data['user'] is Map) ? data['user'] : data;
    return UserListItem.fromJson((json as Map).cast<String, dynamic>());
  }

  Future<void> create(NewUser user) => _api.post('/admin/users', data: user.toJson());

  /// [status] is one of `active` | `unverified`.
  Future<void> setStatus(String id, String status) =>
      _api.patch('/admin/users/$id/status', data: {'status': status});

  /// Returns the raw CSV text from `GET /admin/users/export`.
  Future<String> exportCsv() async {
    final res = await _api.getRaw<String>('/admin/users/export');
    return res.data ?? '';
  }
}
