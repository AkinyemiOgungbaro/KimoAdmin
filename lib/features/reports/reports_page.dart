import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/widgets/admin_scaffold.dart';
import '../../theme/app_theme.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/reports',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reports',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 1.2,
                children: const [
                  _ReportCard(
                    color: Color(0xFFECECFF),
                    iconColor: Color(0xFF6B4EFF),
                    icon: Icons.description_outlined,
                    title: 'Payment Report',
                    description: 'Overview of all payment\nactivities.',
                    metricLabel: 'Total Volume',
                    metricValue: '₦24,850,000',
                  ),
                  _ReportCard(
                    color: Color(0xFFE4FBE9),
                    iconColor: Color(0xFF22C55E),
                    icon: Icons.wallet_outlined,
                    title: 'Wallet & Coins\nReport',
                    description: 'Wallet funding, withdrawal\nand coin economy',
                    metricLabel: 'Total Coins Earned',
                    metricValue: '18,450,250',
                  ),
                  _ReportCard(
                    color: Color(0xFFFFF4E0),
                    iconColor: Color(0xFFF59E0B),
                    icon: Icons.people_outline,
                    title: 'User Report',
                    description: 'User growth, engagement\nand demographics.',
                    metricLabel: 'Total Users',
                    metricValue: '245,850',
                  ),
                  _ReportCard(
                    color: Color(0xFFFFE4E4),
                    iconColor: Color(0xFFEF4444),
                    icon: Icons.gamepad_outlined,
                    title: 'Game Performance\nReport',
                    description: 'Most played games, win\nrate and metrics.',
                    metricLabel: 'Top Game',
                    metricValue: 'XOXO',
                  ),
                  _ReportCard(
                    color: Color(0xFFE0F2FE),
                    iconColor: Color(0xFF3B82F6),
                    icon: Icons.emoji_events_outlined,
                    title: 'Tournament',
                    description:
                        'Tournament participation\nand price distribution.',
                    metricLabel: 'Total Tournaments',
                    metricValue: '56',
                  ),
                  _ReportCard(
                    color: Color(0xFFECECFF),
                    iconColor: Color(0xFF6B4EFF),
                    icon: Icons.bar_chart_outlined,
                    title: 'Revenue Report',
                    description: 'Revenue, fees and financial\nsummary.',
                    metricLabel: 'Net Revenue',
                    metricValue: '₦23,480,000',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Color color;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String description;
  final String metricLabel;
  final String metricValue;

  const _ReportCard({
    required this.color,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.description,
    required this.metricLabel,
    required this.metricValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: iconColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: iconColor.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            metricLabel,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            metricValue,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                'View Report',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward, color: iconColor, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}
