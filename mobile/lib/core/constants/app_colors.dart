import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF22C55E); // vivid green from screenshot
  static const primaryLight = Color(0xFF4ADE80);
  static const primaryDark = Color(0xFF166534);
  static const accent = Color(0xFFFDE047); // sun yellow
  static const background = Color(0xFFF8FAFC); // very light gray/off-white
  static const surface = Color(0xFFFFFFFF); // white cards
  
  // Weather card colors
  static const weatherBlue = Color(0xFF1E1E4C);
  static const weatherBlueLight = Color(0xFF2B2B68);

  static const textDark = Color(0xFF1E293B);
  static const textMuted = Color(0xFF64748B);
  static const textLight = Color(0xFF94A3B8);

  static const success = Color(0xFF10B981); 
  static const successLight = Color(0xFFD1FAE5);
  static const warning = Color(0xFFF59E0B); 
  static const warningLight = Color(0xFFFEF3C7);
  static const danger = Color(0xFFEF4444); 
  static const dangerLight = Color(0xFFFEE2E2);

  static const divider = Color(0xFFE2E8F0);
  static const shadow = Color(0x0C000000);

  // Gradient definitions
  static const primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryLight, primary],
  );

  static const weatherGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [weatherBlueLight, weatherBlue],
  );
}
