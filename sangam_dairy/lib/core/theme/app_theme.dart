import 'package:flutter/material.dart';

class AppTheme {
  // ============================================================
  // BRAND COLORS
  // ============================================================
  static const Color primaryGreen = Color(0xFF087A35);
  static const Color darkGreen = Color(0xFF064D25);
  static const Color mediumGreen = Color(0xFF0D9B48);
  static const Color lightGreen = Color(0xFFE8F5E9);

  static const Color accentOrange = Color(0xFFFFA817);
  static const Color softOrange = Color(0xFFFFE8C4);

  static const Color cream = Color(0xFFFFF9EB);
  static const Color background = Color(0xFFF8FAF7);

  static const Color textDark = Color(0xFF1A1C19);
  static const Color textGrey = Color(0xFF6B7280);

  // ============================================================
  // LIGHT THEME
  // ============================================================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primaryGreen,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: accentOrange,
        surface: Colors.white,
        onSurface: textDark,
        surfaceContainerHighest: cream,
        outline: const Color(0xFFE5E7EB),
      ),

      // ========================================================
      // TYPOGRAPHY
      // ========================================================
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textDark, fontWeight: FontWeight.w800, fontSize: 32),
        displayMedium: TextStyle(color: textDark, fontWeight: FontWeight.w700, fontSize: 28),
        titleLarge: TextStyle(color: darkGreen, fontWeight: FontWeight.w700, fontSize: 22),
        titleMedium: TextStyle(color: textDark, fontWeight: FontWeight.w600, fontSize: 18),
        bodyLarge: TextStyle(color: textDark, fontWeight: FontWeight.w500, fontSize: 16),
        bodyMedium: TextStyle(color: textGrey, fontWeight: FontWeight.w400, fontSize: 14),
      ),

      // ========================================================
      // APP BAR
      // ========================================================
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: darkGreen,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: darkGreen, size: 24),
        titleTextStyle: TextStyle(
          color: darkGreen,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),

      // ========================================================
      // INPUT DECORATION
      // ========================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textGrey, fontSize: 15, fontWeight: FontWeight.w400),
      ),

      // ========================================================
      // BUTTONS
      // ========================================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: primaryGreen.withValues(alpha: 0.3),
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen, width: 2),
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ),

      // ========================================================
      // CARD
      // ========================================================
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
      ),

      // ========================================================
      // NAVIGATION BAR
      // ========================================================
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 10,
        indicatorColor: primaryGreen.withValues(alpha: 0.1),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 75,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryGreen, size: 28);
          }
          return const IconThemeData(color: textGrey, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: primaryGreen,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            );
          }
          return const TextStyle(
            color: textGrey,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          );
        }),
      ),
    );
  }
}
