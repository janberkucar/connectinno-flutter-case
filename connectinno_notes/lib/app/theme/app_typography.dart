import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Design tokens — text styles. Derived from [TextTheme] in [AppTheme]; use for
/// one-off emphasis only.
abstract final class AppTypography {
  static TextStyle pageTitle(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        );
  }

  static TextStyle bodySecondary(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: AppColors.textSecondary,
        );
  }
}
