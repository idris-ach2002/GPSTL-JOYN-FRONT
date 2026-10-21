import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

class AppTypography {
  AppTypography._();

  static const TextStyle display = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 56,
    height: 1.05,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading1 = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 40,
    height: 1.1,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 32,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 24,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 18,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 16,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}
