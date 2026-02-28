import 'package:flutter/material.dart';

extension AppColors on ColorScheme {
  // Warm plushie palette
  static const Color warmBeige = Color(0xFFFAF0DC);
  static const Color warmCream = Color(0xFFF5E6C8);
  static const Color warmAmber = Color(0xFFD4A047);
  static const Color warmAmberDeep = Color(0xFFC08830);
  static const Color warmBrown = Color(0xFF5C3D1E);
  static const Color warmBrownLight = Color(0xFF8B6340);
  static const Color softWhite = Color(0xFFFFFFFF);
  static const Color cardSurface = Color(0xFFFFFBF2);
  static const Color subtleGray = Color(0xFFE8DCC8);

  // Semantic colors
  static const Color successGreen = Color(0xFF6B8E5A);
  static const Color errorRed = Color(0xFFB85C4A);
  static const Color infoBlue = Color(0xFF4A7FA5);
}

class PlushieTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFD4A047),
          onPrimary: Colors.white,
          secondary: Color(0xFF8B6340),
          onSecondary: Colors.white,
          surface: Color(0xFFFFFBF2),
          onSurface: Color(0xFF3D2B1F),
          surfaceContainerHighest: Color(0xFFF5E6C8),
          outline: Color(0xFFE8DCC8),
        ),
        scaffoldBackgroundColor: const Color(0xFFFAF0DC),
        fontFamily: 'Nunito',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAF0DC),
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Color(0xFF3D2B1F)),
          titleTextStyle: TextStyle(
            color: Color(0xFF3D2B1F),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3D2B1F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFFFFBF2),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFFE8DCC8), width: 1),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFFFBF2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFE8DCC8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFE8DCC8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide:
                const BorderSide(color: Color(0xFFD4A047), width: 1.5),
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4A047),
          onPrimary: Colors.white,
          secondary: Color(0xFF8B6340),
          surface: Color(0xFF2A1F14),
          onSurface: Color(0xFFF5E6C8),
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1208),
      );
}
