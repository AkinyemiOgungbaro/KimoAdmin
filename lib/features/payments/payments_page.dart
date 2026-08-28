import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/widgets/admin_scaffold.dart';
import '../../theme/app_theme.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
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
                _statCard('Total Total Payments', '₦24,850,000', '+ 15.6% vs yesterday', true, const Color(0xFF6B4EFF)),
                _statCard('Payments Today', '₦3,450,000', '+ 20.1% vs yesterday', true, const Color(0xFF22C55E)),
                _statCard('Successful Transactions', '₦21,250,000', '+ 17.4% vs yesterday', true, const Color(0xFFEF4444)),
                _statCard('Pending Payments', '₦780,000', '- 12.7% vs yesterday', false, const Color(0xFF3B82F6)),
                _statCard('Failed Payments', '18,942', '- 28.0% vs yesterday', false, const Color(0xFFF97316)),
                _statCard('Refunds', '₦320,000', '+ 15.6% vs yesterday', true, const Color(0xFF3B82F6)),
                _statCard('Payment Fees', '₦21,250,000', '+ 15.6% vs yesterday', true, const Color(0xFF22C55E)),
                _statCard('Unreconciled', '₦780,000', '- 15.6% vs yesterday', false, const Color(0xFFEF4444)),
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
              color: const Color(0xFFF8F5FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEBEBFF)),
            ),
            child: Column(
              children: [
                _buildTableHeader(),
                const Divider(height: 1, color: Color(0xFFEBEBFF)),
                _buildTableRow('PAY78291', 'KimoUser123', 'Wallet Funding', 'Card', '₦5,000', 'Successful', '28 mins ago'),
                const Divider(height: 1, color: Color(0xFFEBEBFF)),
                _buildTableRow('PAY78292', 'KimoUser123', 'Tournament Entry', 'Wallet', '₦2,500', 'Pending', '13 mins ago'),
                const Divider(height: 1, color: Color(0xFFEBEBFF)),
                _buildTableRow('PAY78293', 'KimoUser123', 'Wallet Funding', 'Bank Transfer', '₦7,000', 'Failed', '1 mins ago'),
                const Divider(height: 1, color: Color(0xFFEBEBFF)),
                _buildTableRow('PAY78294', 'KimoUser123', 'In-App Purchase', 'Card', '₦41,800', 'Successful', '87 mins ago'),
                const Divider(height: 1, color: Color(0xFFEBEBFF)),
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
      ),
    );
  }

  Widget _statCard(String label, String value, String change, bool positive, Color iconColor) {
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
                  color: positive ? AppColors.statusGreen : AppColors.statusRed,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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

  Widget _buildTableRow(String id, String user, String type, String method, String amount, String status, String time) {
    Color statusColor;
    Color statusBg;
    if (status == 'Successful') {
      statusColor = AppColors.statusGreen;
      statusBg = AppColors.statusGreenBg;
    } else if (status == 'Pending') {
      statusColor = AppColors.statusOrange;
      statusBg = AppColors.statusOrangeBg;
    } else {
      statusColor = AppColors.statusRed;
      statusBg = AppColors.statusRedBg;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(id, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 10,
                  backgroundImage: AssetImage('assets/images/user_avatar.png'),
                  backgroundColor: AppColors.divider,
                ),
                const SizedBox(width: 8),
                Text(user, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(type, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            flex: 2,
            child: Text(method, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            flex: 1,
            child: Text(amount, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
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
                  status,
                  style: GoogleFonts.inter(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(time, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
