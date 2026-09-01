import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import 'banner_models.dart';

class BannersRepository {
  final ApiClient _api;

  BannersRepository(this._api);

  Future<BannersPageData> list({int page = 1, int limit = 20}) async {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    final data = await _api.get('/admin/banners', query: query);
    return BannersPageData.fromJson(data);
  }

  Future<PlacementsData> placements() async {
    final data = await _api.get('/admin/banners/placements?=');
    return PlacementsData.fromJson(data);
  }

  Future<void> addBanner({
    required String name,
    required String placements,
    String? targetUrl,
    String? startsAt,
    String? endsAt,
    required MultipartFile file,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'placements': placements,
      if (targetUrl != null && targetUrl.isNotEmpty) 'target_url': targetUrl,
      if (startsAt != null && startsAt.isNotEmpty) 'starts_at': startsAt,
      if (endsAt != null && endsAt.isNotEmpty) 'ends_at': endsAt,
      'file': file,
    });

    await _api.post('/admin/banners', data: formData);
  }

  Future<void> updateBanner({
    required String id,
    required String name,
    required String placements,
    String? targetUrl,
    String? startsAt,
    String? endsAt,
    MultipartFile? file,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'placements': placements,
      if (targetUrl != null && targetUrl.isNotEmpty) 'target_url': targetUrl,
      if (startsAt != null && startsAt.isNotEmpty) 'starts_at': startsAt,
      if (endsAt != null && endsAt.isNotEmpty) 'ends_at': endsAt,
      if (file != null) 'file': file,
    });

    await _api.patch('/admin/banners/$id', data: formData);
  }
}
