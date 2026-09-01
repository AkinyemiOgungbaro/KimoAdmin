
import '../../dashboard/data/dashboard_models.dart';

class PaymentsData {
  final DashboardTile totalPayments;
  final DashboardTile payments;
  final DashboardTile successful;
  final DashboardTile pending;
  final DashboardTile failed;
  final DashboardTile? refunds;
  final DashboardTile fees;
  final DashboardTile? unreconciled;
  final List<PaymentTransaction> recent;

  PaymentsData({
    required this.totalPayments,
    required this.payments,
    required this.successful,
    required this.pending,
    required this.failed,
    this.refunds,
    required this.fees,
    this.unreconciled,
    required this.recent,
  });

  factory PaymentsData.fromJson(Map<String, dynamic> json) {
    final tiles = json['tiles'] as Map<String, dynamic>? ?? json;

    return PaymentsData(
      totalPayments: DashboardTile.from(
          tiles['total_payments_kobo'] ?? tiles['total_payments']),
      payments: DashboardTile.from(tiles['payments_kobo'] ?? tiles['payments']),
      successful:
          DashboardTile.from(tiles['successful_kobo'] ?? tiles['successful']),
      pending: DashboardTile.from(tiles['pending_kobo'] ?? tiles['pending']),
      failed: DashboardTile.from(tiles['failed_count'] ?? tiles['failed']),
      refunds: (tiles['refunds_kobo'] ?? tiles['refunds']) != null
          ? DashboardTile.from(tiles['refunds_kobo'] ?? tiles['refunds'])
          : null,
      fees: DashboardTile.from(tiles['provider_fees_kobo'] ?? tiles['fees']),
      unreconciled: (tiles['unreconciled_kobo'] ?? tiles['unreconciled']) != null
          ? DashboardTile.from(tiles['unreconciled_kobo'] ?? tiles['unreconciled'])
          : null,
      recent: (json['recent'] as List<dynamic>?)
              ?.map(
                  (e) => PaymentTransaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class PaymentTransaction {
  final String id;
  final String username;
  final String purpose;
  final String? channel;
  final int amountKobo;
  final String status;
  final DateTime createdAt;

  PaymentTransaction({
    required this.id,
    required this.username,
    required this.purpose,
    this.channel,
    required this.amountKobo,
    required this.status,
    required this.createdAt,
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? 'Unknown',
      purpose: json['purpose'] as String? ?? '',
      channel: json['channel'] as String?,
      amountKobo: json['amount_kobo'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
