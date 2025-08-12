import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      primaryColor: const Color(0xFF0A192F),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: const Color(0xFF64FFDA),
        surface: const Color(0xFF112240),
        background: const Color(0xFF0A192F),
        onBackground: const Color(0xFFCCD6F6),
        onSurface: const Color(0xFF8892B0),
      ),
      textTheme: GoogleFonts.montserratTextTheme(),
      scaffoldBackgroundColor: const Color(0xFF0A192F),
    );
  }
}