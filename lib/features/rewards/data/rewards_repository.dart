import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import 'reward_models.dart';

class RewardsRepository {
  final ApiClient _api;
  RewardsRepository(this._api);

  Future<RewardsPageData> list({String? category, int page = 1, int limit = 12}) async {
    final data = await _api.get('/admin/rewards', query: {
      if (category != null && category.isNotEmpty) 'category': category,
      'page': page,
      'limit': limit,
    });
    return RewardsPageData.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<List<DataPlan>> getDataPlans(String network) async {
    final res = await _api.get('/admin/rewards/data-plans', query: {'network': network});
    final items = (res['items'] as List?) ?? [];
    return items.map((e) => DataPlan.fromJson((e as Map).cast<String, dynamic>())).toList();
  }

  Future<RewardItem> get(String id) async {
    final data = await _api.get('/admin/rewards/$id');
    final json = (data is Map && data['reward'] is Map) ? data['reward'] : data;
    return RewardItem.fromJson((json as Map).cast<String, dynamic>());
  }

  Future<void> create(RewardForm form) =>
      _api.post('/admin/rewards', data: _toFormData(form));

  Future<void> update(String id, RewardForm form) =>
      _api.patch('/admin/rewards/$id', data: _toFormData(form));

  Future<void> outOfStock(String id) => _api.post('/admin/rewards/$id/out-of-stock');

  /// Uses `POST /admin/rewards/{id}` with a raw `{action}` body.
  Future<void> setActive(String id, bool active) => _api.post(
        '/admin/rewards/$id',
        data: {'action': active ? 'activate' : 'deactivate'},
      );

  FormData _toFormData(RewardForm form) {
    final map = <String, dynamic>{...form.toFields()};
    if (form.imageBytes != null) {
      map['file'] = MultipartFile.fromBytes(
        form.imageBytes!,
        filename: form.imageFilename ?? 'reward.png',
      );
    }
    return FormData.fromMap(map);
  }
}
