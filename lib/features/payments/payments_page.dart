import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/di.dart';
import '../../core/format.dart';
import '../../core/range.dart';
import '../../shared/widgets/admin_scaffold.dart';
import '../../shared/widgets/async_view.dart';
import '../../shared/widgets/range_dropdown.dart';
import '../../shared/widgets/status_badge.dart';
import '../../theme/app_theme.dart';
import 'data/payments_models.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  RangePeriod _period = RangePeriod.today;
  late Future<PaymentsData> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = paymentsRepository.get(_period.token);
  }

  void _reload() => setState(_load);

  void _onPeriod(RangePeriod p) {
    if (p == _period) return;
    setState(() {
      _period = p;
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/payments',
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Text(
                'Payment',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              RangeDropdown(value: _period, onChanged: _onPeriod),
            ],
          ),
          const SizedBox(height: 32),
          AsyncView<PaymentsData>(
            future: _future,
            onRetry: _reload,
            minHeight: 400,
            builder: (context, data) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F5FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEBEBFF)),
                    ),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _statCard('Total Payments', data.totalPayments),
                        _statCard('Payments Today', data.payments),
                        _statCard('Successful Transactions', data.successful),
                        _statCard('Pending Payments', data.pending),
                        _statCard('Failed Payments', data.failed),
                        _statCard('Refunds', data.refunds),
                        _statCard('Payment Fees', data.fees),
                        _statCard('Unreconciled', data.unreconciled),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Recent Payment Transactions',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      children: [
                        _buildTableHeader(),
                        const Divider(height: 1),
                        if (data.recent.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(child: Text('No recent transactions')),
                          ),
                        for (int i = 0; i < data.recent.length; i++) ...[
                          if (i > 0) const Divider(height: 1, indent: 20, endIndent: 20),
                          _PaymentRow(txn: data.recent[i]),
                        ],
                        if (data.recent.isNotEmpty) const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text(
                              'View All Cash Transactions',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, var tile) {
    if (tile == null) {
      return _buildCardBase(
        label,
        'N/A',
        null,
        true,
        const Color(0xFF6B4EFF), // default icon color
      );
    }

    // Check if it's the `failed` tile, if it's count, use Format.number instead of currency
    final formattedValue = label.toLowerCase().contains('failed')
        ? Format.number(tile.value)
        : Format.naira(tile.value);

    final change = tile.changePercent;
    final changeText = change == null
        ? null
        : '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}%';

    return _buildCardBase(
      label,
      formattedValue,
      changeText,
      (change ?? 0) >= 0,
      const Color(0xFF6B4EFF),
    );
  }

  Widget _buildCardBase(String label, String value, String? change,
      bool positive, Color iconColor) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.wallet, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (change != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  positive ? Icons.trending_up : Icons.trending_down,
                  color: positive ? AppColors.statusGreen : AppColors.statusRed,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  change,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color:
                        positive ? AppColors.statusGreen : AppColors.statusRed,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(flex: 1, child: _th('ID')),
          Expanded(flex: 2, child: _th('User')),
          Expanded(flex: 2, child: _th('Type')),
          Expanded(flex: 2, child: _th('Method')),
          Expanded(flex: 1, child: _th('Amount')),
          Expanded(flex: 1, child: _th('Status')),
          Expanded(flex: 1, child: _th('Time')),
        ],
      ),
    );
  }

  Widget _th(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

}

class _PaymentRow extends StatefulWidget {
  final PaymentTransaction txn;
  const _PaymentRow({required this.txn});

  @override
  State<_PaymentRow> createState() => _PaymentRowState();
}

class _PaymentRowState extends State<_PaymentRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.txn;
    final status = t.status.toLowerCase();
    
    Color statusColor;
    Color statusBg;
    if (status == 'successful') {
      statusColor = AppColors.statusGreen;
      statusBg = AppColors.statusGreenBg;
    } else if (status == 'pending') {
      statusColor = AppColors.statusOrange;
      statusBg = AppColors.statusOrangeBg;
    } else {
      statusColor = AppColors.statusRed;
      statusBg = AppColors.statusRedBg;
    }

    final id = t.id.isNotEmpty ? (t.id.length > 8 ? '${t.id.substring(0, 8)}...' : t.id) : '-';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Container(
        color: _hovering ? AppColors.pageBg : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(id,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSecondary)),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: AppColors.divider,
                    child: Text(
                      t.username.isNotEmpty ? t.username[0].toUpperCase() : '?',
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(t.username,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.textPrimary)),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(t.purpose,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSecondary)),
            ),
            Expanded(
              flex: 2,
              child: Text(t.channel ?? '-',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSecondary)),
            ),
            Expanded(
              flex: 1,
              child: Text(Format.naira(t.amountKobo),
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSecondary)),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    t.status,
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(Format.relativeTime(t.createdAt.toIso8601String()),
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}

