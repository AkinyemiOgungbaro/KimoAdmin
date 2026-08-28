import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

/// A pill showing a backend status token. Accepts raw API values (e.g.
/// `out_of_stock`, `unverified`) and renders a human-readable label.
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, text) = _colors(status.toLowerCase().trim());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label(status),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: text,
        ),
      ),
    );
  }

  static (Color, Color) _colors(String s) {
    switch (s) {
      case 'active':
      case 'live':
        return (AppColors.statusGreenBg, AppColors.statusGreen);
      case 'unverified':
      case 'maintenance':
        return (AppColors.statusOrangeBg, AppColors.statusOrange);
      case 'out_of_stock':
      case 'out of stock':
        return (AppColors.statusRedBg, AppColors.statusRed);
      case 'upcoming':
        return (AppColors.statusBlueBg, AppColors.statusBlue);
      case 'suspended':
      case 'canceled':
      case 'cancelled':
        return (AppColors.statusRedBg, AppColors.statusRed);
      case 'over':
      case 'completed':
      case 'ended':
        return (AppColors.statusGreyBg, AppColors.statusGrey);
      default:
        return (AppColors.statusGreyBg, AppColors.textSecondary);
    }
  }

  /// `out_of_stock` → "Out Of Stock", `over` → "Completed".
  static String _label(String raw) {
    final s = raw.toLowerCase().trim();
    if (s == 'over') return 'Completed';
    if (s == 'out_of_stock') return 'Out of Stock';
    final words = s.split(RegExp(r'[_\s]+')).where((w) => w.isNotEmpty);
    return words
        .map((w) => w.substring(0, 1).toUpperCase() + w.substring(1))
        .join(' ');
  }
}
