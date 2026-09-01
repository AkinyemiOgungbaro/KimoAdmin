import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/range.dart';
import '../../theme/app_theme.dart';

/// Bordered dropdown that selects a [RangePeriod]. Shared by the pages that
/// send a `range` query param (dashboard uses its own inline copy).
class RangeDropdown extends StatelessWidget {
  final RangePeriod value;
  final ValueChanged<RangePeriod> onChanged;

  const RangeDropdown(
      {super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<RangePeriod>(
          value: value,
          items: kRangePeriods
              .map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(p.label, style: GoogleFonts.inter(fontSize: 13))))
              .toList(),
          onChanged: (p) => p == null ? null : onChanged(p),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
