import '../../../core/api/api_client.dart';
import 'wallet_models.dart';

class WalletRepository {
  final ApiClient _api;
  WalletRepository(this._api);

  Future<WalletData> get(String range) async {
    final data = await _api.get('/admin/wallet', query: {'range': range});
    return WalletData.fromJson((data as Map).cast<String, dynamic>());
  }
}
