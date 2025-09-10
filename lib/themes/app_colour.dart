import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Light Theme Colors (based on reference UI)
  static const Color primaryBlue = Color(0xFF2196F3); // Main blue
  static const Color primaryBlueDark = Color(0xFF1976D2); // Darker blue
  static const Color primaryBlueLight = Color(0xFF4FC3F7); // Light blue for gradients/highlights
  
  static const Color secondaryBlue = Color(0xFF64B5F6); // Secondary blue shade
  static const Color accentBlue = Color(0xFF03DAC6); // Teal accent
  
  // Background colors
  static const Color backgroundLight = Color(0xFFE8E5FF); // Light purple background from UI
  static const Color backgroundSecondary = Color(0xFFF3F2FF); // Even lighter background
  static const Color cardBackground = Color(0xFFFFFFFF); // White cards
  static const Color surfaceLight = Color(0xFFFAFAFA); // Light surface
  
  // Text colors
  static const Color textPrimary = Color(0xFF1A1A1A); // Main text
  static const Color textSecondary = Color(0xFF666666); // Secondary text
  static const Color textTertiary = Color(0xFF999999); // Tertiary text
  static const Color textOnPrimary = Color(0xFFFFFFFF); // Text on primary color
  
  // Semantic colors
  static const Color success = Color(0xFF4CAF50); // Green for success/price
  static const Color warning = Color(0xFFFF9800); // Orange for warnings
  static const Color error = Color(0xFFF44336); // Red for errors
  static const Color info = Color(0xFF2196F3); // Blue for info
  
  // Border and divider colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color dividerLight = Color(0xFFEEEEEE);
  
  // Shadow colors
  static const Color shadowLight = Color(0x0F000000);
  static const Color shadowMedium = Color(0x1F000000);

  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF121212); // Dark background
  static const Color backgroundDarkSecondary = Color(0xFF1E1E1E); // Secondary dark background
  static const Color cardBackgroundDark = Color(0xFF2D2D2D); // Dark cards
  static const Color surfaceDark = Color(0xFF1F1F1F); // Dark surface
  
  // Dark theme text colors
  static const Color textPrimaryDark = Color(0xFFE0E0E0); // Main text on dark
  static const Color textSecondaryDark = Color(0xFFB0B0B0); // Secondary text on dark
  static const Color textTertiaryDark = Color(0xFF808080); // Tertiary text on dark
  
  // Dark theme border and divider
  static const Color borderDark = Color(0xFF3D3D3D);
  static const Color dividerDark = Color(0xFF2D2D2D);
  
  // Dark theme shadows
  static const Color shadowDark = Color(0x3F000000);

  // Gradient colors (matching the sidebar gradient from UI)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      primaryBlueLight, // Light blue at top
      primaryBlue,      // Main blue at bottom
    ],
  );

  static const LinearGradient primaryGradientHorizontal = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      primaryBlueLight,
      primaryBlue,
    ],
  );

  // Dark theme gradients
  static const LinearGradient primaryGradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1976D2), // Darker blue for dark theme
      Color(0xFF0D47A1), // Even darker blue
    ],
  );

  // Helper method to get colors based on theme
  static Color getTextPrimary(bool isDark) => isDark ? textPrimaryDark : textPrimary;
  static Color getTextSecondary(bool isDark) => isDark ? textSecondaryDark : textSecondary;
  static Color getBackground(bool isDark) => isDark ? backgroundDark : backgroundLight;
  static Color getCardBackground(bool isDark) => isDark ? cardBackgroundDark : cardBackground;
  static Color getSurface(bool isDark) => isDark ? surfaceDark : surfaceLight;
  static Color getBorder(bool isDark) => isDark ? borderDark : borderLight;
  static Color getDivider(bool isDark) => isDark ? dividerDark : dividerLight;
  
  // Material color swatch for primary color
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF2196F3, // Primary blue
    <int, Color>{
      50: Color(0xFFE3F2FD),
      100: Color(0xFFBBDEFB),
      200: Color(0xFF90CAF9),
      300: Color(0xFF64B5F6),
      400: Color(0xFF42A5F5),
      500: Color(0xFF2196F3), // Primary
      600: Color(0xFF1E88E5),
      700: Color(0xFF1976D2),
      800: Color(0xFF1565C0),
      900: Color(0xFF0D47A1),
    },
  );

  // Special colors from the reference UI
  static const Color rentButtonBlue = Color(0xFF4FC3F7); // The "Rent Now" button color
  static const Color priceGreen = Color(0xFF2E7D32); // Price text color
  static const Color locationGray = Color(0xFF757575); // Location text color
  static const Color bedroomIconGray = Color(0xFF9E9E9E); // Icons in property cards
}