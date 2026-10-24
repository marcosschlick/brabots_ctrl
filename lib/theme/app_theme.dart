import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFFF3F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceTint = Color(0xFFEAF0F7);
  static const Color brandBlue = Color(0xFF123F78);
  static const Color brandGreen = Color(0xFF00884A);
  static const Color primaryText = Color(0xFF162B45);
  static const Color secondaryText = Color(0xFF63748A);

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: background,
    fontFamily: GoogleFonts.poppins().fontFamily,
    colorScheme: const ColorScheme.light(
      primary: brandBlue,
      secondary: brandGreen,
      surface: surface,
      onSurface: primaryText,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: primaryText,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        color: primaryText,
        fontSize: 19,
        fontWeight: FontWeight.w700,
      ),
    ),
    dividerColor: const Color(0xFFE4EAF1),
  );

  static BoxDecoration get deviceCardDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: const Color(0xFFE3EAF1)),
    boxShadow: const [
      BoxShadow(color: Color(0x0D18324D), blurRadius: 24, offset: Offset(0, 8)),
    ],
  );

  static const Color deviceDividerColor = Color(0xFFE7EDF4);
}
