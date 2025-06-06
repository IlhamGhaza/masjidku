import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      // Main Colors
      primary: Color(0xFF3366CC), // Main Blue
      primaryContainer: Color(0xFFE6F0FF), // Primary Light
      onPrimaryContainer: Color(0xFF0D47A1), // Primary Dark
      secondary: Color(0xFF4285F4), // Secondary Blue
      // Neutral Colors
      background: Color(0xFFF5F5F5), // Background
      surface: Color(0xFFFFFFFF), // Card Background
      onSurface: Color(0xFF212121), // Text Primary
      onBackground: Color(0xFF212121), // Text Primary
      // Functional Colors
      error: Color(0xFFD32F2F), // Error
      errorContainer: Color(0xFFFFEBEE), // Error Light
      onError: Color(0xFFFFFFFF),
    ),

    // Text Theme
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF212121)), // Text Primary
      bodyMedium: TextStyle(color: Color(0xFF757575)), // Text Secondary
      bodySmall: TextStyle(color: Color(0xFF9E9E9E)), // Text Hint
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: Color(0xFFEEEEEE), // Divider
    ),

    // Card
    cardTheme: CardThemeData(
      color: const Color(0xFFFFFFFF), // Use CardThemeData
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF3366CC),
      foregroundColor: Color(0xFFFFFFFF),
      elevation: 0,
    ),

    // FloatingActionButton
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF3366CC),
      foregroundColor: Color(0xFFFFFFFF),
    ),

    // ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3366CC),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  // Dark Theme Colors
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      // Main Colors
      primary: Color(0xFF5B8DEF), // Light Blue
      primaryContainer: Color(0xFF1A3366), // Primary Light
      onPrimaryContainer: Color(0xFF5B8DEF), // Primary Dark
      secondary: Color(0xFF4285F4), // Secondary Blue
      // Neutral Colors
      background: Color(0xFF121212), // Background
      surface: Color(0xFF1E1E1E), // Card Background
      surfaceVariant: Color(0xFF282828), // Surface
      onSurface: Color(0xFFFFFFFF), // Text Primary
      onBackground: Color(0xFFFFFFFF), // Text Primary
      // Functional Colors
      error: Color(0xFFEF5350), // Error
      errorContainer: Color(0xFFC62828), // Error Dark
      onError: Color(0xFFFFFFFF),
    ),

    // Text Theme
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFFFFFFF)), // Text Primary
      bodyMedium: TextStyle(color: Color(0xFFB0BEC5)), // Text Secondary
      bodySmall: TextStyle(color: Color(0xFF78909C)), // Text Hint
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: Color(0xFF323232), // Divider
    ),

    // Card
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E), // Use CardThemeData
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A3366),
      foregroundColor: Color(0xFFFFFFFF),
      elevation: 0,
    ),

    // FloatingActionButton
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF5B8DEF),
      foregroundColor: Color(0xFFFFFFFF),
    ),

    // ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF3366CC),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  // Custom colors not included in ThemeData
  static const successColor = Color(0xFF4CAF50); // Success
  static const successLightColor = Color(0xFFE8F5E9); // Success Light
  static const warningColor = Color(0xFFFFA000); // Warning
  static const warningLightColor = Color(0xFFFFF3E0); // Warning Light
  static const infoColor = Color(0xFF2196F3); // Info (Blue)
  static const infoLightColor = Color(0xFFE3F2FD); // Info Light

  // Dark theme custom colors
  static const successDarkColor = Color(0xFF66BB6A); // Success
  static const successDarkBgColor = Color(0xFF2E7D32); // Success Dark
  static const warningDarkColor = Color(0xFFFFB74D); // Warning
  static const warningDarkBgColor = Color(0xFFF57C00); // Warning Dark
  static const infoDarkColor = Color(0xFF42A5F5); // Info
  static const infoDarkBgColor = Color(0xFF1565C0); // Info Dark

  // Gradients
  static const LinearGradient lightHeaderGradient = LinearGradient(
    colors: [Color(0xFF0D47A1), Color(0xFF3366CC)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient lightButtonGradient = LinearGradient(
    colors: [Color(0xFF3366CC), Color(0xFF5B8DEF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient darkHeaderGradient = LinearGradient(
    colors: [Color(0xFF0D2B66), Color(0xFF1A3366)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient darkButtonGradient = LinearGradient(
    colors: [Color(0xFF3366CC), Color(0xFF5B8DEF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Transparencies
  static const Color overlayLight = Color(0x1A000000); // rgba(0, 0, 0, 0.1)
  static const Color overlayMedium = Color(0x4D000000); // rgba(0, 0, 0, 0.3)
  static const Color overlayDark = Color(0x80000000); // rgba(0, 0, 0, 0.5)
  static const Color lightThemeScrim = Color(0x33000000); // rgba(0, 0, 0, 0.2)
  static const Color darkThemeScrim = Color(
    0x1AFFFFFF,
  ); // rgba(255, 255, 255, 0.1)
}
