import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class TournamentOnlyBadge extends StatelessWidget {
  const TournamentOnlyBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('Tournaments only',
          style: GoogleFonts.inter(
              fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white)),
    );
  }
}

class TournamentOnlyToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const TournamentOnlyToggle({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Hidden from casual play, only used by tournaments',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.primary,
            ),
          ),
          Text('Tournaments only',
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
