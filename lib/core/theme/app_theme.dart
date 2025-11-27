import 'package:flutter/material.dart';

/// Tema oscuro personalizado para Urban Smart Farming
/// Utiliza tonos verdes vibrantes para representar agricultura
class AppTheme {
  // Colores primarios - tonos verdes para agricultura
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryGreenLight = Color(0xFF66BB6A);
  static const Color primaryGreenDark = Color(0xFF388E3C);

  // Colores de fondo oscuro
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceDarkElevated = Color(0xFF2C2C2C);

  // Colores de estado para métricas
  static const Color statusOptimal = Color(0xFF4CAF50);
  static const Color statusWarning = Color(0xFFFFA726);
  static const Color statusDanger = Color(0xFFEF5350);

  // Colores de texto
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textHint = Color(0xFF757575);

  /// Tema oscuro de la aplicación
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        primaryContainer: primaryGreenDark,
        secondary: primaryGreenLight,
        surface: surfaceDark,
        error: statusDanger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: backgroundDark,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card
      cardTheme: CardTheme(
        color: surfaceDark,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDarkElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: statusDanger, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: statusDanger, width: 2),
        ),
        hintStyle: const TextStyle(color: textHint),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryGreen;
          }
          return textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryGreenLight.withValues(alpha: 0.5);
          }
          return textHint.withValues(alpha: 0.3);
        }),
      ),

      // Tab Bar
      tabBarTheme: const TabBarTheme(
        labelColor: primaryGreen,
        unselectedLabelColor: textSecondary,
        indicatorColor: primaryGreen,
        indicatorSize: TabBarIndicatorSize.tab,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: surfaceDarkElevated,
        selectedColor: primaryGreen,
        labelStyle: const TextStyle(color: textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: textPrimary),
        bodySmall: TextStyle(fontSize: 12, color: textSecondary),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
      ),
    );
  }

  /// Helper para obtener color según estado de métrica
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'optimal':
      case 'óptimo':
        return statusOptimal;
      case 'warning':
      case 'precaución':
        return statusWarning;
      case 'danger':
      case 'peligro':
        return statusDanger;
      default:
        return textSecondary;
    }
  }
}
