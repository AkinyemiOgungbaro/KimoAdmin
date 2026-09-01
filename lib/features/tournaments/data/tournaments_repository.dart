import '../../../core/api/api_client.dart';
import 'tournament_models.dart';

class TournamentsRepository {
  final ApiClient _api;
  TournamentsRepository(this._api);

  Future<TournamentsPageData> list({int page = 1, int limit = 50}) async {
    final data = await _api
        .get('/admin/tournaments', query: {'page': page, 'limit': limit});
    return TournamentsPageData.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<String> entryCode() async {
    final data = await _api.get('/admin/tournaments/entry-code');
    return (data as Map)['entry_code']?.toString() ?? '';
  }

  Future<LeaderboardData> leaderboard({int page = 1, int limit = 20}) async {
    final data = await _api.get('/admin/tournaments/leaderboard', query: {
      'page': page,
      'limit': limit,
    });
    return LeaderboardData.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<TournamentItem> detail(String id) async {
    final data = await _api.get('/admin/tournaments/$id');
    final json =
        (data is Map && data['tournament'] is Map) ? data['tournament'] : data;
    return TournamentItem.fromJson((json as Map).cast<String, dynamic>());
  }

  Future<List<TournamentPlayer>> players(String id) async {
    final data = await _api.get('/admin/tournaments/$id/players');

    List items = [];
    if (data is List) {
      items = data;
    } else if (data is Map) {
      items = (data['items'] as List?) ?? [];
    }

    return items
        .map((e) =>
            TournamentPlayer.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<void> create(TournamentForm form) =>
      _api.post('/admin/tournaments', data: form.toJson());

  Future<void> update(String id, Map<String, dynamic> fields) =>
      _api.patch('/admin/tournaments/$id', data: fields);

  Future<void> cancel(String id) => _api.delete('/admin/tournaments/$id');

  Future<void> restore(String id) =>
      _api.post('/admin/tournaments/$id/restore');
}
