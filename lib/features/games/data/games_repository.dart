import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import 'game_models.dart';

class GamesRepository {
  final ApiClient _api;
  GamesRepository(this._api);

  Future<List<GameSummary>> list({String range = '30d'}) async {
    final data = await _api.get('/admin/games', query: {'range': range});
    final items = ((data as Map)['items'] as List?) ?? const [];
    return items
        .map((e) => GameSummary.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<GameDetail> detail(String key, {String range = '30d'}) async {
    final data = await _api.get('/admin/games/$key', query: {'range': range});
    return GameDetail.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<GameSummary> updateSettings(String key, GameSettingsPatch patch) async {
    final data = await _api.patch('/admin/games/$key', data: patch.toJson());
    return GameSummary.fromJson((data as Map).cast<String, dynamic>());
  }

  // ---- picture_puzzle images ----------------------------------------------

  Future<PuzzleImage> uploadPuzzleImage({
    required String name,
    required List<int> bytes,
    required String filename,
  }) async {
    final form = FormData.fromMap({
      'name': name,
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final data = await _api.post('/admin/games/picture_puzzle/images', data: form);
    return PuzzleImage.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<void> deletePuzzleImage(String id) =>
      _api.delete('/admin/games/picture_puzzle/images/$id');

  // ---- trivia questions ----------------------------------------------------

  Future<TriviaPageData> listTrivia({String? category, int page = 1, int limit = 20}) async {
    final data = await _api.get('/admin/games/trivia/questions', query: {
      if (category != null && category.isNotEmpty) 'category': category,
      'page': page,
      'limit': limit,
    });
    return TriviaPageData.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<TriviaImportResult> importTrivia({
    required String category,
    required List<int> bytes,
    required String filename,
  }) async {
    final form = FormData.fromMap({
      'category': category,
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final data = await _api.post('/admin/games/trivia/questions', data: form);
    return TriviaImportResult.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<void> deleteTrivia(String id) =>
      _api.delete('/admin/games/trivia/questions/$id');
}
