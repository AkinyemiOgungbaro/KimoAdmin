import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/di.dart';
import '../../core/format.dart';
import '../../core/range.dart';
import '../../shared/widgets/admin_scaffold.dart';
import '../../shared/widgets/async_view.dart';
import '../../shared/widgets/range_dropdown.dart';
import '../../theme/app_theme.dart';
import 'data/wallet_models.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  RangePeriod _period = RangePeriod.today;
  late Future<WalletData> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = walletRepository.get(_period.token);
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
      currentRoute: '/wallet',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Wallet',
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
            AsyncView<WalletData>(
              future: _future,
              onRetry: _reload,
              minHeight: 400,
              builder: (context, data) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 7,
                            child: _buildCashWalletOverview(
                                data.cash, data.charts)),
                        const SizedBox(width: 24),
                        Expanded(
                            flex: 5,
                            child: _buildCoinEconomyOverview(
                                data.coins, data.charts)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 7,
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildTableSection(
                                  'Recent Cash Transactions',
                                  'View All Cash Transactions',
                                  ['ID', 'User', 'Type', 'Amount', 'Status'],
                                  data.recent.cashTransactions,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _buildTableSection(
                                  'Pending Redemptions',
                                  'View All Redemptions',
                                  ['ID', 'User', 'Reward', 'Coins', 'Status'],
                                  data.recent.pendingRedemptions,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              _buildQuickActions(),
                              const SizedBox(height: 24),
                              // _buildAlerts(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildBottomSummary(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashWalletOverview(WalletCashData cash, WalletCharts charts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cash Wallet Overview',
          style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F5FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEBEBFF)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: _statTile(
                          'Total Customer Funds', cash.totalCustomerFunds,
                          isCurrency: true)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _statTile('Funds Added', cash.fundsAdded,
                          isCurrency: true)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _statTile('Funds Withdrawn', cash.fundsSpent,
                          isCurrency: true)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _statTile('Pending Withdrawals', cash.reversals,
                          isCurrency:
                              true)), // Reversals are usually negative but here used for symmetry
                ],
              ),
              const SizedBox(height: 24),
              _buildCashFlowSummary(cash),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                      child: _statTile(
                          'Total Active Wallets', cash.activeWallets,
                          isCurrency: false)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _statTile('Pending Deposits', cash.pendingDeposits,
                          isCurrency: true)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _statTile(
                          'Failed Transactions', cash.failedPayments,
                          isCurrency: false)),
                  const SizedBox(width: 16),
                  Expanded(
                      child:
                          const SizedBox()), // Empty tile or add another one if needed
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F5FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEBEBFF)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Coin Sources',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 0,
                                centerSpaceRadius: 40,
                                sections: charts.bySource.entries
                                    .toList()
                                    .asMap()
                                    .entries
                                    .map((e) {
                                  const colors = [
                                    Color(0xFF22C55E),
                                    Color(0xFF3B82F6),
                                    Color(0xFFEAB308),
                                    Color(0xFFF97316),
                                    Color(0xFF8B5CF6)
                                  ];
                                  return PieChartSectionData(
                                    color: colors[e.key % colors.length],
                                    value: e.value.value.toDouble(),
                                    title: '',
                                    radius: 15,
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: charts.bySource.entries
                                  .toList()
                                  .asMap()
                                  .entries
                                  .take(3)
                                  .map((e) {
                                const colors = [
                                  Color(0xFF22C55E),
                                  Color(0xFF3B82F6),
                                  Color(0xFFEAB308),
                                  Color(0xFFF97316),
                                  Color(0xFF8B5CF6)
                                ];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: _legendItem(
                                      colors[e.key % colors.length],
                                      e.value.key,
                                      Format.number(e.value.value),
                                      ''),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cash Balance Trend',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) => FlLine(
                                color: const Color(0xFFEBEBFF), strokeWidth: 1),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  String text = '';
                                  if (value == 0)
                                    text = '0';
                                  else if (value == 1)
                                    text = 'N10M';
                                  else if (value == 2)
                                    text = 'N20M';
                                  else if (value == 3)
                                    text = 'N30M';
                                  else if (value == 4) text = 'N40M';
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text(text,
                                        style: GoogleFonts.inter(
                                            fontSize: 10,
                                            color: AppColors.textSecondary),
                                        textAlign: TextAlign.right),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: charts.cashBalanceTrend.length > 5
                                    ? (charts.cashBalanceTrend.length / 5)
                                        .ceilToDouble()
                                    : 1,
                                getTitlesWidget: (value, meta) {
                                  if (value >= 0 &&
                                      value < charts.cashBalanceTrend.length) {
                                    final dayStr = charts
                                        .cashBalanceTrend[value.toInt()].day;
                                    String formattedDay = dayStr;
                                    try {
                                      final date = DateTime.parse(dayStr);
                                      final months = [
                                        'Jan',
                                        'Feb',
                                        'Mar',
                                        'Apr',
                                        'May',
                                        'Jun',
                                        'Jul',
                                        'Aug',
                                        'Sep',
                                        'Oct',
                                        'Nov',
                                        'Dec'
                                      ];
                                      formattedDay =
                                          '${months[date.month - 1]} ${date.day}';
                                    } catch (_) {}
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(formattedDay,
                                          style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: AppColors.textMuted)),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minY: 0,
                          maxY: charts.cashBalanceTrend.fold<double>(
                                  0.0,
                                  (m, e) =>
                                      e.value > m ? e.value.toDouble() : m) *
                              1.2,
                          lineBarsData: [
                            LineChartBarData(
                              spots: charts.cashBalanceTrend
                                  .asMap()
                                  .entries
                                  .map((e) => FlSpot(e.key.toDouble(),
                                      e.value.value.toDouble()))
                                  .toList(),
                              isCurved: true,
                              color: const Color(0xFF6B4EFF),
                              barWidth: 2,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: const Color(0xFF6B4EFF)
                                    .withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoinEconomyOverview(WalletCoinsData coins, WalletCharts charts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kimo Coins Economy Overview',
          style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2E0934), // dark purple
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: _statTile(
                          'Coins in Circulation', coins.inCirculation,
                          isDark: true)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _statTile('Coins Earned Today', coins.earned,
                          isDark: true)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _statTile('Coins Redeemed Today', coins.spent,
                          isDark: true)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _statTile(
                          'Pending Redemptions', coins.pendingRedemptions,
                          isDark: true)),
                ],
              ),
              const SizedBox(height: 24),
              _buildCoinFlowSummary(coins),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                      child: _statTile('Coins Expired/Reversed', coins.expired,
                          isDark: true)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _statTile(
                          'Reward Claimed Today', coins.rewardsClaimed,
                          isDark: true)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _statTile('Reversed Coins', coins.reversed,
                          isDark: true, showIcon: false)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _statTile(
                          'Bonus in Circulation', coins.bonusInCirculation,
                          isDark: true)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2E0934),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Coin Activity Summary',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 0,
                                centerSpaceRadius: 40,
                                sections: charts.bySink.entries
                                    .toList()
                                    .asMap()
                                    .entries
                                    .map((e) {
                                  const colors = [
                                    Color(0xFF22C55E),
                                    Color(0xFF3B82F6),
                                    Color(0xFFEAB308),
                                    Color(0xFFF97316),
                                    Color(0xFF8B5CF6)
                                  ];
                                  return PieChartSectionData(
                                    color: colors[e.key % colors.length],
                                    value: e.value.value.toDouble(),
                                    title: '',
                                    radius: 15,
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: charts.bySink.entries
                                  .toList()
                                  .asMap()
                                  .entries
                                  .take(4)
                                  .map((e) {
                                const colors = [
                                  Color(0xFF22C55E),
                                  Color(0xFF3B82F6),
                                  Color(0xFFEAB308),
                                  Color(0xFFF97316),
                                  Color(0xFF8B5CF6)
                                ];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: _legendItem(
                                      colors[e.key % colors.length],
                                      e.value.key,
                                      Format.number(e.value.value),
                                      '',
                                      isDark: true),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Top games by Coins Earned',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                          TextSpan(
                            text: '  (This Month)',
                            style: GoogleFonts.inter(
                                fontSize: 10, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Text('Games',
                                style: GoogleFonts.inter(
                                    fontSize: 10, color: Colors.white))),
                        Expanded(
                            flex: 2,
                            child: Text('Coins Earned',
                                style: GoogleFonts.inter(
                                    fontSize: 10, color: Colors.white))),
                        Expanded(
                            flex: 2,
                            child: Text('Players',
                                style: GoogleFonts.inter(
                                    fontSize: 10, color: Colors.white))),
                        Expanded(
                            flex: 2,
                            child: Text('Avg Coins / User',
                                style: GoogleFonts.inter(
                                    fontSize: 10, color: Colors.white))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (final g in charts.topGames)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _topGameRow(
                            g.game,
                            Format.number(g.coinsEarned),
                            Format.number(g.players),
                            Format.number(g.avgCoinsPerUser)),
                      ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('View Full Report',
                              style: GoogleFonts.inter(
                                  fontSize: 11, color: Colors.white)),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_circle_right,
                              size: 14, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statTile(String label, var tile,
      {bool isDark = false, bool isCurrency = false, bool showIcon = true}) {
    if (tile == null) {
      return _statBox(label, 'N/A', null, isDark: isDark, showIcon: showIcon);
    }

    final formattedValue =
        isCurrency ? Format.naira(tile.value) : Format.number(tile.value);

    final change = tile.changePercent;
    final changeText = change == null
        ? null
        : '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}%';

    final valueColor = isDark
        ? Colors.white
        : ((change ?? 0) >= 0 ? AppColors.statusGreen : AppColors.statusRed);

    return _statBox(label, formattedValue, changeText,
        isDark: isDark, showIcon: showIcon, valueColor: valueColor);
  }

  Widget _statBox(String label, String value, String? subtext,
      {Color valueColor = AppColors.textPrimary,
      bool isDark = false,
      bool showIcon = true}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isDark ? Colors.black54 : AppColors.textSecondary)),
          const SizedBox(height: 4),
          Row(
            children: [
              if (showIcon) ...[
                isDark
                    ? Image.asset('assets/images/kcoin.png',
                        width: 14, height: 14)
                    : Icon(Icons.wallet, size: 14, color: valueColor),
                const SizedBox(width: 4),
              ],
              Text(value,
                  style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.black87 : valueColor)),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtext ?? ' ',
              style: GoogleFonts.inter(
                  fontSize: 10,
                  color: subtext == null
                      ? Colors.transparent
                      : (isDark ? Colors.black54 : AppColors.textSecondary))),
        ],
      ),
    );
  }

  Widget _buildCashFlowSummary(WalletCashData cash) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cash Flow Summary',
              style:
                  GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _flowItem(Format.nairaCompact(cash.fundsAdded.value),
                  'Funds Added', const Color(0xFF6B4EFF)),
              const Icon(Icons.arrow_forward),
              _flowItem(Format.nairaCompact(cash.totalCustomerFunds.value),
                  'Available Balance', const Color(0xFF3B82F6)),
              const Icon(Icons.arrow_forward),
              _flowItem(Format.nairaCompact(cash.fundsSpent.value),
                  'Funds Used', const Color(0xFF22C55E)),
              const Icon(Icons.arrow_forward),
              _flowItem(Format.nairaCompact(cash.reversals?.value ?? 0),
                  'Withdrawals', const Color(0xFF6B4EFF)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoinFlowSummary(WalletCoinsData coins) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Coin Activity Summary',
              style:
                  GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _flowItem(Format.compact(coins.earned.value), 'Coins Earned',
                  const Color(0xFFF59E0B)),
              const Icon(Icons.arrow_forward),
              _flowItem(Format.compact(coins.inCirculation.value), 'In Wallets',
                  const Color(0xFFF59E0B)),
              const Icon(Icons.arrow_forward),
              _flowItem(Format.compact(coins.spent.value), 'Funds Used',
                  const Color(0xFFF59E0B)),
              const Icon(Icons.arrow_forward),
              _flowItem(
                  Format.compact(coins.inCirculation.value - coins.spent.value),
                  'Outstanding',
                  const Color(0xFFF59E0B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _flowItem(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.circle, size: 8, color: color),
            const SizedBox(width: 4),
            Text(value,
                style: GoogleFonts.outfit(
                    fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildTableSection(String title, String footerAction,
      List<String> cols, List<Map<String, dynamic>> rows) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBEBFF)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(title,
                    style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEBEBFF)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: cols
                  .map((c) => Expanded(
                      child: Text(c,
                          style: GoogleFonts.inter(
                              fontSize: 11, fontWeight: FontWeight.bold))))
                  .toList(),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEBEBFF)),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('No entries found',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textSecondary)),
            ),
          for (final row in rows) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                      child: Text(
                          row['id'] == null
                              ? '-'
                              : (row['id'].toString().length > 8
                                  ? '${row['id'].toString().substring(0, 8)}...'
                                  : row['id'].toString()),
                          style: GoogleFonts.inter(fontSize: 12))),
                  Expanded(
                      child: Text(row['username']?.toString() ?? '-',
                          style: GoogleFonts.inter(fontSize: 12))),
                  if (row.containsKey('purpose'))
                    Expanded(
                        child: Text(row['purpose']?.toString() ?? '-',
                            style: GoogleFonts.inter(fontSize: 12))),
                  if (row.containsKey('reward'))
                    Expanded(
                        child: Text(row['reward']?.toString() ?? '-',
                            style: GoogleFonts.inter(fontSize: 12))),
                  if (row.containsKey('amount_kobo'))
                    Expanded(
                        child: Text(
                            Format.naira(row['amount_kobo'] as int? ?? 0),
                            style: GoogleFonts.inter(fontSize: 12))),
                  if (row.containsKey('coins'))
                    Expanded(
                        child: Text(Format.number(row['coins'] as int? ?? 0),
                            style: GoogleFonts.inter(fontSize: 12))),
                  Expanded(
                      child: Text(row['status']?.toString() ?? '-',
                          style: GoogleFonts.inter(fontSize: 12))),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEBEBFF)),
          ],
          Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: Text(footerAction,
                  style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBEBFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions',
              style:
                  GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _actionRow('Add Funds to User Wallet', () => context.go('/users')),
          _actionRow('Adjust User Coin', () => context.go('/users')),
          _actionRow('Process Withdrawal', () => context.go('/users')),
          _actionRow('View All Transactions', () => context.go('/payments')),
        ],
      ),
    );
  }

  Widget _actionRow(String label, [VoidCallback? onTap]) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEBEBFF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w500)),
              const Icon(Icons.chevron_right,
                  size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlerts() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBEBFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Alerts',
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              // Text('View All →',
              //     style: GoogleFonts.inter(
              //         fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          // _alertRow('Unusual Coin Accumulation',
          //     'User KimoUser9887 earned 450k coins in 40 minutes'),
          // _alertRow('Failed Deposit Attempt',
          //     '3 failed deposit in the last 30 minutes'),
          // _alertRow('Redemption Failed', 'N500 Airtime to KimoUser654'),
        ],
      ),
    );
  }

  Widget _alertRow(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w600)),
              Text(subtitle,
                  style: GoogleFonts.inter(
                      fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
          const Icon(Icons.chevron_right,
              size: 16, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildBottomSummary() {
    return Row(
      children: [
        Expanded(
            child: _bottomCard('Total Customer with Cash Wallet', '18,942')),
        const SizedBox(width: 16),
        Expanded(
            child:
                _bottomCard('Total Customer Funds (All Time)', '₦156,293,090')),
        const SizedBox(width: 16),
        Expanded(
            child: _bottomCard('Total Deposit (All Time)', '₦178,250,000')),
        const SizedBox(width: 16),
        Expanded(
            child: _bottomCard('Total Withdrawal (All Time)', '₦112,493,000')),
        const SizedBox(width: 16),
        Expanded(
            child: _bottomCard('Total Coins Earned (All Time)', '₦780,000')),
        const SizedBox(width: 16),
        Expanded(
            child:
                _bottomCard('Total Reward Claimed (All Time)', '₦1,245,810')),
      ],
    );
  }

  Widget _bottomCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEBEBFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _legendItem(
      Color color, String title, String? value, String percentage,
      {bool isDark = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, color: color),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(title,
              style: GoogleFonts.inter(
                  fontSize: 10,
                  color: isDark ? Colors.white : AppColors.textPrimary)),
        ),
        if (value != null) ...[
          Expanded(
            flex: 2,
            child: Text(value,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary)),
          ),
        ],
        Expanded(
          flex: 1,
          child: Text(percentage,
              style: GoogleFonts.inter(
                  fontSize: 10,
                  color: isDark ? Colors.white70 : AppColors.textSecondary),
              textAlign: TextAlign.right),
        ),
      ],
    );
  }

  Widget _topGameRow(
      String game, String coins, String players, String avgCoins) {
    return Row(
      children: [
        Expanded(
            flex: 2,
            child: Text(game,
                style: GoogleFonts.inter(fontSize: 10, color: Colors.white70))),
        Expanded(
            flex: 2,
            child: Text(coins,
                style: GoogleFonts.inter(fontSize: 10, color: Colors.white70))),
        Expanded(
            flex: 2,
            child: Text(players,
                style: GoogleFonts.inter(fontSize: 10, color: Colors.white70))),
        Expanded(
            flex: 2,
            child: Text(avgCoins,
                style: GoogleFonts.inter(fontSize: 10, color: Colors.white70))),
      ],
    );
  }
}
