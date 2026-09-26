import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Desktop typography scale optimized for Windows DirectWrite rendering
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Segoe UI';

  // Display Metric (Large Hero numbers)
  static const TextStyle heroMetric = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: -0.5,
  );

  // Standard Metric Display
  static const TextStyle displayMetric = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    letterSpacing: -0.5,
  );

  // Section / Card Headings
  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static const TextStyle cardHeading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  // Sub-headers & Input Labels
  static const TextStyle subHeader = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );

  // Body / Table Cell Typography
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  // Status Badges & Pills
  static const TextStyle badge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  // Monospace for CNIC, IDs, and cryptographic hashes
  static const TextStyle mono = TextStyle(
    fontFamily: 'Consolas',
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: 0.5,
  );
}
