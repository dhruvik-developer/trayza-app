import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF845CBD);
  static const Color primaryLight = Color(0xFFF4EFFC);
  
  // Neutral Palette
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E293B);
  static const Color sidebarBackground = Color(0xFFFCFCFD);
  static const Color border = Color(0xFFF3F4F6); // Grey-100
  
  // Status Colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF1F2937);
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Deprecated/Legacy names (optional but good for compatibility if used elsewhere)
  static const Color background = backgroundLight;
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
}

extension ColorsExtension on Colors {
  static const Color emerald = Color(0xFF10B981);
}
