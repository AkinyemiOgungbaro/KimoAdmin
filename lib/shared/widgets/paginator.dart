import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

/// A compact, windowed page selector (‹ 1 2 3 … ›). Hidden when there is only
/// a single page.
class Paginator extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final ValueChanged<int> onSelect;
  final int maxButtons;

  const Paginator({
    super.key,
    required this.currentPage,
    required this.pageCount,
    required this.onSelect,
    this.maxButtons = 5,
  });

  @override
  Widget build(BuildContext context) {
    if (pageCount <= 1) return const SizedBox.shrink();

    final int start = (currentPage - maxButtons ~/ 2)
        .clamp(1, math.max(1, pageCount - maxButtons + 1))
        .toInt();
    final int end = math.min(pageCount, start + maxButtons - 1);
    final pages = <int>[for (var p = start; p <= end; p++) p];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Arrow(
          icon: Icons.chevron_left_rounded,
          enabled: currentPage > 1,
          onTap: () => onSelect(currentPage - 1),
        ),
        const SizedBox(width: 4),
        for (final p in pages)
          _PageBox(page: p, active: p == currentPage, onTap: () => onSelect(p)),
        const SizedBox(width: 4),
        _Arrow(
          icon: Icons.chevron_right_rounded,
          enabled: currentPage < pageCount,
          onTap: () => onSelect(currentPage + 1),
        ),
      ],
    );
  }
}

class _PageBox extends StatelessWidget {
  final int page;
  final bool active;
  final VoidCallback onTap;
  const _PageBox(
      {required this.page, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: active ? null : Border.all(color: AppColors.divider),
          ),
          child: Center(
            child: Text(
              '$page',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: active ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _Arrow(
      {required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.divider),
        ),
        child: Icon(icon,
            size: 20,
            color: enabled ? AppColors.textSecondary : AppColors.textMuted),
      ),
    );
  }
}
