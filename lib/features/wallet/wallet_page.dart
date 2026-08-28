import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../shared/widgets/admin_scaffold.dart';
import '../../theme/app_theme.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

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
                Center(
                  child: Text(
                    'History',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    border: Border.all(color: AppColors.divider),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Today',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.keyboard_arrow_down,
                          size: 16, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: _buildCashWalletOverview()),
                const SizedBox(width: 24),
                Expanded(flex: 5, child: _buildCoinEconomyOverview()),
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
                          [
                            'ID',
                            'User',
                            'Type',
                            'Method',
                            'Amount',
                            'Status',
                            'Time'
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildTableSection(
                          'Pending Redemptions',
                          'View All Redemptions',
                          [
                            'ID',
                            'User',
                            'Reward',
                            'Coins',
                            'Requested',
                            'Status'
                          ],
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
                      _buildAlerts(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildBottomSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildCashWalletOverview() {
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
                      child: _statBox('Total Customer Funds', '₦24,850,000',
                          'Available Balance')),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _statBox('Funds Added Today', '₦3,450,000',
                          'Available Balance',
                          valueColor: AppColors.statusGreen)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _statBox('Funds Withdrawn Today', '₦21,250,000',
                          'Available Balance',
                          valueColor: AppColors.statusRed)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _statBox(
                          'Pending Withdrawals', '₦780,000', '32 requests',
                          valueColor: AppColors.statusOrange)),
                ],
              ),
              const SizedBox(height: 24),
              _buildCashFlowSummary(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                      child: _statBox('Total Active Wallets', '18,942', null,
                          valueColor: AppColors.statusRed)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _statBox('Pending Deposits', '₦320,000', null,
                          valueColor: AppColors.statusOrange)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _statBox(
                          'Failed Transactions', '₦21,250,000', null,
                          valueColor: AppColors.statusGreen)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _statBox('RefundToday', '₦780,000', null,
                          valueColor: const Color(0xFF6B4EFF))),
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
                    Text('Cash Wallet Analytics',
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
                                sections: [
                                  PieChartSectionData(
                                      color: const Color(0xFF22C55E),
                                      value: 58,
                                      title: '',
                                      radius: 15),
                                  PieChartSectionData(
                                      color: const Color(0xFF6B4EFF),
                                      value: 34,
                                      title: '',
                                      radius: 15),
                                  PieChartSectionData(
                                      color: const Color(0xFFF59E0B),
                                      value: 8,
                                      title: '',
                                      radius: 15),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _legendItem(const Color(0xFF22C55E),
                                    'Funds Added', 'N38.2M', '58%'),
                                const SizedBox(height: 8),
                                _legendItem(const Color(0xFF6B4EFF),
                                    'Funds Used', 'N22.4M', '34%'),
                                const SizedBox(height: 8),
                                _legendItem(const Color(0xFFF59E0B),
                                    'Withdrawals', 'N12.0M', '8%'),
                              ],
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
                                getTitlesWidget: (value, meta) {
                                  const dates = [
                                    'May 15',
                                    'May 16',
                                    'May 17',
                                    'May 18',
                                    'May 19',
                                    'May 20',
                                    'May 21'
                                  ];
                                  if (value >= 0 && value < dates.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(dates[value.toInt()],
                                          style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: AppColors.textSecondary)),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minY: 0,
                          maxY: 4,
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 1.8),
                                FlSpot(1, 1.5),
                                FlSpot(2, 2.3),
                                FlSpot(3, 2.4),
                                FlSpot(4, 2.8),
                                FlSpot(5, 2.2),
                                FlSpot(6, 3.5),
                              ],
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

  Widget _buildCoinEconomyOverview() {
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
                      child: _statBox('Coins in Circulation', '18,450,250',
                          'Available Balance',
                          isDark: true)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _statBox('Coins Earned Today', '2,354,800',
                          'Available Balance',
                          isDark: true)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _statBox('Coins Redeemed Today', '1,214,600',
                          'Available Balance',
                          isDark: true)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _statBox(
                          'Pending Redemptions', '1,890', '32 requests',
                          isDark: true)),
                ],
              ),
              const SizedBox(height: 24),
              _buildCoinFlowSummary(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                      child: _statBox('Coins Expired/Reversed', '240,000', null,
                          isDark: true)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _statBox('Reward Claimed Today', '42,810', null,
                          isDark: true)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _statBox('Failed Transactions', '37', null,
                          isDark: true, showIcon: false)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _statBox('Refund Today', '12', null,
                          isDark: true, showIcon: false)),
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
                                sections: [
                                  PieChartSectionData(
                                      color: const Color(0xFF22C55E),
                                      value: 62,
                                      title: '',
                                      radius: 15),
                                  PieChartSectionData(
                                      color: const Color(0xFF6B4EFF),
                                      value: 15,
                                      title: '',
                                      radius: 15),
                                  PieChartSectionData(
                                      color: const Color(0xFFF59E0B),
                                      value: 13,
                                      title: '',
                                      radius: 15),
                                  PieChartSectionData(
                                      color: const Color(0xFFEF4444),
                                      value: 10,
                                      title: '',
                                      radius: 15),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _legendItem(const Color(0xFF22C55E), 'Games',
                                    null, '62%',
                                    isDark: true),
                                const SizedBox(height: 8),
                                _legendItem(const Color(0xFF6B4EFF),
                                    'Referrals', null, '15%',
                                    isDark: true),
                                const SizedBox(height: 8),
                                _legendItem(const Color(0xFFF59E0B), 'Bonuses',
                                    null, '13%',
                                    isDark: true),
                                const SizedBox(height: 8),
                                _legendItem(const Color(0xFFEF4444),
                                    'Promotions', null, '10%',
                                    isDark: true),
                              ],
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
                    _topGameRow('Puzzle', '6,245,000', '24,850', '251'),
                    const SizedBox(height: 8),
                    _topGameRow('XOXO', '4,125,000', '15,420', '267'),
                    const SizedBox(height: 8),
                    _topGameRow('Trivia', '3,250,000', '10,230', '318'),
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

  Widget _buildCashFlowSummary() {
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
              _flowItem('N24,850,000', 'Funds Added', const Color(0xFF6B4EFF)),
              const Icon(Icons.arrow_forward),
              _flowItem(
                  'N3,450,000', 'Available Balance', const Color(0xFF3B82F6)),
              const Icon(Icons.arrow_forward),
              _flowItem('N2,250,000', 'Funds Used', const Color(0xFF22C55E)),
              const Icon(Icons.arrow_forward),
              _flowItem('N1,250,000', 'Withdrawals', const Color(0xFF6B4EFF)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoinFlowSummary() {
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
              _flowItem('2.35M', 'Coins Earned', const Color(0xFFF59E0B)),
              const Icon(Icons.arrow_forward),
              _flowItem('18.45M', 'In Wallets', const Color(0xFFF59E0B)),
              const Icon(Icons.arrow_forward),
              _flowItem('1.21M', 'Funds Used', const Color(0xFFF59E0B)),
              const Icon(Icons.arrow_forward),
              _flowItem('17.00M', 'Outstanding', const Color(0xFFF59E0B)),
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

  Widget _buildTableSection(
      String title, String footerAction, List<String> cols) {
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text('Placeholder for list rows',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textSecondary)),
          ),
          const Divider(height: 1, color: Color(0xFFEBEBFF)),
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
          _actionRow('Add Funds to User Wallet'),
          _actionRow('Adjust User Coin'),
          _actionRow('Process Withdrawal'),
          _actionRow('View All Transactions'),
        ],
      ),
    );
  }

  Widget _actionRow(String label) {
    return Container(
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
              style:
                  GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500)),
          const Icon(Icons.chevron_right,
              size: 16, color: AppColors.textSecondary),
        ],
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
              Text('View All →',
                  style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          _alertRow('Unusual Coin Accumulation',
              'User KimoUser9887 earned 450k coins in 40 minutes'),
          _alertRow('Failed Deposit Attempt',
              '3 failed deposit in the last 30 minutes'),
          _alertRow('Redemption Failed', 'N500 Airtime to KimoUser654'),
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
