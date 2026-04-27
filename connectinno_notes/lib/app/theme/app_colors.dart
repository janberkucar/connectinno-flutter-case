import 'package:flutter/material.dart';

/// Design tokens — colors. No ad-hoc [Color] literals in feature UI.
abstract final class AppColors {
  static const Color primary = Color(0xFF111827);
  static const Color secondary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color error = Color(0xFFDC2626);
  static const Color border = Color(0xFFE5E7EB);
  static const Color pinned = Color(0xFFFEF3C7);
  static const Color onPrimary = Color(0xFFFFFFFF);
}
