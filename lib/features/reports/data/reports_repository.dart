import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import 'reports_models.dart';

class ReportsRepository {
  final ApiClient _api;
  ReportsRepository(this._api);

  Future<List<ReportCardData>> get() async {
    final data = await _api.get('/admin/reports');
    final items = data is Map ? data['items'] : data;
    return (items as List<dynamic>?)
            ?.map((e) => ReportCardData.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  Future<List<int>> download(String reportId) async {
    final res = await _api.getRaw<List<int>>(
      '/admin/reports/$reportId/pdf',
      responseType: ResponseType.bytes,
    );
    return res.data ?? <int>[];
  }
}

