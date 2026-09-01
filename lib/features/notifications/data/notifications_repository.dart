import '../../../core/api/api_client.dart';
import 'notification_models.dart';

class NotificationsRepository {
  final ApiClient _api;

  NotificationsRepository(this._api);

  Future<NotificationsPageData> list(
      {int page = 1, int limit = 20, String? severity}) async {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    if (severity != null && severity.isNotEmpty) {
      query['severity'] = severity;
    }
    final data = await _api.get('/admin/notifications', query: query);
    return NotificationsPageData.fromJson(data);
  }

  Future<void> markAllAsRead() async {
    await _api.post('/admin/notifications/read-all');
  }
}
