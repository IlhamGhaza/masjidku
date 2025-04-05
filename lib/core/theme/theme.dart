import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      // Warna Utama
      primary: Color(0xFF00897B), // Hijau Toska
      primaryContainer: Color(0xFFE0F2F1), // Primary Light
      onPrimaryContainer: Color(0xFF006064), // Primary Dark
      secondary: Color(0xFF388E3C), // Accent (Hijau)
      // Warna Netral
      background: Color(0xFFF5F5F5), // Background
      surface: Color(0xFFFFFFFF), // Card Background
      onSurface: Color(0xFF212121), // Text Primary
      onBackground: Color(0xFF212121), // Text Primary
      // Warna Fungsi
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
    cardTheme: CardTheme(
      color: const Color(0xFFFFFFFF),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF00897B),
      foregroundColor: Color(0xFFFFFFFF),
      elevation: 0,
    ),

    // FloatingActionButton
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF00897B),
      foregroundColor: Color(0xFFFFFFFF),
    ),

    // ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );

  // Dark Theme Colors
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      // Warna Utama
      primary: Color(0xFF4DB6AC), // Hijau Toska Terang
      primaryContainer: Color(0xFF1D3C38), // Primary Light
      onPrimaryContainer: Color(0xFF00796B), // Primary Dark
      secondary: Color(0xFF66BB6A), // Accent (Hijau Terang)
      // Warna Netral
      background: Color(0xFF121212), // Background
      surface: Color(0xFF1E1E1E), // Card Background
      surfaceVariant: Color(0xFF282828), // Surface
      onSurface: Color(0xFFFFFFFF), // Text Primary
      onBackground: Color(0xFFFFFFFF), // Text Primary
      // Warna Fungsi
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
    cardTheme: CardTheme(
      color: const Color(0xFF1E1E1E),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF00796B),
      foregroundColor: Color(0xFFFFFFFF),
      elevation: 0,
    ),

    // FloatingActionButton
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF4DB6AC),
      foregroundColor: Color(0xFFFFFFFF),
    ),

    // ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );

  // Custom colors yang tidak masuk ke dalam ThemeData
  static const successColor = Color(0xFF388E3C); // Success
  static const successLightColor = Color(0xFFE8F5E9); // Success Light
  static const warningColor = Color(0xFFFFA000); // Warning
  static const warningLightColor = Color(0xFFFFF3E0); // Warning Light
  static const infoColor = Color(0xFF1976D2); // Info
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
    colors: [Color(0xFF006064), Color(0xFF00897B)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient lightButtonGradient = LinearGradient(
    colors: [Color(0xFF00897B), Color(0xFF4DB6AC)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient darkHeaderGradient = LinearGradient(
    colors: [Color(0xFF004D40), Color(0xFF00695C)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient darkButtonGradient = LinearGradient(
    colors: [Color(0xFF00796B), Color(0xFF26A69A)],
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
