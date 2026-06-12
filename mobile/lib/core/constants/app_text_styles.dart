import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ─── Playfair Display – headings / brand ───────────────────────────────────
  static TextStyle get displayLarge => GoogleFonts.tajawal(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
        height: 1.2,
      );

  static TextStyle get displayMedium => GoogleFonts.tajawal(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
        height: 1.3,
      );

  static TextStyle get headlineLarge => GoogleFonts.tajawal(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      );

  static TextStyle get headlineMedium => GoogleFonts.tajawal(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      );

  // ─── Inter – body / UI ────────────────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.tajawal(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
        height: 1.4,
      );

  static TextStyle get labelLarge => GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
        letterSpacing: 0,
      );

  static TextStyle get labelMedium => GoogleFonts.tajawal(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 0,
      );

  static TextStyle get labelSmall => GoogleFonts.tajawal(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 0,
      );

  static TextStyle get buttonText => GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0,
      );

  static TextStyle get appBarTitle => GoogleFonts.tajawal(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
      );
}
