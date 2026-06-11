import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8F8AFF);
  static const Color primaryDark = Color(0xFF4B42D6);
  
  // Accent colors
  static const Color accent = Color(0xFFFF6584);
  
  // Neutral colors
  static const Color backgroundLight = Color(0xFFF9FAFC);
  static const Color backgroundDark = Color(0xFF12121A);
  
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1E2E);
  
  static const Color textLight = Color(0xFF1E293B);
  static const Color textDark = Color(0xFFF1F5F9);
  
  static const Color textMutedLight = Color(0xFF64748B);
  static const Color textMutedDark = Color(0xFF94A3B8);

  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF2E2E3E);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Gradient Colors
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
