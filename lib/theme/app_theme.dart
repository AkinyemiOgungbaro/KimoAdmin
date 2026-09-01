import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Sidebar
  static const Color sidebarBg = Color(0xFF1A0A2E);
  static const Color sidebarActiveItem = Color(0xFF6B4EFF);
  static const Color sidebarText = Color(0xFFB0B0C8);
  static const Color sidebarActiveText = Color(0xFFFFFFFF);

  // Accent
  static const Color primary = Color(0xFF6B4EFF);
  static const Color primaryLight = Color(0xFFEDE9FF);
  static const Color primaryDark = Color(0xFF4A32CC);

  // Logo
  static const Color logoBox = Color(0xFF8B2FC9);

  // Page
  static const Color pageBg = Color(0xFFF4F4F8);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE8E8F0);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF9090A0);
  static const Color textMuted = Color(0xFFB8B8C8);

  // Status
  static const Color statusGreen = Color(0xFF34C759);
  static const Color statusGreenBg = Color(0xFFE8FAF0);
  static const Color statusRed = Color(0xFFFF3B30);
  static const Color statusRedBg = Color(0xFFFFEEED);
  static const Color statusOrange = Color(0xFFFF9500);
  static const Color statusOrangeBg = Color(0xFFFFF3E0);
  static const Color statusBlue = Color(0xFF007AFF);
  static const Color statusBlueBg = Color(0xFFE9F2FF);
  static const Color statusGrey = Color(0xFF8A8A9A);
  static const Color statusGreyBg = Color(0xFFF0F0F8);

  // Chart colours
  static const Color chartLine = Color(0xFF6B4EFF);
  static const Color chartLineFill = Color(0x336B4EFF);
  static const Color chartBar = Color(0xFF7B68EE);
  static const Color chartDonutEarned = Color(0xFF34C759);
  static const Color chartDonutRedeemed = Color(0xFF6B4EFF);

  // Stat card borders
  static const Color statGreen = Color(0xFF34C759);
  static const Color statBlue = Color(0xFF007AFF);
  static const Color statYellow = Color(0xFFFFCC00);
  static const Color statRed = Color(0xFFFF3B30);
  static const Color statPurple = Color(0xFF6B4EFF);
}

class AppTheme {
  static ThemeData get theme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.pageBg,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        surface: AppColors.cardBg,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      dividerColor: AppColors.divider,
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle:
            GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle:
            GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14),
      ),
    );
  }
}
