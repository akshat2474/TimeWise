// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF9B59B6); 
  static const Color primaryVariant = Color(0xFF8E44AD); 
  static const Color secondary = Color(0xFF2ECC71); 
  static const Color accentBlue = Color(0xFF3498DB); 

  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF1C1C1E); 
  static const Color surfaceVariant = Color(0xFF2C2C2E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFEBEBF5);
  static const Color textTertiary = Color(0xFF8A8A8E);

  static const Color error = Color(0xFFE74C3C);

  static ThemeData get darkTheme {
    final baseTheme = ThemeData.dark();
    final textTheme = GoogleFonts.interTextTheme(baseTheme.textTheme).apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    );

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      splashColor: primary.withOpacity(0.2),
      highlightColor: primary.withOpacity(0.1),
      
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        background: background,
        surface: surface,
        error: error,
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onBackground: textPrimary,
        onSurface: textPrimary,
        onError: textPrimary,
      ),

      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -1),
        displayMedium: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.5),
        headlineSmall: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
        bodyLarge: textTheme.bodyLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: textTheme.bodyMedium?.copyWith(color: textSecondary, fontSize: 14),
        labelLarge: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.5),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: primary),
      ),

      cardTheme: CardTheme(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1.5),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: textTertiary, fontWeight: FontWeight.w400),
        labelStyle: TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: textTheme.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textSecondary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          side: BorderSide(color: surfaceVariant, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
