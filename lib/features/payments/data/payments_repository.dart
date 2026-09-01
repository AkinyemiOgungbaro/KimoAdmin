import '../../../core/api/api_client.dart';
import 'payments_models.dart';

class PaymentsRepository {
  final ApiClient _api;
  PaymentsRepository(this._api);

  Future<PaymentsData> get(String range) async {
    final data = await _api.get('/admin/payments', query: {'range': range});
    return PaymentsData.fromJson((data as Map).cast<String, dynamic>());
  }
}
