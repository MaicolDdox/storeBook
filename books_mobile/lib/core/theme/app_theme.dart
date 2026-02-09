import 'package:flutter/material.dart';

class AppTheme {
  static const Color lightBlue = Color(0xFFE9F1FA);
  static const Color brightBlue = Color(0xFF00ABE4);
  static const Color white = Color(0xFFFFFFFF);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: brightBlue,
      primary: brightBlue,
      surface: white,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: lightBlue,
      colorScheme: colorScheme,
      cardTheme: const CardThemeData(
        color: white,
        elevation: 2,
        shadowColor: Color(0x14004E78),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD2E3F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD2E3F0)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brightBlue,
          foregroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
