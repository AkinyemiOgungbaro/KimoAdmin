import '../../../core/api/api_client.dart';
import 'dashboard_models.dart';

class DashboardRepository {
  final ApiClient _api;
  DashboardRepository(this._api);

  Future<DashboardData> get(String range) async {
    final data = await _api.get('/admin/dashboard', query: {'range': range});
    return DashboardData.fromJson((data as Map).cast<String, dynamic>());
  }
}
