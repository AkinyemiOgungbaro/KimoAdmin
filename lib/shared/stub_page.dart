import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../shared/widgets/admin_scaffold.dart';
import '../theme/app_theme.dart';

class StubPage extends StatelessWidget {
  final String title;
  final String route;
  final IconData icon;

  const StubPage({
    super.key,
    required this.title,
    required this.route,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: route,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.primaryLight),
            const SizedBox(height: 20),
            Text(title,
                style: GoogleFonts.inter(
                    fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Text('This section is coming soon.',
                style: GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
