import 'package:flutter/material.dart';

/// App Color Palette - Legal Sathi
/// Professional, trustworthy color scheme for legal advisory application
class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF00401A); // Main brand color
  static const Color primaryDark = Color(
    0xFF003314,
  ); // Darker variant for emphasis
  static const Color primaryLight = Color(0xFFE6EFEA); // Light green background

  // Backgrounds
  static const Color scaffold = Color(0xFFF5F5F5); // Main scaffold background
  static const Color surface = Color(0xFFFFFFFF); // Card and surface background
  static const Color cardBackground = Color(0xFFFFFFFF); // Card background

  // Text Colors
  static const Color textPrimary = Color(0xFF000000); // Primary text
  static const Color textSecondary = Color(0xFF757575); // Secondary text
  static const Color textHint = Color(0xFFBDBDBD); // Hint/placeholder text
  static const Color textDisabled = Color(0xFF9E9E9E); // Disabled text

  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Success green
  static const Color error = Color(0xFFF44336); // Error red
  static const Color warning = Color(0xFFFF9800); // Warning orange
  static const Color info = Color(0xFF2196F3); // Info blue

  // UI Elements
  static const Color border = Color(0xFFE0E0E0); // Border color
  static const Color divider = Color(0xFFE0E0E0); // Divider color

  // Shadow
  static BoxShadow get softShadow => BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 12,
    offset: const Offset(0, 4),
    spreadRadius: 0,
  );

  static BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withOpacity(0.06),
    blurRadius: 8,
    offset: const Offset(0, 2),
    spreadRadius: 0,
  );

  // Grey Scale (for flexibility)
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
}

/// App Design Constants
/// Consistent spacing, radius, and animation values
class AppConstants {
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 14.0;
  static const double radiusCard = 12.0;
  static const double radiusButton = 12.0;

  // Spacing
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // Animation Duration
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 350);

  // Animation Curve
  static const Curve animationCurve = Curves.easeInOut;

  // Elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
}
