import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/format.dart';
import '../theme/app_theme.dart';

class CoinsDonutChart extends StatelessWidget {
  final double earned;
  final double redeemed;

  const CoinsDonutChart(
      {super.key, required this.earned, required this.redeemed});

  @override
  Widget build(BuildContext context) {
    final total = earned + redeemed;
    if (total <= 0) {
      return Center(
        child: Text(
          'No coin activity yet',
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
        ),
      );
    }
    final earnedPct = (earned / total * 100).round();
    final redeemedPct = (redeemed / total * 100).round();

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 52,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                        value: earned,
                        color: AppColors.chartDonutEarned,
                        radius: 28,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: redeemed,
                        color: AppColors.chartDonutRedeemed,
                        radius: 28,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Format.compact(total),
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Total coins',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LegendItem(
                color: AppColors.chartDonutEarned,
                label: 'Earned',
                value: '${Format.compact(earned)} ($earnedPct%)',
              ),
              const SizedBox(height: 12),
              _LegendItem(
                color: AppColors.chartDonutRedeemed,
                label: 'Redeemed',
                value: '${Format.compact(redeemed)} ($redeemedPct%)',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem(
      {required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.textSecondary)),
              Text(value,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}
