import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary       = Color(0xFF3A8F85);
  static const Color primaryDark   = Color(0xFF2D7068);
  static const Color primaryLight  = Color(0xFF5BB3A8);
  static const Color accent        = Color(0xFFF4A261);
  static const Color accentPink    = Color(0xFFE07F9C);
  static const Color background    = Color(0xFFF7F9F9);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color inputFill     = Color(0xFFEEF5F4);
  static const Color textPrimary   = Color(0xFF1A2E2C);
  static const Color textSecondary = Color(0xFF6B8A88);
  static const Color textLight     = Color(0xFF9AB5B2);
  static const Color divider       = Color(0xFFE8F0EF);
  static const Color success       = Color(0xFF4CAF7D);
  static const Color warning       = Color(0xFFFFB74D);
  static const Color error         = Color(0xFFE57373);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      surface: surface,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: textPrimary),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
    ),
  );
}
