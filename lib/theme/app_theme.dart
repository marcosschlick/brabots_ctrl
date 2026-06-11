import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color backgroundYellow = Color.fromARGB(255, 252, 217, 80);
  static const Color deviceCardGreen = Color.fromARGB(255, 0, 148, 64);
  static const Color appBarBackground = Colors.black;
  static const Color controlButton = Colors.deepPurple;

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundYellow,
    fontFamily: GoogleFonts.poppins().fontFamily,
    colorScheme: const ColorScheme.light(
      primary: deviceCardGreen,
      secondary: controlButton,
      surface: backgroundYellow,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: appBarBackground,
      foregroundColor: Colors.white,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 8,
        shadowColor: Colors.deepPurple.withOpacity(0.6),
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
      ),
    ),
  );

  static const Color scaffoldBackground = backgroundYellow;

  static BoxDecoration get deviceCardDecoration => BoxDecoration(
    color: deviceCardGreen,
    borderRadius: BorderRadius.circular(24),
  );

  static Color get deviceDividerColor => Colors.white.withOpacity(0.25);
}
